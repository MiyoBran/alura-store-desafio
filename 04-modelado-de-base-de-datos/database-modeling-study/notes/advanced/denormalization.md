# Denormalization

## Overview

Denormalization is the intentional introduction of redundancy into a database design to improve read performance. It's the opposite of normalization and involves strategically violating normal forms.

---

## Table of Contents

1. [When to Denormalize](#when-to-denormalize)
2. [Common Denormalization Techniques](#common-denormalization-techniques)
3. [Calculated/Derived Columns](#calculatedderived-columns)
4. [Duplicate Data Across Tables](#duplicate-data-across-tables)
5. [Precomputed Aggregates](#precomputed-aggregates)
6. [Flattening Hierarchies](#flattening-hierarchies)
7. [Storing JSON/Arrays](#storing-jsonarrays)
8. [Maintaining Denormalized Data](#maintaining-denormalized-data)
9. [Trade-offs and Risks](#trade-offs-and-risks)

---

## When to Denormalize

### ✅ Good Reasons to Denormalize

1. **Read-Heavy Workloads**
   - Analytics and reporting systems
   - Data warehouses
   - Dashboard queries
   - Public-facing search features

2. **Performance Critical Paths**
   - Homepage loading
   - Search results
   - Real-time dashboards
   - API endpoints with SLAs

3. **Complex Joins Are Too Slow**
   - Joining 5+ tables regularly
   - Recursive queries
   - Self-joins on large tables

4. **Reduce Network Round Trips**
   - Microservices architecture
   - Distributed databases
   - High-latency connections

### ❌ Bad Reasons to Denormalize

- "Joins are always slow" (optimize first!)
- "It's easier to query" (learn SQL better)
- "Everyone does it" (cargo cult programming)
- Without measuring performance first
- In highly transactional OLTP systems

### Decision Framework

```
1. Measure current performance
2. Identify bottlenecks (is it really the joins?)
3. Try optimization first:
   - Add indexes
   - Optimize queries
   - Use caching
   - Add materialized views
4. If still slow and read-heavy → consider denormalization
5. Document the decision and trade-offs
```

---

## Common Denormalization Techniques

### 1. Add Redundant Foreign Key

Instead of joining through intermediate table, add direct foreign key.

**Normalized:**
```sql
Orders → Order_Items → Products

SELECT o.order_id, p.product_name
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;
```

**Denormalized:**
```sql
-- Add product_id directly to orders
ALTER TABLE orders ADD product_id INT;

SELECT o.order_id, p.product_name
FROM orders o
JOIN products p ON o.product_id = p.product_id;
-- One less join!
```

### 2. Store Computed Values

Store the result of calculations instead of computing on every query.

**Normalized:**
```sql
SELECT 
    order_id,
    (SELECT SUM(quantity * unit_price) FROM order_items WHERE order_id = o.order_id) as total
FROM orders o;
```

**Denormalized:**
```sql
ALTER TABLE orders ADD total DECIMAL(10,2);

-- Maintain with trigger
DELIMITER //
CREATE TRIGGER update_order_total
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total = (SELECT SUM(quantity * unit_price) FROM order_items WHERE order_id = NEW.order_id)
    WHERE order_id = NEW.order_id;
END //
DELIMITER ;

SELECT order_id, total FROM orders;
-- Much faster!
```

### 3. Duplicate Reference Data

Copy frequently accessed reference data to avoid joins.

**Normalized:**
```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

SELECT o.order_id, c.customer_name, c.email
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;
```

**Denormalized:**
```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(100),  -- Denormalized
    customer_email VARCHAR(100), -- Denormalized
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

SELECT order_id, customer_name, customer_email
FROM orders;
-- No join needed!
```

---

## Calculated/Derived Columns

Store the result of calculations or aggregations.

### Example: Full Name

**Normalized:**
```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

SELECT user_id, CONCAT(first_name, ' ', last_name) as full_name
FROM users;
```

**Denormalized:**
```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    full_name VARCHAR(100)  -- Denormalized
);

-- Keep in sync with trigger
DELIMITER //
CREATE TRIGGER maintain_full_name
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    SET NEW.full_name = CONCAT(NEW.first_name, ' ', NEW.last_name);
END //

CREATE TRIGGER maintain_full_name_update
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    SET NEW.full_name = CONCAT(NEW.first_name, ' ', NEW.last_name);
END //
DELIMITER ;
```

### Example: Age from Birthdate

```sql
ALTER TABLE users ADD age INT;

DELIMITER //
CREATE TRIGGER calculate_age
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    SET NEW.age = TIMESTAMPDIFF(YEAR, NEW.birthdate, CURDATE());
END //
DELIMITER ;

-- Update ages daily with scheduled job
UPDATE users SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());
```

---

## Duplicate Data Across Tables

Copy data to avoid joins in common queries.

### Example: Product Information in Orders

**Normalized:**
```sql
CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Query requires join
SELECT oi.*, p.product_name, p.price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;
```

**Denormalized:**
```sql
CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    product_name VARCHAR(200),  -- Snapshot at order time
    unit_price DECIMAL(10,2),    -- Snapshot at order time
    quantity INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- No join needed, and price is preserved even if product price changes!
SELECT * FROM order_items;
```

**Benefits:**
- Faster queries
- Historical accuracy (price at purchase time)
- Product can be deleted without breaking old orders

---

## Precomputed Aggregates

Store aggregate results instead of computing on every query.

### Example: Customer Statistics

**Normalized:**
```sql
-- Compute on every query
SELECT 
    c.customer_id,
    c.name,
    COUNT(o.order_id) as order_count,
    SUM(o.total) as lifetime_value,
    MAX(o.order_date) as last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;
```

**Denormalized:**
```sql
ALTER TABLE customers ADD (
    order_count INT DEFAULT 0,
    lifetime_value DECIMAL(10,2) DEFAULT 0,
    last_order_date DATE NULL
);

-- Maintain with triggers
DELIMITER //
CREATE TRIGGER update_customer_stats_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    UPDATE customers
    SET order_count = order_count + 1,
        lifetime_value = lifetime_value + NEW.total,
        last_order_date = NEW.order_date
    WHERE customer_id = NEW.customer_id;
END //

CREATE TRIGGER update_customer_stats_delete
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
    UPDATE customers
    SET order_count = order_count - 1,
        lifetime_value = lifetime_value - OLD.total
    WHERE customer_id = OLD.customer_id;
END //
DELIMITER ;

-- Simple, fast query
SELECT customer_id, name, order_count, lifetime_value, last_order_date
FROM customers;
```

### Example: Product Popularity

```sql
ALTER TABLE products ADD (
    times_ordered INT DEFAULT 0,
    total_quantity_sold INT DEFAULT 0,
    total_revenue DECIMAL(10,2) DEFAULT 0
);

DELIMITER //
CREATE TRIGGER update_product_stats
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET times_ordered = times_ordered + 1,
        total_quantity_sold = total_quantity_sold + NEW.quantity,
        total_revenue = total_revenue + (NEW.quantity * NEW.unit_price)
    WHERE product_id = NEW.product_id;
END //
DELIMITER ;

-- Fast leaderboard query
SELECT product_name, times_ordered, total_revenue
FROM products
ORDER BY total_revenue DESC
LIMIT 10;
```

---

## Flattening Hierarchies

Convert hierarchical data to flat structure for easier querying.

### Example: Category Path

**Normalized:**
```sql
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100),
    parent_id INT,
    FOREIGN KEY (parent_id) REFERENCES categories(category_id)
);

-- Complex recursive query to get full path
WITH RECURSIVE path AS (
    SELECT category_id, name, parent_id, name as path
    FROM categories WHERE category_id = 10
    UNION ALL
    SELECT c.category_id, c.name, c.parent_id, CONCAT(c.name, ' > ', p.path)
    FROM categories c
    JOIN path p ON c.category_id = p.parent_id
)
SELECT path FROM path WHERE parent_id IS NULL;
```

**Denormalized:**
```sql
ALTER TABLE categories ADD category_path VARCHAR(500);

-- Store full path: "Electronics > Computers > Laptops"
UPDATE categories c
SET category_path = (
    -- Build path with recursive CTE or application code
    'Electronics > Computers > Laptops'
);

-- Simple query
SELECT category_id, name, category_path
FROM categories
WHERE category_id = 10;

-- Easy search
SELECT * FROM categories WHERE category_path LIKE '%Computers%';
```

---

## Storing JSON/Arrays

Store related data as JSON instead of separate tables.

### Example: Product Attributes

**Normalized:**
```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(200)
);

CREATE TABLE product_attributes (
    product_id INT,
    attribute_name VARCHAR(100),
    attribute_value VARCHAR(200),
    PRIMARY KEY (product_id, attribute_name)
);

-- Query requires join
SELECT p.name, pa.attribute_name, pa.attribute_value
FROM products p
JOIN product_attributes pa ON p.product_id = pa.product_id;
```

**Denormalized with JSON:**
```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(200),
    attributes JSON  -- Denormalized
);

INSERT INTO products (product_id, name, attributes)
VALUES (1, 'Laptop', JSON_OBJECT(
    'brand', 'Dell',
    'ram_gb', 16,
    'screen_size', 15.6,
    'has_touchscreen', true
));

-- Query JSON
SELECT 
    name,
    attributes->>'$.brand' as brand,
    attributes->>'$.ram_gb' as ram
FROM products;

-- Search in JSON
SELECT * FROM products
WHERE attributes->>'$.brand' = 'Dell';
```

### Example: Order Items as Array

```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    items JSON  -- [{product_id: 1, qty: 2, price: 50}, ...]
);

-- Single table, fast retrieval
SELECT * FROM orders WHERE order_id = 100;
```

**Trade-off:** Flexibility vs. querying power and data integrity.

---

## Maintaining Denormalized Data

Keeping redundant data in sync is critical!

### Strategy 1: Database Triggers

**Pros:** Automatic, in database, can't forget  
**Cons:** Performance overhead, complexity, hard to debug

```sql
DELIMITER //
CREATE TRIGGER sync_customer_name
AFTER UPDATE ON customers
FOR EACH ROW
BEGIN
    IF OLD.name != NEW.name THEN
        UPDATE orders
        SET customer_name = NEW.name
        WHERE customer_id = NEW.customer_id;
    END IF;
END //
DELIMITER ;
```

### Strategy 2: Application Code

**Pros:** Full control, easier to test, can add business logic  
**Cons:** Can be bypassed, must remember in all code paths

```python
def update_customer(customer_id, new_name):
    # Update customer
    db.execute("UPDATE customers SET name = ? WHERE customer_id = ?", (new_name, customer_id))
    
    # Sync denormalized data
    db.execute("UPDATE orders SET customer_name = ? WHERE customer_id = ?", (new_name, customer_id))
    
    db.commit()
```

### Strategy 3: Batch Jobs

**Pros:** No real-time overhead, can handle complex logic  
**Cons:** Data temporarily inconsistent, requires scheduling

```sql
-- Run nightly
UPDATE products p
SET times_ordered = (
    SELECT COUNT(DISTINCT order_id)
    FROM order_items
    WHERE product_id = p.product_id
);
```

### Strategy 4: Event-Driven Updates

**Pros:** Decoupled, scalable, can be async  
**Cons:** More complex architecture, eventual consistency

```
Customer Updated Event → Message Queue → Update Denormalized Tables
```

### Strategy 5: Materialized Views

**Pros:** Database-managed, query like a table  
**Cons:** Database-specific, refresh strategies vary

```sql
-- PostgreSQL
CREATE MATERIALIZED VIEW customer_summary AS
SELECT 
    c.customer_id,
    c.name,
    COUNT(o.order_id) as order_count,
    SUM(o.total) as lifetime_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- Refresh (manual or scheduled)
REFRESH MATERIALIZED VIEW customer_summary;
```

---

## Trade-offs and Risks

### Benefits of Denormalization

✅ **Faster Reads**
- Fewer or no joins
- Precomputed values
- Simpler queries

✅ **Reduced Database Load**
- Less CPU for aggregations
- Fewer disk seeks
- Better cache utilization

✅ **Improved Response Times**
- Better user experience
- Can meet SLA requirements
- Scales better for read-heavy apps

✅ **Simplified Queries**
- Easier for developers
- Fewer bugs
- Better ORMs performance

### Costs of Denormalization

❌ **Data Inconsistency Risk**
- Redundant data can become out of sync
- Bugs in sync logic are serious
- Hard to detect inconsistencies

❌ **Increased Storage**
- Same data stored multiple times
- Larger databases
- Higher backup/restore times

❌ **Slower Writes**
- Must update multiple places
- Trigger overhead
- More complex transactions

❌ **Maintenance Burden**
- Sync logic must be maintained
- Schema changes are harder
- More code to test

❌ **Harder to Update Business Rules**
- Changing how aggregates are calculated
- Migrating existing denormalized data
- Temporary inconsistencies during changes

### Measuring the Impact

Before and after denormalization, measure:

```sql
-- Query performance
EXPLAIN SELECT ...;

-- Execution time
SET profiling = 1;
SELECT ...;
SHOW PROFILES;

-- Index usage
SHOW INDEX FROM table_name;

-- Table size
SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb
FROM information_schema.TABLES
WHERE table_schema = 'your_database';
```

---

## Best Practices

### 1. Document Everything

```sql
-- Orders table contains denormalized customer_name for performance.
-- Updated by trigger: sync_customer_name
-- See: docs/denormalization.md
CREATE TABLE orders (
    ...
    customer_name VARCHAR(100), -- DENORMALIZED from customers.name
    ...
);
```

### 2. Add Data Validation

```sql
-- Periodically check for inconsistencies
SELECT o.order_id, o.customer_name, c.name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.customer_name != c.name;
```

### 3. Version Your Aggregates

```sql
ALTER TABLE customers ADD (
    stats_version INT DEFAULT 1,
    stats_updated_at TIMESTAMP
);

-- Rebuild stats if version mismatch
UPDATE customers SET 
    order_count = (SELECT COUNT(*) FROM orders WHERE customer_id = customers.customer_id),
    stats_version = 2
WHERE stats_version = 1;
```

### 4. Use Read Replicas Instead?

Before denormalizing, consider:
- Read replicas for scaling reads
- Caching layer (Redis, Memcached)
- CDN for static data
- Materialized views (database-managed)

### 5. Start Small

- Denormalize one field at a time
- Measure impact
- Add monitoring
- Document lessons learned

### 6. Have a Rollback Plan

```sql
-- Can always go back to normalized
ALTER TABLE orders DROP COLUMN customer_name;
DROP TRIGGER sync_customer_name;
```

---

## Examples: Before and After

### Example 1: E-commerce Product List

**Before (Normalized):**
```sql
SELECT 
    p.product_id,
    p.name,
    c.category_name,
    b.brand_name,
    COUNT(r.review_id) as review_count,
    AVG(r.rating) as avg_rating
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN brands b ON p.brand_id = b.brand_id
LEFT JOIN reviews r ON p.product_id = r.product_id
WHERE p.is_active = TRUE
GROUP BY p.product_id, p.name, c.category_name, b.brand_name
LIMIT 20;

-- Execution time: 450ms
```

**After (Denormalized):**
```sql
ALTER TABLE products ADD (
    category_name VARCHAR(100),
    brand_name VARCHAR(100),
    review_count INT DEFAULT 0,
    avg_rating DECIMAL(3,2) DEFAULT 0
);

SELECT 
    product_id,
    name,
    category_name,
    brand_name,
    review_count,
    avg_rating
FROM products
WHERE is_active = TRUE
LIMIT 20;

-- Execution time: 12ms (37x faster!)
```

### Example 2: User Dashboard

**Before:**
```sql
-- 5 separate queries!
SELECT COUNT(*) FROM posts WHERE user_id = 123;
SELECT COUNT(*) FROM comments WHERE user_id = 123;
SELECT COUNT(*) FROM likes WHERE user_id = 123;
SELECT COUNT(*) FROM followers WHERE following_id = 123;
SELECT COUNT(*) FROM following WHERE follower_id = 123;
```

**After:**
```sql
ALTER TABLE users ADD (
    post_count INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    follower_count INT DEFAULT 0,
    following_count INT DEFAULT 0
);

-- 1 query!
SELECT post_count, comment_count, like_count, follower_count, following_count
FROM users
WHERE user_id = 123;
```

---

## Summary

### When to Denormalize

| Scenario | Denormalize? |
|----------|-------------|
| Read-heavy analytics | ✅ Yes |
| Complex reporting queries | ✅ Yes |
| Real-time dashboards | ✅ Yes |
| Historical snapshots needed | ✅ Yes |
| Transactional OLTP system | ❌ No |
| Frequently changing data | ❌ No |
| Can optimize with indexes | ❌ No |
| Complex sync logic required | ❌ Consider alternatives |

### Decision Checklist

- [ ] Measured current performance
- [ ] Identified specific bottleneck
- [ ] Tried indexes and query optimization
- [ ] Considered caching and read replicas
- [ ] Calculated read/write ratio (90%+ reads?)
- [ ] Designed sync strategy
- [ ] Documented denormalization decision
- [ ] Have rollback plan
- [ ] Added monitoring for data consistency

**Remember:** Denormalization is optimization. Follow the rule: "Make it work, make it right, make it fast." Don't denormalize prematurely!

---

## References

- "Database Internals" by Alex Petrov
- "Designing Data-Intensive Applications" by Martin Kleppmann
- "The Data Warehouse Toolkit" by Ralph Kimball
- PostgreSQL documentation on materialized views
- MySQL documentation on triggers and stored procedures
