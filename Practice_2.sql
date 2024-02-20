--- EX1:
SELECT DISTINCT CITY
FROM STATION
WHERE mod(ID,2)=0;

--- EX2:
SELECT (COUNT(CITY) - COUNT(DISTINCT CITY)) DIFFERENT
FROM STATION;

--- EX3:
SELECT CEIL(AVG(CAST (SALARY AS DECIMAL)) - AVG(Replace((CAST (salary AS DECIMAL)),0,''))) extra
FROM EMPLOYEES;

--- EX4:
SELECT Round(CAST((SUM(item_count*order_occurrences)/sum(order_occurrences)) AS DECIMAL),1) as mean
FROM items_per_order;

--- EX5:
SELECT candidate_ID 
FROM candidates
WHERE skill IN ('Python','Tableau','PostgreSQL')
GROUP BY candidate_ID
HAVING COUNT(skill)=3
ORDER BY candidate_ID;

--- EX6:
SELECT user_id,
max(date(post_date)) - min(date(post_date)) AS day_between 
FROM posts
WHERE post_date BETWEEN '2021-01-01' AND '2022-01-01'
GROUP BY user_id
HAVING COUNT(post_id) >=2 ;

--- EX7:
SELECT card_name, 
MAX(issued_amount) - MIN(issued_amount) AS difference
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY MAX(issued_amount) - MIN(issued_amount) DESC;

--- EX8:
SELECT manufacturer, 
COUNT(product_id) AS drug_count,
SUM(cogs-total_sales) AS total_loss
FROM pharmacy_sales
WHERE total_sales<cogs
GROUP BY manufacturer
ORDER BY SUM(cogs-total_sales) DESC;

--- EX9:
SELECT *
FROM cinema
WHERE description NOT LIKE "boring"
HAVING MOD(ID,2)=1
ORDER BY rating DESC;

--- EX10:
SELECT teacher_id, COUNT(DISTINCT subject_id) AS cnt
FROM Teacher
GROUP BY teacher_id;

--- EX11:
SELECT user_id, COUNT(follower_id) AS followers_count
FROM followers
GROUP BY user_id
ORDER BY user_id;

--- EX12:
SELECT class
FROM courses
GROUP BY class
HAVING COUNT(student)>=5;



