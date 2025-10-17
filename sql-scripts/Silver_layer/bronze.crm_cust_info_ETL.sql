select * from bronze.crm_cust_info

---Finding duplicates in the cut_id--------------------------------------------------------------
select 
count(*),
cst_id
from  bronze.crm_cust_info
group by cst_id
having COUNT(*) >1

--Finding leading space in the name's columns

select cst_firstname from bronze.crm_cust_info
where cst_firstname != TRIM(cst_firstname)

---Finding distinct recoards--

select distinct cst_gndr
from silver.crm_cust_info
--------------------------------------------------------------------------------------------------------
  
--Cleaning data----
insert into silver.crm_cust_info(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
)
select 
cst_id,
cst_key,
ltrim(cst_firstname) as cst_firstname,
ltrim(cst_lastname) as cst_lastname,
case 
	when upper(ltrim(cst_marital_status)) = 'S' then 'Single'
	when upper(ltrim(cst_marital_status)) = 'M' then 'Married'
	else 'n/a'
end cst_marital_status,
case
	when UPPER(ltrim(cst_gndr)) = 'F' then 'Female'
	when upper(ltrim(cst_gndr)) = 'M' then 'Male'
	else 'n/a'
end cst_gndr,
cst_create_date
From 
	(
	select *,
	ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last
	from bronze.crm_cust_info
	) t 
	where flag_last = 1 
--------------------------------------------------------------------------------------------------
