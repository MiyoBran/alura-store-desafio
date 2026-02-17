-- INNER JOINS - SQL Practice
-- Combining data from multiple tables based on related columns

-- ============================================
-- BASIC INNER JOIN
-- ============================================

-- Join customers and orders
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- Alternative syntax (implicit join - less preferred)
SELECT c.first_name, o.order_date
FROM customers c, orders o
WHERE c.customer_id = o.customer_id;

-- ============================================
-- JOIN WITH WHERE CLAUSE
-- ============================================

-- Get orders from a specific customer
SELECT 
    c.first_name,
    c.last_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.email = 'john.doe@email.com';

-- Orders placed in a specific date range
SELECT 
    c.first_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date BETWEEN '2026-01-01' AND '2026-01-31'
  AND o.status = 'completed';

-- ============================================
-- JOINING THREE TABLES
-- ============================================

-- Get order details with product information
SELECT 
    c.first_name,
    c.last_name,
    o.order_id,
    o.order_date,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id;

-- ============================================
-- JOINS WITH AGGREGATION
-- ============================================

-- Total spending per customer
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Products sold with total quantity
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    COUNT(oi.order_id) AS times_ordered,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.price
ORDER BY total_revenue DESC;

-- ============================================
-- JOINING WITH COMPUTED COLUMNS
-- ============================================

-- Calculate order totals with discounts
SELECT 
    o.order_id,
    c.first_name,
    c.last_name,
    o.order_date,
    SUM(oi.quantity * oi.unit_price) AS subtotal,
    SUM(oi.quantity * oi.unit_price) * 0.1 AS tax,
    SUM(oi.quantity * oi.unit_price) * 1.1 AS total_with_tax
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, c.first_name, c.last_name, o.order_date;

-- ============================================
-- MULTIPLE JOINS WITH FILTERING
-- ============================================

-- Find customers who bought a specific product
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    o.order_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
WHERE p.product_name = 'Laptop'
ORDER BY o.order_date DESC;

-- ============================================
-- SELF JOIN
-- ============================================

-- Find employees and their managers
SELECT 
    e.employee_id,
    e.first_name AS employee_name,
    e.last_name AS employee_lastname,
    m.first_name AS manager_name,
    m.last_name AS manager_lastname
FROM employees e
INNER JOIN employees m ON e.manager_id = m.employee_id;

-- Find products in the same category
SELECT 
    p1.product_name AS product1,
    p2.product_name AS product2,
    c.category_name
FROM products p1
INNER JOIN products p2 ON p1.category_id = p2.category_id
INNER JOIN categories c ON p1.category_id = c.category_id
WHERE p1.product_id < p2.product_id  -- Avoid duplicates
ORDER BY c.category_name;

-- ============================================
-- JOINING THROUGH JUNCTION TABLES (Many-to-Many)
-- ============================================

-- Books and their authors
SELECT 
    b.title,
    a.first_name,
    a.last_name,
    ba.author_order
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id
ORDER BY b.title, ba.author_order;

-- Students and their enrolled courses
SELECT 
    s.first_name,
    s.last_name,
    c.course_name,
    e.semester,
    e.year,
    e.grade
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON e.course_id = c.course_id
WHERE e.year = 2026
ORDER BY s.last_name, s.first_name;

-- ============================================
-- COMPLEX BUSINESS QUERIES
-- ============================================

-- Monthly sales report by product category
SELECT 
    cat.category_name,
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM categories cat
INNER JOIN products p ON cat.category_id = p.category_id
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'completed'
  AND o.order_date >= '2026-01-01'
GROUP BY cat.category_name, DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month, total_revenue DESC;

-- Customer purchase history with product details
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_id,
    o.order_date,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total,
    o.status
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
WHERE c.customer_id = 1
ORDER BY o.order_date DESC, o.order_id, p.product_name;

-- Products with average rating
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    COUNT(r.review_id) AS total_reviews,
    AVG(r.rating) AS average_rating,
    MIN(r.rating) AS lowest_rating,
    MAX(r.rating) AS highest_rating
FROM products p
INNER JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name, p.price
HAVING COUNT(r.review_id) >= 5  -- At least 5 reviews
ORDER BY average_rating DESC, total_reviews DESC;

-- ============================================
-- JOINING WITH SUBQUERIES
-- ============================================

-- Customers who spent more than average
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(o.total_amount) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(total_amount) AS customer_total
        FROM orders
        GROUP BY customer_id
    ) AS avg_spending
);

-- ============================================
-- PRACTICAL EXAMPLES
-- ============================================

-- Top 10 customers by order count
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spent
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, customer_name, c.email
ORDER BY order_count DESC
LIMIT 10;

-- Products frequently bought together
SELECT 
    p1.product_name AS product1,
    p2.product_name AS product2,
    COUNT(*) AS times_bought_together
FROM order_items oi1
INNER JOIN order_items oi2 ON oi1.order_id = oi2.order_id
INNER JOIN products p1 ON oi1.product_id = p1.product_id
INNER JOIN products p2 ON oi2.product_id = p2.product_id
WHERE oi1.product_id < oi2.product_id
GROUP BY p1.product_name, p2.product_name
HAVING COUNT(*) >= 5
ORDER BY times_bought_together DESC;

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

-- Exercise 1: List all orders with customer names and addresses
-- YOUR CODE HERE:



-- Exercise 2: Find the total revenue per category
-- YOUR CODE HERE:



-- Exercise 3: Get all books with their authors (handle multiple authors)
-- YOUR CODE HERE:



-- Exercise 4: Find customers who have reviewed products they purchased
-- YOUR CODE HERE:



-- Exercise 5: Calculate the average order value per customer segment
-- Segment based on total spending: Bronze (<$100), Silver ($100-$500), Gold (>$500)
-- YOUR CODE HERE:



-- ============================================
-- NOTES
-- ============================================

/*
INNER JOIN KEY POINTS:

1. Returns only matching rows from both tables
2. Non-matching rows are excluded
3. Use table aliases for readability (c, o, p, etc.)
4. Join condition goes in ON clause
5. Filter conditions go in WHERE clause
6. Can join multiple tables in sequence
7. Performance depends on indexes on join columns

COMMON PATTERNS:
- Parent-Child: customers ⟷ orders
- Many-to-Many: students ⟷ courses (via enrollments)
- Self-Join: employees ⟷ managers
- Multiple Levels: customers ⟷ orders ⟷ order_items ⟷ products

PERFORMANCE TIPS:
- Index foreign key columns
- Use EXPLAIN to analyze query performance
- Join on indexed columns when possible
- Be careful with Cartesian products
- Consider using views for complex joins

BEST PRACTICES:
- Always use explicit JOIN syntax (INNER JOIN)
- Use meaningful table aliases
- Fully qualify column names when ambiguous
- Group logically related joins together
- Comment complex join conditions
*/
