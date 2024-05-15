#   SQL MINI PROJECT 

-- Part - A	

-- ICC Test Cricket

-- Dataset: ICC Test Batting Figures.csv

-- Tasks to be performed:


-- 1.	Import the csv file to a table in the database.
        create database `icc test cricket`;
        use `icc test cricket`;
        select * from `icc test batting figures (1)`;
        
-- 2.	Remove the column 'Player Profile' from the table.

alter table `icc test batting figures (1)`
drop column `Player Profile`;
select * from `icc test batting figures (1)`;

-- 3.	Extract the country name and player names from the given data and store it in separate columns for further usage.

select substr(player,position('(' in player))
from  `icc test batting figures (1)`;
alter table `icc test batting figures (1)`
add column country varchar(50) after player;
update `icc test batting figures (1)`
set country = substr(player,position('(' in player)),
player = TRIM(SUBSTRING_INDEX(player, '(', 1));
-- Here the position functiom is used to get the postion of given string, and then using susbtring is to find the value from that index position till last.

-- 4.	From the column 'Span' extract the start_year and end_year and store them in separate columns for further usage.

alter table `icc test batting figures (1)` add column start_year int after Span;
update `icc test batting figures (1)` set start_year=(substring(Span,1,4));
alter table `icc test batting figures (1)` add column end_year int after start_year;
update `icc test batting figures (1)` set end_year=substring(Span,6);

-- 5.	The column 'HS' has the highest score scored by the player so far in any given match.
--      The column also has details if the player had completed the match in a NOT OUT status. 
--       Extract the data and store the highest runs and the NOT OUT status in different columns.

alter table `icc test batting figures (1)` 
add column HighestRuns int, 
add column NotOut varchar(3);

update `icc test batting figures (1)` 
set HighestRuns = SUBSTRING_INDEX(HS, '*', 1),
NotOut = if(HS like '%*', 'Yes', 'No');

-- 6.	Using the data given, considering the players who were active in the year of 2019,
--      create a set of batting order of best 6 players using 
--      the selection criteria of those who have a good average score across all matches for India.

select * from `icc test batting figures (1)`
where start_year<=2019 and end_year>=2019 and country='(india)'
order by avg desc
limit 6;

-- 7.	Using the data given, considering the players who were active in the year of 2019,
--      create a set of batting order of best 6 players using the selection criteria
--      of those who have the highest number of 100s across all matches for India.

select player,country,`100` from `icc test batting figures (1)`
where start_year<=2019 and end_year>=2019 and country='(india)' 
order by `100` desc
limit 6;

-- 8.	Using the data given, considering the players who were active in the year of 2019,
--      create a set of batting order of best 6 players using 2 selection criteria of your own for India.

select * from `icc test batting figures (1)` 
where  country='(india)'and `100`>2 and hs>150
limit 6;

-- 9.	Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data given,
--      considering the players who were active in the year of 2019,
--      create a set of batting order of best 6 players
--      using the selection criteria of those who have a good average score across all matches for South Africa.

create view  Batting_Order_GoodAvgScorers_SA as 
select *from `icc test batting figures (1)` where start_year<=2019 and end_year>=2019 and country like'%SA%' 
limit 6;
select * from Batting_Order_GoodAvgScorers_SA;

-- 10.	Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ Using the data given,
--      considering the players who were active in the year of 2019,
--      create a set of batting order of best 6 players 
--      using the selection criteria of those who have highest number of 100s across all matches for South Africa.

create view Batting_Order_HighestCenturyScorers_SA as 
select player,country,`100` from `icc test batting figures (1)` 
where start_year<=2019 and end_year>=2019 and country like'%SA%' order by `100` desc 
limit 6;
select * from Batting_Order_HighestCenturyScorers_SA;

-- 11.	Using the data given, Give the number of player_played for each country.

select country, count(player) as no_of_player from `icc test batting figures (1)` 
group by country 
order by count(player) desc;

-- 12.	Using the data given, Give the number of player_played for Asian and Non-Asian continent

select case
when Country  in ('(INDIA)', '(ICC/INDIA)','(Pak)','(SL)','(BDESH)') then'Asian'
else 'Non-Asian'
end as Continent,
count(*) as no_player from `icc test batting figures (1)` 
group by Continent;

------------------------------------------------------------------------------------------------------------------------------------------

-- Part – B

-- Diagram: E-R Diagram of Supply_chain database 

