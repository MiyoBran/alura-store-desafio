-- COMPLEX JOINS - SQL Practice
-- Advanced join patterns, multiple joins, self-joins, and complex scenarios

-- ============================================
-- MULTIPLE TABLE JOINS
-- ============================================

-- Join 3 tables: customers, orders, order_items
SELECT 
    c.customer_id,
    c.name,
    o.order_id,
    o.order_date,
    oi.product_id,
    oi.quantity,
    oi.unit_price
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id;

-- Join 4 tables: add product details
SELECT 
    c.name as customer_name,
    o.order_id,
    o.order_date,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) as line_total
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_date DESC;

-- Join 5 tables: add category information
SELECT 
    c.name as customer,
    o.order_id,
    cat.category_name,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
WHERE o.order_date >= '2024-01-01';

-- Complex e-commerce query (7 tables)
SELECT 
    c.customer_id,
    c.name,
    c.email,
    a.street_address,
    ci.city_name,
    st.state_name,
    o.order_id,
    o.total_amount,
    s.shipping_status
FROM customers c
LEFT JOIN addresses a ON c.customer_id = a.customer_id AND a.is_primary = TRUE
LEFT JOIN cities ci ON a.city_id = ci.city_id
LEFT JOIN states st ON ci.state_id = st.state_id
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN shipments s ON o.order_id = s.order_id
WHERE c.is_active = TRUE;

-- ============================================
-- SELF JOINS
-- ============================================

-- Employee-Manager relationship
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name as employee_name,
    e.title as employee_title,
    m.first_name || ' ' || m.last_name as manager_name,
    m.title as manager_title
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY m.employee_id, e.employee_id;

-- Find employees with the same title
SELECT 
    e1.employee_id as emp1_id,
    e1.first_name as emp1_name,
    e2.employee_id as emp2_id,
    e2.first_name as emp2_name,
    e1.title
FROM employees e1
INNER JOIN employees e2 
    ON e1.title = e2.title 
    AND e1.employee_id < e2.employee_id  -- Avoid duplicates
ORDER BY e1.title, e1.employee_id;

-- Hierarchical organization chart
SELECT 
    e1.employee_id as level1_id,
    e1.first_name as level1_name,
    e2.employee_id as level2_id,
    e2.first_name as level2_name,
    e3.employee_id as level3_id,
    e3.first_name as level3_name
FROM employees e1
LEFT JOIN employees e2 ON e1.employee_id = e2.manager_id
LEFT JOIN employees e3 ON e2.employee_id = e3.manager_id
WHERE e1.manager_id IS NULL  -- Top level managers
ORDER BY e1.employee_id, e2.employee_id, e3.employee_id;

-- Find products in the same category
SELECT 
    p1.product_id as product1_id,
    p1.product_name as product1,
    p2.product_id as product2_id,
    p2.product_name as product2,
    p1.category_id,
    ABS(p1.price - p2.price) as price_difference
FROM products p1
INNER JOIN products p2 
    ON p1.category_id = p2.category_id 
    AND p1.product_id < p2.product_id
WHERE ABS(p1.price - p2.price) < 10  -- Similar price
ORDER BY p1.category_id, price_difference;

-- Find customers who ordered the same products
SELECT 
    o1.customer_id as customer1,
    o2.customer_id as customer2,
    oi1.product_id,
    p.product_name,
    COUNT(*) as common_purchases
FROM order_items oi1
JOIN order_items oi2 ON oi1.product_id = oi2.product_id
JOIN orders o1 ON oi1.order_id = o1.order_id
JOIN orders o2 ON oi2.order_id = o2.order_id
JOIN products p ON oi1.product_id = p.product_id
WHERE o1.customer_id < o2.customer_id  -- Avoid duplicates
GROUP BY o1.customer_id, o2.customer_id, oi1.product_id, p.product_name
HAVING COUNT(*) > 2
ORDER BY common_purchases DESC;

-- ============================================
-- CROSS JOIN (Cartesian Product)
-- ============================================

-- Generate all combinations (use carefully!)
SELECT 
    c.color,
    s.size
FROM colors c
CROSS JOIN sizes s;

-- Calendar × employees (schedule template)
SELECT 
    d.date,
    e.employee_id,
    e.first_name
FROM date_range d
CROSS JOIN employees e
WHERE d.date BETWEEN '2024-01-01' AND '2024-01-31'
ORDER BY d.date, e.employee_id;

