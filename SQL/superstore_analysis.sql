USE superstore_project;

DESCRIBE superstore_cleaned;


-- 1. TOTAL ROW COUNT
SELECT COUNT(*) AS total_rows
FROM superstore_cleaned;

-- 2. NULL AUDIT
-- 🟢 RUN KAR SAKTE HO
-- Purpose: Important columns mein NULL values check karna
-- =========================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(`Order ID` IS NULL) AS order_id_nulls,
    SUM(`Order Date` IS NULL) AS order_date_nulls,
    SUM(`Ship Date` IS NULL) AS ship_date_nulls,
    SUM(`Customer ID` IS NULL) AS customer_id_nulls,
    SUM(`Customer Name` IS NULL) AS customer_name_nulls,
    SUM(`Postal Code` IS NULL) AS postal_code_nulls,
    SUM(`Product ID` IS NULL) AS product_id_nulls,
    SUM(`Sales` IS NULL) AS sales_nulls,
    SUM(`Quantity` IS NULL) AS quantity_nulls,
    SUM(`Discount` IS NULL) AS discount_nulls,
    SUM(`Profit` IS NULL) AS profit_nulls
FROM superstore_cleaned;



-- 3. DUPLICATE ROW ID CHECK
-- 🟢 RUN KAR SAKTE HO
-- Purpose: Duplicate Row IDs check karna
-- =========================================================

SELECT COUNT(*) AS duplicate_row_ids
FROM (
    SELECT `Row ID`
    FROM superstore_cleaned
    GROUP BY `Row ID`
    HAVING COUNT(*) > 1
) AS duplicates;

-- 4. VIEW DATA
-- 🟢 RUN KAR SAKTE HO
-- Purpose: Table ke records dekhna
-- =========================================================

SELECT *
FROM superstore_cleaned
LIMIT 100;



-- 5. ORDER DATE vs SHIP DATE CHECK
-- 🟢 RUN KAR SAKTE HO
-- Purpose: Ship Date Order Date se pehle toh nahi
-- =========================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(
        STR_TO_DATE(`Ship Date`, '%d-%m-%y')
        < STR_TO_DATE(`Order Date`, '%d-%m-%y')
    ) AS invalid_ship_dates
FROM superstore_cleaned;


-- 6. DATE CONVERSION PREVIEW
-- 🟢 RUN KAR SAKTE HO
-- Purpose: Text dates ko DATE mein convert karke preview karna
-- =========================================================

SELECT
    `Order Date`,
    STR_TO_DATE(`Order Date`, '%d-%m-%y') AS order_date_converted,
    `Ship Date`,
    STR_TO_DATE(`Ship Date`, '%d-%m-%y') AS ship_date_converted
FROM superstore_cleaned
LIMIT 20;





-- 7. NEW DATE COLUMNS CREATE
-- 🔴 RUN MAT KARNA
-- Already executed successfully
-- Purpose: DATE type ke temporary columns banana
-- =========================================================

ALTER TABLE superstore_cleaned
ADD COLUMN order_date_new DATE,
ADD COLUMN ship_date_new DATE;


-- 8. TEXT DATE → DATE CONVERSION
-- 🔴 RUN MAT KARNA
-- Already executed successfully
-- 9,994 rows update ho chuki hain
-- =========================================================

UPDATE superstore_cleaned
SET
    order_date_new = STR_TO_DATE(`Order Date`, '%d-%m-%y'),
    ship_date_new = STR_TO_DATE(`Ship Date`, '%d-%m-%y');
    
    
    
-- 9. OLD vs NEW DATE VERIFICATION
-- 🟢 RUN KAR SAKTE HO
-- Purpose: Converted dates verify karna
-- =========================================================

SELECT
    `Order Date`,
    order_date_new,
    `Ship Date`,
    ship_date_new
FROM superstore_cleaned
LIMIT 20;
    
    
    
