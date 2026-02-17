-- ALTER TABLES - DDL Practice
-- Data Definition Language: Modifying existing database structures

-- ============================================
-- ADD COLUMN
-- ============================================

-- Add single column
ALTER TABLE customers 
ADD phone VARCHAR(20);

-- Add column with constraint
ALTER TABLE customers
ADD date_of_birth DATE NOT NULL DEFAULT '1900-01-01';

-- Add column with CHECK constraint
ALTER TABLE products
ADD discount_percentage DECIMAL(5,2) CHECK (discount_percentage BETWEEN 0 AND 100);

-- Add multiple columns
ALTER TABLE orders
ADD (
    shipped_date TIMESTAMP NULL,
    tracking_number VARCHAR(100),
    carrier VARCHAR(50)
);

-- ============================================
-- MODIFY/CHANGE COLUMN
-- ============================================

-- Change data type (MySQL)
ALTER TABLE customers
MODIFY COLUMN phone VARCHAR(30);

-- Change column with constraints (MySQL)
ALTER TABLE products
MODIFY COLUMN price DECIMAL(12,2) NOT NULL;

-- Rename and change type (MySQL)
ALTER TABLE customers
CHANGE COLUMN phone phone_number VARCHAR(30);

-- PostgreSQL syntax for modifying column
-- ALTER TABLE customers
-- ALTER COLUMN phone TYPE VARCHAR(30);

-- Make column NOT NULL
ALTER TABLE customers
MODIFY COLUMN email VARCHAR(100) NOT NULL;

-- Set default value
ALTER TABLE products
ALTER stock_quantity SET DEFAULT 0;

-- Remove default value
ALTER TABLE products
ALTER stock_quantity DROP DEFAULT;

-- ============================================
-- DROP COLUMN
-- ============================================

-- Drop single column
ALTER TABLE customers
DROP COLUMN middle_name;

-- Drop multiple columns (MySQL)
ALTER TABLE orders
DROP COLUMN notes,
DROP COLUMN internal_id;

-- ============================================
-- RENAME TABLE/COLUMN
-- ============================================

-- Rename table (MySQL)
RENAME TABLE old_customers TO customers_archive;

-- Rename table (alternative syntax)
ALTER TABLE customers RENAME TO app_customers;

-- Rename column (MySQL 8.0+)
ALTER TABLE customers
RENAME COLUMN old_name TO new_name;

-- ============================================
-- ADD CONSTRAINTS
-- ============================================

-- Add primary key
ALTER TABLE categories
ADD PRIMARY KEY (category_id);

-- Add foreign key
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Add foreign key with custom name
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_products
    FOREIGN KEY (product_id)
    REFERENCES products(product_id)
    ON DELETE CASCADE;

-- Add UNIQUE constraint
ALTER TABLE customers
ADD CONSTRAINT unique_email UNIQUE (email);

-- Add composite UNIQUE constraint
ALTER TABLE order_items
ADD CONSTRAINT unique_order_product
    UNIQUE (order_id, product_id);

-- Add CHECK constraint
ALTER TABLE products
ADD CONSTRAINT chk_price_positive
    CHECK (price >= 0);

-- Add CHECK constraint with multiple conditions
ALTER TABLE orders
ADD CONSTRAINT chk_order_dates
    CHECK (shipped_date IS NULL OR shipped_date >= order_date);

-- ============================================
-- DROP CONSTRAINTS
-- ============================================

-- Drop foreign key
ALTER TABLE orders
DROP FOREIGN KEY fk_orders_customers;

-- Drop primary key
ALTER TABLE temp_table
DROP PRIMARY KEY;

-- Drop UNIQUE constraint
ALTER TABLE customers
DROP INDEX unique_email;

-- Drop CHECK constraint (MySQL 8.0.16+)
ALTER TABLE products
DROP CHECK chk_price_positive;

-- ============================================
-- ADD/DROP INDEXES
-- ============================================

