-- CREATE TABLES - DDL Practice
-- Data Definition Language: Creating database structures

-- ============================================
-- BASIC TABLE CREATION
-- ============================================

-- Simple table with basic data types
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- AUTO-INCREMENT PRIMARY KEY
-- ============================================

-- Using AUTO_INCREMENT (MySQL) or SERIAL (PostgreSQL)
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,  -- MySQL
    -- product_id SERIAL PRIMARY KEY,           -- PostgreSQL
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- FOREIGN KEY CONSTRAINTS
-- ============================================

-- Table with foreign key reference
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2),
    status VARCHAR(20) DEFAULT 'pending',
    
    -- Foreign key constraint
    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ============================================
-- COMPOSITE PRIMARY KEY
-- ============================================

-- Junction table with composite key
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    
    -- Composite primary key
    PRIMARY KEY (order_id, product_id),
    
    -- Foreign keys
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE RESTRICT
);

-- ============================================
-- UNIQUE CONSTRAINTS
-- ============================================

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CHECK CONSTRAINTS
-- ============================================

CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    salary DECIMAL(10, 2),
    hire_date DATE NOT NULL,
    
    -- Check constraints
    CONSTRAINT chk_salary CHECK (salary > 0),
    CONSTRAINT chk_email CHECK (email LIKE '%@%')
);

-- ============================================
-- ENUMERATED TYPES
-- ============================================

CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    status ENUM('draft', 'sent', 'paid', 'overdue', 'cancelled') DEFAULT 'draft',
    total_amount DECIMAL(10, 2) NOT NULL,
    
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT chk_due_date CHECK (due_date >= invoice_date)
);

-- ============================================
-- SELF-REFERENCING TABLE
-- ============================================

-- Employees with manager relationship
CREATE TABLE org_employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    manager_id INT,
    department VARCHAR(50),
    
    -- Self-referencing foreign key
    FOREIGN KEY (manager_id) 
        REFERENCES org_employees(employee_id)
        ON DELETE SET NULL
);

-- ============================================
-- MULTIPLE FOREIGN KEYS
-- ============================================

CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
        
    -- Constraints
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT unique_user_product UNIQUE (product_id, user_id)
);

-- ============================================
-- TEMPORAL TABLES (Audit/History)
-- ============================================

CREATE TABLE product_price_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    old_price DECIMAL(10, 2),
    new_price DECIMAL(10, 2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(50),
    
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

-- Exercise 1: Create a Categories table
-- - category_id (PK, auto-increment)
-- - category_name (unique, not null)
-- - parent_category_id (FK to self, for subcategories)
-- - description

-- YOUR CODE HERE:



-- Exercise 2: Create a ProductCategories junction table
-- - product_id (FK to products)
-- - category_id (FK to categories)
-- - Composite PK on both columns

-- YOUR CODE HERE:



-- Exercise 3: Create an Addresses table
-- - address_id (PK)
-- - customer_id (FK to customers)
-- - street_address
-- - city
-- - state
-- - postal_code
-- - country
-- - is_default (boolean)

-- YOUR CODE HERE:



-- ============================================
-- NOTES
-- ============================================

/*
KEY CONCEPTS:
1. Primary Key: Unique identifier for each row
2. Foreign Key: References primary key in another table
3. NOT NULL: Column cannot contain NULL values
4. UNIQUE: All values must be unique
5. DEFAULT: Default value if none provided
6. CHECK: Validates data before insertion
7. AUTO_INCREMENT/SERIAL: Automatically generates sequential numbers

CASCADE OPTIONS:
- ON DELETE CASCADE: Delete related rows
- ON DELETE SET NULL: Set FK to NULL
- ON DELETE RESTRICT: Prevent deletion
- ON UPDATE CASCADE: Update related rows

BEST PRACTICES:
- Use meaningful table and column names
- Always define primary keys
- Add foreign keys for referential integrity
- Use appropriate data types
- Add comments for complex logic
- Consider indexing frequently queried columns
*/
