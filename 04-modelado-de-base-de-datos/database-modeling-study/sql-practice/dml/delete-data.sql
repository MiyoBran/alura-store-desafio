-- DELETE DATA - DML Practice
-- Removing records from database tables

-- ============================================
-- BASIC DELETE SYNTAX
-- ============================================

-- Delete specific row
DELETE FROM customers
WHERE customer_id = 100;

-- Delete multiple rows with single condition
DELETE FROM products
WHERE stock_quantity = 0;

-- Delete all rows  (BE EXTREMELY CAREFUL!)
DELETE FROM temp_table;

-- More efficient way to delete all rows
TRUNCATE TABLE temp_table;

-- ============================================
-- DELETE WITH WHERE CLAUSE
-- ============================================

-- Single condition
DELETE FROM orders
WHERE status = 'cancelled';

-- Multiple conditions (AND)
DELETE FROM products
WHERE discontinued = TRUE
  AND stock_quantity = 0
  AND last_updated < '2020-01-01';

-- Multiple conditions (OR)
DELETE FROM sessions
WHERE expires_at < NOW()
   OR is_active = FALSE;

-- Using IN clause
DELETE FROM notifications
WHERE user_id IN (101, 102, 103);

-- Using NOT IN
DELETE FROM products
WHERE category_id NOT IN (1, 2, 3, 4);

-- Using BETWEEN
DELETE FROM logs
WHERE created_at BETWEEN '2023-01-01' AND '2023-12-31';

-- Using LIKE
DELETE FROM customers
WHERE email LIKE '%@spam-domain.com';

-- Using IS NULL
DELETE FROM customers
WHERE email IS NULL
  AND phone IS NULL
  AND last_login IS NULL;

-- Using comparison operators
DELETE FROM products
WHERE price < 0.01;  -- Remove invalid prices

DELETE FROM orders
WHERE order_date < DATE_SUB(NOW(), INTERVAL 5 YEAR);

-- ============================================
-- DELETE WITH SUBQUERIES
-- ============================================

-- Delete based on subquery
DELETE FROM order_items
WHERE order_id IN (
    SELECT order_id
    FROM orders
    WHERE status = 'cancelled'
);

-- Delete orphaned records
DELETE FROM order_items
WHERE product_id NOT IN (
    SELECT product_id
    FROM products
);

-- Delete using EXISTS
DELETE FROM products
WHERE NOT EXISTS (
    SELECT 1
    FROM categories
    WHERE categories.category_id = products.category_id
);

-- Delete based on aggregate condition
DELETE FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM (
        SELECT customer_id, COUNT(*) as order_count
        FROM orders
        GROUP BY customer_id
        HAVING order_count = 0
    ) AS inactive_customers
)
AND created_at < DATE_SUB(NOW(), INTERVAL 2 YEAR);

-- Delete duplicates, keep one
DELETE t1 FROM customers t1
INNER JOIN customers t2
WHERE t1.customer_id > t2.customer_id
  AND t1.email = t2.email;

-- ============================================
-- DELETE WITH JOIN (MySQL)
-- ============================================

-- Delete using INNER JOIN
DELETE p
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
WHERE c.is_active = FALSE;

-- Delete from multiple tables
DELETE o, oi
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'cancelled'
  AND o.created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- Delete using LEFT JOIN (orphaned records)
DELETE p
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
WHERE c.category_id IS NULL;

-- Complex join delete
DELETE c
FROM cart_items c
INNER JOIN customers cust ON c.customer_id = cust.customer_id
LEFT JOIN orders o ON cust.customer_id = o.customer_id
WHERE o.order_id IS NULL
  AND c.created_at < DATE_SUB(NOW(), INTERVAL 6 MONTH);

-- ============================================
-- CASCADE DELETES
-- ============================================

-- When foreign key has ON DELETE CASCADE, child records are auto-deleted

-- Example schema:
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE  -- Child items deleted automatically
);

-- Deleting parent record:
DELETE FROM orders WHERE order_id = 100;
-- This will automatically delete all order_items with order_id = 100

-- ============================================
-- Different ON DELETE behaviors:
-- ============================================

-- CASCADE: Delete child records automatically
-- Example above

-- RESTRICT: Prevent delete if children exist
CREATE TABLE products (
    product_id INT PRIMARY KEY
);

CREATE TABLE order_items2 (
    item_id INT PRIMARY KEY,
    product_id INT,
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT  -- Cannot delete product if ordered
);