-- All product × all customers (marketing matrix)
SELECT 
    c.customer_id,
    c.email,
    p.product_id,
    p.product_name
FROM customers c
CROSS JOIN products p
WHERE p.is_active = TRUE
  AND c.marketing_opt_in = TRUE;

-- ============================================
-- JOINING DERIVED TABLES (Subqueries)
-- ============================================

-- Join with aggregated subquery
SELECT 
    c.customer_id,
    c.name,
    summary.order_count,
    summary.total_spent
FROM customers c
INNER JOIN (
    SELECT 
        customer_id,
        COUNT(*) as order_count,
        SUM(total) as total_spent
    FROM orders
    GROUP BY customer_id
) summary ON c.customer_id = summary.customer_id;

-- Multiple derived tables
SELECT 
    p.product_id,
    p.product_name,
    sales.units_sold,
    reviews.avg_rating,
    reviews.review_count
FROM products p
LEFT JOIN (
    SELECT product_id, SUM(quantity) as units_sold
    FROM order_items
    GROUP BY product_id
) sales ON p.product_id = sales.product_id
LEFT JOIN (
    SELECT product_id, AVG(rating) as avg_rating, COUNT(*) as review_count
    FROM reviews
    GROUP BY product_id
) reviews ON p.product_id = reviews.product_id
ORDER BY sales.units_sold DESC NULLS LAST;

-- Join with filtered subquery
SELECT 
    c.name,
    recent_orders.order_count
FROM customers c
INNER JOIN (
    SELECT customer_id, COUNT(*) as order_count
    FROM orders
    WHERE order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    GROUP BY customer_id
    HAVING COUNT(*) >= 3
) recent_orders ON c.customer_id = recent_orders.customer_id;

-- ============================================
-- JOINING WITH COMMON TABLE EXPRESSIONS (CTEs)
-- ============================================

-- Single CTE
WITH customer_totals AS (
    SELECT 
        customer_id,
        COUNT(*) as order_count,
        SUM(total) as lifetime_value
    FROM orders
    GROUP BY customer_id
)
SELECT 
    c.customer_id,
    c.name,
    c.email,
    ct.order_count,
    ct.lifetime_value
FROM customers c
INNER JOIN customer_totals ct ON c.customer_id = ct.customer_id
WHERE ct.lifetime_value > 1000;

-- Multiple CTEs
WITH 
monthly_sales AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') as month,
        SUM(total) as monthly_total
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
monthly_avg AS (
    SELECT AVG(monthly_total) as avg_monthly_sales
    FROM monthly_sales
)
SELECT 
    ms.month,
    ms.monthly_total,
    ma.avg_monthly_sales,
    ms.monthly_total - ma.avg_monthly_sales as variance,
    ROUND((ms.monthly_total / ma.avg_monthly_sales - 1) * 100, 2) as pct_change
FROM monthly_sales ms
CROSS JOIN monthly_avg ma
ORDER BY ms.month;

