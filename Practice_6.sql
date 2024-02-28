--- EX1:
With duplicate AS
(
SELECT DISTINCT company_id, title, description, COUNT(job_id) AS job_id_count
FROM job_listings
GROUP BY company_id,title, description
)

SELECT COUNT(company_id) AS duplicate_companies
FROM duplicate
WHERE job_id_count>=2;

--- EX2:
WITH CTE AS 
(
SELECT category, product, sum(spend) as total_spend 
FROM product_spend
WHERE EXTRACT(Year FROM transaction_date)='2022'
GROUP BY category, product
ORDER BY category, total_spend DESC
)

(SELECT *
FROM CTE 
WHERE category ='appliance'
LIMIT 2)

UNION ALL

(SELECT * 
FROM CTE
WHERE category ='electronics'
LIMIT 2)

--- EX3:
SELECT COUNT(policy_holder_id) AS member_count
FROM (
SELECT policy_holder_id, COUNT(case_id) as case_count
from callers
GROUP BY policy_holder_id
HAVING COUNT(case_id) >=3
) AS new_callers;

--- EX4:
SELECT page_id
FROM pages
WHERE page_id NOT IN (SELECT DISTINCT page_id 
FROM page_likes)

--- EX5:
WITH monthly AS (
SELECT user_id, event_type, COUNT(month) as month_count
FROM ( 
  SELECT user_id, event_type, 
  EXTRACT(month FROM event_date) AS month
  FROM user_actions
  WHERE EXTRACT(month FROM event_date) IN (6,7)
  ORDER BY user_id, event_type, month) AS CTE
GROUP BY user_id, event_type
HAVING COUNT(month)>=2
)
SELECT 7 as month,
COUNT(*) AS monthly_active_users
FROM monthly;

--- EX6:
SELECT SUBSTRING(trans_date,1,7) as month,
country, COUNT(id) AS trans_count,
SUM(CASE WHEN state='approved' THEN 1 ELSE 0 END) AS approved_count,
SUM(amount) AS trans_total_amount,
SUM(CASE WHEN state='approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM transactions
GROUP BY SUBSTRING(trans_date,1,7),country;

--- EX7:
SELECT product_id, year as first_year, quantity, price
FROM Sales
WHERE (product_id, year) IN (
SELECT product_id,MIN(year)
FROM sales
GROUP BY product_id);

--- EX8:
SELECT DISTINCT customer_id 
FROM customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(*) FROM product);

--- EX9:
SELECT employee_id
FROM employees
WHERE salary <30000
AND manager_id NOT IN ( SELECT employee_id FROM employees)
ORDER BY employee_id;

--- EX10:
Duplicate link EX1

--- EX11:
(SELECT u.name as results
FROM movierating as mr
JOIN users as u ON u.user_id = mr.user_id
GROUP BY mr.user_id
ORDER BY COUNT(mr.rating) DESC,u.name
LIMIT 1)

UNION ALL

(SELECT m.title as results
FROM movierating as mr
JOIN movies as m ON mr.movie_id=m.movie_id
WHERE SUBSTRING(mr.created_at,1,7) ='2020-02'
GROUP BY mr.movie_id
ORDER BY avg(mr.rating) DESC, m.title
LIMIT 1);

--- EX12:
WITH summary AS(
SELECT requester_id as id, 
SUM(case WHEN requester_id != accepter_id THEN 1 ELSE 0 END) AS amount
FROM RequestAccepted
GROUP by requester_id

UNION ALL

SELECT accepter_id as id, 
SUM(case WHEN requester_id != accepter_id THEN 1 ELSE 0 END) AS amount
FROM RequestAccepted
GROUP by accepter_id
)

SELECT DISTINCT id, SUM(amount) AS num
FROM summary
GROUP BY id
ORDER BY num DESC
LIMIT 1;


