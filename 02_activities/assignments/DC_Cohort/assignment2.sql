/* ASSIGNMENT 2 */
--Please write responses between the QUERY # and END QUERY blocks
/* SECTION 2 */

-- COALESCE
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list:

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product


But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a blank for the first column with
nulls, and 'unit' for the second column with nulls. 

**HINT**: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same. */
--QUERY 1

--checking where the nulls are
SELECT 
product_name, 
product_size,  -- product size has nulls
product_qty_type -- product qty type has nulls
FROM product;

--trying the given syntax
SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product; -- null values across whole table

--adding the coalesce to size and qty
SELECT 
product_name || ', ' || 
COALESCE(product_size, 'unit') || 
' (' || COALESCE(product_qty_type, '') || ')'
FROM product;

--checking work
SELECT *,
product_name || ', ' || 
COALESCE(product_size, 'unit') || 
' (' || COALESCE(product_qty_type, '') || ')'
FROM product;

--END QUERY


--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). 
Filter the visits to dates before April 29, 2022. */
--QUERY 2

SELECT DISTINCT  -- unique values
	customer_id,
	market_date,
	
		dense_rank()  OVER (
			PARTITION BY customer_id 
			ORDER BY market_date
				) AS visit_number
	
FROM customer_purchases
WHERE market_date > '2022-04-29'
ORDER BY market_date, customer_id;

--switching order of results

SELECT DISTINCT
	customer_id,
	market_date,
	
		dense_rank()  OVER ( --dense rank assigns same rank to ties 
			PARTITION BY customer_id 
			ORDER BY market_date
				) AS visit_number1
	
FROM customer_purchases
WHERE market_date > '2022-04-29'
ORDER BY customer_id, market_date;

--END QUERY


/* 2. Reverse the numbering of the query so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit.
HINT: Do not use the previous visit dates filter. */
--QUERY 3

--reversing the order
SELECT DISTINCT
    customer_id,
    market_date,
    
		dense_rank() OVER (
			PARTITION BY customer_id 
			ORDER BY market_date DESC  -- descending order, reversing ranking, most recent date = #1
    ) AS visit_number_desc
    
FROM customer_purchases
ORDER BY customer_id, market_date;

--with subquery 

SELECT	
	customer_id,
	market_date,
	visit_number_desc
	
	--subquery
		FROM (
				SELECT DISTINCT
						customer_id,
						market_date,
    
						dense_rank() OVER (
						PARTITION BY customer_id 
						ORDER BY market_date DESC  -- descending order, reversing ranking, most recent date = #1
						) AS visit_number_desc
		FROM customer_purchases)
		
		AS ranked_visits
WHERE visit_number_desc = 1
ORDER BY customer_id;


--checking work, noting that all visits in result table are in 2023-10
SELECT DISTINCT  --changing date filter
	customer_id,
	market_date,
	
		dense_rank()  OVER (
			PARTITION BY customer_id 
			ORDER BY market_date
				) AS visit_number
	
FROM customer_purchases
WHERE market_date > '2023-10-01'
ORDER BY market_date, customer_id;

--END QUERY


/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. 

You can make this a running count by including an ORDER BY within the PARTITION BY if desired.
Filter the visits to dates before April 29, 2022. */

--QUERY 4

SELECT 
	customer_id,
	vendor_id, --product number shared between vendors, so need vendor_id for comp key
	product_id,
	market_date,
	quantity,
	
		COUNT (product_id) 
		OVER (
			PARTITION BY customer_id, product_id)
			as num_of_purchases
			
FROM customer_purchases

WHERE market_date > '2022-04-29' --adding date filter 

--END QUERY


-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */
--QUERY 5

SELECT 
    product_name,
    CASE 
		WHEN INSTR(product_name,'-') > 0  --finding the hyphens
        THEN TRIM (SUBSTR (product_name, INSTR (product_name, '-') + 1)) --trims hyphen
        ELSE NULL 
	  
	END AS description_of_product --mkes the new column with the trimmed description 
	
FROM product
ORDER BY product_name;

--END QUERY


/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */
--QUERY 6

-- a lot of hate for REGEXP in class lol

SELECT 
    product_name,
    product_size
FROM product
WHERE product_size REGEXP '[0-9]';

--playing around/checking table
--SELECT 
    --product_name,
   -- product_size
--FROM product
--WHERE product_size > 0

--END QUERY


-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */
--QUERY 7

-- step one: find sales values grouped dates
WITH sales_per_date AS (
    SELECT 
        market_date,
	  quantity,
	  cost_to_customer_per_qty,
        ROUND(SUM(quantity * cost_to_customer_per_qty), 2) AS total_sales
    FROM customer_purchases
    GROUP BY market_date --internal part runs
),

-- step two: rank windowed function
ranked_sales AS (
    SELECT 
        market_date,
        total_sales, --pulling from step one
        RANK() OVER (ORDER BY total_sales DESC) AS best_rank,
        RANK() OVER (ORDER BY total_sales ASC)  AS worst_rank
    FROM sales_per_date
)

