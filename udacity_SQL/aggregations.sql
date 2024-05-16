-- GROUP BY
-- Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.
SELECT a.name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY occurred_at
LIMIT 1;

-- Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and the company name.
SELECT a.name, SUM(total_amt_usd) total_sales
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name;

-- Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? Your query should return only three values - the date, channel, and account name.
SELECT w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id 
ORDER BY w.occurred_at DESC
LIMIT 1;

-- Find the total number of times each type of channel from the web_events was used. Your final table should have two columns - the channel and the number of times the channel was used.
SELECT w.channel, COUNT(*)
FROM web_events w
GROUP BY w.channel

-- Who was the primary contact associated with the earliest web_event?
SELECT a.primary_poc
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at
LIMIT 1;

-- What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name and the total usd. Order from smallest dollar amounts to largest.
SELECT a.name, MIN(total_amt_usd) smallest_order
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order;

-- Sort of strange we have a bunch of orders with no dollars. We might want to look into those.

-- Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. Order from fewest reps to most reps.

SELECT r.name, COUNT(*) num_reps
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
GROUP BY r.name
ORDER BY num_reps;



-- Questions: HAVING

-- How many of the sales reps have more than 5 accounts that they manage?
SELECT s.name, COUNT(a.id) acc_count
FROM sales_reps s
JOIN accounts a ON s.id = a.sales_rep_id
GROUP BY s.name
HAVING COUNT(a.id) > 5
ORDER BY acc_count;


-- How many accounts have more than 20 orders?
SELECT a.name, COUNT(o.total) as total_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
HAVING COUNT(o.total) > 20
ORDER BY total_orders;

-- Which account has the most orders?
SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY num_orders DESC
LIMIT 1;

-- Which accounts spent more than 30,000 usd total across all orders?
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spent;

-- DATE
-- Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. Do you notice any trends in the yearly sales totals?
SELECT DATE_PART('year', occurred_at) ord_year,  SUM(total_amt_usd) total_spent
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

/* 
Which month did Parch & Posey have the greatest sales in terms of total dollars? 
Are all months evenly represented by the dataset?
In order for this to be 'fair', we should remove the sales from 2013 and 2017. 
For the same reasons as discussed above.

*/
SELECT DATE_PART('month', occurred_at) ord_year,  SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;

/*
Which year did Parch & Posey have the greatest sales in terms of total number of orders? 
Are all years evenly represented by the dataset?
*/
SELECT DATE_PART('year', occurred_at) ord_year,  COUNT(*) total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

/*
Which month did Parch & Posey have the greatest sales in terms of total number of orders? 
Are all months evenly represented by the dataset?
*/
SELECT DATE_PART('month', occurred_at) ord_year,  COUNT(*) total_sales
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;

/*
In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
*/
SELECT DATE_TRUNC('month', o.occurred_at) ord_date, SUM(o.gloss_amt_usd) tot_spent
FROM orders o 
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- CASE
/*
Write a query to display for each order, the account ID, total amount of the order, and the level of the 
order - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or smaller than $3000.
*/
SELECT account_id, total_amt_usd,
   CASE WHEN total_amt_usd > 3000 THEN 'Large'
   ELSE 'Small' END AS order_level
FROM orders;

/*
Write a query to display the number of orders in each of three categories, based on the total number of 
items in each order. The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
*/
SELECT CASE WHEN total >= 2000 THEN 'At Least 2000'
	WHEN total < 2000 AND total >= 1000 THEN 'Between 1000 and 2000'
   ELSE 'Less than 1000' END AS order_level,
COUNT (*) AS order_count
FROM orders
GROUP BY 1;

/*
We would like to understand 3 different levels of customers based on the amount associated with their 
purchases. The top level includes anyone with a Lifetime Value (total sales of all orders) greater than 
200,000 usd. The second level is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd. 
Provide a table that includes the level associated with each account. You should provide the account name, 
the total sales of all orders for the customer, and the level. Order with the top spending customers listed 
first.
*/
SELECT a.name, SUM(o.total_amt_usd) total_amt_usd,
	CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'top'
		WHEN SUM(o.total_amt_usd) > 100000 THEN 'middle'
		ELSE 'low' END AS total_amt_spent
FROM orders o
JOIN accounts a ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC;

/*
We would now like to perform a similar calculation to the first, but we want to obtain the total amount 
spent by customers only in 2016 and 2017. Keep the same levels as in the previous question. Order with the 
top spending customers listed first.
*/

/*
We would like to identify top performing sales reps, which are sales reps associated with more than 
200 orders. Create a table with the sales rep name, the total number of orders, and a column with top or 
not depending on if they have more than 200 orders. Place the top sales people first in your final table.
*/

/*
The previous didn't account for the middle, nor the dollar amount associated with the sales. Management 
decides they want to see these characteristics represented as well. We would like to identify top performing 
sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales. 
The middle group has any rep with more than 150 orders or 500000 in sales. Create a table with the sales rep 
name, the total number of orders, total sales across all orders, and a column with top, middle, or low 
depending on this criteria. Place the top sales people based on dollar amount of sales first in your final 
table. You might see a few upset sales people by this criteria!
*/