-- 10. FINAL DATE CONVERSION VALIDATION
-- 🟢 RUN KAR SAKTE HO
-- Purpose: Converted DATE columns mein NULL/error
-- aur invalid date relationship check karna
-- =========================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(order_date_new IS NULL) AS order_date_nulls,
    SUM(ship_date_new IS NULL) AS ship_date_nulls,
    SUM(ship_date_new < order_date_new) AS invalid_date_relationship
FROM superstore_cleaned;



SELECT
    COUNT(*) AS total_rows,
    SUM(order_date_new IS NULL) AS order_date_nulls,
    SUM(ship_date_new IS NULL) AS ship_date_nulls,
    SUM(ship_date_new < order_date_new) AS invalid_date_relationship
FROM superstore_cleaned;



-- STEP 12: QUANTITY & DISCOUNT VALIDATION
-- Purpose: Check whether Quantity and Discount contain
-- logically invalid values.
-- This query only checks the data; it does NOT change data.
-- =========================================================

SELECT
    COUNT(*) AS total_rows,

    -- Check for zero or negative quantity
    SUM(Quantity <= 0) AS invalid_quantity,

    -- Check for discount outside the valid range 0 to 1
    SUM(Discount < 0 OR Discount > 1) AS invalid_discount

FROM superstore_cleaned;



-- STEP 13: SALES & PROFIT VALIDATION
-- Purpose: Check for NULL, zero, or unusual values
-- in Sales and Profit columns.
-- This query only checks the data; it does NOT change data.
-- =========================================================

SELECT
    COUNT(*) AS total_rows,

    -- Count NULL Sales values
    SUM(Sales IS NULL) AS sales_nulls,

    -- Count NULL Profit values
    SUM(Profit IS NULL) AS profit_nulls,

    -- Count zero Sales values
    SUM(Sales = 0) AS zero_sales,

    -- Count negative Profit values
    SUM(Profit < 0) AS negative_profit_rows

FROM superstore_cleaned;



-- STEP 14: FINAL DATA QUALITY SUMMARY
-- Purpose: Perform a final high-level quality check
-- before moving to SQL analysis.
-- This query only checks the data; it does NOT change data.
-- =========================================================

SELECT
    COUNT(*) AS total_rows,

    -- Check whether Row ID values are unique
    COUNT(DISTINCT `Row ID`) AS unique_row_ids,

    -- Check for missing Order IDs
    SUM(`Order ID` IS NULL) AS null_order_ids,

    -- Check for missing Sales values
    SUM(Sales IS NULL) AS null_sales,

    -- Check for missing Profit values
    SUM(Profit IS NULL) AS null_profit,

    -- Check for invalid Quantity values
    SUM(Quantity <= 0) AS invalid_quantity,

    -- Check for invalid Discount values
    SUM(Discount < 0 OR Discount > 1) AS invalid_discount,

    -- Check for invalid Order/Ship date relationship
    SUM(ship_date_new < order_date_new) AS invalid_date_relationship

FROM superstore_cleaned;

-- next important


ALTER TABLE superstore_cleaned
    DROP COLUMN `Order Date`,
    DROP COLUMN `Ship Date`,
    CHANGE COLUMN order_date_new `Order Date` DATE,
    CHANGE COLUMN ship_date_new `Ship Date` DATE;


DESCRIBE superstore_cleaned;


-- =========================================================
-- STEP 16: SELECT
-- Purpose: Retrieve data from a table.
-- This query only reads data; it does NOT change the database.
-- =========================================================

SELECT *
FROM superstore_cleaned;

-- =========================================================
-- STEP 17: SELECT SPECIFIC COLUMNS
-- Purpose: Retrieve only the required columns from the table.
-- This query only reads data; it does NOT change the database.
-- =========================================================

SELECT
    `Order ID`,
    `Customer Name`,
    Category,
    Sales,
    Profit
FROM superstore_cleaned;


-- =========================================================
-- STEP 18: COLUMN ALIASES USING AS
-- Purpose: Give a temporary, readable name to a column.
-- This query only reads data; it does NOT change the database.
-- =========================================================

