-- EXPERIMENT 6: STORED PROCEDURES AND TRIGGERS
-- Name: Ayush Singh
-- Registration No.: 25LBCS3283
-- Course: BTech CSE AIML-1 Group-B
-- Database: CompanyDB
--
-- AIM:
-- Create a validated employee transfer procedure, implement
-- salary validation triggers, and maintain a salary audit log.

USE CompanyDB;


-- ============================================================
-- 1. SALARY AUDIT TABLE
-- Store salary changes for auditing.
-- ============================================================

CREATE TABLE IF NOT EXISTS Employee_Salary_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(30) NOT NULL
);


-- ============================================================
-- 2. SALARY VALIDATION TRIGGER - INSERT
-- Reject salaries below 30000 or above 150000.
-- ============================================================

DROP TRIGGER IF EXISTS validate_employee_salary_insert;

DELIMITER //

CREATE TRIGGER validate_employee_salary_insert
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary IS NOT NULL
       AND (NEW.salary < 30000 OR NEW.salary > 150000) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Salary must be between 30000 and 150000';
    END IF;
END//

DELIMITER ;


-- ============================================================
-- 3. SALARY VALIDATION TRIGGER - UPDATE
-- Apply the same salary limits to salary updates.
-- ============================================================

DROP TRIGGER IF EXISTS validate_employee_salary_update;

DELIMITER //

CREATE TRIGGER validate_employee_salary_update
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary IS NOT NULL
       AND (NEW.salary < 30000 OR NEW.salary > 150000) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Salary must be between 30000 and 150000';
    END IF;
END//

DELIMITER ;


-- ============================================================
-- 4. SALARY AUDIT TRIGGER
-- Record old and new salaries after a successful salary change.
-- ============================================================

DROP TRIGGER IF EXISTS audit_salary_update;

DELIMITER //

CREATE TRIGGER audit_salary_update
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NOT (OLD.salary <=> NEW.salary) THEN
        INSERT INTO Employee_Salary_Audit
            (emp_id, old_salary, new_salary, action)
        VALUES
            (NEW.emp_id, OLD.salary, NEW.salary, 'SALARY UPDATE');
    END IF;
END//

DELIMITER ;


-- ============================================================
-- 5. STORED PROCEDURE: TRANSFER EMPLOYEE
-- Validate employee ID and department ID.
-- Reject nonexistent IDs and transfers to the same department.
-- Roll back and return the SQL error if an exception occurs.
-- ============================================================

DROP PROCEDURE IF EXISTS transfer_employee;

DELIMITER //

CREATE PROCEDURE transfer_employee(
    IN p_emp_id INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE v_emp_count INT DEFAULT 0;
    DECLARE v_dept_count INT DEFAULT 0;
    DECLARE v_old_dept_id INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Validate employee existence.
    SELECT COUNT(*)
    INTO v_emp_count
    FROM Employee
    WHERE emp_id = p_emp_id;

    IF v_emp_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee does not exist';
    END IF;

    -- Validate department existence.
    SELECT COUNT(*)
    INTO v_dept_count
    FROM Department
    WHERE dept_id = p_new_dept_id;

    IF v_dept_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Department does not exist';
    END IF;

    -- Retrieve the employee's current department.
    SELECT dept_id
    INTO v_old_dept_id
    FROM Employee
    WHERE emp_id = p_emp_id
    FOR UPDATE;

    -- Prevent unnecessary transfers to the same department.
    IF v_old_dept_id = p_new_dept_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Employee is already in this department';
    END IF;

    -- Perform the transfer.
    UPDATE Employee
    SET dept_id = p_new_dept_id
    WHERE emp_id = p_emp_id;

    COMMIT;
END//

DELIMITER ;


-- ============================================================
-- 6. TEST SUCCESSFUL TRANSFER
-- Employee 6 is initially in IT (department 1).
-- Transfer the employee to Marketing (department 4).
-- ============================================================

CALL transfer_employee(6, 4);

SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee e
JOIN Department d
    ON e.dept_id = d.dept_id
WHERE e.emp_id = 6;


-- ============================================================
-- 7. TEST EDGE CASES
-- Execute each CALL separately because an invalid CALL
-- intentionally returns an error.
-- ============================================================

-- Test A: Employee does not exist.
-- Expected: Employee does not exist.
-- CALL transfer_employee(99, 4);

-- Test B: Department does not exist.
-- Employee 6 is currently in department 4.
-- Expected: Department does not exist.
-- CALL transfer_employee(6, 99);

-- Test C: Employee is already in the requested department.
-- Expected: Employee is already in this department.
-- CALL transfer_employee(6, 4);

-- Test D: Transfer employee 6 back to IT.
-- Expected: Successful transfer.
-- CALL transfer_employee(6, 1);


-- ============================================================
-- 8. TEST SALARY VALIDATION
-- Invalid update: must be rejected by the trigger.
-- Run separately to observe the expected error.
-- ============================================================

-- Expected error:
-- ERROR 1644 (45000):
-- Salary must be between 30000 and 150000.

-- UPDATE Employee
-- SET salary = 20000
-- WHERE emp_id = 6;


-- Valid update: should succeed and create an audit entry.
UPDATE Employee
SET salary = 85000
WHERE emp_id = 6;

SELECT
    emp_id,
    emp_name,
    salary
FROM Employee
WHERE emp_id = 6;


-- ============================================================
-- 9. TEST SALARY AUDIT LOG
-- Display recorded salary changes.
-- ============================================================

SELECT
    audit_id,
    emp_id,
    old_salary,
    new_salary,
    changed_at,
    action
FROM Employee_Salary_Audit
ORDER BY audit_id;


-- ============================================================
-- 10. VERIFY TRIGGERS AND PROCEDURE
-- ============================================================

SHOW TRIGGERS;

SHOW PROCEDURE STATUS
WHERE Db = 'CompanyDB'
  AND Name = 'transfer_employee';


-- ============================================================
-- RESULT:
-- Implemented a validated employee transfer procedure,
-- salary validation triggers for INSERT and UPDATE,
-- and an audit trigger for salary changes.
-- ============================================================
