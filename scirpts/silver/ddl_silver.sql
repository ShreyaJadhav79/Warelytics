/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema.
    - Drops existing tables if they already exist to avoid duplication errors.
    - Adds a column `dwh_create_date` to track when the data was inserted 
      into the Silver layer.
    - Silver tables are usually cleansed and slightly transformed versions of 
      the raw Bronze data.

===============================================================================
NOTE ABOUT SILVER LAYER:
    The Silver Layer is the **clean, standardized version of the Bronze Layer**.
    - It takes raw data from Bronze and applies basic transformations:
        * Cleans and trims text fields.
        * Converts datatypes (e.g., INT → DATE).
        * Handles missing or invalid values.
        * Adds tracking columns like `dwh_create_date`.
    - Purpose:
        * Prepares data for analytics and reporting.
        * Acts as a bridge between raw data (Bronze) and final reporting (Gold).
    - The goal is to make data **accurate, readable, and query-friendly**.

Execution:
    Run this script whenever you need to **rebuild the Silver tables** completely.
===============================================================================
*/

-- ==========================================================
-- Table 1: silver.crm_cust_info
-- Stores cleansed customer information.
-- `dwh_create_date` automatically captures when the record was inserted.
-- ==========================================================
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id             INT,            -- Unique Customer ID
    cst_key            NVARCHAR(50),   -- Key to link with ERP tables
    cst_firstname      NVARCHAR(50),   -- Customer's first name
    cst_lastname       NVARCHAR(50),   -- Customer's last name
    cst_marital_status NVARCHAR(50),   -- Marital status info
    cst_gndr           NVARCHAR(50),   -- Gender of the customer
    cst_create_date    DATE,           -- Date the record was created in source
    dwh_create_date    DATETIME2 DEFAULT GETDATE()  -- Timestamp when data loaded into silver
);
GO


-- ==========================================================
-- Table 2: silver.crm_prd_info
-- Stores product information with links to product categories.
-- `dwh_create_date` is used for data warehouse load tracking.
-- ==========================================================
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id          INT,              -- Unique Product ID
    cat_id          NVARCHAR(50),     -- Category ID from ERP category table
    prd_key         NVARCHAR(50),     -- Key for joining with other tables
    prd_nm          NVARCHAR(50),     -- Product name
    prd_cost        INT,              -- Cost of the product
    prd_line        NVARCHAR(50),     -- Product line/category type
    prd_start_dt    DATE,             -- Start date of product availability
    prd_end_dt      DATE,             -- End date of product availability
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- Timestamp when data loaded into silver
);
GO


-- ==========================================================
-- Table 3: silver.crm_sales_details
-- Stores cleansed sales data including orders, shipments, and revenue.
-- Dates are converted from INT in Bronze to proper DATE format here.
-- ==========================================================
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num     NVARCHAR(50),     -- Sales order number
    sls_prd_key     NVARCHAR(50),     -- Product key linked to crm_prd_info
    sls_cust_id     INT,              -- Customer ID linked to crm_cust_info
    sls_order_dt    DATE,             -- Order date
    sls_ship_dt     DATE,             -- Shipment date
    sls_due_dt      DATE,             -- Due date for delivery
    sls_sales       INT,              -- Total sales amount
    sls_quantity    INT,              -- Quantity sold
    sls_price       INT,              -- Price of product
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- Timestamp when data loaded into silver
);
GO


-- ==========================================================
-- Table 4: silver.erp_loc_a101
-- Stores cleansed location data with country details.
-- ==========================================================
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid             NVARCHAR(50),     -- Customer/Entity ID
    cntry           NVARCHAR(50),     -- Country name
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- Timestamp when data loaded into silver
);
GO


-- ==========================================================
-- Table 5: silver.erp_cust_az12
-- Stores ERP customer details like birthdate and gender.
-- ==========================================================
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid             NVARCHAR(50),     -- Customer ID for linking to CRM data
    bdate           DATE,             -- Birthdate of customer
    gen             NVARCHAR(50),     -- Gender of customer
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- Timestamp when data loaded into silver
);
GO


-- ==========================================================
-- Table 6: silver.erp_px_cat_g1v2
-- Stores product category and sub-category details.
-- Maintenance field might indicate status like 'Active', 'Inactive', etc.
-- ==========================================================
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id              NVARCHAR(50),     -- Category ID
    cat             NVARCHAR(50),     -- Category name
    subcat          NVARCHAR(50),     -- Sub-category name
    maintenance     NVARCHAR(50),     -- Maintenance flag/status
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- Timestamp when data loaded into silver
);
GO
