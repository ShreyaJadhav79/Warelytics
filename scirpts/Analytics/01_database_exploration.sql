/* =============================================================================== 
   Database Exploration
   ===============================================================================
   Purpose:
       - To explore the structure of the database, including the list of tables and their schemas.
       - To inspect the columns and metadata for specific tables.
   
   Tables Used:
       - INFORMATION_SCHEMA.TABLES      --> Contains information about all tables in the database
       - INFORMATION_SCHEMA.COLUMNS     --> Contains information about all columns in each table
============================================================================== */

-- Retrieve a list of all tables in the database
-- This query will show the catalog, schema, table name, and type (BASE TABLE or VIEW)
SELECT
     TABLE_CATALOG,           -- The database/catalog name
     TABLE_SCHEMA,            -- The schema name (like 'dbo' in SQL Server)
     TABLE_NAME,              -- Name of the table
     TABLE_TYPE               -- Type of table (BASE TABLE or VIEW)
FROM INFORMATION_SCHEMA.TABLES;

-- Retrieve all columns for a specific table (dim_customers)
-- This query will show column name, data type, nullability, and max length for each column in the table
SELECT
     COLUMN_NAME,             -- Name of the column
     DATA_TYPE,               -- Data type of the column (e.g., INT, VARCHAR)
     IS_NULLABLE,             -- Whether the column allows NULL values ('YES' or 'NO')
     CHARACTER_MAXIMUM_LENGTH -- Maximum length for character-based columns (NULL for numeric types)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';  -- Filter to only show columns for the 'dim_customers' table
