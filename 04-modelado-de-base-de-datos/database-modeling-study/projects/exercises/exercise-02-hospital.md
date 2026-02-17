# Exercise 02: Hospital Management System

## Overview

Design a comprehensive database for a hospital management system that handles patients, doctors, appointments, treatments, medications, and billing.

---

## Business Requirements

### Core Entities

1. **Patients**
   - Personal information (name, birth date, contact details)
   - Medical history
   - Insurance information
   - Emergency contact

2. **Doctors**
   - Personal information
   - Specialization
   - License number
   - Department assignment
   - Work schedule

3. **Appointments**
   - Patient and doctor assignment
   - Date and time
   - Status (scheduled, completed, cancelled)
   - Reason for visit
   - Notes

4. **Medical Records**
   - Patient medical history
   - Diagnoses
   - Treatment plans
   - Lab results
   - Allergies

5. **Prescriptions**
   - Medications prescribed
   - Dosage and frequency
   - Duration
   - Pharmacy fulfillment

6. **Departments**
   - Department information
   - Location
   - Head doctor

7. **Rooms and Beds**
   - Room numbers and types (ICU, general, private)
   - Bed availability
   - Current occupancy

8. **Billing**
   - Services provided
   - Costs
   - Insurance claims
   - Payments

---

## Exercise Tasks

### Part 1: Conceptual Design (ERD)

Create an Entity-Relationship Diagram showing:
- All entities mentioned above
- Relationships between entities with cardinality
- Primary attributes for each entity

**Consider:**
- One patient can have many appointments
- One doctor can have many appointments
- One appointment can result in multiple prescriptions
- Patients can be admitted to rooms
- Doctors work in departments

---

### Part 2: Normalization

1. **Identify Normal Forms**
   - Are all entities in 3NF?
   - Are there any repeating groups?
   - Are there partial or transitive dependencies?

2. **Normalize if Needed**
   - Identify areas that violate normal forms
   - Create junction tables where needed
   - Justify your decisions

**Example to Consider:**
- Should patient address be in a separate table?
- How to handle multiple phone numbers for a patient?
- Should medication information be separate from prescriptions?

---

### Part 3: Create Database Schema (DDL)

Write SQL CREATE TABLE statements for:

1. **Patients Table**
   - patient_id (PK)
   - first_name
   - last_name
   - birth_date
   - gender
   - phone
   - email
   - address
   - insurance_info
   - emergency_contact_name
   - emergency_contact_phone

2. **Doctors Table**
   - doctor_id (PK)
   - first_name
   - last_name
   - specialization
   - license_number
   - phone
   - email
   - hire_date
   - department_id (FK)

3. **Departments Table**
   - department_id (PK)
   - department_name
   - location
   - head_doctor_id (FK)

4. **Appointments Table**
   - appointment_id (PK)
   - patient_id (FK)
   - doctor_id (FK)
   - appointment_date
   - appointment_time
   - status
   - reason
   - notes

5. **Medical_Records Table**
   - record_id (PK)
   - patient_id (FK)
   - doctor_id (FK)
   - visit_date
   - diagnosis
   - treatment_notes
   - follow_up_required

6. **Medications Table**
   - medication_id (PK)
   - medication_name
   - description
   - manufacturer
   - unit_price

7. **Prescriptions Table**
   - prescription_id (PK)
   - appointment_id (FK)
   - medication_id (FK)
   - dosage
   - frequency
   - duration_days
   - instructions

8. **Rooms Table**
   - room_id (PK)
   - room_number
   - room_type (ICU, General, Private)
   - floor
   - bed_count

9. **Admissions Table**
   - admission_id (PK)
   - patient_id (FK)
   - room_id (FK)
   - admit_date
   - discharge_date
   - diagnosis
   - attending_doctor_id (FK)

10. **Billing Table**
    - billing_id (PK)
    - patient_id (FK)
    - appointment_id (FK)
    - admission_id (FK)
    - total_amount
    - insurance_paid
    - patient_paid
    - date_issued
    - payment_status

**Include:**
- Appropriate data types
- Primary keys
- Foreign keys with ON DELETE and ON UPDATE rules
- NOT NULL constraints
- CHECK constraints where appropriate
- DEFAULT values

---

### Part 4: Sample Data (DML)

Insert sample data for:
- At least 5 patients
- At least 3 doctors across 2 departments
- At least 10 appointments (some completed, some scheduled)
- At least 5 prescriptions
- At least 2 room admissions

---

### Part 5: Queries

Write SQL queries to answer:

1. **List all appointments for a specific patient**
   ```sql
   -- Show patient name, doctor name, date, time, status
   ```

2. **Find all doctors in a specific department**
   ```sql
   -- Show doctor name, specialization
   ```

3. **Get patient medical history**
   ```sql
   -- Show all diagnoses and treatments for a patient
   ```

4. **Find available rooms**
   ```sql
   -- Show rooms that are not currently occupied
   ```

5. **Calculate total billing for a patient**
   ```sql
   -- Sum all charges for a specific patient
   ```

6. **List all prescriptions for an appointment**
   ```sql
   -- Show medication name, dosage, frequency, duration
   ```

