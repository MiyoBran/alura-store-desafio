-- E-COMMERCE DATABASE SCHEMA
-- Complete sample database for an online store

-- ============================================
-- DROP TABLES (if exists) - For clean reinstall
-- ============================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS shopping_cart_items;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS shopping_carts;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;

-- ============================================
-- CREATE TABLES
-- ============================================

-- Customers table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    
    INDEX idx_email (email),
    INDEX idx_last_name (last_name)
);

-- Categories table (with hierarchy support)
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL,
    parent_category_id INT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
        ON DELETE SET NULL,
    INDEX idx_parent (parent_category_id)
);

-- Products table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    sku VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    cost DECIMAL(10, 2),
    category_id INT,
    stock_quantity INT DEFAULT 0,
    reorder_level INT DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    weight_kg DECIMAL(6, 2),
    dimensions VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON DELETE SET NULL,
    INDEX idx_category (category_id),
    INDEX idx_price (price),
    INDEX idx_sku (sku),
    CONSTRAINT chk_price CHECK (price >= 0),
    CONSTRAINT chk_stock CHECK (stock_quantity >= 0)
);

-- Addresses table
CREATE TABLE addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    address_type ENUM('billing', 'shipping') DEFAULT 'shipping',
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) DEFAULT 'USA',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE,
    INDEX idx_customer (customer_id)
);

-- Orders table
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    shipping_address_id INT,
    billing_address_id INT,
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    shipping_cost DECIMAL(10, 2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    payment_method VARCHAR(50),
    tracking_number VARCHAR(100),
    shipped_date TIMESTAMP NULL,
    delivered_date TIMESTAMP NULL,
    notes TEXT,
    
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE RESTRICT,
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id)
        ON DELETE SET NULL,
    FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id)
        ON DELETE SET NULL,
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_order_date (order_date)
);

-- Order Items table (junction table)
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    line_total DECIMAL(10, 2) AS (quantity * unit_price - discount_amount) STORED,
    
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE RESTRICT,
    INDEX idx_order (order_id),
    INDEX idx_product (product_id),
    CONSTRAINT chk_quantity CHECK (quantity > 0),
    CONSTRAINT chk_unit_price CHECK (unit_price >= 0)
);

-- Shopping Cart table
CREATE TABLE shopping_carts (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
);

-- Shopping Cart Items table
CREATE TABLE shopping_cart_items (
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (cart_id) REFERENCES shopping_carts(cart_id)
        ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE CASCADE,
    UNIQUE KEY unique_cart_product (cart_id, product_id),
    CONSTRAINT chk_cart_quantity CHECK (quantity > 0)
);

-- Reviews table
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL,
    title VARCHAR(200),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count INT DEFAULT 0,
    
    FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE,
    UNIQUE KEY unique_product_customer (product_id, customer_id),
    INDEX idx_product (product_id),
    INDEX idx_rating (rating),
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
);

-- ============================================
-- SAMPLE DATA
-- ============================================

-- Insert Customers
INSERT INTO customers (first_name, last_name, email, phone, password_hash) VALUES
('John', 'Doe', 'john.doe@email.com', '555-0101', 'hash1'),
('Jane', 'Smith', 'jane.smith@email.com', '555-0102', 'hash2'),
('Bob', 'Johnson', 'bob.johnson@email.com', '555-0103', 'hash3'),
('Alice', 'Williams', 'alice.williams@email.com', '555-0104', 'hash4'),
('Charlie', 'Brown', 'charlie.brown@email.com', '555-0105', 'hash5');

-- Insert Categories
INSERT INTO categories (category_name, parent_category_id, description) VALUES
('Electronics', NULL, 'Electronic devices and accessories'),
('Computers', 1, 'Desktop and laptop computers'),
('Accessories', 1, 'Computer accessories'),
('Clothing', NULL, 'Apparel and fashion'),
('Books', NULL, 'Physical and digital books');

-- Insert Products
INSERT INTO products (product_name, sku, description, price, cost, category_id, stock_quantity) VALUES
('MacBook Pro 16"', 'MBP-16-001', 'High-performance laptop', 2499.99, 1800.00, 2, 15),
('Dell XPS 13', 'DELL-XPS-001', 'Compact ultrabook', 1299.99, 950.00, 2, 20),
('Wireless Mouse', 'MOUSE-001', 'Ergonomic wireless mouse', 29.99, 12.00, 3, 100),
('Mechanical Keyboard', 'KB-MECH-001', 'RGB mechanical keyboard', 89.99, 40.00, 3, 50),
('4K Monitor 27"', 'MON-4K-27-001', '27-inch 4K display', 399.99, 250.00, 1, 30),
('USB-C Hub', 'HUB-USBC-001', '7-in-1 USB-C hub', 49.99, 20.00, 3, 75),
('Wireless Headphones', 'HEAD-WL-001', 'Noise-cancelling headphones', 199.99, 100.00, 1, 40),
('T-Shirt', 'SHIRT-001', 'Cotton t-shirt', 19.99, 8.00, 4, 200),
('Jeans', 'JEANS-001', 'Denim jeans', 49.99, 25.00, 4, 150),
('Database Design Book', 'BOOK-DB-001', 'Learn database modeling', 39.99, 15.00, 5, 60);

