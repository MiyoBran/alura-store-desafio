# Exercise 01: Bookstore Database Design

## Objective
Design a complete database for an online bookstore. This exercise will help you practice entity identification, relationship modeling, and normalization.

## Business Requirements

### Books
- Track books with title, ISBN, publication year, price, and description
- Books can have multiple authors
- Books belong to one or more categories (Fiction, Science, History, etc.)
- Track available stock quantity for each book

### Authors
- Store author information: name, biography, birth date
- Authors can write multiple books
- Books can have multiple authors (co-authors)

### Customers
- Customer accounts with name, email, phone, registration date
- Customers can have multiple delivery addresses
- One address can be marked as default

### Orders
- Customers place orders containing multiple books
- Track order date, total amount, and order status
- Store shipping address for each order
- Order status: pending, processing, shipped, delivered, cancelled

### Reviews
- Customers can review books they've purchased
- Reviews include rating (1-5 stars) and comment
- Track review date
- One customer can only review a book once

### Shopping Cart
- Customers can add books to cart before ordering
- Track quantity for each book in cart

## Tasks

### Part 1: Entity Identification
List all entities you've identified from the requirements above.

**Your Answer:**
- 
- 
- 

### Part 2: Attributes
For each entity, list its attributes (columns). Identify:
- Primary Key (PK)
- Foreign Keys (FK)
- Data types
- Constraints (NOT NULL, UNIQUE, etc.)

**Example Format:**
```
Books
- book_id (PK, INT, AUTO_INCREMENT)
- isbn (VARCHAR(13), UNIQUE, NOT NULL)
- title (VARCHAR(200), NOT NULL)
- ...
```

**Your Answer:**

### Part 3: Relationships
Identify relationships between entities. Specify:
- Type (1:1, 1:N, M:N)
- Cardinality
- Whether it's mandatory or optional

**Example Format:**
```
Books (M) ←→ (N) Authors
- Many-to-Many
- Requires junction table: book_authors
- Mandatory: A book must have at least one author
```

**Your Answer:**

### Part 4: ERD
Draw an Entity-Relationship Diagram (ERD) for your design.

You can:
- Draw on paper and take a photo
- Use draw.io, Lucidchart, or dbdiagram.io
- Use ASCII art
- Create DBML (see modeling-languages/dbml/)

**Your Answer/Link:**

### Part 5: Normalization Check
Verify your design meets normalization requirements:

**1NF (First Normal Form):**
- [ ] All attributes contain atomic values?
- [ ] No repeating groups?

**2NF (Second Normal Form):**
- [ ] In 1NF?
- [ ] No partial dependencies?

**3NF (Third Normal Form):**
- [ ] In 2NF?
- [ ] No transitive dependencies?

**Issues Found:**

### Part 6: SQL Implementation
Write SQL CREATE TABLE statements for your design.

**Your Code:**
```sql
-- Create your tables here

```

### Part 7: Sample Queries
Write SQL queries for common operations:

**Query 1:** Find all books by a specific author
```sql
-- Your query here

```

**Query 2:** Get all orders for a customer with order details
```sql
-- Your query here

```

**Query 3:** Find the top 5 best-rated books
```sql
-- Your query here

```

**Query 4:** Get total sales amount by category
```sql
-- Your query here

```

**Query 5:** Find customers who haven't placed orders in the last 6 months
```sql
-- Your query here

```

## Bonus Challenges

### Challenge 1: Inventory Management
Add support for tracking:
- Low stock alerts when quantity < 5
- Automatic reordering
- Supplier information

### Challenge 2: Promotions
Add support for:
- Discount codes
- Seasonal sales
- Buy-one-get-one offers

### Challenge 3: Wishlists
Allow customers to:
- Create multiple wishlists
- Add books to wishlists
- Share wishlists with others

## Reflection Questions

1. What was the most challenging part of this design?


2. How did you handle many-to-many relationships?


3. What indexes would you add for better performance?


4. How would you handle book editions (paperback, hardcover, ebook)?


5. What additional features would make this database more realistic?


---

## Submission Checklist
- [ ] All entities identified
- [ ] Attributes and data types specified
- [ ] Relationships documented
- [ ] ERD created
- [ ] Normalized to 3NF
- [ ] SQL CREATE statements written
- [ ] Sample queries implemented
- [ ] Bonus challenges attempted

**Completion Date:** _______________

**Self-Assessment:** ___/10

**Notes:**