SELECT
    `Order ID` AS order_id,
    `Customer Name` AS customer_name,
    Sales AS total_sales,
    Profit AS total_profit
FROM superstore_cleaned;


-- =========================================================
-- STEP 19: DISTINCT
-- Purpose: Return only unique values from a column.
-- This query only reads data; it does NOT change the database.
-- =========================================================

SELECT DISTINCT Category
FROM superstore_cleaned;

-- =========================================================
-- STEP 20: DISTINCT WITH MULTIPLE COLUMNS
-- Purpose: Find unique combinations of Category and Sub-Category.
-- This query only reads data; it does NOT change the database.
-- =========================================================

SELECT DISTINCT
    Category,
    `Sub-Category`
FROM superstore_cleaned
ORDER BY Category, `Sub-Category`;


-- =========================================================
-- STEP 21: ORDER BY
-- Purpose: Sort the result based on a column.
-- This query only reads data; it does NOT change the database.
-- =========================================================

SELECT
    `Product Name`,
    Sales,
    Profit
FROM superstore_cleaned
ORDER BY Sales DESC;

-- =========================================================
-- STEP 22: LIMIT
-- Purpose: Return only a specified number of rows.
-- This query only reads data; it does NOT change the database.
-- =========================================================

SELECT
    `Product Name`,
    Sales,
    Profit
FROM superstore_cleaned
ORDER BY Sales DESC
LIMIT 10;


-- =========================================================
-- STEP 23: WHERE
-- Purpose: Filter rows based on a condition.
-- This query only reads data; it does NOT change the database.
-- =========================================================

SELECT
    `Order ID`,
    `Customer Name`,
    Category,
    Sales,
    Profit
FROM superstore_cleaned
WHERE Category = 'Furniture';



-- =========================================================
-- STEP 24: WHERE WITH NUMERIC CONDITION
-- Purpose: Find rows where Sales is greater than 1000.
-- This query only reads data; it does NOT change the database.
-- =========================================================

SELECT
    `Order ID`,
    `Product Name`,
    Sales,
    Profit
FROM superstore_cleaned
WHERE Sales > 1000;


-- =========================================================
-- STEP 25: AND OPERATOR
-- Purpose: Filter rows that satisfy multiple conditions.
-- This query only reads data; it does NOT change the database.
-- =========================================================

SELECT
    `Order ID`,
    `Product Name`,
    Category,
    Sales,
    Profit
FROM superstore_cleaned
WHERE Category = 'Furniture'
  AND Sales > 1000;
  
  
  
  
  -- =========================================================
-- STEP 26: OR OPERATOR
-- Purpose: Filter rows when at least one condition is true.
-- This query only reads data; it does NOT change the database.
-- =========================================================

SELECT
    `Order ID`,
    `Product Name`,
    Category,
    Sales,
    Profit
FROM superstore_cleaned
WHERE Category = 'Furniture'
   OR Category = 'Technology';
   
   
   
   
   -- =========================================================
-- STEP 27: IN OPERATOR
-- Purpose: Filter a column against multiple possible values.
-- This query only reads data; it does NOT change the database.
-- =========================================================

SELECT
    `Order ID`,
    `Product Name`,
    Category,
    Sales,
    Profit
FROM superstore_cleaned
WHERE Category IN ('Furniture', 'Technology');



-- =========================================================
-- STEP 28: BETWEEN OPERATOR
-- Purpose: Filter records within a specific numeric range.
-- This query only reads data; it does NOT change the database.
-- =========================================================

SELECT
    `Order ID`,
    `Product Name`,
    Sales,
    Profit
FROM superstore_cleaned
WHERE Sales BETWEEN 1000 AND 5000;




-- =========================================================
-- STEP 29: LIKE OPERATOR
-- Purpose: Search text using a pattern.
-- This query only reads data; it does NOT change the database.
-- =========================================================

SELECT
    `Order ID`,
    `Customer Name`,
    `Product Name`,
    Sales,
    Profit
FROM superstore_cleaned
WHERE `Customer Name` LIKE 'A%';



