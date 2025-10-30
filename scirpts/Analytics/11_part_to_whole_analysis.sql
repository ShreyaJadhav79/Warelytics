/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations across all rows.
===============================================================================
*/

-- Which categories contribute the most to overall sales?
WITH category_sales AS (
    SELECT
        p.category,                 -- Product category
        SUM(f.sales_amount) AS total_sales  -- Total sales for each category
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p      -- Join to get category name
        ON p.product_key = f.product_key
    GROUP BY p.category                -- Aggregate by category
)
SELECT
    category,                           -- Category name
    total_sales,                        -- Total sales for this category
    SUM(total_sales) OVER () AS overall_sales,  -- Total sales across all categories
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
        -- Calculate what % this category contributes to overall sales, rounded to 2 decimals
FROM category_sales
ORDER BY total_sales DESC;            -- Sort from highest contributing category to lowest
