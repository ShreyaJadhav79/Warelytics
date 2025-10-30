/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN()       --> Finds the smallest value in a column (earliest date in this case)
    - MAX()       --> Finds the largest value in a column (latest date in this case)
    - DATEDIFF()  --> Calculates the difference between two dates
===============================================================================
*/

-- Determine the first and last order date and the total duration in months
SELECT 
    MIN(order_date) AS first_order_date,                 -- Earliest order date
    MAX(order_date) AS last_order_date,                  -- Latest order date
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date))   -- Number of months between first and last order
        AS order_range_months
FROM gold.fact_sales;                                   -- From the fact_sales table in 'gold' schema

-- Find the youngest and oldest customer based on birthdate
SELECT
    MIN(birthdate) AS oldest_birthdate,                 -- Earliest birthdate = oldest customer
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,  -- Age of the oldest customer
    MAX(birthdate) AS youngest_birthdate,               -- Latest birthdate = youngest customer
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age -- Age of the youngest customer
FROM gold.dim_customers;                                -- From the dim_customers table in 'gold' schema
