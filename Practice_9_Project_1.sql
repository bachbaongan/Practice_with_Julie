SELECT * FROM public.sales_dataset_rfm_prj;

/*Chuyển đổi kiểu dữ liệu phù hợp cho các trường ( sử dụng câu lệnh ALTER) */
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN ordernumber TYPE integer USING (ordernumber::integer);
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN quantityordered TYPE integer USING (quantityordered::integer);
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN priceeach TYPE numeric USING (priceeach::numeric);
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN orderlinenumber TYPE integer USING (orderlinenumber::integer);
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN sales TYPE numeric USING (sales::numeric);
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN orderdate TYPE timestamp USING (orderdate::timestamp);
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN msrp TYPE numeric USING (msrp::numeric);

/*Check NULL/BLANK (‘’)  ở các trường: ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE.*/
SELECT COUNT(*)
FROM public.sales_dataset_rfm_prj 
WHERE ordernumber IS NULL 
OR quantityordered IS NULL 
OR  priceeach IS NULL 
OR orderlinenumber IS NULL	
OR SALES is NULL
OR ORDERDATE IS NULL

/*Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra từ CONTACTFULLNAME.*/
ALTER TABLE public.sales_dataset_rfm_prj ADD contactfirstname TEXT;
ALTER TABLE public.sales_dataset_rfm_prj ADD contactlastname TEXT;
 
UPDATE public.sales_dataset_rfm_prj
SET (contactfirstname, contactlastname)= 
(LEFT(contactfullname,POSITION('-' IN contactfullname)-1),
RIGHT(contactfullname,LENGTH(contactfullname)-POSITION('-' IN contactfullname)))
WHERE (contactfirstname IS NULL OR contactfirstname ='')
AND (contactlastname IS NULL OR contactlastname ='');

--Chuẩn hóa CONTACTLASTNAME, CONTACTFIRSTNAME theo định dạng chữ cái đầu tiên viết hoa, chữ cái tiếp theo viết thường.
UPDATE public.sales_dataset_rfm_prj
SET (contactfirstname, contactlastname)= 
(CONCAT(UPPER((LEFT(contactfirstname,1))),RIGHT(contactfirstname,LENGTH(contactfirstname)-1)),
CONCAT(UPPER((LEFT(contactlastname,1))),RIGHT(contactlastname,LENGTH(contactlastname)-1)));

/* Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Qúy, tháng, năm được lấy ra từ ORDERDATE */
ALTER TABLE public.sales_dataset_rfm_prj ADD QTR_ID Integer;
ALTER TABLE public.sales_dataset_rfm_prj ADD MONTH_ID Integer;
ALTER TABLE public.sales_dataset_rfm_prj ADD YEAR_ID Integer;

UPDATE public.sales_dataset_rfm_prj
SET (QTR_ID, MONTH_ID, YEAR_ID)= 
(EXTRACT(Quarter FROM orderdate),EXTRACT(MONTH FROM orderdate),EXTRACT(YEAR FROM orderdate));

/*Hãy tìm outlier (nếu có) cho cột QUANTITYORDERED và hãy chọn cách xử lý cho bản ghi đó (2 cách) */
--- Boxplot
WITH box_min_max_value AS (
SELECT Q1-1.5 * IQR AS min_value, 
Q3 +1.5 * IQR as max_value
FROM (
SELECT 
percentile_cont(0.25) WITHIN GROUP(ORDER BY QUANTITYORDERED) AS Q1,
percentile_cont(0.75) WITHIN GROUP(ORDER BY QUANTITYORDERED) AS Q3,
percentile_cont(0.75) WITHIN GROUP(ORDER BY QUANTITYORDERED) - percentile_cont(0.25) WITHIN GROUP(ORDER BY QUANTITYORDERED) AS IQR
FROM public.sales_dataset_rfm_prj) AS sub1
)

SELECT * FROM public.sales_dataset_rfm_prj
WHERE quantityordered <(SELECT min_value FROM box_min_max_value)
OR quantityordered > (SELECT max_value FROM box_min_max_value)

--- Z-score
SELECT AVG(quantityordered) AS avg_no,
stddev(quantityordered) AS stddev
FROM public.sales_dataset_rfm_prj

WITH sub1 AS (
SELECT quantityordered, 
(SELECT AVG(quantityordered) FROM public.sales_dataset_rfm_prj) as avg,
(SELECT stddev(quantityordered) FROM public.sales_dataset_rfm_prj) AS stddev
FROM public.sales_dataset_rfm_prj)

,sub_outlier AS(
SELECT quantityordered, avg,
((quantityordered- avg)/stddev) as z_score
FROM sub1
WHERE abs(((quantityordered- avg)/stddev))>3)

--Update outlier by Average amount
UPDATE public.sales_dataset_rfm_prj
SET quantityordered = (SELECT AVG(quantityordered) FROM public.sales_dataset_rfm_prj)
WHERE quantityordered IN (SELECT quantityordered FROM sub_outlier)

--Delete ourlier  - Not run
WITH sub1 AS (
SELECT quantityordered, 
(SELECT AVG(quantityordered) FROM public.sales_dataset_rfm_prj) as avg,
(SELECT stddev(quantityordered) FROM public.sales_dataset_rfm_prj) AS stddev
FROM public.sales_dataset_rfm_prj)

,sub_outlier AS(
SELECT quantityordered, avg,
((quantityordered- avg)/stddev) as z_score
FROM sub1
WHERE abs(((quantityordered- avg)/stddev))>3)

DELETE FROM public.sales_dataset_rfm_prj
WHERE quantityordered IN (SELECT quantityordered FROM sub_outlier)

/*Sau khi làm sạch dữ liệu, hãy lưu vào bảng mới  tên là SALES_DATASET_RFM_PRJ_CLEAN*/
CREATE TABLE SALES_DATASET_RFM_PRJ_CLEAN AS
SELECT *
FROM public.sales_dataset_rfm_prj