-- SET NULL: Set foreign key to NULL
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    manager_id INT,
    FOREIGN KEY (manager_id)
        REFERENCES employees(employee_id)
        ON DELETE SET NULL  -- Set manager_id to NULL when manager deleted
);

-- NO ACTION: Similar to RESTRICT
CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    product_id INT,
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE NO ACTION
);

-- ============================================
-- SOFT DELETE PATTERN
-- ============================================

-- Instead of deleting, mark as deleted
ALTER TABLE users ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP NULL;

-- "Delete" user (soft delete)
UPDATE users
SET is_deleted = TRUE,
    deleted_at = NOW()
WHERE user_id = 123;

-- Query active users
SELECT * FROM users WHERE is_deleted = FALSE;

-- Restore deleted user
UPDATE users
SET is_deleted = FALSE,
    deleted_at = NULL
WHERE user_id = 123;

-- Permanently delete after grace period
DELETE FROM users
WHERE is_deleted = TRUE
  AND deleted_at < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- ============================================
-- BATCH DELETES
-- ============================================

-- Delete in batches with LIMIT
DELETE FROM logs
WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY)
LIMIT 1000;

-- Repeat until all are deleted
-- Can be done in a loop or scheduled job

-- Delete with ORDER BY and LIMIT
DELETE FROM sessions
ORDER BY last_activity ASC
LIMIT 500;

-- Batch delete pattern for large tables
DELIMITER //
CREATE PROCEDURE batch_delete_old_logs()
BEGIN
    DECLARE rows_deleted INT DEFAULT 1;
    WHILE rows_deleted > 0 DO
        DELETE FROM logs
        WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY)
        LIMIT 1000;
        
        SET rows_deleted = ROW_COUNT();
        
        -- Small delay to avoid overwhelming database
        DO SLEEP(0.1);
    END WHILE;
END //
DELIMITER ;

-- ============================================
-- SAFE DELETE PRACTICES
-- ============================================

-- 1. ALWAYS test with SELECT first
SELECT * FROM orders WHERE status = 'cancelled';

-- 2. Then run DELETE
DELETE FROM orders WHERE status = 'cancelled';

-- 3. Use transactions for critical deletes
START TRANSACTION;

DELETE FROM order_items WHERE order_id = 100;
DELETE FROM orders WHERE order_id = 100;

-- Verify
SELECT * FROM orders WHERE order_id = 100;
SELECT * FROM order_items WHERE order_id = 100;

-- If correct:
COMMIT;
-- If wrong:
-- ROLLBACK;

-- 4. Create backup before mass delete
CREATE TABLE products_backup AS SELECT * FROM products;

DELETE FROM products WHERE discontinued = TRUE;

-- If problems, restore:
-- INSERT INTO products SELECT * FROM products_backup;

-- 5. Count rows before delete
SELECT COUNT(*) FROM logs WHERE created_at < '2023-01-01';
-- Expected: 1523

DELETE FROM logs WHERE created_at < '2023-01-01';
-- Affected rows: 1523 ✓

-- ============================================
-- TRUNCATE VS DELETE
-- ============================================

-- DELETE: Removes rows one by one, fires triggers, can be rolled back
DELETE FROM table_name;

-- TRUNCATE: Fast, resets auto-increment, cannot be rolled back
TRUNCATE TABLE table_name;

/*
DELETE vs TRUNCATE comparison:

DELETE:
- Can use WHERE clause
- Slower for large tables
- Can be rolled back (in transaction)
-Fires DELETE triggers
- Doesn't reset AUTO_INCREMENT
- Logs each row deletion

TRUNCATE:
- No WHERE clause (all rows deleted)
- Very fast, even for large tables
- Cannot be rolled back (DDL operation)
- Does NOT fire triggers
- Resets AUTO_INCREMENT to 1
- Minimal logging

When to use:
- DELETE: When you need WHERE clause or want to keep auto-increment counter
- TRUNCATE: When clearing entire table and want to reset counters
*/

-- ============================================
-- COMMON DELETE PATTERNS
-- ============================================

-- Pattern 1: Delete old records
DELETE FROM logs
WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- Pattern 2: Delete test data
DELETE FROM customers WHERE email LIKE '%@test.com';

-- Pattern 3: Delete orphaned records
DELETE FROM order_items
WHERE product_id NOT IN (SELECT product_id FROM products);

