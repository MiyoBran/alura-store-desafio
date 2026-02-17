-- TRANSACTIONS - SQL Practice
-- Managing data consistency and integrity with ACID properties

-- ============================================
-- WHAT ARE TRANSACTIONS?
-- ============================================

/*
A TRANSACTION is a sequence of SQL operations treated as a single unit.

ACID Properties:
- Atomicity: All or nothing (complete or rollback)
- Consistency: Data remains valid
- Isolation: Concurrent transactions don't interfere
- Durability: Committed changes persist

Key Commands:
- START TRANSACTION / BEGIN - Start transaction
- COMMIT - Save all changes
- ROLLBACK - Undo all changes
- SAVEPOINT - Create checkpoint within transaction

Use Cases:
- Financial operations (transfers, payments)
- Multi-table inserts/updates
- Data integrity requirements
- Error recovery
- Concurrent access control
*/

-- ============================================
-- BASIC TRANSACTION SYNTAX
-- ============================================

-- Simple transaction
START TRANSACTION;

INSERT INTO customers (name, email)
VALUES ('John Doe', 'john@example.com');

-- If everything is okay:
COMMIT;

-- If there's a problem:
-- ROLLBACK;

-- Transaction with multiple operations
START TRANSACTION;

UPDATE accounts
SET balance = balance - 100
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 100
WHERE account_id = 2;

COMMIT;

-- Transaction with error handling
START TRANSACTION;

INSERT INTO orders (customer_id, order_date, total)
VALUES (1, NOW(), 150.00);

SET @order_id = LAST_INSERT_ID();

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (@order_id, 5, 2, 75.00);

-- Verify the data
SELECT * FROM orders WHERE order_id = @order_id;
SELECT * FROM order_items WHERE order_id = @order_id;

-- If correct:
COMMIT;
-- If wrong:
-- ROLLBACK;

-- ============================================
-- SAVEPOINTS
-- ============================================

-- Savepoint allows partial rollback
START TRANSACTION;

INSERT INTO categories (category_name)
VALUES ('Electronics');

SAVEPOINT sp1;

INSERT INTO categories (category_name)
VALUES ('Books');

SAVEPOINT sp2;

INSERT INTO categories (category_name)
VALUES ('Clothing');

-- Rollback to sp2 (removes 'Clothing', keeps 'Books' and 'Electronics')
ROLLBACK TO SAVEPOINT sp2;

-- Rollback to sp1 (removes 'Books' and 'Clothing', keeps 'Electronics')
ROLLBACK TO SAVEPOINT sp1;

-- Release savepoint (no longer needed)
RELEASE SAVEPOINT sp1;

COMMIT;

-- ============================================
-- AUTOCOMMIT MODE
-- ============================================

-- Check autocommit status
SELECT @@autocommit;

-- Disable autocommit (each statement is NOT auto-committed)
SET autocommit = 0;

INSERT INTO customers (name, email)
VALUES ('Jane Smith', 'jane@example.com');

-- Must explicitly commit
COMMIT;

-- Enable autocommit (default)
SET autocommit = 1;

-- Single statement with autocommit disabled
SET autocommit = 0;
UPDATE products SET price = price * 1.1 WHERE category_id = 3;
COMMIT;
SET autocommit = 1;

-- ============================================
-- ISOLATION LEVELS
-- ============================================

/*
Isolation Levels (from least to most strict):

1. READ UNCOMMITTED
   - Can read uncommitted changes from other transactions
   - Dirty reads possible
   - Fastest, least safe

2. READ COMMITTED (PostgreSQL default)
   - Can only read committed data
   - Prevents dirty reads
   - Non-repeatable reads possible

3. REPEATABLE READ (MySQL default)
   - Same query returns same results within transaction
   - Prevents dirty reads and non-repeatable reads
   - Phantom reads possible

4. SERIALIZABLE
   - Transactions execute as if serial (one after another)
   - Prevents all anomalies
   - Slowest, most safe
*/

-- Check current isolation level
SELECT @@transaction_isolation;

-- Set isolation level for next transaction
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Set isolation level for current transaction only
START TRANSACTION;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- ... your queries ...
COMMIT;

-- READ UNCOMMITTED example
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 1;
-- Can see uncommitted changes from other transactions!
COMMIT;

-- REPEATABLE READ example
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 1;
-- ... time passes, another transaction updates and commits ...
SELECT balance FROM accounts WHERE account_id = 1;
-- Same value as first SELECT (repeatable read)
COMMIT;

