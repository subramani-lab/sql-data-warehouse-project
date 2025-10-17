---ETL on bronze.crm_prd_info---

select * from bronze.crm_prd_info

---Finding duplicates---
select 
prd_id,
count(*)
from bronze.crm_prd_info
group by prd_id
having count(*) >1 or prd_id is null

----checking leading space--
select prd_nm from bronze.crm_prd_info
where prd_nm != trim(prd_nm)

----checking negative values & null values----
select prd_cost from bronze.crm_prd_info
where prd_cost <0 or prd_cost is null

----Checking standaridization  & consistency---
select distinct prd_line from bronze.crm_prd_info

----Check for invalid data orders----
----end data must not be earlier than the start date----
select * from bronze.crm_prd_info
where prd_end_dt < prd_start_dt 

select *,
DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) ,
prd_end_dt
from bronze.crm_prd_info where prd_key in ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')

-----------------------------------------------------------------------------------------
----Amended Table columns-----------------------------
IF OBJECT_ID ('silver.crm_prd_info' , 'U') IS NOT NULL
  	DROP TABLE silver.crm_prd_info;
CREATE TABLE [silver].[crm_prd_info](
	[prd_id] [int] NULL,
	cat_id nvarchar(50),
	prd_key nvarchar(50),
	[prd_nm] [nvarchar](50) NULL,
	[prd_cost] [int] NULL,
	[prd_line] [nvarchar](50) NULL,
	[prd_start_dt] [date] NULL,
	[prd_end_dt] [date] NULL,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
)

-------Inserting table into silver layer----------

insert into silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
select 
	prd_id,
	REPLACE(SUBSTRING(prd_key,1 ,5), '-', '_') as cat_id, --Extract category id
	SUBSTRING(prd_key, 7, LEN(prd_key)) as prd_key, --Extract product key
	prd_nm,
	ISNULL(prd_cost,0) AS prd_cost,
	case 
		when upper(trim(prd_line)) = 'M' then 'Mountain'
		when upper(trim(prd_line)) = 'R' then 'Road'
		when upper(trim(prd_line)) = 'S' then 'Other Sales'
		when upper(trim(prd_line)) = 'T' then 'Toruing'
		else 'n\a'
	end as prd_line, --Mpa product line codes to descriptive values
	Cast(prd_start_dt as date) as prd_start_dt,
	Cast(
	DATEADD(DAY, -1 ,LEAD(prd_start_dt) over (partition by prd_key order by prd_start_dt)) 
	as date) 
	as prd_end_dt_1 --- Calculate end date as one day before next start date
from bronze.crm_prd_info


---quality check for silver layer # crm_prd_info --> TABLE--
---Finding duplicates---
select 
prd_id,
count(*)
from silver.crm_prd_info
group by prd_id
having count(*) >1 or prd_id is null

----checking leading space--
select prd_nm from silver.crm_prd_info
where prd_nm != trim(prd_nm)

----checking negative values & null values----
select prd_cost from silver.crm_prd_info
where prd_cost <0 or prd_cost is null

----Checking standaridization  & consistency---
select distinct prd_line from silver.crm_prd_info

----Check for invalid data orders----
----end data must not be earlier than the start date----
select * from silver.crm_prd_info
where prd_end_dt < prd_start_dt 

select * from silver.crm_prd_info
select * from bronze.crm_prd_info
