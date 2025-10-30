/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - These queries are meant for validation only, not for production ETL runs.
    - Investigate and resolve any discrepancies found during the checks.
    - The checks should return **no records** if everything is correct.
===============================================================================
*/

-- ====================================================================
-- CHECK 1: Uniqueness of 'customer_key' in gold.dim_customers
-- ====================================================================
-- Purpose:
--     - Each customer_key should be unique in the dimension table.
--     - Duplicate keys indicate data quality issues or incorrect joins.
-- Expectation:
--     - This query should return **0 rows** if there are no duplicates.
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- CHECK 2: Uniqueness of 'product_key' in gold.dim_products
-- ====================================================================
-- Purpose:
--     - Each product_key should be unique in the dimension table.
--     - Ensures there are no duplicate product records.
-- Expectation:
--     - This query should return **0 rows** if data quality is good.
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- CHECK 3: Referential Integrity between fact and dimensions
-- ====================================================================
-- Purpose:
--     - Ensure that every foreign key in the fact table matches a key in the
--       corresponding dimension tables.
--     - Helps validate the star schema relationships.
-- Logic:
--     - Perform LEFT JOIN from fact table to dimensions.
--     - If a product_key or customer_key is missing in the dimension,
--       it will show as NULL in the result.
-- Expectation:
--     - This query should return **0 rows** if integrity is perfect.
SELECT 
    f.order_number,
    f.product_key,
    f.customer_key,
    p.product_key AS product_exists,
    c.customer_key AS customer_exists
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL  -- Missing product in dimension
   OR c.customer_key IS NULL; -- Missing customer in dimension

/*
===============================================================================
NOTES ON GOLD LAYER
===============================================================================
1. Gold Layer contains **business-ready data**, which is modeled using a Star Schema:
    - Dimension Tables: gold.dim_customers, gold.dim_products
    - Fact Table: gold.fact_sales

2. Why Quality Checks?
    - Prevents issues like:
        a) Duplicate records in dimensions.
        b) Orphan records in fact tables (i.e., facts without matching dimension keys).
        c) Ensures reliable and accurate analytics.

3. Best Practice:
    - Run these quality checks **after every ETL pipeline run**.
    - Investigate and fix any mismatches before publishing data for reporting.

4. Ideal Workflow:
    - Bronze → Silver → Gold → Quality Checks
===============================================================================
*/
