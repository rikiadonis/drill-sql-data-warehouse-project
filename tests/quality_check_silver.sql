/*
=================================================================================
Quality Chcks: Silver Layer
=================================================================================

Script Purpose:
  This script performs various qulaity checks for data standardization, accuracy, 
  and consistency across 'silver' schemas. It includes checks for:
  - Null or duplicate primary keys.
  - Unwanted spaces in string fields.
  - Data standardization & consistency.
  - Invalid date ranges or orders.
  - Data consistency between related fields.

Usage Notes:
  - Run these check after loading Silver Layer.
  - Investigate and resolve any discrepancies during found the checks.
====================================================================================
*/

-- Data Correcteness

-- Check for Nulls or Dupicates in Primary Key
-- Expectaction: No Result
SELECT
	cst_id,
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1


-- Check for Unwanted Spaces
-- Expectation: No Result 

SELECT
	cst_firstname,
	cst_lastname
FROM silver.crm_cust_info
WHERE TRIM(cst_firstname) != cst_firstname
OR TRIM(cst_lastname) != cst_lastname


-- Data Standardization & Consistency

SELECT DISTINCT
	cst_marital_status
FROM silver.crm_cust_info

SELECT DISTINCT
	cst_gndr
FROM silver.crm_cust_info


-- Check for Unwanted Spaces
-- Expectation: No Result

SELECT
	sls_prd_key
FROM bronze.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key)

-- Chcek for Invalid Data
-- Expecation: No Result

SELECT
	sls_order_dt
FROM silver.crm_sales_details
WHERE LEN(sls_order_dt) != 10 

SELECT 
	sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > GETDATE()
OR sls_order_dt > sls_ship_dt
OR sls_order_dt > sls_due_dt


-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Result

SELECT
	cid,
	COUNT(*)
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1
OR cid IS NULL

-- Check for Valid between Primary Kay
-- Expectation: No Result

SELECT
	*
FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT cst_number FROM silver.crm_cust_info)

-- Check for Unwanted Spaces
-- Expectation: No Result

SELECT
	*
FROM silver.erp_cust_az12
WHERE cid != TRIM(cid)

-- Check for Date Valid
-- Expectation: No Result

SELECT
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '01-01-1920'
OR bdate > GETDATE()

-- Standardization & Consistency

SELECT DISTINCT
	gen
FROM silver.erp_cust_az12

-- Check for Primary Kay Valid
-- Expectation: No Result

SELECT
	*
FROM bronze.erp_loc_a101
WHERE cid NOT IN (SELECT cst_number FROM silver.crm_cust_info)

-- Check for NULLs or Dupicates in Primary Key
-- Expectation: No Result

SELECT
	cid,
	COUNT(*)
FROM bronze.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1
OR cid IS NULL

-- Check for Standardization & Consistency

SELECT DISTINCT
	cntry
FROM bronze.erp_loc_a101


-- Check for Valid in Primary Key
-- Expectation: No Result
SELECT
	*
FROM silver.erp_px_cat_g1v2
WHERE id NOT IN (SELECT prd_cat FROM silver.crm_prd_info)

-- Check for Unwanted Spaces
-- Expectation: No Result
SELECT
	*
FROM silver.erp_px_cat_g1v2
WHERE id != TRIM(id)

-- Standardization & Consistency
SELECT DISTINCT
	cat
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT
	subcat
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT
	maintenance
FROM silver.erp_px_cat_g1v2
