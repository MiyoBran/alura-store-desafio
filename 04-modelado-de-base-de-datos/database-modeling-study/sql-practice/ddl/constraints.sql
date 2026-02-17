-- CONSTRAINTS - DDL Practice
-- Adding, modifying, and removing constraints for data integrity

-- ============================================
-- PRIMARY KEY CONSTRAINTS
-- ============================================

-- Add PRIMARY KEY during table creation
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

-- Add PRIMARY KEY with custom name
CREATE TABLE employees (
    employee_id INT,
    first_name VARCHAR(50),
    CONSTRAINT pk_employees PRIMARY KEY (employee_id)
);

-- Composite PRIMARY KEY
CREATE TABLE course_enrollments (
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    PRIMARY KEY (student_id, course_id)
);

-- Add PRIMARY KEY to existing table
ALTER TABLE categories
ADD PRIMARY KEY (category_id);

-- Add PRIMARY KEY with custom name
ALTER TABLE products
ADD CONSTRAINT pk_products PRIMARY KEY (product_id);

-- Drop PRIMARY KEY
ALTER TABLE temp_table
DROP PRIMARY KEY;

-- ============================================
-- FOREIGN KEY CONSTRAINTS
-- ============================================

-- Basic FOREIGN KEY
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- FOREIGN KEY with custom name
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    CONSTRAINT fk_order_items_orders
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    CONSTRAINT fk_order_items_products
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- FOREIGN KEY with ON DELETE/UPDATE actions
CREATE TABLE comments (
    comment_id INT PRIMARY KEY,
    post_id INT,
    user_id INT,
    CONSTRAINT fk_comments_posts
        FOREIGN KEY (post_id)
        REFERENCES posts(post_id)
        ON DELETE CASCADE        -- Delete comments when post is deleted
        ON UPDATE CASCADE,       -- Update if post_id changes
    CONSTRAINT fk_comments_users
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE SET NULL       -- Set to NULL if user is deleted
);

-- Add FOREIGN KEY to existing table
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Drop FOREIGN KEY
ALTER TABLE orders
DROP FOREIGN KEY fk_orders_customers;

-- Composite FOREIGN KEY
CREATE TABLE order_shipments (
    shipment_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    FOREIGN KEY (order_id, product_id)
        REFERENCES order_items(order_id, product_id)
);

-- ============================================
-- UNIQUE CONSTRAINTS
-- ============================================

-- UNIQUE constraint on single column
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE
);

-- UNIQUE constraint with custom name
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    sku VARCHAR(50),
    CONSTRAINT unique_product_sku UNIQUE (sku)
);

-- Composite UNIQUE constraint
CREATE TABLE product_reviews (
    review_id INT PRIMARY KEY,
    product_id INT,
    user_id INT,
    CONSTRAINT unique_user_product_review
        UNIQUE (product_id, user_id)  -- User can review product only once
);

-- Add UNIQUE constraint to existing table
ALTER TABLE customers
ADD CONSTRAINT unique_customer_email UNIQUE (email);

-- Add composite UNIQUE constraint
ALTER TABLE enrollments
ADD CONSTRAINT unique_student_course
    UNIQUE (student_id, course_id);

-- Drop UNIQUE constraint
ALTER TABLE customers
DROP INDEX unique_customer_email;

-- ============================================
-- CHECK CONSTRAINTS
-- ============================================

-- Simple CHECK constraint
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    price DECIMAL(10,2),
    stock_quantity INT,
    CHECK (price >= 0),
    CHECK (stock_quantity >= 0)
);

-- CHECK constraint with custom name
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    salary DECIMAL(10,2),
    hire_date DATE,
    CONSTRAINT chk_positive_salary CHECK (salary > 0),
    CONSTRAINT chk_valid_hire_date CHECK (hire_date <= CURDATE())
);

-- CHECK constraint with multiple conditions
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    shipped_date DATE,
    status VARCHAR(20),
    CONSTRAINT chk_order_status
        CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
    CONSTRAINT chk_shipping_after_order
        CHECK (shipped_date IS NULL OR shipped_date >= order_date)
);

