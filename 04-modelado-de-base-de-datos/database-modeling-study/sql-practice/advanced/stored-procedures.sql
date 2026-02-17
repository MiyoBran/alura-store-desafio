-- STORED PROCEDURES - SQL Practice
-- Creating reusable SQL code blocks with parameters and logic

-- ============================================
-- WHAT ARE STORED PROCEDURES?
-- ============================================

/*
A Stored Procedure is a prepared SQL code that you can save and reuse.

Benefits:
- Reusable code
- Better performance (compiled once)
- Reduce network traffic
- Business logic encapsulation
- Security (grant EXECUTE without table access)
- Transaction management
- Complex logic with control flow

Syntax varies by database:
- MySQL/MariaDB: DELIMITER, BEGIN/END
- PostgreSQL: CREATE FUNCTION
- SQL Server: CREATE PROCEDURE
- Oracle: PL/SQL
*/

-- ============================================
-- BASIC STORED PROCEDURES (MySQL)
-- ============================================

-- Change delimiter (MySQL/MariaDB)
DELIMITER //

-- Simple procedure without parameters
CREATE PROCEDURE get_all_customers()
BEGIN
    SELECT * FROM customers;
END //

DELIMITER ;

-- Call the procedure
CALL get_all_customers();

-- ============================================
-- PROCEDURES WITH INPUT PARAMETERS
-- ============================================

DELIMITER //

-- Single input parameter
CREATE PROCEDURE get_customer_by_id(IN customer_id INT)
BEGIN
    SELECT 
        customer_id,
        name,
        email,
        registration_date
    FROM customers
    WHERE customer_id = customer_id;
END //

DELIMITER ;

-- Call with parameter
CALL get_customer_by_id(123);

-- Multiple input parameters
DELIMITER //

