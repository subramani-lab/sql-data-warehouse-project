/*Advance Analytics*/

----1.Change-Over-Time----

/*Analyze how a measure evoles over time
Helps track trends and identify seasonality in your data */

select 
DATETRUNC(YEAR,order_date) AS order_date,
sum(sales) AS total_sales
from gold.fact_sales
where order_date is not null
GROUP BY DATETRUNC(YEAR,order_date)

select 
YEAR(order_date) AS order_date,
sum(sales) AS total_sales
from gold.fact_sales
where order_date is not null
GROUP BY YEAR(order_date)

SELECT
FORMAT(order_date, 'yyyy') as order_date,
sum(sales) AS total_sales
from gold.fact_sales
where order_date is not null
GROUP BY FORMAT(order_date, 'yyyy')