USE superstore_project;


-- STEP 30: IS NULL
-- Purpose: Find missing Sales values.
-- CHECK ONLY: database change nahi hoga.

SELECT
    `Order ID`,
    `Customer Name`,
    Sales,
    Profit
FROM superstore_cleaned
WHERE Sales IS NULL;



-- STEP 31: IS NOT NULL
-- CHECK ONLY: database change nahi hoga.

SELECT
    `Order ID`,
    `Customer Name`,
    Sales,
    Profit
FROM superstore_cleaned
WHERE Sales IS NOT NULL
LIMIT 10;



-- STEP 32: CASE WHEN
-- Purpose: Classify each row based on Profit.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Order ID`,
    `Customer Name`,
    Sales,
    Profit,

    CASE
        WHEN Profit > 0 THEN 'Profitable'
        WHEN Profit < 0 THEN 'Loss'
        ELSE 'Break-even'
    END AS Profit_Status

FROM superstore_cleaned
LIMIT 20;



-- STEP 33: CASE WHEN with Sales
-- Purpose: Classify sales into business-friendly categories.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Order ID`,
    `Product Name`,
    Sales,

    CASE
        WHEN Sales >= 1000 THEN 'High Sales'
        WHEN Sales >= 500 THEN 'Medium Sales'
        ELSE 'Low Sales'
    END AS Sales_Category

FROM superstore_cleaned
LIMIT 20;



-- STEP 34: GROUP BY
-- Purpose: Calculate total Sales and Profit for each Category.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    Category,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit

FROM superstore_cleaned

GROUP BY Category;



-- STEP 35: COUNT with GROUP BY
-- Purpose: Find how many records belong to each Category.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    Category,
    COUNT(*) AS total_records

FROM superstore_cleaned

GROUP BY Category;



-- STEP 36: COUNT DISTINCT
-- Purpose: Find the number of unique orders in each Category.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    Category,
    COUNT(DISTINCT `Order ID`) AS unique_orders

FROM superstore_cleaned

GROUP BY Category;





-- STEP 37: AVG, MAX, MIN
-- Purpose: Find average, highest and lowest Sales for each Category.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    Category,
    AVG(Sales) AS average_sales,
    MAX(Sales) AS highest_sales,
    MIN(Sales) AS lowest_sales

FROM superstore_cleaned

GROUP BY Category;




-- STEP 38: Category-wise Profit Analysis
-- Purpose: Compare total Sales and total Profit by Category.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    Category,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit

FROM superstore_cleaned

GROUP BY Category

ORDER BY total_profit DESC;




-- STEP 39: HAVING
-- Purpose: Filter grouped/aggregated results.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    Category,
    SUM(Sales) AS total_sales

FROM superstore_cleaned

GROUP BY Category

HAVING SUM(Sales) > 700000;





SELECT
    Category,
    Sales
FROM superstore_cleaned
WHERE Sales > 1000;





-- Purpose: Calculate total sales by Category for high-value sales rows,
-- then keep only Categories whose total exceeds 700000.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    Category,
    SUM(Sales) AS total_sales
FROM superstore_cleaned
WHERE Sales > 1000
GROUP BY Category
HAVING SUM(Sales) > 700000
ORDER BY total_sales DESC;




SELECT
    Category,
    SUM(Sales) AS total_sales
FROM superstore_cleaned
WHERE Sales > 1000
GROUP BY Category;




-- Purpose: Filter rows first, then group them,
-- and finally keep categories whose filtered sales exceed 280000.
-- CHECK ONLY: Database mein koi change nahi hoga.

SELECT
    Category,
    SUM(Sales) AS total_sales
FROM superstore_cleaned
WHERE Sales > 1000
GROUP BY Category
HAVING SUM(Sales) > 280000
ORDER BY total_sales DESC;




-- Purpose: Find the 10 rows with the highest Sales.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Order ID`,
    `Product Name`,
    Sales,
    Profit
FROM superstore_cleaned
ORDER BY Sales DESC
LIMIT 10;




-- Purpose: Find the 10 rows with the highest Profit.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Order ID`,
    `Product Name`,
    Sales,
    Profit
