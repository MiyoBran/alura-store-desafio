# 🏗️ Projects - Practice Exercises and Sample Schemas

[← Back to Main](../README.md)

This section contains hands-on projects to apply your database modeling knowledge. Work through exercises or study complete sample schemas.

---

## 📚 Table of Contents

- [Overview](#overview)
- [Practice Exercises](#practice-exercises)
- [Sample Schemas](#sample-schemas)
- [How to Use This Section](#how-to-use-this-section)
- [Learning Paths](#learning-paths)

---

## 🎯 Overview

### Two Types of Projects

**1. Practice Exercises** - Open-ended design challenges
- You design the database from scratch
- Includes requirements and evaluation criteria
- Multiple valid solutions possible
- Great for learning and interviews

**2. Sample Schemas** - Complete working databases
- Fully implemented SQL code with sample data
- Study professional database structures
- Use as templates for your projects
- Reference for best practices

### Learning Approach

**Exercise-Driven (Recommended for Beginners):**
1. Start with an exercise
2. Design your solution
3. Compare with sample schema
4. Learn from differences

**Schema-Study (Recommended for Intermediate):**
1. Study a sample schema
2. Understand the design decisions
3. Modify for a different domain
4. Add your own features

---

## Practice Exercises

Design databases from business requirements. Each exercise includes a complete specification with tasks and evaluation criteria.

### Available Exercises

| Exercise | Domain | Difficulty | Est. Time | Focus Areas |
|----------|--------|------------|-----------|-------------|
| [exercise-01-bookstore.md](exercises/exercise-01-bookstore.md) | **Bookstore** | ⭐ Beginner | 2-3 hours | Basic relationships, inventory |
| [exercise-02-hospital.md](exercises/exercise-02-hospital.md) | **Hospital** | ⭐⭐⭐ Advanced | 4-6 hours | Complex relationships, scheduling |
| [exercise-03-university.md](exercises/exercise-03-university.md) | **University** | ⭐⭐⭐ Advanced | 4-6 hours | Prerequisites, recursive relationships |

---

### Exercise 01: Bookstore Management System ⭐

**Difficulty:** Beginner  
**Focus:** Basic database design, inventory management, simple relationships  
**File:** [exercise-01-bookstore.md](exercises/exercise-01-bookstore.md)

**What You'll Learn:**
- Basic entity identification
- One-to-many relationships
- Inventory tracking
- Simple queries and transactions

**Core Entities:**
- Books, Authors, Publishers, Customers
- Orders, Order Items
- Inventory

**Key Challenges:**
- Book-author many-to-many relationship
- Order management and inventory updates
- Customer purchase history

**Prerequisites:**
- Basic SQL (CREATE TABLE, INSERT, SELECT)
- Understanding of primary and foreign keys
- [Normalization basics](../notes/fundamentals/normalization.md)

**Recommended Time:** 2-3 hours

---

### Exercise 02: Hospital Management System ⭐⭐⭐

**Difficulty:** Advanced  
**Focus:** Complex relationships, scheduling, medical records, billing  
**File:** [exercise-02-hospital.md](exercises/exercise-02-hospital.md)

**What You'll Learn:**
- Complex multi-entity relationships
- Appointment scheduling logic
- Medical records management
- Financial transactions and billing

**Core Entities:**
- Patients, Doctors, Appointments
- Medical Records, Prescriptions
- Departments, Rooms, Billing

**Key Challenges:**
- Doctor availability and appointment scheduling
- Patient medical history tracking
- Prescription management with dosages
- Billing and insurance claims
- Room allocation and capacity

**Advanced Features:**
- Lab tests and results
- Staff management (nurses, admin)
- Bed occupancy management
- Appointment reminders
- Doctor performance analytics

**Prerequisites:**
- Strong SQL skills (joins, subqueries, aggregations)
- Understanding of complex relationships
- Familiarity with constraints and triggers

**Recommended Time:** 4-6 hours

**Real-World Considerations:**
- HIPAA compliance (data privacy)
- HL7 standards (health data exchange)
- Security and access control

---

### Exercise 03: University Management System ⭐⭐⭐

**Difficulty:** Advanced  
**Focus:** Academic calendar, prerequisites, enrollment, GPA calculation  
**File:** [exercise-03-university.md](exercises/exercise-03-university.md)

**What You'll Learn:**
- Recursive relationships (course prerequisites)
- Complex enrollment logic
- GPA calculation and academic standing
- Schedule conflict detection

**Core Entities:**
- Students, Instructors, Courses
- Sections, Enrollments
- Departments, Programs, Semesters

**Key Challenges:**
- Course prerequisite chains (recursive relationships)
- Enrollment with capacity limits
- GPA calculation (weighted by credits)
- Schedule conflict prevention
- Academic program requirements

**Advanced Features:**
- Course waitlist management
- Grade distribution analysis
- Graduation requirement tracking
- Room scheduling and conflicts
- Course recommendations

**Prerequisites:**
- Advanced SQL (recursive queries, CTEs)
- Complex join patterns
- Understanding of self-referencing foreign keys

**Recommended Time:** 4-6 hours

**Real-World Considerations:**
- FERPA compliance (student privacy)
- Student Information System (SIS) architecture
- Integration with external systems

---

## Sample Schemas

Complete, working database schemas with sample data. Study these to learn professional database design patterns.

### Available Schemas

| Schema | Domain | Complexity | Tables | Key Features |
|--------|--------|------------|--------|--------------|
| [ecommerce-schema.sql](sample-schemas/ecommerce-schema.sql) | **E-commerce** | ⭐⭐ Intermediate | 8 | Products, orders, payments |
| [library-system-schema.sql](sample-schemas/library-system-schema.sql) | **Library** | ⭐⭐ Intermediate | 12 | Loans, reservations, fines |
| [social-media-schema.sql](sample-schemas/social-media-schema.sql) | **Social Media** | ⭐⭐⭐ Advanced | 14 | Posts, likes, followers, messages |

---

### E-commerce Schema ⭐⭐

**File:** [ecommerce-schema.sql](sample-schemas/ecommerce-schema.sql)  
**Complexity:** Intermediate  
**Tables:** 8 tables

**What's Included:**
- Complete CREATE TABLE statements
- Sample data (50+ rows)
- Indexes and constraints
- Common e-commerce queries
- Best practices comments

**Core Tables:**
- Products, Categories
- Customers, Addresses
- Orders, Order Items
- Payments, Shopping Carts

**Learn From This:**
- Product catalog organization
- Order processing workflow
- Payment handling
- Shopping cart implementation
- Customer management

**Use Cases:**
- Template for online store projects
- Study product-category relationships
- Understand order lifecycle
- Learn transaction patterns

---

### Library System Schema ⭐⭐

**File:** [library-system-schema.sql](sample-schemas/library-system-schema.sql)  
**Complexity:** Intermediate  
**Tables:** 12 tables

**What's Included:**
- Multi-branch library system
- Book catalog with authors (many-to-many)
- Loan management with renewals
- Reservation system (holds)
- Fine calculation and tracking
- Views, triggers, and procedures

**Core Tables:**
- Branches, Librarians, Members
- Books, Authors, Publishers, Categories
- Book Copies (physical items)
- Loans, Reservations, Fines

**Learn From This:**
- Multi-location management
- Physical item tracking (copies vs catalog)
- Temporal data (due dates, renewals)
- Fine calculation logic
- Automated triggers for counts

**Advanced Features:**
- Stored procedure for creating posts
- Triggers for updating counts
- Views for common queries
- Sample data for testing

**Use Cases:**
- Inventory management systems
- Rental/booking applications
- Multi-location businesses
- Item reservation systems

---

### Social Media Schema ⭐⭐⭐

**File:** [social-media-schema.sql](sample-schemas/social-media-schema.sql)  
**Complexity:** Advanced  
**Tables:** 14 tables

**What's Included:**
- User authentication and profiles
- Posts with media attachments
- Comments (nested/threaded)
- Likes (posts and comments)
- Followers and friendships
- Direct messaging
- Notifications
- Hashtags and trending
- Stored procedures and triggers

**Core Tables:**
- Users, User Profiles
- Posts, Post Media, Comments
- Post Likes, Comment Likes
- Followers, Friendships, User Blocks
- Messages, Notifications
- Hashtags, Post Hashtags

**Learn From This:**
- Social graph relationships
- Follower/following patterns
- Nested comments (self-referencing)
- Activity feed generation
- Notification system design
- Hashtag implementation
- Privacy controls

**Advanced Features:**
- Triggers for automated counts and notifications
- Stored procedure for post creation with hashtags
- Complex indexes for performance
- Views for common feeds

**Use Cases:**
- Social networking applications
- Community platforms
- Messaging systems
- Activity feed implementations

---

## 🎯 How to Use This Section

### For Exercises

**Step 1: Read Requirements**
- Review the business requirements carefully
- Identify entities and relationships
- Note any special constraints

**Step 2: Design Your Solution**
- Draw an ERD (use [Crow's Foot notation](../modeling-languages/erd/entity-relationship-examples.md))
- Apply [normalization rules](../notes/fundamentals/normalization.md)
- Define tables, columns, and relationships

**Step 3: Implement in SQL**
- Write CREATE TABLE statements
- Add constraints and indexes
- Insert sample data

**Step 4: Test Your Design**
- Write queries to answer business questions
- Test edge cases
- Verify constraints work

**Step 5: Compare and Learn**
- Compare with relevant sample schema
- Identify differences in approach
- Learn from alternative solutions

### For Sample Schemas

**Step 1: Study the Structure**
- Read through all CREATE TABLE statements
- Understand relationships and foreign keys
- Note indexes and constraints

**Step 2: Analyze the Data**
- Review sample data
- See how relationships work in practice
- Understand data types chosen

**Step 3: Run the Queries**
- Execute provided views
- Test stored procedures
- See triggers in action

**Step 4: Experiment**
- Add your own tables
- Modify existing structures
- Write additional queries

**Step 5: Apply to Your Projects**
- Use patterns in your own designs
- Adapt structures to different domains
- Build on these foundations

---

## 🎯 Learning Paths

### Path 1: Complete Beginner

**Week 1:** Bookstore Exercise
1. Read [exercise-01-bookstore.md](exercises/exercise-01-bookstore.md)
2. Design your ERD on paper
3. Implement in SQL
4. Compare with [ecommerce-schema.sql](sample-schemas/ecommerce-schema.sql)

**Week 2:** Study E-commerce Schema
1. Read through [ecommerce-schema.sql](sample-schemas/ecommerce-schema.sql)
2. Run it in your database
3. Write 10 practice queries
4. Modify schema (add reviews, wishlists, etc.)

### Path 2: Intermediate Developer

**Week 1:** Hospital Exercise
1. Attempt [exercise-02-hospital.md](exercises/exercise-02-hospital.md)
2. Focus on appointment scheduling
3. Implement basic version first
4. Add advanced features

**Week 2:** Study Library System
1. Analyze [library-system-schema.sql](sample-schemas/library-system-schema.sql)
2. Study the triggers and procedures
3. Test reservation and loan logic
4. Adapt for a different rental system

### Path 3: Advanced/Interview Prep

**Week 1:** University Exercise
1. Complete [exercise-03-university.md](exercises/exercise-03-university.md)
2. Implement recursive prerequisites
3. Add GPA calculation
4. Write complex reporting queries

**Week 2:** Social Media Deep Dive
1. Study [social-media-schema.sql](sample-schemas/social-media-schema.sql)
2. Understand social graph patterns
3. Optimize for performance
4. Design a feed generation algorithm

### Path 4: Build Your Own

**Combine Everything:**
1. Choose a domain you're passionate about
2. Design using lessons from exercises
3. Reference sample schemas for patterns
4. Build a complete, production-ready database

---

## 💡 Tips for Success

### Exercise Tips

**Do:**
✅ Start with identifying entities  
✅ Draw diagrams before coding  
✅ Normalize to 3NF first  
✅ Add sample data early to test  
✅ Write queries to validate design

**Don't:**
❌ Jump straight to SQL  
❌ Skip normalization  
❌ Forget about constraints  
❌ Ignore edge cases  
❌ Under-estimate time needed

### Schema Study Tips

**Do:**
✅ Run the entire schema  
✅ Modify and experiment  
✅ Understand "why" behind decisions  
✅ Write additional queries  
✅ Draw your own ERD from the schema

**Don't:**
❌ Just read - must execute  
❌ Copy blindly without understanding  
❌ Skip the sample data  
❌ Ignore comments and documentation

---

## 📊 Progress Tracker

### Exercises
- [ ] Bookstore (Beginner) - Attempted
- [ ] Bookstore (Beginner) - Completed
- [ ] Hospital (Advanced) - Attempted
- [ ] Hospital (Advanced) - Completed
- [ ] University (Advanced) - Attempted
- [ ] University (Advanced) - Completed

### Sample Schemas Studied
- [ ] E-commerce - Read through
- [ ] E-commerce - Ran and tested
- [ ] E-commerce - Modified/extended
- [ ] Library System - Read through
- [ ] Library System - Ran and tested
- [ ] Library System - Modified/extended
- [ ] Social Media - Read through
- [ ] Social Media - Ran and tested
- [ ] Social Media - Modified/extended

### Own Projects
- [ ] Designed own database (domain: _______________)
- [ ] Implemented in SQL
- [ ] Added sample data
- [ ] Deployed/used in a project

---

## 🔗 Related Sections

**Design Foundation:**
- ERD creation: [modeling-languages/erd/](../modeling-languages/erd/)
- Normalization: [notes/fundamentals/normalization.md](../notes/fundamentals/normalization.md)
- Relationships: [notes/fundamentals/relationships.md](../notes/fundamentals/relationships.md)

**Implementation Skills:**
- CREATE TABLE: [sql-practice/ddl/create-tables.sql](../sql-practice/ddl/create-tables.sql)
- Constraints: [sql-practice/ddl/constraints.sql](../sql-practice/ddl/constraints.sql)
- Complex joins: [sql-practice/joins/complex-joins.sql](../sql-practice/joins/complex-joins.sql)

**Advanced Topics:**
- Design patterns: [notes/advanced/database-design-patterns.md](../notes/advanced/database-design-patterns.md)
- Indexing: [notes/advanced/indexing-strategies.md](../notes/advanced/indexing-strategies.md)

---

## 🎓 Evaluation Criteria

### For Self-Assessment

When evaluating your exercise solutions:

**Data Modeling (40%):**
- [ ] All entities identified
- [ ] Proper normalization (3NF minimum)
- [ ] Relationships correctly modeled
- [ ] Appropriate use of junction tables

**SQL Implementation (30%):**
- [ ] Valid SQL syntax
- [ ] Proper data types chosen
- [ ] Constraints implemented (PK, FK, UNIQUE, CHECK)
- [ ] Indexes on foreign keys

**Functionality (20%):**
- [ ] Meets all business requirements
- [ ] Sample data works correctly
- [ ] Queries produce expected results
- [ ] Edge cases handled

**Best Practices (10%):**
- [ ] Consistent naming conventions
- [ ] Appropriate comments
- [ ] No redundant data (unless justified)
- [ ] Security considerations

---

## 🚀 Next Steps

After completing projects:
1. **Build a portfolio** - Document your best designs on GitHub
2. **Contribute to open source** - Find database-related projects
3. **Interview prep** - Practice explaining your design decisions
4. **Real-world application** - Use in actual projects
5. **Advanced learning** - Study [indexing](../notes/advanced/indexing-strategies.md) and [partitioning](../notes/advanced/partitioning.md)

---

**Navigation:** [🏠 Main](../README.md) | [📝 Notes](../notes/README.md) | [💻 SQL Practice](../sql-practice/README.md) | [🎨 Modeling](../modeling-languages/README.md) | [📚 Resources](../resources/README.md)
