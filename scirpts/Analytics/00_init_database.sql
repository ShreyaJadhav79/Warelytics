/* 
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' 
    after checking if it already exists. 
    - If the database exists, it is dropped and recreated. 
    - Additionally, this script creates a schema called 'gold'.
	
WARNING:       
    Running this script will DROP the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. 
    Proceed with caution and ensure you have proper backups before running this script.
*/

-- Switch to the master database before creating or dropping any database
USE master;
GO

-- ====================================================================
-- Step 1: Drop the 'DataWarehouseAnalytics' database if it already exists
-- ====================================================================
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    -- Change database to SINGLE_USER mode to disconnect all users
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    
    -- Drop the database
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- ====================================================================
-- Step 2: Create a new database named 'DataWarehouseAnalytics'
-- ====================================================================
CREATE DATABASE DataWarehouseAnalytics;
GO

-- Switch to the newly created database
USE DataWarehouseAnalytics;
GO

-- ====================================================================
-- Step 3: Create a new schema named 'gold'
-- ====================================================================
CREATE SCHEMA gold;
GO

/* ===================================================================
   Step 4: Create the Gold Layer Tables
   - These tables contain clean, business-ready data for reporting and analytics
   - Follows a STAR schema design with Dimension and Fact tables
   =================================================================== */

-- Create Dimension Table: Customers
CREATE TABLE gold.dim_customers(
	customer_key int,              -- Surrogate key (primary key for analytics)
	customer_id int,               -- Original customer ID from source
	customer_number nvarchar(50),  -- Customer number/code
	first_name nvarchar(50),       -- First name of the customer
	last_name nvarchar(50),        -- Last name of the customer
	country nvarchar(50),          -- Customer's country
	marital_status nvarchar(50),   -- Marital status (Single/Married)
	gender nvarchar(50),           -- Gender (M/F/Other)
	birthdate date,                 -- Date of birth
	create_date date                -- Date customer was created in system
);
GO

-- Create Dimension Table: Products
CREATE TABLE gold.dim_products(
	product_key int,               -- Surrogate key (primary key for analytics)
	product_id int,                 -- Original product ID from source
	product_number nvarchar(50),    -- Product code/number
	product_name nvarchar(50),      -- Product name
	category_id nvarchar(50),       -- Category ID
	category nvarchar(50),          -- Product category
	subcategory nvarchar(50),       -- Product subcategory
	maintenance nvarchar(50),       -- Maintenance type (e.g., Standard, Premium)
	cost int,                        -- Product cost
	product_line nvarchar(50),      -- Product line
	start_date date                  -- Date the product became active
);
GO

-- Create Fact Table: Sales
CREATE TABLE gold.fact_sales(
	order_number nvarchar(50),      -- Order number
	product_key int,                -- Foreign key referencing dim_products
	customer_key int,               -- Foreign key referencing dim_customers
	order_date date,                 -- Date of the order
	shipping_date date,              -- Date when the order was shipped
	due_date date,                   -- Expected delivery date
	sales_amount int,                 -- Total sales amount
	quantity tinyint,                 -- Quantity of products sold
	price int                         -- Price per unit
);
GO

/* ===================================================================
   Step 5: Load Data into Gold Tables using BULK INSERT
   - Assumes that CSV files are present at the specified location
   - FIRSTROW = 2 skips the header row in the CSV file
   - FIELDTERMINATOR = ',' specifies comma-separated values
   - TABLOCK improves performance by locking the table during bulk load
   =================================================================== */

-- ================================================================
-- Load Data into gold.dim_customers
-- ================================================================
TRUNCATE TABLE gold.dim_customers; -- Clear table before loading new data
GO

BULK INSERT gold.dim_customers
FROM 'C:\Users\Shreya\Downloads\sql-data-analytics-project-main\datasets\csv-files\gold.dim_customers.csv'
WITH (
	FIRSTROW = 2,             -- Skip the header row
	FIELDTERMINATOR = ',',     -- Columns are separated by commas
	TABLOCK                     -- Lock table for faster bulk insert
);
GO

-- ================================================================
-- Load Data into gold.dim_products
-- ================================================================
TRUNCATE TABLE gold.dim_products; -- Clear table before loading new data
GO

BULK INSERT gold.dim_products
FROM 'C:\Users\Shreya\Downloads\sql-data-analytics-project-main\datasets\csv-files\gold.dim_products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

-- ================================================================
-- Load Data into gold.fact_sales
-- ================================================================
TRUNCATE TABLE gold.fact_sales; -- Clear table before loading new data
GO

BULK INSERT gold.fact_sales
FROM 'C:\Users\Shreya\Downloads\sql-data-analytics-project-main\datasets\csv-files\gold.fact_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO
