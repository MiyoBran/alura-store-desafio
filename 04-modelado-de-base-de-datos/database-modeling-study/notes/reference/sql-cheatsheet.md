# SQL Quick Reference Cheat Sheet

## Data Definition Language (DDL)

### CREATE TABLE
```sql
CREATE TABLE table_name (
    column1 datatype [constraints],
    column2 datatype [constraints],
    ...
    [table_constraints]
);
```

### Common Data Types
```sql
-- Numeric
INT, BIGINT, SMALLINT, TINYINT
DECIMAL(precision, scale)
FLOAT, DOUBLE

-- String
VARCHAR(length)
CHAR(length)
TEXT
ENUM('value1', 'value2', ...)

-- Date/Time
DATE           -- YYYY-MM-DD
TIME           -- HH:MM:SS
DATETIME       -- YYYY-MM-DD HH:MM:SS
TIMESTAMP      -- Auto-updating timestamp

-- Boolean
BOOLEAN        -- TRUE/FALSE
```

### Constraints
```sql
PRIMARY KEY
FOREIGN KEY
UNIQUE
NOT NULL
DEFAULT value
CHECK (condition)
AUTO_INCREMENT  -- MySQL
SERIAL          -- PostgreSQL
```

### ALTER TABLE
```sql
-- Add column
ALTER TABLE table_name ADD column_name datatype;

-- Drop column
ALTER TABLE table_name DROP COLUMN column_name;

-- Modify column
ALTER TABLE table_name MODIFY COLUMN column_name new_datatype;

-- Add constraint
ALTER TABLE table_name ADD CONSTRAINT name FOREIGN KEY (col) REFERENCES other(col);

-- Drop constraint
ALTER TABLE table_name DROP CONSTRAINT constraint_name;
```

### DROP & TRUNCATE
```sql
DROP TABLE table_name;           -- Delete table
DROP TABLE IF EXISTS table_name; -- Safe drop
TRUNCATE TABLE table_name;       -- Delete all data, keep structure
```

---

## Data Manipulation Language (DML)

### SELECT
```sql
-- Basic
SELECT column1, column2 FROM table_name;
SELECT * FROM table_name;
SELECT DISTINCT column FROM table_name;

-- With aliases
SELECT column AS alias_name FROM table;

-- LIMIT
SELECT * FROM table LIMIT 10;
SELECT * FROM table LIMIT 10 OFFSET 20;  -- Skip 20, get next 10
```

### WHERE Clause
```sql
-- Comparison operators
=, !=, <>, <, >, <=, >=

-- Examples
WHERE price > 100
WHERE status = 'active'
WHERE quantity BETWEEN 10 AND 50
WHERE name IN ('Alice', 'Bob', 'Charlie')
WHERE email LIKE '%@gmail.com'
WHERE description IS NULL
WHERE created_at >= '2026-01-01'

-- Logical operators
WHERE condition1 AND condition2
WHERE condition1 OR condition2
WHERE NOT condition
```

### ORDER BY
```sql
SELECT * FROM table ORDER BY column ASC;   -- Ascending (default)
SELECT * FROM table ORDER BY column DESC;  -- Descending
SELECT * FROM table ORDER BY col1, col2 DESC;  -- Multiple columns
```

### INSERT
```sql
-- Single row
INSERT INTO table (col1, col2) VALUES (val1, val2);

-- Multiple rows
INSERT INTO table (col1, col2) VALUES 
    (val1, val2),
    (val3, val4),
    (val5, val6);

-- From SELECT
INSERT INTO table1 SELECT * FROM table2 WHERE condition;
```

### UPDATE
```sql
UPDATE table_name 
SET column1 = value1, column2 = value2
WHERE condition;

-- Example
UPDATE products SET price = price * 1.1 WHERE category = 'Electronics';
```

### DELETE
```sql
DELETE FROM table_name WHERE condition;

-- Delete all rows (careful!)
DELETE FROM table_name;
```

---

## Joins

### INNER JOIN
```sql
SELECT * FROM table1
INNER JOIN table2 ON table1.id = table2.table1_id;
```

