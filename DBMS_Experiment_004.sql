-- EXPERIMENT 4: SQL JOINS, SUBQUERIES AND EXECUTION PLANS
-- Name: Ayush Singh
-- Registration No.: 25LBCS3283
-- Course: BTech CSE AIML-1 Group-B
-- Database: CompanyDB
--
-- AIM:
-- To demonstrate INNER JOIN, LEFT JOIN, SELF JOIN, 3-WAY JOIN,
-- correlated subqueries, EXISTS, simulated INTERSECT and EXCEPT,
-- and execution plan analysis using EXPLAIN.

USE CompanyDB;

-- 1. INNER JOIN
-- Display employee names, salaries, and department names.

SELECT
    e.emp_id,
    e.emp_name,
    e.salary,
    d.dept_name
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id
ORDER BY e.emp_id;


-- 2. LEFT JOIN
-- Display all departments and their employees.
-- Departments without employees would still appear.

SELECT
    d.dept_id,
    d.dept_name,
    e.emp_name,
    e.salary
FROM Department d
LEFT JOIN Employee e
    ON d.dept_id = e.dept_id
ORDER BY d.dept_id, e.emp_id;


-- 3. SELF JOIN
-- Compare pairs of employees working in the same department.
-- emp_id < emp_id prevents duplicate pairs and self-pairing.
-- Display the first 10 pairs.


SELECT
    e1.emp_name AS employee_1,
    e2.emp_name AS employee_2,
    e1.dept_id,
    e1.salary AS salary_1,
    e2.salary AS salary_2
FROM Employee e1
INNER JOIN Employee e2
    ON e1.dept_id = e2.dept_id
    AND e1.emp_id < e2.emp_id
ORDER BY e1.dept_id, e1.emp_id, e2.emp_id
LIMIT 10;


-- 4. THREE-WAY JOIN
-- Display employee, department, project, and salary details.

SELECT
    e.emp_name,
    d.dept_name,
    p.project_name,
    e.salary
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id
INNER JOIN Project p
    ON e.project_id = p.project_id
ORDER BY d.dept_name, e.emp_name;



-- 5. CORRELATED SUBQUERY
-- Find employees earning more than their department's
-- average salary.


SELECT
    e.emp_id,
    e.emp_name,
    e.salary,
    e.dept_id
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
)
ORDER BY e.dept_id, e.salary DESC;


-- ============================================================
-- 6. EXISTS
-- Find departments with at least one employee earning
-- more than 80000.
-- ============================================================

SELECT
    d.dept_id,
    d.dept_name
FROM Department d
WHERE EXISTS (
    SELECT 1
    FROM Employee e
    WHERE e.dept_id = d.dept_id
      AND e.salary > 80000
)
ORDER BY d.dept_id;


-- ============================================================
-- 7. SIMULATED INTERSECT
-- Find employees who belong to IT AND earn more than 70000.
--
-- Set A: Employees in IT.
-- Set B: Employees earning more than 70000.
-- Result: Employees belonging to both sets.
-- ============================================================

SELECT
    emp_id,
    emp_name,
    salary
FROM Employee
WHERE emp_id IN (
    SELECT emp_id
    FROM Employee
    WHERE dept_id = 1
)
AND emp_id IN (
    SELECT emp_id
    FROM Employee
    WHERE salary > 70000
)
ORDER BY emp_id;


-- ============================================================
-- 8. SIMULATED EXCEPT
-- Find employees earning more than 70000 who do NOT belong
-- to IT.
--
-- Set A: Employees earning more than 70000.
-- Set B: Employees in IT.
-- Result: Set A excluding Set B.
-- ============================================================

SELECT
    emp_id,
    emp_name,
    salary
FROM Employee
WHERE emp_id IN (
    SELECT emp_id
    FROM Employee
    WHERE salary > 70000
)
AND emp_id NOT IN (
    SELECT emp_id
    FROM Employee
    WHERE dept_id = 1
)
ORDER BY emp_id;


-- ============================================================
-- 9A. EXPLAIN: INNER JOIN
-- Inspect the execution plan for the join and salary filter.
-- ============================================================

EXPLAIN
SELECT
    e.emp_name,
    d.dept_name
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id
WHERE e.salary > 70000;


-- ============================================================
-- 9B. EXPLAIN: CORRELATED SUBQUERY
-- Inspect the execution plan for department-average filtering.
-- ============================================================

EXPLAIN
SELECT
    e.emp_name,
    e.salary
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
);


-- ============================================================
-- 9C. EXPLAIN: EXISTS
-- Inspect the execution plan for the existence check.
-- ============================================================

EXPLAIN
SELECT
    d.dept_name
FROM Department d
WHERE EXISTS (
    SELECT 1
    FROM Employee e
    WHERE e.dept_id = d.dept_id
      AND e.salary > 80000
);


-- ============================================================
-- 10. OPTIONAL: EXPLAIN ANALYZE
-- MySQL 8.0.18+.
-- Actually executes the SELECT and reports runtime details.
-- Run separately if supported by your MySQL version.
-- ============================================================

-- EXPLAIN ANALYZE
-- SELECT
--     e.emp_name,
--     d.dept_name
-- FROM Employee e
-- INNER JOIN Department d
--     ON e.dept_id = d.dept_id
-- WHERE e.salary > 70000;


-- ============================================================
-- RESULT VERIFICATION
-- ============================================================

-- Total employees
SELECT COUNT(*) AS total_employees
FROM Employee;

-- Total departments
SELECT COUNT(*) AS total_departments
FROM Department;

-- Total projects
SELECT COUNT(*) AS total_projects
FROM Project;


-- ============================================================
-- RESULT:
-- Demonstrated INNER JOIN, LEFT JOIN, SELF JOIN, THREE-WAY
-- JOIN, correlated subqueries, EXISTS, simulated INTERSECT,
-- simulated EXCEPT, and EXPLAIN execution plans.
-- ============================================================
