SELECT * FROM customer_shopping_data;

-- Checking the data type
SELECT column_name,
		data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'customer_shopping_data';

-- Changing the column types in the database
ALTER TABLE customer_shopping_data 
ALTER COLUMN age TYPE INT
USING age::integer;

ALTER TABLE customer_shopping_data
ALTER COLUMN price TYPE NUMERIC
USING price::numeric;

ALTER TABLE customer_shopping_data 
ALTER COLUMN quantity TYPE NUMERIC
USING quantity::numeric;

-- Changing data type of invoice_date
CREATE TEMP TABLE temp_date AS
	SELECT invoice_no,
			split_part(invoice_date, '/', 1) AS date,
			split_part(invoice_date, '/', 2) AS month,
			split_part(invoice_date, '/', 3) AS year
	FROM customer_shopping_data;

CREATE TEMP TABLE csd_v2 AS
WITH dates AS (
	SELECT invoice_no,
			CASE WHEN length(date) = 1 THEN '0'|| date ELSE date END,
			CASE WHEN length(month) = 1 THEN '0'|| month ELSE month END,
			year
	FROM temp_date
),
date_format AS (
	SELECT invoice_no,
		CONCAT (year, '-', month, '-', date)::DATE AS date
	FROM dates
)
SELECT csd.*, df.date AS inv_date
FROM customer_shopping_data AS csd
LEFT JOIN date_format AS df
USING(invoice_no);

SELECT * FROM csd_v2;

-- Analyzing nominal variables
SELECT DISTINCT customer_id, COUNT(*)
FROM csd_v2
GROUP BY customer_id
ORDER BY COUNT(*) DESC;

/*Hence from the given data sent we cannot analyze the buying habbits of an individual customer
 since each transaction contain a unique customer_id */

SELECT DISTINCT category, COUNT(*)
FROM csd_v2
GROUP BY category
ORDER BY COUNT(*) DESC;

/*There are 8 types of item category mentioned against the data set
- Clothing
- Cosmetics
- Food & Beverage
- Toys
- Shoes
- Souvenir
- Technology
- Books
*/

SELECT DISTINCT payment_method, COUNT(*) 
FROM csd_v2
GROUP BY payment_method
ORDER BY COUNT DESC;

/*There are three payment menthods in the dataset which are as following
 -Cash
 -Credit Card
 -Debit Card
 */

SELECT DISTINCT shopping_mall, COUNT(*)
FROM csd_v2
GROUP BY shopping_mall
ORDER BY COUNT DESC;

/*There are 10 shopping_malls which have be recorded in the data set:
 - Mall of Istanbul
 - Kanyon
 - Metrocity
 - Metropol AVM
 - Istinye Park
 - Zorlu Center
 - Cevahir AVM
 - Forum Istanbul
 - Viaport Outlet
 - Emaar Square Mall
 */

-- Analyzing numeric, integer and date variables
SELECT MIN(age), MAX(AGE), AVG(age), percentile_disc(0.5) WITHIN GROUP (ORDER BY age) AS median, stddev(age) AS stddev 
FROM csd_v2;

/*
- MIN = 18
- MAX = 69
- AVG = 43.4271
- MEDIAN = 43
- STDDEV = 14.99
Analyzing the values mentioned above shows that age is approximatly normally distributed. The outliers
don't have much effect on the distribution of age data.
*/

SELECT MIN(quantity), MAX(quantity), AVG(quantity), percentile_disc(0.5) WITHIN GROUP (ORDER BY quantity), stddev(quantity) 
FROM csd_v2;
/*
 - MIN = 1
 - MAX = 53
 - AVG = 3.0034
 - MEDIAN = 3
 - STDDEV = 1.4130
 Data is normally distributed. However, the curve of the distribution is narrower compared to age.
 This makes sence as the range of value for quantity is much less compared to age.
 */

SELECT MIN(price), MAX(price), AVG(price), percentile_cont(0.5) WITHIN GROUP (ORDER BY price) AS median, stddev(price) 
FROM csd_v2;

/*
- MIN = 5.23
- MAX = 5250
- AVG = 689.2563
- MEDIAN = 203.3
- STDDEV = 941.1846
The average and median shows that data is not normally distributed. The figures show that
data is left skewed which its distribution is wider then age and quantity.
*/

SELECT MIN(inv_date), MAX(inv_date)
FROM csd_v2;
/*
 - MIN = 2021-01-01
 - MAX = 2023-03-08
 */

/*The price variable needs to further investigated since it seems to be left skewed by analyzing figures.*/

