/*
===============================================================================================
Srored Procedure: Load Silver Layer
===============================================================================================

Script Purpose:
  This stored procedure performs ETL (Extarct, Transform, Load) process to
  populate the 'silver' schema tables from the 'bronze' tables.

Action Performed:
  - Truncates silver tables.
  - Inserts cleansed and transformed data from Bronze tables into Silver tables.

Parameters:
  None.
  This Stored Procedure does not accept any parameters or return any values.

Usage Example:
  EXEC silver.load_silver;

*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	BEGIN TRY
	DECLARE  @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
		SET @batch_start_time = GETDATE()
		PRINT('=====================================================================================')
		PRINT('Loading Silver Layer')
		PRINT('======================================================================================')
		
		PRINT('------------------------------------------------------------------------------------------')
		PRINT('Loading CRM Tables')
		PRINT('------------------------------------------------------------------------------------------')
		
		
		SET @start_time = GETDATE() 
		PRINT('>> Truncating Table: silver.crm_cust_info')
		TRUNCATE TABLE silver.crm_cust_info
		PRINT('>> Insert Data Into: silver.crm_cust_info')
		INSERT INTO silver.crm_cust_info(cst_id, cst_number, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) cst_firstname,
			TRIM(cst_lastname) cst_lastname,
			CASE
				WHEN UPPER(TRIM(cst_marital_status)) IN ('M', 'MARRIED') THEN 'Married'
				WHEN UPPER(TRIM(cst_marital_status)) IN ('S', 'SINGLE') THEN 'Single'
				ELSE 'n/a'
			END cst_marital_status,
			CASE
				WHEN UPPER(TRIM(cst_gndr)) IN ('M', 'MALE') THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) IN ('F', 'FEMALE') THEN 'Female'
				ELSE 'n/a'
			END cst_gndr,
			cst_create_date
		FROM
		(
		SELECT
			*,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) id_flag
		FROM bronze.crm_cust_info
		) t
		WHERE id_flag = 1 AND cst_id IS NOT NULL
		SET @end_time = GETDATE()
		PRINT('>> Load Duration ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.')
		PRINT('------------------------------------------------------------------------------------------')
		PRINT('')
		PRINT('>> Truncating Table: silver.crm_prd_info')
		TRUNCATE TABLE silver.crm_prd_info
		PRINT('>> Insert Data Into: silver.crm_prd_info')
		INSERT INTO silver.crm_prd_info(prd_id, prd_number, prd_cat, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
		SELECT
			prd_id,
			SUBSTRING(UPPER(TRIM(prd_key)), 7, LEN(prd_key)) prd_number,
			SUBSTRING(UPPER(TRIM(REPLACE(prd_key, '-', '_'))), 1, 5) prd_cat,
			prd_nm,
			CASE
				WHEN prd_cost IS NULL OR prd_cost < 0 THEN 0
				ELSE prd_cost
			END prd_cost,
			CASE 
				UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END prd_line,
			prd_start_dt,
			LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_id) - 1 prd_end_dt
		FROM bronze.crm_prd_info
		SET @end_time = GETDATE()
		PRINT('>> Load Duration ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.')
		PRINT('------------------------------------------------------------------------------------------')
		PRINT('')
		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: silver.crm_sales_details')
		TRUNCATE TABLE silver.crm_sales_details
		PRINT('>> Insert Data Into: silver.crm_sales_details')
		INSERT INTO silver.crm_sales_details(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE
				WHEN LEN(sls_order_dt) = 8 THEN CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE)
				ELSE NULL
			END sls_order_dt,
			CASE
				WHEN LEN(sls_ship_dt) = 8 THEN CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE)
				ELSE NULL
			END sls_ship_dt,
			CASE 
				WHEN LEN(sls_due_dt) = 8 THEN CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE)
				ELSE NULL
			END sls_due_dt,
			CASE
				WHEN sls_sales != sls_price * sls_quantity OR sls_sales IS NULL OR sls_sales <= 0 THEN ABS(sls_price) * sls_quantity
				ELSE sls_sales
			END sls_sales,
			sls_quantity,
			CASE
				WHEN sls_price IS NULL OR sls_price <= 0 THEN ABS(sls_sales) / NULLIF(sls_quantity, 0) 
				ELSE sls_price
			END sls_price
		FROM bronze.crm_sales_details
		SET @end_time = GETDATE()
		PRINT('>> Load Duration ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.')
		PRINT('------------------------------------------------------------------------------------------')
		PRINT('')
		PRINT('------------------------------------------------------------------------------------------')
		PRINT('Loading ERP Tables')
		PRINT('------------------------------------------------------------------------------------------')
		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: silver.erp_cust_az12')
		TRUNCATE TABLE silver.erp_cust_az12
		PRINT('>> Insert Data Into: silver.erp_cust_az12' )
		INSERT INTO silver.erp_cust_az12(cid, bdate, gen)
		SELECT
			REPLACE(UPPER(TRIM(cid)), 'NAS', '') cid,
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END bdate,
			CASE
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				ELSE 'n/a'
			END gen
		FROM bronze.erp_cust_az12
		SET @end_time =  GETDATE()
		PRINT('>> Load Duration ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.')
		PRINT('------------------------------------------------------------------------------------------')
		PRINT('')
		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: silver.erp_loc_a101')
		TRUNCATE TABLE silver.erp_loc_a101
		PRINT('>> Insert Data Into: silver.erp_loc_a101')
		INSERT INTO silver.erp_loc_a101(cid, cntry)
		SELECT
			REPLACE(UPPER(TRIM(cid)), '-', '') cid,
			CASE
				WHEN UPPER(TRIM(cntry)) IN ('DE', 'DEU', 'GERMANY') THEN 'Germany'
				WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
				WHEN UPPER(TRIM(cntry)) IN ('AU', 'AUS', 'AUSTRALIA') THEN 'Australia'
				WHEN UPPER(TRIM(cntry)) IN ('GB', 'GBR', 'UNITED KINGDOM') THEN 'United Kingdom'
				WHEN UPPER(TRIM(cntry)) IN ('CA', 'CAN', 'CANADA') THEN 'Canada'
				WHEN UPPER(TRIM(cntry)) IN ('FR', 'FRA', 'FRANCE') THEN 'France'
				ELSE 'n/a'
			END cntry
		FROM bronze.erp_loc_a101
		SET @end_time = GETDATE()
		PRINT('>> Load Duration ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds.')
		PRINT('------------------------------------------------------------------------------------------')
		PRINT('')
		SET @start_time = GETDATE()
		PRINT('Truncating Table: silver.erp_cat_g1v2')
		TRUNCATE TABLE silver.erp_px_cat_g1v2
		PRINT('Insert Data Into: silver.erp_cat_g1v2')
		INSERT INTO silver.erp_px_cat_g1v2(id, cat, subcat, maintenance)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2
		SET @end_time = GETDATE()
		PRINT('>> Load Duration ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' miliiseconds.')
		PRINT('------------------------------------------------------------------------------------------')
		PRINT('')
		SET @batch_end_time = GETDATE()
		PRINT('=====================================================================================')
		PRINT('Loading Silver Layer is Completed')
		PRINT('>> Total Load Duration ' + CAST(DATEDIFF(MILLISECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' milliseconds.')
		PRINT('======================================================================================')

	END TRY
	
	BEGIN CATCH
		PRINT('An Error Occured')
		PRINT('Error Message: ' + ERROR_MESSAGE())
		PRINT('Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR))
		PRINT('Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR))
		PRINT('Error Procedure: ' + CAST(ERROR_PROCEDURE() AS NVARCHAR))
	END CATCH
END

