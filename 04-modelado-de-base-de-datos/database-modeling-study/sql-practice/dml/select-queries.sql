-- SELECT QUERIES - DML Practice
-- Data Manipulation Language: Retrieving data

-- ============================================
-- BASIC SELECT
-- ============================================

-- Select all columns
SELECT * FROM customers;

-- Select specific columns
SELECT first_name, last_name, email 
FROM customers;

-- Select with alias
SELECT 
    first_name AS "First Name",
    last_name AS "Last Name",
    email AS "Email Address"
FROM customers;

-- ============================================
-- WHERE CLAUSE - Filtering
-- ============================================

-- Simple condition
SELECT * FROM products
WHERE price > 100;

-- Multiple conditions (AND)
SELECT * FROM products
WHERE price > 50 AND stock_quantity > 0;

-- Multiple conditions (OR)
SELECT * FROM products
WHERE price < 20 OR stock_quantity > 100;

-- Combined conditions
SELECT * FROM products
WHERE (price > 50 AND price < 200) 
   OR stock_quantity > 100;

-- ============================================
-- COMPARISON OPERATORS
-- ============================================

-- Equal to
SELECT * FROM orders WHERE status = 'completed';

-- Not equal to
SELECT * FROM orders WHERE status != 'cancelled';
SELECT * FROM orders WHERE status <> 'cancelled';  -- Alternative

-- Greater than, less than
SELECT * FROM products WHERE price >= 100;
SELECT * FROM products WHERE stock_quantity < 10;

-- BETWEEN
SELECT * FROM orders 
WHERE order_date BETWEEN '2026-01-01' AND '2026-01-31';

-- IN
SELECT * FROM orders 
WHERE status IN ('pending', 'processing', 'shipped');

-- NOT IN
SELECT * FROM products
WHERE product_id NOT IN (1, 5, 10);

-- IS NULL / IS NOT NULL
SELECT * FROM customers WHERE email IS NULL;
SELECT * FROM customers WHERE email IS NOT NULL;

-- ============================================
-- PATTERN MATCHING - LIKE
-- ============================================

-- Starts with
SELECT * FROM customers 
WHERE last_name LIKE 'Smith%';

-- Ends with
SELECT * FROM customers 
WHERE email LIKE '%@gmail.com';

-- Contains
SELECT * FROM products 
WHERE product_name LIKE '%laptop%';

-- Single character wildcard (_)
SELECT * FROM products 
WHERE product_name LIKE 'MacBook _ro';

-- NOT LIKE
SELECT * FROM customers 
WHERE email NOT LIKE '%@test.com';

-- ============================================
-- SORTING - ORDER BY
-- ============================================

-- Ascending order (default)
SELECT * FROM products 
ORDER BY price;

SELECT * FROM products 
ORDER BY price ASC;  -- Explicit

-- Descending order
SELECT * FROM products 
ORDER BY price DESC;

-- Multiple columns
SELECT * FROM products 
ORDER BY stock_quantity DESC, price ASC;

-- Order by computed column
SELECT 
    product_name,
    price,
    stock_quantity,
    (price * stock_quantity) AS total_value
FROM products
ORDER BY total_value DESC;

-- ============================================
-- LIMITING RESULTS
-- ============================================

-- LIMIT (MySQL, PostgreSQL)
SELECT * FROM products 
ORDER BY price DESC 
LIMIT 10;

-- TOP (SQL Server)
-- SELECT TOP 10 * FROM products ORDER BY price DESC;

-- Pagination (OFFSET and LIMIT)
SELECT * FROM products 
ORDER BY product_id
LIMIT 10 OFFSET 20;  -- Skip first 20, get next 10

-- ============================================
-- DISTINCT - Remove Duplicates
-- ============================================

SELECT DISTINCT city FROM customers;

SELECT DISTINCT status FROM orders;

-- Count distinct values
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM orders;

-- ============================================
-- AGGREGATE FUNCTIONS
-- ============================================

-- COUNT
SELECT COUNT(*) AS total_products FROM products;
SELECT COUNT(product_id) AS product_count FROM products;

-- SUM
SELECT SUM(total_amount) AS total_sales FROM orders;

