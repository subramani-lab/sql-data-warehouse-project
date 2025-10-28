---Validating columns,

select sls_ord_num  from bronze.crm_sales_details
where sls_ord_num != TRIM(sls_ord_num)

Select * from bronze.crm_sales_details where sls_prd_key not in (Select sls_prd_key from silver.crm_cust_info)

Select * from bronze.crm_sales_details where sls_cust_id not in (Select cst_id from silver.crm_cust_info)

select 
nullif(sls_order_dt ,0) as sls_order_dt
from bronze.crm_sales_details --Negative number or zeros can't be cast to a date
where sls_order_dt <=0 
OR len(sls_order_dt) != 8
OR sls_order_dt >205000101
or sls_order_dt <19000101

select 
nullif(sls_ship_dt ,0) as sls_ship_dt
from bronze.crm_sales_details --Negative number or zeros can't be cast to a date
where sls_ship_dt <=0 
OR len(sls_ship_dt) != 8
OR sls_ship_dt >205000101
or sls_ship_dt <19000101

select 
nullif(sls_due_dt ,0) as sls_due_dt
from bronze.crm_sales_details --Negative number or zeros can't be cast to a date
where sls_due_dt <=0 
OR len(sls_due_dt) != 8
OR sls_due_dt >205000101
or sls_due_dt <19000101

--Checking for Invalid date orders
select * from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt
OR sls_order_dt > sls_due_dt


----------Business Rules----
--Sales = Quantity * price
--And not contain negative, zeros, And null are not allowed!
--RULES
--If sales is negative, zero or null, derive it using quantity and price (Quantity * price)
--If price is zero or null, calculate it using sales and quantity (Sales / Quantity)
--If price is negative, convert it to a positive value
select DISTINCT
sls_sales AS Old_sls_sales,
sls_quantity,
sls_price as Old_sls_price
from bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <=0
OR sls_quantity <=0
OR sls_price <=0
ORDER BY sls_sales,sls_quantity,sls_price

SELECT DISTINCT
    sls_sales AS Old_sls_sales,
    sls_quantity,
    sls_price AS Old_sls_price,
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <=0
OR sls_quantity <=0
OR sls_price <=0
ORDER BY sls_sales,sls_quantity,sls_price
----------------------------------------------------------
IF OBJECT_ID ('silver.crm_sales_details' , 'U') IS NOT NULL
  	DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details(
	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50) ,
	sls_cust_id int ,
	sls_order_dt date,
	sls_ship_dt date,
	sls_due_dt date,
	sls_sales int,
	sls_quantity int ,
	sls_price int,
	dwh_create_date 
	DATETIME2 DEFAULT GETDATE()
);
----------------------------------------------------------
insert into silver.crm_sales_details(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity ,
	sls_price
)
select
sls_ord_num,
sls_prd_key,
sls_cust_id,
case
	when sls_order_dt = 0 or len(sls_order_dt) !=8 THEN NULL
	else cast(cast(sls_order_dt as varchar) as date )
	end
as sls_order_dt,
case 
	when sls_ship_dt = 0 or len(sls_ship_dt) != 8 THEN NULL
	ELSE  CAST(CAST(sls_ship_dt AS nvarchar) AS DATE) 
	END
AS sls_ship_dt,
CASE 
	when sls_due_dt = 0 or len(sls_due_dt) != 8 THEN NULL
	ELSE  CAST(CAST(sls_due_dt AS nvarchar) AS DATE) 
	END
AS sls_due_dt,
CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
sls_quantity,
CASE
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
from bronze.crm_sales_details

-------------------------------------------
--Validating Silver layer for crm_sales_details
select * from bronze.crm_sales_details
select * from silver.crm_sales_details

select sls_ord_num  from silver.crm_sales_details
where sls_ord_num != TRIM(sls_ord_num)

Select * from silver.crm_sales_details where sls_prd_key not in (Select sls_prd_key from silver.crm_cust_info)

Select * from silver.crm_sales_details where sls_cust_id not in (Select cst_id from silver.crm_cust_info)


select DISTINCT
sls_sales AS Old_sls_sales,
sls_quantity,
sls_price as Old_sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <=0
OR sls_quantity <=0
OR sls_price <=0
ORDER BY sls_sales,sls_quantity,sls_price
