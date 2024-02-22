--- EX1:
SELECT name
FROm students
WHERE marks>75
ORDER BY RIGHT(name,3), ID;

--- EX2:
SELECT user_id, 
  CONCAT(UPPER(Left(name,1)),LOWER(RIGHT(name,LENGTH(name)-1))) AS name
FROM users
ORDER BY user_id;

--- EX3:
SELECT manufacturer,
CONCAT('$',ROUND(SUM(total_sales)/1000000,0),' million') AS sale
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY SUM(total_sales) DESC, manufacturer;

--- EX4:
SELECT EXTRACT(month FROM submit_date) as mth,
product_id as product,
ROUND(AVG(stars),2) as avg_stars
FROM reviews
GROUP BY EXTRACT(month FROM submit_date), product_id
ORDER BY EXTRACT(month FROM submit_date), product_id;

--- EX5:
SELECT sender_id, 
COUNT(DISTINCT message_id) AS count_messages
FROM messages
WHERE sent_date BETWEEN '2022-08-01' AND '2022-09-01'
GROUP BY sender_id
ORDER BY COUNT(message_id) DESC
LIMIT 2;

--- EX6:
SELECT tweet_id
FROM Tweets
WHERE LENGTH(content) >15;

--- EX7:
SELECT activity_date as day,
COUNT(DISTINCT user_id) AS active_users
FROM activity
WHERE activity_date BETWEEN '2019-06-28' AND '2019-07-27'
GROUP BY activity_date;

--- EX8:
select EXTRACT(month FROM joining_date) AS Month,
COUNT(id) AS number_emplolyee
from employees
WHERE EXTRACT(year FROM joining_date)=2022
AND EXTRACT(month FROM joining_date) BETWEEN 1 and 7
GROUP BY EXTRACT(month FROM joining_date) ;

--- EX9:
select POSITION('a' IN first_name) 
from worker
WHERE first_name='Amitah';

--- EX10:
select title,
SUBSTRING(title FROM LENGTH(winery)+2 FOR 4) AS year
from winemag_p2
WHERE country='Macedonia';