-- SERIALIZABLE example
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 1;
-- Other transactions may wait or fail if they conflict
UPDATE accounts SET balance = balance + 100 WHERE account_id = 1;
COMMIT;

-- ============================================
-- LOCKING
-- ============================================

-- SELECT ... FOR UPDATE (exclusive lock)
START TRANSACTION;

SELECT balance
FROM accounts
WHERE account_id = 1
FOR UPDATE;  -- Lock the row

-- Other transactions must wait to modify this row
UPDATE accounts
SET balance = balance - 100
WHERE account_id = 1;

COMMIT;  -- Release lock

-- SELECT ... LOCK IN SHARE MODE (shared lock)
START TRANSACTION;

SELECT balance
FROM accounts
WHERE account_id = 1
LOCK IN SHARE MODE;  -- Shared lock (others can read, not write)

-- Other transactions can read but not modify
-- Your transaction can also read but typically shouldn't modify

COMMIT;

-- Lock multiple rows
START TRANSACTION;

SELECT *
FROM products
WHERE category_id = 5
FOR UPDATE;

-- All matching rows are locked
UPDATE products
SET stock_quantity = stock_quantity - 1
WHERE category_id = 5;

COMMIT;

-- ============================================
-- DEADLOCK HANDLING
-- ============================================

/*
Deadlock occurs when two transactions wait for each other:

Transaction A:
1. Locks row 1
2. Waits for row 2 (locked by B)

Transaction B:
1. Locks row 2
2. Waits for row 1 (locked by A)

MySQL automatically detects and rolls back one transaction.
*/

