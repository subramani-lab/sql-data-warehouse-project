----Data Standardization & Consistency-----------------
select distinct CNTRY from bronze.erp_loc_a101
-------------------------------------------------------
	
INSERT INTO SILVER.erp_loc_a101(
CID,
CNTRY
)
select 
REPLACE(CID, '-' ,'') AS CID, --Replace '-' wiht '' spalce
CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
     WHEN TRIM(CNTRY) IN ('US','USA') THEN 'united states'
	 WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
	 ELSE TRIM(CNTRY)
END AS CNTRY --Normlize and handel missing or blank country codes
from bronze.erp_loc_a101
order by CID
	
---------Data quality check--------------------------------
SELECT * FROM silver.erp_loc_a101
select * from bronze.erp_loc_a101
----Data Standardization & Consistency-----------------
select distinct CNTRY from silver.erp_loc_a101
----------------------------------------------------

#erp_px_cat_g1v2

select * from bronze.erp_px_cat_g1v2
-----------Checking unwanted spaces-----------------
select ID from bronze.erp_px_cat_g1v2
where ID != trim(ID)

select CAT from bronze.erp_px_cat_g1v2
where CAT != trim(CAT)

select SUBCAT from bronze.erp_px_cat_g1v2
where SUBCAT != trim(SUBCAT)

select MAINTENANCE from bronze.erp_px_cat_g1v2
where MAINTENANCE != trim(MAINTENANCE)
------------Data standaridization & Consistency--------
select distinct MAINTENANCE from bronze.erp_px_cat_g1v2

------------------------------------------------------
INSERT INTO SILVER.erp_px_cat_g1v2(
ID,
CAT,
SUBCAT,
MAINTENANCE)
select  
ID,
CAT,
SUBCAT,
MAINTENANCE
from bronze.erp_px_cat_g1v2
