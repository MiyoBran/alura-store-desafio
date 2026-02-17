-- ============================================================================
-- Library Management System - Complete Database Schema
-- ============================================================================
-- Description: Comprehensive library system for managing books, members,
--              loans, reservations, and fines.
-- Database: MySQL / PostgreSQL compatible
-- Author: Database Modeling Study
-- ============================================================================

-- Drop tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS fines;
DROP TABLE IF EXISTS reservations;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS book_copies;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS publishers;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS librarians;
DROP TABLE IF EXISTS branches;

-- ============================================================================
-- LIBRARY BRANCHES
-- ============================================================================

CREATE TABLE branches (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(2),
    zip_code VARCHAR(10),
    phone VARCHAR(20),
    email VARCHAR(100),
    opening_hours VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- LIBRARIANS (STAFF)
-- ============================================================================

CREATE TABLE librarians (
    librarian_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    branch_id INT NOT NULL,
    position VARCHAR(50) DEFAULT 'Librarian',
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

-- ============================================================================
-- MEMBERS (LIBRARY PATRONS)
-- ============================================================================

CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    member_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    date_of_birth DATE,
    membership_date DATE NOT NULL,
    membership_expiry DATE NOT NULL,
    branch_id INT NOT NULL,
    status ENUM('active', 'suspended', 'expired') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

-- ============================================================================
-- AUTHORS
-- ============================================================================

CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_last_name (last_name),
    INDEX idx_full_name (first_name, last_name)
);

-- ============================================================================
-- PUBLISHERS
-- ============================================================================

CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    publisher_name VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(50),
    website VARCHAR(200),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CATEGORIES
-- ============================================================================

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- ============================================================================
-- BOOKS (CATALOG)
-- ============================================================================

CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(13) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    subtitle VARCHAR(200),
    publisher_id INT,
    publication_year INT,
    edition VARCHAR(20),
    language VARCHAR(50) DEFAULT 'English',
    pages INT,
    category_id INT,
    description TEXT,
    cover_image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    INDEX idx_isbn (isbn),
    INDEX idx_title (title),
    INDEX idx_category (category_id)
);

-- ============================================================================
-- BOOK AUTHORS (MANY-TO-MANY JUNCTION TABLE)
-- ============================================================================

CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT DEFAULT 1,  -- For co-authored books
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- ============================================================================
-- BOOK COPIES (PHYSICAL ITEMS)
-- ============================================================================

CREATE TABLE book_copies (
    copy_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    barcode VARCHAR(50) UNIQUE NOT NULL,
    branch_id INT NOT NULL,
    acquisition_date DATE NOT NULL,
    condition_status ENUM('new', 'good', 'fair', 'poor', 'damaged') DEFAULT 'new',
    location VARCHAR(50),  -- Shelf location
    status ENUM('available', 'on_loan', 'reserved', 'maintenance', 'lost') DEFAULT 'available',
    price DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    INDEX idx_barcode (barcode),
    INDEX idx_status (status),
    INDEX idx_book_branch (book_id, branch_id)
);

-- ============================================================================
-- LOANS (CHECKOUT RECORDS)
-- ============================================================================

CREATE TABLE loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    librarian_id INT,
    checkout_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    renewal_count INT DEFAULT 0,
    status ENUM('active', 'returned', 'overdue', 'lost') DEFAULT 'active',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (librarian_id) REFERENCES librarians(librarian_id) ON DELETE SET NULL,
    INDEX idx_member (member_id),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date),
    CHECK (due_date >= checkout_date),
    CHECK (return_date IS NULL OR return_date >= checkout_date)
);

-- ============================================================================
-- RESERVATIONS (HOLD REQUESTS)
-- ============================================================================

CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    status ENUM('pending', 'ready', 'fulfilled', 'cancelled', 'expired') DEFAULT 'pending',
    branch_id INT NOT NULL,
    notified_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    INDEX idx_member (member_id),
    INDEX idx_book (book_id),
    INDEX idx_status (status)
);

-- ============================================================================
-- FINES
-- ============================================================================

CREATE TABLE fines (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT NOT NULL,
    member_id INT NOT NULL,
    fine_amount DECIMAL(10, 2) NOT NULL,
    reason VARCHAR(100) NOT NULL,
    fine_date DATE NOT NULL,
    paid_amount DECIMAL(10, 2) DEFAULT 0.00,
    payment_date DATE,
    status ENUM('pending', 'paid', 'waived') DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    INDEX idx_member (member_id),
    INDEX idx_status (status),
    CHECK (fine_amount >= 0),
    CHECK (paid_amount >= 0),
    CHECK (paid_amount <= fine_amount)
);

-- ============================================================================
-- INSERT SAMPLE DATA
-- ============================================================================

