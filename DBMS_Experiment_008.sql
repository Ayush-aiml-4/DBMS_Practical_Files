CREATE DATABASE bank_db;
USE bank_db;

CREATE TABLE Account(
    acc_no INT PRIMARY KEY,
    name VARCHAR(30),
    balance DECIMAL(10,2)
);

INSERT INTO Account VALUES
(101,'Aarav',10000),
(102,'Riya',5000);

-- Transaction with COMMIT
START TRANSACTION;

UPDATE Account
SET balance=balance-2000
WHERE acc_no=101;

UPDATE Account
SET balance=balance+2000
WHERE acc_no=102;

COMMIT;

SELECT * FROM Account;

-- SAVEPOINT and partial rollback
START TRANSACTION;

UPDATE Account
SET balance=balance-1000
WHERE acc_no=101;

SAVEPOINT sp1;

UPDATE Account
SET balance=balance+1000
WHERE acc_no=102;

ROLLBACK TO sp1;

COMMIT;

SELECT * FROM Account;

-- Complete rollback
START TRANSACTION;

UPDATE Account
SET balance=balance-5000
WHERE acc_no=101;

ROLLBACK;

SELECT * FROM Account;

-- Isolation level
SET SESSION TRANSACTION ISOLATION LEVEL
READ COMMITTED;

START TRANSACTION;

SELECT * FROM Account;

COMMIT;

-- Check current isolation level
SELECT @@transaction_isolation;