-- Example that might cause deadlock (DON'T RUN simultaneously)

-- Session 1:
START TRANSACTION;
UPDATE accounts SET balance = balance - 10 WHERE account_id = 1;
-- Waits here for Session 2 to release account_id = 2
UPDATE accounts SET balance = balance + 10 WHERE account_id = 2;
COMMIT;

-- Session 2 (running at same time):
START TRANSACTION;
UPDATE accounts SET balance = balance - 5 WHERE account_id = 2;
-- Waits here for Session 1 to release account_id = 1
UPDATE accounts SET balance = balance + 5 WHERE account_id = 1;
COMMIT;
-- One of these will be rolled back automatically!

-- Prevent deadlocks:
-- 1. Always access tables/rows in same order
-- 2. Keep transactions short
-- 3. Use appropriate isolation levels
-- 4. Handle deadlock exceptions in application code

-- ============================================
-- PRACTICAL TRANSACTION EXAMPLES
-- ============================================

-- Example 1: Bank Transfer
DELIMITER //

CREATE PROCEDURE transfer_money(
    IN from_account INT,
    IN to_account INT,
    IN amount DECIMAL(10,2)
)
BEGIN
    DECLARE from_balance DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transaction failed' AS message;
    END;
    
    START TRANSACTION;
    
    -- Lock and check source account balance
    SELECT balance INTO from_balance
    FROM accounts
    WHERE account_id = from_account
    FOR UPDATE;
    
    -- Validate sufficient funds
    IF from_balance < amount THEN
        ROLLBACK;
        SELECT 'Insufficient funds' AS message;
    ELSE
        -- Deduct from source
        UPDATE accounts
        SET balance = balance - amount
        WHERE account_id = from_account;
        
        -- Add to destination
        UPDATE accounts
        SET balance = balance + amount
        WHERE account_id = to_account;
        
        -- Log transaction
        INSERT INTO account_transactions (
            from_account_id,
            to_account_id,
            amount,
            transaction_date
        ) VALUES (
            from_account,
            to_account,
            amount,
            NOW()
        );
        
        COMMIT;
        SELECT 'Transfer successful' AS message;
    END IF;
END //

DELIMITER ;

CALL transfer_money(1, 2, 100.00);

-- Example 2: Order Processing
START TRANSACTION;

-- Create order
INSERT INTO orders (customer_id, order_date, status)
VALUES (123, NOW(), 'pending');

SET @order_id = LAST_INSERT_ID();

-- Check product availability and lock rows
SELECT product_id, stock_quantity
FROM products
WHERE product_id IN (5, 10, 15)
FOR UPDATE;

-- Add order items and update stock
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES 
    (@order_id, 5, 2, 29.99),
    (@order_id, 10, 1, 49.99),
    (@order_id, 15, 3, 19.99);

UPDATE products SET stock_quantity = stock_quantity - 2 WHERE product_id = 5;
UPDATE products SET stock_quantity = stock_quantity - 1 WHERE product_id = 10;
UPDATE products SET stock_quantity = stock_quantity - 3 WHERE product_id = 15;

-- Update order total
UPDATE orders
SET total = (
    SELECT SUM(quantity * unit_price)
    FROM order_items
    WHERE order_id = @order_id
)
WHERE order_id = @order_id;

-- Verify no negative stock
IF EXISTS (SELECT 1 FROM products WHERE product_id IN (5, 10, 15) AND stock_quantity < 0) THEN
    ROLLBACK;
    SELECT 'Insufficient stock' AS error;
ELSE
    COMMIT;
    SELECT @order_id AS order_id, 'Order created successfully' AS message;
END IF;

-- Example 3: Batch Update with Error Recovery
START TRANSACTION;

SAVEPOINT before_price_update;

-- Update prices for category 1
UPDATE products
SET price = price * 1.10
WHERE category_id = 1;

-- Check if any price exceeds maximum
IF EXISTS (SELECT 1 FROM products WHERE price > 9999.99) THEN
    -- Rollback price change
    ROLLBACK TO SAVEPOINT before_price_update;
    SELECT 'Price update cancelled - exceeded maximum' AS message;
ELSE
    -- Log price changes
    INSERT INTO price_change_log (category_id, change_percentage, changed_at)
    VALUES (1, 10.00, NOW());
    
    COMMIT;
    SELECT 'Prices updated successfully' AS message;
END IF;

-- Example 4: Multi-table Data Sync
START TRANSACTION;

-- Update product
UPDATE products
SET product_name = 'Updated Product Name',
    price = 99.99,
    updated_at = NOW()
WHERE product_id = 100;

-- Update denormalized data in orders
UPDATE order_items
SET product_name = 'Updated Product Name',
    unit_price = 99.99
WHERE product_id = 100
  AND order_id IN (
      SELECT order_id
      FROM orders
      WHERE status = 'pending'
  );

-- Recalculate order totals
UPDATE orders o
SET total = (
    SELECT SUM(quantity * unit_price)
    FROM order_items
    WHERE order_id = o.order_id
)
WHERE order_id IN (
    SELECT DISTINCT order_id
    FROM order_items
    WHERE product_id = 100
);

COMMIT;

-- ============================================
-- TRANSACTION MONITORING
-- ============================================

-- Show running transactions (MySQL/InnoDB)
SELECT * FROM information_schema.INNODB_TRX;

-- Show locks
SELECT * FROM information_schema.INNODB_LOCKS;

-- Show lock waits
SELECT * FROM information_schema.INNODB_LOCK_WAITS;

-- Show process list
SHOW PROCESSLIST;

-- Kill long-running transaction
-- KILL <process_id>;

-- Transaction history (if general log enabled)
SHOW VARIABLES LIKE 'general_log%';

-- ============================================
-- TRANSACTION BEST PRACTICES
-- ============================================

-- Pattern 1: Try-Catch style with error handler
DELIMITER //

CREATE PROCEDURE safe_update_inventory(
    IN product_id INT,
    IN quantity_change INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Update failed - transaction rolled back' AS error;
    END;
    
    START TRANSACTION;
    
    UPDATE products
    SET stock_quantity = stock_quantity + quantity_change
    WHERE product_id = product_id;
    
    -- Validate result
    IF (SELECT stock_quantity FROM products WHERE product_id = product_id) < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock cannot be negative';
    END IF;
    
    INSERT INTO inventory_log (product_id, quantity_change, changed_at)
    VALUES (product_id, quantity_change, NOW());
    
    COMMIT;
    SELECT 'Update successful' AS message;
END //

DELIMITER ;

-- Pattern 2: Explicit validation before commit
START TRANSACTION;

-- Make changes
UPDATE accounts SET balance = balance - 500 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 500 WHERE account_id = 2;

-- Validate
SET @balance_check = (
    SELECT SUM(balance)
    FROM accounts
    WHERE account_id IN (1, 2)
);

-- Previous total should equal current total
IF @balance_check = @expected_total THEN
    COMMIT;
ELSE
    ROLLBACK;
    SELECT 'Validation failed' AS error;
END IF;

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

-- Exercise 1: Simple Money Transfer
-- Write transaction to transfer $50 from account 1 to account 2
-- Include validation for sufficient funds
-- YOUR CODE HERE:



-- Exercise 2: Order Creation with Stock Check
-- Create transaction that:
-- 1. Creates order
-- 2. Adds order items
-- 3. Updates product stock
-- 4. Rollback if any product has insufficient stock
-- YOUR CODE HERE:



-- Exercise 3: Batch Price Update with Savepoints
-- Update prices for multiple categories
-- Use savepoints to allow partial rollback if one category fails validation
-- YOUR CODE HERE:



-- Exercise 4: User Registration with Profile
-- Create transaction that:
-- 1. Inserts into users table
-- 2. Inserts into user_profiles table
-- 3. Inserts into user_preferences table
-- 4. Rollback all if any step fails
-- YOUR CODE HERE:



-- Exercise 5: Inventory Adjustment with Logging
-- Create stored procedure that:
-- 1. Updates product stock
-- 2. Logs change to inventory_log table
-- 3. Validates stock doesn't go negative
-- 4. Uses proper error handling
-- YOUR CODE HERE:



-- Exercise 6: Test Isolation Levels
-- Create two transactions that demonstrate the difference between
-- READ COMMITTED and REPEATABLE READ
-- YOUR CODE HERE:



-- ============================================
-- NOTES
-- ============================================

/*
TRANSACTION BEST PRACTICES:

1. Keep Transactions Short
   - Minimize transaction duration
   - Don't include unnecessary operations
   - Avoid user interaction within transactions
   - Release locks quickly

2. Access Resources in Consistent Order
   - Prevents deadlocks
   - Always lock table A before table B
   - Document locking order

3. Use Appropriate Isolation Level
   - Don't use SERIALIZABLE unless necessary
   - READ COMMITTED for most cases
   - REPEATABLE READ for consistency
   - Consider performance trade-offs

4. Handle Errors Properly
   - Always include error handling
   - ROLLBACK on errors
   - Return meaningful error messages
   - Log errors for debugging

5. Use Savepoints for Complex Operations
   - Allows partial rollback
   - Better than all-or-nothing
   - Clean up savepoints when done

6. Validate Before Commit
   - Check data integrity
   - Verify business rules
   - Ensure constraints are met

COMMON TRANSACTION PATTERNS:

1. Transfer Pattern
   START TRANSACTION;
   UPDATE table1 SET value = value - X;
   UPDATE table2 SET value = value + X;
   COMMIT;

2. Create with Dependencies
   START TRANSACTION;
   INSERT INTO parent_table ...;
   SET @parent_id = LAST_INSERT_ID();
   INSERT INTO child_table (parent_id, ...) VALUES (@parent_id, ...);
   COMMIT;

3. Validate and Update
   START TRANSACTION;
   SELECT ... FOR UPDATE;  -- Lock
   -- Validate
   IF valid THEN
       UPDATE ...;
       COMMIT;
   ELSE
       ROLLBACK;
   END IF;

TRANSACTION MISTAKES TO AVOID:

1. ❌ Long-running transactions
   - Holds locks too long
   - Blocks other users
   - Risk of timeout

2. ❌ No error handling
   - Partial updates on error
   - Data inconsistency
   - No recovery mechanism

3. ❌ Forgetting to COMMIT
   - Changes not saved
   - Locks held indefinitely (if autocommit=0)

4. ❌ Reading outside transaction
   - Inconsistent data view
   - Race conditions

5. ❌ Not using FOR UPDATE when needed
   - Lost updates
   - Race conditions
   - Data corruption

6. ❌ Nested transactions (not supported in MySQL)
   - Use savepoints instead

PERFORMANCE CONSIDERATIONS:

1. Transaction Overhead
   - Each transaction has cost
   - Batch operations when possible
   - But not too large (lock duration)

2. Lock Contention
   - Minimize locked rows/tables
   - Short transaction duration
   - Use row-level locking

3. Deadlock Prevention
   - Consistent lock ordering
   - Short transactions
   - Appropriate isolation level
   - Retry logic in application

4. Log File Size
   - Transactions use redo/undo logs
   - Monitor log file growth
   - Tune log buffer size

WHEN TO USE TRANSACTIONS:

✅ Always Use For:
- Money transfers
- Multi-table inserts/updates
- Data integrity requirements
- Inventory management
- Any operation that must be atomic

✅ Consider Using For:
- Batch operations
- Complex business logic
- Data migrations
- Reporting (consistent snapshot)

❌ May Not Need For:
- Single INSERT/UPDATE/DELETE
- Read-only operations
- Logging (can lose some data)
- Non-critical data

TESTING TRANSACTIONS:

1. Test happy path (all success)
2. Test error handling (each step fails)
3. Test concurrent access (multiple users)
4. Test deadlock scenarios
5. Test with realistic data volumes
6. Test isolation  levels
7. Monitor performance impact

TRANSACTION MONITORING:

1. Track long-running transactions
2. Monitor lock waits
3. Identify deadlocks
4. Review isolation levels
5. Check transaction log size
6. Profile transaction performance
*/
