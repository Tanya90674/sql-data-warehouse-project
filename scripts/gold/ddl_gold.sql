/*
=============================================================================
DDL Script: Create Gold Views
=============================================================================
Script Purpose:
  This script creates views for the Gold layer in the data warehouse.
  The gold layer represents the final dimension and fact tables (Star Schema)

  Each view performs transformations and combines data from the silver layer 
  to produce a clean, enriched, and business-ready dataset.

Usage:
  - These views can be queried directly for analytics and reposrting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

If OBECT_ID('gold.dim_customers', 'V') IS NOT NULL
  DROP VIEW gold.dim_customers
GO
CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY cs.cst_id) AS customer_key,
	cs.cst_id                             AS customer_id,
	cs.cst_key                            AS customer_number,
	cs.cst_firstname                      AS first_name,
	cs.cst_lastname                       AS last_name,
	eco.CNTRY                             AS country,
	cs.cst_marital_status                 AS marital_status,
	CASE WHEN cs.cst_gndr != 'n/a' THEN cs.cst_gndr
		   ELSE COALESCE(ebd.GEN, 'n/a')
	END                                   AS gender,
	ebd.BDATE                             AS birthdate,
	cs.cst_create_date                    AS create_date
FROM silver.crm_cust_info cs
LEFT JOIN silver.erp_CUST_AZ12 ebd
  ON ebd.CID = cs.cst_key
LEFT JOIN silver.erp_LOC_A101 eco
  ON eco.CID = cs.cst_key
GO

  -- ===================================================================================
  -- Create Dimension: gold.dim_product
  -- ===================================================================================

If OBECT_ID('gold.dim_product', 'V') IS NOT NULL
  DROP VIEW gold.dim_product
GO
CREATE VIEW gold.dim_product AS 
SELECT 
	ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id                                               AS product_id,
	pn.prd_key                                              AS product_number,
	pn.prd_nm                                               AS product_name,
	pn.cat_id                                               AS category_id,
	cat.CAT                                                 AS category,
	cat.SUBCAT                                              AS subcategory,
	cat.maintenance,
	pn.prd_cost                                             AS product_cost,
	pn.prd_line                                             AS product_line,
	pn.prd_start_dt                                         AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_PX_CAT_G1V2 cat
  ON cat.ID = pn.cat_id
WHERE prd_end_dt IS NULL --Filter out all historical data
GO

-- ==================================================================================
-- Create Dimension: gold.fact_sales
-- ==================================================================================

IF OBECT_ID('gold.fact_sales', 'V') IS NOT NULL
  DROP VIEW gold.fact_sales
GO
CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num           AS order_number,
	gp.product_key           AS product_key,
	gc.customer_key          AS customer_key,
	sd.sls_order_dt          AS order_date,
	sd.sls_ship_dt           AS ship_date,
	sd.sls_due_dt            AS due_date,
	sd.sls_sales             AS sales_amount,
	sd.sls_quantity          AS quantity,
	sd.sls_price             AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_customers gc
  ON sd.sls_cust_id = gc.customer_id
LEFT JOIN gold.dim_product gp
  ON gp.product_number = sd.sls_prd_key





