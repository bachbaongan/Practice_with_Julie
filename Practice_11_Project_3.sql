/*Doanh thu theo từng ProductLine, Year  và DealSize?*/
SELECT productline, year_id, dealsize, SUM(sales) as Revenue
FROM public.sales_dataset_rfm_prj_clean
GROUP BY productline, year_id, dealsize
ORDER BY productline, year_id, dealsize

/*Đâu là tháng có bán tốt nhất mỗi năm?*/
SELECT month_id, SUM(sales) as revenue, count(ordernumber) as order_number
FROM public.sales_dataset_rfm_prj_clean
GROUP BY month_id
ORDER BY revenue DESC, order_number DESC


/*Product line nào được bán nhiều ở tháng 11?*/
SELECT month_id, productline, 
SUM(sales) as revenue, count(ordernumber) as order_number
FROM public.sales_dataset_rfm_prj_clean
WHERE month_id =11
GROUP BY month_id,productline
ORDER BY revenue DESC, order_number DESC

/*Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? */
WITH CTE AS (
SELECT *, RANK() oVER(PARTITION BY year_id ORDER BY revenue DESC) as rank
FROM (
SELECT year_id, productline, sum(sales) as revenue
FROM public.sales_dataset_rfm_prj_clean
GROUP BY year_id, productline
) as sub
	)
SELECT *
FROm CTE
WHERE rank=1

/*Ai là khách hàng tốt nhất, phân tích dựa vào RFM */
-- FIND R, F, M
WITH Customer_rfm AS (
SELECT customername, 
current_date - max(orderdate) as R,
count(distinct ordernumber) as F,
sum(sales) as M
FROM public.sales_dataset_rfm_prj_clean
GROUP BY customername
)
-- RFM score
, rfm_score as (
SELECT customername, 
ntile(5) OVER(ORDER BY R DESC) AS r_score,
ntile(5) OVER(ORDER BY F) as f_score,
ntile(5) OVER(ORDER BY M) as m_score
FROM customer_rfm
)
-- RFM final
, rfm_final as (
SELECT customername,
CAST(r_score as varchar)||cast(f_score as varchar)||cast(m_score as varchar) as rfm_score
FROM rfm_score
)
SELECT segment, count(*) FROM (
SELECT a.customername,b.segment 
FROM rfm_final a
JOIN segment_score b ON a.rfm_score =b.scores) as s
group by segment
order by count (*) DESC
