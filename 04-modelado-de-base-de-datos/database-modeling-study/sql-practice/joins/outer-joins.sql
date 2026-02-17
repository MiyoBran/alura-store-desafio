-- OUTER JOINS - SQL Practice
-- LEFT JOIN, RIGHT JOIN, and FULL OUTER JOIN examples

-- ============================================
-- SETUP: Sample Tables
-- ============================================

/*
-- Customers Table
customer_id | name          | email
1           | John Smith    | john@email.com
2           | Jane Doe      | jane@email.com
3           | Bob Johnson   | bob@email.com
4           | Alice Brown   | alice@email.com

-- Orders Table
order_id | customer_id | order_date  | total
101      | 1           | 2024-01-15  | 150.00
102      | 1           | 2024-01-20  | 200.00
103      | 2           | 2024-01-18  | 75.00
104      | NULL        | 2024-01-22  | 50.00  -- Guest order
*/

-- ============================================
-- LEFT JOIN (LEFT OUTER JOIN)
-- ============================================

-- Returns ALL rows from left table + matching rows from right table
-- NULL for right table columns if no match

-- Basic LEFT JOIN
SELECT 
    c.customer_id,
    c.name,
    o.order_id,
    o.total
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

/*
Result includes:
- All customers (even those without orders)
- Customers without orders show NULL for order columns
- Alice Brown (customer 4) appears with NULL order_id and total
*/

-- LEFT JOIN to find customers who never ordered
SELECT 
    c.customer_id,
    c.name,
    c.email
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- LEFT JOIN with aggregate
SELECT 
    c.customer_id,
    c.name,
    COUNT(o.order_id) as total_orders,
    COALESCE(SUM(o.total), 0) as total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;

-- Multiple LEFT JOINs
SELECT 
    c.customer_id,
    c.name,
    COUNT(DISTINCT o.order_id) as order_count,
    COUNT(DISTINCT r.review_id) as review_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN reviews r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.name;

-- LEFT JOIN with WHERE on left table
SELECT 
    c.customer_id,
    c.name,
    o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE c.country = 'USA';  -- Filter before join

-- ============================================
-- RIGHT JOIN (RIGHT OUTER JOIN)
-- ============================================

-- Returns ALL rows from right table + matching rows from left table
-- NULL for left table columns if no match

-- Basic RIGHT JOIN
SELECT 
    c.name,
    o.order_id,
    o.total
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;

/*
Result includes:
- All orders (even guest orders without customer)
- Guest orders show NULL for customer name
- Order 104 appears with NULL customer name
*/

-- RIGHT JOIN to find orphaned orders (no customer)
SELECT 
    o.order_id,
    o.order_date,
    o.total
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

-- Convert RIGHT JOIN to LEFT JOIN (more common/readable)
-- These are equivalent:
SELECT c.name, o.order_id
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- Same as:
SELECT c.name, o.order_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id;

-- ============================================
-- FULL OUTER JOIN
-- ============================================

-- MySQL doesn't support FULL OUTER JOIN directly
-- Simulate with UNION of LEFT and RIGHT joins

-- FULL OUTER JOIN simulation
SELECT 
    c.customer_id,
    c.name,
    o.order_id,
    o.total
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id

UNION

SELECT 
    c.customer_id,
    c.name,
    o.order_id,
    o.total
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;

/*
Result includes:
- All customers (with or without orders)
- All orders (with or without customers)
*/

-- Find mismatched records (customers without orders OR orders without customers)
SELECT 
    c.customer_id,
    c.name,
    o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL  -- Customers without orders

UNION

SELECT 
    c.customer_id,
    c.name,
    o.order_id
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;  -- Orders without customers

-- ============================================
-- PRACTICAL LEFT JOIN EXAMPLES
-- ============================================

-- Example 1: Product inventory report (including products never ordered)
SELECT 
    p.product_id,
    p.product_name,
    p.stock_quantity,
    COALESCE(SUM(oi.quantity), 0) as total_sold
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.stock_quantity
ORDER BY total_sold DESC;

-- Example 2: Customer activity report
SELECT 
    c.customer_id,
    c.name,
    c.registration_date,
    COUNT(o.order_id) as order_count,
    MAX(o.order_date) as last_order_date,
    DATEDIFF(NOW(), MAX(o.order_date)) as days_since_last_order
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.registration_date;

