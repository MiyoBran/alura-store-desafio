# Indexing Strategies

## Overview

Indexes are the most powerful tool for database query optimization. A well-designed index can make the difference between a query that takes milliseconds and one that takes minutes. This guide covers index types, when to use them, and how to optimize index strategies.

---

## Table of Contents

1. [What is an Index?](#what-is-an-index)
2. [Index Types](#index-types)
3. [Single-Column Indexes](#single-column-indexes)
4. [Composite (Multi-Column) Indexes](#composite-multi-column-indexes)
5. [Covering Indexes](#covering-indexes)
6. [Partial/Filtered Indexes](#partialfiltered-indexes)
7. [Full-Text Indexes](#full-text-indexes)
8. [Spatial Indexes](#spatial-indexes)
9. [When to Create Indexes](#when-to-create-indexes)
10. [Index Maintenance](#index-maintenance)
11. [Common Pitfalls](#common-pitfalls)

---

## What is an Index?

An index is a data structure that improves the speed of data retrieval operations on a database table at the cost of additional storage and slower writes.

### Analogy

**Without Index:** Like finding a word in a book by reading every page sequentially.

**With Index:** Like using a book's index to jump directly to the page you need.

### How Indexes Work

Most databases use **B-Tree** (balanced tree) indexes:

```
         [50]
        /    \
    [25]      [75]
    /  \      /  \
 [10][35] [60][90]
```

- Logarithmic search time: O(log n)
- Keeps data sorted
- Allows range queries
- Self-balancing

### Index Overhead

**Benefits:**
- Fast SELECT queries
- Fast WHERE filtering
- Fast JOIN operations
- Fast ORDER BY operations

**Costs:**
- Storage space (10-30% of table size)
- Slower INSERT operations
- Slower UPDATE operations
- Slower DELETE operations
- Index maintenance overhead

---

## Index Types

### 1. B-Tree Index (Default)

The most common index type. Good for:
- Equality comparisons (=)
- Range queries (<, >, BETWEEN)
- Sorting (ORDER BY)
- Prefix matching (LIKE 'abc%')

```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_products_price ON products(price);
```

**Use for:** Most general-purpose indexing needs.

### 2. Hash Index

Fast for equality comparisons only.

```sql
-- PostgreSQL
CREATE INDEX idx_users_uuid ON users USING HASH (uuid);

-- MySQL (MEMORY storage engine)
CREATE TABLE sessions (
    session_id CHAR(32),
    KEY USING HASH (session_id)
) ENGINE=MEMORY;
```

**Use for:** Exact match lookups, no range queries needed.

**Limitations:** No ORDER BY, no <, >, BETWEEN, no LIKE.

### 3. Full-Text Index

Optimized for text search.

```sql
-- MySQL
CREATE FULLTEXT INDEX idx_articles_content ON articles(title, body);

SELECT * FROM articles
WHERE MATCH(title, body) AGAINST ('database indexing');

-- PostgreSQL (GIN index)
CREATE INDEX idx_articles_search ON articles USING GIN (to_tsvector('english', body));

SELECT * FROM articles
WHERE to_tsvector('english', body) @@ to_tsquery('database & indexing');
```

**Use for:** Text search, natural language queries, search engines.

### 4. Spatial Index (R-Tree)

For geographic/geometric data.

```sql
-- MySQL
CREATE SPATIAL INDEX idx_locations ON stores(location);

SELECT * FROM stores
WHERE ST_Distance_Sphere(location, POINT(-73.9857, 40.7484)) < 5000;

-- PostgreSQL (PostGIS)
CREATE INDEX idx_locations ON stores USING GIST (location);

SELECT * FROM stores
WHERE ST_DWithin(location, ST_MakePoint(-73.9857, 40.7484)::geography, 5000);
```

**Use for:** Geographic queries, spatial relationships, proximity searches.

### 5. Bitmap Index

Efficient for low-cardinality columns (few distinct values).

```sql
-- Oracle
CREATE BITMAP INDEX idx_users_gender ON users(gender);
CREATE BITMAP INDEX idx_users_is_active ON users(is_active);
```

**Use for:** Data warehouses, OLAP, columns with few distinct values.

**Not available in:** MySQL, PostgreSQL (use B-tree instead).

### 6. Expression/Functional Index

Index on a computed value.

```sql
-- Index on lowercase email for case-insensitive search
CREATE INDEX idx_users_email_lower ON users(LOWER(email));

SELECT * FROM users WHERE LOWER(email) = 'user@example.com';

-- Index on extracted year
CREATE INDEX idx_orders_year ON orders(YEAR(order_date));

SELECT * FROM orders WHERE YEAR(order_date) = 2024;
```

**Use for:** Frequent queries on computed values or functions.

---

## Single-Column Indexes

Best for queries filtering or sorting by one column.

### Example: Email Lookup

```sql
CREATE INDEX idx_users_email ON users(email);

-- Fast query
SELECT * FROM users WHERE email = 'user@example.com';
-- Uses idx_users_email
```

### Example: Date Range

```sql
CREATE INDEX idx_orders_date ON orders(order_date);

-- Fast query
SELECT * FROM orders 
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31';
-- Uses idx_orders_date
```

### When to Use Single-Column Indexes

- Column frequently used in WHERE clause alone
- Column used for sorting (ORDER BY)
- Column used in JOIN conditions
- High cardinality (many distinct values)

### When NOT to Use

- Low cardinality (e.g., boolean, gender) - unless very large table
- Column rarely queried
- Table is very small (<1000 rows)

---

## Composite (Multi-Column) Indexes

Index on multiple columns. **Order matters!**

### Column Order Rule

**Put the most selective column first!**

```sql
-- Good: email is highly selective
CREATE INDEX idx_users_email_status ON users(email, status);

-- Less optimal: status has few values
CREATE INDEX idx_users_status_email ON users(status, email);
```

### Left-Prefix Rule

A composite index can be used for queries on:
- All columns in the index
- Left-most prefix of columns

```sql
CREATE INDEX idx_name_city_age ON users(last_name, city, age);

-- Can use index:
WHERE last_name = 'Smith'
WHERE last_name = 'Smith' AND city = 'NYC'
WHERE last_name = 'Smith' AND city = 'NYC' AND age > 25

-- CANNOT use index efficiently:
WHERE city = 'NYC'  -- Doesn't start with last_name
WHERE age = 25      -- Doesn't start with last_name
WHERE city = 'NYC' AND age = 25  -- Doesn't start with last_name
```

### Example: Multi-Column Query

```sql
-- Without composite index (slow)
SELECT * FROM orders 
WHERE customer_id = 123 AND order_date > '2024-01-01';

-- Create composite index
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

-- Now fast!
SELECT * FROM orders 
WHERE customer_id = 123 AND order_date > '2024-01-01';
```

### Equality Before Range

Put equality comparisons before range comparisons in index order.

```sql
-- Good: equality (customer_id) before range (order_date)
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

WHERE customer_id = 123 AND order_date > '2024-01-01';

-- Less optimal: range before equality
CREATE INDEX idx_orders_date_customer ON orders(order_date, customer_id);

WHERE customer_id = 123 AND order_date > '2024-01-01';
-- Can only use order_date part of index
```

### Example: Equality + Equality + Range

```sql
CREATE INDEX idx_users_status_city_created ON users(status, city, created_at);

-- Optimal query
WHERE status = 'active' AND city = 'NYC' AND created_at > '2024-01-01';
-- Uses all three columns in index
```

---

## Covering Indexes

An index that contains all columns needed for a query. The database can answer the query using only the index, without accessing the table.

### Example: Query Only Indexed Columns

```sql
CREATE INDEX idx_users_email_name ON users(email, first_name, last_name);

-- Covering query - no table access needed!
SELECT first_name, last_name 
FROM users 
WHERE email = 'user@example.com';
-- Entire query answered from index
```

### Include Clause (SQL Server, PostgreSQL 11+)

Add non-key columns to index without affecting sort order.

```sql
-- PostgreSQL
CREATE INDEX idx_orders_customer_with_total 
ON orders(customer_id) INCLUDE (total, order_date);

SELECT total, order_date 
FROM orders 
WHERE customer_id = 123;
-- Answered entirely from index
```

### Benefits

- No table lookups required
- Faster query execution
- Less I/O

### Example: Covering Index for Reporting

```sql
-- Report query
SELECT 
    DATE(order_date) as day,
    COUNT(*) as order_count,
    SUM(total) as revenue
FROM orders
WHERE order_date >= '2024-01-01'
GROUP BY DATE(order_date);

-- Covering index
CREATE INDEX idx_orders_date_total ON orders(order_date, total);
-- Query can be answered entirely from index
```

---

## Partial/Filtered Indexes

Index only a subset of rows. Smaller, faster, and more efficient.

### Example: Active Users Only

```sql
-- PostgreSQL
CREATE INDEX idx_active_users_email ON users(email) WHERE is_active = TRUE;

-- MySQL (simulates with prefix)
-- Not directly supported, but can optimize with composite index
CREATE INDEX idx_users_active_email ON users(is_active, email);
```

**Benefits:**
- Smaller index
- Faster to maintain
- Faster queries on filtered subset

### Example: Recent Orders

```sql
-- Index only last 90 days of orders
CREATE INDEX idx_recent_orders ON orders(order_date)
WHERE order_date > CURRENT_DATE - INTERVAL '90 days';

SELECT * FROM orders 
WHERE order_date > CURRENT_DATE - INTERVAL '30 days';
-- Uses smaller, faster partial index
```

### Example: Non-NULL Values

```sql
CREATE INDEX idx_users_phone ON users(phone) WHERE phone IS NOT NULL;

SELECT * FROM users WHERE phone = '555-1234';
-- Smaller index, excludes NULL phone numbers
```

### When to Use

- Majority of queries filter on same condition
- Only subset of data is frequently queried
- Want to reduce index size and maintenance cost

---

## Full-Text Indexes

Specialized indexes for text search.

### MySQL Full-Text

```sql
CREATE TABLE articles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200),
    body TEXT,
    FULLTEXT idx_search (title, body)
);

-- Natural language search
SELECT * FROM articles
WHERE MATCH(title, body) AGAINST ('database optimization');

-- Boolean mode (AND, OR, NOT)
SELECT * FROM articles
WHERE MATCH(title, body) AGAINST ('+database -mysql' IN BOOLEAN MODE);

-- Phrase search
SELECT * FROM articles
WHERE MATCH(title, body) AGAINST ('"database design"' IN BOOLEAN MODE);

-- Relevance score
SELECT 
    title,
    MATCH(title, body) AGAINST ('database optimization') as relevance
FROM articles
WHERE MATCH(title, body) AGAINST ('database optimization')
ORDER BY relevance DESC;
```

### PostgreSQL Full-Text

```sql
-- Add tsvector column
ALTER TABLE articles ADD COLUMN search_vector tsvector;

-- Populate search vector
UPDATE articles
SET search_vector = to_tsvector('english', title || ' ' || body);

-- Create GIN index
CREATE INDEX idx_articles_search ON articles USING GIN(search_vector);

-- Search
SELECT * FROM articles
WHERE search_vector @@ to_tsquery('english', 'database & optimization');

-- Ranking
SELECT 
    title,
    ts_rank(search_vector, to_tsquery('english', 'database & optimization')) as rank
FROM articles
WHERE search_vector @@ to_tsquery('english', 'database & optimization')
ORDER BY rank DESC;
```

### Full-Text Features

- Stemming (running, runs, ran → run)
- Stop words (the, a, an)
- Boolean operators (AND, OR, NOT)
- Phrase search
- Proximity search
- Relevance ranking

---

## Spatial Indexes

For geographic and geometric data.

### MySQL Spatial Index

```sql
CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    name VARCHAR(100),
    location POINT NOT NULL,
    SPATIAL INDEX idx_location (location)
);

-- Insert data
INSERT INTO stores (store_id, name, location)
VALUES (1, 'Store A', ST_GeomFromText('POINT(-73.9857 40.7484)'));

-- Find stores within 5km
SELECT 
    name,
    ST_Distance_Sphere(location, ST_GeomFromText('POINT(-73.9900 40.7500)')) as distance
FROM stores
WHERE ST_Distance_Sphere(location, ST_GeomFromText('POINT(-73.9900 40.7500)')) < 5000
ORDER BY distance;

-- Find stores in bounding box
SELECT * FROM stores
WHERE MBRContains(
    ST_GeomFromText('LINESTRING(-74.0 40.7, -73.9 40.8)'),
    location
);
```

### PostgreSQL with PostGIS

```sql
-- Enable PostGIS
CREATE EXTENSION postgis;

CREATE TABLE stores (
    store_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    location GEOGRAPHY(POINT, 4326)
);

-- Create spatial index
CREATE INDEX idx_stores_location ON stores USING GIST(location);

-- Find nearby stores
SELECT 
    name,
    ST_Distance(location, ST_MakePoint(-73.9857, 40.7484)::geography) as distance
FROM stores
WHERE ST_DWithin(location, ST_MakePoint(-73.9857, 40.7484)::geography, 5000)
ORDER BY distance;
```

---

## When to Create Indexes

### ✅ Create Indexes For

1. **Primary Keys** (automatic in most databases)
2. **Foreign Keys** (for JOIN performance)
3. **Columns in WHERE Clauses**
4. **Columns in ORDER BY**
5. **Columns in GROUP BY**
6. **Columns in JOIN Conditions**
7. **Unique Constraints** (automatic)

### ❌ Don't Index

1. **Very Small Tables** (<1000 rows)
2. **Low Cardinality Columns** (few distinct values) on small-medium tables
3. **Columns with Frequent UPDATEs** 
4. **Large Text/BLOB Columns** (use full-text index instead)
5. **Columns Rarely Used in Queries**

### Decision Framework

```
1. Is this column used in WHERE, JOIN, or ORDER BY? → Consider index
2. How selective is this column? (high cardinality) → Higher priority
3. How often is this query run? → Frequent queries = higher priority
4. How often is this column updated? → Frequent updates = lower priority
5. How large is the table? → Larger tables benefit more from indexes
6. Is this query slow without the index? → Measure with EXPLAIN
```

---

## Index Maintenance

### Analyzing Index Usage

**MySQL:**
```sql
-- Show index usage
SELECT 
    table_name,
    index_name,
    cardinality,
    index_type
FROM information_schema.STATISTICS
WHERE table_schema = 'your_database';

-- Find duplicate indexes
SELECT 
    table_name,
    GROUP_CONCAT(index_name) as indexes,
    column_name
FROM information_schema.STATISTICS
WHERE table_schema = 'your_database'
GROUP BY table_name, column_name
HAVING COUNT(*) > 1;
```

**PostgreSQL:**
```sql
-- Index usage statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;

-- Unused indexes
SELECT 
    schemaname,
    tablename,
    indexname
FROM pg_stat_user_indexes
WHERE idx_scan = 0
AND indexrelname NOT LIKE '%_pkey';

-- Index size
SELECT 
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as size
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;
```

### Rebuilding Indexes

Indexes can become fragmented over time.

**MySQL:**
```sql
-- Rebuild index
ALTER TABLE users DROP INDEX idx_email;
CREATE INDEX idx_email ON users(email);

-- Or optimize table (rebuilds all indexes)
OPTIMIZE TABLE users;
```

**PostgreSQL:**
```sql
-- Rebuild index
REINDEX INDEX idx_users_email;

-- Rebuild all indexes on table
REINDEX TABLE users;

-- Rebuild concurrently (PostgreSQL 12+) - doesn't lock table
REINDEX INDEX CONCURRENTLY idx_users_email;
```

### Monitoring Index Bloat

```sql
-- PostgreSQL: Check index bloat
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as size,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_scan < 100  -- Low usage
ORDER BY pg_relation_size(indexrelid) DESC;
```

### Dropping Unused Indexes

```sql
-- Be careful! Monitor usage first
DROP INDEX idx_rarely_used;

-- PostgreSQL: Drop concurrently (won't lock table)
DROP INDEX CONCURRENTLY idx_rarely_used;
```

---

## Common Pitfalls

### 1. Over-Indexing

**Problem:** Too many indexes slow down writes and waste space.

**Solution:** Only create indexes that are actually used. Monitor and drop unused indexes.

### 2. Wrong Column Order in Composite Indexes

**Problem:**
```sql
-- Bad: low cardinality first
CREATE INDEX idx_users_status_email ON users(status, email);

WHERE email = 'user@example.com' AND status = 'active';
-- Index not used efficiently
```

**Solution:**
```sql
-- Good: high cardinality first
CREATE INDEX idx_users_email_status ON users(email, status);
```

### 3. Function Calls on Indexed Columns

**Problem:**
```sql
CREATE INDEX idx_users_email ON users(email);

-- Index NOT used!
SELECT * FROM users WHERE LOWER(email) = 'user@example.com';
```

**Solution:**
```sql
-- Create function-based index
CREATE INDEX idx_users_email_lower ON users(LOWER(email));

SELECT * FROM users WHERE LOWER(email) = 'user@example.com';
```

### 4. Leading Wildcards in LIKE

**Problem:**
```sql
CREATE INDEX idx_users_name ON users(name);

-- Index NOT used!
SELECT * FROM users WHERE name LIKE '%Smith%';
```

**Solution:** Use full-text search instead.

```sql
CREATE FULLTEXT INDEX idx_users_name_ft ON users(name);
SELECT * FROM users WHERE MATCH(name) AGAINST ('Smith');
```

### 5. Implicit Type Conversion

**Problem:**
```sql
CREATE INDEX idx_users_user_id ON users(user_id); -- INT type

-- Index NOT used (comparing INT to VARCHAR)
SELECT * FROM users WHERE user_id = '123';
```

**Solution:** Use correct data type.
```sql
SELECT * FROM users WHERE user_id = 123;
```

### 6. Indexing NULLable Columns Ineffectively

**Problem:** B-tree indexes include NULLs, which may not be useful.

**Solution:** Use partial index to exclude NULLs.
```sql
-- PostgreSQL
CREATE INDEX idx_users_phone ON users(phone) WHERE phone IS NOT NULL;
```

---

## Best Practices Summary

### Index Design Checklist

- [ ] Identify slow queries with EXPLAIN
- [ ] Index columns used in WHERE, JOIN, ORDER BY
- [ ] Put high-cardinality columns first in composite indexes
- [ ] Put equality conditions before range conditions
- [ ] Consider covering indexes for frequent queries
- [ ] Use partial indexes for subset queries
- [ ] Monitor index usage regularly
- [ ] Drop unused indexes
- [ ] Rebuild fragmented indexes
- [ ] Document why each index exists

### General Rules

1. **Measure First:** Use EXPLAIN to identify bottlenecks
2. **Start Simple:** Single-column indexes first
3. **Composite Wisely:** Order matters!
4. **Monitor Usage:** Drop unused indexes
5. **Balance:** Reads vs. writes trade-off
6. **Test Changes:** Measure impact on production-like data

### Quick Reference

| Query Pattern | Index Type |
|--------------|-----------|
| WHERE id = 123 | B-Tree single column |
| WHERE email = 'x@y.com' | B-Tree single column |
| WHERE age > 25 | B-Tree single column |
| WHERE status = 'A' AND city = 'NYC' | Composite B-Tree |
| WHERE MATCH(text) AGAINST ('word') | Full-Text |
| WHERE ST_Distance(loc, point) < 1000 | Spatial |
| WHERE LOWER(email) = 'x@y.com' | Function-based |
| Only active users | Partial/Filtered |

---

## Further Reading

- "Use The Index, Luke!" by Markus Winand (book)
- PostgreSQL documentation on indexes
- MySQL documentation on optimization and indexes
- "High Performance MySQL" by Baron Schwartz
- Database-specific EXPLAIN documentation