-- Branches
INSERT INTO branches (branch_name, address, city, state, zip_code, phone, email, opening_hours)
VALUES
    ('Central Library', '123 Main St', 'Springfield', 'IL', '62701', '555-0101', 'central@library.org', 'Mon-Fri 8AM-8PM, Sat-Sun 10AM-6PM'),
    ('North Branch', '456 Oak Ave', 'Springfield', 'IL', '62702', '555-0102', 'north@library.org', 'Mon-Fri 9AM-7PM, Sat 10AM-5PM'),
    ('South Branch', '789 Elm St', 'Springfield', 'IL', '62703', '555-0103', 'south@library.org', 'Mon-Fri 9AM-6PM, Sat 10AM-4PM');

-- Librarians
INSERT INTO librarians (employee_number, first_name, last_name, email, phone, hire_date, branch_id, position)
VALUES
    ('LIB001', 'John', 'Smith', 'john.smith@library.org', '555-1001', '2018-03-15', 1, 'Head Librarian'),
    ('LIB002', 'Sarah', 'Johnson', 'sarah.j@library.org', '555-1002', '2019-06-20', 1, 'Librarian'),
    ('LIB003', 'Michael', 'Brown', 'michael.b@library.org', '555-1003', '2020-01-10', 2, 'Librarian'),
    ('LIB004', 'Emily', 'Davis', 'emily.d@library.org', '555-1004', '2021-09-05', 3, 'Librarian');

-- Members
INSERT INTO members (member_number, first_name, last_name, email, phone, address, city, state, zip_code, date_of_birth, membership_date, membership_expiry, branch_id, status)
VALUES
    ('MEM001', 'Alice', 'Williams', 'alice.w@email.com', '555-2001', '100 Pine St', 'Springfield', 'IL', '62701', '1985-04-12', '2023-01-15', '2024-01-15', 1, 'active'),
    ('MEM002', 'Bob', 'Miller', 'bob.m@email.com', '555-2002', '200 Maple Ave', 'Springfield', 'IL', '62702', '1990-08-22', '2023-02-20', '2024-02-20', 1, 'active'),
    ('MEM003', 'Carol', 'Wilson', 'carol.w@email.com', '555-2003', '300 Birch Rd', 'Springfield', 'IL', '62703', '1978-11-30', '2023-03-10', '2024-03-10', 2, 'active'),
    ('MEM004', 'David', 'Taylor', 'david.t@email.com', '555-2004', '400 Cedar Ln', 'Springfield', 'IL', '62701', '2000-02-14', '2023-04-05', '2024-04-05', 2, 'active'),
    ('MEM005', 'Eva', 'Anderson', 'eva.a@email.com', '555-2005', '500 Spruce Dr', 'Springfield', 'IL', '62702', '1995-07-08', '2023-05-12', '2024-05-12', 3, 'active');

-- Authors
INSERT INTO authors (first_name, last_name, birth_date, nationality, biography)
VALUES
    ('J.K.', 'Rowling', '1965-07-31', 'British', 'Author of Harry Potter series'),
    ('George', 'Orwell', '1903-06-25', 'British', 'Author of 1984 and Animal Farm'),
    ('Jane', 'Austen', '1775-12-16', 'British', 'Author of Pride and Prejudice'),
    ('Mark', 'Twain', '1835-11-30', 'American', 'Author of Tom Sawyer'),
    ('Agatha', 'Christie', '1890-09-15', 'British', 'Mystery writer'),
    ('Isaac', 'Asimov', '1920-01-02', 'American', 'Science fiction author');

-- Publishers
INSERT INTO publishers (publisher_name, country, website)
VALUES
    ('Penguin Random House', 'USA', 'www.penguinrandomhouse.com'),
    ('HarperCollins', 'USA', 'www.harpercollins.com'),
    ('Simon & Schuster', 'USA', 'www.simonandschuster.com'),
    ('Macmillan', 'UK', 'www.macmillan.com');

-- Categories
INSERT INTO categories (category_name, description, parent_category_id)
VALUES
    ('Fiction', 'Fictional works', NULL),
    ('Non-Fiction', 'Non-fictional works', NULL),
    ('Science Fiction', 'Sci-fi novels', 1),
    ('Mystery', 'Mystery and detective novels', 1),
    ('Romance', 'Romance novels', 1),
    ('Biography', 'Biographies', 2),
    ('History', 'Historical works', 2);

-- Books
INSERT INTO books (isbn, title, publisher_id, publication_year, category_id, language, pages, description)
VALUES
    ('9780439708180', 'Harry Potter and the Sorcerer''s Stone', 1, 1997, 1, 'English', 309, 'First book in Harry Potter series'),
    ('9780451524935', '1984', 2, 1949, 1, 'English', 328, 'Dystopian social science fiction'),
    ('9780141439518', 'Pride and Prejudice', 1, 1813, 5, 'English', 432, 'Classic romance novel'),
    ('9780062073488', 'And Then There Were None', 3, 1939, 4, 'English', 272, 'Mystery novel'),
    ('9780553293357', 'Foundation', 4, 1951, 3, 'English', 255, 'Science fiction novel');