-- CHECK with complex logic
CREATE TABLE discounts (
    discount_id INT PRIMARY KEY,
    discount_type VARCHAR(20),
    discount_value DECIMAL(10,2),
    CONSTRAINT chk_discount_logic CHECK (
        (discount_type = 'percentage' AND discount_value BETWEEN 0 AND 100)
        OR
        (discount_type = 'fixed' AND discount_value >= 0)
    )
);

-- Add CHECK constraint to existing table
ALTER TABLE products
ADD CONSTRAINT chk_price_range
    CHECK (price BETWEEN 0 AND 999999.99);

-- Drop CHECK constraint (MySQL 8.0.16+)
ALTER TABLE products
DROP CHECK chk_price_range;

-- ============================================
-- NOT NULL CONSTRAINTS
-- ============================================

-- NOT NULL during table creation
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20)  -- nullable
);

-- Add NOT NULL to existing column
ALTER TABLE customers
MODIFY COLUMN

 email VARCHAR(100) NOT NULL;

-- Remove NOT NULL (make column nullable)
ALTER TABLE customers
MODIFY COLUMN phone VARCHAR(20) NULL;

-- ============================================
-- DEFAULT CONSTRAINTS
-- ============================================

-- DEFAULT values during table creation
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending',
    is_paid BOOLEAN DEFAULT FALSE,
    quantity INT DEFAULT 1
);

-- DEFAULT with expressions
CREATE TABLE audit_log (
    log_id INT PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Add DEFAULT to existing column
ALTER TABLE products
ALTER stock_quantity SET DEFAULT 0;

-- Remove DEFAULT
ALTER TABLE products
ALTER stock_quantity DROP DEFAULT;

-- ============================================
-- AUTO_INCREMENT / IDENTITY
-- ============================================

-- AUTO_INCREMENT (MySQL)
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100)
);

-- SERIAL (PostgreSQL shorthand)
-- CREATE TABLE customers (
--     customer_id SERIAL PRIMARY KEY,
--     name VARCHAR(100)
-- );

-- IDENTITY (SQL Server)
-- CREATE TABLE customers (
--     customer_id INT IDENTITY(1,1) PRIMARY KEY,
--     name VARCHAR(100)
-- );

-- Modify AUTO_INCREMENT starting value
ALTER TABLE customers AUTO_INCREMENT = 1000;

-- ============================================
-- PRACTICAL CONSTRAINT COMBINATIONS
-- ============================================

-- Example 1: Complete user table with all constraint types
CREATE TABLE users (
    user_id INT AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    age INT,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT pk_users PRIMARY KEY (user_id),
    CONSTRAINT unique_username UNIQUE (username),
    CONSTRAINT unique_email UNIQUE (email),
    CONSTRAINT chk_age CHECK (age >= 13 AND age <= 120),
    CONSTRAINT chk_status CHECK (status IN ('active', 'inactive', 'suspended'))
);

-- Example 2: Order system with referential integrity
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    
    CONSTRAINT fk_orders_customers
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_total_positive CHECK (total_amount >= 0),
    CONSTRAINT chk_order_status
        CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    
    CONSTRAINT fk_order_items_orders
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,
    CONSTRAINT unique_order_product UNIQUE (order_id, product_id),
    CONSTRAINT chk_quantity_positive CHECK (quantity > 0),
    CONSTRAINT chk_price_positive CHECK (unit_price >= 0)
);

-- Example 3: Self-referencing with constraints
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    manager_id INT,
    salary DECIMAL(10,2),
    hire_date DATE NOT NULL,
    
    CONSTRAINT fk_employees_manager
        FOREIGN KEY (manager_id)
        REFERENCES employees(employee_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_salary_positive CHECK (salary > 0),
    CONSTRAINT chk_hire_date CHECK (hire_date <= CURDATE())
);

