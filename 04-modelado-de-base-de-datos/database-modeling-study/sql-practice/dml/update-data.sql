-- UPDATE DATA - DML Practice
-- Modifying existing records in database tables

-- ============================================
-- BASIC UPDATE SYNTAX
-- ============================================

-- Update single column
UPDATE customers
SET email = 'newemail@example.com'
WHERE customer_id = 1;

-- Update multiple columns
UPDATE products
SET price = 29.99,
    stock_quantity = 100,
    updated_at = NOW()
WHERE product_id = 5;

-- Update all rows (BE CAREFUL!)
UPDATE products
SET is_active = TRUE;

-- ============================================
-- UPDATE WITH WHERE CLAUSE
-- ============================================

-- Update based on single condition
UPDATE orders
SET status = 'shipped'
WHERE order_id = 1001;

-- Update with multiple conditions (AND)
UPDATE employees
SET salary = salary * 1.10  -- 10% raise
WHERE department_id = 3
  AND hire_date < '2020-01-01';

-- Update with OR condition
UPDATE products
SET is_featured = FALSE
WHERE stock_quantity = 0
   OR discontinued = TRUE;

-- Update with IN clause
UPDATE orders
SET priority = 'high'
WHERE customer_id IN (101, 102, 103, 104);

-- Update with BETWEEN
UPDATE products
SET discount_percentage = 10
WHERE price BETWEEN 50 AND 100;

-- Update with LIKE
UPDATE customers
SET email_verified = TRUE
WHERE email LIKE '%@company.com';

-- Update with IS NULL
UPDATE customers
SET phone = 'NOT PROVIDED'
WHERE phone IS NULL;

-- ============================================
-- UPDATE WITH CALCULATIONS
-- ============================================

-- Increase value by percentage
UPDATE products
SET price = price * 1.15  -- 15% increase
WHERE category_id = 2;

-- Decrease value
UPDATE products
SET stock_quantity = stock_quantity - 5
WHERE product_id = 10;

-- Conditional calculation
UPDATE products
SET price = CASE
    WHEN category_id = 1 THEN price * 1.10  -- 10% increase
    WHEN category_id = 2 THEN price * 1.05  -- 5% increase
    ELSE price
END
WHERE price > 0;

-- Update with mathematical operations
UPDATE order_items
SET total_price = unit_price * quantity;

-- Update with concatenation
UPDATE users
SET full_name = CONCAT(first_name, ' ', last_name);

-- ============================================
-- UPDATE WITH SUBQUERIES
-- ============================================

-- Update based on subquery result
UPDATE products
SET category_name = (
    SELECT name
    FROM categories
    WHERE categories.category_id = products.category_id
);

-- Update using value from another table
UPDATE employees
SET department_name = (
    SELECT name
    FROM departments
    WHERE departments.id = employees.department_id
);

-- Update based on aggregated data
UPDATE customers
SET total_orders = (
    SELECT COUNT(*)
    FROM orders
    WHERE orders.customer_id = customers.customer_id
);

-- Update using subquery in WHERE
UPDATE products
SET is_bestseller = TRUE
WHERE product_id IN (
    SELECT product_id
    FROM order_items
    GROUP BY product_id
    HAVING SUM(quantity) > 100
);

-- Update based on NOT EXISTS
UPDATE products
SET is_orphaned = TRUE
WHERE NOT EXISTS (
    SELECT 1
    FROM categories
    WHERE categories.category_id = products.category_id
);

-- ============================================
-- UPDATE WITH JOIN (MySQL specific)
-- ============================================

-- Update using JOIN
UPDATE products p
INNER JOIN categories c ON p.category_id = c.category_id
SET p.category_name = c.name
WHERE c.is_active = TRUE;

-- Update multiple tables (MySQL)
UPDATE orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
SET o.customer_email = c.email,
    o.updated_at = NOW()
WHERE c.email_verified = TRUE;

-- Update with LEFT JOIN
UPDATE products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
SET p.never_ordered = TRUE
WHERE oi.product_id IS NULL;

-- Complex join update
UPDATE employees e
INNER JOIN departments d ON e.department_id = d.department_id
INNER JOIN locations l ON d.location_id = l.location_id
SET e.cost_center = CONCAT(d.code, '-', l.code)
WHERE e.cost_center IS NULL;

-- ============================================
-- BATCH UPDATES
-- ============================================

