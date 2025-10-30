/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

-- Segment products into cost ranges and count how many products fall into each segment
WITH product_segments AS (
    SELECT
        product_key,            -- Unique product identifier
        product_name,           -- Name of the product
        cost,                   -- Cost of the product
        CASE                     -- Define cost ranges
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,                  -- Cost segment
    COUNT(product_key) AS total_products  -- Number of products in each segment
FROM product_segments
GROUP BY cost_range             -- Group products by cost range
ORDER BY total_products DESC;   -- Sort by descending number of products

-- Segment customers based on spending behavior and lifespan
WITH customer_spending AS (
    SELECT
        c.customer_key,                       -- Unique customer ID
        SUM(f.sales_amount) AS total_spending, -- Total spending of the customer
        MIN(order_date) AS first_order,       -- First order date
        MAX(order_date) AS last_order,        -- Last order date
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan -- Months between first and last order
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key                 -- Aggregate per customer
)
SELECT 
    customer_segment,                        -- VIP / Regular / New
    COUNT(customer_key) AS total_customers   -- Number of customers in each segment
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'       -- High spending long-term customers
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'   -- Moderate spending long-term customers
            ELSE 'New'                                                        -- Short-term customers (<12 months)
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment                    -- Group customers by segment
ORDER BY total_customers DESC;              -- Sort by descending number of customers
