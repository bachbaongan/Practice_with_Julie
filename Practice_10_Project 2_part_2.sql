CREATE VIEW  my-project-010823-394620.thelook_ecommerce2.vw_ecommerce_analyst AS ( --Create view to do Cohort Analysis
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