-- AVG
SELECT AVG(price) AS average_price FROM products;

-- MIN and MAX
SELECT MIN(price) AS cheapest, MAX(price) AS most_expensive 
FROM products;

-- Multiple aggregates
SELECT 
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS average_order_value,
    MIN(total_amount) AS smallest_order,
    MAX(total_amount) AS largest_order
FROM orders;

-- ============================================
-- GROUP BY
-- ============================================

-- Group by single column
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status;

-- Group by multiple columns
SELECT status, YEAR(order_date) AS year, COUNT(*) AS order_count
FROM orders
GROUP BY status, YEAR(order_date);

-- With aggregate functions
SELECT 
    customer_id,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id;

-- ============================================
-- HAVING - Filter Groups
-- ============================================

-- Find customers with more than 5 orders
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 5;

-- Find products with average rating > 4
SELECT product_id, AVG(rating) AS avg_rating
FROM reviews
GROUP BY product_id
HAVING AVG(rating) > 4;

-- Combining WHERE and HAVING
SELECT 
    customer_id,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_spent
FROM orders
WHERE status = 'completed'
GROUP BY customer_id
HAVING SUM(total_amount) > 1000;

-- ============================================
-- CALCULATED COLUMNS
-- ============================================

-- Arithmetic operations
SELECT 
    product_name,
    price,
    price * 0.9 AS sale_price,
    price * 0.1 AS discount_amount
FROM products;

-- String concatenation
SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name,
    email
FROM customers;

-- Date calculations
SELECT 
    order_date,
    DATE_ADD(order_date, INTERVAL 7 DAY) AS estimated_delivery
FROM orders;

-- ============================================
-- CASE STATEMENTS
-- ============================================

-- Simple CASE
SELECT 
    product_name,
    stock_quantity,
    CASE 
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        WHEN stock_quantity < 10 THEN 'Low Stock'
        WHEN stock_quantity < 50 THEN 'In Stock'
        ELSE 'Well Stocked'
    END AS stock_status
FROM products;

-- CASE with aggregations
SELECT 
    status,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN total_amount > 100 THEN 1 ELSE 0 END) AS high_value_orders
FROM orders
GROUP BY status;

-- ============================================
-- SUBQUERIES
-- ============================================

-- IN subquery
SELECT * FROM products
WHERE product_id IN (
    SELECT DISTINCT product_id 
    FROM order_items
);

-- Scalar subquery
SELECT * FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- Correlated subquery
SELECT p.product_name, p.price
FROM products p
WHERE p.price > (
    SELECT AVG(price) 
    FROM products 
    WHERE stock_quantity > 0
);

-- ============================================
-- DATE AND TIME FUNCTIONS
-- ============================================

-- Current date/time
SELECT CURRENT_DATE, CURRENT_TIME, CURRENT_TIMESTAMP;

-- Extract parts
SELECT 
    order_date,
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    DAY(order_date) AS day
FROM orders;

-- Format dates
SELECT 
    order_date,
    DATE_FORMAT(order_date, '%Y-%m-%d') AS formatted_date
FROM orders;

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

-- Exercise 1: Find all products priced between 50 and 100
-- YOUR CODE HERE:



-- Exercise 2: Get the top 5 customers by total spending
-- YOUR CODE HERE:



-- Exercise 3: Count orders by status for each month
-- YOUR CODE HERE:



-- Exercise 4: Find products that have never been ordered
-- YOUR CODE HERE:



-- Exercise 5: Get average rating for each product with at least 5 reviews
-- YOUR CODE HERE:



-- ============================================
-- NOTES
-- ============================================

/*
QUERY EXECUTION ORDER:
1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
6. ORDER BY
7. LIMIT

REMEMBER:
- WHERE filters rows before grouping
- HAVING filters groups after aggregation
- Use DISTINCT to remove duplicates
- Aliases can't be used in WHERE (but can in ORDER BY)
- LIMIT syntax varies by database system

PERFORMANCE TIPS:
- Use indexes on frequently filtered columns
- Avoid SELECT * in production
- Use EXPLAIN to analyze query performance
- Filter as early as possible (WHERE vs HAVING)
*/