7. **Find patients with upcoming appointments**
   ```sql
   -- Show patients with appointments in the next 7 days
   ```

8. **Get doctor's schedule for a specific date**
   ```sql
   -- Show all appointments for a doctor on a given date
   ```

9. **Find overdue bills**
   ```sql
   -- Show billing records with payment_status = 'pending' older than 30 days
   ```

10. **List most prescribed medications**
    ```sql
    -- Count prescriptions per medication, order by frequency
    ```

---

### Part 6: Advanced Features

1. **Create a View: Patient Dashboard**
   - Show patient info with count of appointments, admissions, and total billing

2. **Create a Stored Procedure: Schedule Appointment**
   - Input: patient_id, doctor_id, date, time, reason
   - Check doctor availability
   - Insert appointment
   - Return appointment_id or error

3. **Create a Trigger: Update Room Availability**
   - When a patient is discharged, update room status
   - Log the discharge in an audit table

4. **Create Indexes**
   - Index on patient last name for search
   - Index on appointment date for scheduling
   - Index on billing payment_status for reporting

---

## Bonus Challenges

### 1. Lab Tests
Add a lab tests feature:
- Lab_Tests table (test_id, test_name, cost)
- Test_Orders table (order_id, patient_id, test_id, order_date, result_date, results)
- Query to show pending lab results

### 2. Staff Management
Expand to include nurses, technicians:
- Staff table with role (doctor, nurse, technician)
- Shift_Schedule table
- Query to show who is working on a specific shift

### 3. Bed Management
Track individual beds:
- Beds table (bed_id, room_id, bed_number, status)
- Update Admissions to reference bed_id instead of room_id
- Query to show bed occupancy rate

### 4. Appointment Reminders
Create a query to identify:
- Patients with appointments tomorrow
- Format output for sending reminder emails/SMS

### 5. Doctor Performance
Create analytics queries:
- Number of patients seen per doctor
- Average appointment duration
- Patient satisfaction scores (if you add a ratings table)

---

## Solution Hints

### Hint 1: Department Head Circular Reference
```sql
-- Create tables in order:
-- 1. Create Departments without head_doctor_id FK
-- 2. Create Doctors with department_id FK
-- 3. Add head_doctor_id FK to Departments later
```

### Hint 2: Appointment Scheduling
```sql
-- Use CHECK constraint to ensure appointment_date is in the future
CHECK (appointment_date >= CURRENT_DATE)

-- Or use a trigger to validate
```

### Hint 3: Room Availability Query
```sql
-- Use LEFT JOIN to find rooms with no current admission
-- WHERE discharge_date IS NULL means currently occupied
-- WHERE admission_id IS NULL means room is available
```

### Hint 4: Billing Calculation
```sql
-- Consider separate tables for:
-- - Service_Charges (e.g., appointment fee, room charges)
-- - Procedure_Charges
-- - Medication_Charges
-- Then sum all for total billing
```

---

## Evaluation Criteria

Your solution will be evaluated on:

1. **Data Modeling (40%)**
   - Correct entity identification
   - Proper relationships and cardinality
   - Normalization to at least 3NF
   - Clear ERD

2. **SQL Implementation (30%)**
   - Correct data types
   - Proper constraints (PK, FK, NOT NULL, CHECK)
   - Referential integrity (ON DELETE, ON UPDATE)
   - Indexes on appropriate columns

3. **Queries (20%)**
   - Correct syntax
   - Efficient queries
   - Use of JOINs, aggregations, subqueries
   - Readable formatting

4. **Advanced Features (10%)**
   - Working views, procedures, triggers
   - Bonus features attempted
   - Code comments and documentation

---

## Expected Deliverables

1. **ERD (conceptual design)**
   - As image (PNG/PDF) or DBML code

2. **DDL Script**
   - CREATE TABLE statements
   - CREATE INDEX statements
   - Comments explaining decisions

3. **DML Script**
   - INSERT statements with sample data

4. **Query Script**
   - All 10 required queries
   - Bonus queries if attempted

5. **Documentation**
   - README explaining your design choices
   - Normalization analysis
   - Any assumptions made

---

## Real-World Considerations

In a real hospital system, you would also need:

- **Security and Compliance:** HIPAA compliance, encryption, audit logs
- **Backup and Recovery:** Regular backups, disaster recovery plan
- **Scalability:** Partitioning large tables, archiving old data
- **Integration:** HL7 standards, API for external systems
- **Reporting:** Complex analytics, reporting dashboards
- **Workflow:** Patient flow, waitlist management
- **Notifications:** Automated reminders, alerts

---

## Learning Objectives

By completing this exercise, you will practice:

- ✅ Designing complex database schemas
- ✅ Modeling many-to-many relationships
- ✅ Handling circular FK references
- ✅ Writing complex queries with JOINs
- ✅ Implementing business logic in SQL
- ✅ Creating views, procedures, and triggers
- ✅ Understanding real-world domain modeling

---

## Additional Resources

- Healthcare database design patterns
- HL7 FHIR standards
- Medical terminology databases (ICD-10, SNOMED CT)
- HIPAA compliance requirements
- Hospital information system (HIS) architectures

Good luck! 🏥
