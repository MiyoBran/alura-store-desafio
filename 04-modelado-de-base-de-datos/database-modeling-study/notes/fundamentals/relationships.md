# Database Relationships

## Types of Relationships

### 1. One-to-One (1:1)

A single record in Table A relates to a single record in Table B.

**When to use:**
- Separating sensitive data
- Splitting large tables for performance
- Optional attributes

**Example:**
```
User ←→ UserProfile

Users:
| user_id | username | email           |
|---------|----------|-----------------|
| 1       | john_doe | john@email.com  |

UserProfiles:
| profile_id | user_id (FK, UNIQUE) | bio          | avatar_url |
|-----------|---------------------|--------------|------------|
| 1         | 1                   | "Developer"  | /img/1.jpg |
```

**SQL Implementation:**
```sql
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE UserProfiles (
    profile_id INT PRIMARY KEY,
    user_id INT UNIQUE,
    bio TEXT,
    avatar_url VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
```

### 2. One-to-Many (1:N)

A single record in Table A can relate to multiple records in Table B.

**Most common relationship type!**

**Examples:**
- Customer → Orders
- Author → Books
- Department → Employees

**Example:**
```
Customer (1) → (N) Orders

Customers:
| customer_id | name    | email           |
|-------------|---------|-----------------|
| 1           | Alice   | alice@email.com |
| 2           | Bob     | bob@email.com   |

Orders:
| order_id | customer_id (FK) | order_date | total   |
|----------|------------------|------------|---------|
| 101      | 1                | 2026-02-15 | 150.00  |
| 102      | 1                | 2026-02-16 | 200.00  |
| 103      | 2                | 2026-02-17 | 75.00   |
```

**SQL Implementation:**
```sql
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
```

### 3. Many-to-Many (M:N)

Multiple records in Table A can relate to multiple records in Table B.

**Requires a junction/bridge table!**

**Examples:**
- Students ↔ Courses
- Products ↔ Orders
- Authors ↔ Books

**Example:**
```
Student (M) ↔ (N) Course

Students:
| student_id | name    |
|-----------|---------|
| 1         | Alice   |
| 2         | Bob     |

Courses:
| course_id | course_name     |
|----------|----------------|
| 101      | Database Design |
| 102      | Web Development |

Enrollments (Junction Table):
| enrollment_id | student_id (FK) | course_id (FK) | enrollment_date |
|--------------|----------------|---------------|----------------|
| 1            | 1              | 101           | 2026-02-01     |
| 2            | 1              | 102           | 2026-02-01     |
| 3            | 2              | 101           | 2026-02-02     |
```

**SQL Implementation:**
```sql
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100)
);

CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    grade VARCHAR(2),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    UNIQUE(student_id, course_id)  -- Prevent duplicate enrollments
);
```

## Cardinality Notation

### Crow's Foot Notation
```
One:    ─|
Many:   ─<
```

Examples:
```
Customer ─|────<─ Order     (One-to-Many)
Student  ─<────>─ Course   (Many-to-Many via junction table)
User     ─|────|─ Profile  (One-to-One)
```

### Min-Max Notation
```
(min, max)
(0,1)   - Zero or One
(1,1)   - Exactly One
(0,N)   - Zero or Many
(1,N)   - One or Many
```

## Participation Constraints

### Mandatory (Total Participation)
Every entity must participate in the relationship.

**Example:** Every Order must have a Customer

### Optional (Partial Participation)
Entity may or may not participate.

**Example:** A Customer may have zero or more Orders

## Recursive Relationships

An entity relates to itself.

**Example: Employee-Manager**
```sql
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    manager_id INT,
    FOREIGN KEY (manager_id) REFERENCES Employees(employee_id)
);
```

**Data:**
```
| employee_id | name    | manager_id |
|-------------|---------|------------|
| 1           | CEO     | NULL       |
| 2           | Manager | 1          |
| 3           | Dev     | 2          |
```

## Ternary Relationships

Three entities participate in a relationship.

**Example: Supplier-Part-Project**
```sql
CREATE TABLE Supplies (
    supplier_id INT,
    part_id INT,
    project_id INT,
    quantity INT,
    PRIMARY KEY (supplier_id, part_id, project_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id),
    FOREIGN KEY (part_id) REFERENCES Parts(part_id),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);
```

## Best Practices

1. **Use meaningful FK names** - e.g., `author_id` instead of `id`
2. **Index foreign keys** - Improves join performance
3. **Define ON DELETE/UPDATE rules**
   - CASCADE: Delete/update related records
   - SET NULL: Set FK to NULL
   - RESTRICT: Prevent deletion
   - NO ACTION: Similar to RESTRICT

**Example:**
```sql
FOREIGN KEY (customer_id) 
    REFERENCES Customers(customer_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
```

4. **Use composite keys wisely** - For junction tables
5. **Document relationships** - Add comments

## Common Patterns

### Self-Referencing
Category → Subcategories

### Associative Entity
Add attributes to M:N relationship (junction table becomes an entity)

### Weak Entity
Depends on another entity for identification
**Example:** OrderItem depends on Order

## Query Examples

### One-to-Many Query
```sql
-- Get all orders for a customer
SELECT o.* 
FROM Orders o
WHERE o.customer_id = 1;
```

### Many-to-Many Query
```sql
-- Get all courses for a student
SELECT c.*
FROM Courses c
JOIN Enrollments e ON c.course_id = e.course_id
WHERE e.student_id = 1;
```

### Recursive Query
```sql
-- Get all employees and their managers
SELECT e.name AS employee, m.name AS manager
FROM Employees e
LEFT JOIN Employees m ON e.manager_id = m.employee_id;
```

---

**Study Notes:**
- 