-- ============================================
-- VIEWING EXISTING CONSTRAINTS
-- ============================================

-- Show table structure with constraints
DESCRIBE table_name;
SHOW CREATE TABLE table_name;

-- Show all constraints for a table (MySQL)
SELECT 
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    TABLE_NAME
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'your_database'
  AND TABLE_NAME = 'your_table';

-- Show foreign key relationships
SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'your_database'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Show CHECK constraints (MySQL 8.0.16+)
SELECT 
    CONSTRAINT_NAME,
    CHECK_CLAUSE
FROM information_schema.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'your_database';

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

-- Exercise 1: Create a table with all constraint types
-- Create a 'products' table with:
-- - Auto-increment PK
-- - NOT NULL name and price
-- - UNIQUE sku
-- - CHECK price > 0
-- - CHECK stock >= 0
-- - DEFAULT stock = 0
-- YOUR CODE HERE:



-- Exercise 2: Add constraints to existing table
-- Given a table 'orders', add:
-- - Foreign key to customers table
-- - CHECK that total_amount >= 0
-- - DEFAULT status = 'pending'
-- - UNIQUE constraint on order_number
-- YOUR CODE HERE:



-- Exercise 3: Create tables with relationships
-- Create: categories, products, product_categories (many-to-many)
-- Include all appropriate constraints
-- YOUR CODE HERE:



-- Exercise 4: Implement soft delete pattern
-- Modify users table to support soft deletes:
-- - Add is_deleted column (default FALSE)
-- - Add deleted_at column (nullable)
-- - Add CHECK: if is_deleted=TRUE, deleted_at must be NOT NULL
-- YOUR CODE HERE:



-- Exercise 5: Fix constraint violations
-- Given tables with orphaned records, write SQL to:
-- 1. Find orphaned order_items (product_id not in products)
-- 2. Delete or fix them
-- 3. Then add the foreign key constraint
-- YOUR CODE HERE:



-- ============================================
-- NOTES
-- ============================================

/*
CONSTRAINT TYPES SUMMARY:

1. PRIMARY KEY
   - Uniquely identifies each row
   - Cannot be NULL
   - Only one per table
   - Automatically creates index

2. FOREIGN KEY
   - Links to another table's PK
   - Enforces referential integrity
   - ON DELETE/UPDATE actions:
     * CASCADE - propagate changes
     * RESTRICT - prevent if referenced
     * SET NULL - set to NULL
     * NO ACTION - similar to RESTRICT

3. UNIQUE
   - Ensures column values are unique
   - Can have multiple per table
   - NULL allowed (unless also NOT NULL)
   - Creates index automatically

4. CHECK
   - Validates data based on condition
   - Can reference multiple columns
   - MySQL 8.0.16+ required

5. NOT NULL
   - Column must have a value
   - Cannot insert/update to NULL

6. DEFAULT
   - Provides default value
   - Used when no value specified
   - Can be expression or literal

BEST PRACTICES:

1. Name constraints explicitly
   - pk_table_name
   - fk_table1_table2
   - unique_table_column
   - chk_table_description

2. Add constraints during table creation when possible

3. For existing tables:
   - Clean data first
   - Then add constraints

4. Use appropriate ON DELETE/UPDATE actions
   - CASCADE for dependent data
   - RESTRICT for preventing orphans
   - SET NULL for optional relationships

5. Document constraint logic in comments

COMMON ERRORS:

1. Cannot add FK - orphaned records exist
   Solution: Clean orphaned records first

2. Cannot add NOT NULL - NULL values exist
   Solution: Update NULLs first

3. Cannot add CHECK - existing data violates
   Solution: Fix data then add constraint

4. Cannot insert - FK violation
   Solution: Ensure parent record exists

PERFORMANCE NOTES:

- Constraints validated on INSERT/UPDATE
- Foreign keys require indexes (usually auto-created)
- CHECK constraints add validation overhead
- UNIQUE constraints create indexes
- Consider batch operations with disabled constraints
  (be very careful!)
*/
