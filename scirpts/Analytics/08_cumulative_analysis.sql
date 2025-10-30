/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()  --> Calculate cumulative or moving metrics
===============================================================================
*/

-- Calculate the total sales per year 
-- and the running total of sales over time 
SELECT
	order_date,                                 -- Year of the order (truncated to start of year)
	total_sales,                                -- Total sales in that year
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,  -- Cumulative sales up to that year
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price    -- Average price over time (moving average)
FROM
(
    -- Subquery: Aggregate sales and average price per year
    SELECT 
        DATETRUNC(year, order_date) AS order_date,  -- Truncate date to year (e.g., 2025-01-01)
        SUM(sales_amount) AS total_sales,          -- Total sales for the year
        AVG(price) AS avg_price                     -- Average selling price for the year
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL                    -- Ensure valid dates only
    GROUP BY DATETRUNC(year, order_date)           -- Aggregate data per year
) t                                               -- Subquery aliased as 't' for window function calculations