-- Try to get insight of business through the dataset 

-- Instruction: Execute the SQL files in the sequence given below.
-- 1.	1_DDL_Case Study
-- 2.	2_Data
-- 3.	3_Data Constraints

start transaction;
use Supply_chain;
select * from customer;
select * from Orders;
select * from Supplier;
select * from Product;
select * from OrderItem;

-- 1.	Company sells the product at different discounted rates.
-- Refer actual product price in product table and selling price in the order item table.
-- Write a query to find out total amount saved in each order then display the orders from highest to lowest amount saved. 

select o.id,sum(p.unitprice - oi.unitprice) as totamnt_saved 
from orders o join orderitem oi on o.id=oi.orderid 
join product p on oi.productid=p.id 
group by o.id order by totamnt_Saved desc;

-- 2.	Mr. Kavin want to become a supplier. He got the database of "Richard's Supply" for reference. Help him to pick: 
-- a. List few products that he should choose based on demand.

select ProductName , count(o.quantity) as product_ordered
from product p join orderitem o 
on p.id=o.ProductId join orders o2
on o2.id=o.orderid
group by ProductName order by product_ordered desc;

-- b. Who will be the competitors for him for the products suggested in above questions.

select distinct s.companyname,p.productname from supplier s 
join product p on s.id=p.supplierid 
where p.id in(select p.id from product p join orderitem oi on p.id=oi.productid
group by p.id 
order by sum(oi.quantity) desc);

-- 3.	Create a combined list to display customers and suppliers details considering the following criteria 
-- ●	Both customer and supplier belong to the same country

select concat(firstname,' ',lastname)as customer_name  , CompanyName,c.country
from product p join orderitem o  on p.id=o.ProductId 
join orders o2 on o2.id=o.orderid 
join supplier s on s.id = p.SupplierId 
join customer c on c.id = o2.customerid
where c.country=s.country;

-- ●	Customer who does not have supplier in their country
select distinct  concat(firstname,' ',lastname)as customer_name
from product p join orderitem o 
on p.id=o.ProductId join orders o2
on o2.id=o.orderid right join 
supplier s on s.id = p.SupplierId join customer c
on c.id = o2.customerid
where c.country not in (select country from supplier );

-- ●	Supplier who does not have customer in their country
select distinct companyname  
from product p join orderitem o 
on p.id=o.ProductId join orders o2
on o2.id=o.orderid join 
supplier s on s.id = p.SupplierId join customer c
on c.id = o2.customerid
where s.country not in (select country from customer );

-- 4.	Every supplier supplies specific products to the customers.
-- Create a view of suppliers and total sales made by their products and write a query on this view to find out top 2 suppliers
-- (using windows function) in each country by total sales done by the products.

create view supplier_sales as
select  s.id,s.CompanyName,s.Country,
sum(oi.quantity * oi.UnitPrice) as total_sales
from supplier s
join orders o on s.id = o.id
join product p on o.id = p.id
join orderitem oi on p.id = oi.id
group by s.id;
select * from supplier_sales;

select * from (select * , rank()over(partition by country order by total_sales) rnk  from supplier_sales)t
where rnk<3;

-- 5.	Find out for which products, UK is dependent on other countries for the supply.
-- List the countries which are supplying these products in the same list.

select productname, s.country as supply_country from product p 
join orderitem o on p.id=o.ProductId 
join orders o2 on o2.id=o.orderid join 
supplier s on s.id = p.SupplierId 
join customer c on c.id = o2.customerid
where c.country = 'UK' and s.country!='UK';

-- 6.	Create two tables as ‘customer’ and ‘customer_backup’ as follow - 
-- ‘customer’ table attributes -
-- Id, FirstName,LastName,Phone
-- ‘customer_backup’ table attributes - 
-- Id, FirstName,LastName,Phone
-- Create a trigger in such a way that It should insert the details into the 
-- ‘customer_backup’ table when you delete the record from the ‘customer’ table automatically.

create table  customers (
  Id int primary key,
  FirstName varchar(20),
  LastName varchar(20),
  Phone int(20)
);

create table customer_backup (
  Id int primary key,
  FirstName varchar(20),
  LastName varchar(20),
  Phone int(20)
);

create trigger backup_customer
after delete on customers
for each row
insert into customer_backup
values(old.Id, old.FirstName, old.LastName, old.Phone);
---------------------------------------------------------------------------------------------------------