-- Update in batches with LIMIT
UPDATE large_table
SET processed = TRUE
WHERE status = 'pending'
LIMIT 1000;

-- Update with ORDER BY and LIMIT
UPDATE products
SET is_featured = TRUE
ORDER BY sales_count DESC
LIMIT 10;  -- Top 10 products

-- Batch update with CASE for different values
UPDATE products
SET discount = CASE product_id
    WHEN 1 THEN 10
    WHEN 2 THEN 15
    WHEN 3 THEN 20
    ELSE discount
END
WHERE product_id IN (1, 2, 3);

-- ============================================
-- CONDITIONAL UPDATES
-- ============================================

-- Simple CASE statement
UPDATE orders
SET status = CASE
    WHEN shipped_date IS NOT NULL THEN 'shipped'
    WHEN payment_date IS NOT NULL THEN 'paid'
    WHEN created_at < DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 'expired'
    ELSE 'pending'
END;

-- Complex CASE with multiple conditions
UPDATE employees
SET bonus = CASE
    WHEN years_of_service >= 10 AND performance_rating >= 8 THEN salary * 0.15
    WHEN years_of_service >= 5 AND performance_rating >= 7 THEN salary * 0.10
    WHEN performance_rating >= 8 THEN salary * 0.08
    ELSE salary * 0.05
END;

-- IF function (MySQL specific)
UPDATE products
SET stock_status = IF(stock_quantity > 0, 'In Stock', 'Out of Stock');

-- IFNULL for default values
UPDATE customers
SET phone = IFNULL(phone, mobile_phone);

-- ============================================
-- DATE AND TIME UPDATES
-- ============================================

-- Current timestamp
UPDATE orders
SET updated_at = CURRENT_TIMESTAMP
WHERE order_id = 100;

-- Add time interval
UPDATE subscriptions
SET expiry_date = DATE_ADD(start_date, INTERVAL 1 YEAR)
WHERE subscription_type = 'annual';

-- Subtract time interval
UPDATE orders
SET shipping_deadline = DATE_SUB(delivery_date, INTERVAL 2 DAY)
WHERE delivery_date IS NOT NULL;

-- Date manipulation
UPDATE events
SET end_date = DATE_ADD(start_date, INTERVAL duration_days DAY);

-- Extract date parts
UPDATE analytics
SET year = YEAR(created_at),
    month = MONTH(created_at),
    day = DAY(created_at);

-- ============================================
-- STRING MANIPULATION UPDATES
-- ============================================

-- UPPER/LOWER case
UPDATE customers
SET email = LOWER(email);

UPDATE products
SET name = UPPER(name)
WHERE category_id = 1;

-- TRIM whitespace
UPDATE customers
SET first_name = TRIM(first_name),
    last_name = TRIM(last_name);

-- REPLACE
UPDATE products
SET description = REPLACE(description, 'old text', 'new text');

-- SUBSTRING
UPDATE users
SET postal_code = SUBSTRING(full_address, -5);

-- Concatenation
UPDATE customers
SET full_address = CONCAT(street, ', ', city, ', ', state, ' ', zip_code);

-- ============================================
-- SAFE UPDATE PRACTICES
-- ============================================

-- Always test with SELECT first
SELECT *
FROM products
WHERE category_id = 3;

-- Then run the UPDATE
UPDATE products
SET price = price * 0.90
WHERE category_id = 3;

-- Use transactions for critical updates
START TRANSACTION;

UPDATE accounts
SET balance = balance - 100
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 100
WHERE account_id = 2;

-- Check if everything is correct
SELECT * FROM accounts WHERE account_id IN (1, 2);

-- If good:
COMMIT;
-- If problems:
-- ROLLBACK;

-- Create backup before mass update
CREATE TABLE products_backup AS SELECT * FROM products;

UPDATE products
SET price = price * 1.20;

-- If problems, restore:
-- TRUNCATE products;
-- INSERT INTO products SELECT * FROM products_backup;

-- ============================================
-- COMMON UPDATE PATTERNS
-- ============================================

-- Pattern 1: Flag outdated records
UPDATE products
SET is_outdated = TRUE
WHERE last_updated < DATE_SUB(NOW(), INTERVAL 6 MONTH);

-- Pattern 2: Soft delete
UPDATE users
SET is_deleted = TRUE,
    deleted_at = NOW()
WHERE user_id = 123;

