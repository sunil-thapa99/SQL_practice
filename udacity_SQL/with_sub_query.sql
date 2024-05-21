/*
Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
*/
WITH t1 as
	(SELECT s.name sales_rep, r.name region, SUM(o.total_amt_usd) total
	FROM sales_reps s
	JOIN region r
	ON r.id = s.region_id
	JOIN accounts a
	ON s.id = a.sales_rep_id
	JOIN orders o
	ON a.id = o.account_id
	GROUP BY 1, 2
	ORDER BY 3 DESC),
	t2 AS (SELECT region, MAX(total) total_amt
	FROM t1
	GROUP BY 1)
SELECT t1.sales_rep, t1.region, t1.total
FROM t1
JOIN t2
ON t1.region = t2.region AND t1.total = t2.total_amt;


/*
For the region with the largest sales total_amt_usd, how many total orders were placed?
*/
WITH t1 AS (
      SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
      FROM sales_reps s
      JOIN accounts a
      ON a.sales_rep_id = s.id
      JOIN orders o
      ON o.account_id = a.id
      JOIN region r
      ON r.id = s.region_id
      GROUP BY r.name), 
t2 AS (
      SELECT MAX(total_amt)
      FROM t1)
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);

/*
How many accounts had more total purchases than the account name which has bought the most standard_qty paper 
throughout their lifetime as a customer?
*/
WITH t1 AS (
      SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
      FROM accounts a
      JOIN orders o
      ON o.account_id = a.id
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 1), 
t2 AS (
      SELECT a.name
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY 1
      HAVING SUM(o.total) > (SELECT total FROM t1))
SELECT COUNT(*)
FROM t2;

/*
For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many 
web_events did they have for each channel?
*/
WITH t1 AS (
      SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
      LIMIT 1)
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;

/*
What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
*/
WITH t1 AS (
      SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
      LIMIT 10)
SELECT AVG(tot_spent)
FROM t1;