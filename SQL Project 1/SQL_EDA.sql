/*
  Northwind SQL – Exploratory Data Analysis (EDA)

  Description:
  This file contains exploratory SQL queries to understand the 
  structure, completeness, and basic descriptive statistics 
  of the Northwind sample database. 
  The goal is to perform initial checks before business analysis.

  EDA Sections:
    1. Database Structure
    2. Row Counts per Table
    3. Sample Data Previews
    4. Missing / Null Value Checks
    5. Key Descriptive Statistics
    6. Distribution Exploration
*/

#Show all available tables in the database
SHOW TABLES;

#Count rows in tables
SELECT 'Customers' AS TableName, COUNT(*) AS RowCount FROM customers
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'Employees', COUNT(*) FROM employees
UNION ALL
SELECT 'Order_Details', COUNT(*) FROM order_details
UNION ALL
SELECT 'Shippers', COUNT(*) FROM shippers
UNION ALL
SELECT 'Categories', COUNT(*) FROM categories;


#Preview Customers table
SELECT * FROM customers LIMIT 5;

#Preview Orders table
SELECT * FROM orders LIMIT 5;

#Preview Products table
SELECT * FROM products LIMIT 5;

#Check for NULL values in Orders table
SELECT 
    SUM(CASE WHEN orderDate IS NULL THEN 1 ELSE 0 END) AS Null_OrderDate,
    SUM(CASE WHEN customerID IS NULL THEN 1 ELSE 0 END) AS Null_CustomerID,
    SUM(CASE WHEN employeeID IS NULL THEN 1 ELSE 0 END) AS Null_EmployeeID,
    SUM(CASE WHEN shipperID IS NULL THEN 1 ELSE 0 END) AS Null_ShipperID
FROM orders;

#Check for NULL values in Products table
SELECT 
    SUM(CASE WHEN productName IS NULL THEN 1 ELSE 0 END) AS Null_ProductName,
    SUM(CASE WHEN unitPrice IS NULL THEN 1 ELSE 0 END) AS Null_UnitPrice,
    SUM(CASE WHEN categoryID IS NULL THEN 1 ELSE 0 END) AS Null_CategoryID
FROM products;

#Check for NULL values in Customers table
SELECT 
    SUM(CASE WHEN companyName IS NULL THEN 1 ELSE 0 END) AS Null_CompanyName,
    SUM(CASE WHEN contactName IS NULL THEN 1 ELSE 0 END) AS Null_ContactName,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS Null_Country
FROM customers;

#Product Price Statistics
SELECT MIN(UnitPrice) AS MinPrice,
       MAX(UnitPrice) AS MaxPrice,
       AVG(UnitPrice) AS AvgPrice
FROM products;

#Freight (Shipping Cost) Statistics
SELECT MIN(freight) AS MinFreight,
       MAX(freight) AS MaxFreight,
       AVG(freight) AS AvgFreight
FROM orders;

#Quantity Statistics (Order Details)
SELECT MIN(quantity) AS MinQty,
       MAX(quantity) AS MaxQty,
       AVG(quantity) AS AvgQty
FROM order_details;

#Number of unique customer countries
SELECT COUNT(DISTINCT country) AS unique_countries
FROM customers;

#Orders per year
SELECT YEAR(orderDate) AS order_year, COUNT(orderID) AS num_orders
FROM orders
GROUP BY YEAR(orderDate)
ORDER BY order_year;


#Distribution of orders by shippers
SELECT s.companyName, COUNT(o.orderID) AS num_orders
FROM orders o
JOIN shippers s ON o.shipperID = s.shipperID
GROUP BY s.companyName
ORDER BY num_orders DESC;



