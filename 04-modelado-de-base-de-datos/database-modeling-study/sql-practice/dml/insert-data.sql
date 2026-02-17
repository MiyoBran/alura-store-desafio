-- INSERT DATA - DML Practice
-- Data Manipulation Language: Adding data to tables

-- ============================================
-- BASIC INSERT
-- ============================================

-- Insert single row with all columns
INSERT INTO customers (customer_id, first_name, last_name, email, created_at)
VALUES (1, 'John', 'Doe', 'john.doe@email.com', '2026-02-15 10:30:00');

-- Insert without specifying all columns (using defaults/auto-increment)
INSERT INTO customers (first_name, last_name, email)
VALUES ('Jane', 'Smith', 'jane.smith@email.com');

-- ============================================
-- MULTIPLE ROW INSERT
-- ============================================

-- Insert multiple rows in one statement (more efficient!)
INSERT INTO products (product_name, description, price, stock_quantity)
VALUES 
    ('Laptop', 'High-performance laptop', 1299.99, 15),
    ('Mouse', 'Wireless mouse', 29.99, 50),
    ('Keyboard', 'Mechanical keyboard', 89.99, 30),
    ('Monitor', '27-inch 4K monitor', 399.99, 20),
    ('Headphones', 'Noise-cancelling headphones', 199.99, 25);

-- ============================================
-- INSERT WITH SELECT (Copy data from another table)
-- ============================================

-- Create a backup table
CREATE TABLE customers_backup AS SELECT * FROM customers WHERE 1=0;  -- Create empty table

-- Copy specific customers
INSERT INTO customers_backup
SELECT * FROM customers
WHERE created_at >= '2026-01-01';

-- Copy with transformation
INSERT INTO product_price_history (product_id, old_price, new_price, change_date)
SELECT 
    product_id,
    price AS old_price,
    price * 1.1 AS new_price,  -- 10% increase
    CURRENT_TIMESTAMP
FROM products
WHERE price < 100;

-- ============================================
-- INSERT DEFAULT VALUES
-- ============================================

-- Insert with explicit DEFAULT keyword
INSERT INTO users (username, email, password_hash, is_active)
VALUES ('newuser', 'new@email.com', 'hashed_password', DEFAULT);

-- ============================================
-- INSERT IGNORE (MySQL) - Skip duplicates
-- ============================================

-- Skip rows that would cause duplicate key errors
INSERT IGNORE INTO users (username, email, password_hash)
VALUES 
    ('john_doe', 'john@email.com', 'hash1'),
    ('jane_doe', 'jane@email.com', 'hash2');

-- ============================================
-- ON DUPLICATE KEY UPDATE (MySQL)
-- ============================================

-- Update if duplicate key exists, insert otherwise
INSERT INTO products (product_id, product_name, price, stock_quantity)
VALUES (1, 'Updated Laptop', 1199.99, 20)
ON DUPLICATE KEY UPDATE 
    price = VALUES(price),
    stock_quantity = stock_quantity + VALUES(stock_quantity);

-- ============================================
-- UPSERT (PostgreSQL) - INSERT ... ON CONFLICT
-- ============================================

-- PostgreSQL syntax for upsert
-- INSERT INTO products (product_id, product_name, price)
-- VALUES (1, 'Laptop', 1299.99)
-- ON CONFLICT (product_id) 
-- DO UPDATE SET price = EXCLUDED.price;

-- ============================================
-- INSERT INTO FOREIGN KEY RELATED TABLES
-- ============================================

-- First insert parent record
INSERT INTO customers (first_name, last_name, email)
VALUES ('Alice', 'Johnson', 'alice@email.com');

-- Get the auto-generated ID (MySQL)
SET @customer_id = LAST_INSERT_ID();

-- Insert related records
INSERT INTO orders (customer_id, order_date, total_amount, status)
VALUES (@customer_id, '2026-02-17', 199.99, 'pending');

-- Or in a transaction to ensure data integrity
START TRANSACTION;

INSERT INTO customers (first_name, last_name, email)
VALUES ('Bob', 'Wilson', 'bob@email.com');

SET @new_customer = LAST_INSERT_ID();

INSERT INTO addresses (customer_id, street_address, city, state, postal_code, is_default)
VALUES (@new_customer, '123 Main St', 'New York', 'NY', '10001', TRUE);

COMMIT;

-- ============================================
-- INSERT WITH SUBQUERY
-- ============================================

-- Insert based on query results
INSERT INTO high_value_customers (customer_id, total_spent)
SELECT customer_id, SUM(total_amount)
FROM orders
WHERE status = 'completed'
GROUP BY customer_id
HAVING SUM(total_amount) > 1000;

-- ============================================
-- INSERT INTO JUNCTION TABLES (Many-to-Many)
-- ============================================