### LEFT JOIN (LEFT OUTER JOIN)
```sql
SELECT * FROM table1
LEFT JOIN table2 ON table1.id = table2.table1_id;
```

### RIGHT JOIN (RIGHT OUTER JOIN)
```sql
SELECT * FROM table1
RIGHT JOIN table2 ON table1.id = table2.table1_id;
```

### FULL OUTER JOIN
```sql
SELECT * FROM table1
FULL OUTER JOIN table2 ON table1.id = table2.table1_id;
```

### SELF JOIN
```sql
SELECT e.name, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

### CROSS JOIN
```sql
SELECT * FROM table1 CROSS JOIN table2;
```

---

## Aggregate Functions

```sql
COUNT(*)              -- Count all rows
COUNT(column)         -- Count non-null values
SUM(column)          -- Sum of values
AVG(column)          -- Average
MIN(column)          -- Minimum
MAX(column)          -- Maximum

-- Example
SELECT COUNT(*), AVG(price), SUM(quantity)
FROM products;
```

---

## GROUP BY & HAVING

```sql
-- Group by single column
SELECT category, COUNT(*) 
FROM products 
GROUP BY category;

-- Group by multiple columns
SELECT category, status, COUNT(*)
FROM products
GROUP BY category, status;

-- HAVING (filter after grouping)
SELECT category, AVG(price) AS avg_price
FROM products
GROUP BY category
HAVING AVG(price) > 100;
```

---

## Subqueries

```sql
-- IN subquery
SELECT * FROM products
WHERE category_id IN (SELECT id FROM categories WHERE name = 'Electronics');

-- Scalar subquery
SELECT * FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- Correlated subquery
SELECT * FROM products p
WHERE price > (SELECT AVG(price) FROM products WHERE category_id = p.category_id);

-- EXISTS
SELECT * FROM customers c
WHERE EXISTS (SELECT 1 FROM orders WHERE customer_id = c.id);
```

---

## String Functions

```sql
CONCAT(str1, str2, ...)         -- Concatenate strings
UPPER(string)                   -- Convert to uppercase
LOWER(string)                   -- Convert to lowercase
LENGTH(string)                  -- String length
SUBSTRING(string, start, len)   -- Extract substring
TRIM(string)                    -- Remove leading/trailing spaces
REPLACE(str, from, to)          -- Replace text
LEFT(string, n)                 -- First n characters
RIGHT(string, n)                -- Last n characters
```

---

## Date & Time Functions

```sql
NOW()                           -- Current date and time
CURDATE()                       -- Current date
CURTIME()                       -- Current time
DATE(datetime)                  -- Extract date
YEAR(date)                      -- Extract year
MONTH(date)                     -- Extract month
DAY(date)                       -- Extract day
DATE_ADD(date, INTERVAL n unit) -- Add time
DATE_SUB(date, INTERVAL n unit) -- Subtract time
DATEDIFF(date1, date2)         -- Difference in days

-- Example
SELECT * FROM orders 
WHERE order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY);
```

---

## Numeric Functions

```sql
ROUND(number, decimals)         -- Round number
CEILING(number)                 -- Round up
FLOOR(number)                   -- Round down
ABS(number)                     -- Absolute value
POWER(number, exponent)         -- Exponentiation
SQRT(number)                    -- Square root
MOD(number, divisor)            -- Modulo
```

---

## Conditional Logic

```sql
-- CASE statement
SELECT 
    product_name,
    price,
    CASE 
        WHEN price < 50 THEN 'Cheap'
        WHEN price < 200 THEN 'Moderate'
        ELSE 'Expensive'
    END AS price_category
FROM products;

-- IF (MySQL)
SELECT IF(stock > 0, 'In Stock', 'Out of Stock') FROM products;

-- COALESCE (return first non-null)
SELECT COALESCE(phone, email, 'No contact') FROM customers;

-- NULLIF (return NULL if equal)
SELECT NULLIF(column1, column2) FROM table;
```

---

## Window Functions (Advanced)

```sql
-- ROW_NUMBER
SELECT *, ROW_NUMBER() OVER (ORDER BY price DESC) AS row_num
FROM products;

