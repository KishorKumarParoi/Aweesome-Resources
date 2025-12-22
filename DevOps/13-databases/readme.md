# Database Fundamentals 💾

Complete guide to MySQL and PostgreSQL for DevOps engineers.

---

## Table of Contents
1. [MySQL](#mysql)
2. [PostgreSQL](#postgresql)

---

## MySQL

Relational database with comprehensive SQL support.

### Database Operations

```sql
-- List all databases
SHOW DATABASES;

-- Use specific database
USE test_db;

-- Show current database
SELECT DATABASE();

-- Drop database
DROP DATABASE test_db;

-- Describe table structure
DESC customers;
```

### Table Operations

```sql
-- Create table
CREATE TABLE student(
  id INT,
  name VARCHAR(100)
);

-- Insert data
INSERT INTO students VALUES (102, "Kishor", "Rajshahi");

-- Select data
SELECT * FROM students WHERE id=101;

-- Update data
UPDATE students SET id = 103 WHERE name="kkp";

-- Delete data
DELETE FROM students WHERE id = 104;

-- Drop table
DROP TABLE students;
```

### Constraints

```sql
-- NOT NULL & DEFAULT constraints
CREATE TABLE customers3 (
  id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  acc_type VARCHAR(50) NOT NULL DEFAULT "Savings"
);

-- PRIMARY KEY & AUTO_INCREMENT
CREATE TABLE customers4 (
  acc_no INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  acc_type VARCHAR(50) NOT NULL DEFAULT 'savings'
);
```

### String Functions

```sql
-- Concatenate strings
SELECT CONCAT('hey', ' ', 'Kishor');
SELECT CONCAT_WS('-', 'hey', ' ', 'Kishor');

-- Substring operations
SELECT SUBSTRING('Kishor Kumar Paroi', 1, 6);
SELECT REPLACE(acc_no, 10, 10000) AS new_acc_no FROM customers4;

-- String transformations
SELECT REVERSE('hello');
SELECT CHAR_LENGTH('kishor');
SELECT LCASE(type), UPPER(name) FROM customers4;
SELECT INSERT('Hey Wassup', 5, 0, 'Kishor');
SELECT LEFT('hello', 2), RIGHT('hello', 2);
SELECT TRIM('  hello  ');
SELECT REPEAT('ha', 3);
```

### Data Retrieval

```sql
-- Distinct values
SELECT DISTINCT acc_type FROM customers4;

-- Sorting
SELECT * FROM customers4 ORDER BY name;
SELECT * FROM customers4 ORDER BY name DESC;

-- Pattern matching (LIKE)
SELECT * FROM customers4 WHERE name LIKE "%s___%";
```

### Alterations

```sql
-- Add column
ALTER TABLE customers4 ADD COLUMN total_cost INT NOT NULL DEFAULT 2000;

-- Update data
UPDATE customers4 SET total_cost=3500 WHERE name LIKE "P%";
```

### Pagination

```sql
-- LIMIT with OFFSET
SELECT * FROM customers4 LIMIT 2,4;  -- Offset 2, limit 4

-- Top result
SELECT * FROM customers4 ORDER BY total_cost DESC LIMIT 1;
```

### Aggregation

```sql
-- Count functions
SELECT COUNT(*) FROM customers4;
SELECT COUNT(DISTINCT total_cost) FROM customers4;
SELECT COUNT(DISTINCT acc_type) FROM customers4 WHERE total_cost = 3500;

-- Group by
SELECT TOTAL_COST FROM customers4 GROUP BY total_cost;
SELECT total_cost, COUNT(DISTINCT acc_type) FROM customers4 GROUP BY total_cost;

-- Sum & aggregate
SELECT acc_type, SUM(total_cost) FROM customers4 GROUP BY acc_type;
```

### Date & Time Functions

```sql
-- Date/time columns
CREATE TABLE person(
  date DATE,
  time TIME,
  datetime DATETIME
);

INSERT INTO person VALUES(CURDATE(), CURTIME(), NOW());

-- Date functions
SELECT MONTHNAME(NOW());
SELECT DATE_FORMAT(NOW(), '%d/%m/%y');
SELECT DATEDIFF('2024-05-12', '2024-01-11');
SELECT DATE_ADD(NOW(), INTERVAL 30 DAY);
SELECT DATE_SUB(NOW(), INTERVAL 30 DAY);
SELECT TIMEDIFF('23:23:23', '11:11:11');
```

### Auto Timestamp

```sql
-- Auto timestamp columns
CREATE TABLE blogs(
  blog VARCHAR(200),
  ct DATETIME DEFAULT CURRENT_TIMESTAMP,
  ut DATETIME ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO blogs(blog) VALUES('this is my first blog');
UPDATE blogs SET blog='this is second blog';  -- ut updates automatically
```

### Relationships & Joins

```sql
-- Create tables with foreign key
CREATE TABLE customers (
  cust_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(200)
);

CREATE TABLE orders (
  ord_id INT AUTO_INCREMENT PRIMARY KEY,
  date DATE,
  amount DECIMAL(10,2),
  cust_id INT,
  FOREIGN KEY (cust_id) REFERENCES customers(cust_id) ON DELETE CASCADE
);

-- Check constraints
SELECT constraint_name, column_name, referenced_table_name
FROM information_schema.key_column_usage
WHERE table_name='orders';

-- Insert data
INSERT INTO orders(date, amount, cust_id) VALUES (CURDATE(), 504.88, 30);

-- Join tables
SELECT * FROM customers
INNER JOIN orders ON orders.cust_id=customers.cust_id;
```

### Complex Queries

```sql
-- Multi-table join
SELECT student_name, course_name
FROM students
JOIN student_course ON student_course.student_id=students.id
JOIN courses ON courses.id=student_course.course_id;

-- Count enrollments
SELECT course_name, COUNT(student_id) AS enrolled_count
FROM courses
JOIN student_course ON student_course.course_id=courses.id
JOIN students ON student_course.student_id=students.id
GROUP BY course_name;

-- Course count and fees
SELECT student_name, COUNT(course_id) AS takenCourseCount, SUM(fees) AS totalFee
FROM students
JOIN student_course ON student_course.student_id=students.id
JOIN courses ON courses.id=student_course.course_id
GROUP BY student_name;
```

### Views & CASE Statements

```sql
-- Create view
CREATE VIEW inst_info AS
SELECT student_name, course_name, fees
FROM students
JOIN student_course ON student_course.student_id=students.id
JOIN courses ON student_course.course_id=courses.id;

-- CASE statement
SELECT
  student_name,
  SUM(fees) AS totalFee,
  CASE
    WHEN SUM(fees) BETWEEN 3000 AND 4999 THEN 'Borolok'
    WHEN SUM(fees) < 3000 THEN 'Gorib'
    WHEN SUM(fees) >= 5000 THEN 'Ultra borolok'
  END AS status
FROM inst_info
GROUP BY student_name;

-- WITH ROLLUP for totals
SELECT
  IFNULL(student_name, "Total") AS Name,
  SUM(fees) AS totalFee,
  CASE
    WHEN SUM(fees) BETWEEN 3000 AND 4999 THEN 'Borolok'
    WHEN SUM(fees) < 3000 THEN 'Gorib'
    ELSE 'Ultra borolok'
  END AS status
FROM inst_info
GROUP BY student_name WITH ROLLUP;
```

---

## PostgreSQL

Advanced open-source relational database with JSON support.

### Basic Commands

```bash
# List databases
\l

# Connect to database
\c test

# Clear screen
\!cls
```

### Advanced Features

**Window Functions**
```sql
SELECT
  student_name,
  fees,
  SUM(fees) OVER () AS total_fees,
  SUM(fees) OVER (ORDER BY fees) AS running_total
FROM students;
```

**JSON Support**
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  data JSONB
);

INSERT INTO users VALUES (1, '{"name": "Kishor", "age": 25}');

-- Query JSON
SELECT data->>'name' FROM users;
SELECT data->'age' FROM users;
```

**Full-text Search**
```sql
CREATE TABLE articles (
  id SERIAL PRIMARY KEY,
  content TEXT
);

-- Create full-text index
CREATE INDEX idx_content ON articles USING GIN(to_tsvector('english', content));

-- Search
SELECT * FROM articles 
WHERE to_tsvector('english', content) @@ plainto_tsquery('english', 'DevOps');
```

---

## MySQL vs PostgreSQL

| Feature | MySQL | PostgreSQL |
|---------|-------|-----------|
| **Compliance** | Some ACID | Full ACID |
| **JSON Support** | Limited | Excellent |
| **Replication** | Master-slave | WAL-based |
| **Scaling** | Good | Excellent |
| **Extensions** | Limited | Extensive |
| **Performance** | Fast for simple | Optimized queries |
| **Open Source** | Yes | Yes |

---

## Best Practices

✅ **Normalize schema** - Reduce redundancy
✅ **Index wisely** - Improve query performance
✅ **Use constraints** - Maintain data integrity
✅ **Backup regularly** - Disaster recovery
✅ **Monitor performance** - Slow query logs
✅ **Use transactions** - ACID compliance
✅ **Encrypt sensitive data** - Security
✅ **Version control** - Schema management

---

**Last Updated:** December 22, 2025
