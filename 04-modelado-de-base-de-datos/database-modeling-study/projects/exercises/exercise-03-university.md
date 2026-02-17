# Exercise 03: University Management System

## Overview

Design a comprehensive database for a university that manages students, instructors, courses, enrollments, grades, and departments. This exercise covers academic systems with complex many-to-many relationships and hierarchical structures.

---

## Business Requirements

### Core Entities

1. **Students**
   - Personal information (name, email, phone)
   - Student ID number
   - Enrollment date
   - Major/program
   - Current status (active, graduated, on leave)
   - GPA

2. **Instructors**
   - Personal information
   - Employee ID
   - Department affiliation
   - Hire date
   - Academic rank (Lecturer, Assistant Professor, Professor)
   - Office location

3. **Courses**
   - Course code (e.g., CS101)
   - Course title
   - Credits
   - Department
   - Prerequisites
   - Description

4. **Course Sections**
   - Course offering for specific semester
   - Instructor assigned
   - Schedule (days and time)
   - Room location
   - Maximum enrollment
   - Current enrollment

5. **Enrollments**
   - Student enrolled in course section
   - Enrollment date
   - Grade
   - Status (enrolled, completed, withdrawn)

6. **Departments**
   - Department name
   - Building location
   - Department chair (instructor)
   - Budget

7. **Programs/Majors**
   - Program name (Computer Science, Mathematics, etc.)
   - Degree type (BS, BA, MS, PhD)
   - Required credits
   - Department

8. **Semesters**
   - Semester code (Fall 2024, Spring 2025)
   - Start and end dates

---

## Exercise Tasks

### Part 1: Conceptual Design (ERD)

Create an Entity-Relationship Diagram showing:
- All entities and their attributes
- Relationships with cardinality
- Key attributes (primary and foreign keys)

**Key Relationships to Model:**
- Students enroll in multiple course sections
- Course sections are taught by one instructor
- Courses can have prerequisites (self-referencing)
- Instructors belong to departments
- Programs require specific courses

**Questions to Consider:**
- How do you represent course prerequisites?
- How do you track historical enrollments vs current?
- Should grades be stored separately or in enrollment?
- How to handle courses offered in multiple semesters?

---

### Part 2: Normalization Analysis

1. **Identify Normalization Issues**
   - Analyze each entity for 1NF, 2NF, 3NF violations
   - Document any denormalization decisions

2. **Potential Issues to Address:**
   - Storing instructor name in course sections (denormalization?)
   - Storing GPA in student table (calculated field)
   - Semester information duplication

**Exercise:**
Consider this table design:
```
Course_Sections (
    section_id,
    course_code,
    course_title,  -- Is this 2NF violation?
    instructor_name,  -- Is this acceptable?
    semester,
    room
)
```
Is it normalized? If not, how would you fix it?

---

### Part 3: Database Schema (DDL)

Create SQL tables for:

### 1. Students
```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    enrollment_date DATE NOT NULL,
    major_id INT,
    status ENUM('active', 'graduated', 'on_leave', 'withdrawn') DEFAULT 'active',
    gpa DECIMAL(3, 2),
    FOREIGN KEY (major_id) REFERENCES programs(program_id)
);
```

### 2. Instructors
```sql
-- Design this table with:
-- instructor_id, employee_number, name, email, hire_date, rank, office, department_id
```

### 3. Departments
```sql
-- Include circular FK: chair_id references instructors
```

### 4. Programs
```sql
-- program_id, program_name, degree_type, department_id, required_credits
```

### 5. Courses
```sql
-- course_id, course_code, title, credits, department_id, description
```

### 6. Course_Prerequisites
```sql
-- Handle many-to-many relationship: one course can have multiple prerequisites
```

### 7. Semesters
```sql
-- semester_id, semester_code, start_date, end_date, is_current
```

### 8. Course_Sections
```sql
-- section_id, course_id, instructor_id, semester_id, room, schedule, max_enrollment
```

### 9. Enrollments
```sql
-- enrollment_id, student_id, section_id, enrollment_date, grade, status
```

### 10. Program_Requirements
```sql
-- Which courses are required for which programs
-- program_id, course_id, requirement_type (required, elective)
```

---