-- Example 3: Category performance (including categories with no products)
SELECT 
    cat.category_id,
    cat.category_name,
    COUNT(p.product_id) as product_count,
    COUNT(oi.order_item_id) as times_ordered
FROM categories cat
LEFT JOIN products p ON cat.category_id = p.category_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY cat.category_id, cat.category_name
ORDER BY times_ordered DESC;

-- Example 4: Employee-Department report (including unassigned employees)
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    COALESCE(d.department_name, 'Unassigned') as department,
    e.salary
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;

-- Example 5: Student enrollment status
SELECT 
    s.student_id,
    s.student_name,
    s.email,
    COUNT(e.course_id) as enrolled_courses,
    CASE 
        WHEN COUNT(e.course_id) = 0 THEN 'Not Enrolled'
        WHEN COUNT(e.course_id) < 3 THEN 'Part Time'
        ELSE 'Full Time'
    END as enrollment_status
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.student_name, s.email;

-- ============================================
-- FINDING MISSING RELATIONSHIPS
-- ============================================

-- Find products without any category
SELECT 
    p.product_id,
    p.product_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
WHERE c.category_id IS NULL;

-- Find orders without items (data integrity issue)
SELECT 
    o.order_id,
    o.order_date
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_item_id IS NULL;

-- Find authors without books
SELECT 
    a.author_id,
    a.author_name
FROM authors a
LEFT JOIN books b ON a.author_id = b.author_id
WHERE b.book_id IS NULL;

-- Find departments without employees
SELECT 
    d.department_id,
    d.department_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

-- ============================================
-- OUTER JOIN WITH MULTIPLE CONDITIONS
-- ============================================

-- LEFT JOIN with multiple join conditions
SELECT 
    c.customer_id,
    c.name,
    o.order_id,
    o.total
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
    AND o.order_date >= '2024-01-01'  -- Additional join condition
    AND o.status = 'completed';

-- LEFT JOIN with complex conditions
SELECT 
    p.product_id,
    p.product_name,
    oi.quantity_sold
FROM products p
LEFT JOIN (
    SELECT 
        product_id,
        SUM(quantity) as quantity_sold
    FROM order_items
    WHERE order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    GROUP BY product_id
) oi ON p.product_id = oi.product_id;

-- ============================================
-- OUTER JOIN WITH AGGREGATES
-- ============================================

-- Customer summary with LEFT JOIN
SELECT 
    c.customer_id,
    c.name,
    COUNT(o.order_id) as order_count,
    COALESCE(SUM(o.total), 0) as lifetime_value,
    COALESCE(AVG(o.total), 0) as avg_order_value,
    COALESCE(MAX(o.order_date), c.registration_date) as last_activity
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.registration_date;

-- Product performance with multiple aggregates
SELECT 
    p.product_id,
    p.product_name,
    COUNT(DISTINCT o.order_id) as times_ordered,
    COALESCE(SUM(oi.quantity), 0) as units_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) as revenue,
    COUNT(DISTINCT r.review_id) as review_count,
    COALESCE(AVG(r.rating), 0) as avg_rating
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name;

-- ============================================
-- ANTI-JOIN PATTERN
-- ============================================

-- Anti-join: Find rows in left table with NO match in right table

-- Method 1: LEFT JOIN with IS NULL
SELECT c.*
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Method 2: NOT EXISTS (often more efficient)
SELECT c.*
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

-- Method 3: NOT IN (careful with NULLs!)
SELECT c.*
FROM customers c
WHERE c.customer_id NOT IN (
    SELECT customer_id
    FROM orders
    WHERE customer_id IS NOT NULL  -- Important!
);

-- ============================================
-- OUTER JOIN WITH CASE
-- ============================================

-- Categorize customers by order activity
SELECT 
    c.customer_id,
    c.name,
    COUNT(o.order_id) as order_count,
    CASE 
        WHEN COUNT(o.order_id) = 0 THEN 'Never Ordered'
        WHEN COUNT(o.order_id) = 1 THEN 'One-Time Customer'
        WHEN COUNT(o.order_id) BETWEEN 2 AND 5 THEN 'Regular Customer'
        WHEN COUNT(o.order_id) > 5 THEN 'VIP Customer'
    END as customer_category
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- Product status based on sales
SELECT 
    p.product_id,
    p.product_name,
    COALESCE(SUM(oi.quantity), 0) as units_sold,
    CASE 
        WHEN SUM(oi.quantity) IS NULL THEN 'Never Sold'
        WHEN SUM(oi.quantity) < 10 THEN 'Slow Moving'
        WHEN SUM(oi.quantity) BETWEEN 10 AND 100 THEN 'Moderate'
        WHEN SUM(oi.quantity) > 100 THEN 'Best Seller'
    END as sales_category
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

