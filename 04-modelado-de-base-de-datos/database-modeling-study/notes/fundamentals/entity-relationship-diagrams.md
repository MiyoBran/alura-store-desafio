# Entity-Relationship Diagrams (ERD)

## What is an ERD?

An **Entity-Relationship Diagram** is a visual representation of entities (tables) in a database and the relationships between them. It helps you design, understand, and communicate database structures.

## When to Use ERDs

- **Planning** - Before building a database
- **Documentation** - Explaining existing systems
- **Communication** - Discussing requirements with stakeholders
- **Analysis** - Understanding complex data relationships
- **Optimization** - Identifying design improvements

## ERD Components

### 1. Entities (Tables)

Represented as rectangles containing the entity name.

```
┌─────────────┐
│  Customer   │
└─────────────┘
```

**Strong Entity:** Can exist independently
**Weak Entity:** Depends on another entity (shown with double rectangle)

```
╔═════════════╗
║ OrderItem   ║  ← Depends on Order
╚═════════════╝
```

### 2. Attributes (Columns)

Listed inside or beside the entity box.

```
┌─────────────────┐
│    Customer     │
├─────────────────┤
│ customer_id (PK)│
│ first_name      │
│ last_name       │
│ email           │
│ phone           │
└─────────────────┘
```

**Attribute Types:**
- **Primary Key (PK)** - Unique identifier (underlined or marked)
- **Foreign Key (FK)** - References another table
- **Composite** - Made up of multiple parts
- **Derived** - Calculated from other attributes
- **Multi-valued** - Can have multiple values

### 3. Relationships

Represented as diamonds or lines connecting entities.

```
Customer ──────< Order
        (places)
```

**Relationship Types:**
- **One-to-One (1:1)** - |──|
- **One-to-Many (1:N)** - |──<
- **Many-to-Many (M:N)** - >──<

### 4. Cardinality

Specifies how many instances can participate in a relationship.

**Crow's Foot Notation:**
```
|   → One (exactly one)
|o  → Zero or One
<   → Many
o<  → Zero or Many
|<  → One or Many
```

**Examples:**
```
Customer ─|────<─ Order
(One customer can have many orders)

User ─|────|─ UserProfile
(One user has exactly one profile)

Student ─<────>─ Course
(Many students can enroll in many courses)
```

## ERD Notations

### 1. Chen Notation

Uses diamonds for relationships, ovals for attributes.

```
         places
Customer ◇─────◇ Order
   ○○○            ○○○
   |||            |||
  name         order_id
  email        date
  phone        total
```

### 2. Crow's Foot Notation (Most Common)

Simple lines with symbols at the ends.

```
┌─────────┐        ┌─────────┐
│Customer │─|────<─│  Order  │
└─────────┘        └─────────┘
```

**Reading:** "One customer has zero or many orders"

### 3. UML Class Diagram

Similar to object-oriented class diagrams.

```
┌──────────────────┐
│    Customer      │
├──────────────────┤
│ -customer_id: int│
│ -name: string    │
│ -email: string   │
├──────────────────┤
│                  │
└──────────────────┘
        │1
        │
        │*
┌──────────────────┐
│      Order       │
├──────────────────┤
│ -order_id: int   │
│ -order_date: date│
│ -total: decimal  │
└──────────────────┘
```

## Common ERD Patterns

### One-to-Many

```
┌──────────┐         ┌──────────┐
│ Customer │─|─────<─│  Order   │
└──────────┘         └──────────┘

One customer, many orders
```

### Many-to-Many (with Junction Table)

```
┌─────────┐       ┌────────────┐       ┌─────────┐
│ Student │─<─────│ Enrollment │─────>─│ Course  │
└─────────┘       └────────────┘       └─────────┘

Students ←→ Courses through Enrollments
```

### One-to-One

```
┌──────┐         ┌──────────────┐
│ User │─|─────|─│ UserProfile  │
└──────┘         └──────────────┘

One user, one profile
```

### Self-Referencing

```
┌───────────┐
│ Employee  │─┐
│           │ │ manages
│ manager_id│<┘
└───────────┘

An employee can manage other employees
```

### Hierarchical (Category Tree)

```
┌────────────┐
│  Category  │─┐
│            │ │ has parent
│ parent_id  │<┘
└────────────┘

Categories can have subcategories
```

## Complete ERD Example: E-Commerce System

