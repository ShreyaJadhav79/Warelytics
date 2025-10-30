/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT     --> Ensures only unique values are returned, removing duplicates
    - ORDER BY     --> Sorts the results in ascending order by default
===============================================================================
*/

-- Retrieve a list of unique countries from which customers originate
SELECT DISTINCT 
    country                 -- Select only the country column
FROM gold.dim_customers     -- From the dim_customers dimension table in the 'gold' schema
ORDER BY country;           -- Sort the countries alphabetically

-- Retrieve a list of unique categories, subcategories, and products
SELECT DISTINCT 
    category,               -- Product category
    subcategory,            -- Subcategory within the category
    product_name            -- Name of the product
FROM gold.dim_products      -- From the dim_products dimension table in the 'gold' schema
ORDER BY category, subcategory, product_name;  -- Sort first by category, then subcategory, then product
