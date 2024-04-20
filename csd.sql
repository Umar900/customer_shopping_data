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


