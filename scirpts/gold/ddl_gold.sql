/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================

Script Purpose:
    This script creates views for the **Gold Layer** in the data warehouse. 
    The **Gold Layer** represents the final dimension and fact tables 
    (Star Schema).

Gold Layer Concept:
    - The **Gold Layer** contains **business-ready data** for reporting and analytics.
    - It is built on top of the **Silver Layer**, which contains cleaned and standardized data.
    - The Gold Layer:
        1. Combines multiple Silver tables to form **Dimensions** (e.g., Customers, Products).
        2. Creates **Fact tables** for transactional data (e.g., Sales).
        3. Generates a **Star Schema** that is easy for BI tools and reporting.

Usage:
    - These views can be queried directly for analytics and reporting.
    - BI dashboards (Power BI, Tableau, etc.) will typically connect to these views.

Structure of the Script:
    1. Create **Customer Dimension View**: gold.dim_customers
    2. Create **Product Dimension View**: gold.dim_products
    3. Create **Sales Fact View**: gold.fact_sales

===============================================================================
*/

-- =============================================================================
-- DIMENSION 1: gold.dim_customers
-- Purpose:
--    This dimension combines customer info from CRM and ERP systems.
--    It enriches CRM data with location and ERP-specific attributes.
-- =============================================================================

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    -- Create surrogate key for dimensional modeling
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, 

    -- Business keys and attributes
    ci.cst_id                          AS customer_id,        -- Customer ID from CRM
    ci.cst_key                         AS customer_number,    -- Customer key from CRM
    ci.cst_firstname                   AS first_name,         -- First name
    ci.cst_lastname                    AS last_name,          -- Last name
    la.cntry                           AS country,            -- Country name from ERP location table
    ci.cst_marital_status              AS marital_status,     -- Standardized marital status

    -- Gender selection logic:
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr            -- Use CRM gender if available
        ELSE COALESCE(ca.gen, 'n/a')                          -- Else fallback to ERP gender
    END AS gender,

    ca.bdate                           AS birthdate,           -- Birthdate from ERP
    ci.cst_create_date                 AS create_date          -- Customer creation date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid             -- Match ERP data using customer key
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;            -- Match location info using customer key
GO

-- =============================================================================
-- DIMENSION 2: gold.dim_products
-- Purpose:
--    This dimension standardizes product data and joins with product category
--    data from ERP.
--    It only includes currently active products (prd_end_dt IS NULL).
-- =============================================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    -- Create surrogate key for product dimension
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, 

    -- Product attributes
    pn.prd_id       AS product_id,        -- Original product ID
    pn.prd_key      AS product_number,    -- Cleaned product number
    pn.prd_nm       AS product_name,      -- Product name
    pn.cat_id       AS category_id,       -- Category ID
    pc.cat          AS category,          -- Category name
    pc.subcat       AS subcategory,       -- Sub-category name
    pc.maintenance  AS maintenance,       -- Maintenance status

    -- Financial and operational attributes
    pn.prd_cost     AS cost,              -- Product cost
    pn.prd_line     AS product_line,      -- Type of product (e.g., Mountain, Road)
    pn.prd_start_dt AS start_date         -- Start date of product
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id                  -- Join category information
WHERE pn.prd_end_dt IS NULL;              -- Exclude historical/inactive products
GO

-- =============================================================================
-- FACT TABLE: gold.fact_sales
-- Purpose:
--    This fact table contains all sales transactions.
--    It connects to dimension tables through surrogate keys.
--    This forms the "center" of the Star Schema.
-- =============================================================================

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,      -- Sales order number

    -- Foreign keys to connect with dimensions
    pr.product_key  AS product_key,       -- Surrogate key from gold.dim_products
    cu.customer_key AS customer_key,      -- Surrogate key from gold.dim_customers

    -- Dates for analysis
    sd.sls_order_dt AS order_date,        -- Order date
    sd.sls_ship_dt  AS shipping_date,     -- Ship date
    sd.sls_due_dt   AS due_date,          -- Due date

    -- Sales metrics
    sd.sls_sales    AS sales_amount,      -- Total sales amount
    sd.sls_quantity AS quantity,          -- Quantity sold
    sd.sls_price    AS price              -- Unit price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number     -- Match product
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;       -- Match customer
GO