### Part 4: Sample Data

Insert sample data including:

1. **3 Departments:**
   - Computer Science
   - Mathematics
   - Physics

2. **5 Instructors:**
   - At least 1 per department
   - One should be department chair

3. **10 Courses:**
   - Mix of introductory and advanced
   - Some with prerequisites

4. **2 Semesters:**
   - Fall 2024
   - Spring 2025

5. **15 Course Sections:**
   - Multiple sections of popular courses
   - Across different semesters

6. **10 Students:**
   - Various majors
   - Different academic standings

7. **30+ Enrollments:**
   - Students enrolled in multiple courses
   - Mix of current and completed courses
   - Various grades

---

### Part 5: Required Queries

Write SQL queries for:

1. **List all courses offered in a specific semester**
   ```sql
   -- Show course code, title, instructor name, schedule
   ```

2. **Find all students enrolled in a specific course section**
   ```sql
   -- Show student name, email, enrollment status
   ```

3. **Get a student's transcript**
   ```sql
   -- Show all courses taken, grades, credits, ordered by semester
   ```

4. **Calculate a student's GPA**
   ```sql
   -- Use grade points: A=4.0, B=3.0, C=2.0, D=1.0, F=0.0
   -- Weighted by course credits
   ```

5. **Find courses a student is eligible to take**
   ```sql
   -- Courses in their major where they've completed prerequisites
   ```

6. **List instructor's teaching load**
   ```sql
   -- Show all sections taught by instructor in current semester
   -- Include total students and capacity
   ```

7. **Find courses with available seats**
   ```sql
   -- WHERE current_enrollment < max_enrollment
   ```

8. **Get department course offerings statistics**
   ```sql
   -- Count courses, sections, total enrollment per department
   ```

9. **Find students on academic probation**
   ```sql
   -- GPA < 2.0 and status = 'active'
   ```

10. **List prerequisite chain for a course**
    ```sql
    -- Recursive query to show all prerequisites and their prerequisites
    ```

---

### Part 6: Advanced Features

### 1. Create View: Student Dashboard
```sql
-- Show student info with:
-- - Total credits earned
-- - Current GPA
-- - Current semester enrollments
-- - Credits needed to graduate
```

### 2. Stored Procedure: Enroll Student
```sql
DELIMITER //
CREATE PROCEDURE enroll_student(
    IN p_student_id INT,
    IN p_section_id INT
)
BEGIN
    -- Check prerequisites completed
    -- Check section capacity
    -- Check schedule conflicts
    -- Insert enrollment
    -- Update section enrollment count
END //
DELIMITER ;
```

### 3. Trigger: Update GPA After Grade Entry
```sql
-- When a grade is entered (enrollment updated)
-- Recalculate student's GPA
```

### 4. Trigger: Prevent Overenrollment
```sql
-- BEFORE INSERT on enrollments
-- Check if section is full
-- Raise error if at capacity
```

### 5. Create Indexes
```sql
-- Index on student last name
-- Index on course code
-- Index on enrollment section_id and student_id
-- Composite index on section (course_id, semester_id)
```

---

## Bonus Challenges

### 1. Course Waitlist
Add a waitlist feature:
- Waitlist table (waitlist_id, student_id, section_id, position, added_date)
- When student withdraws, automatically enroll first waitlist student
- Query to show waitlist for each course

### 2. Grade Distribution Analysis
Create queries to show:
- Grade distribution (A, B, C, D, F counts) per course
- Average GPA per major
- Instructor grade distribution patterns

### 3. Graduation Requirements Check
Create a stored procedure:
- Check if student has completed all required courses
- Check if total credits >= requirement
- Return list of missing requirements

### 4. Room Scheduling Conflicts
Create a query to detect:
- Two sections scheduled in same room at same time
- Instructor teaching multiple sections at same time

### 5. Course Recommendations
Create a query to suggest:
- Courses based on student's major
- Courses based on completed prerequisites
- Popular courses among students in same major

---

## Solution Hints

### Hint 1: Prerequisites (Self-Referencing Many-to-Many)
```sql
CREATE TABLE course_prerequisites (
    course_id INT,  -- The course that requires prerequisites
    prerequisite_id INT,  -- The prerequisite course
    PRIMARY KEY (course_id, prerequisite_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (prerequisite_id) REFERENCES courses(course_id)
);
```