-- Assuming we have order_id = 1 and products
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES 
    (1, 1, 2, 1299.99),  -- 2 Laptops
    (1, 2, 1, 29.99),    -- 1 Mouse
    (1, 3, 1, 89.99);    -- 1 Keyboard

-- Book authors (many-to-many)
INSERT INTO book_authors (book_id, author_id, author_order)
VALUES 
    (1, 1, 1),  -- First author
    (1, 2, 2);  -- Second author (co-author)

-- ============================================
-- PRACTICAL EXAMPLES
-- ============================================

-- Complete order creation example
START TRANSACTION;

-- 1. Create customer (if new)
INSERT INTO customers (first_name, last_name, email, phone)
VALUES ('Sarah', 'Connor', 'sarah.connor@email.com', '555-0123');

SET @customer_id = LAST_INSERT_ID();

-- 2. Create order
INSERT INTO orders (customer_id, order_date, status)
VALUES (@customer_id, CURRENT_DATE, 'pending');

SET @order_id = LAST_INSERT_ID();

-- 3. Add order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT @order_id, product_id, 1, price
FROM products
WHERE product_id IN (1, 3, 5);

-- 4. Update order total
UPDATE orders 
SET total_amount = (
    SELECT SUM(quantity * unit_price)
    FROM order_items
    WHERE order_id = @order_id
)
WHERE order_id = @order_id;

-- 5. Update product stock
UPDATE products p
JOIN order_items oi ON p.product_id = oi.product_id
SET p.stock_quantity = p.stock_quantity - oi.quantity
WHERE oi.order_id = @order_id;

COMMIT;

-- ============================================
-- INSERT WITH GENERATED/COMPUTED VALUES
-- ============================================

-- Using functions
INSERT INTO orders (customer_id, order_date, total_amount)
VALUES 
    (1, CURRENT_DATE, 0),
    (2, DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY), 0);

-- Using expressions
INSERT INTO products (product_name, price, stock_quantity, total_value)
VALUES ('USB Cable', 9.99, 100, 9.99 * 100);

-- ============================================
-- BULK INSERT FROM CSV (for reference)
-- ============================================

-- MySQL
-- LOAD DATA INFILE '/path/to/customers.csv'
-- INTO TABLE customers
-- FIELDS TERMINATED BY ','
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (first_name, last_name, email, phone);

-- PostgreSQL
-- COPY customers(first_name, last_name, email, phone)
-- FROM '/path/to/customers.csv'
-- DELIMITER ','
-- CSV HEADER;

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

-- Exercise 1: Insert 5 new products with varying prices
-- YOUR CODE HERE:



-- Exercise 2: Create a complete order with multiple items
-- Use a transaction and include all related tables
-- YOUR CODE HERE:



-- Exercise 3: Insert student enrollments (many-to-many)
-- Assuming students and courses tables exist
-- YOUR CODE HERE:



-- Exercise 4: Copy active users to an archive table
-- YOUR CODE HERE:



-- Exercise 5: Insert product reviews for existing orders
-- Ensure customers can only review products they've bought
-- YOUR CODE HERE:



-- ============================================
-- COMMON MISTAKES TO AVOID
-- ============================================

-- ❌ DON'T: Insert without checking foreign key exists
-- INSERT INTO orders (customer_id, order_date) VALUES (9999, CURRENT_DATE);

-- ✅ DO: Verify parent record exists first
-- SELECT customer_id FROM customers WHERE customer_id = 1;
-- Then insert if exists

-- ❌ DON'T: Insert duplicate unique values
-- INSERT INTO users (username, email) VALUES ('john', 'john@email.com');
-- INSERT INTO users (username, email) VALUES ('john', 'other@email.com'); -- Error!

-- ✅ DO: Use INSERT IGNORE or ON DUPLICATE KEY UPDATE

-- ❌ DON'T: Forget required NOT NULL columns
-- INSERT INTO products (product_name) VALUES ('Test'); -- Error if price is NOT NULL

-- ✅ DO: Provide all required columns or defaults

-- ============================================
-- NOTES
-- ============================================

/*
KEY POINTS:

1. Always specify column names in INSERT statements for clarity
2. Use multi-row INSERT for better performance
3. Use transactions for related inserts to maintain consistency
4. Check foreign key constraints before inserting
5. Use LAST_INSERT_ID() (MySQL) or RETURNING (PostgreSQL) to get auto-generated IDs
6. Validate data before inserting
7. Use appropriate data types and conversions
8. Handle duplicates with IGNORE or ON DUPLICATE KEY UPDATE

PERFORMANCE TIPS:
- Batch inserts when possible (multiple VALUES)
- Use LOAD DATA / COPY for bulk imports
- Disable indexes temporarily for large imports
- Use transactions to reduce commit overhead
- Consider using prepared statements for repeated inserts

SECURITY:
- Always use parameterized queries to prevent SQL injection
- Validate and sanitize input data
- Use appropriate user permissions
*/