FROM superstore_cleaned
ORDER BY Profit DESC
LIMIT 10;




-- Purpose: Find the 10 rows with the lowest Profit.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Order ID`,
    `Product Name`,
    Sales,
    Profit
FROM superstore_cleaned
ORDER BY Profit ASC
LIMIT 10;



-- Region-wise Business Analysis.


-- STEP 20: REGION-WISE SALES AND PROFIT
-- Purpose: Compare Sales and Profit across different Regions.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    Region,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM superstore_cleaned
GROUP BY Region
ORDER BY total_sales DESC;




-- STEP 21: STATE-WISE SALES AND PROFIT
-- Purpose: Compare Sales and Profit across different States.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    State,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM superstore_cleaned
GROUP BY State
ORDER BY total_sales DESC;





-- STEP 22: SEGMENT-WISE SALES AND PROFIT
-- Purpose: Compare Sales and Profit across customer segments.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    Segment,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM superstore_cleaned
GROUP BY Segment
ORDER BY total_sales DESC;






-- Purpose: Compare Sales and Profit across different Ship Modes.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Ship Mode`,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM superstore_cleaned
GROUP BY `Ship Mode`
ORDER BY total_sales DESC;




-- STEP 24: CATEGORY / SUB-CATEGORY ANALYSIS
-- Purpose: Compare Sales and Profit across Sub-Categories.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    Category,
    `Sub-Category`,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM superstore_cleaned
GROUP BY Category, `Sub-Category`
ORDER BY total_sales DESC;





-- STEP 24: SUB-CATEGORY RECORD COUNT
-- Purpose: Find how many records belong to each Sub-Category.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    Category,
    `Sub-Category`,
    COUNT(*) AS total_records
FROM superstore_cleaned
GROUP BY Category, `Sub-Category`
ORDER BY total_records DESC;





-- STEP 25: CUSTOMER-WISE SALES AND PROFIT
-- Purpose: Compare Sales and Profit across customers.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Customer ID`,
    `Customer Name`,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM superstore_cleaned
GROUP BY `Customer ID`, `Customer Name`
ORDER BY total_sales DESC;




-- STEP 25: TOP 10 CUSTOMERS BY SALES
-- Purpose: Find the 10 customers generating the highest Sales.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Customer ID`,
    `Customer Name`,
    SUM(Sales) AS total_sales
FROM superstore_cleaned
GROUP BY `Customer ID`, `Customer Name`
ORDER BY total_sales DESC
LIMIT 10;






-- STEP 25: TOP 10 CUSTOMERS BY PROFIT
-- Purpose: Find the 10 customers generating the highest Profit.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Customer ID`,
    `Customer Name`,
    SUM(Profit) AS total_profit
FROM superstore_cleaned
GROUP BY `Customer ID`, `Customer Name`
ORDER BY total_profit DESC
LIMIT 10;




-- STEP 26: PRODUCT-WISE SALES AND PROFIT
-- Purpose: Compare Sales and Profit across different products.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Product ID`,
    `Product Name`,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM superstore_cleaned
GROUP BY `Product ID`, `Product Name`
ORDER BY total_sales DESC
LIMIT 20;






-- STEP 26: LOWEST-PROFIT PRODUCTS
-- Purpose: Find products generating the lowest Profit.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Product ID`,
    `Product Name`,
    SUM(Profit) AS total_profit
FROM superstore_cleaned
GROUP BY `Product ID`, `Product Name`
ORDER BY total_profit ASC
LIMIT 10;





-- STEP 27: SUBQUERY
-- Purpose: Find sales records above the overall average Sales.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Order ID`,
    `Product Name`,
    Sales,
    Profit
FROM superstore_cleaned
WHERE Sales > (
    SELECT AVG(Sales)
    FROM superstore_cleaned
)
ORDER BY Sales DESC
LIMIT 20;








