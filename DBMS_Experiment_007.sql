CREATE DATABASE normalization_db;
USE normalization_db;

-- UNF: Multiple products in one row
CREATE TABLE Sales_UNF(
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    CustomerName VARCHAR(40),
    Products VARCHAR(100),
    Quantities VARCHAR(50),
    Prices VARCHAR(50)
);

INSERT INTO Sales_UNF VALUES
(101,1,'Aarav','Laptop,Mouse','1,2','50000,800'),
(102,2,'Riya','Keyboard,Mouse','1,1','1500,800');

-- 1NF: Atomic values
CREATE TABLE Sales_1NF(
    OrderID INT,
    ProductID INT,
    CustomerID INT,
    CustomerName VARCHAR(40),
    ProductName VARCHAR(40),
    Quantity INT,
    Price DECIMAL(10,2),
    PRIMARY KEY(OrderID,ProductID)
);

INSERT INTO Sales_1NF VALUES
(101,1,1,'Aarav','Laptop',1,50000),
(101,2,1,'Aarav','Mouse',2,800),
(102,3,2,'Riya','Keyboard',1,1500),
(102,2,2,'Riya','Mouse',1,800);

-- 2NF: Remove partial dependencies
CREATE TABLE Customer(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(40)
);

CREATE TABLE Product(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(40),
    Price DECIMAL(10,2)
);

CREATE TABLE OrderDetails(
    OrderID INT,
    ProductID INT,
    Quantity INT,
    PRIMARY KEY(OrderID,ProductID)
);

-- 3NF: Separate transitive dependencies
CREATE TABLE Orders(
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    FOREIGN KEY(CustomerID) REFERENCES Customer(CustomerID)
);

-- Insert normalized data
INSERT INTO Customer VALUES
(1,'Aarav'),
(2,'Riya');

INSERT INTO Product VALUES
(1,'Laptop',50000),
(2,'Mouse',800),
(3,'Keyboard',1500);

INSERT INTO Orders VALUES
(101,1),
(102,2);

INSERT INTO OrderDetails VALUES
(101,1,1),
(101,2,2),
(102,3,1),
(102,2,1);

-- BCNF check
SELECT * FROM Orders;
SELECT * FROM Customer;
SELECT * FROM Product;
SELECT * FROM OrderDetails;

-- Lossless Join Verification
SELECT o.OrderID,c.CustomerName,p.ProductName,od.Quantity
FROM Orders o
JOIN Customer c ON o.CustomerID=c.CustomerID
JOIN OrderDetails od ON o.OrderID=od.OrderID
JOIN Product p ON od.ProductID=p.ProductID;

-- Dependency preservation check
SELECT OrderID,CustomerID FROM Orders;
SELECT CustomerID,CustomerName FROM Customer;
SELECT ProductID,ProductName,Price FROM Product;
SELECT OrderID,ProductID,Quantity FROM OrderDetails;
