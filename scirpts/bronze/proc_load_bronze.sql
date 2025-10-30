/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    - This stored procedure loads data into the 'bronze' schema from external CSV files.
    - It is the **first step in your ETL pipeline**.
    - The bronze layer stores **raw, unprocessed data** directly from source files.

Process Flow:
    1. Truncate (empty) each bronze table to avoid duplicate data.
    2. Load data from CSV files into each table using `BULK INSERT`.
    3. Print duration logs to monitor performance.
    4. Handle any errors gracefully with TRY...CATCH block.

Parameters:
    - None (This procedure does not accept input parameters).

How to Execute:
    EXEC bronze.load_bronze;

===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    -- Declare variables to track timings for logging
    DECLARE @start_time DATETIME,       -- Tracks start time for each table load
            @end_time DATETIME,         -- Tracks end time for each table load
            @batch_start_time DATETIME, -- Start time for entire bronze load
            @batch_end_time DATETIME;   -- End time for entire bronze load

    BEGIN TRY
        ------------------------------------------------------------------------
        -- Start of Bronze Layer Loading Process
        ------------------------------------------------------------------------
        SET @batch_start_time = GETDATE();  -- Mark the beginning of the load
        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';

        ------------------------------------------------------------------------
        -- STEP 1: Load CRM Tables
        ------------------------------------------------------------------------
        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';

        ------------------------------------------------------------------------
        -- 1.1 Load crm_cust_info (Customer Information)
        ------------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info; -- Empty the table before inserting new data

        PRINT '>> Inserting Data Into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\sql\dwh_project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,              -- Skip header row
            FIELDTERMINATOR = ',',     -- CSV file uses comma as delimiter
            TABLOCK                     -- Improves performance for bulk loads
        );

        -- Log load time for this table
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        ------------------------------------------------------------------------
        -- 1.2 Load crm_prd_info (Product Information)
        ------------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\sql\dwh_project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        ------------------------------------------------------------------------
        -- 1.3 Load crm_sales_details (Sales Transactions)
        ------------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\sql\dwh_project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        ------------------------------------------------------------------------
        -- STEP 2: Load ERP Tables
        ------------------------------------------------------------------------
        PRINT '------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------';

        ------------------------------------------------------------------------
        -- 2.1 Load erp_loc_a101 (Location Information)
        ------------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\sql\dwh_project\datasets\source_erp\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        ------------------------------------------------------------------------
        -- 2.2 Load erp_cust_az12 (Customer Birthdate & Gender)
        ------------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\sql\dwh_project\datasets\source_erp\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        ------------------------------------------------------------------------
        -- 2.3 Load erp_px_cat_g1v2 (Product Category Information)
        ------------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\sql\dwh_project\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        ------------------------------------------------------------------------
        -- End of Bronze Layer Loading
        ------------------------------------------------------------------------
        SET @batch_end_time = GETDATE();

        PRINT '==========================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';
    
    END TRY

    ------------------------------------------------------------------------
    -- Error Handling Section (CATCH Block)
    ------------------------------------------------------------------------
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();                  -- Detailed error message
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);  -- SQL error number
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);    -- SQL error state
        PRINT '==========================================';
    END CATCH
END