-- best day
-- worst day
	SELECT 
		market_date,
		total_sales,
		'Best Day' AS sales_category -- adding best day section 
	FROM ranked_sales
	WHERE best_rank = 1

-- step three: union 
UNION

	SELECT 
		market_date,
		total_sales,
		'Worst Day' AS sales_category -- adding best day section :( 
	FROM ranked_sales
	WHERE worst_rank = 1

ORDER BY total_sales DESC;


--checking work -- see same date as Best Day result, and same total 
SELECT 
	market_date,
	ROUND(SUM(quantity * cost_to_customer_per_qty), 2) AS total_sales
FROM customer_purchases

GROUP BY market_date
HAVING ROUND(SUM(quantity * cost_to_customer_per_qty), 2) > 900
ORDER BY total_sales DESC;

--END QUERY



/* SECTION 3 */

-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */
--QUERY 8

SELECT DISTINCT -- how many distinct products are there 
    vendor_id,
    product_id
FROM vendor_inventory; --returns 8 rows 

SELECT DISTINCT 
customer_id
FROM customer;

SELECT 
	COUNT(DISTINCT customer_id)
FROM customer; -- 26 distinct customer IDS
-- should have 208 = 8*26


--cross join
SELECT 
    vi.vendor_id,
    vi.product_id,
    c.customer_id
FROM (
    SELECT DISTINCT vendor_id, product_id, original_price
    FROM vendor_inventory
) vi
CROSS JOIN customer c;
--haha it has 208 rows, as expected 

--final 
SELECT 
    v.vendor_name, --using vendor name and price
    p.product_name,
    vi.original_price,
    COUNT(c.customer_id) AS total_customers,
    5 AS qty_per_customer,
    ROUND(vi.original_price * 5 * COUNT(c.customer_id), 2) AS total_revenue --stock of 5 of each product 
    
FROM (
    SELECT DISTINCT vendor_id, product_id, original_price
    FROM vendor_inventory
) vi

CROSS JOIN customer c

JOIN vendor v   ON vi.vendor_id  = v.vendor_id
JOIN product p  ON vi.product_id = p.product_id
GROUP BY v.vendor_name, p.product_name, vi.original_price
ORDER BY v.vendor_name, p.product_name;

--END QUERY


-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

--QUERY 9


DROP TABLE IF EXISTS temp.product_units;
CREATE TEMP TABLE product_units AS
	SELECT *,
	CURRENT_TIMESTAMP as snapshot_timestamp -- current time/current quantity, not this time zone tho
	
	FROM product
	WHERE product_qty_type = 'unit';

--checking to see temp table and that timestamp is there
SELECT * 
	FROM product_units
	
--END QUERY


/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

--QUERY 10

INSERT INTO product_units
VALUES(100,'baby carrot sticks','1 lb',3,'lbs', CURRENT_TIMESTAMP);

--checking for baby carrots 
SELECT * 
	FROM product_units

--END QUERY


-- DELETE
/* 1. Delete the older record for the whatever product you added. 
HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/ --very ominous

--QUERY 11

DELETE FROM product_units
--SELECT * FROM product_expanded -- can help you determine you are looking  at the right rows before running a deletion
WHERE product_id = 100 ;

--checking for baby carrots 
SELECT * 
	FROM product_units --it's gone

--END QUERY


-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;


Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 

Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 

Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 

Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
	
When you have all of these components, you can run the update statement. */

--QUERY 12

--adding the new column
ALTER TABLE product_units
ADD current_quantity INT;

SELECT * 
	FROM product_units --it's there, but all null values
	
--most recent quantity per product -- based on most recent/MAX market date
SELECT 
    product_id,
    quantity
FROM vendor_inventory

WHERE market_date = (
    SELECT MAX(market_date)
    FROM vendor_inventory vi2
    WHERE vi2.product_id = vendor_inventory.product_id
);
	--only 8 products have current quantity
	
--coalesce for nulls
SELECT 
    COALESCE(
        (SELECT quantity 
         FROM vendor_inventory vi
         WHERE vi.product_id = product_units.product_id
         AND vi.market_date = (
	   
             SELECT MAX(market_date) 
             FROM vendor_inventory vi2
             WHERE vi2.product_id = product_units.product_id
         )
        ), 0)
FROM product_units;
-- can see 0s in results 


-- update 
UPDATE product_units
SET current_quantity = COALESCE(

				(SELECT quantity 
				FROM vendor_inventory vi
				WHERE vi.product_id = product_units.product_id
				AND vi.market_date = 
				
					(SELECT MAX(market_date) 
					FROM vendor_inventory vi2
					WHERE vi2.product_id = product_units.product_id
					)
				0)

WHERE product_units.product_id IN (
    SELECT product_id 
    FROM vendor_inventory
);

-- checking work 
SELECT *
FROM product_units;


-- still seeing nulls, troubleshooting 
SELECT 
	product_id, 
	product_name 
	FROM product_units;

SELECT DISTINCT 
	product_id 
	FROM vendor_inventory;

--END QUERY