-- Recursive CTE (employee hierarchy)
WITH RECURSIVE employee_hierarchy AS (
    -- Anchor: Top-level employees
    SELECT 
        employee_id,
        first_name,
        manager_id,
        1 as level,
        CAST(first_name AS CHAR(200)) as path
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive: Employees reporting to previous level
    SELECT 
        e.employee_id,
        e.first_name,
        e.manager_id,
        eh.level + 1,
        CONCAT(eh.path, ' -> ', e.first_name)
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT 
    employee_id,
    first_name,
    level,
    path
FROM employee_hierarchy
ORDER BY level, employee_id;

-- ============================================
-- JOINING WITH UNIONS
-- ============================================

-- Union results then join
SELECT 
    combined.id,
    combined.name,
    combined.type,
    details.description
FROM (
    SELECT customer_id as id, name, 'Customer' as type FROM customers
    UNION ALL
    SELECT supplier_id as id, company_name as name, 'Supplier' as type FROM suppliers
) combined
LEFT JOIN contact_details details ON combined.id = details.entity_id AND details.entity_type = combined.type;

-- Join multiple unions
WITH all_transactions AS (
    SELECT order_id as transaction_id, customer_id, total as amount, 'Order' as type, order_date as date
    FROM orders
    UNION ALL
    SELECT refund_id, customer_id, -amount, 'Refund', refund_date
    FROM refunds
    UNION ALL
    SELECT credit_id, customer_id, amount, 'Credit', credit_date
    FROM store_credits
)
SELECT 
    c.customer_id,
    c.name,
    t.transaction_id,
    t.type,
    t.amount,
    t.date
FROM customers c
INNER JOIN all_transactions t ON c.customer_id = t.customer_id
ORDER BY c.customer_id, t.date;

-- ============================================
-- CONDITIONAL JOINS
-- ============================================

-- Join with additional conditions
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    d.discount_percentage,
    (p.price * (1 - d.discount_percentage / 100)) as discounted_price
FROM products p
LEFT JOIN discounts d 
    ON p.category_id = d.category_id
    AND d.start_date <= CURDATE()
    AND d.end_date >= CURDATE()
    AND p.price >= d.min_price;

-- Join with CASE in join condition
SELECT 
    o.order_id,
    o.total,
    sh.shipping_method,
    sh.shipping_cost
FROM orders o
INNER JOIN shipping_rates sh 
    ON sh.weight_category = CASE 
        WHEN o.total_weight < 1 THEN 'light'
        WHEN o.total_weight < 5 THEN 'medium'
        ELSE 'heavy'
    END
    AND sh.destination_zone = o.shipping_zone;

-- ============================================
-- PERFORMANCE OPTIMIZATION PATTERNS
-- ============================================

-- Index hint (MySQL)
SELECT 
    c.name,
    o.order_id
FROM customers c
INNER JOIN orders o USE INDEX (idx_customer_id) ON c.customer_id = o.customer_id
WHERE o.order_date >= '2024-01-01';

-- Straight join (force join order) - MySQL
SELECT STRAIGHT_JOIN
    c.name,
    o.order_id,
    oi.product_id
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE c.country = 'USA';

-- Filtering before join (better performance)
SELECT 
    c.name,
    recent_orders.order_id,
    recent_orders.total
FROM customers c
INNER JOIN (
    SELECT order_id, customer_id, total
    FROM orders
    WHERE order_date >= '2024-01-01'  -- Filter early!
) recent_orders ON c.customer_id = recent_orders.customer_id;

-- ============================================
-- PRACTICAL COMPLEX SCENARIOS
-- ============================================

-- Scenario 1: Sales report with multiple dimensions
SELECT 
    c.name as customer,
    cat.category_name,
    p.product_name,
    SUM(oi.quantity) as units_sold,
    SUM(oi.quantity * oi.unit_price) as revenue,
    AVG(r.rating) as avg_rating
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
LEFT JOIN reviews r ON p.product_id = r.product_id
WHERE o.order_date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY c.name, cat.category_name, p.product_name
HAVING SUM(oi.quantity * oi.unit_price) > 1000
ORDER BY revenue DESC;

-- Scenario 2: Customer segmentation
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.name,
        COUNT(DISTINCT o.order_id) as order_count,
        SUM(o.total) as lifetime_value,
        MAX(o.order_date) as last_order_date,
        DATEDIFF(CURDATE(), MAX(o.order_date)) as days_since_last_order
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.name
)
SELECT 
    customer_id,
    name,
    order_count,
    lifetime_value,
    last_order_date,
    CASE 
        WHEN order_count = 0 THEN 'Never Purchased'
        WHEN days_since_last_order > 365 THEN 'Inactive'
        WHEN lifetime_value > 10000 AND order_count > 50 THEN 'VIP'
        WHEN lifetime_value > 5000 THEN 'High Value'
        WHEN order_count > 10 THEN 'Regular'
        ELSE 'Occasional'
    END as segment
FROM customer_metrics
ORDER BY lifetime_value DESC;

-- Scenario 3: Product recommendation (customers who bought X also bought Y)
SELECT 
    oi1.product_id as purchased_product,
    p1.product_name as purchased_name,
    oi2.product_id as recommended_product,
    p2.product_name as recommended_name,
    COUNT(DISTINCT o1.customer_id) as times_bought_together,
    ROUND(COUNT(DISTINCT o1.customer_id) * 100.0 / (
        SELECT COUNT(DISTINCT customer_id)
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE oi.product_id = oi1.product_id
    ), 2) as recommendation_strength_pct
FROM order_items oi1
JOIN orders o1 ON oi1.order_id = o1.order_id
JOIN orders o2 ON o1.customer_id = o2.customer_id
JOIN order_items oi2 
    ON o2.order_id = oi2.order_id 
    AND oi2.product_id != oi1.product_id
