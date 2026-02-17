# Database Design Best Practices

## General Principles

### 1. Plan Before You Code
- **Understand Requirements** - Talk to stakeholders and users
- **Model First** - Create ERDs before writing SQL
- **Iterate Design** - Refine through feedback
- **Document Decisions** - Record why you made specific choices

### 2. Follow Naming Conventions
```sql
-- Use consistent, descriptive names

-- Tables: plural or singular (pick one and stick to it)
customers       -- ✓ Good
customer        -- ✓ Also acceptable
tbl_customers   -- ✗ Avoid prefixes

-- Columns: descriptive, lowercase with underscores
customer_id     -- ✓ Good
first_name      -- ✓ Good
customerID      -- ✗ Inconsistent casing
fn              -- ✗ Too cryptic

-- Foreign keys: reference the related table
customer_id     -- ✓ Clear relationship
fk_customer     -- ~ Acceptable but redundant
c_id            -- ✗ Ambiguous
```

**Convention Guidelines:**
- Use lowercase with underscores (snake_case)
- Be descriptive but concise
- Avoid reserved words (user → users or app_user)
- Use singular for table names or plural consistently
- Foreign keys should match referenced column names

### 3. Choose Appropriate Data Types

```sql
-- String lengths
email VARCHAR(100)      -- ✓ Reasonable max
name VARCHAR(255)       -- ✓ Standard for names
description TEXT        -- ✓ For long text
status CHAR(1)          -- ✓ Fixed length

-- Numeric
age TINYINT            -- ✓ 0-255, saves space
price DECIMAL(10,2)    -- ✓ Exact for money
quantity INT           -- ✓ Standard integer
id BIGINT              -- ✓ For very large tables

-- Date/Time
created_at TIMESTAMP   -- ✓ Auto-updating
birth_date DATE        -- ✓ Date only
start_time TIME        -- ✓ Time only

-- Boolean
is_active BOOLEAN      -- ✓ Clear intent
active TINYINT(1)      -- ~ Works but less clear
```

**Guidelines:**
- Use the smallest data type that fits your needs
- Use DECIMAL for money (never FLOAT)
- Use TIMESTAMP for audit trails
- Use ENUM for fixed small sets of values
- Consider future growth but don't over-allocate

---

## Schema Design

### 4. Normalize Appropriately

**Follow normalization rules (usually to 3NF):**

```sql
-- ✗ BAD: Unnormalized
CREATE TABLE orders (
    order_id INT,
    customer_name VARCHAR(100),
    customer_email VARCHAR(100),  -- Redundant customer data
    product_names TEXT,            -- Multiple products in one field
    ...
);

-- ✓ GOOD: Normalized
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id)
);
```

**When to denormalize:**
- Proven performance requirements
- Read-heavy, write-light scenarios
- Data warehousing / reporting
- Acceptable data redundancy

### 5. Use Primary Keys Wisely

```sql
-- ✓ GOOD: Auto-incrementing surrogate key
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    ...
);

-- ✓ GOOD: Natural key when appropriate
CREATE TABLE countries (
    country_code CHAR(2) PRIMARY KEY,  -- ISO code
    country_name VARCHAR(100)
);

-- ✓ GOOD: Composite key for junction tables
CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    PRIMARY KEY (student_id, course_id)
);

-- ✗ AVOID: Using business data as PK when it might change
CREATE TABLE users (
    email VARCHAR(100) PRIMARY KEY,  -- What if they change email?
    ...
);
```

**Guidelines:**
- Use surrogate keys (auto-increment) for most tables
- Natural keys are OK for reference/lookup tables
- Never use sensitive or changeable data as PK
- Consider UUIDs for distributed systems

### 6. Implement Foreign Keys

```sql
-- ✓ ALWAYS define foreign key constraints
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE RESTRICT      -- Prevent deletion of referenced customers
        ON UPDATE CASCADE       -- Update order if customer_id changes
);
```

**ON DELETE options:**
- `RESTRICT` / `NO ACTION` - Prevent deletion (safest)
- `CASCADE` - Delete related records (use carefully!)
- `SET NULL` - Set FK to NULL (for optional relationships)
- `SET DEFAULT` - Set to default value

**Guidelines:**
- Always use FK constraints for referential integrity
- Choose appropriate ON DELETE behavior
- Index foreign key columns for performance

### 7. Handle NULL Values Carefully

```sql
-- Define what's required vs optional
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    email VARCHAR(100) NOT NULL,        -- Required
    phone VARCHAR(20),                   -- Optional (NULL allowed)
    middle_name VARCHAR(50),             -- Optional
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Watch out for NULL in queries
-- This won't find customers without phone numbers:
SELECT * FROM customers WHERE phone != '555-1234';

-- Use IS NULL explicitly:
SELECT * FROM customers WHERE phone IS NULL;
```

**Guidelines:**
- Make required fields NOT NULL
- Use DEFAULT values where appropriate
- Be explicit about NULL handling in queries
- Remember: NULL != NULL in SQL

---

## Performance Optimization

### 8. Index Strategically

```sql
-- ✓ Index foreign keys
CREATE INDEX idx_orders_customer ON orders(customer_id);

-- ✓ Index frequently searched columns
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_products_name ON products(product_name);

-- ✓ Composite indexes for common query combinations
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

-- ✗ Don't over-index
-- Each index speeds reads but slows writes
-- Index only what you actually query
```

**What to index:**
- Primary keys (automatic)
- Foreign keys
- Columns in WHERE clauses
- Columns in JOIN conditions
- Columns in ORDER BY
- Columns in GROUP BY

