-- TRIGGERS - SQL Practice
-- Automatic actions in response to database events

-- ============================================
-- WHAT ARE TRIGGERS?
-- ============================================

/*
A TRIGGER is a database object that automatically executes when:
- INSERT, UPDATE, or DELETE occurs on a table
- Defined timing: BEFORE or AFTER the event

Common Uses:
- Audit trails (who changed what and when)
- Data validation and enforcement
- Maintaining derived/calculated columns
- Enforcing complex business rules
- Preventing invalid operations
- Logging changes
- Cascading updates/deletes
- Denormalization maintenance

Caution:
- Can slow down operations
- Hidden logic (not visible in application code)
- Can cause unexpected side effects
- Debugging can be difficult
- Can create trigger chains (trigger calling trigger)
*/

-- ============================================
-- BASIC TRIGGERS
-- ============================================

-- BEFORE INSERT trigger
DELIMITER //

CREATE TRIGGER before_customer_insert
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
    -- Set created_at timestamp
    SET NEW.created_at = NOW();
    
    -- Normalize email to lowercase
    SET NEW.email = LOWER(NEW.email);
    
    -- Set default values
    IF NEW.status IS NULL THEN
        SET NEW.status = 'active';
    END IF;
END //

DELIMITER ;

-- AFTER INSERT trigger
DELIMITER //

CREATE TRIGGER after_customer_insert
AFTER INSERT ON customers
FOR EACH ROW
BEGIN
    -- Log the new customer
    INSERT INTO customer_audit_log (
        customer_id,
        action,
        action_date,
        performed_by
    ) VALUES (
        NEW.customer_id,
        'INSERT',
        NOW(),
        USER()
    );
END //

DELIMITER ;

-- BEFORE UPDATE trigger
DELIMITER //

CREATE TRIGGER before_product_update
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    -- Set updated_at timestamp
    SET NEW.updated_at = NOW();
    
    -- Prevent negative prices
    IF NEW.price < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Price cannot be negative';
    END IF;
    
    -- Prevent negative stock
    IF NEW.stock_quantity < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock quantity cannot be negative';
    END IF;
END //

DELIMITER ;

-- AFTER UPDATE trigger
DELIMITER //

CREATE TRIGGER after_product_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    -- Log price changes
    IF OLD.price != NEW.price THEN
        INSERT INTO price_history (
            product_id,
            old_price,
            new_price,
            changed_at,
            changed_by
        ) VALUES (
            NEW.product_id,
            OLD.price,
            NEW.price,
            NOW(),
            USER()
        );
    END IF;
END //

DELIMITER ;

-- BEFORE DELETE trigger
DELIMITER //

CREATE TRIGGER before_customer_delete
BEFORE DELETE ON customers
FOR EACH ROW
BEGIN
    -- Prevent deletion if customer has orders
    IF EXISTS (SELECT 1 FROM orders WHERE customer_id = OLD.customer_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete customer with existing orders';
    END IF;
END //

DELIMITER ;

-- AFTER DELETE trigger
DELIMITER //

CREATE TRIGGER after_customer_delete
AFTER DELETE ON customers
FOR EACH ROW
BEGIN
    -- Archive deleted customer
    INSERT INTO customers_deleted_archive (
        customer_id,
        name,
        email,
        deleted_at,
        deleted_by
    ) VALUES (
        OLD.customer_id,
        OLD.name,
        OLD.email,
        NOW(),
        USER()
    );
END //

DELIMITER ;

-- ============================================
-- AUDIT TRAIL TRIGGERS
-- ============================================

-- Complete audit trail example
DELIMITER //

CREATE TRIGGER audit_orders_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        table_name,
        record_id,
        action,
        old_values,
        new_values,
        changed_by,
        changed_at
    ) VALUES (
        'orders',
        NEW.order_id,
        'INSERT',
        NULL,
        JSON_OBJECT(
            'customer_id', NEW.customer_id,
            'total', NEW.total,
            'status', NEW.status
        ),
        USER(),
        NOW()
    );
END //

