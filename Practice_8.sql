--- EX1:
SELECT 
ROUND(SUM(CASE WHEN ranking=1 AND order_date=customer_pref_delivery_date THEN 1 ELSE 0 END)*100/COUNT(DISTINCT customer_id),2) as immediate_percentage
FROM
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) as ranking
FROM delivery) as sub

---EX2:
SELECT ROUND(CAST((SUM(CASE WHEN gap=1 and order_ranking = 1 THEN 1 ELSE 0 END))AS decimal)/count(distinct player_id),2) as fraction
FROM (
SELECT *, 
LEAD(event_date) OVER(PARTITION BY player_id ORDER BY event_date) AS next_day,
LEAD(event_date) OVER(PARTITION BY player_id ORDER BY event_date) - event_date AS gap,
RANK() OVER(PARTITION BY player_id ORDER BY event_date) as order_ranking
FROM activity) as sub

--- EX3:
SELECT s1.id, 
CASE WHEN s2.student IS NOT NULL THEN s2.student ELSE s1.student END as student
FROM(
SELECT *,CASE WHEN mod(id,2)!=0 THEN id +1 ELSE id-1 END AS switch_id
FROM seat) as s1
LEFT JOIN seat as s2 ON s2.id=s1.switch_id

--- EX4:
SELECT visited_on, amount, average_amount
FROM (
SELECT sub.visited_on, SUM(sub.amount*1.0) OVER(ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as amount,
ROUND(AVG(sub.amount*1.0) OVER(ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) as average_amount,
LAG(visited_on,6) OVER() as visit_7
FROM (SELECT visited_on, sum(amount) as amount, ROW_NUMBER() OVER(ORDER BY visited_on)  as NUM_day
FROM customer
GROUP BY visited_on
ORDER BY visited_on) as sub
) as sub2
WHERE visit_7 IS NOT null;

--- EX5:
SELECT ROUND(CAST(sum(tiv_2016) AS DECIMAL),2) as tiv_2016
FROM insurance
WHERE tiv_2015 IN(
SELECT tiv_2015
FROM insurance
GROUP BY tiv_2015
HAVING COunt(*) >1)
AND (lat,lon) IN (
SELECT lat,lon
FROM insurance
GROUP BY lat,lon
HAVING COUNT(*)=1
)

--- EX6:
WITH CTE AS (
SELECT d.name as Department,e.name as Employee,e.salary as Salary,
DENSE_RANK() OVER(PARTITION BY d.name ORDER BY e.salary DESC) as ranking
FROM employee as e 
JOIN department as d ON e.departmentid=d.id
)
SELECT department, employee, salary
FROM CTE
WHERE ranking <=3

--- EX7:
SELECT person_name
FROM(
SELECT *,
SUM(weight) OVER(ORDER BY turn) as total_weight
FROM queue
) as sub
WHERE total_weight<=1000
ORDER BY total_weight DESC
LIMIt 1

--- EX8:
SELECT DISTINCT product_id, new_price as price
FROM products
WHERE (product_id, change_date) IN (
SELECT product_id, max(change_date) 
FROM products
WHERE change_date <='2019-08-16'
GROUP BY product_id)

UNION ALL

SELECT DISTINCT product_id, 10 as price
FROM products
GROUP BY product_id
HAVING min(change_date) >'2019-08-16'
