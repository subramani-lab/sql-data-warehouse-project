/* 
--Bronze layer--
Crearing bronze (stage layer) to bring data from SOURE to SQL Server bronze layer
*/
--Creating database and schema
  use master;
  create database datawarehouse;
  use datawarehouse;

--Creating all layer schema's--
create schema bronze;
go
create schema silver;
go
create schema gold;

--Table Creation----
  IF OBJECT_ID ('bronze.erp_cust_az12' , 'U') IS NOT NULL
  	DROP TABLE bronze.erp_cust_az12;
    create table bronze.erp_cust_az12(
    CID nvarchar(50),
    BDATE DATE,
    GEN nvarchar(50)
    );

--Loading data from source to Sql Sever Bronze layer------
  TRUNCATE TABLE bronze.crm_cust_info;
  BULK INSERT bronze.crm_cust_info
  FROM 'C:\Users\91868\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
  with (
  	FIRSTROW = 2,
  	FIELDTERMINATOR = ',',
  	TABLOCK);
  SELECT * FROM bronze.crm_cust_info;
  SELECT COUNT(*) FROM bronze.crm_cust_info;