CREATE PROCEDURE get_orders_by_date_range(
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    SELECT 
        order_id,
        customer_id,
        order_date,
        total,
        status
    FROM orders
    WHERE order_date BETWEEN start_date AND end_date
    ORDER BY order_date DESC;
END //

DELIMITER ;

-- Call with multiple parameters
CALL get_orders_by_date_range('2024-01-01', '2024-12-31');

-- ============================================
-- PROCEDURES WITH OUTPUT PARAMETERS
-- ============================================

DELIMITER //

-- OUT parameter returns a value
CREATE PROCEDURE get_customer_count(OUT total_customers INT)
BEGIN
    SELECT COUNT(*) INTO total_customers
    FROM customers
    WHERE is_active = TRUE;
END //

DELIMITER ;

-- Call and retrieve output
CALL get_customer_count(@count);
SELECT @count AS total_customers;

-- Multiple IN and OUT parameters
DELIMITER //

CREATE PROCEDURE get_order_summary(
    IN cust_id INT,
    OUT order_count INT,
    OUT total_spent DECIMAL(10,2)
)
BEGIN
    SELECT 
        COUNT(*),
        COALESCE(SUM(total), 0)
    INTO order_count, total_spent
    FROM orders
    WHERE customer_id = cust_id;
END //

DELIMITER ;

-- Call and get outputs
CALL get_order_summary(123, @orders, @spent);
SELECT @orders AS order_count, @spent AS total_spent;

-- ============================================
-- PROCEDURES WITH INOUT PARAMETERS
-- ============================================

DELIMITER //

-- INOUT parameter: both input and output
CREATE PROCEDURE apply_discount(INOUT price DECIMAL(10,2), IN discount_pct DECIMAL(5,2))
BEGIN
    SET price = price * (1 - discount_pct / 100);
END //

DELIMITER ;

-- Call with INOUT
SET @product_price = 100.00;
CALL apply_discount(@product_price, 10);  -- 10% discount
SELECT @product_price;  -- Returns 90.00

-- ============================================
-- CONTROL FLOW: IF-THEN-ELSE
-- ============================================

DELIMITER //

CREATE PROCEDURE categorize_order(
    IN order_total DECIMAL(10,2),
    OUT category VARCHAR(50)
)
BEGIN
    IF order_total < 50 THEN
        SET category = 'Small';
    ELSEIF order_total < 200 THEN
        SET category = 'Medium';
    ELSEIF order_total < 1000 THEN
        SET category = 'Large';
    ELSE
        SET category = 'Premium';
    END IF;
END //

DELIMITER ;

CALL categorize_order(150.00, @cat);
SELECT @cat;  -- Returns 'Medium'

-- ============================================
-- CONTROL FLOW: CASE
-- ============================================

DELIMITER //

CREATE PROCEDURE get_discount_rate(
    IN customer_tier VARCHAR(20),
    OUT discount_pct DECIMAL(5,2)
)
BEGIN
    SET discount_pct = CASE customer_tier
        WHEN 'platinum' THEN 20.00
        WHEN 'gold' THEN 15.00
        WHEN 'silver' THEN 10.00
        WHEN 'bronze' THEN 5.00
        ELSE 0.00
    END;
END //

DELIMITER ;

-- ============================================
-- CONTROL FLOW: LOOPS
-- ============================================

-- WHILE loop
DELIMITER //

CREATE PROCEDURE generate_sequence(IN max_num INT)
BEGIN
    DECLARE counter INT DEFAULT 1;
    
    DROP TEMPORARY TABLE IF EXISTS sequence_temp;
    CREATE TEMPORARY TABLE sequence_temp (num INT);
    
    WHILE counter <= max_num DO
        INSERT INTO sequence_temp VALUES (counter);
        SET counter = counter + 1;
    END WHILE;
    
    SELECT * FROM sequence_temp;
END //

DELIMITER ;

CALL generate_sequence(10);

-- REPEAT loop (do-while)
DELIMITER //

CREATE PROCEDURE repeat_example(IN iterations INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    
    REPEAT
        SET i = i + 1;
        SELECT i;
    UNTIL i >= iterations
    END REPEAT;
END //

DELIMITER ;

-- LOOP with LEAVE (break)
DELIMITER //

CREATE PROCEDURE loop_example()
BEGIN
    DECLARE counter INT DEFAULT 0;
    
    my_loop: LOOP
        SET counter = counter + 1;
        
        IF counter > 5 THEN
            LEAVE my_loop;  -- Exit loop
        END IF;
        
        SELECT counter;
    END LOOP;
END //

DELIMITER ;

-- ============================================
-- ERROR HANDLING
-- ============================================

DELIMITER //

CREATE PROCEDURE safe_insert_customer(
    IN cust_name VARCHAR(100),
    IN cust_email VARCHAR(100),
    OUT success BOOLEAN,
    OUT error_msg VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET success = FALSE;
        SET error_msg = 'Error occurred during insert';
        ROLLBACK;
    END;
    
    START TRANSACTION;
    
    INSERT INTO customers (name, email, registration_date)
    VALUES (cust_name, cust_email, CURDATE());
    
    SET success = TRUE;
    SET error_msg = 'Customer created successfully';
    
    COMMIT;
END //

DELIMITER ;

CALL safe_insert_customer('John Doe', 'john@example.com', @ok, @msg);
SELECT @ok, @msg;

-- Specific error handling
DELIMITER //

CREATE PROCEDURE insert_with_duplicate_check(IN email VARCHAR(100))
BEGIN
    DECLARE duplicate_entry CONDITION FOR 1062;  -- MySQL duplicate key error
    
    DECLARE EXIT HANDLER FOR duplicate_entry
    BEGIN
        SELECT 'Email already exists' AS error_message;
    END;
    
    INSERT INTO customers (email, name)
    VALUES (email, 'New Customer');
    
    SELECT 'Customer created' AS success_message;
END //

DELIMITER ;

-- ============================================
-- TRANSACTIONS IN PROCEDURES
-- ============================================

DELIMITER //

CREATE PROCEDURE transfer_funds(
    IN from_account INT,
    IN to_account INT,
    IN amount DECIMAL(10,2),
    OUT result VARCHAR(100)
)
BEGIN
    DECLARE from_balance DECIMAL(10,2);
    
    -- Error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET result = 'Transaction failed';
    END;
    
    START TRANSACTION;
    
    -- Check balance
    SELECT balance INTO from_balance
    FROM accounts
    WHERE account_id = from_account
    FOR UPDATE;  -- Lock row
    
    IF from_balance < amount THEN
        ROLLBACK;
        SET result = 'Insufficient funds';
    ELSE
        -- Deduct from source
        UPDATE accounts
        SET balance = balance - amount
        WHERE account_id = from_account;
        
        -- Add to destination
        UPDATE accounts
        SET balance = balance + amount
        WHERE account_id = to_account;
        
        COMMIT;
        SET result = 'Transfer successful';
    END IF;
END //

DELIMITER ;

CALL transfer_funds(1, 2, 100.00, @result);
SELECT @result;

-- ============================================
-- CURSORS
-- ============================================

DELIMITER //

CREATE PROCEDURE process_all_customers()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_customer_id INT;
    DECLARE v_name VARCHAR(100);
    
    -- Declare cursor
    DECLARE customer_cursor CURSOR FOR
        SELECT customer_id, name
        FROM customers
        WHERE is_active = TRUE;
    
    -- Declare continue handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Open cursor
    OPEN customer_cursor;
    
    read_loop: LOOP
        -- Fetch next row
        FETCH customer_cursor INTO v_customer_id, v_name;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Process each customer
        -- Example: Update or perform action
        SELECT v_customer_id, v_name;
    END LOOP;
    
    -- Close cursor
    CLOSE customer_cursor;
END //

DELIMITER ;

-- Cursor with aggregation
DELIMITER //

CREATE PROCEDURE update_customer_totals()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_customer_id INT;
    DECLARE v_total DECIMAL(10,2);
    
    DECLARE order_cursor CURSOR FOR
        SELECT customer_id, SUM(total) as total_spent
        FROM orders
        GROUP BY customer_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN order_cursor;
    
    update_loop: LOOP
        FETCH order_cursor INTO v_customer_id, v_total;
        
        IF done THEN
            LEAVE update_loop;
        END IF;
        
        UPDATE customers
        SET lifetime_value = v_total
        WHERE customer_id = v_customer_id;
    END LOOP;
    
    CLOSE order_cursor;
END //

DELIMITER ;

-- ============================================
-- DYNAMIC SQL
-- ============================================

DELIMITER //

CREATE PROCEDURE dynamic_query(IN table_name VARCHAR(64))
BEGIN
    SET @sql = CONCAT('SELECT * FROM ', table_name, ' LIMIT 10');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;

CALL dynamic_query('customers');

-- Dynamic SQL with parameters
DELIMITER //

CREATE PROCEDURE search_table(
    IN tbl VARCHAR(64),
    IN col VARCHAR(64),
    IN search_value VARCHAR(100)
)
BEGIN
    SET @sql = CONCAT(
        'SELECT * FROM ', tbl,
        ' WHERE ', col, ' LIKE ?'
    );
    
    PREPARE stmt FROM @sql;
    SET @search = CONCAT('%', search_value, '%');
    EXECUTE stmt USING @search;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;

-- ============================================
-- PRACTICAL EXAMPLES
-- ============================================

-- Example 1: Complete order processing
DELIMITER //

CREATE PROCEDURE create_order(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_order_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_total DECIMAL(10,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Order creation failed';
        SET p_order_id = NULL;
    END;
    
    START TRANSACTION;
    
    -- Check stock
    SELECT unit_price, stock_quantity
    INTO v_price, v_stock
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;
    
    IF v_stock < p_quantity THEN
        ROLLBACK;
        SET p_message = 'Insufficient stock';
        SET p_order_id = NULL;
    ELSE
        -- Calculate total
        SET v_total = v_price * p_quantity;
        
        -- Create order
        INSERT INTO orders (customer_id, order_date, total, status)
        VALUES (p_customer_id, NOW(), v_total, 'pending');
        
        SET p_order_id = LAST_INSERT_ID();
        
        -- Create order items
        INSERT INTO order_items (order_id, product_id, quantity, unit_price)
        VALUES (p_order_id, p_product_id, p_quantity, v_price);
        
        -- Update stock
        UPDATE products
        SET stock_quantity = stock_quantity - p_quantity
        WHERE product_id = p_product_id;
        
        COMMIT;
        SET p_message = 'Order created successfully';
    END IF;
END //

DELIMITER ;

CALL create_order(1, 5, 2, @new_order_id, @msg);
SELECT @new_order_id, @msg;

-- Example 2: Batch email generation
DELIMITER //

CREATE PROCEDURE generate_customer_emails(IN email_type VARCHAR(50))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_customer_id INT;
    DECLARE v_email VARCHAR(100);
    DECLARE v_name VARCHAR(100);
    
    DECLARE customer_cursor CURSOR FOR
        SELECT customer_id, email, name
        FROM customers
        WHERE is_active = TRUE
          AND email_opt_in = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    DROP TEMPORARY TABLE IF EXISTS email_queue;
    CREATE TEMPORARY TABLE email_queue (
        customer_id INT,
        email VARCHAR(100),
        subject VARCHAR(200),
        body TEXT
    );
    
    OPEN customer_cursor;
    
    email_loop: LOOP
        FETCH customer_cursor INTO v_customer_id, v_email, v_name;
        
        IF done THEN
            LEAVE email_loop;
        END IF;
        
        INSERT INTO email_queue (customer_id, email, subject, body)
        VALUES (
            v_customer_id,
            v_email,
            CONCAT(email_type, ' - Special Offer'),
            CONCAT('Dear ', v_name, ', We have a special offer for you!')
        );
    END LOOP;
    
    CLOSE customer_cursor;
    
    SELECT * FROM email_queue;
END //

DELIMITER ;

-- ============================================
-- MANAGING STORED PROCEDURES
-- ============================================

-- Show all stored procedures
SHOW PROCEDURE STATUS WHERE Db = 'your_database';

-- Show procedure definition
SHOW CREATE PROCEDURE get_all_customers;

-- Drop procedure
DROP PROCEDURE IF EXISTS procedure_name;

-- List procedures from information_schema
SELECT 
    ROUTINE_NAME,
    ROUTINE_TYPE,
    CREATED,
    LAST_ALTERED
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'your_database'
  AND ROUTINE_TYPE = 'PROCEDURE';

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

-- Exercise 1: Simple Customer Lookup
-- Create procedure that takes customer_id and returns customer details
-- Name: get_customer_details
-- YOUR CODE HERE:



-- Exercise 2: Order Total Calculator
-- Create procedure that calculates order total from order_items
-- Input: order_id, Output: total_amount
-- Name: calculate_order_total
-- YOUR CODE HERE:



-- Exercise 3: Product Stock Update
-- Create procedure to add/remove stock
-- Inputs: product_id, quantity_change (can be negative)
-- Output: new_stock_quantity, success/error message
-- Name: update_product_stock
-- YOUR CODE HERE:



-- Exercise 4: Customer Tier Assignment
-- Create procedure that assigns customer tier based on lifetime spending
-- Input: customer_id
-- Logic: < $500: Bronze, $500-$2000: Silver, $2000-$10000: Gold, > $10000: Platinum
-- Update customers table with tier
-- Name: assign_customer_tier
-- YOUR CODE HERE:



-- Exercise 5: Monthly Sales Report
-- Create procedure that generates sales summary for given month/year
-- Inputs: year, month
-- Returns: order_count, total_revenue, avg_order_value, unique_customers
-- Name: monthly_sales_report
-- YOUR CODE HERE:



-- Exercise 6: Bulk Price Update
-- Create procedure to update product prices by category
-- Inputs: category_id, percentage_change (e.g., 10 for 10% increase)
-- Include transaction and error handling
-- Name: bulk_update_prices
-- YOUR CODE HERE:



-- ============================================
-- NOTES
-- ============================================

/*
STORED PROCEDURE BEST PRACTICES:

1. Naming Conventions
   - Use descriptive names: create_order not co
   - Prefix: sp_ or proc_ (optional)
   - Verbs for actions: get_, create_, update_, delete_

2. Parameters
   - Use IN, OUT, INOUT appropriately
   - Validate input parameters
   - Use meaningful parameter names: p_ prefix

3. Error Handling
   - Always include error handlers for production
   - Use transactions for data modifications
   - Return meaningful error messages
   - Log errors when appropriate

4. Performance
   - Procedures are compiled and cached
   - Use appropriate indexes on tables
   - Avoid cursors when set-based operations work
   - Keep procedures focused and simple

5. Security
   - Grant EXECUTE permission only
   - Validate all inputs (SQL injection)
   - Use parameterized queries
   - Don't expose sensitive data

6. Documentation
   - Comment complex logic
   - Document parameters and return values
   - Include usage examples
   - Version control procedure code

WHEN TO USE STORED PROCEDURES:

✅ Use For:
- Complex business logic
- Frequent operations
- Transaction management
- Data validation
- Batch processing
- Security (controlled data access)
- Reduce network traffic

❌ Avoid For:
- Simple SELECT queries
- One-time operations
- Frequently changing logic
- When ORM provides better solution
- Presentation logic

COMMON MISTAKES:

1. No error handling
2. Not using transactions
3. Overusing cursors (slow!)
4. Not validating inputs
5. Too complex/long procedures
6. Hard-coding values
7. No documentation
8. Forgetting to drop temp tables

PERFORMANCE TIPS:

1. Use set-based operations over cursors
2. Index columns used in WHERE clauses
3. Minimize transaction scope
4. Avoid SELECT * - specify columns
5. Use temporary tables for complex logic
6. ANALYZE/EXPLAIN procedure execution
7. Cache procedure plans (automatic in most DBs)

TESTING PROCEDURES:

1. Test with valid inputs
2. Test with invalid inputs
3. Test edge cases (NULL, empty, extremes)
4. Test error handling
5. Test concurrent execution
6. Monitor performance
7. Use transactions for test data cleanup

DATABASE-SPECIFIC NOTES:

MySQL:
- DELIMITER required
- No function overloading
- Limited debugging

PostgreSQL:
- CREATE FUNCTION for procedures
- Better error handling
- Supports multiple languages

SQL Server:
- CREATE PROCEDURE
- Rich T-SQL features
- Excellent debugging tools

Oracle:
- PL/SQL
- Most feature-rich
- Package support
*/
