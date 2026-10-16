-- EXPERIMENT 5: SQL VIEWS AND RECURSIVE CTE
-- Name: Ayush Singh
-- Registration No.: 25LBCS3283
-- Course: BTech CSE AIML-1 Group-B
-- Database: CompanyDB
--
-- AIM:
-- Create department salary summary and employee hierarchy
-- views, test view updatability, and display reporting chains
-- using a recursive CTE.
--

USE CompanyDB;


-- ============================================================
-- 1. EXTEND EMPLOYEE TABLE WITH MANAGER_ID
-- ============================================================

-- Add the manager_id column only if it does not already exist.
-- Execute this ALTER TABLE statement once on a fresh schema.

ALTER TABLE Employee
ADD COLUMN manager_id INT NULL;

-- Make manager_id a self-referencing foreign key.
ALTER TABLE Employee
ADD CONSTRAINT fk_employee_manager
FOREIGN KEY (manager_id) REFERENCES Employee(emp_id);


-- ============================================================
-- 2. ASSIGN MANAGER RELATIONSHIPS
-- ============================================================
-- Employee 1 is the top-level manager.
-- Employees 2-6 report to employee 1.
-- Employees 7-12 report to employee 2.
-- Employees 13-18 report to employee 3.
-- Employees 19-24 report to employee 4.
-- Employees 25-30 report to employee 5.
--

UPDATE Employee
SET manager_id = CASE
    WHEN emp_id BETWEEN 2 AND 6 THEN 1
    WHEN emp_id BETWEEN 7 AND 12 THEN 2
    WHEN emp_id BETWEEN 13 AND 18 THEN 3
    WHEN emp_id BETWEEN 19 AND 24 THEN 4
    WHEN emp_id BETWEEN 25 AND 30 THEN 5
    ELSE NULL
END;


-- Verify employee-manager relationships.

SELECT
    emp_id,
    emp_name,
    dept_id,
    manager_id
FROM Employee
ORDER BY emp_id;


-- ============================================================
-- 3. DEPARTMENT SALARY SUMMARY VIEW
-- Display employee count, average salary, minimum salary,
-- maximum salary, and total salary for each department.
-- ============================================================

CREATE OR REPLACE VIEW department_salary_summary AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MIN(e.salary) AS minimum_salary,
    MAX(e.salary) AS maximum_salary,
    SUM(e.salary) AS total_salary
FROM Department d
JOIN Employee e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;


-- Display the department salary summary.

SELECT *
FROM department_salary_summary
ORDER BY dept_id;


-- ============================================================
-- 4. EMPLOYEE HIERARCHY VIEW
-- Display each employee, department, immediate manager,
-- and salary.
-- ============================================================

CREATE OR REPLACE VIEW employee_hierarchy AS
SELECT
    e.emp_id,
    e.emp_name,
    e.dept_id,
    d.dept_name,
    e.manager_id,
    m.emp_name AS manager_name,
    e.salary
FROM Employee e
JOIN Department d
    ON e.dept_id = d.dept_id
LEFT JOIN Employee m
    ON e.manager_id = m.emp_id;


-- Display the employee hierarchy.

SELECT *
FROM employee_hierarchy
ORDER BY dept_id, emp_id;


-- ============================================================
-- 5. TEST VIEW UPDATABILITY
-- ============================================================

-- A. Update the base table directly.
-- This safely demonstrates that the salary change is possible.
-- Employee 6 receives a salary increase of 1000.

UPDATE Employee
SET salary = salary + 1000
WHERE emp_id = 6;


-- Verify the salary update.

SELECT
    emp_id,
    emp_name,
    salary
FROM Employee
WHERE emp_id = 6;


-- B. Test the joined employee_hierarchy view.
-- This view contains joins and may be non-updatable depending
-- on the view definition and MySQL rules.
--
-- The following statement is commented out so the full script
-- can run without stopping if MySQL rejects the update.
--
-- UPDATE employee_hierarchy
-- SET salary = salary + 1000
-- WHERE emp_id = 6;


-- C. Test the grouped department_salary_summary view.
-- Views containing GROUP BY and aggregate functions are
-- not directly updatable in MySQL.
--
-- The following statement is commented out because MySQL
-- will reject this update.
--
-- UPDATE department_salary_summary
-- SET average_salary = average_salary + 1000
-- WHERE dept_id = 1;


-- Verify the summary view after the base-table update.

SELECT *
FROM department_salary_summary
ORDER BY dept_id;


-- ============================================================
-- 6. RECURSIVE CTE: EMPLOYEE REPORTING CHAINS
-- Start with employees who have no manager, then recursively
-- find employees who report to each manager.
-- ============================================================

WITH RECURSIVE reporting_chain AS (
    -- Anchor member: top-level employees.
    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        1 AS level,
        CAST(e.emp_name AS CHAR(500)) AS reporting_path
    FROM Employee e
    WHERE e.manager_id IS NULL

    UNION ALL

    -- Recursive member: employees reporting to the current row.
    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        rc.level + 1,
        CONCAT(rc.reporting_path, ' -> ', e.emp_name)
    FROM Employee e
    JOIN reporting_chain rc
        ON e.manager_id = rc.emp_id
)
SELECT
    emp_id,
    emp_name,
    manager_id,
    level,
    reporting_path
FROM reporting_chain
ORDER BY reporting_path;


-- ============================================================
-- 7. FINAL VERIFICATION
-- ============================================================

-- Total employees.

SELECT COUNT(*) AS total_employees
FROM Employee;

-- Total departments.

SELECT COUNT(*) AS total_departments
FROM Department;

-- Verify the number of rows in each view.

SELECT COUNT(*) AS department_summary_rows
FROM department_salary_summary;

SELECT COUNT(*) AS employee_hierarchy_rows
FROM employee_hierarchy;


-- ============================================================
-- RESULT:
-- Created the department salary summary and employee hierarchy
-- views, demonstrated base-table updates and view limitations,
-- and used a recursive CTE to display reporting chains.
-- ============================================================
