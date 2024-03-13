/*Create view followed dataset requirement*/
CREATE VIEW  my-project-010823-394620.thelook_ecommerce2.vw_ecommerce_analyst AS ( 
WITH sub1 AS (
SELECT FORMAT_DATE('%Y-%m',o.delivered_at) as month_year,
p.category as product_category,
o.order_id,oi.id, oi.sale_price,o.num_of_item, p.cost
FROM my-project-010823-394620.thelook_ecommerce2.orders AS o
JOIN my-project-010823-394620.thelook_ecommerce2.order_items AS oi ON oi.order_id=o.order_id
JOIN my-project-010823-394620.thelook_ecommerce2.products AS p ON oi.product_id=p.id
WHERE o.status='Complete'
ORDER BY month_year, p.category
)
, sub2 as(
SELECT sub1.month_year,sub1.product_category,  
SUM(sale_price) AS TPV,
COUNT(order_id) AS TPO,
SUM(cost) AS total_cost
FROM sub1
GROUP BY sub1.product_category,sub1.month_year
ORDER BY sub1.product_category,sub1.month_year
)
SELECT sub2.month_year,sub2.product_category, ROUND(sub2.TPV,2) as TPV, sub2.TPO,
ROUND((sub2.TPV-LAG(sub2.TPV) OVER(ORDER BY sub2.product_category, sub2.month_year))/(LAG(sub2.TPV) OVER(ORDER BY sub2.product_category, sub2.month_year))*100.00,2) AS revenue_growth,
ROUND((sub2.TPO-LAG(sub2.TPO) OVER(ORDER BY sub2.product_category,sub2.month_year))/LAG(sub2.TPO) OVER(ORDER BY sub2.product_category,sub2.month_year)*100.00,2) AS order_growth,
ROUND(sub2.total_cost,2) As total_cost,
ROUND(TPV-TPO,2) as total_profit,
ROUND((TPV-TPO)/sub2.total_cost,2) AS Profit_to_cost_ratio
FROM sub2
ORDER BY sub2.product_category, sub2.month_year
)

/* Cohort Analysis*/
WITH sub2 AS (
SELECT user_id, sale_price, FORMAT_DATE('%Y-%m',first_day) as cohort_date, first_day,
sub1.delivered_at,
(extract(year from delivered_at)-extract(year from first_day))*12 
+(extract(month from delivered_at)-extract(month from first_day))+1 as index
FROM
(
SELECT user_id, sale_price, delivered_at,  min(delivered_at) OVER (PARTITION BY user_id) as first_day
FROM my-project-010823-394620.thelook_ecommerce2.order_items
WHERE delivered_at IS NOT NUll) as sub1
)
, sub3 as(
SELECT cohort_date, index, count(DISTINCT user_id) as cnt,
SUM(sale_price) as revenue
FROM sub2
GROUP BY cohort_date, index
)
, customer_cohort AS(
SELECT sub3.cohort_date,
SUM(CASE WHEN index=1 THEN cnt ELSE 0 END) as m1,
SUM(CASE WHEN index=2 THEN cnt ELSE 0 END) as m2,
SUM(CASE WHEN index=3 THEN cnt ELSE 0 END) as m3,
SUM(CASE WHEN index=4 THEN cnt ELSE 0 END) as m4,
SUM(CASE WHEN index=5 THEN cnt ELSE 0 END) AS m5,
SUM(CASE WHEN index=6 THEN cnt ELSE 0 END) AS m6,
SUM(CASE WHEN index=7 THEN cnt ELSE 0 END) AS m7,
SUM(CASE WHEN index=8 THEN cnt ELSE 0 END) AS m8,
SUM(CASE WHEN index=9 THEN cnt ELSE 0 END) AS m9,
SUM(CASE WHEN index=10 THEN cnt ELSE 0 END) AS m10,
SUM(CASE WHEN index=11 THEN cnt ELSE 0 END) AS m11,
SUM(CASE WHEN index=12 THEN cnt ELSE 0 END) AS m12
FROM sub3
GROUP BY sub3.cohort_date
ORDER BY sub3.cohort_date
)
SELECT  customer_cohort.cohort_date,
ROUND(100.00*m1/m1,2)||'%' as m1,
ROUND(100.00*m2/m1,2)||'%' as m2,
ROUND(100.00*m3/m1,2)||'%' as m3,
ROUND(100.00*m4/m1,2)||'%' as m4,
ROUND(100.00*m5/m1,2)||'%' as m5,
ROUND(100.00*m6/m1,2)||'%' as m6,
ROUND(100.00*m7/m1,2)||'%' as m7,
ROUND(100.00*m8/m1,2)||'%' as m8,
ROUND(100.00*m9/m1,2)||'%' as m9,
ROUND(100.00*m10/m1,2)||'%' as m10,
ROUND(100.00*m11/m1,2)||'%' as m11,
ROUND(100.00*m12/m1,2)||'%' as m12
FROM customer_cohort