-- RANK
SELECT *, RANK() OVER (PARTITION BY category ORDER BY price DESC) AS rank
FROM products;

-- LAG and LEAD
SELECT price, LAG(price) OVER (ORDER BY date) AS previous_price
FROM product_prices;
```

---

## Indexes

```sql
-- Create index
CREATE INDEX idx_name ON table (column);
CREATE UNIQUE INDEX idx_name ON table (column);
CREATE INDEX idx_name ON table (col1, col2);  -- Composite

-- Drop index
DROP INDEX idx_name ON table;

-- Show indexes
SHOW INDEXES FROM table;
```

---

## Transactions

```sql
-- Start transaction
START TRANSACTION;  -- or BEGIN;

-- Commit changes
COMMIT;

-- Rollback changes
ROLLBACK;

-- Savepoint
SAVEPOINT savepoint_name;
ROLLBACK TO savepoint_name;
```

---

## Views

```sql
-- Create view
CREATE VIEW view_name AS
SELECT column1, column2
FROM table
WHERE condition;

-- Use view
SELECT * FROM view_name;

-- Drop view
DROP VIEW view_name;
```

---

## Common Patterns

### Pagination
```sql
SELECT * FROM products
ORDER BY product_id
LIMIT 20 OFFSET 40;  -- Page 3 (20 per page)
```

### Top N per Group
```sql
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rn
    FROM products
) ranked
WHERE rn <= 5;
```

### Find Duplicates
```sql
SELECT email, COUNT(*)
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;
```

### Remove Duplicates
```sql
DELETE FROM table
WHERE id NOT IN (
    SELECT MIN(id)
    FROM table
    GROUP BY duplicate_column
);
```

### Pivot Data (MySQL)
```sql
SELECT 
    category,
    SUM(CASE WHEN year = 2024 THEN sales ELSE 0 END) AS sales_2024,
    SUM(CASE WHEN year = 2025 THEN sales ELSE 0 END) AS sales_2025,
    SUM(CASE WHEN year = 2026 THEN sales ELSE 0 END) AS sales_2026
FROM sales_data
GROUP BY category;
```

---

## Performance Tips

```sql
-- Use EXPLAIN to analyze queries
EXPLAIN SELECT * FROM table WHERE condition;

-- Index foreign keys
CREATE INDEX idx_fk ON table (foreign_key_column);

-- Avoid SELECT * in production
-- Instead: SELECT specific_columns

-- Use LIMIT for large result sets
SELECT * FROM large_table LIMIT 1000;

-- Batch operations when possible
INSERT INTO table VALUES (1,2), (3,4), (5,6);  -- Better than 3 inserts
```

---

## Useful Commands

```sql
-- Show tables
SHOW TABLES;

-- Describe table structure  
DESCRIBE table_name;
SHOW COLUMNS FROM table_name;

-- Show create table statement
SHOW CREATE TABLE table_name;

-- Count rows
SELECT COUNT(*) FROM table_name;

-- Database info
SHOW DATABASES;
USE database_name;
```

---

## Quick Reference Summary

| Operation | Syntax |
|-----------|--------|
| Create table | `CREATE TABLE name (...)` |
| Insert data | `INSERT INTO table VALUES (...)` |
| Select data | `SELECT columns FROM table` |
| Update data | `UPDATE table SET col=val WHERE...` |
| Delete data | `DELETE FROM table WHERE...` |
| Join tables | `SELECT * FROM t1 JOIN t2 ON...` |
| Group data | `SELECT col, COUNT(*) FROM t GROUP BY col` |
| Filter groups | `HAVING COUNT(*) > 5` |
| Sort results | `ORDER BY column ASC/DESC` |
| Limit results | `LIMIT n OFFSET m` |

---

**Remember:**
- Always use WHERE when updating or deleting
- Test queries on sample data first
- Use transactions for related operations
- Index columns used in WHERE, JOIN, and ORDER BY
- Back up before major changes

**Practice:** The more you use SQL, the more natural it becomes!