**What NOT to index:**
- Small tables (< 1000 rows)
- Columns rarely queried
- Columns with low cardinality (e.g., boolean)
- Tables with heavy write operations

### 9. Use Appropriate Constraints

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,           -- Unique constraint
    price DECIMAL(10,2) CHECK (price >= 0),    -- Check constraint
    stock INT CHECK (stock >= 0),
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Constraint names for clarity
ALTER TABLE orders 
ADD CONSTRAINT chk_order_total 
CHECK (total_amount >= 0);

ALTER TABLE users
ADD CONSTRAINT unique_email
UNIQUE (email);
```

**Types of constraints:**
- `PRIMARY KEY` - Unique identifier
- `FOREIGN KEY` - Referential integrity
- `UNIQUE` - Prevent duplicates
- `NOT NULL` - Require value
- `CHECK` - Validate data
- `DEFAULT` - Default value

---

## Data Integrity

### 10. Implement Audit Trails

```sql
-- Add timestamp columns
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    ...
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT
);

-- Consider soft deletes for important data
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    ...
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP NULL,
    deleted_by INT
);
```

### 11. Use Transactions

```sql
-- ✓ Group related operations
START TRANSACTION;

INSERT INTO orders (customer_id, total) VALUES (1, 100);
SET @order_id = LAST_INSERT_ID();

INSERT INTO order_items (order_id, product_id, quantity)
VALUES (@order_id, 5, 2);

UPDATE products SET stock = stock - 2 WHERE product_id = 5;

COMMIT;  -- All or nothing
```

### 12. Validate Data

```sql
-- At database level
CREATE TABLE users (
    email VARCHAR(100) CHECK (email LIKE '%@%'),
    age INT CHECK (age >= 0 AND age <= 150),
    status ENUM('active', 'inactive', 'pending')
);

-- At application level
-- - Validate format (email, phone, etc.)
-- - Sanitize inputs
-- - Use parameterized queries (prevent SQL injection)
```

---

## Security

### 13. Protect Sensitive Data

```sql
-- Never store passwords in plain text
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50),
    password_hash VARCHAR(255),  -- Hashed, not plain text
    salt VARCHAR(255),
    ...
);

-- Separate sensitive data
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    email VARCHAR(100),
    ...
);

CREATE TABLE payment_methods (
    payment_id INT PRIMARY KEY,
    customer_id INT,
    card_last_four CHAR(4),  -- Only store last 4 digits
    expiry_month INT,
    -- Never store full card numbers in database
);
```

### 14. Use Least Privilege

```sql
-- Create specific users with limited permissions
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'password';

-- Grant only necessary permissions
GRANT SELECT, INSERT, UPDATE ON database.* TO 'app_user'@'localhost';

-- Read-only user for reports
GRANT SELECT ON database.* TO 'report_user'@'localhost';

-- Avoid using root/admin accounts in applications
```

---

## Documentation

### 15. Comment Your Schema

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY COMMENT 'Unique product identifier',
    sku VARCHAR(50) COMMENT 'Stock keeping unit - unique per product',
    price DECIMAL(10,2) COMMENT 'Current selling price in USD',
    ...
) COMMENT='Product catalog - main inventory table';

-- Add meaningful comments
ALTER TABLE orders ADD COLUMN notes TEXT 
COMMENT 'Internal notes, not visible to customer';
```

### 16. Maintain Documentation

- Keep ERDs up to date
- Document business rules
- Explain complex constraints
- Record migration history
- Document reasons for design decisions

---

## Common Pitfalls to Avoid

### ❌ Don't Do This:

1. **Using SELECT * in production code**
   ```sql
   SELECT * FROM large_table;  -- ✗ Retrieves unnecessary data
   ```

2. **No WHERE clause in UPDATE/DELETE**
   ```sql
   DELETE FROM customers;  -- ✗ Deletes everything!
   ```

3. **Storing calculated values**
   ```sql
   CREATE TABLE orders (
       subtotal DECIMAL(10,2),
       tax DECIMAL(10,2),
       total DECIMAL(10,2)  -- ✗ Calculated, can get out of sync
   );
   ```

4. **Using VARCHAR(MAX) everywhere**
   ```sql
   name VARCHAR(10000)  -- ✗ Wastes space
   ```

5. **Ignoring indexes**
   ```sql
   -- ✗ No indexes on commonly queried columns
   CREATE TABLE orders (customer_id INT, order_date DATE);
   SELECT * FROM orders WHERE customer_id = 123;  -- Slow!
   ```

6. **Circular references**
   ```sql
   -- ✗ Can cause issues
   CREATE TABLE a (a_id INT, b_id INT, FOREIGN KEY (b_id) REFERENCES b(b_id));
   CREATE TABLE b (b_id INT, a_id INT, FOREIGN KEY (a_id) REFERENCES a(a_id));
   ```

---

## Checklist for New Tables

- [ ] Meaningful table and column names
- [ ] Primary key defined
- [ ] Appropriate data types
- [ ] NOT NULL on required fields
- [ ] Foreign keys with ON DELETE/UPDATE rules
- [ ] Unique constraints where needed
- [ ] Check constraints for validation
- [ ] Indexes on foreign keys and search columns
- [ ] Created_at / Updated_at timestamps
- [ ] Comments for clarity
- [ ] Reviewed for normalization
- [ ] Security considerations addressed

---

## Resources

- [Notes on Normalization](../fundamentals/normalization.md)
- [Entity-Relationship Diagrams](../fundamentals/entity-relationship-diagrams.md)
- [SQL Cheat Sheet](sql-cheatsheet.md)
- [Sample Schemas](../../projects/sample-schemas/)

---

**Remember:** Good database design is an investment. Spend time planning to save time debugging!