JOIN products p1 ON oi1.product_id = p1.product_id
JOIN products p2 ON oi2.product_id = p2.product_id
WHERE oi1.product_id = 123  -- Product ID we're recommending for
GROUP BY oi1.product_id, p1.product_name, oi2.product_id, p2.product_name
HAVING COUNT(DISTINCT o1.customer_id) >= 5
ORDER BY times_bought_together DESC
LIMIT 10;

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

-- Exercise 1: Complete Order Report
-- Create a comprehensive order report showing:
-- - Customer name and email
-- - Order ID and date
-- - Each product ordered with quantity and price
-- - Product category
-- - Total order amount
-- For orders in the last 60 days
-- YOUR CODE HERE:



-- Exercise 2: Employee Reporting Chain
-- Show each employee with their complete reporting chain up to CEO
-- Include: employee name, manager name, manager's manager name
-- YOUR CODE HERE:



-- Exercise 3: Product Comparison
-- Find products in the same category with similar prices (within 20%)
-- Show both product names, category, and price difference
-- YOUR CODE HERE:



-- Exercise 4: Customer Purchase Pattern
-- For each customer, show:
-- - Total orders
-- - Favorite category (most purchased)
-- - Average order value
-- - Last purchase date
-- Join customers, orders, order_items, products, categories
-- YOUR CODE HERE:



-- Exercise 5: Monthly Sales Dashboard
-- Create monthly report with:
-- - Month
-- - Number of orders
-- - Unique customers
-- - Revenue
-- - Average order value
-- - Comparison to previous month
-- YOUR CODE HERE:



-- Exercise 6: Cross-Sell Analysis
-- Find product pairs frequently bought together
-- Show product names and how many times bought in same order
-- Minimum 10 occurrences
-- YOUR CODE HERE:



-- Exercise 7: Hierarchical Category Tree
-- Display full category hierarchy with product counts
-- Show: main category -> subcategory -> product count
-- Include categories without products
-- YOUR CODE HERE:



-- ============================================
-- NOTES
-- ============================================

/*
COMPLEX JOIN BEST PRACTICES:

1. Join Order Matters
   - Start with smallest result set
   - Filter early
   - Join on indexed columns

2. Use Appropriate Join Types
   - INNER: Only matching records
   - LEFT: Preserve left table records
   - CROSS: All combinations (use sparingly!)

3. Alias Everything
   - Makes queries readable
   - Prevents ambiguity
   - FROM customers c helps!

4. Index Join Columns
   - Primary keys
   - Foreign keys
   - Frequently joined columns

5. Use CTEs for Readability
   - Break complex queries into steps
   - Reusable in same query
   - Better than nested subqueries

6. Consider Performance
   - EXPLAIN your queries
   - Watch for Cartesian products
   - Limit result sets early
   - Use covering indexes

COMMON PATTERNS:

1. Fact-Dimension Star Schema
   - Central fact table
   - Multiple dimension tables
   - Common in data warehousing

2. Self-Join for Hierarchies
   - Employees/managers
   - Categories/subcategories
   - Geographic hierarchies

3. Join + Aggregate
   - Group after joining
   - Use DISTINCT carefully
   - Watch for multiplication

4. Anti-Join
   - Find non-matches
   - LEFT JOIN + IS NULL
   - Or use NOT EXISTS

TROUBLESHOOTING:

1. Unexpected Row Count
   - Check for Cartesian products
   - Verify join conditions
   - Use DISTINCT if needed (but understand why!)

2. Slow Queries
   - Add indexes on join columns
   - Filter before joining
   - Use EXPLAIN ANALYZE
   - Consider query rewrite

3. NULL Handling
   - Remember: NULL != NULL
   - Use IS NULL, not = NULL
   - COALESCE for defaults
   - LEFT JOIN creates NULLs

4. Ambiguous Columns
   - Always qualify columns
   - Use table aliases
   - SELECT c.id, not SELECT id

PERFORMANCE TIPS:

1. Index all join columns
2. Filter before joining (WHERE in subquery)
3. Use INNER JOIN when possible (smaller result set)
4. Avoid joining on functions: JOIN ON YEAR(date) = 2024 (bad!)
5. Use EXPLAIN to verify index usage
6. Consider denormalization for complex frequent queries
7. Use materialized views for expensive joins
8. Batch process large join operations

WHEN TO USE SUBQUERIES VS JOINS:

Subqueries:
- Calculating aggregates
- Complex filtering logic
- When readability improves

Joins:
- Combining related data
- Better performance (usually)
- When returning columns from multiple tables

Rule of thumb: If you need data from joined table, use JOIN.
If you only need to filter, consider EXISTS/IN.
*/
