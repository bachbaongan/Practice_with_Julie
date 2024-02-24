--- EX1:
SELECT 
SUM(CASE WHEN device_type ='laptop' THEN 1 ELSE 0
END) as laptop_reviews,
SUM(CASE WHEN device_type IN ('tablet','phone') THEN 1 ELSE 0
END) as mobile_views
FROM viewership;

--- EX2:
SELECT *,
CASE WHEN x+y>z AND x+z>y AND y+z>x THEN 'Yes' ELSE 'No' END as triangle
FROM triangle;

--- EX3:
Cannot run the query

  
--- EX4:
SELECT name 
FROM customer
WHERE referee_id !=2 or COALESCE(referee_id, 0)=0;

--- EX5:
select survived,
SUM(CASE WHEN pclass=1 THEN 1 ELSE 0 END) as first_class,
SUM(CASE WHEN pclass=2 THEN 1 ELSE 0 END) as second_class,
SUM(CASE WHEN pclass=3 THEN 1 ELSE 0 END) as third_class
from titanic
GROUP BY survived ;