-- Pattern 3: Archive old records
UPDATE orders
SET is_archived = TRUE
WHERE order_date < DATE_SUB(NOW(), INTERVAL 2 YEAR)
  AND status = 'completed';

-- Pattern 4: Denormalization update
UPDATE orders
SET total_amount = (
    SELECT SUM(quantity * unit_price)
    FROM order_items
    WHERE order_items.order_id = orders.order_id
);

-- Pattern 5: Status progression
UPDATE tasks
SET status = 'in_progress',
    started_at = NOW()
WHERE status = 'pending'
  AND assigned_to IS NOT NULL;

-- Pattern 6: Reset/clear fields
UPDATE sessions
SET token = NULL,
    expires_at = NULL
WHERE expires_at < NOW();

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

-- Exercise 1: Price Update
-- Increase prices by 10% for all products in category 'Electronics'
-- that haven't been updated in the last 30 days
-- YOUR CODE HERE:



-- Exercise 2: Customer Status
-- Update customer status to 'VIP' for customers who have:
-- - Made more than 10 orders
-- - Total spending > $1000
-- - Active account
-- YOUR CODE HERE:



-- Exercise 3: Batch Processing
-- Update products to set 'low_stock' flag for items where:
-- - stock_quantity < reorder_level
-- - is_active = TRUE
-- Limit to 100 records
-- YOUR CODE HERE:



-- Exercise 4: Data Cleanup
-- For all customers:
-- - Trim whitespace from first_name and last_name
-- - Convert email to lowercase
-- - Set phone to 'N/A' where NULL
-- YOUR CODE HERE:



-- Exercise 5: Complex Status Update
-- Update order status based on conditions:
-- - 'shipped' if shipped_date is set
-- - 'processing' if packed_date is set but not shipped
-- - 'pending' if paid but not packed
-- - 'cancelled' if order_date > 30 days and status still 'pending'
-- YOUR CODE HERE:



-- Exercise 6: Profit Calculation
-- Update product profit_margin column:
-- profit_margin = ((selling_price - cost_price) / cost_price) * 100
-- Only for products where both prices are set
-- YOUR CODE HERE:



-- Exercise 7: Reference Data Synchronization
-- Update employees table to set department_name from departments table
-- for all employees where department_name is NULL or empty
-- YOUR CODE HERE:



-- ============================================
-- NOTES
-- ============================================

/*
BEST PRACTICES:

1. ALWAYS use WHERE clause
   - Without WHERE, ALL rows are updated!
   - Test with SELECT first

2. Use transactions for critical updates
   - Allows ROLLBACK if something goes wrong
   - Provides data consistency

3. Backup before mass updates
   - Create table copy or export data
   - Easy recovery if needed

4. Verify affected rows
   - Check row count after update
   - Review sample of updated records

5. Update in batches for large tables
   - Use LIMIT to control update size
   - Prevents long locks and timeouts

6. Consider performance
   - Indexed columns in WHERE clause
   - Avoid complex calculations in large updates

COMMON MISTAKES:

1. Forgetting WHERE clause → Updates all rows
2. Not testing SELECT before UPDATE
3. Updating without backup on production
4. Complex UPDATEs without transactions
5. Not handling NULL values properly
6. Self-referencing updates without subquery

TROUBLESHOOTING:

1. "Safe mode" error (MySQL Workbench):
   SET SQL_SAFE_UPDATES = 0;
   -- Run your UPDATE
   SET SQL_SAFE_UPDATES = 1;

2. Deadlocks in concurrent updates:
   - Update in consistent order
   - Use shorter transactions
   - Add appropriate indexes

3. Update takes too long:
   - Break into smaller batches
   - Update during off-peak hours
   - Check for missing indexes

4. Unexpected results:
   - Always SELECT first
   - Use EXPLAIN to understand query plan
   - Test on copy of data first

PERFORMANCE TIPS:

1. Index columns in WHERE clause
2. Update in batches with LIMIT
3. Avoid functions on indexed columns in WHERE
4. Use EXPLAIN to optimize complex updates
5. Consider creating temp table for complex logic

MYSQL SAFE UPDATE MODE:

When safe update mode is ON:
- UPDATE/DELETE without WHERE on indexed column is blocked
- UPDATE/DELETE without LIMIT is blocked

To disable temporarily:
SET SQL_SAFE_UPDATES = 0;
*/
