/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows to compare trends.
    - AVG() OVER(): Computes average values within partitions for comparison.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
   to both the average sales performance of the product and the previous year's sales */
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,       -- Extract year from order_date
        p.product_name,                          -- Product name
        SUM(f.sales_amount) AS current_sales     -- Total sales for that product in the year
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key         -- Join to get product names
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)
SELECT
    order_year,                                    -- Year of sales
    product_name,                                  -- Product name
    current_sales,                                 -- Total sales for that year
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,  -- Average sales across all years for that product
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,  -- Difference from average
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'  -- Performance above average
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'  -- Performance below average
        ELSE 'Avg'  -- Exactly average
    END AS avg_change,
    
    -- Year-over-Year Analysis
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,  -- Previous year's sales
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,  -- Difference from previous year
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'  -- Sales increased
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'  -- Sales decreased
        ELSE 'No Change'  -- Sales remained same
    END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;  -- Sort by product and year for readability
