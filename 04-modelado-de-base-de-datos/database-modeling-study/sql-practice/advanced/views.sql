-- VIEWS - SQL Practice
-- Creating, modifying, and using database views

-- ============================================
-- WHAT ARE VIEWS?
-- ============================================

/*
A VIEW is a virtual table based on a SELECT query.
- Doesn't store data (except materialized views)
- Query is executed each time view is accessed
- Simplifies complex queries
- Provides security/abstraction layer
- Can be used like a regular table in SELECT statements

Benefits:
- Simplify complex queries
- Hide complexity from users
- Provide data security (show only certain columns/rows)
- Maintain consistent query logic
- Create virtual denormalized tables
*/

-- ============================================
-- CREATING BASIC VIEWS
-- ============================================

-- Simple view
CREATE VIEW active_customers AS
SELECT 
    customer_id,
    name,
    email,
    registration_date
FROM customers
WHERE is_active = TRUE;

-- Use the view
SELECT * FROM active_customers;

-- View with calculated columns
CREATE VIEW product_inventory AS
SELECT 
    product_id,
    product_name,
    stock_quantity,
    unit_price,
    (stock_quantity * unit_price) AS inventory_value,
    CASE 
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        WHEN stock_quantity < reorder_level THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM products;

-- View with joins
CREATE VIEW customer_orders AS
SELECT 
    c.customer_id,
    c.name AS customer_name,
    c.email,
    o.order_id,
    o.order_date,
    o.total,
    o.status
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- View with aggregation
CREATE VIEW monthly_sales AS
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(*) AS order_count,
    SUM(total) AS total_sales,
    AVG(total) AS avg_order_value
FROM orders
WHERE status = 'completed'
GROUP BY DATE_FORMAT(order_date, '%Y-%m');

-- ============================================
-- COMPLEX VIEWS
-- ============================================

-- Multi-table join view
CREATE VIEW order_details AS
SELECT 
    o.order_id,
    o.order_date,
    c.customer_id,
    c.name AS customer_name,
    c.email,
    p.product_id,
    p.product_name,
    cat.category_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total,
    o.status AS order_status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id;

-- View with subquery
CREATE VIEW top_customers AS
SELECT 
    c.customer_id,
    c.name,
    c.email,
    customer_stats.order_count,
    customer_stats.total_spent,
    customer_stats.last_order_date
FROM customers c
INNER JOIN (
    SELECT 
        customer_id,
        COUNT(*) AS order_count,
        SUM(total) AS total_spent,
        MAX(order_date) AS last_order_date
    FROM orders
    GROUP BY customer_id
    HAVING SUM(total) > 1000
) customer_stats ON c.customer_id = customer_stats.customer_id;

-- View with UNION
CREATE VIEW all_transactions AS
SELECT 
    order_id AS transaction_id,
    customer_id,
    order_date AS transaction_date,
    total AS amount,
    'ORDER' AS transaction_type
FROM orders
UNION ALL
SELECT 
    refund_id AS transaction_id,
    customer_id,
    refund_date AS transaction_date,
    -amount AS amount,
    'REFUND' AS transaction_type
FROM refunds;

-- ============================================
-- MODIFYING VIEWS
-- ============================================

-- Replace existing view
CREATE OR REPLACE VIEW active_customers AS
SELECT 
    customer_id,
    name,
    email,
    phone,  -- Added column
    registration_date
FROM customers
WHERE is_active = TRUE
  AND deleted_at IS NULL;  -- Added condition

-- Alter view (SQL Server, PostgreSQL)
-- ALTER VIEW active_customers AS
-- SELECT ...

-- ============================================
-- DROPPING VIEWS
-- ============================================

-- Drop a view
DROP VIEW IF EXISTS temp_view;

-- Drop multiple views
DROP VIEW IF EXISTS view1, view2, view3;

-- ============================================
-- UPDATABLE VIEWS
-- ============================================

/*
A view is updatable if:
- Based on single table (usually)
- No DISTINCT, GROUP BY, HAVING, UNION
- Only columns from single table in SELECT
- All NOT NULL columns included (for INSERT)
*/

-- Updatable view example
CREATE VIEW editable_products AS
SELECT 
    product_id,
    product_name,
    price,
    stock_quantity
FROM products
WHERE is_active = TRUE;

-- You can UPDATE through this view
UPDATE editable_products
SET price = 29.99
WHERE product_id = 1;

-- You can INSERT through this view
INSERT INTO editable_products (product_name, price, stock_quantity)
VALUES ('New Product', 49.99, 100);

-- You can DELETE through this view
DELETE FROM editable_products
WHERE product_id = 999;

-- WITH CHECK OPTION - Ensure inserts/updates meet view criteria
CREATE OR REPLACE VIEW active_cheap_products AS
SELECT 
    product_id,
    product_name,
    price
FROM products
WHERE is_active = TRUE
  AND price < 100
WITH CHECK OPTION;

-- This will fail because price >= 100
-- INSERT INTO active_cheap_products (product_name, price)
-- VALUES ('Expensive Item', 150);  -- ERROR!

