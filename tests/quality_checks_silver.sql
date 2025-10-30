/*
===============================================================================
Quality Checks for Silver Layer
===============================================================================
Script Purpose:
    This script performs various **data quality checks** for data consistency, 
    accuracy, and standardization across the **Silver Layer** tables.

    The checks include:
    1. Null or duplicate primary keys.
    2. Unwanted leading/trailing spaces in string fields.
    3. Data standardization and consistency checks.
    4. Invalid date ranges and incorrect date orders.
    5. Business rule validation (e.g., Sales = Quantity * Price).

Why These Checks Are Important:
    - Silver Layer contains **cleaned and standardized data** derived from the Bronze Layer.
    - These checks help ensure the data is **accurate and reliable** before loading into the Gold Layer.
    - Fixing issues here prevents bad data from propagating into reporting and analytics.

Usage Notes:
    - Run these checks **after loading data into Silver Layer**.
    - **Expected Results**: Most queries should return **0 rows**.
    - If a query returns rows, those are **data quality issues** that must be investigated and resolved.
===============================================================================
*/

-- =============================================================================
-- 1. CHECKING 'silver.crm_cust_info'
-- =============================================================================

-- Check for NULL or Duplicate Primary Key (cst_id)
-- Expectation: No duplicates or NULLs should exist.
SELECT 
    cst_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces in Customer Key
-- Expectation: No leading or trailing spaces.
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Data Standardization: Marital Status values
-- Purpose: Identify inconsistent or unexpected values.
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;

-- =============================================================================
-- 2. CHECKING 'silver.crm_prd_info'
-- =============================================================================

-- Check for NULL or Duplicate Primary Key (prd_id)
-- Expectation: No duplicates or NULLs should exist.
SELECT 
    prd_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces in Product Name
-- Expectation: No leading or trailing spaces.
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULL or Negative Product Cost
-- Expectation: Cost must be non-negative and not NULL.
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization: Product Line
-- Purpose: Identify inconsistent or unexpected values.
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: Start date should always be before or equal to End date.
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- =============================================================================
-- 3. CHECKING 'silver.crm_sales_details'
-- =============================================================================

-- Check for Invalid Dates in Bronze before loading
-- Purpose: Identify invalid dates in raw data (Bronze Layer).
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;

-- Check for Invalid Date Orders (Order Date > Ship Date or Due Date)
-- Expectation: Order date should be on or before both ship date and due date.
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: The multiplication must match the sales column.
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- =============================================================================
-- 4. CHECKING 'silver.erp_cust_az12'
-- =============================================================================

-- Identify Out-of-Range Birthdates
-- Expectation: Birthdates must be between 1924-01-01 and today.
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- Data Standardization: Gender
-- Purpose: Identify inconsistent or unexpected gender values.
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;

-- =============================================================================
-- 5. CHECKING 'silver.erp_loc_a101'
-- =============================================================================

-- Data Standardization: Country
-- Purpose: Review and standardize country names.
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- =============================================================================
-- 6. CHECKING 'silver.erp_px_cat_g1v2'
-- =============================================================================

-- Check for Unwanted Spaces in Category Fields
-- Expectation: No leading or trailing spaces.
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Data Standardization: Maintenance
-- Purpose: Identify inconsistent or unexpected maintenance values.
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;

/*
===============================================================================
FINAL NOTES
===============================================================================
1. Silver Layer Role:
    - Silver Layer holds **cleaned and standardized data**.
    - It acts as a staging area before data is transformed into business-ready
      structures in the Gold Layer.

2. Why Quality Checks?
    - Detect issues early before they reach the Gold Layer.
    - Ensure data is **accurate, complete, and ready for analytics**.

3. Expected Results:
    - Ideally, every query should return **0 rows**, except the ones designed to 
      show distinct values (for review).

4. Workflow:
    Bronze → Silver → Run Quality Checks → Gold → Final Quality Checks
===============================================================================
*/
