[Thelook Dataset](https://console.cloud.google.com/marketplace/product/bigquery-public-data/thelook-ecommerce?q=search&referrer=search&project=sincere-torch-350709)
[Bigquery](https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=thelook_ecommerce&page=dataset&project=my-project-010823-394620&ws=!1m4!1m3!8m2!1s225578876761!2s2ca6c5a4ca1f4ebd94d7999ed2ac3bf1)
/* 1. Số lượng người mua và số lượng đơn hàng đã hoàn thành mỗi tháng ( Từ 1/2019-4/2022) */
SELECT 
FORMAT_DATE('%Y-%m',delivered_at) as month_year,-- Convert Timestamp in Bigqueey
COUNT(DISTINCT user_id) as total_user,
COUNT(DISTINCT order_id) as total_order
FROM bigquery-public-data.thelook_ecommerce.order_items
WHERE delivered_at BETWEEN '2019-01-01' and '2022-05-01'
AND status ='Complete'
GROUP BY FORMAT_DATE('%Y-%m',delivered_at)
ORDER BY month_year

/*=> Số lượng đơn hàng và số lượng khách hàng mỗi tháng có xu hướng tăng dần theo thời gian. 
Trung bình 1 khách hàng sẽ có trung bình 1 đơn hàng hoàn thành mỗi tháng.*/

--Từ phần này, trong đề ko nêu rõ nên chị tính giá trị các đơn hàng **đã hoàn thành** trong thời gian từ 01/2019-4/2022

/*Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng ( Từ 1/2019-4/2022)*/
SELECT 
FORMAT_DATE('%Y-%m',delivered_at) as month_year,
COUNT(DISTINCT user_id) as distinct_user,
ROUND(SUM(sale_price)/COUNT(DISTINCT order_id),2) as average_order_value
FROM bigquery-public-data.thelook_ecommerce.order_items
WHERE delivered_at BETWEEN '2019-01-01' and '2022-05-01' 
AND status ='Complete'
GROUP BY FORMAT_DATE('%Y-%m',delivered_at)
ORDER BY month_year

/*=> Số lượng khách hàng khác nhau tăng đều mỗi tháng nhưng giá trị trung bình mỗi đơn hàng chỉ tăng sau 1 tháng, 
nhưng sau đó đã giảm xuống và giữ vững ở mức khoàng 100 trong suốt khoảng thời gian sau đó.*/

/* Các khách hàng có trẻ tuổi nhất và lớn tuổi nhất theo từng giới tính ( Từ 1/2019-4/2022)*/

WITH CTE AS (
(SELECT first_name, last_name, gender, age, 'youngest' as tag
FROM bigquery-public-data.thelook_ecommerce.users
WHERE age = (SELECT min(age) FROM bigquery-public-data.thelook_ecommerce.users)
AND id IN (SELECT user_id
FROM bigquery-public-data.thelook_ecommerce.order_items
WHERE delivered_at BETWEEN '2019-01-01' and '2022-05-01'
AND status ='Complete')
ORDER BY gender)

UNION ALL

(SELECT first_name, last_name, gender, age, 'oldest' as tag
FROM bigquery-public-data.thelook_ecommerce.users
WHERE age = (SELECT max(age) FROM bigquery-public-data.thelook_ecommerce.users)
AND id IN (SELECT user_id
FROM bigquery-public-data.thelook_ecommerce.order_items
WHERE delivered_at BETWEEN '2019-01-01' and '2022-05-01'
AND status ='Complete')
ORDER BY gender)
)

SELECT tag, age, 
COUNT(tag) as no_user
FROM CTE
GROUP BY tag, age

--=> Có 154 khách hàng trẻ nhất ở độ tuổi 12 và 130 khách hàng lớn nhất ở độ tuổi 70 tham gia mua hàng và có đơn hàng hoàn thành trong khoảng thời gian từ 01/2019 đến 04/2022.

/*Top 5 sản phẩm có lợi nhuận cao nhất từng tháng (xếp hạng cho từng sản phẩm)*/
WITH CTE AS (
SELECT month_year, product_id, count(id) as cnt
FROM (
SELECT id, FORMAT_DATE('%Y-%m',delivered_at) as month_year,
product_id
FROM bigquery-public-data.thelook_ecommerce.order_items 
WHERE status ='Complete'
ORDER BY month_year) as sub
GROUP BY month_year, product_id
ORDER BY month_year
) 
, sub2 as(
SELECT cte.month_year, cte.product_id, p.name as product_name, 
ROUND(p.retail_price *cte.cnt,2) as sales,
ROUND(p.cost*cte.cnt,2) as cost,
ROUND((p.retail_price *cte.cnt-p.cost*cte.cnt),2) as profit
FROM CTE as cte 
LEFT JOIN bigquery-public-data.thelook_ecommerce.products AS p ON p.id=cte.product_id
ORDER BY cte.month_year
)
, sub3 AS (
SELECT *,
DENSE_RANK() OVER(PARTITION BY sub2.month_year oRDER BY sub2.profit DESC) AS rank_per_month
FROM sub2
ORDER BY sub2.month_year
)
SELECT * 
FROM sub3
WHERE rank_per_month <=5

/*Tổng doanh thu theo ngày của từng danh mục sản phẩm (category) trong 3 tháng qua ( giả sử ngày hiện tại là 15/4/2022)*/
WITH CTE AS (
SELECT FORMAT_DATE('%Y-%m-%d',oi.delivered_at) as dates,oi.id, oi.product_id, oi.sale_price,p.category as product_categories
FROM bigquery-public-data.thelook_ecommerce.order_items as oi
LEFT JOIN bigquery-public-data.thelook_ecommerce.products as p ON oi.product_id=p.id
WHERE status ='Complete'
AND delivered_at BETWEEN '2022-01-15' and '2022-04-16'
ORDER BY FORMAT_DATE('%Y-%m-%d',delivered_at)
)
SELECT dates, product_categories, 
ROUND(SUM(sale_price),2) as revenue
FROM CTE
GROUP BY dates, CTE.product_categories
ORDER BY dates
