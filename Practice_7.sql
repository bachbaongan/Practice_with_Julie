--- EX1:
WITH summary AS(
SELECT EXTRACT(year FROM transaction_date) AS year, product_id,
spend as curr_year_spend,
LAG(spend) OVER(PARTITION BY product_id ORDER BY product_id ) AS pre_year_spend
FROM user_transactions
)

SELECT *,
ROUND((curr_year_spend-pre_year_spend)/pre_year_spend*100,2) AS yoy_rate
FROM summary

--- EX2:
SELECT card_name, issued_amount
FROM(
SELECT *,
DENSE_RANk() OVER(PARTITION BY card_name ORDER BY issue_year, issue_month) AS rank
FROM monthly_cards_issued) AS subtable
WHERE rank =1
ORDER BY issued_amount DESC;

--- EX3:
SELECT user_id, spend, transaction_date
FROM (
SELECT *,
RANK() OVER(PARTITION BY user_id ORDER BY transaction_date) AS rank
FROM transactions) AS subtable
WHERE rank =3;

--- EX4:
WITH CTE AS (
SELECT *,
RANK() OVER(PARTITION BY user_id ORDER BY transaction_date DESC) AS rank
FROM user_transactions
)
SELECT transaction_date, user_id, COUNT(product_id)
FROM CTE
WHERE rank =1
GROUP BY user_id, transaction_date
ORDER BY transaction_date;

--- EX5:
WITH subtweets AS (
SELECT *, 
LAG(tweet_count) OVER(PARTITION BY user_id ORDER BY tweet_date) AS lag_1,
LAG(tweet_count,2) OVER(PARTITION BY user_id ORDER BY tweet_date) AS lag_2
FROM tweets
)
SELECT user_id, tweet_date,
CASE 
WHEN lag_1 IS NOT NULL and lag_2 IS NOT NULL THEN ROUND(1.0*(tweet_count+ lag_1+ lag_2)/3,2)
WHEN lag_1 IS NOT NULL and lag_2 IS NULL THEN ROUND(1.0*(tweet_count+ lag_1)/2,2)
ELSE ROUND(tweet_count*1.0,2) END AS rolling_avg_3d
FROM subtweets;

--- EX6:
SELECT COUNT(*) AS payment_count
FROM (
SELECT *, 
LEAD(transaction_timestamp) OVER(PARTITION BY merchant_id, credit_card_id, amount) AS next_trans,
(LEAD(transaction_timestamp) OVER(PARTITION BY merchant_id, credit_card_id, amount))- transaction_timestamp as gap
FROM transactions
) AS subtable
WHERE gap <= INTERVAL '10 minutes';

--- EX7:
WITH summary AS (
SELECT *,
DENSE_RANK() OVER(PARTITION BY category ORDER BY total_spend DESC, product) as ranking
FROM(
SELECT category, product,
SUM(spend) as total_spend
FROM product_spend
WHERE EXTRACT(YEAR FROM transaction_date)='2022'
GROUP BY category, product
) as subtable
)
SELECT category, product, total_spend
FROM summary
WHERE ranking IN (1,2);

--- EX8:
WITH summary AS(
SELECT *,
DENSE_RANK() OVER(ORDER BY count DESC) AS artist_rank
FROM (
SELECT ar.artist_name,
COUNT (s.song_id) as count
FROM global_song_rank AS gl
JOIN songs as s ON s.song_id=gl.song_id
JOIN artists as ar ON ar.artist_id = s.artist_id
WHERE rank<=10
GROUP BY ar.artist_name
ORDER BY count(s.song_id) DESC) AS subtable
)
SELECT artist_name, artist_rank
FROM summary
WHERE artist_rank<=5;
