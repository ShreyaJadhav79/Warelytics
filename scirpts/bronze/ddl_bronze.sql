/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    - This script creates all the required tables in the 'bronze' schema.
    - If a table already exists, it will be dropped first (to avoid conflicts).
    - These bronze tables act as the **raw data layer** in the data warehouse.
    - You should run this script whenever you want to reset/rebuild your bronze layer.

NOTE:
    - 'bronze' schema holds unprocessed data directly loaded from source systems.
    - We use 'GO' statements to separate each batch execution in SQL Server.
===============================================================================
*/

--------------------------------------------------------------------------------
-- Step 1: Drop and Create bronze.crm_cust_info
-- Purpose: Store customer information from CRM system
--------------------------------------------------------------------------------
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;   -- Drop the table if it already exists
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,           -- Unique numeric ID for each customer
    cst_key             NVARCHAR(50),  -- Business key or natural key from source
    cst_firstname       NVARCHAR(50),  -- Customer first name
    cst_lastname        NVARCHAR(50),  -- Customer last name
    cst_marital_status  NVARCHAR(50),  -- Marital status (Single, Married, etc.)
    cst_gndr            NVARCHAR(50),  -- Gender (Male, Female, etc.)
    cst_create_date     DATE           -- Date when the customer record was created
);
GO

--------------------------------------------------------------------------------
-- Step 2: Drop and Create bronze.crm_prd_info
-- Purpose: Store product details from CRM system
--------------------------------------------------------------------------------
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,            -- Unique product ID
    prd_key      NVARCHAR(50),   -- Composite product key (category + product code)
    prd_nm       NVARCHAR(50),   -- Product name
    prd_cost     INT,            -- Product cost
    prd_line     NVARCHAR(50),   -- Product line (e.g., Mountain, Road, etc.)
    prd_start_dt DATETIME,       -- Start date of the product availability
    prd_end_dt   DATETIME        -- End date of the product availability
);
GO

--------------------------------------------------------------------------------
-- Step 3: Drop and Create bronze.crm_sales_details
-- Purpose: Store sales transactions from CRM system
--------------------------------------------------------------------------------
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),   -- Sales order number (unique order identifier)
    sls_prd_key  NVARCHAR(50),   -- Product key (links to product table)
    sls_cust_id  INT,            -- Customer ID (links to customer table)
    sls_order_dt INT,            -- Order date (stored as integer in format YYYYMMDD)
    sls_ship_dt  INT,            -- Shipment date (stored as integer YYYYMMDD)
    sls_due_dt   INT,            -- Due date for the order (stored as integer YYYYMMDD)
    sls_sales    INT,            -- Total sales amount for the order
    sls_quantity INT,            -- Quantity of product sold
    sls_price    INT             -- Price of the product
);
GO

--------------------------------------------------------------------------------
-- Step 4: Drop and Create bronze.erp_loc_a101
-- Purpose: Store location details from ERP system
--------------------------------------------------------------------------------
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid    NVARCHAR(50),  -- Customer ID (used to join with other ERP/CRM tables)
    cntry  NVARCHAR(50)   -- Country code or name (e.g., 'US', 'DE', etc.)
);
GO

--------------------------------------------------------------------------------
-- Step 5: Drop and Create bronze.erp_cust_az12
-- Purpose: Store additional customer details from ERP system
--------------------------------------------------------------------------------
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid    NVARCHAR(50),  -- Customer ID (primary reference key)
    bdate  DATE,          -- Birthdate of the customer
    gen    NVARCHAR(50)   -- Gender ('M', 'F', 'Male', 'Female')
);
GO

--------------------------------------------------------------------------------
-- Step 6: Drop and Create bronze.erp_px_cat_g1v2
-- Purpose: Store product category information from ERP system
--------------------------------------------------------------------------------
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           NVARCHAR(50),  -- Product ID (reference to product table)
    cat          NVARCHAR(50),  -- Product category (e.g., 'Electronics')
    subcat       NVARCHAR(50),  -- Sub-category (e.g., 'Mobile Phones')
    maintenance  NVARCHAR(50)   -- Maintenance info or description
);
GO
