# Table Partitioning

## Overview

Partitioning divides a large table into smaller, more manageable pieces called partitions, while still treating them as a single logical table. This improves query performance, makes maintenance easier, and enables efficient data archival.

---

## Table of Contents

1. [What is Partitioning?](#what-is-partitioning)
2. [Benefits and Trade-offs](#benefits-and-trade-offs)
3. [Partitioning Types](#partitioning-types)
4. [Range Partitioning](#range-partitioning)
5. [List Partitioning](#list-partitioning)
6. [Hash Partitioning](#hash-partitioning)
7. [Key Partitioning](#key-partitioning)
8. [Composite Partitioning](#composite-partitioning)
9. [Partition Pruning](#partition-pruning)
10. [Maintenance Operations](#maintenance-operations)
11. [Sharding vs Partitioning](#sharding-vs-partitioning)

---

## What is Partitioning?

Partitioning splits a single table into multiple physical storage units (partitions) based on a partitioning key, while maintaining a single logical table interface.

### Analogy

Imagine a file cabinet:
- **Without Partitioning:** All documents in one massive drawer
- **With Partitioning:** Documents organized into separate drawers by year, department, or region

You still interact with "the file cabinet," but each drawer can be accessed, maintained, or archived independently.

### How It Works

```sql
-- Logical table
SELECT * FROM orders WHERE order_date = '2024-01-15';

-- Physical storage (transparent to users)
orders_2023  (not accessed)
orders_2024  (accessed - partition pruning!)
orders_2025  (not accessed)
```

### Key Concepts

**Partition Key:** Column(s) used to determine which partition a row belongs to.

**Partition Pruning:** Database skips irrelevant partitions when executing queries. Huge performance win!

**Transparent:** Applications query the table normally; partitioning is mostly transparent.

---

## Benefits and Trade-offs

### ✅ Benefits

**1. Improved Query Performance**
- Partition pruning reduces data scanned
- Smaller partitions fit in memory better
- Index scans are faster on smaller partitions

**2. Easier Maintenance**
- Archive old data by dropping partitions
- Rebuild indexes on one partition at a time
- Vacuum/analyze smaller chunks (PostgreSQL)
- Optimize individual partitions (MySQL)

**3. Parallel Processing**
- Queries can scan multiple partitions in parallel
- Faster backup/restore (partition-level)

**4. Better Data Organization**
- Separate hot and cold data
- Place partitions on different storage tiers
- Compress old partitions

### ❌ Trade-offs

**1. Complexity**
- More complex schema design
- Partition key must be chosen carefully
- Application changes may be needed

**2. Limitations**
- Partition key cannot be changed easily
- May limit some query optimizations
- Cross-partition queries can be slower

**3. Overhead**
- Metadata overhead for many partitions
- Planning overhead (choosing partitions)
- Not all databases support partitioning equally

---

## Partitioning Types

### Comparison Table

| Type | Best For | Example |
|------|----------|---------|
| Range | Time-series data, continuous values | Orders by date, users by signup date |
| List | Discrete categories | Regions, departments, status codes |
| Hash | Even distribution, no natural key | User IDs, session IDs |
| Key | Similar to hash, uses DB hash function | Primary keys, composite keys |
| Composite | Complex requirements | Range by date + hash by customer |

---

## Range Partitioning

Partition by continuous value ranges. Most common for time-series data.

### MySQL Range Partitioning

```sql
-- Partition orders by year
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE NOT NULL,
    total DECIMAL(10,2)
)
PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p_2022 VALUES LESS THAN (2023),
    PARTITION p_2023 VALUES LESS THAN (2024),
    PARTITION p_2024 VALUES LESS THAN (2025),
    PARTITION p_2025 VALUES LESS THAN (2026),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Query automatically uses partition pruning
SELECT * FROM orders WHERE order_date >= '2024-01-01' AND order_date < '2024-12-31';
-- Only scans p_2024 partition!

-- Check partition usage
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH
FROM information_schema.PARTITIONS
WHERE TABLE_NAME = 'orders';
```

### PostgreSQL Range Partitioning

```sql
-- Create main table
CREATE TABLE orders (
    order_id SERIAL,
    customer_id INT,
    order_date DATE NOT NULL,
    total DECIMAL(10,2)
) PARTITION BY RANGE (order_date);

-- Create partitions
CREATE TABLE orders_2023 PARTITION OF orders
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE orders_2024 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE orders_2025 PARTITION OF orders
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Create default partition for data outside ranges
CREATE TABLE orders_default PARTITION OF orders DEFAULT;

-- Indexes must be created on each partition or the parent
CREATE INDEX idx_orders_customer ON orders (customer_id);
-- Automatically created on all partitions

-- Query uses partition pruning
EXPLAIN SELECT * FROM orders WHERE order_date = '2024-06-15';
-- Shows only orders_2024 is scanned
```

### Range Partitioning by Month

```sql
-- MySQL
CREATE TABLE events (
    event_id BIGINT,
    event_date DATE,
    event_type VARCHAR(50)
)
PARTITION BY RANGE (TO_DAYS(event_date)) (
    PARTITION p_2024_01 VALUES LESS THAN (TO_DAYS('2024-02-01')),
    PARTITION p_2024_02 VALUES LESS THAN (TO_DAYS('2024-03-01')),
    PARTITION p_2024_03 VALUES LESS THAN (TO_DAYS('2024-04-01')),
    -- ... more months
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

```sql
-- PostgreSQL
CREATE TABLE events (
    event_id BIGSERIAL,
    event_date DATE NOT NULL,
    event_type VARCHAR(50)
) PARTITION BY RANGE (event_date);

CREATE TABLE events_2024_01 PARTITION OF events
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE events_2024_02 PARTITION OF events
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
-- ... more months
```

### Automatic Partition Creation (PostgreSQL with pg_partman)

```sql
-- Install extension
CREATE EXTENSION pg_partman;

-- Create partitioned table
CREATE TABLE logs (
    log_id BIGSERIAL,
    log_time TIMESTAMP NOT NULL,
    message TEXT
) PARTITION BY RANGE (log_time);

-- Use pg_partman to auto-create monthly partitions
SELECT partman.create_parent(
    p_parent_table := 'public.logs',
    p_control := 'log_time',
    p_type := 'native',
    p_interval := 'monthly',
    p_premake := 3  -- Create 3 future partitions in advance
);

-- Maintenance runs automatically or via cron
SELECT partman.run_maintenance('public.logs');
```

---

## List Partitioning

Partition by discrete values (categories).

### MySQL List Partitioning

```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    region VARCHAR(50)
)
PARTITION BY LIST COLUMNS (region) (
    PARTITION p_north VALUES IN ('North', 'Northeast', 'Northwest'),
    PARTITION p_south VALUES IN ('South', 'Southeast', 'Southwest'),
    PARTITION p_east VALUES IN ('East'),
    PARTITION p_west VALUES IN ('West'),
    PARTITION p_other VALUES IN (NULL, 'Unknown', 'International')
);

-- Query scans only relevant partition
SELECT * FROM customers WHERE region = 'North';
-- Only p_north partition scanned
```

### PostgreSQL List Partitioning

```sql
CREATE TABLE customers (
    customer_id SERIAL,
    name VARCHAR(100),
    region VARCHAR(50)
) PARTITION BY LIST (region);

CREATE TABLE customers_north PARTITION OF customers
    FOR VALUES IN ('North', 'Northeast', 'Northwest');

CREATE TABLE customers_south PARTITION OF customers
    FOR VALUES IN ('South', 'Southeast', 'Southwest');

CREATE TABLE customers_east PARTITION OF customers
    FOR VALUES IN ('East');

CREATE TABLE customers_west PARTITION OF customers
    FOR VALUES IN ('West');

CREATE TABLE customers_default PARTITION OF customers DEFAULT;
```

### Example: Multi-Tenant by Tenant ID

```sql
-- PostgreSQL
CREATE TABLE tenant_data (
    id SERIAL,
    tenant_id INT NOT NULL,
    data JSONB
) PARTITION BY LIST (tenant_id);

-- One partition per major tenant
CREATE TABLE tenant_data_1 PARTITION OF tenant_data FOR VALUES IN (1);
CREATE TABLE tenant_data_2 PARTITION OF tenant_data FOR VALUES IN (2);
CREATE TABLE tenant_data_3 PARTITION OF tenant_data FOR VALUES IN (3);
-- Small tenants share a partition
CREATE TABLE tenant_data_small PARTITION OF tenant_data FOR VALUES IN (4, 5, 6, 7, 8, 9, 10);
```

---

## Hash Partitioning

Distribute rows evenly across partitions using a hash function. Good when no natural partitioning key exists.

### MySQL Hash Partitioning

```sql
CREATE TABLE users (
    user_id BIGINT PRIMARY KEY,
    username VARCHAR(100),
    email VARCHAR(200)
)
PARTITION BY HASH (user_id)
PARTITIONS 8;  -- Creates 8 partitions
-- Users distributed evenly: p0, p1, p2, ..., p7

-- Query may need to scan all partitions if not filtering by user_id
SELECT * FROM users WHERE email = 'user@example.com';
-- Scans all 8 partitions

-- Query with user_id only scans one partition
SELECT * FROM users WHERE user_id = 12345;
-- Scans only partition (12345 % 8)
```

### PostgreSQL Hash Partitioning

```sql
CREATE TABLE users (
    user_id BIGSERIAL,
    username VARCHAR(100),
    email VARCHAR(200)
) PARTITION BY HASH (user_id);

-- Create hash partitions
CREATE TABLE users_h0 PARTITION OF users FOR VALUES WITH (MODULUS 8, REMAINDER 0);
CREATE TABLE users_h1 PARTITION OF users FOR VALUES WITH (MODULUS 8, REMAINDER 1);
CREATE TABLE users_h2 PARTITION OF users FOR VALUES WITH (MODULUS 8, REMAINDER 2);
CREATE TABLE users_h3 PARTITION OF users FOR VALUES WITH (MODULUS 8, REMAINDER 3);
CREATE TABLE users_h4 PARTITION OF users FOR VALUES WITH (MODULUS 8, REMAINDER 4);
CREATE TABLE users_h5 PARTITION OF users FOR VALUES WITH (MODULUS 8, REMAINDER 5);
CREATE TABLE users_h6 PARTITION OF users FOR VALUES WITH (MODULUS 8, REMAINDER 6);
CREATE TABLE users_h7 PARTITION OF users FOR VALUES WITH (MODULUS 8, REMAINDER 7);
```

### When to Use Hash Partitioning

✅ **Good for:**
- Even data distribution needed
- No natural partitioning key
- Parallel query performance
- Avoid hot spots in writes

❌ **Not good for:**
- Range queries (date ranges, etc.)
- Queries that don't filter by partition key
- When you need to drop/archive old data

---

## Key Partitioning

Similar to hash partitioning, but uses the database's internal hash function. MySQL-specific.

### MySQL Key Partitioning

```sql
-- Partition by primary key
CREATE TABLE sessions (
    session_id CHAR(32) PRIMARY KEY,
    user_id INT,
    created_at TIMESTAMP
)
PARTITION BY KEY (session_id)
PARTITIONS 16;

-- Partition by composite key
CREATE TABLE user_preferences (
    user_id INT,
    preference_key VARCHAR(50),
    preference_value TEXT,
    PRIMARY KEY (user_id, preference_key)
)
PARTITION BY KEY (user_id, preference_key)
PARTITIONS 8;
```

### Difference: Hash vs Key

| Hash | Key |
|------|-----|
| Uses MySQL's hash function | Uses storage engine hash function |
| Explicit column specified | Can use primary key implicitly |
| More control | More flexible |

---

## Composite Partitioning

Combine multiple partitioning strategies. Also called **sub-partitioning**.

### Range-Hash Partitioning

```sql
-- MySQL
CREATE TABLE sales (
    sale_id BIGINT,
    sale_date DATE,
    customer_id INT,
    amount DECIMAL(10,2)
)
PARTITION BY RANGE (YEAR(sale_date))
SUBPARTITION BY HASH (customer_id)
SUBPARTITIONS 4 (
    PARTITION p_2022 VALUES LESS THAN (2023),
    PARTITION p_2023 VALUES LESS THAN (2024),
    PARTITION p_2024 VALUES LESS THAN (2025)
);

-- Results in: p_2022_0, p_2022_1, p_2022_2, p_2022_3, p_2023_0, ...
-- Total: 3 years × 4 hash buckets = 12 partitions
```

### Range-List Partitioning (PostgreSQL)

```sql
-- Partition by year, sub-partition by region
CREATE TABLE sales (
    sale_id BIGSERIAL,
    sale_date DATE NOT NULL,
    region VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2)
) PARTITION BY RANGE (sale_date);

CREATE TABLE sales_2024 PARTITION OF sales
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01')
    PARTITION BY LIST (region);

CREATE TABLE sales_2024_north PARTITION OF sales_2024
    FOR VALUES IN ('North', 'Northeast');

CREATE TABLE sales_2024_south PARTITION OF sales_2024
    FOR VALUES IN ('South', 'Southeast');

CREATE TABLE sales_2024_other PARTITION OF sales_2024 DEFAULT;
```

### When to Use Composite Partitioning

- Large datasets with multiple access patterns
- Combine time-based with geographic distribution
- Balance partition sizes
- Optimize for different query types

---

## Partition Pruning

The database skips scanning irrelevant partitions. **This is why partitioning improves performance!**

### Example: Query with Pruning

```sql
-- Table partitioned by year
SELECT * FROM orders WHERE order_date = '2024-06-15';

-- Execution plan (simplified):
-- Partition Scan: orders_2024 only
-- Partitions skipped: orders_2022, orders_2023, orders_2025
```

### Check Partition Pruning with EXPLAIN

**MySQL:**
```sql
EXPLAIN PARTITIONS
SELECT * FROM orders WHERE order_date >= '2024-01-01' AND order_date < '2024-12-31';

-- Output shows which partitions are accessed
-- partitions: p_2024
```

**PostgreSQL:**
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders WHERE order_date >= '2024-01-01' AND order_date < '2024-12-31';

-- Output shows partition pruning
-- Seq Scan on orders_2024
-- (other partitions not shown = not scanned)
```

### Requirements for Partition Pruning

1. **WHERE clause must filter on partition key**
   ```sql
   -- Good: partition pruning works
   WHERE order_date = '2024-06-15'
   
   -- Bad: partition pruning doesn't work
   WHERE YEAR(order_date) = 2024  -- Function prevents pruning in some DBs
   ```

2. **Use literals or parameters, not computed values**
   ```sql
   -- Good
   WHERE order_date >= '2024-01-01'
   
   -- May not prune optimally
   WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
   ```

3. **Comparison operators must be compatible**
   ```sql
   -- Good: =, <, >, <=, >=, BETWEEN, IN
   WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31'
   
   -- Bad: OR across different partitions
   WHERE order_date = '2023-12-31' OR order_date = '2024-01-01'
   -- Both partitions must be scanned
   ```

---

## Maintenance Operations

### Adding Partitions

**MySQL:**
```sql
-- Add new partition to RANGE
ALTER TABLE orders
ADD PARTITION (PARTITION p_2026 VALUES LESS THAN (2027));

-- Add new partition to LIST
ALTER TABLE customers
ADD PARTITION (PARTITION p_central VALUES IN ('Central'));
```

**PostgreSQL:**
```sql
-- Add new partition
CREATE TABLE orders_2026 PARTITION OF orders
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
```

### Dropping Partitions

**MySQL:**
```sql
-- Drop old partition (fast way to delete old data!)
ALTER TABLE orders DROP PARTITION p_2020;

-- Rows in p_2020 are deleted instantly
```

**PostgreSQL:**
```sql
-- Detach partition (makes it standalone table)
ALTER TABLE orders DETACH PARTITION orders_2020;

-- Then drop or archive it
DROP TABLE orders_2020;
-- Or move to archive schema
ALTER TABLE orders_2020 SET SCHEMA archive;
```

### Splitting Partitions

**MySQL:**
```sql
-- Split a partition into smaller ones
ALTER TABLE orders
REORGANIZE PARTITION p_future INTO (
    PARTITION p_2026 VALUES LESS THAN (2027),
    PARTITION p_2027 VALUES LESS THAN (2028),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

### Merging Partitions

**MySQL:**
```sql
-- Merge multiple partitions
ALTER TABLE orders
REORGANIZE PARTITION p_2020, p_2021, p_2022 INTO (
    PARTITION p_old VALUES LESS THAN (2023)
);
```

### Truncating Partitions

```sql
-- MySQL
ALTER TABLE orders TRUNCATE PARTITION p_2023;

-- PostgreSQL
TRUNCATE TABLE orders_2023;
```

### Rebuilding Partitions

```sql
-- MySQL: Rebuild/optimize a partition
ALTER TABLE orders REBUILD PARTITION p_2024;
ALTER TABLE orders OPTIMIZE PARTITION p_2024;

-- PostgreSQL: Vacuum/analyze a partition
VACUUM ANALYZE orders_2024;
```

---

## Sharding vs Partitioning

### Partitioning

- **One Database Server**
- Splits table into smaller pieces on same server
- Transparent to application
- Improves query performance and maintenance
- Limited by single server capacity

```
Database Server
├── orders_2023 (partition)
├── orders_2024 (partition)
└── orders_2025 (partition)
```

### Sharding

- **Multiple Database Servers**
- Splits data across different servers
- Requires application logic to route queries
- Horizontal scaling (add more servers)
- More complex but higher scalability

```
Database Server 1 (shard 1)
└── users with ID 1-1000000

Database Server 2 (shard 2)
└── users with ID 1000001-2000000

Database Server 3 (shard 3)
└── users with ID 2000001-3000000
```

### When to Use What

| Use Case | Solution |
|----------|----------|
| Single server, time-series data | Range partitioning |
| Single server, large table | Hash partitioning |
| Need to archive old data | Range partitioning |
| Outgrew single server | Sharding |
| Global application, multi-region | Sharding |
| Write throughput limit | Sharding |

---

## Best Practices

### Choosing a Partition Key

1. **Use columns in WHERE clauses**
   - Most queries should filter on partition key
   - Enables partition pruning

2. **Evenly distribute data**
   - Avoid very large or very small partitions
   - Monitor partition sizes

3. **Align with data lifecycle**
   - Archive by date? → Use date range partitioning
   - Delete by tenant? → Use tenant list partitioning

4. **Keep partition count reasonable**
   - Too many partitions = overhead
   - Rule of thumb: 10-100 partitions is typical
   - Thousands of partitions can hurt performance

### Partition Size Guidelines

- **Too small:** Excessive metadata, planning overhead
- **Too large:** Defeats purpose of partitioning
- **Sweet spot:** 10GB - 100GB per partition (depends on use case)

### Indexes on Partitioned Tables

**MySQL:**
```sql
-- Indexes are per-partition automatically
CREATE TABLE orders (...) PARTITION BY RANGE (...);
CREATE INDEX idx_customer ON orders (customer_id);
-- Creates idx_customer on each partition
```

**PostgreSQL:**
```sql
-- Create index on parent table (propagates to all partitions)
CREATE INDEX idx_customer ON orders (customer_id);

-- Or create index on specific partition
CREATE INDEX idx_customer_2024 ON orders_2024 (customer_id);
```

### Monitoring

```sql
-- MySQL: Check partition sizes
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    ROUND(DATA_LENGTH / 1024 / 1024, 2) AS data_mb,
    ROUND(INDEX_LENGTH / 1024 / 1024, 2) AS index_mb
FROM information_schema.PARTITIONS
WHERE TABLE_NAME = 'orders'
ORDER BY PARTITION_NAME;

-- PostgreSQL: Check partition sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE tablename LIKE 'orders_%'
ORDER BY tablename;
```

---

## Common Pitfalls

### 1. Not Including Partition Key in WHERE Clause

```sql
-- Bad: scans all partitions
SELECT * FROM orders WHERE customer_id = 123;

-- Good: scans one partition
SELECT * FROM orders WHERE order_date = '2024-06-15' AND customer_id = 123;
```

### 2. Using Functions on Partition Key

```sql
-- Bad: prevents partition pruning
WHERE YEAR(order_date) = 2024

-- Good: allows partition pruning
WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01'
```

### 3. Too Many Partitions

```sql
-- Bad: daily partitions for 10 years = 3650 partitions!
PARTITION BY RANGE (TO_DAYS(order_date)) ...

-- Good: monthly or yearly partitions
PARTITION BY RANGE (YEAR(order_date)) ...
```

### 4. Forgetting to Add New Partitions

**Solution:** Automate partition creation, or use MAXVALUE catchall.

```sql
-- MySQL
PARTITION p_future VALUES LESS THAN MAXVALUE

-- PostgreSQL: use pg_partman extension
```

### 5. Partition Key Not in Primary Key

Some databases require partition key to be part of the primary key.

```sql
-- MySQL: Partition key must be in PK or unique key
CREATE TABLE orders (
    order_id INT,
    order_date DATE,
    PRIMARY KEY (order_id, order_date)  -- Includes partition key!
)
PARTITION BY RANGE (YEAR(order_date)) (...);
```

---

## Summary

### Quick Reference

| Partition Type | Use When | Example |
|---------------|----------|---------|
| **Range** | Time-series, continuous values | Orders by date |
| **List** | Discrete categories | Regions, departments |
| **Hash** | Even distribution, no natural key | User IDs |
| **Key** | Like hash, more flexible (MySQL) | Primary key partitioning |
| **Composite** | Complex requirements | Range + Hash |

### Decision Flowchart

```
1. Do you need to archive/delete old data regularly?
   YES → Range partitioning by date
   
2. Do you have natural categories (region, department)?
   YES → List partitioning
   
3. Do you need even data distribution without natural key?
   YES → Hash partitioning
   
4. Do you have complex requirements (time + region)?
   YES → Composite partitioning
   
5. Table < 100 million rows and fast enough?
   YES → Maybe you don't need partitioning!
```

### Checklist

- [ ] Chosen partition key appears in most queries
- [ ] Partition count is reasonable (10-100)
- [ ] Each partition is 10GB-100GB (rule of thumb)
- [ ] Plan for adding/dropping partitions
- [ ] Tested partition pruning with EXPLAIN
- [ ] Indexed appropriately on each partition
- [ ] Documented partitioning strategy
- [ ] Monitoring partition sizes

---

## Further Reading

- MySQL Partitioning Documentation
- PostgreSQL Table Partitioning Documentation
- "Database Internals" by Alex Petrov
- "Designing Data-Intensive Applications" by Martin Kleppmann
- pg_partman extension for PostgreSQL