-- STEP 27B: CUSTOMERS ABOVE AVERAGE SALES
-- Purpose: Find customers whose total Sales are above the average customer Sales.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Customer ID`,
    `Customer Name`,
    SUM(Sales) AS total_sales
FROM superstore_cleaned
GROUP BY `Customer ID`, `Customer Name`
HAVING SUM(Sales) > (
    SELECT AVG(customer_sales)
    FROM (
        SELECT
            `Customer ID`,
            SUM(Sales) AS customer_sales
        FROM superstore_cleaned
        GROUP BY `Customer ID`
    ) AS customer_summary
)
ORDER BY total_sales DESC;




-- STEP 28: CTE
-- Purpose: Use a CTE to calculate customer-wise Sales and identify top customers.
-- CHECK ONLY: This query does NOT change the database.

WITH customer_sales AS (
    SELECT
        `Customer ID`,
        `Customer Name`,
        SUM(Sales) AS total_sales
    FROM superstore_cleaned
    GROUP BY `Customer ID`, `Customer Name`
)

SELECT
    `Customer ID`,
    `Customer Name`,
    total_sales
FROM customer_sales
ORDER BY total_sales DESC
LIMIT 10;





-- STEP 29: WINDOW FUNCTION - CUSTOMER SALES RANK
-- Purpose: Rank customers based on their total Sales.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Customer ID`,
    `Customer Name`,
    SUM(Sales) AS total_sales,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS sales_rank
FROM superstore_cleaned
GROUP BY `Customer ID`, `Customer Name`
ORDER BY sales_rank
LIMIT 20;






-- STEP 29B: WINDOW FUNCTION - ROW NUMBER
-- Purpose: Assign a unique row number to customers based on Sales.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Customer ID`,
    `Customer Name`,
    SUM(Sales) AS total_sales,
    ROW_NUMBER() OVER (ORDER BY SUM(Sales) DESC) AS sales_row_number
FROM superstore_cleaned
GROUP BY `Customer ID`, `Customer Name`
ORDER BY sales_row_number
LIMIT 20;




-- STEP 30: PROFIT MARGIN ANALYSIS
-- Purpose: Calculate overall Sales, Profit and Profit Margin.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS profit_margin_pct
FROM superstore_cleaned;



-- STEP 30: YEAR-WISE SALES AND PROFIT
-- Purpose: Compare Sales and Profit across different years.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%y')) AS order_year,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM superstore_cleaned
GROUP BY order_year
ORDER BY order_year;





-- STEP 30A: CHECK ACTUAL ORDER DATE FORMAT
-- Purpose: Check how Order Date is actually stored.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    `Order Date`,
    LENGTH(`Order Date`) AS date_length
FROM superstore_cleaned
LIMIT 10;




-- STEP 30: YEAR-WISE SALES AND PROFIT
-- Purpose: Compare Sales and Profit across different years.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    YEAR(STR_TO_DATE(`Order Date`, '%Y-%m-%d')) AS order_year,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM superstore_cleaned
GROUP BY order_year
ORDER BY order_year;




-- FINAL SQL CHECK: DATA QUALITY VALIDATION
-- Purpose: Final check before moving to Power BI.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT `Row ID`) AS unique_row_ids,
    SUM(`Sales` IS NULL) AS null_sales,
    SUM(`Profit` IS NULL) AS null_profit,
    SUM(`Quantity` <= 0) AS invalid_quantity,
    SUM(`Discount` < 0 OR `Discount` > 1) AS invalid_discount
FROM superstore_cleaned;




-- FINAL DATE VALIDATION
-- Purpose: Confirm Ship Date is never before Order Date.
-- CHECK ONLY: This query does NOT change the database.

SELECT
    COUNT(*) AS total_rows,
    SUM(
        STR_TO_DATE(`Ship Date`, '%Y-%m-%d')
        < STR_TO_DATE(`Order Date`, '%Y-%m-%d')
    ) AS invalid_ship_dates
FROM superstore_cleaned;

