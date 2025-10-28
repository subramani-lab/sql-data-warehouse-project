----Data Standardization & Consistency-----------------
select distinct CNTRY from bronze.erp_loc_a101

-------------------------------------------------------
INSERT INTO SILVER.erp_loc_a101(
CID,
CNTRY
)
select 
REPLACE(CID, '-' ,'') AS CID,
CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
     WHEN TRIM(CNTRY) IN ('US','USA') THEN 'united states'
	 WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
	 ELSE TRIM(CNTRY)
END AS CNTRY
from bronze.erp_loc_a101
order by CID


---------Data quality check--------------------------------
SELECT * FROM silver.erp_loc_a101
select * from bronze.erp_loc_a101

----Data Standardization & Consistency-----------------
select distinct CNTRY from silver.erp_loc_a101
