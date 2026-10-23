/*
===========================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===========================================================================

Script Purpose:
  This stored procedure loads data into the 'bronze' schema from external CSV files.
  It performs the following actions:
  - Truncates the bronze tables before loading data.
  - Uses the 'BULK INSERT' command to load data from csv Files to bronze tables.

Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC bronze.load_bronze;
=============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	BEGIN TRY
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
		SET @batch_start_time = GETDATE()
		PRINT('================================================================================')
		PRINT('-- Load Bronze Layer --') 
		PRINT('================================================================================')

		PRINT('--------------------------------------------------------------------------------')
		PRINT('-- Load CMR Tables --')
		PRINT('--------------------------------------------------------------------------------')


		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: bronze.crm_cust_info')
		TRUNCATE TABLE bronze.crm_cust_info
		PRINT('>> Inserting Data Into: bronze.crm_info')
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\barti\Desktop\datasets\source_crm\cust_info.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.')
		PRINT('--------------------------------------------------------------------------------')


		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: bronze.crm_prd_info')
		TRUNCATE TABLE bronze.crm_prd_info
		PRINT('>> Insert Data Into: bronze.cmr_prd_imfo')
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\barti\Desktop\datasets\source_crm\prd_info.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.')
		PRINT('--------------------------------------------------------------------------------')

		PRINT('>> Truncating Table: bronze.crm_sales_details')
		TRUNCATE TABLE bronze.crm_sales_details
		PRINT('>> Insert Data Into: bronze.crm_sales_details')
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\barti\Desktop\datasets\source_crm\sales_details.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.')
		PRINT('--------------------------------------------------------------------------------')
		
		PRINT('--------------------------------------------------------------------------------')
		PRINT('-- Loading ERP Tables --')
		PRINT('--------------------------------------------------------------------------------')

		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: bronze.erp_cust_az12')
		TRUNCATE TABLE bronze.erp_cust_az12
		PRINT('>> Insert Data Into: bronze.erp_cust_az12')
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\barti\Desktop\datasets\source_erp\cust_az12.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.')
	
		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: bronze.erp_loc101')
		TRUNCATE TABLE bronze.erp_loc_a101
		PRINT('>> Insert Data Into: bronze.erp_loc101')
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\barti\Desktop\datasets\source_erp\loc_a101.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.')
		PRINT('--------------------------------------------------------------------------------')
		
		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: bronze.px_cat_g1v2')
		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		PRINT('>> Insert Data Into: bronze.px_cat_g1v2')
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\barti\Desktop\datasets\source_erp\px_cat_g1v2.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.')
		PRINT('--------------------------------------------------------------------------------')
		SET @batch_end_time = GETDATE()
		PRINT('================================================================================')
		PRINT('>> Load Bronze Layer Sucessfully')
		PRINT('>> Total Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' millliseconds.')
		PRINT('================================================================================')

	END TRY

	BEGIN CATCH
		PRINT('An Error Occured')
		PRINT('Error Message: ' + ERROR_MESSAGE())
		PRINT('Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR))
		PRINT('Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR))
		PRINT('Error Procedure: ' + CAST(ERROR_PROCEDURE() AS NVARCHAR))
	END CATCH
END;