-- Add index
ALTER TABLE customers
ADD INDEX idx_last_name (last_name);

-- Add composite index
ALTER TABLE orders
ADD INDEX idx_customer_date (customer_id, order_date);

-- Add unique index
ALTER TABLE products
ADD UNIQUE INDEX idx_sku (sku);

-- Drop index
ALTER TABLE customers
DROP INDEX idx_last_name;

-- ============================================
-- MODIFY TABLE PROPERTIES
-- ============================================

-- Change auto-increment value
ALTER TABLE customers
AUTO_INCREMENT = 1000;

-- Change table engine (MySQL)
ALTER TABLE customers
ENGINE = InnoDB;

-- Change character set
ALTER TABLE customers
CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Add table comment
ALTER TABLE customers
COMMENT = 'Customer information and contact details';

-- ============================================
-- PRACTICAL EXAMPLES
-- ============================================

-- Example 1: Adding audit columns to existing table
ALTER TABLE products
ADD created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD created_by INT,
ADD updated_by INT;

-- Example 2: Making email unique and required
ALTER TABLE users
MODIFY COLUMN email VARCHAR(100) NOT NULL,
ADD CONSTRAINT unique_user_email UNIQUE (email);

-- Example 3: Adding soft delete functionality
ALTER TABLE customers
ADD is_deleted BOOLEAN DEFAULT FALSE,
ADD deleted_at TIMESTAMP NULL,
ADD deleted_by INT NULL;

-- Example 4: Restructuring a table for better performance
-- Add new normalized foreign key column
ALTER TABLE orders
ADD customer_id INT;

-- Populate the new column
UPDATE orders o
JOIN customers c ON o.customer_email = c.email
SET o.customer_id = c.customer_id;

-- Make it NOT NULL after populating
ALTER TABLE orders
MODIFY COLUMN customer_id INT NOT NULL;

-- Add foreign key
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id);

-- Drop old denormalized column
ALTER TABLE orders
DROP COLUMN customer_email;

-- Example 5: Adding partitioning-ready columns
ALTER TABLE sales_data
ADD sale_year INT AS (YEAR(sale_date)) STORED,
ADD sale_month INT AS (MONTH(sale_date)) STORED;

-- ============================================
-- SAFE ALTER TABLE PRACTICES
-- ============================================

-- Always backup before altering!
-- CREATE TABLE customers_backup AS SELECT * FROM customers;

-- Check for dependencies before dropping columns
-- SELECT * FROM information_schema.KEY_COLUMN_USAGE
-- WHERE REFERENCED_TABLE_NAME = 'customers';

-- Test on a copy first for large tables
-- CREATE TABLE customers_test LIKE customers;
-- INSERT INTO customers_test SELECT * FROM customers LIMIT 1000;
-- ALTER TABLE customers_test ADD COLUMN test VARCHAR(50); -- test here first

-- Use transactions where supported (PostgreSQL, not MySQL for DDL)
-- BEGIN;
-- ALTER TABLE customers ADD COLUMN new_col VARCHAR(50);
-- -- verify changes
-- COMMIT; -- or ROLLBACK;

-- ============================================
-- HANDLING LARGE TABLES
-- ============================================

-- For very large tables, consider:

-- 1. Use pt-online-schema-change (Percona Toolkit) for MySQL
-- pt-online-schema-change --alter "ADD COLUMN new_col VARCHAR(50)" D=database,t=customers