-- ============================================
-- SECURITY VIEWS
-- ============================================

-- Hide sensitive data
CREATE VIEW public_employees AS
SELECT 
    employee_id,
    first_name,
    last_name,
    department_id,
    hire_date
    -- Excludes: salary, SSN, etc.
FROM employees;

-- Row-level security
CREATE VIEW my_team AS
SELECT 
    employee_id,
    first_name,
    last_name,
    email
FROM employees
WHERE manager_id = CURRENT_USER_ID();  -- Only see your direct reports

-- Column masking
CREATE VIEW customer_contact AS
SELECT 
    customer_id,
    name,
    CONCAT(SUBSTRING(email, 1, 3), '***@', SUBSTRING_INDEX(email, '@', -1)) AS masked_email,
    CONCAT('***-***-', RIGHT(phone, 4)) AS masked_phone
FROM customers;

-- ============================================
-- MATERIALIZED VIEWS (PostgreSQL, Oracle)
-- ============================================

/*
Materialized views:
- Physically store the result set
- Must be refreshed to see new data
- Much faster for complex queries
- Use disk space
- Ideal for reporting/analytics
*/

-- PostgreSQL syntax
-- CREATE MATERIALIZED VIEW sales_summary AS
-- SELECT 
--     DATE_TRUNC('month', order_date) AS month,
--     COUNT(*) AS order_count,
--     SUM(total) AS revenue
-- FROM orders
-- GROUP BY DATE_TRUNC('month', order_date);

-- Refresh materialized view
-- REFRESH MATERIALIZED VIEW sales_summary;

-- Concurrent refresh (PostgreSQL)
-- REFRESH MATERIALIZED VIEW CONCURRENTLY sales_summary;

-- ============================================
-- INDEXED VIEWS (SQL Server)
-- ============================================

/*
Indexed views in SQL Server:
- Similar to materialized views
- Must meet strict requirements
- First index must be unique clustered index
- Significant performance boost
*/

-- SQL Server syntax example
-- CREATE VIEW product_sales
-- WITH SCHEMABINDING
-- AS
-- SELECT 
--     p.product_id,
--     SUM(oi.quantity) AS total_quantity,
--     COUNT_BIG(*) AS row_count
-- FROM dbo.products p
-- JOIN dbo.order_items oi ON p.product_id = oi.product_id
-- GROUP BY p.product_id;

-- CREATE UNIQUE CLUSTERED INDEX idx_product_sales
-- ON product_sales (product_id);

-- ============================================
-- PARTITIONED VIEWS
-- ============================================

-- Combine data from multiple tables (horizontal partitioning)
CREATE VIEW all_orders AS
SELECT * FROM orders_2022
UNION ALL
SELECT * FROM orders_2023
UNION ALL
SELECT * FROM orders_2024;

-- ============================================
-- RECURSIVE VIEWS (CTEs in views)
-- ============================================

-- View with recursive CTE
CREATE VIEW employee_hierarchy AS
WITH RECURSIVE org_chart AS (
    SELECT 
        employee_id,
        first_name,
        last_name,
        manager_id,
        1 AS level,
        CAST(first_name AS CHAR(200)) AS path
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    SELECT 
        e.employee_id,
        e.first_name,
        e.last_name,
        e.manager_id,
        oc.level + 1,
        CONCAT(oc.path, ' -> ', e.first_name)
    FROM employees e
    JOIN org_chart oc ON e.manager_id = oc.employee_id
)
SELECT * FROM org_chart;

-- ============================================
-- VIEW METADATA
-- ============================================

-- List all views (MySQL)
SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';

-- View definition (MySQL)
SHOW CREATE VIEW view_name;

-- View information from information_schema
SELECT 
    TABLE_NAME,
    VIEW_DEFINITION,
    IS_UPDATABLE,
    CHECK_OPTION
FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = 'your_database';

-- ============================================
-- PRACTICAL VIEW EXAMPLES
-- ============================================

-- Example 1: Dashboard summary view
CREATE VIEW dashboard_summary AS
SELECT 
    (SELECT COUNT(*) FROM customers WHERE is_active = TRUE) AS active_customers,
    (SELECT COUNT(*) FROM orders WHERE order_date >= CURDATE()) AS today_orders,
    (SELECT SUM(total) FROM orders WHERE order_date >= CURDATE()) AS today_revenue,
    (SELECT COUNT(*) FROM products WHERE stock_quantity < reorder_level) AS low_stock_products,
    (SELECT AVG(total) FROM orders WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)) AS avg_order_value_30d;

-- Example 2: Customer segmentation view
CREATE VIEW customer_segments AS
SELECT 
    c.customer_id,
    c.name,
    c.email,
    COALESCE(stats.order_count, 0) AS order_count,
    COALESCE(stats.total_spent, 0) AS lifetime_value,
    stats.last_order_date,
    CASE 
        WHEN stats.order_count IS NULL THEN 'Never Purchased'
        WHEN stats.total_spent > 10000 THEN 'VIP'
        WHEN stats.total_spent > 5000 THEN 'Premium'
        WHEN stats.total_spent > 1000 THEN 'Regular'
        ELSE 'Occasional'
    END AS segment
