 /* ASSIGNMENT 1 */
--Please write responses between the QUERY # and END QUERY blocks
/* SECTION 2 */


--SELECT
/* 1. Write a query that returns everything in the customer table. */
--QUERY 1

SELECT *
FROM customer;

--END QUERY


/* 2. Write a query that displays all of the columns and 10 rows from the customer table, 
sorted by customer_last_name, then customer_first_ name. */
--QUERY 2

SELECT *
FROM customer
ORDER BY customer_last_name,  customer_first_name
LIMIT 10;

--END QUERY


--WHERE
/* 1. Write a query that returns all customer purchases of product IDs 4 and 9. 
Limit to 25 rows of output. */
--QUERY 3

SELECT *
FROM customer_purchases
WHERE  product_id = 4 
OR product_id = 9;

-- product ID 9 does not exist? --
--adding limit of 25 rows-- 

SELECT *
FROM customer_purchases
WHERE  product_id = 4 
OR product_id = 9
LIMIT 25; 

--END QUERY


/*2. Write a query that returns all customer purchases and a new calculated column 'price' (quantity * cost_to_customer_per_qty), 
filtered by customer IDs between 8 and 10 (inclusive) using either:
	1.  two conditions using AND
	2.  one condition using BETWEEN
Limit to 25 rows of output.
*/
--QUERY 4

SELECT *,
	(quantity * cost_to_customer_per_qty) AS price
FROM customer_purchases
WHERE customer_id BETWEEN 8 AND 10
LIMIT 25; 

--or, using the >=< signs--

SELECT *,
	(quantity * cost_to_customer_per_qty) AS price
FROM customer_purchases
WHERE customer_id >=8 
	AND customer_id <=10
LIMIT 25; 

--END QUERY


--CASE
/* 1. Products can be sold by the individual unit or by bulk measures like lbs. or oz. 
Using the product table, write a query that outputs the product_id and product_name
columns and add a column called prod_qty_type_condensed that displays the word “unit” 
if the product_qty_type is “unit,” and otherwise displays the word “bulk.” */
--QUERY 5

SELECT 
	product_id, 
	product_name,
	CASE WHEN product_qty_type = 'unit'  THEN 'unit'
	ELSE 'bulk'
	END as prod_qty_type

FROM product;

--END QUERY


/* 2. We want to flag all of the different types of pepper products that are sold at the market. 
add a column to the previous query called pepper_flag that outputs a 1 if the product_name 
contains the word “pepper” (regardless of capitalization), and otherwise outputs 0. */
--QUERY 6

SELECT product_id, product_name,
	CASE WHEN product_qty_type = 'unit'  THEN 'unit'
	ELSE 'bulk'
	END as prod_qty_type

,CASE WHEN product_name LIKE '%pepper%' THEN 1
	ELSE 0
	END as pepper_flag
FROM product;

--END QUERY


--JOIN
/* 1. Write a query that INNER JOINs the vendor table to the vendor_booth_assignments table on the 
vendor_id field they both have in common, and sorts the result by market_date, then vendor_name.
Limit to 24 rows of output. */
--QUERY 7

SELECT *
FROM vendor
INNER JOIN vendor_booth_assignments
	ON vendor.vendor_id = vendor_booth_assignments.vendor_id
ORDER BY  market_date,  vendor_name
LIMIT 24;

--END QUERY



/* SECTION 3 */

-- AGGREGATE
/* 1. Write a query that determines how many times each vendor has rented a booth 
at the farmer’s market by counting the vendor booth assignments per vendor_id. */
--QUERY 8

 SELECT COUNT(vendor_id) as num_of_rentals1
 FROM vendor_booth_assignments;

--not grouped by vendor id--

SELECT vendor_id,
	COUNT (vendor_id) as num_of_rentals2
FROM vendor_booth_assignments
GROUP BY vendor_id;

 --vendor_id of 2,5,6 do not exist in vendor_booth_assignments so the final table makes sense--

--END QUERY


