/*
Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
*/
SELECT t3.sales_rep, t2.region, t2.max_total_sales
FROM 
(SELECT region, MAX(total_amt_usd) max_total_sales
FROM
	(SELECT r.name as region, s.name as sales_rep, SUM(o.total_amt_usd) as total_amt_usd
	FROM region r
	JOIN sales_reps s
	ON r.id = s.region_id
	JOIN accounts a
	ON s.id = a.sales_rep_id
	JOIN orders o
	ON a.id = o.account_id
	GROUP BY 2, 1
	ORDER BY 3 DESC
	) t1
GROUP BY 1) t2
JOIN (
	SELECT r.name as region, s.name as sales_rep, SUM(o.total_amt_usd) as total_amt_usd
	FROM region r
	JOIN sales_reps s
	ON r.id = s.region_id
	JOIN accounts a
	ON s.id = a.sales_rep_id
	JOIN orders o
	ON a.id = o.account_id
	GROUP BY 2, 1
	ORDER BY 3 DESC
) t3
ON t2.region = t3.region AND t2.max_total_sales = t3.total_amt_usd;
/*
For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?
*/
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY 1
HAVING SUM(o.total_amt_usd) = 
(
	SELECT MAX(total_amt)
	FROM 
		(SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
		FROM sales_reps s
		JOIN accounts a
		ON a.sales_rep_id = s.id
		JOIN orders o
		ON o.account_id = a.id
		JOIN region r
		ON r.id = s.region_id
		GROUP BY r.name) t1
)


/*
How many accounts had more total purchases than the account name which has bought the most standard_qty paper 
throughout their lifetime as a customer?
*/
SELECT COUNT(*)
FROM
	(SELECT a.name account_name
	FROM accounts a
	JOIN orders o
	ON o.account_id = a.id
	GROUP BY 1
	HAVING SUM(o.total) > 
		(SELECT total 
		FROM
		(SELECT a.name account_name, SUM(o.standard_qty)total_std, SUM(o.total) total
		FROM accounts a
		JOIN orders o
		ON o.account_id = a.id
		GROUP BY 1
		ORDER BY 2 DESC
		LIMIT 1) t1)) counter_tab;

/*
For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events 
did they have for each channel?
*/
SELECT a.name, w.channel, COUNT(*)
FROM web_events w
JOIN accounts a
ON a.id = w.account_id AND a.id = (SELECT id FROM(
	SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
	FROM orders o
	JOIN accounts a
	ON a.id = o.account_id
	GROUP BY a.id, a.name
	ORDER BY 3 DESC
	LIMIT 1
)inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;


/*
What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
*/
SELECT AVG(total_amt)
FROM
	(SELECT a.id, a.name, SUM(o.total_amt_usd) total_amt
	FROM accounts a
	JOIN orders o
	ON a.id = o.account_id
	GROUP BY 1, 2
	ORDER BY 3 DESC
	LIMIT 10) inner_table;
