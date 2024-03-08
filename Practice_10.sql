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