FROM customers c
LEFT JOIN (
    SELECT 
        customer_id,
        COUNT(*) AS order_count,
        SUM(total) AS total_spent,
        MAX(order_date) AS last_order_date
    FROM orders
    GROUP BY customer_id
) stats ON c.customer_id = stats.customer_id;

-- Example 3: Product performance view
CREATE VIEW product_performance AS
SELECT 
    p.product_id,
    p.product_name,
    p.category_id,
    cat.category_name,
    p.price,
    p.stock_quantity,
    COALESCE(sales.units_sold, 0) AS units_sold,
    COALESCE(sales.revenue, 0) AS revenue,
    COALESCE(reviews.avg_rating, 0) AS avg_rating,
    COALESCE(reviews.review_count, 0) AS review_count,
    p.created_at,
    DATEDIFF(CURDATE(), p.created_at) AS days_since_creation
FROM products p
LEFT JOIN categories cat ON p.category_id = cat.category_id
LEFT JOIN (
    SELECT 
        product_id,
        SUM(quantity) AS units_sold,
        SUM(quantity * unit_price) AS revenue
    FROM order_items
    GROUP BY product_id
) sales ON p.product_id = sales.product_id
LEFT JOIN (
    SELECT 
        product_id,
        AVG(rating) AS avg_rating,
        COUNT(*) AS review_count
    FROM reviews
    GROUP BY product_id
) reviews ON p.product_id = reviews.product_id;

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

-- Exercise 1: Simple Customer View
-- Create a view showing only active customers with their email and phone
-- Name: active_customer_contacts
-- YOUR CODE HERE:



-- Exercise 2: Sales Report View
-- Create a view showing daily sales summary:
-- date, order_count, total_revenue, avg_order_value
-- Name: daily_sales
-- YOUR CODE HERE:



-- Exercise 3: Low Inventory Alert View
-- Create view showing products with stock below reorder level
-- Include: product_id, name, current_stock, reorder_level, category
-- Name: low_inventory_alert
-- YOUR CODE HERE:



-- Exercise 4: Customer  Loyalty View
-- Create view categorizing customers by loyalty:
-- Include customer info, order_count, total_spent, loyalty_tier
-- Tiers: Bronze (1-5 orders), Silver (6-20), Gold (21-50), Platinum (51+)
-- Name: customer_loyalty
-- YOUR CODE HERE:



-- Exercise 5: Product Catalog View
-- Create a denormalized view for product catalog:
-- Product details + category + supplier info (if applicable)
-- Hide discontinued products
-- Name: product_catalog
-- YOUR CODE HERE:



-- Exercise 6: Recent Activity View
-- Create view showing orders from last 30 days with customer and product details
-- Name: recent_orders
-- YOUR CODE HERE:



-- ============================================
-- NOTES
-- ============================================

/*
VIEW BEST PRACTICES:

1. Naming Conventions
   - Descriptive names: customer_orders not co
   - Prefix (optional): v_customer_orders or vw_customer_orders
   - Consistent naming across project

2. Documentation
   - Comment complex views
   - Document purpose and usage
   - Note any performance considerations

3. Performance
   - Views don't improve performance (usually slower)
   - Consider materialized views for complex aggregations
   - Index underlying tables properly
   - Avoid views on views (query gets too complex)

4. Security
   - Use views to restrict data access
   - Grant permissions on views, not base tables
   - Hide sensitive columns

5. Maintenance
   - Keep views simple
   - Update views when schema changes
   - Test view performance regularly
   - Version control view definitions

WHEN TO USE VIEWS:

✅ Use Views For:
- Simplifying complex, frequently-used queries
- Providing consistent business logic
- Security/data hiding
- Creating abstraction layer
- Backward compatibility when schema changes
- Denormalizing for reports (materialized)

❌ Avoid Views For:
- Simple one-time queries
- Queries that change frequently
- Already slow queries (won't help performance)
- Heavy computation (consider materialized views instead)

VIEW LIMITATIONS:

- Cannot contain ORDER BY (in most DBs) unless combined with LIMIT
- Cannot reference temporary tables
- May not be updatable if complex
- Can hide performance problems
- Nested views can become slow
- No parameters (use stored procedures instead)

PERFORMANCE CONSIDERATIONS:

1. Views are executed every time they're queried
2. Complex views can be slow - use EXPLAIN
3. Materialized views trade freshness for speed
4. Index underlying tables, not views
5. Avoid SELECT * in views
6. Consider covering indexes on base tables

COMMON MISTAKES:

1. Using SELECT * in views (breaks when schema changes)
2. Creating views on top of views (performance issues)
3. Not granting proper permissions on views
4. Forgetting to refresh materialized views
5. Using views to "fix" bad schema design
6. Not handling NULLs in calculated columns

ALTERNATIVES TO VIEWS:

- Table-valued functions (with parameters)
- Temporary tables (for one-time complex logic)
- Stored procedures (for complex logic with parameters)
- Materialized views (for performance)
- Denormalized tables (for extreme performance needs)
*/