-- Pattern 4: Delete duplicates
DELETE t1 FROM emails t1
INNER JOIN emails t2
WHERE t1.id > t2.id
  AND t1.email_address = t2.email_address;

-- Pattern 5: Delete based on related table
DELETE FROM shopping_carts
WHERE customer_id IN (
    SELECT customer_id
    FROM customers
    WHERE is_deleted = TRUE
);

-- Pattern 6: Archive then delete
INSERT INTO orders_archive
SELECT * FROM orders
WHERE order_date < DATE_SUB(NOW(), INTERVAL 2 YEAR);

DELETE FROM orders
WHERE order_date < DATE_SUB(NOW(), INTERVAL 2 YEAR);

-- Pattern 7: Cascading manual delete
-- Delete in correct order to respect foreign keys
DELETE FROM order_items WHERE order_id = 100;
DELETE FROM order_transactions WHERE order_id = 100;
DELETE FROM order_shipments WHERE order_id = 100;
DELETE FROM orders WHERE order_id = 100;

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

-- Exercise 1: Basic Delete
-- Delete all products that are discontinued AND have zero stock
-- YOUR CODE HERE:



-- Exercise 2: Delete with Subquery
-- Delete all orders from customers who haven't logged in for 2+ years
-- YOUR CODE HERE:



-- Exercise 3: Delete Orphaned Records
-- Delete all order_items where the referenced product_id doesn't exist
-- in the products table
-- YOUR CODE HERE:



-- Exercise 4: Delete Duplicates
-- Delete duplicate customer records based on email, keeping the oldest one
-- YOUR CODE HERE:



-- Exercise 5: Archive and Delete
-- Move orders older than 3 years to orders_archive table, then delete them
-- YOUR CODE HERE:



-- Exercise 6: Implement Soft Delete
-- Add necessary columns to users table and implement soft delete
-- for user_id = 50
-- YOUR CODE HERE:



-- Exercise 7: Batch Delete
-- Delete logs in batches of 1000, where created_at < 90 days ago
-- YOUR CODE HERE:



-- ============================================
-- NOTES
-- ============================================

/*
CRITICAL SAFETY RULES:

1. ALWAYS use WHERE clause
   - Without WHERE, ALL rows are deleted!
   - No undo button in production!

2. Test with SELECT first
   SELECT * FROM table WHERE condition;
   -- Verify these are the rows you want to delete
   DELETE FROM table WHERE condition;

3. Use transactions for important deletes
   START TRANSACTION;
   DELETE ...
   -- Check
   COMMIT; or ROLLBACK;

4. Backup before mass deletes
   - Export data or create backup table
   - Production rule: backup before delete

5. Be aware of foreign keys
   - Check ON DELETE behavior
   - Delete in correct order

COMMON MISTAKES:

1. Forgetting WHERE clause → Deletes everything
2. Not checking foreign key constraints
3. Deleting parent before children  (if no CASCADE)
4. Not using transaction on critical deletes
5. Truncating instead of deleting when WHERE is needed

TROUBLESHOOTING:

1. Cannot delete due to foreign key:
   - Delete children first
   - Or temporarily disable foreign key checks:
     SET FOREIGN_KEY_CHECKS = 0;
     -- Delete
     SET FOREIGN_KEY_CHECKS = 1;
   - Use with extreme caution!

2. Delete taking too long:
   - Delete in smaller batches
   - Add indexes on WHERE clause columns
   - Delete during off-peak hours

3. Safe mode error:
   SET SQL_SAFE_UPDATES = 0;
   -- Delete
   SET SQL_SAFE_UPDATES = 1;

PERFORMANCE TIPS:

1. Delete in batches for large datasets
2. Add indexes on columns used in WHERE
3. Use TRUNCATE for emptying entire table
4. Consider partitioning for time-series data
5. Archive old data instead of deleting

RECOVERY:

If you accidentally deleted data:

1. ROLLBACK if in transaction:
   ROLLBACK;

2. Restore from backup:
   -- If backup exists
   RESTORE DATABASE ...

3. Use binary log (MySQL):
   -- Extract deleted data from binlog
   mysqlbinlog ...

4. Replica/slave database:
   -- If replication lag, stop before delete propagates
   -- Copy data from replica

PREVENTION > CURE:
- Always backup
- Test on copy first
- Use soft deletes for user data
- Require review for mass deletes
- Practice with test database
*/
