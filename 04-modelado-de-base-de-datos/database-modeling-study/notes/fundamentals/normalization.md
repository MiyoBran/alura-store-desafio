# Database Normalization

## What is Normalization?

Normalization is the process of organizing data in a database to reduce redundancy and improve data integrity. It involves dividing large tables into smaller ones and defining relationships between them.

## Goals of Normalization

1. **Eliminate redundant data** - Store data only once
2. **Ensure data dependencies make sense** - Keep related data together
3. **Reduce anomalies** - Prevent insertion, update, and deletion problems
4. **Improve data integrity** - Maintain consistency

## Normal Forms

### First Normal Form (1NF)

**Rules:**
- Each column contains atomic (indivisible) values
- Each column contains values of a single type
- Each row is unique
- Order of rows/columns doesn't matter

**Example - Not in 1NF:**
```
| customer_id | name  | phone_numbers        |
|-------------|-------|---------------------|
| 1           | John  | 123-456, 789-012    |
```

**Example - In 1NF:**
```
| customer_id | name  | phone_number |
|-------------|-------|-------------|
| 1           | John  | 123-456     |
| 1           | John  | 789-012     |
```

### Second Normal Form (2NF)

**Rules:**
- Must be in 1NF
- All non-key attributes must depend on the entire primary key
- Eliminates partial dependencies

**Example - Not in 2NF:**
```
| order_id | product_id | product_name | quantity |
|----------|-----------|--------------|----------|
| 101      | 1         | Laptop       | 2        |
```
*Problem: product_name depends only on product_id, not the full key (order_id + product_id)*

**Example - In 2NF:**
```
Orders table:
| order_id | product_id | quantity |
|----------|-----------|----------|
| 101      | 1         | 2        |

Products table:
| product_id | product_name |
|-----------|-------------|
| 1         | Laptop      |
```

### Third Normal Form (3NF)

**Rules:**
- Must be in 2NF
- No transitive dependencies
- Non-key attributes must depend only on the primary key

**Example - Not in 3NF:**
```
| employee_id | employee_name | department_id | department_name |
|-------------|--------------|---------------|----------------|
| 1           | Alice        | 10            | Sales          |
```
*Problem: department_name depends on department_id, not employee_id*

**Example - In 3NF:**
```
Employees table:
| employee_id | employee_name | department_id |
|-------------|--------------|---------------|
| 1           | Alice        | 10            |

Departments table:
| department_id | department_name |
|---------------|----------------|
| 10            | Sales          |
```

### Boyce-Codd Normal Form (BCNF)

**Rules:**
- Must be in 3NF
- For every dependency A → B, A must be a super key
- Stricter version of 3NF

**When to use:** When you have overlapping candidate keys

### Fourth Normal Form (4NF)

**Rules:**
- Must be in BCNF
- No multi-valued dependencies

**Example:** A professor can teach multiple subjects and work on multiple research projects independently

### Fifth Normal Form (5NF)

**Rules:**
- Must be in 4NF
- No join dependencies
- Can't be decomposed further without losing information

## Practical Example: Library System

### Unnormalized
```
| book_id | title | authors           | borrower | borrower_phone |
|---------|-------|-------------------|----------|---------------|
| 1       | DB101 | Smith, Jones      | Alice    | 123-456      |
```

### Normalized (3NF)
```
Books:
| book_id | title |
|---------|-------|
| 1       | DB101 |

Authors:
| author_id | author_name |
|-----------|------------|
| 1         | Smith      |
| 2         | Jones      |

Book_Authors:
| book_id | author_id |
|---------|-----------|
| 1       | 1         |
| 1       | 2         |

Borrowers:
| borrower_id | name  | phone   |
|-------------|-------|---------|
| 1           | Alice | 123-456 |

Loans:
| loan_id | book_id | borrower_id | loan_date |
|---------|---------|-------------|-----------|
| 1       | 1       | 1           | 2026-02-15|
```

## Denormalization

Sometimes we intentionally violate normalization rules for:
- **Performance** - Reduce joins
- **Simplicity** - Easier queries
- **Read-heavy systems** - Data warehouses, reporting

**When to denormalize:**
- Proven performance issues
- Read operations far exceed writes
- Acceptable data redundancy

## Anomalies Prevented by Normalization

### Insert Anomaly
Cannot add data without adding other unrelated data

### Update Anomaly
Updating data in one place but not others, causing inconsistency

### Delete Anomaly
Deleting data unintentionally removes other important data

## Quick Reference

| Normal Form | Key Rule |
|------------|----------|
| 1NF | Atomic values, no repeating groups |
| 2NF | No partial dependencies |
| 3NF | No transitive dependencies |
| BCNF | Every determinant is a candidate key |
| 4NF | No multi-valued dependencies |
| 5NF | No join dependencies |

## Practice Questions

1. Is this table in 1NF? Why or why not?
2. Identify the normal form of your current table
3. Normalize a given table to 3NF

---

**Study Notes:**
- 