### Hint 2: GPA Calculation
```sql
SELECT 
    s.student_id,
    SUM(c.credits * 
        CASE e.grade
            WHEN 'A' THEN 4.0
            WHEN 'B' THEN 3.0
            WHEN 'C' THEN 2.0
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
        END
    ) / SUM(c.credits) AS gpa
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN course_sections cs ON e.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
WHERE e.grade IS NOT NULL
GROUP BY s.student_id;
```

### Hint 3: Recursive Prerequisites Query
```sql
-- PostgreSQL / MySQL 8.0+
WITH RECURSIVE prereq_chain AS (
    SELECT course_id, prerequisite_id, 1 AS level
    FROM course_prerequisites
    WHERE course_id = ?  -- Input course
    
    UNION ALL
    
    SELECT cp.course_id, cp.prerequisite_id, pc.level + 1
    FROM course_prerequisites cp
    JOIN prereq_chain pc ON cp.course_id = pc.prerequisite_id
)
SELECT c.course_code, c.title, pc.level
FROM prereq_chain pc
JOIN courses c ON pc.prerequisite_id = c.course_id
ORDER BY pc.level, c.course_code;
```

### Hint 4: Schedule Conflict Detection
```sql
-- Check for room conflicts
SELECT cs1.section_id, cs1.room, cs1.schedule
FROM course_sections cs1
JOIN course_sections cs2 ON cs1.room = cs2.room
    AND cs1.schedule = cs2.schedule
    AND cs1.semester_id = cs2.semester_id
    AND cs1.section_id < cs2.section_id;  -- Avoid duplicates
```

---

## Evaluation Criteria

1. **Data Modeling (40%)**
   - Correct entity identification
   - Proper handling of many-to-many relationships
   - Self-referencing relationships (prerequisites, department chair)
   - Normalization to 3NF
   - Clear and complete ERD

2. **SQL Implementation (30%)**
   - Correct table structures
   - Appropriate data types and constraints
   - Referential integrity
   - Indexes on common query columns

3. **Queries (20%)**
   - Correctness and efficiency
   - Use of JOINs, aggregations, subqueries
   - Handling of recursive queries
   - GPA calculation accuracy

4. **Advanced Features (10%)**
   - Working stored procedures
   - Triggers that maintain data integrity
   - Views for complex queries
   - Bonus features

---

## Expected Deliverables

1. **ERD** (PNG/PDF or DBML code)
2. **DDL Script** (CREATE TABLE statements with comments)
3. **DML Script** (Sample data INSERT statements)
4. **Query Script** (All 10 required queries)
5. **Advanced Features Script** (Views, procedures, triggers)
6. **Documentation** (Design decisions, assumptions, normalization analysis)

---

## Real-World Considerations

In a real university system, you would also need:

- **Academic Calendar:** Terms, holidays, registration periods
- **Financial Aid:** Scholarships, grants, tuition management
- **Advising:** Student-advisor assignments, academic plans
- **Degree Audit:** Automated degree progress tracking
- **Transfer Credits:** Courses from other institutions
- **Grade Appeals:** Workflow for grade disputes
- **Class Registration:** Waitlists, drop/add periods, permissions
- **Security:** FERPA compliance, role-based access control
- **Reporting:** Enrollment reports, retention analytics, accreditation reports

---

## Learning Objectives

By completing this exercise, you will practice:

- ✅ Modeling self-referencing relationships (prerequisites, organizational hierarchy)
- ✅ Handling many-to-many relationships (students-courses, courses-prerequisites)
- ✅ Circular foreign key relationships (department-chair)
- ✅ Calculated fields vs stored values (GPA)
- ✅ Recursive queries (prerequisite chains)
- ✅ Complex business logic in SQL
- ✅ Data integrity with triggers
- ✅ Academic domain modeling

---

## Additional Resources

- Student Information System (SIS) architectures
- Academic standards and grading systems
- Course catalog management
- Banner, PeopleSoft, Ellucian systems (commercial SIS)
- Education data standards (IPEDS, Common Education Data Standards)

Good luck! 🎓
