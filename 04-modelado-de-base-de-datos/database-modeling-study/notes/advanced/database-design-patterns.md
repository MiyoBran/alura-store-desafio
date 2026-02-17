# Database Design Patterns

## Overview

Database design patterns are proven solutions to common data modeling challenges. Understanding these patterns helps you build scalable, maintainable, and efficient database systems.

---

## Table of Contents

1. [Star Schema](#star-schema)
2. [Snowflake Schema](#snowflake-schema)
3. [Temporal Tables](#temporal-tables)
4. [Soft Delete Pattern](#soft-delete-pattern)
5. [Audit Trail Pattern](#audit-trail-pattern)
6. [Entity-Attribute-Value (EAV)](#entity-attribute-value-eav)
7. [Polymorphic Associations](#polymorphic-associations)
8. [Adjacency List (Hierarchies)](#adjacency-list-hierarchies)
9. [Materialized Path](#materialized-path)
10. [Single Table Inheritance](#single-table-inheritance)
11. [Multi-Tenant Patterns](#multi-tenant-patterns)
12. [Event Sourcing](#event-sourcing)

---

## Star Schema

**Use Case:** Data warehousing, analytics, reporting

**Description:** Central fact table surrounded by dimension tables. Optimized for read-heavy analytics queries.

### Structure

```
       [Time Dimension]
              |
[Product Dim] - [Sales Fact] - [Customer Dim]
              |
       [Store Dimension]
```

### Example

```sql
-- Fact Table (measures/metrics)
CREATE TABLE sales_fact (
    sale_id INT PRIMARY KEY,
    date_key INT,
    product_key INT,
    customer_key INT,
    store_key INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    FOREIGN KEY (date_key) REFERENCES time_dimension(date_key),
    FOREIGN KEY (product_key) REFERENCES product_dimension(product_key),
    FOREIGN KEY (customer_key) REFERENCES customer_dimension(customer_key),
    FOREIGN KEY (store_key) REFERENCES store_dimension(store_key)
);

-- Dimension Tables (descriptive attributes)
CREATE TABLE product_dimension (
    product_key INT PRIMARY KEY,
    product_id VARCHAR(50),
    product_name VARCHAR(200),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100)
);

CREATE TABLE customer_dimension (
    customer_key INT PRIMARY KEY,
    customer_id VARCHAR(50),
    customer_name VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    customer_segment VARCHAR(50)
);

CREATE TABLE time_dimension (
    date_key INT PRIMARY KEY,
    date DATE,
    day_of_week VARCHAR(20),
    day_of_month INT,
    month INT,
    quarter INT,
    year INT,
    is_weekend BOOLEAN
);
```

### Use query

```sql
SELECT 
    t.year,
    t.quarter,
    p.category,
    c.country,
    SUM(s.total_amount) as total_sales,
    SUM(s.quantity) as units_sold,
    COUNT(DISTINCT s.customer_key) as unique_customers
FROM sales_fact s
JOIN time_dimension t ON s.date_key = t.date_key
JOIN product_dimension p ON s.product_key = p.product_key
JOIN customer_dimension c ON s.customer_key = c.customer_key
WHERE t.year = 2024
GROUP BY t.year, t.quarter, p.category, c.country;
```

**Pros:** Fast query performance, simple joins, easy to understand  
**Cons:** Data redundancy in dimensions, harder to maintain normalized data

---

## Snowflake Schema

**Use Case:** Normalized data warehousing when storage is a concern

**Description:** Extension of star schema where dimension tables are normalized into multiple related tables.

### Example

```sql
-- Normalized dimension tables
CREATE TABLE product_dimension (
    product_key INT PRIMARY KEY,
    product_id VARCHAR(50),
    product_name VARCHAR(200),
    subcategory_key INT,
    FOREIGN KEY (subcategory_key) REFERENCES subcategory_dimension(subcategory_key)
);

CREATE TABLE subcategory_dimension (
    subcategory_key INT PRIMARY KEY,
    subcategory_name VARCHAR(100),
    category_key INT,
    FOREIGN KEY (category_key) REFERENCES category_dimension(category_key)
);

CREATE TABLE category_dimension (
    category_key INT PRIMARY KEY,
    category_name VARCHAR(100)
);
```

**Pros:** Less storage (normalized), data integrity  
**Cons:** More complex queries, more joins, slower performance

---

## Temporal Tables

**Use Case:** Tracking historical changes, time-travel queries, auditing

**Description:** Store data with validity periods to track how data changes over time.

### Example: Effective Dating

```sql
CREATE TABLE employee_history (
    employee_id INT,
    version_id INT AUTO_INCREMENT,
    name VARCHAR(100),
    department VARCHAR(100),
    salary DECIMAL(10,2),
    valid_from DATE,
    valid_to DATE,
    is_current BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (employee_id, version_id),
    INDEX idx_current (employee_id, is_current),
    INDEX idx_date_range (employee_id, valid_from, valid_to)
);

-- Insert initial record
INSERT INTO employee_history (employee_id, name, department, salary, valid_from, valid_to, is_current)
VALUES (1, 'John Doe', 'Engineering', 75000, '2023-01-01', '9999-12-31', TRUE);

-- Update: close old record, insert new one
UPDATE employee_history
SET valid_to = '2024-06-30', is_current = FALSE
WHERE employee_id = 1 AND is_current = TRUE;

INSERT INTO employee_history (employee_id, name, department, salary, valid_from, valid_to, is_current)
VALUES (1, 'John Doe', 'Management', 95000, '2024-07-01', '9999-12-31', TRUE);

-- Query: What was John's salary on 2024-01-15?
SELECT salary
FROM employee_history
WHERE employee_id = 1
  AND '2024-01-15' BETWEEN valid_from AND valid_to;

-- Query: Get all changes for employee
SELECT *
FROM employee_history
WHERE employee_id = 1
ORDER BY valid_from;
```

### SQL Server Temporal Tables (Built-in)

```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    salary DECIMAL(10,2),
    valid_from DATETIME2 GENERATED ALWAYS AS ROW START,
    valid_to DATETIME2 GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (valid_from, valid_to)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.employees_history));

-- Query historical data
SELECT * FROM employees
FOR SYSTEM_TIME AS OF '2024-01-15'
WHERE employee_id = 1;
```

**Pros:** Complete history, time-travel queries, compliance  
**Cons:** More storage, complex updates, slower writes

---

## Soft Delete Pattern

**Use Case:** Recovering deleted data, audit requirements, preventing accidental deletions

**Description:** Mark records as deleted instead of physically removing them.

### Example

```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP NULL,
    deleted_by VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_active (is_deleted)
);

-- "Delete" customer
UPDATE customers
SET is_deleted = TRUE,
    deleted_at = NOW(),
    deleted_by = 'admin@example.com'
WHERE customer_id = 123;

-- Query active customers
SELECT * FROM customers WHERE is_deleted = FALSE;

-- Restore deleted customer
UPDATE customers
SET is_deleted = FALSE,
    deleted_at = NULL,
    deleted_by = NULL
WHERE customer_id = 123;

-- Permanent cleanup (after grace period)
DELETE FROM customers
WHERE is_deleted = TRUE
  AND deleted_at < DATE_SUB(NOW(), INTERVAL 90 DAY);
```

### Using with Views

```sql
CREATE VIEW active_customers AS
SELECT customer_id, name, email, created_at
FROM customers
WHERE is_deleted = FALSE;

-- Application queries active customers only
SELECT * FROM active_customers;
```

**Pros:** Data recovery, audit trail, safer than hard deletes  
**Cons:** Larger database, must remember to filter, unique constraint complications

---

## Audit Trail Pattern

**Use Case:** Compliance, security, debugging, user activity tracking

**Description:** Record who changed what and when.

### Example: Separate Audit Table

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(200),
    price DECIMAL(10,2),
    stock_quantity INT,
    updated_at TIMESTAMP NULL
);

CREATE TABLE product_audit (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    action VARCHAR(20),  -- INSERT, UPDATE, DELETE
    old_values JSON,
    new_values JSON,
    changed_by VARCHAR(100),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    INDEX idx_product (product_id),
    INDEX idx_date (changed_at)
);

-- Trigger to automatically log changes
DELIMITER //
CREATE TRIGGER audit_product_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    INSERT INTO product_audit (product_id, action, old_values, new_values, changed_by)
    VALUES (
        NEW.product_id,
        'UPDATE',
        JSON_OBJECT('name', OLD.product_name, 'price', OLD.price, 'stock', OLD.stock_quantity),
        JSON_OBJECT('name', NEW.product_name, 'price', NEW.price, 'stock', NEW.stock_quantity),
        USER()
    );
END //
DELIMITER ;

-- Query audit trail
SELECT 
    audit_id,
    action,
    old_values->>'$.price' as old_price,
    new_values->>'$.price' as new_price,
    changed_by,
    changed_at
FROM product_audit
WHERE product_id = 100
ORDER BY changed_at DESC;
```

**Pros:** Complete change history, compliance, debugging  
**Cons:** Storage overhead, performance impact on writes

---

## Entity-Attribute-Value (EAV)

**Use Case:** Highly dynamic attributes, sparse data, product catalogues with varying attributes

**Description:** Store attributes as rows instead of columns. Very flexible schema.

### Example

```sql
CREATE TABLE entities (
    entity_id INT PRIMARY KEY,
    entity_type VARCHAR(50)
);

CREATE TABLE attributes (
    attribute_id INT PRIMARY KEY,
    attribute_name VARCHAR(100),
    attribute_type VARCHAR(50)  -- string, number, date, boolean
);

CREATE TABLE entity_attributes (
    entity_id INT,
    attribute_id INT,
    value TEXT,
    PRIMARY KEY (entity_id, attribute_id),
    FOREIGN KEY (entity_id) REFERENCES entities(entity_id),
    FOREIGN KEY (attribute_id) REFERENCES attributes(attribute_id)
);

-- Add a product
INSERT INTO entities (entity_id, entity_type) VALUES (1, 'Laptop');

-- Define attributes
INSERT INTO attributes (attribute_id, attribute_name, attribute_type)
VALUES 
    (1, 'brand', 'string'),
    (2, 'ram_gb', 'number'),
    (3, 'screen_size', 'number'),
    (4, 'has_touchscreen', 'boolean');

-- Set entity attributes
INSERT INTO entity_attributes (entity_id, attribute_id, value)
VALUES 
    (1, 1, 'Dell'),
    (1, 2, '16'),
    (1, 3, '15.6'),
    (1, 4, 'true');

-- Query entity
SELECT 
    e.entity_id,
    a.attribute_name,
    ea.value
FROM entities e
JOIN entity_attributes ea ON e.entity_id = ea.entity_id
JOIN attributes a ON ea.attribute_id = a.attribute_id
WHERE e.entity_id = 1;
```

**Pros:** Extremely flexible, easy to add new attributes  
**Cons:** Complex queries, poor performance, difficult to enforce data types, no referential integrity

**Warning:** Use sparingly! Only when you truly need dynamic schema.

---

## Polymorphic Associations

**Use Case:** A table that can belong to multiple other tables

**Description:** One table references multiple parent tables.

### Example: Comments that can be on Posts or Events

```sql
CREATE TABLE posts (
    post_id INT PRIMARY KEY,
    title VARCHAR(200),
    content TEXT
);

CREATE TABLE events (
    event_id INT PRIMARY KEY,
    event_name VARCHAR(200),
    event_date DATE
);

CREATE TABLE comments (
    comment_id INT PRIMARY KEY,
    commentable_type VARCHAR(50),  -- 'post' or 'event'
    commentable_id INT,            -- ID in posts or events table
    comment_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_poly (commentable_type, commentable_id)
);

-- Comment on a post
INSERT INTO comments (comment_id, commentable_type, commentable_id, comment_text)
VALUES (1, 'post', 5, 'Great post!');

-- Comment on an event
INSERT INTO comments (comment_id, commentable_type, commentable_id, comment_text)
VALUES (2, 'event', 10, 'Looking forward to this event!');

-- Query comments for a post
SELECT *
FROM comments
WHERE commentable_type = 'post' AND commentable_id = 5;
```

### Better Alternative: Separate Junction Tables

```sql
CREATE TABLE post_comments (
    comment_id INT PRIMARY KEY,
    post_id INT,
    comment_text TEXT,
    FOREIGN KEY (post_id) REFERENCES posts(post_id)  -- Real FK!
);

CREATE TABLE event_comments (
    comment_id INT PRIMARY KEY,
    event_id INT,
    comment_text TEXT,
    FOREIGN KEY (event_id) REFERENCES events(event_id)  -- Real FK!
);
```

**Pros (Polymorphic):** DRY code, flexible  
**Cons:** No foreign key constraints, complex queries, data integrity issues

---

## Adjacency List (Hierarchies)

**Use Case:** Categories, org charts, comment threads

**Description:** Each record has a parent_id pointing to its parent.

### Example

```sql
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100),
    parent_id INT NULL,
    level INT,
    FOREIGN KEY (parent_id) REFERENCES categories(category_id),
    INDEX idx_parent (parent_id)
);

INSERT INTO categories VALUES
    (1, 'Electronics', NULL, 1),
    (2, 'Computers', 1, 2),
    (3, 'Phones', 1, 2),
    (4, 'Laptops', 2, 3),
    (5, 'Desktops', 2, 3),
    (6, 'Smartphones', 3, 3),
    (7, 'Feature Phones', 3, 3);

-- Find children of a category
SELECT *
FROM categories
WHERE parent_id = 2;

-- Find all descendants (recursive CTE, MySQL 8+)
WITH RECURSIVE category_tree AS (
    -- Anchor: start with parent
    SELECT category_id, category_name, parent_id, 1 as depth
    FROM categories
    WHERE category_id = 1
    
    UNION ALL
    
    -- Recursive: find children
    SELECT c.category_id, c.category_name, c.parent_id, ct.depth + 1
    FROM categories c
    JOIN category_tree ct ON c.parent_id = ct.category_id
)
SELECT * FROM category_tree;
```

**Pros:** Simple to understand and implement  
**Cons:** Finding all descendants requires recursion, moving subtrees is complex

---

## Materialized Path

**Use Case:** Hierarchies where you often query ancestors/descendants

**Description:** Store the full path from root to node.

### Example

```sql
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100),
    path VARCHAR(255),  -- e.g., '/1/2/4/'
    level INT,
    INDEX idx_path (path)
);

INSERT INTO categories VALUES
    (1, 'Electronics', '/1/', 1),
    (2, 'Computers', '/1/2/', 2),
    (3, 'Phones', '/1/3/', 2),
    (4, 'Laptops', '/1/2/4/', 3);

-- Find all descendants of Computers (id=2)
SELECT *
FROM categories
WHERE path LIKE '/1/2/%';

-- Find all ancestors of Laptops (id=4)
SELECT *
FROM categories
WHERE '/1/2/4/' LIKE CONCAT(path, '%')
ORDER BY level;
```

**Pros:** Fast ancestor/descendant queries  
**Cons:** Path length limits depth, updating paths when moving nodes

---

## Single Table Inheritance

**Use Case:** Similar entities with some shared and some unique attributes

**Description:** Store different types of entities in one table with a type discriminator.

### Example

```sql
CREATE TABLE vehicles (
    vehicle_id INT PRIMARY KEY,
    vehicle_type VARCHAR(20),  -- 'car', 'truck', 'motorcycle'
    brand VARCHAR(100),
    model VARCHAR(100),
    year INT,
    -- Car-specific
    num_doors INT NULL,
    -- Truck-specific
    bed_length_ft INT NULL,
    payload_capacity_lbs INT NULL,
    -- Motorcycle-specific
    engine_cc INT NULL,
    has_sidecar BOOLEAN NULL
);

-- Query only cars
SELECT * FROM vehicles WHERE vehicle_type = 'car';

-- Query with relevant columns
SELECT vehicle_id, brand, model, num_doors
FROM vehicles
WHERE vehicle_type = 'car';
```

**Pros:** Simple queries, easy joins, single table  
**Cons:** Sparse data (many NULLs), growing table, unclear schema

**Alternative:** Class Table Inheritance (separate tables with joins)

---

## Multi-Tenant Patterns

**Use Case:** SaaS applications serving multiple customers (tenants)

### Pattern 1: Shared Schema with Tenant ID

```sql
CREATE TABLE tenants (
    tenant_id INT PRIMARY KEY,
    tenant_name VARCHAR(100),
    subdomain VARCHAR(50)
);

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    tenant_id INT,
    username VARCHAR(100),
    email VARCHAR(100),
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    INDEX idx_tenant (tenant_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    tenant_id INT,
    user_id INT,
    total DECIMAL(10,2),
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    INDEX idx_tenant (tenant_id)
);

-- Always filter by tenant!
SELECT * FROM orders WHERE tenant_id = 5 AND status = 'pending';
```

**Pros:** Simple, cost-effective, easy backups  
**Cons:** Risk of data leaks (must always filter), noisy neighbor problem

### Pattern 2: Separate Schemas per Tenant

```sql
-- Database: tenant_1
CREATE TABLE users (...);
CREATE TABLE orders (...);

-- Database: tenant_2
CREATE TABLE users (...);
CREATE TABLE orders (...);
```

**Pros:** Data isolation, tenant-specific customizations  
**Cons:** More databases to manage, harder to aggregate data

### Pattern 3: Separate Databases per Tenant

**Pros:** Complete isolation, security, scalability  
**Cons:** Expensive, complex management

---

## Event Sourcing

**Use Case:** Financial systems, audit logs, time-travel requirements

**Description:** Store all changes as a sequence of events instead of current state.

### Example

```sql
CREATE TABLE account_events (
    event_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    event_type VARCHAR(50),  -- 'deposit', 'withdrawal', 'transfer_in', 'transfer_out'
    amount DECIMAL(10,2),
    balance_after DECIMAL(10,2),
    event_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSON,
    INDEX idx_account_time (account_id, event_timestamp)
);

-- Deposit
INSERT INTO account_events (account_id, event_type, amount, balance_after)
VALUES (1, 'deposit', 100.00, 100.00);

-- Withdrawal
INSERT INTO account_events (account_id, event_type, amount, balance_after)
VALUES (1, 'withdrawal', 30.00, 70.00);

-- Current balance (latest event)
SELECT balance_after
FROM account_events
WHERE account_id = 1
ORDER BY event_id DESC
LIMIT 1;

-- Balance at specific time
SELECT balance_after
FROM account_events
WHERE account_id = 1
  AND event_timestamp <= '2024-06-15 12:00:00'
ORDER BY event_id DESC
LIMIT 1;

-- All transactions
SELECT * FROM account_events WHERE account_id = 1 ORDER BY event_id;
```

**Pros:** Complete audit trail, can rebuild state, time-travel  
**Cons:** More complex, more storage, eventual consistency

---

## Summary and When to Use Each Pattern

| Pattern | Best For | Avoid When |
|---------|----------|------------|
| Star Schema | Analytics, reporting | Transactional systems |
| Temporal Tables | History tracking | Simple CRUD apps |
| Soft Delete | Recovery, auditing | Storage is limited |
| Audit Trail | Compliance | Low-value data changes |
| EAV | Extreme flexibility | You can define a schema |
| Polymorphic | DRY associations | You need referential integrity |
| Adjacency List | Simple hierarchies | Deep trees, frequent queries |
| Materialized Path | Deep hierarchies | Frequent moves |
| Single Table Inheritance | Similar entities | Very different attributes |
| Multi-Tenant (Shared) | Cost-effective SaaS | Strict data isolation |
| Event Sourcing | Audit, time-travel | Simple state management |

---

## References

- "Data Warehouse Toolkit" by Ralph Kimball
- "Designing Data-Intensive Applications" by Martin Kleppmann
- "SQL Antipatterns" by Bill Karwin
- PostgreSQL documentation on temporal tables
- Microsoft SQL Server temporal tables documentation