-- 2. Use gh-ost (GitHub's online schema migration tool)
-- gh-ost --database=mydb --table=customers --alter="ADD COLUMN new_col VARCHAR(50)"

-- 3. Create new table and migrate (manual approach)
CREATE TABLE customers_new LIKE customers;

ALTER TABLE customers_new
ADD COLUMN new_column VARCHAR(50);

-- Insert data in batches
INSERT INTO customers_new 
SELECT *, NULL AS new_column
FROM customers
LIMIT 10000;

-- Eventually rename tables
RENAME TABLE customers TO customers_old, customers_new TO customers;

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

-- Exercise 1: Add audit trail columns to the products table
-- Add: created_at, updated_at, created_by, updated_by
-- YOUR CODE HERE:



-- Exercise 2: Modify the orders table
-- - Add shipping_cost column (DECIMAL(10,2), default 0)
-- - Add order_notes column (TEXT, nullable)
-- - Make total_amount NOT NULL
-- YOUR CODE HERE:



-- Exercise 3: Add constraints to ensure data integrity
-- - Email must be unique in users table
-- - Price must be positive in products table
-- - Order date must be before shipped date in orders table
-- YOUR CODE HERE:



-- Exercise 4: Restructure a table
-- - Add a status column with ENUM('active', 'inactive', 'pending')
-- - Set default to 'pending'
-- - Update existing rows to 'active'
-- - Then make it NOT NULL
-- YOUR CODE HERE:



-- Exercise 5: Create and add a foreign key
-- Assuming you have products and categories tables
-- - Add category_id to products if it doesn't exist
-- - Add foreign key constraint with CASCADE on update
-- YOUR CODE HERE:



-- ============================================
-- COMMON ISSUES AND SOLUTIONS
-- ============================================

/*
ISSUE 1: Cannot add NOT NULL column without default
ERROR: Cannot add NOT NULL column without a default value

SOLUTION:
-- Option A: Add with default
ALTER TABLE table ADD column VARCHAR(50) NOT NULL DEFAULT 'unknown';

-- Option B: Add as nullable, populate, then make NOT NULL
ALTER TABLE table ADD column VARCHAR(50);
UPDATE table SET column = 'value';
ALTER TABLE table MODIFY column VARCHAR(50) NOT NULL;

---

ISSUE 2: Foreign key constraint fails
ERROR: Cannot add foreign key constraint

SOLUTION:
-- Check for orphaned records
SELECT * FROM orders 
WHERE customer_id NOT IN (SELECT customer_id FROM customers);

-- Clean up orphaned records
DELETE FROM orders WHERE customer_id NOT IN (SELECT customer_id FROM customers);

-- Then add FK
ALTER TABLE orders ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

---

ISSUE 3: Cannot drop column used in index/constraint
ERROR: Cannot drop column because it is used in an index

SOLUTION:
-- Drop index first
ALTER TABLE table DROP INDEX index_name;
-- Then drop column
ALTER TABLE table DROP COLUMN column_name;

---

ISSUE 4: ALTER takes too long / locks table
SOLUTION:
-- Use online schema change tools
-- Or work during maintenance window
-- Or use pt-online-schema-change / gh-ost for MySQL
*/

-- ============================================
-- NOTES
-- ============================================

/*
KEY POINTS:

1. ALTER TABLE modifies existing table structure
2. Can add/drop columns, constraints, indexes
3. Can modify column properties
4. Some operations require table rebuild (slow on large tables)

SYNTAX DIFFERENCES:
- MySQL: MODIFY COLUMN, CHANGE COLUMN
- PostgreSQL: ALTER COLUMN ... TYPE, RENAME COLUMN
- SQL Server: ALTER COLUMN

IMPORTANT:
- ALWAYS backup before altering production tables
- Test on development environment first
- Consider downtime for large tables
- Some ALTER operations lock the table
- Use online schema change tools for large tables

BEST PRACTICES:
- Name constraints explicitly for easy management
- Add NOT NULL constraints carefully
- Use transactions where possible
- Document schema changes
- Plan migrations for production
- Consider application compatibility

PERFORMANCE:
- Adding columns is usually fast
- Changing column type may require table rebuild
- Adding indexes can be slow on large tables
- Use ALGORITHM=INPLACE when possible (MySQL)

HELPFUL QUERIES:
-- Show table structure
DESCRIBE table_name;
SHOW CREATE TABLE table_name;

-- Show indexes
SHOW INDEX FROM table_name;

-- Show constraints
SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'table_name';
*/