-- Insert Addresses
INSERT INTO addresses (customer_id, address_type, street_address, city, state, postal_code, is_default) VALUES
(1, 'shipping', '123 Main St', 'New York', 'NY', '10001', TRUE),
(1, 'billing', '123 Main St', 'New York', 'NY', '10001', FALSE),
(2, 'shipping', '456 Oak Ave', 'Los Angeles', 'CA', '90001', TRUE),
(3, 'shipping', '789 Pine Rd', 'Chicago', 'IL', '60601', TRUE),
(4, 'shipping', '321 Elm St', 'Houston', 'TX', '77001', TRUE);

-- Insert Shopping Carts
INSERT INTO shopping_carts (customer_id) VALUES (1), (2), (3);

-- Insert Orders
INSERT INTO orders (customer_id, status, shipping_address_id, billing_address_id, subtotal, tax_amount, shipping_cost, total_amount, payment_method) VALUES
(1, 'delivered', 1, 2, 2529.98, 202.40, 0.00, 2732.38, 'credit_card'),
(2, 'shipped', 3, 3, 139.98, 11.20, 9.99, 161.17, 'paypal'),
(3, 'processing', 4, 4, 449.98, 36.00, 15.00, 500.98, 'credit_card'),
(1, 'pending', 1, 2, 89.97, 7.20, 5.99, 103.16, 'credit_card');

-- Insert Order Items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 2499.99),
(1, 3, 1, 29.99),
(2, 4, 1, 89.99),
(2, 6, 1, 49.99),
(3, 5, 1, 399.99),
(3, 6, 1, 49.99),
(4, 8, 3, 19.99),
(4, 9, 1, 29.99);

-- Insert Reviews
INSERT INTO reviews (product_id, customer_id, rating, title, comment, is_verified_purchase) VALUES
(1, 1, 5, 'Excellent laptop!', 'Best laptop I ever owned. Fast and reliable.', TRUE),
(3, 1, 4, 'Good mouse', 'Comfortable to use, battery lasts long.', TRUE),
(4, 2, 5, 'Love this keyboard!', 'Great typing experience, RGB is beautiful.', TRUE),
(6, 2, 4, 'Useful hub', 'Works well with all my devices.', TRUE),
(5, 3, 5, 'Amazing display', 'Colors are vibrant, perfect for photo editing.', TRUE);

-- ============================================
-- USEFUL VIEWS
-- ============================================

-- Customer order summary view
CREATE VIEW customer_order_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS lifetime_value,
    MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, customer_name, c.email;

-- Product inventory view
CREATE VIEW product_inventory AS
SELECT 
    p.product_id,
    p.product_name,
    p.sku,
    c.category_name,
    p.price,
    p.stock_quantity,
    p.reorder_level,
    CASE 
        WHEN p.stock_quantity = 0 THEN 'Out of Stock'
        WHEN p.stock_quantity < p.reorder_level THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status,
    COALESCE(AVG(r.rating), 0) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name, p.sku, c.category_name, 
         p.price, p.stock_quantity, p.reorder_level;

-- Order details view
CREATE VIEW order_details AS
SELECT 
    o.order_id,
    o.order_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    o.status,
    COUNT(oi.order_item_id) AS item_count,
    o.subtotal,
    o.tax_amount,
    o.shipping_cost,
    o.total_amount,
    CONCAT(sa.street_address, ', ', sa.city, ', ', sa.state) AS shipping_address
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN addresses sa ON o.shipping_address_id = sa.address_id
GROUP BY o.order_id, o.order_date, customer_name, c.email, o.status,
         o.subtotal, o.tax_amount, o.shipping_cost, o.total_amount, shipping_address;

-- ============================================
-- NOTES
-- ============================================

/*
This schema includes:
✓ Customers and authentication
✓ Product catalog with categories
✓ Shopping cart functionality
✓ Order management
✓ Multiple addresses per customer
✓ Product reviews
✓ Inventory tracking
✓ Price and tax calculations

Best Practices Used:
- Foreign key constraints for referential integrity
- Indexes on frequently queried columns
- Check constraints for data validation
- Enums for status fields
- Timestamps for audit trails
- Normalized to 3NF
- Meaningful naming conventions
- Comments for clarity

To Use:
1. Execute this script to create the database
2. Sample data is already inserted
3. Use the views for common queries
4. Modify as needed for your requirements
*/
