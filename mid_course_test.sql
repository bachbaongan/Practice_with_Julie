/*Question 1:
Task: Tạo danh sách tất cả chi phí thay thế (replacement costs ) khác nhau của các film.*/
SELECT DISTINCT replacement_cost 
FROM film
ORDER BY replacement_cost;

---Question: Chi phí thay thế thấp nhất là bao nhiêu?
SELECT DISTINCT replacement_cost AS min_replacement_cost
FROM film
ORDER BY replacement_cost
LIMIT 1;

/*Question 2:
Task: Viết một truy vấn cung cấp cái nhìn tổng quan về số lượng phim có chi phí thay thế trong các phạm vi chi phí sau
1.	low: 9.99 - 19.99
2.	medium: 20.00 - 24.99
3.	high: 25.00 - 29.99*/
SELECT 
SUM(CASE WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 1 ELSE 0 END)AS "low: 9.99 - 19.99",
SUM(CASE WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 1 ELSE 0 END)AS "medium: 20.00 - 24.99",
SUM(CASE WHEN replacement_cost BETWEEN 25.00 AND 29.99 THEN 1 ELSE 0 END)AS "high: 25.00 - 29.99"
FROM film;

---Question: Có bao nhiêu phim có chi phí thay thế thuộc nhóm “low”?
SELECT 
SUM(CASE WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 1 ELSE 0 END)AS "low"
FROM film;

/*Question 3:
Task: Tạo danh sách các film_title  bao gồm tiêu đề (title), độ dài (length) và tên danh mục (category_name) được sắp xếp 
theo độ dài giảm dần. Lọc kết quả để chỉ các phim trong danh mục 'Drama' hoặc 'Sports'.*/
SELECT fl.title, fl.length, ca.name AS category_name
FROM film as fl
JOIN film_category as fc ON fl.film_id=fc.film_id
JOIN category as ca ON ca.category_id=fc.category_id
WHERE ca.name IN ('Drama','Sports')
ORDER BY fl.length DESC;

---Question: Phim dài nhất thuộc thể loại nào và dài bao nhiêu?
SELECT fl.length, ca.name AS category_name
FROM film as fl
JOIN film_category as fc ON fl.film_id=fc.film_id
JOIN category as ca ON ca.category_id=fc.category_id
WHERE ca.name IN ('Drama','Sports')
ORDER BY fl.length DESC
LIMIT 1;

/*Question 4:
Task: Đưa ra cái nhìn tổng quan về số lượng phim (tilte) trong mỗi danh mục (category).*/
SELECT ca.name AS category, COUNT(fl.title) AS title_count
FROM film as fl
JOIN film_category as fc ON fl.film_id=fc.film_id
JOIN category as ca ON ca.category_id=fc.category_id
GROUP BY ca.name;

---Question:Thể loại danh mục nào là phổ biến nhất trong số các bộ phim?
SELECT ca.name AS category, CONCAT(COUNT(fl.title),' titles') AS title_count
FROM film as fl
JOIN film_category as fc ON fl.film_id=fc.film_id
JOIN category as ca ON ca.category_id=fc.category_id
GROUP BY ca.name
ORDER BY COUNT(fl.title) DESC
LIMIT 1;

/*Question 5:
Task:Đưa ra cái nhìn tổng quan về họ và tên của các diễn viên cũng như số lượng phim họ tham gia.*/
SELECT CONCAT(ac.first_name,' ',ac.last_name) AS actor,
COUNT(fl.film_id) AS film_no
FROM film as fl
LEFT JOIN film_actor AS fa ON fl.film_id=fa.film_id
LEFT JOIN actor AS ac ON ac.actor_id = fa.actor_id
GROUP BY CONCAT(ac.first_name,' ',ac.last_name)
ORDER BY COUNT(fl.film_id) DESC;

---Question: Diễn viên nào đóng nhiều phim nhất?
SELECT CONCAT(ac.first_name,' ',ac.last_name) AS actor,
COUNT(fl.film_id) AS film_no
FROM film as fl
LEFT JOIN film_actor AS fa ON fl.film_id=fa.film_id
LEFT JOIN actor AS ac ON ac.actor_id = fa.actor_id
GROUP BY CONCAT(ac.first_name,' ',ac.last_name)
ORDER BY COUNT(fl.film_id) DESC
LIMIT 1;

/*Question 6:
Level: Intermediate
Topic: LEFT JOIN & FILTERING
Task: Tìm các địa chỉ không liên quan đến bất kỳ khách hàng nào.*/\
SELECT ad.address_id, ad.address, ad.address2, ad.district, ad.city_id, ad.postal_code, ad.phone, ad.last_update
FROM address as ad
LEFT JOIN customer as cus ON ad.address_id = cus.address_id
WHERE cus.customer_id IS NULL;
---Question: Có bao nhiêu địa chỉ như vậy?
SELECT COUNT(ad.address_id) as no_customer_address_count
FROM address as ad
LEFT JOIN customer as cus ON ad.address_id = cus.address_id
WHERE cus.customer_id IS NULL;

/*Question 7:
Task: Danh sách các thành phố và doanh thu tương ừng trên từng thành phố*/
SELECT ci.city, SUM(pa.amount) AS revenue
FROM city AS ci
JOIN address AS ad ON ci.city_id=ad.city_id
JOIN customer AS cus ON ad.address_id =cus.address_id
JOIN payment AS pa ON pa.customer_id=cus.customer_id
GROUP BY ci.city
ORDER BY SUM(pa.amount) DESC
---Question:Thành phố nào đạt doanh thu cao nhất?
SELECT ci.city, SUM(pa.amount) AS revenue
FROM city AS ci
JOIN address AS ad ON ci.city_id=ad.city_id
JOIN customer AS cus ON ad.address_id =cus.address_id
JOIN payment AS pa ON pa.customer_id=cus.customer_id
GROUP BY ci.city
ORDER BY SUM(pa.amount) DESC
LIMIT 1;

/*Question 8:
Task: Tạo danh sách trả ra 2 cột dữ liệu: 
-	cột 1: thông tin thành phố và đất nước ( format: “city, country")
-	cột 2: doanh thu tương ứng với cột 1*/
SELECT CONCAT(ci.city,', ',co.country) AS "city, country",
SUM(pa.amount) AS revenue
FROM city AS ci
JOIN country As co ON ci.country_id=co.country_id
JOIN address AS ad ON ci.city_id=ad.city_id
JOIN customer AS cus ON ad.address_id =cus.address_id
JOIN payment AS pa ON pa.customer_id=cus.customer_id
GROUP BY CONCAT(ci.city,', ',co.country)
ORDER BY SUM(pa.amount) ASC
---Question: thành phố của đất nước nào đat doanh thu thấp nhất
SELECT CONCAT(ci.city,', ',co.country) AS "city, country",
SUM(pa.amount) AS revenue
FROM city AS ci
JOIN country As co ON ci.country_id=co.country_id
JOIN address AS ad ON ci.city_id=ad.city_id
JOIN customer AS cus ON ad.address_id =cus.address_id
JOIN payment AS pa ON pa.customer_id=cus.customer_id
GROUP BY CONCAT(ci.city,', ',co.country)
ORDER BY SUM(pa.amount) ASC
LIMIT 1;