-- Book Authors
INSERT INTO book_authors (book_id, author_id, author_order)
VALUES
    (1, 1, 1),
    (2, 2, 1),
    (3, 3, 1),
    (4, 5, 1),
    (5, 6, 1);

-- Book Copies
INSERT INTO book_copies (book_id, barcode, branch_id, acquisition_date, condition_status, location, status, price)
VALUES
    (1, 'BC001001', 1, '2023-01-10', 'good', 'A-101', 'available', 19.99),
    (1, 'BC001002', 1, '2023-01-10', 'good', 'A-102', 'on_loan', 19.99),
    (1, 'BC001003', 2, '2023-01-15', 'new', 'B-201', 'available', 19.99),
    (2, 'BC002001', 1, '2023-02-01', 'good', 'A-150', 'available', 14.99),
    (2, 'BC002002', 2, '2023-02-01', 'fair', 'B-220', 'available', 14.99),
    (3, 'BC003001', 1, '2023-02-10', 'new', 'A-200', 'on_loan', 12.99),
    (3, 'BC003002', 3, '2023-02-10', 'good', 'C-301', 'available', 12.99),
    (4, 'BC004001', 2, '2023-03-01', 'good', 'B-250', 'available', 16.99),
    (5, 'BC005001', 1, '2023-03-05', 'new', 'A-300', 'available', 15.99),
    (5, 'BC005002', 3, '2023-03-05', 'good', 'C-350', 'on_loan', 15.99);

-- Loans
INSERT INTO loans (copy_id, member_id, librarian_id, checkout_date, due_date, return_date, status)
VALUES
    (2, 1, 1, '2024-01-10', '2024-01-24', '2024-01-20', 'returned'),
    (6, 2, 2, '2024-01-15', '2024-01-29', NULL, 'active'),
    (10, 3, 3, '2024-01-20', '2024-02-03', NULL, 'active'),
    (2, 4, 1, '2024-01-25', '2024-02-08', NULL, 'overdue');

-- Reservations
INSERT INTO reservations (book_id, member_id, reservation_date, expiry_date, status, branch_id)
VALUES
    (1, 5, '2024-01-28', '2024-02-11', 'pending', 3),
    (3, 1, '2024-01-29', '2024-02-12', 'ready', 1);

-- Fines
INSERT INTO fines (loan_id, member_id, fine_amount, reason, fine_date, paid_amount, status)
VALUES
    (4, 4, 5.00, 'Overdue - 5 days late', '2024-02-13', 0.00, 'pending');

-- ============================================================================
-- USEFUL QUERIES AND VIEWS
-- ============================================================================

-- View: Books with authors
CREATE OR REPLACE VIEW vw_books_with_authors AS
SELECT 
    b.book_id,
    b.isbn,
    b.title,
    GROUP_CONCAT(CONCAT(a.first_name, ' ', a.last_name) ORDER BY ba.author_order SEPARATOR ', ') AS authors,
    p.publisher_name,
    b.publication_year,
    c.category_name
FROM books b
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
LEFT JOIN categories c ON b.category_id = c.category_id
GROUP BY b.book_id, b.isbn, b.title, p.publisher_name, b.publication_year, c.category_name;

-- View: Available books by branch
CREATE OR REPLACE VIEW vw_available_books AS
SELECT 
    br.branch_name,
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) AS author,
    bc.barcode,
    bc.location,
    bc.condition_status
FROM book_copies bc
JOIN books b ON bc.book_id = b.book_id
JOIN branches br ON bc.branch_id = br.branch_id
LEFT JOIN book_authors ba ON b.book_id = ba.book_id AND ba.author_order = 1
LEFT JOIN authors a ON ba.author_id = a.author_id
WHERE bc.status = 'available'
ORDER BY br.branch_name, b.title;

-- View: Active loans with overdue status
CREATE OR REPLACE VIEW vw_active_loans AS
SELECT 
    l.loan_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    m.email AS member_email,
    b.title AS book_title,
    bc.barcode,
    l.checkout_date,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) AS days_overdue,
    l.status
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
WHERE l.status IN ('active', 'overdue')
ORDER BY l.due_date;

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Already created inline with tables, but additional indexes:
CREATE INDEX idx_loans_checkout_date ON loans(checkout_date);
CREATE INDEX idx_members_status ON members(status);
CREATE INDEX idx_books_publication_year ON books(publication_year);

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