/* 2. The Farmer’s Market Customer Appreciation Committee wants to give a bumper 
sticker to everyone who has ever spent more than $2000 at the market. Write a query that generates a list 
of customers for them to give stickers to, sorted by last name, then first name. 

HINT: This query requires you to join two tables, use an aggregate function, and use the HAVING keyword. */
--QUERY 9

-- joining the tables with customer_id-- 
SELECT *
FROM customer
INNER JOIN customer_purchases
	ON customer.customer_id = customer_purchases.customer_id
ORDER BY  customer_last_name, customer_first_name;


--selecting the relevant columns and using table aliases -- 
SELECT 
    c.customer_first_name,
    c.customer_last_name,
    c.customer_id,
    cp.quantity,
    cp.cost_to_customer_per_qty
FROM customer AS c
INNER JOIN customer_purchases AS cp
    ON c.customer_id = cp.customer_id
ORDER BY c.customer_last_name, c.customer_first_name;

-- now adding the sum to determine the purchase totals
--,SUM(quantity*cost_to_customer_per_qty) as total_spend
--HAVING total_spend > 2000

-- final query 
SELECT 
    c.customer_first_name,
    c.customer_last_name,
    c.customer_id,
    cp.quantity,
    cp.cost_to_customer_per_qty,
    SUM (cp.quantity * cp.cost_to_customer_per_qty) AS total_spend
FROM customer AS c
INNER JOIN customer_purchases AS cp
    ON c.customer_id = cp.customer_id
GROUP BY c.customer_last_name, c.customer_first_name
HAVING total_spend > 2000
ORDER BY c.customer_id, c.customer_last_name, c.customer_first_name;


--checking results without >2000 and order by--
SELECT 
    c.customer_first_name,
    c.customer_last_name,
    c.customer_id,
    cp.quantity,
    cp.cost_to_customer_per_qty,
    SUM (cp.quantity * cp.cost_to_customer_per_qty) AS total_spend
FROM customer AS c
INNER JOIN customer_purchases AS cp
    ON c.customer_id = cp.customer_id
GROUP BY c.customer_last_name, c.customer_first_name

--END QUERY


--Temp Table
/* 1. Insert the original vendor table into a temp.new_vendor and then add a 10th vendor: 
Thomass Superfood Store, a Fresh Focused store, owned by Thomas Rosenthal

HINT: This is two total queries -- first create the table from the original, then insert the new 10th vendor. 
When inserting the new vendor, you need to appropriately align the columns to be inserted 
(there are five columns to be inserted, I've given you the details, but not the syntax) 

-> To insert the new row use VALUES, specifying the value you want for each column:
VALUES(col1,col2,col3,col4,col5) 
*/
--QUERY 10

-- vendor_id, vendor_name, vendor_type, vendor_owner_first_name, vendor_owner_last_name - from vendor table
-- will be 10, Thomass Superfood Store, a Fresh Focused store, Thomas, Rosenthal

DROP TABLE IF EXISTS temp.new_vendor;

--creating the new table
CREATE TABLE temp.new_vendor AS
SELECT *
FROM vendor;

--inserting the values in 
INSERT INTO temp.new_vendor
VALUES(10,
	'Thomass Superfood Store', 
	'a Fresh Focused store', 
	'Thomas',
	'Rosenthal');
	
--checking work - yay it shows up!!!!
SELECT * FROM temp.new_vendor;



--END QUERY


-- Date
/*1. Get the customer_id, month, and year (in separate columns) of every purchase in the customer_purchases table.

HINT: you might need to search for strfrtime modifers sqlite on the web to know what the modifers for month 
and year are! 
Limit to 25 rows of output. */
--QUERY 11




--END QUERY


/* 2. Using the previous query as a base, determine how much money each customer spent in April 2022. 
Remember that money spent is quantity*cost_to_customer_per_qty. 

HINTS: you will need to AGGREGATE, GROUP BY, and filter...
but remember, STRFTIME returns a STRING for your WHERE statement...
AND be sure you remove the LIMIT from the previous query before aggregating!! */
--QUERY 12




--END QUERY
