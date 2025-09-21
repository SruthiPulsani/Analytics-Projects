  /*
  Northwind SQL Portfolio

  Description:
  This SQL portfolio demonstrates skills in querying and analyzing data 
  from the Northwind sample database. The queries cover:
    - Data exploration
    - Filtering and sorting
    - Aggregations and grouping
    - Joins (inner, cross, and self-joins)
    - Subqueries and Common Table Expressions (CTEs)
    - Window functions (RANK, DENSE_RANK, Running Totals)
    - Date functions (YEAR, MONTH)
    - Business analysis insights such as revenue, spending, and performance

  SQL Concepts & Functions Used:
    SELECT, FROM, WHERE, DISTINCT, ORDER BY, LIMIT
    COUNT(), SUM(), AVG()
    GROUP BY, HAVING
    INNER JOIN, CROSS JOIN, Self-Join
    Subqueries (scalar, correlated)
    WITH (CTEs)
    RANK(), DENSE_RANK(), SUM() OVER()
    YEAR(), MONTH()
    Revenue calculations with (UnitPrice * Quantity * (1 - Discount))

  Note:
  Each query is preceded by a comment explaining the objective.
  Results can be verified using the Northwind raw database and query output file in portfolio.
*/

  
  #List all customers located in the USA
  select*
  from customers 
  where country = 'USA';
  
  #Show the first 10 most expensive products
  select *
  from products
  order by 4 desc
  limit 10;
  
  #find all orders placed in January 2014
  select *
  from orders
  where orderDate between "2014-01-01" and "2014-01-31";
  
  #Display all employees who work in London
  select *
  from employees 
  where city = 'london';
  
  #How many customers are there in each country
  select count(distinct customerID) customer_count, country
  from customers 
  group by country
  order by 1 desc;
  
 #What is the average shipping (freight) cost per shipper
 select shipperID, avg(freight) as avg_freight
 from orders
 group by shipperID;
 
 #Which product has the highest price
 select *
 from products
  order by 4 desc
  limit 1;
  
 #Calculate the total sales revenue for each year
    with new_order_details as
    (SELECT 
        orders.orderID AS order_id_order,
        orders.orderDate,
        order_details.quantity,
        order_details.unitPrice,
        order_details.orderID AS order_id_detail
    FROM orders
    JOIN order_details
      ON orders.orderID = order_details.orderID
      ),
	new_order_details_1 as
      (select order_id_order, year(orderDate) as year, quantity*unitPrice as sales_revenue
      from new_order_details)
      
      select year, sum(sales_revenue) as sales_revenue
      from new_order_details_1
      group by year;
      
#Show each order with the customer who placed it
select orders.orderID, orders.customerID, orders.orderDate, customers.companyName, customers.contactName
from orders
join customers 
on orders.customerID = customers.customerID;

#List each product along with its category name
select products.productID,products.productName,categories.categoryName,categories.description
from products
join categories
on products.categoryID = categories.categoryID
order by 2;

#Which employee handled which orders?
select orders.orderID, employees.employeeID, employees.employeeName, employees.title
from orders
join employees
on orders.employeeID = employees.employeeID
order by 1;

#Show employees along with their managers
SELECT 
    e.employeeID AS EmployeeID,
    e.employeeName AS EmployeeName,
    m.employeeName AS ManagerName
FROM employees e
JOIN employees m
  ON e.reportsTo = m.employeeID;

#Find products that are more expensive than the average product price.
select productID, productName, UnitPrice
from products 
where unitprice > (
select avg(UnitPrice)
from products);

#Which customers have placed more than 10 orders?
with count_orders as (
select customerID, count(orderID) as order_count
from orders
group by customerID)

select c.customerID, c.companyName, co.order_count
from count_orders co
join customers c
on co.customerID = c.customerID
where co.order_count > 10;

#Find employees who have handled orders above the average order value

with new_OD as 
(select quantity*unitPrice*(1-discount) as order_value, orderID
from order_details),

avg_value_table as 
(
select avg(new_OD.order_value) as avg_order_value , orders.employeeID, employees.employeeName
from new_OD 
join orders 
on new_OD.orderID = orders.orderID
join employees
on orders.employeeID = employees.employeeID
group by employees.employeeName, orders.employeeID 
),

order_value_table as
(select avg(order_value) as overall_avg from new_OD )

select a.avg_order_value, a.employeeID, a.employeeName
from avg_value_table a cross join order_value_table o
where a.avg_order_value > o.overall_avg;

#Rank customers by their total spending
with customers_ranking as 
(
select c.customerID , sum(unitPrice*quantity*(1-discount)) as spending
from order_details od
join orders o
on od.orderID = o.orderID
join customers c
on o.customerID = c.customerID
group by c.customerID
)

select *,
rank() over(order by spending desc) as ranking
from customers_ranking;

#Find the running total of sales by month.
with new_total_sales as
(select sum(unitPrice*quantity*(1-discount)) as total_sales, month(orderdate) as month_of
from order_details od
join orders o
on od.orderID = o.orderID
group by month_of)

select *,
sum(total_sales) over(order by month_of) as running_total
from new_total_sales;


#Show the top 3 products by revenue within each category.

with revenue_new as
(select c.categoryID,p.productID, sum(od.unitPrice*od.quantity*(1-od.discount)) as revenue
from order_details od
join products p
on od.productID = p.productID 
join categories c 
on p.categoryID = c.categoryID
group by c.categoryID, p.productID),

tanked_revenue as (

select *,
dense_rank() over(partition by categoryID order by revenue desc) as ranking 
from revenue_new)

select * 
from tanked_revenue 
where ranking <=3;

#Who are the top 5 customers by total spending?
select c.customerID , c.companyName, sum(unitPrice*quantity*(1-discount)) as spending
from order_details od
join orders o
on od.orderID = o.orderID
join customers c
on o.customerID = c.customerID
group by c.customerID, c.companyName
order by sum(unitPrice*quantity*(1-discount)) desc
limit 5;

#Which employee has handled the most orders?
select  employees.employeeID, employees.employeeName, count(orders.orderID) as count_orders
from orders
join employees
on orders.employeeID = employees.employeeID
group by employees.employeeID, employees.employeeName
order by count(orders.orderID)  desc
limit 1 ;

#Which shipper has delivered the most orders?
select s.shipperID, s.companyName, count(o.orderID) as count_orders
from orders o
join shippers s
on o.shipperID = s.shipperID
group by s.shipperID, s.companyName
order by 3 desc
limit 1;
  
#What is the total sales revenue for each product category?
select c.categoryID, c.categoryName, sum(od.unitPrice*od.quantity*(1-od.discount)) as revenue
from order_details od
join products p
on od.productID = p.productID 
join categories c 
on p.categoryID = c.categoryID
group by c.categoryID , c.categoryName;

#Which month had the highest sales revenue?
select month(o.orderDate) as month_of, sum(od.unitPrice*od.quantity*(1-od.discount)) as sales_revenue
from order_details od
join orders o
on od.orderID = o.orderID 
group by month(o.orderDate)
order by 2 desc
limit 1;


  