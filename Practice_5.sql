--- EX1:
SELECT co.continent, FLOOR(AVG(ci.population)) AS avg_population
FROM Country as co
JOIN city as ci ON co.code=ci.countrycode
GROUP BY co.continent;

--- EX2:
SELECT 
ROUND(CAST(SUM(CASE WHEN te.signup_action ='Confirmed' THEN 1 ELSE 0 END) as decimal)/Count(te.signup_action),2) as confirm_rate
FROM emails as em
LEFT JOIN texts as te ON em.email_id=te.email_id;

--- EX3:
SELECT ag.age_bucket,
ROUND(CAST(SUM(CASE WHEN ac.activity_type ='send' THEN ac.time_spent ELSE 0 END) as decimal)/sum(ac.time_spent)*100,2) as send_perc,
ROUND(CAST(SUM(CASE WHEN ac.activity_type ='open' THEN ac.time_spent ELSE 0 END) as decimal)/sum(ac.time_spent)*100,2) as open_perc
FROM activities AS ac
JOIN age_breakdown as ag ON ac.user_id=ag.user_id
WHERE ac.activity_type IN ('send','open')
GROUP BY ag.age_bucket;

--- EX4:
SELECT cus.customer_id 
FROM customer_contracts as cus
JOIN products as pro ON cus.product_id = pro.product_id
GROUP BY cus.customer_id
HAVING COUNT(DISTINCT pro.product_category)=3;

--- EX5:
SELECT e2.employee_id, e2.name, 
COUNT(e1.employee_id ) as reports_count, 
ROUND(AVG(e1.age),0) as average_age
FROM employees as e1
JOIN employees as e2 ON e1.reports_to = e2.employee_id
GROUP BY e2.employee_id
ORDER BY e2.employee_id;

--- EX6:
SELECT pro.product_name, SUM(od.unit) AS unit
FROM products AS pro
JOIN orders as od ON pro.product_id = od.product_id
WHERE od.order_date BETWEEN '2020-02-01' AND '2020-02-29'
GROUP BY pro.product_name
HAVING SUM(od.unit) >=100;

--- EX7:
SELECT pa.page_id
FROM pages as pa
LEFT JOIN page_likes as pl ON pa.page_id=pl.page_id
WHERE pl.liked_date IS NULL
ORDER BY pa.page_id;
