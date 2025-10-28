------------Identify out-of-Range Dates-------------------

select distinct
BDATE
from bronze.erp_cust_az12
where BDATE < '1924-01-01' or BDATE > getdate()

------------DATA STANDARIDIZATION & CONSISTENCY-----------
SELECT DISTINCT GEN,
CASE WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
	 else 'n/a'
end as GEN
FROM bronze.erp_cust_az12
----------------------------------------------------------
IF OBJECT_ID ('silver.erp_cust_az12' , 'U') IS NOT NULL
  	DROP TABLE silver.crm_sales_details;
create table silver.erp_cust_az12(
CID nvarchar(50),
BDATE DATE,
GEN nvarchar(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
)
------------------------------------------------------------
insert into silver.erp_cust_az12(
CID,
BDATE,
GEN
)
select 
CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID , 4, LEN(CID)) --Remove 'NAS' perfix if present
	ELSE CID
END AS CID,
CASE WHEN BDATE > GETDATE() THEN NULL
	ELSE BDATE
END AS BDATE, -- Set future birthdates to null
CASE WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
	 else 'n/a'
end as GEN -- Nomalize gender values and handel unknown cases
from bronze.erp_cust_az12

-----Validating data quality-----------
select * from silver.erp_cust_az12
select * from bronze.erp_cust_az12

select distinct
BDATE
from silver.erp_cust_az12
where BDATE < '1924-01-01' or BDATE > getdate()

------------DATA STANDARIDIZATION & CONSISTENCY-----------
SELECT DISTINCT GEN from silver.erp_cust_az12
