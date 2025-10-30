/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
       - total orders
       - total sales
       - total quantity purchased
       - total products
       - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value
        - average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;  -- Drop existing view if it exists
GO

CREATE VIEW gold.report_customers AS

WITH base_query AS(
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_customers
---------------------------------------------------------------------------*/
SELECT
    f.order_number,                            -- Unique order identifier
    f.product_key,                              -- Product identifier
    f.order_date,                               -- Date of the order
    f.sales_amount,                             -- Sales amount for this row
    f.quantity,                                 -- Quantity purchased
    c.customer_key,                             -- Unique customer identifier
    c.customer_number,                          -- Customer number
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, -- Full name
    DATEDIFF(year, c.birthdate, GETDATE()) AS age  -- Customer age in years
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL                  -- Only consider valid orders
)

, customer_aggregation AS (
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders,       -- Total number of unique orders
    SUM(sales_amount) AS total_sales,                  -- Total sales by customer
    SUM(quantity) AS total_quantity,                   -- Total items purchased
    COUNT(DISTINCT product_key) AS total_products,     -- Number of unique products purchased
    MAX(order_date) AS last_order_date,                -- Most recent order date
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan  -- Months between first and last order
FROM base_query
GROUP BY 
    customer_key,
    customer_number,
    customer_name,
    age
)

SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    -- Age segmentation
    CASE 
         WHEN age < 20 THEN 'Under 20'
         WHEN age BETWEEN 20 AND 29 THEN '20-29'
         WHEN age BETWEEN 30 AND 39 THEN '30-39'
         WHEN age BETWEEN 40 AND 49 THEN '40-49'
         ELSE '50 and above'
    END AS age_group,
    -- Customer segment based on lifespan and total sales
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) AS recency,  -- Months since last order
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    -- Compute average order value (AOV)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,
    -- Compute average monthly spend
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM customer_aggregation;