CREATE TRIGGER audit_orders_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        table_name,
        record_id,
        action,
        old_values,
        new_values,
        changed_by,
        changed_at
    ) VALUES (
        'orders',
        NEW.order_id,
        'UPDATE',
        JSON_OBJECT(
            'customer_id', OLD.customer_id,
            'total', OLD.total,
            'status', OLD.status
        ),
        JSON_OBJECT(
            'customer_id', NEW.customer_id,
            'total', NEW.total,
            'status', NEW.status
        ),
        USER(),
        NOW()
    );
END //

CREATE TRIGGER audit_orders_delete
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        table_name,
        record_id,
        action,
        old_values,
        new_values,
        changed_by,
        changed_at
    ) VALUES (
        'orders',
        OLD.order_id,
        'DELETE',
        JSON_OBJECT(
            'customer_id', OLD.customer_id,
            'total', OLD.total,
            'status', OLD.status
        ),
        NULL,
        USER(),
        NOW()
    );
END //

DELIMITER ;

-- ============================================
-- DATA VALIDATION TRIGGERS
-- ============================================

DELIMITER //

-- Validate email format
CREATE TRIGGER validate_customer_email
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
    IF NEW.email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid email format';
    END IF;
END //

-- Validate date constraints
CREATE TRIGGER validate_order_dates
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    -- Order date cannot be in the future
    IF NEW.order_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order date cannot be in the future';
    END IF;
    
    -- Shipped date must be after order date
    IF NEW.shipped_date IS NOT NULL AND NEW.shipped_date < NEW.order_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Shipped date cannot be before order date';
    END IF;
END //

-- Validate business rules
CREATE TRIGGER validate_discount
BEFORE INSERT ON discounts
FOR EACH ROW
BEGIN
    -- Percentage discount must be between 0 and 100
    IF NEW.discount_type = 'percentage' THEN
        IF NEW.discount_value < 0 OR NEW.discount_value > 100 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Percentage discount must be between 0 and 100';
        END IF;
    END IF;
    
    -- End date must be after start date
    IF NEW.end_date < NEW.start_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'End date must be after start date';
    END IF;
END //

DELIMITER ;

-- ============================================
-- MAINTAINING CALCULATED COLUMNS
-- ============================================

DELIMITER //

-- Auto-calculate order total
CREATE TRIGGER calculate_order_total
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    SET NEW.line_total = NEW.quantity * NEW.unit_price;
END //

