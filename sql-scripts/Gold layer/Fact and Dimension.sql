--Creating Golden layer---------
create view gold.dim_customers as
select 
	ROW_NUMBER() over (order by cst_id) as customer_key, -- Creating unique rows
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	la.CNTRY as country,
	ci.cst_marital_status as marital_status,
	case when ci.cst_gndr != 'n/a' then ci.cst_gndr --CRM is the Master for gender info (Data intergration)
		 else coalesce(ca.gen , 'n/a')
	end as gender,
	ca.bdate as birthday,
	ci.cst_create_date as create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
on ci.cst_key = la.CID 


-----Data Intergreation-----
select distinct
	ci.cst_gndr,
	ca.gen,
	case when ci.cst_gndr != 'n/a' then ci.cst_gndr --CRM is the Master for gender info (Data intergration)
		 else coalesce(ca.gen , 'n/a')
	end as new_gen
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
on ci.cst_key = la.CID 

select distinct gender from gold.dim_customers
------------------------------------------------------------------------------------
select * from silver.crm_prd_info
select * from silver.erp_px_cat_g1v2

create view gold.dim_products as
select
ROW_NUMBER () over(order by pn.prd_start_dt, pn.prd_key) as product_key,
pn.prd_id AS product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.CAT as category ,
pc.SUBCAT as subcategory,
PC.MAINTENANCE as maintenance,
pn.prd_cost as cost,
pn.prd_line product_line,
pn.prd_start_dt as start_date
from silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
on pn.cat_id = pc.ID
where pn.prd_end_dt is null -- Filter our all historical data

select * from gold.dim_products

---------------------------------------------------------------------------------
create view gold.fact_sales as
SELECT 
    sd.sls_ord_num as order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt as order_date,
    sd.sls_ship_dt as ship_date,
    sd.sls_due_dt as due_date,
    sd.sls_sales as sales,
    sd.sls_quantity as quantity,
    sd.sls_price as price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;

--Foreign key intergrity (Dimensions)
select * from gold.fact_sales f
left join gold.dim_customers c
on f.customer_key = c.customer_key
where c.customer_key is null

select * from gold.fact_sales f
left join gold.dim_products  p
on f.product_key = p.product_key
where p.product_key is null