```
┌─────────────────┐
│    Customer     │
├─────────────────┤
│ customer_id (PK)│
│ first_name      │
│ last_name       │
│ email (UNIQUE)  │
│ phone           │
│ created_at      │
└─────────────────┘
        │ 1
        │
        │ *
┌─────────────────┐         ┌──────────────────┐
│     Order       │─────*───│   Order_Items    │
├─────────────────┤         ├──────────────────┤
│ order_id (PK)   │         │ order_id (FK)    │
│ customer_id(FK) │         │ product_id (FK)  │
│ order_date      │         │ quantity         │
│ total_amount    │         │ unit_price       │
│ status          │         └──────────────────┘
└─────────────────┘                 │ *
        │ 1                         │
        │                           │ 1
        │ *                         │
┌─────────────────┐         ┌──────────────────┐
│    Address      │         │     Product      │
├─────────────────┤         ├──────────────────┤
│ address_id (PK) │         │ product_id (PK)  │
│ customer_id(FK) │         │ product_name     │
│ street          │         │ description      │
│ city            │         │ price            │
│ state           │         │ stock_quantity   │
│ postal_code     │         │ category_id (FK) │
│ is_default      │         └──────────────────┘
└─────────────────┘                 │ *
                                    │
                                    │ 1
                            ┌──────────────────┐
                            │    Category      │
                            ├──────────────────┤
                            │ category_id (PK) │
                            │ category_name    │
                            │ parent_id (FK)   │
                            └──────────────────┘
```

## Cardinality Examples Explained

### Example 1: Customer → Order
```
Customer ─|────<─ Order
```
- **Mandatory on Customer side (|):** Every order MUST have a customer
- **Optional on Order side (<):** A customer MAY have zero or more orders

### Example 2: Order → OrderItem
```
Order ─|────<─ OrderItem
```
- Every order item must belong to an order
- An order can have multiple items

### Example 3: User ↔ UserProfile
```
User ─|────|─ UserProfile
```
- One user has exactly one profile
- One profile belongs to exactly one user

## ERD Best Practices

1. **Clear Naming**
   - Use singular names for entities (Customer, not Customers)
   - Use descriptive relationship names
   - Follow consistent naming conventions

2. **Proper Keys**
   - Clearly mark primary keys (PK)
   - Indicate foreign keys (FK)
   - Show unique constraints

3. **Appropriate Detail**
   - Include all essential attributes
   - Don't clutter with too many details initially
   - Use separate diagrams for different views (conceptual, logical, physical)

4. **Layout**
   - Minimize crossing lines
   - Group related entities
   - Use consistent spacing

5. **Documentation**
   - Add notes for complex relationships
   - Document business rules
   - Include cardinality constraints

## ERD Tools

### Free/Open Source
- **dbdiagram.io** - Web-based, uses DBML
- **draw.io** - General diagramming
- **PlantUML** - Code-based diagrams
- **MySQL Workbench** - For MySQL databases
- **pgAdmin** - For PostgreSQL

### Commercial
- **Lucidchart** - Web-based
- **ERDPlus** - Web-based, educational
- **Microsoft Visio** - Desktop
- **Enterprise Architect** - Full UML suite

### From Database
- Most database tools can generate ERDs from existing databases
- Reverse engineering from schema

## Practice Exercise

### Design an ERD for a Library System

**Requirements:**
- Track books (title, ISBN, publication year)
- Authors (books can have multiple authors)
- Members (who borrow books)
- Loans (track borrowing and returns)
- Publishers

**Your Task:**
1. Identify entities
2. Define attributes for each entity
3. Determine relationships and cardinality
4. Draw the ERD (on paper or using a tool)

### Questions to Consider:
- Can a book have multiple authors?
- Can an author write multiple books?
- Can a member borrow multiple books at once?
- Should you track loan history?
- How do you handle book copies (multiple physical copies of the same book)?

## Common Mistakes to Avoid

- ❌ **Missing Primary Keys** - Every entity needs one
- ❌ **Wrong Cardinality** - Carefully consider min/max relationships
- ❌ **Redundant Relationships** - Don't duplicate what's already implied
- ❌ **Missing Junction Tables** - Required for many-to-many relationships
- ❌ **Incomplete Attributes** - Include all necessary fields
- ❌ **No Validation** - Review with stakeholders

## ERD Checklist

- [ ] All entities identified
- [ ] Primary keys defined for all entities
- [ ] Foreign keys properly placed
- [ ] Relationships clearly labeled
- [ ] Cardinality specified
- [ ] Junction tables for M:N relationships
- [ ] Weak entities properly marked
- [ ] Consistent notation used
- [ ] No redundant data
- [ ] Reviewed with team/stakeholders

---

**Study Notes:**
- 

---

## Next Steps

- Practice drawing ERDs for real-world scenarios
- Learn [DBML](../../modeling-languages/dbml/dbml-examples.dbml) for quick diagramming
- Study [Normalization](normalization.md) to refine your designs
- Review [Relationships](relationships.md) for implementation details