CREATE TRIGGER update_order_total_on_item_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total = (
        SELECT SUM(line_total)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END //

CREATE TRIGGER update_order_total_on_item_update
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total = (
        SELECT SUM(line_total)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END //

CREATE TRIGGER update_order_total_on_item_delete
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total = COALESCE((
        SELECT SUM(line_total)
        FROM order_items
        WHERE order_id = OLD.order_id
    ), 0)
    WHERE order_id = OLD.order_id;
END //

DELIMITER ;

-- ============================================
-- INVENTORY MANAGEMENT TRIGGERS
-- ============================================

DELIMITER //

-- Decrease stock when order is placed
CREATE TRIGGER decrease_stock_on_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity,
        last_sold_date = NOW()
    WHERE product_id = NEW.product_id;
    
    -- Alert if stock is low
    IF (SELECT stock_quantity FROM products WHERE product_id = NEW.product_id) 
       < (SELECT reorder_level FROM products WHERE product_id = NEW.product_id) THEN
        INSERT INTO stock_alerts (product_id, alert_type, created_at)
        VALUES (NEW.product_id, 'LOW_STOCK', NOW());
    END IF;
END //

-- Restore stock on order cancellation
CREATE TRIGGER restore_stock_on_cancel
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status != 'cancelled' AND NEW.status = 'cancelled' THEN
        UPDATE products p
        INNER JOIN order_items oi ON p.product_id = oi.product_id
        SET p.stock_quantity = p.stock_quantity + oi.quantity
        WHERE oi.order_id = NEW.order_id;
    END IF;
END //

DELIMITER ;

-- ============================================
-- DENORMALIZATION TRIGGERS
-- ============================================

DELIMITER //

-- Maintain customer statistics
CREATE TRIGGER update_customer_stats_on_order
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    UPDATE customers
    SET 
        total_orders = total_orders + 1,
        lifetime_value = lifetime_value + NEW.total,
        last_order_date = NEW.order_date
    WHERE customer_id = NEW.customer_id;
END //

-- Update product popularity score
CREATE TRIGGER update_product_popularity
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET 
        times_ordered = times_ordered + 1,
        total_quantity_sold = total_quantity_sold + NEW.quantity,
        popularity_score = (times_ordered + 1) * 10 + (total_quantity_sold + NEW.quantity)
    WHERE product_id = NEW.product_id;
END //

DELIMITER ;

-- ============================================
-- CASCADING OPERATIONS
-- ============================================

DELIMITER //

-- Soft delete cascade
CREATE TRIGGER cascade_soft_delete_orders
AFTER UPDATE ON customers
FOR EACH ROW
BEGIN
    IF OLD.is_deleted = FALSE AND NEW.is_deleted = TRUE THEN
        -- Soft delete all customer's orders
        UPDATE orders
        SET is_deleted = TRUE, deleted_at = NOW()
        WHERE customer_id = NEW.customer_id;
    END IF;
END //

-- Update related timestamps
CREATE TRIGGER update_order_on_item_change
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET updated_at = NOW()
    WHERE order_id = NEW.order_id;
END //

DELIMITER ;

-- ============================================
-- PREVENTING OPERATIONS
-- ============================================

DELIMITER //

-- Prevent updates to finalized records
CREATE TRIGGER prevent_finalized_order_changes
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status = 'completed' AND NEW.status != 'completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot modify completed orders';
    END IF;
END //

-- Prevent deletion of referenced records
CREATE TRIGGER prevent_category_delete_with_products
BEFORE DELETE ON categories
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM products WHERE category_id = OLD.category_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete category with products';
    END IF;
END //

-- Read-only records
CREATE TRIGGER prevent_admin_user_deletion
BEFORE DELETE ON users
FOR EACH ROW
BEGIN
    IF OLD.role = 'admin' AND OLD.is_system = TRUE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete system admin users';
    END IF;
END //

DELIMITER ;

-- ============================================
-- MANAGING TRIGGERS
-- ============================================

-- Show all triggers
SHOW TRIGGERS;

-- Show triggers for specific table
SHOW TRIGGERS WHERE `Table` = 'customers';

-- Show trigger definition
SHOW CREATE TRIGGER trigger_name;

-- Drop trigger
DROP TRIGGER IF EXISTS trigger_name;

-- List triggers from information_schema
SELECT 
    TRIGGER_NAME,
    EVENT_MANIPULATION,
    EVENT_OBJECT_TABLE,
    ACTION_TIMING,
    ACTION_STATEMENT
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'your_database';

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

-- Exercise 1: Timestamp Trigger
-- Create BEFORE INSERT and BEFORE UPDATE triggers for 'products' table
-- Auto-set created_at on INSERT, updated_at on UPDATE
-- YOUR CODE HERE:



-- Exercise 2: Email Normalization
-- Create BEFORE INSERT trigger on 'users' table
-- Normalize email to lowercase and trim whitespace
-- YOUR CODE HERE:



-- Exercise 3: Price Change Logger
-- Create AFTER UPDATE trigger on 'products' table
-- Log price changes to 'price_history' table
-- Only log when price actually changes
-- YOUR CODE HERE:



-- Exercise 4: Order Status Validation
-- Create BEFORE UPDATE trigger on 'orders' table
-- Prevent status changes from 'shipped' back to 'pending'
-- Prevent status from 'cancelled' to any other status
-- YOUR CODE HERE:



-- Exercise 5: Automatic Category Counter
-- Create triggers to maintain a 'product_count' in categories table
-- Update count on product INSERT, UPDATE (category change), DELETE
-- YOUR CODE HERE:



-- Exercise 6: Audit Trail
-- Create complete audit trail for 'customers' table
-- Log INSERT, UPDATE, DELETE to 'customer_audit' table
-- Include old values, new values, timestamp, and user
-- YOUR CODE HERE:



-- Exercise 7: Stock Alert
-- Create AFTER UPDATE trigger on 'products' table
-- Insert alert into 'stock_alerts' when stock falls below reorder_level
-- YOUR CODE HERE:



-- ============================================
-- NOTES
-- ============================================

/*
TRIGGER BEST PRACTICES:

1. Naming Conventions
   - Descriptive: before_customer_insert, audit_order_update
   - Pattern: {timing}_{table}_{action}
   - Or: {action}_{table}_{purpose}

2. Keep Triggers Simple
   - Simple logic only
   - Avoid complex calculations
   - Don't call multiple tables unless necessary
   - Avoid trigger chains (trigger calling trigger)

3. Performance
   - Triggers execute for EVERY row
   - Keep them fast
   - Avoid heavy queries
   - Index columns used in trigger queries

4. Error Handling
   - Use SIGNAL for validation errors
   - Provide clear error messages
   - Consider transaction impact

5. Documentation
   - Comment trigger purpose
   - Document business rules
   - Note side effects
   - Explain non-obvious logic

6. Testing
   - Test INSERT, UPDATE, DELETE
   - Test with NULL values
   - Test with edge cases
   - Test performance with large batches

WHEN TO USE TRIGGERS:

✅ Use Triggers For:
- Audit trails (who, what, when)
- Automatic timestamps
- Data validation
- Maintaining derived columns
- Enforcing complex constraints
- Preventing invalid operations
- Cascading soft deletes

❌ Avoid Triggers For:
- Complex business logic (use procedures)
- Heavy calculations
- External API calls
- Application-level logic
- Anything that could be in application code

TRIGGER LIMITATIONS:

- MySQL: Cannot modify same table that fired trigger
- Performance impact on INSERT/UPDATE/DELETE
- Debugging is harder than application code
- Can create "hidden" business logic
- Trigger chains can be confusing
- Cannot return result sets (in most DBs)

COMMON MISTAKES:

1. Modifying NEW in AFTER triggers (won't work)
2. Referencing NEW in DELETE triggers
3. Referencing OLD in INSERT triggers
4. Infinite trigger loops
5. Not considering NULL values
6. Forgetting transaction context
7. Over-using triggers for application logic

TRIGGER TIMING:

BEFORE:
- Modify NEW values
- Validation
- Setting defaults
- Preventing operation (SIGNAL error)

AFTER:
- Audit logging
- Updating other tables
- Cascading operations
- Cannot modify NEW values

OLD vs NEW:

INSERT:
- NEW available (the new row)
- OLD not available

UPDATE:
- NEW available (updated values)
- OLD available (original values)

DELETE:
- OLD available (the deleted row)
- NEW not available

PERFORMANCE CONSIDERATIONS:

1. Triggers execute for EACH row
2.  Keep logic minimal
3. Batch operations can be slow with triggers
4. Consider disabling triggers for bulk imports
5. Index columns used in trigger WHERE clauses
6. Monitor trigger execution time

ALTERNATIVES TO TRIGGERS:

- Application code (more visible, easier to debug)
- Stored procedures (can be called explicitly)
- CHECK constraints (for validation)
- Foreign keys with CASCADE (for relationships)
- Database events (scheduled tasks)
- Change Data Capture (CDC) for auditing

DEBUGGING TRIGGERS:

1. Check trigger existence: SHOW TRIGGERS
2. Check trigger definition: SHOW CREATE TRIGGER
3. Test with SELECT before implementing
4. Use temporary tables for debugging output
5. Add logging to audit tables
6. Test in development first
7. Monitor slow query log

SECURITY:

- Triggers run with definer privileges
- Be careful with SECURITY DEFINER
- Validate all inputs
- Prevent SQL injection in dynamic SQL
- Don't expose sensitive data in error messages
*/
