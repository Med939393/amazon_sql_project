-- Amazon Sales Analysis Projects 

-- Create the table so we can import the data


CREATE TABLE sales(
					id int PRIMARY KEY,
					order_date date,
					customer_name VARCHAR(25),
					state VARCHAR(25),
					category VARCHAR(25),
					sub_category VARCHAR(25),
					product_name VARCHAR(255),
					sales FLOAT,
					quantity INT,
					profit FLOAT
					);

-- Importing the data into the table 

-- -------------------------------------------------------------------------------------
-- Exploratory Data Analysis and Pre Processing
-- -------------------------------------------------------------------------------------

select * from sales

--  Checking total rows count

select * from sales

select count(*) from sales 


-- Checking if there any missing values

select count(*) from sales where id is null or order_date is null  or customer_name is null   or state is null 

or category  is null  or sub_category is null  or product_name is null  or sales is null  or quantity is null   or profit is null 

--  Checking for duplicate entry 

with cte as ( select *, row_number () over (partition by id  ,  order_date  ,  customer_name , state  

, category ,    sub_category ,  product_name  , sales ,quantity , profit order by  id   , order_date  ,  customer_name , state  

, category ,    sub_category ,  product_name  , sales ,quantity , profit  ) as rn from sales )

select * from cte  where rn > 1

-- Feature Engineering 

--  creating a year column

ALTER TABLE sales
ADD COLUMN YEAR VARCHAR(4);
-- adding year value into the year column
UPDATE sales
SET year = EXTRACT(YEAR FROM order_date);

-- creating a new column for the month 
ALTER TABLE sales
ADD COLUMN MONTH VARCHAR(15);

-- adding abbreviated month name  
UPDATE sales
SET month = TO_CHAR(order_date, 'mon');

-- adding new column as day_name
ALTER TABLE sales
ADD COLUMN day_name VARCHAR(15);

-- updating day name into the day column
UPDATE sales 
SET day_name = TO_CHAR(order_date, 'day');

SELECT TO_CHAR(order_date, 'day')
FROM sales;

select * from sales

select TO_CHAR(order_date, 'mon') from sales


-- Solving Business Problems 
-- -------------------------------------------------------------------------------------
-- Q.1 Find total sales for each category ?

select * from sales 

select category,ROUND(SUM(sales)::numeric, 4) as total_sales from sales group by 1 order by 2 DESC

-- Q.2 Find out top 5 customers who made the highest profits?

select customer_name,SUM(profit) as highest_profits from sales group by 1 order by 2 DESC limit 5

-- Q.3 Find out average qty ordered per category 

select category,AVG(quantity) as average_qty from sales group by 1 order by 2 DESC

-- Q.4 Top 5 products that has generated highest revenue 

select * from sales 

select product_name,ROUND(SUM(sales)::numeric, 2) as total_sales from sales group by 1 order by 2 DESC limit 5 

-- Q.5 Top 5 products whose revenue has decreased in comparison to previous year?

WITH py1 
AS (
	SELECT
		product_name,
		SUM(sales) as revenue
	FROM sales
	WHERE year = '2023'
	GROUP BY 1
),
py2 
AS	(
	SELECT
		product_name,
		SUM(sales) as revenue
	FROM sales
	WHERE year = '2022'
	GROUP BY 1
)
SELECT
	py1.product_name,
	py1.revenue as current_revenue,
	py2.revenue as prev_revenue,
	(py1.revenue / py2.revenue) as revenue_decreased_ratio
FROM py1
JOIN py2
ON py1.product_name = py2.product_name
WHERE py1.revenue < py2.revenue
ORDER BY 2 DESC
LIMIT 5;

-- Q.6 Highest profitable sub category ?

select * from sales 

select sub_category ,SUM(profit) as profits from sales group by 1 order by 2 DESC limit 1 

-- Q.7 Find out states with highest total orders? 

select state,COUNT(id) as  total_orders from sales group by 1 order by 2 DESC

-- Q.8 Determine the month with the highest number of orders.

select * from sales 

SELECT 
	(month ||'-' || year) month_name, -- for mysql CONCAT()
	COUNT(id) as number_of_orders
FROM sales
GROUP BY 1
ORDER BY 2 DESC;

-- Q.9 Calculate the profit margin percentage for each sale (Profit divided by Sales).

SELECT category,
	SUM(profit/sales) as profit_mergin
FROM sales group by 1 order by 2 DESC

-- Q.10 Calculate the percentage contribution of each sub-category to 
-- the total sales amount for the year 2023.

select * from sales 

WITH CTE
	AS (SELECT
			sub_category,
			SUM(sales) as revenue_per_category
		FROM sales
		WHERE year = '2023'
		GROUP BY 1

)

SELECT	
	sub_category,
	(revenue_per_category / total_sales * 100) as percentage_contribution
FROM cte
CROSS JOIN
(SELECT SUM(sales) AS total_sales FROM sales WHERE year = '2023') AS cte1;

-- End of Project

