# 💻 SQL Practice - Hands-On Learning

[← Back to Main](../README.md)

This section contains practical SQL exercises organized by complexity and topic. Each file includes examples, exercises, and best practices.

---

## 📚 Table of Contents

- [Getting Started](#getting-started)
- [DDL - Data Definition Language](#ddl---data-definition-language)
- [DML - Data Manipulation Language](#dml---data-manipulation-language)
- [Joins](#joins)
- [Advanced SQL](#advanced-sql)
- [Learning Paths](#learning-paths)

---

## 🚀 Getting Started

### Prerequisites

Before starting SQL practice:
- ✓ Read [notes/fundamentals/data-modeling-concepts.md](../notes/fundamentals/data-modeling-concepts.md)
- ✓ Have a database installed (MySQL, PostgreSQL, or SQLite)
- ✓ Have a SQL client ready (DBeaver, TablePlus, or command line)

### How to Use These Files

1. **Open in your SQL client** - Copy code to your database tool
2. **Run examples** - Execute each example to see results
3. **Try exercises** - Complete practice problems at the end of each file
4. **Experiment** - Modify queries to explore different outcomes
5. **Take notes** - Comment your learning directly in the SQL files

### Setup Instructions

```sql
-- Create a practice database
CREATE DATABASE practice_db;
USE practice_db;

-- You're ready to start!
```

---

## DDL - Data Definition Language

**What is DDL?** SQL commands for creating and modifying database structures (tables, indexes, constraints).

| File | Topic | Difficulty | Est. Time | Prerequisites |
|------|-------|------------|-----------|---------------|
| [create-tables.sql](ddl/create-tables.sql) | **CREATE TABLE** | ⭐ Beginner | 30-45 min | None |
| [alter-tables.sql](ddl/alter-tables.sql) | **ALTER TABLE** | ⭐⭐ Intermediate | 30-45 min | CREATE TABLE |
| [constraints.sql](ddl/constraints.sql) | **Constraints & Indexes** | ⭐⭐ Intermediate | 45-60 min | CREATE TABLE |

**Learning Objectives:**
- ✓ Create tables with appropriate data types
- ✓ Modify existing table structures
- ✓ Add and manage constraints (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK)
- ✓ Create indexes for performance

**Practice Tips:**
- Start by creating simple tables, then add complexity
- Always specify data types explicitly
- Use constraints to enforce data integrity
- Test constraints by trying to insert invalid data

---

## DML - Data Manipulation Language

**What is DML?** SQL commands for inserting, querying, updating, and deleting data.

| File | Topic | Difficulty | Est. Time | Prerequisites |
|------|-------|------------|-----------|---------------|
| [insert-data.sql](dml/insert-data.sql) | **INSERT** | ⭐ Beginner | 30-45 min | CREATE TABLE |
| [select-queries.sql](dml/select-queries.sql) | **SELECT (Basic to Advanced)** | ⭐⭐ Intermediate | 60-90 min | INSERT |
| [update-data.sql](dml/update-data.sql) | **UPDATE** | ⭐⭐ Intermediate | 30-45 min | SELECT |
| [delete-data.sql](dml/delete-data.sql) | **DELETE** | ⭐⭐ Intermediate | 30-45 min | SELECT |

**Learning Objectives:**
- ✓ Insert single and multiple rows
- ✓ Query data with WHERE, ORDER BY, GROUP BY, HAVING
- ✓ Update records safely with conditions
- ✓ Delete data and understand CASCADE behavior
- ✓ Use aggregate functions (COUNT, SUM, AVG, MIN, MAX)

**Practice Tips:**
- **SELECT first, then UPDATE/DELETE** - Always verify your WHERE clause with SELECT
- Practice filtering with different conditions (AND, OR, IN, BETWEEN, LIKE)
- Master aggregate functions before moving to joins
- Understand the impact of NULL values

---

## Joins

**What are Joins?** SQL operations that combine data from multiple tables based on relationships.

| File | Topic | Difficulty | Est. Time | Prerequisites |
|------|-------|------------|-----------|---------------|
| [inner-joins.sql](joins/inner-joins.sql) | **INNER JOIN** | ⭐⭐ Intermediate | 45-60 min | SELECT basics |
| [outer-joins.sql](joins/outer-joins.sql) | **LEFT/RIGHT/FULL OUTER JOIN** | ⭐⭐ Intermediate | 45-60 min | INNER JOIN |
| [complex-joins.sql](joins/complex-joins.sql) | **Multi-table & Self Joins** | ⭐⭐⭐ Advanced | 60-90 min | All previous joins |

**Learning Objectives:**
- ✓ Understand when to use each type of join
- ✓ Combine data from 2+ tables
- ✓ Handle NULL values in joins
- ✓ Perform self-joins for hierarchical data
- ✓ Optimize join performance

**Practice Tips:**
- **Visualize first** - Draw tables and their relationships before writing queries
- Start with 2-table joins, then add more complexity
- Use table aliases for readability
- Always check for NULL values in outer joins
- Practice with the sample schemas in [../projects/sample-schemas/](../projects/sample-schemas/)

**Join Type Quick Reference:**
- `INNER JOIN` - Only matching rows from both tables
- `LEFT JOIN` - All rows from left table + matching from right
- `RIGHT JOIN` - All rows from right table + matching from left
- `FULL OUTER JOIN` - All rows from both tables
- `CROSS JOIN` - Cartesian product (all combinations)

---

## Advanced SQL

**What's Advanced SQL?** Features that go beyond basic queries: views, procedures, triggers, and transactions.

| File | Topic | Difficulty | Est. Time | Prerequisites |
|------|-------|------------|-----------|---------------|
| [views.sql](advanced/views.sql) | **Views & Materialized Views** | ⭐⭐ Intermediate | 45-60 min | Complex SELECT |
| [stored-procedures.sql](advanced/stored-procedures.sql) | **Stored Procedures** | ⭐⭐⭐ Advanced | 60-90 min | All DML + Joins |
| [triggers.sql](advanced/triggers.sql) | **Triggers** | ⭐⭐⭐ Advanced | 60-90 min | Procedures |
| [transactions.sql](advanced/transactions.sql) | **Transactions & Concurrency** | ⭐⭐⭐ Advanced | 60-90 min | UPDATE/DELETE |

**Learning Objectives:**
- ✓ Create reusable views for complex queries
- ✓ Write stored procedures with parameters and control flow
- ✓ Implement automatic actions with triggers
- ✓ Manage data integrity with transactions
- ✓ Understand isolation levels and deadlocks

**Practice Tips:**
- **Views:** Start with simple SELECT queries, convert to views
- **Procedures:** Begin with parameter-less procedures, add complexity gradually
- **Triggers:** Understand BEFORE vs AFTER, test thoroughly
- **Transactions:** Always use in production for multi-step operations

**When to Use:**
- **Views:** Simplify complex queries, security (hide columns)
- **Stored Procedures:** Reusable logic, better performance for complex operations
- **Triggers:** Audit trails, automatic updates, enforce business rules
- **Transactions:** Ensure data consistency in multi-step operations

---

## 🎯 Learning Paths

### Path 1: Complete Beginner (4-6 weeks)

**Week 1:** DDL Basics
- [ ] create-tables.sql
- [ ] Practice creating 5 different tables
- [ ] Review [data-modeling-concepts.md](../notes/fundamentals/data-modeling-concepts.md)

**Week 2:** DML Basics
- [ ] insert-data.sql
- [ ] select-queries.sql (basic queries only)
- [ ] Practice with sample data

**Week 3:** Intermediate DML
- [ ] select-queries.sql (advanced queries)
- [ ] update-data.sql
- [ ] delete-data.sql

**Week 4:** Joins
- [ ] inner-joins.sql
- [ ] outer-joins.sql
- [ ] Work on [bookstore exercise](../projects/exercises/exercise-01-bookstore.md)

**Week 5-6:** Advanced (Optional)
- [ ] alter-tables.sql & constraints.sql
- [ ] complex-joins.sql
- [ ] views.sql

### Path 2: Intermediate Developer (2-3 weeks)

**Week 1:** Review + Practice
- [ ] Quick review: create-tables.sql, select-queries.sql
- [ ] Focus on: complex-joins.sql
- [ ] Complete: [hospital exercise](../projects/exercises/exercise-02-hospital.md)

**Week 2:** Advanced SQL
- [ ] views.sql
- [ ] stored-procedures.sql
- [ ] triggers.sql

**Week 3:** Master + Apply
- [ ] transactions.sql
- [ ] Study sample schemas in [../projects/sample-schemas/](../projects/sample-schemas/)
- [ ] Build your own project

### Path 3: Advanced/Interview Prep (1-2 weeks)

- [ ] Review complex-joins.sql
- [ ] Master all advanced files
- [ ] Practice on [LeetCode Database Problems](https://leetcode.com/problemset/database/)
- [ ] Study [indexing strategies](../notes/advanced/indexing-strategies.md)
- [ ] Review [partitioning](../notes/advanced/partitioning.md)

---

## 📊 Progress Tracker

### DDL
- [ ] create-tables.sql ⭐ Beginner
- [ ] alter-tables.sql ⭐⭐ Intermediate  
- [ ] constraints.sql ⭐⭐ Intermediate

### DML
- [ ] insert-data.sql ⭐ Beginner
- [ ] select-queries.sql ⭐⭐ Intermediate
- [ ] update-data.sql ⭐⭐ Intermediate
- [ ] delete-data.sql ⭐⭐ Intermediate

### Joins
- [ ] inner-joins.sql ⭐⭐ Intermediate
- [ ] outer-joins.sql ⭐⭐ Intermediate
- [ ] complex-joins.sql ⭐⭐⭐ Advanced

### Advanced
- [ ] views.sql ⭐⭐ Intermediate
- [ ] stored-procedures.sql ⭐⭐⭐ Advanced
- [ ] triggers.sql ⭐⭐⭐ Advanced
- [ ] transactions.sql ⭐⭐⭐ Advanced

**Total Files:** 14 | **Completed:** ___

---

## 💡 Practice Tips & Best Practices

### General Tips
1. **Type, don't copy-paste** - Muscle memory helps learning
2. **Break complex queries** - Start simple, add complexity step by step
3. **Use EXPLAIN** - Understand query execution plans
4. **Test with bad data** - Try to break your constraints
5. **Comment your code** - Explain your reasoning

### Common Mistakes to Avoid
❌ Forgetting WHERE clause in UPDATE/DELETE (affects all rows!)  
❌ Not using table aliases in joins  
❌ Ignoring NULL values in comparisons  
❌ Using SELECT * in production queries  
❌ Not testing transactions rollback scenarios

### Performance Tips
⚡ **Create indexes** on foreign keys and frequently searched columns  
⚡ **Use LIMIT** when testing queries on large tables  
⚡ **Avoid SELECT *** - Specify only needed columns  
⚡ **Use JOINs instead of subqueries** when possible  
⚡ **Analyze slow queries** with EXPLAIN

### Testing Your Queries

```sql
-- Always test your WHERE clause with SELECT first
SELECT * FROM users WHERE status = 'inactive';  -- Check what will be affected

-- Once verified, proceed with UPDATE/DELETE
UPDATE users SET status = 'archived' WHERE status = 'inactive';
```

---

## 🔗 Related Sections

**Theory behind the practice:**
- Database concepts: [notes/README.md](../notes/README.md)
- Normalization: [notes/fundamentals/normalization.md](../notes/fundamentals/normalization.md)
- Indexing: [notes/advanced/indexing-strategies.md](../notes/advanced/indexing-strategies.md)

**Apply your skills:**
- Practice projects: [projects/README.md](../projects/README.md)
- Sample schemas: [projects/sample-schemas/](../projects/sample-schemas/)

**Additional practice:**
- SQLZoo: https://sqlzoo.net/
- LeetCode: https://leetcode.com/problemset/database/
- HackerRank: https://www.hackerrank.com/domains/sql

---

## 📚 Additional Resources

**Quick References:**
- [SQL Cheat Sheet](../notes/reference/sql-cheatsheet.md)
- [Data Types Reference](../notes/reference/data-types.md)
- [Useful Links](../resources/useful-links.md)

**External Practice:**
- [SQLBolt](https://sqlbolt.com/) - Interactive tutorials
- [PostgreSQL Exercises](https://pgexercises.com/) - Real-world scenarios
- [Mode SQL Tutorial](https://mode.com/sql-tutorial/) - Analytics focused

---

**Navigation:** [🏠 Main](../README.md) | [📝 Notes](../notes/README.md) | [🎨 Modeling](../modeling-languages/README.md) | [🏗️ Projects](../projects/README.md) | [📚 Resources](../resources/README.md)