-- Exercise 1: All Customers Report
-- List all customers with their order count and total spent
-- Include customers who have never ordered (show 0 for counts)
-- YOUR CODE HERE:



-- Exercise 2: Product Inventory
-- Show all products with total quantity sold
-- Include products that were never sold
-- List products never sold first
-- YOUR CODE HERE:



-- Exercise 3: Department Employee Count
-- Show all departments with employee count
-- Include departments with no employees
-- YOUR CODE HERE:



-- Exercise 4: Inactive Customers
-- Find customers who registered but never placed an order
-- Show customer_id, name, email, and registration_date
-- YOUR CODE HERE:



-- Exercise 5: Complete Category Report
-- Show all categories with:
-- - Number of products in category
-- - Number of times products were ordered
-- - Total revenue from category
-- Include categories with no products
-- YOUR CODE HERE:



-- Exercise 6: Student Course Summary
-- For each student, show:
-- - Student name
-- - Number of  courses enrolled
-- - Course names (concatenated)
-- Include students not enrolled in any course
-- YOUR CODE HERE:



-- Exercise 7: Find Data Integrity Issues
-- Write queries to find:
-- a) Orders without any order items
-- b) Order items referencing non-existent products
-- c) Reviews for products that don't exist
-- YOUR CODE HERE:



-- ============================================
-- NOTES
-- ============================================

/*
OUTER JOIN TYPES:

LEFT JOIN (LEFT OUTER JOIN):
- Returns ALL rows from left table
- Matching rows from right table
- NULL in right table columns if no match
- Most commonly used outer join

RIGHT JOIN (RIGHT OUTER JOIN):
- Returns ALL rows from right table
- Matching rows from left table
- NULL in left table columns if no match
- Can be rewritten as LEFT JOIN (recommended)

FULL OUTER JOIN:
- Returns ALL rows from both tables
- NULL where there's no match on either side
- MySQL: Use UNION of LEFT and RIGHT joins

WHEN TO USE:

LEFT JOIN:
- List all items from main table
- Include items even if no related data
- Example: All customers (even without orders)

RIGHT JOIN:
- Less common (use LEFT JOIN instead)
- Only when right table is conceptually primary

FULL OUTER JOIN:
- Find all mismatches
- Data reconciliation
- Finding orphaned records on either side

KEY DIFFERENCES FROM INNER JOIN:

INNER JOIN:
- Only matching rows
- Filters out non-matches

OUTER JOIN:
- All rows from one or both tables
- Preserves non-matches
- Use COALESCE for NULL handling

BEST PRACTICES:

1. Use LEFT JOIN more than RIGHT JOIN
   - More intuitive
   - Easier to read

2. Handle NULLs with COALESCE
   COALESCE(SUM(amount), 0)

3. Be careful with WHERE clause
   - WHERE after LEFT JOIN can turn it into INNER JOIN
   - Use join conditions in ON clause instead

4. Use meaningful table aliases
   FROM customers c
   LEFT JOIN orders o ...

5. Consider performance
   - Outer joins can be slower
   - Ensure proper indexes

COMMON MISTAKES:

1. WHERE clause killing outer join effect
   -- BAD:
   LEFT JOIN orders o ON c.id = o.customer_id
   WHERE o.status = 'completed'
   -- This filters out customers without orders!
   
   -- GOOD:
   LEFT JOIN orders o 
     ON c.id = o.customer_id 
     AND o.status = 'completed'

2. Not handling NULL aggregates
   -- Use COALESCE for zero instead of NULL
   COALESCE(COUNT(o.order_id), 0)

3. Forgetting DISTINCT with multiple joins
   -- Can cause duplicate counts

4. Using NOT IN with nullable columns
   -- Use NOT EXISTS or LEFT JOIN IS NULL instead

PERFORMANCE TIPS:

1. Index join columns
2. Filter before joining (derived tables)
3. Use EXISTS for anti-joins when possible
4. EXPLAIN your queries
5. Consider materialized views for complex reports
*/
