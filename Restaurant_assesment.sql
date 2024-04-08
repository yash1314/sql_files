use restaurant
GO

--1. Convert Dataset to SQL Database:
-- Create SQL statements to define and populate tables for menu_details and order_details using the provided dataset.

Create Database resturant

-- 2. Basic SELECT Queries:
--- Retrieve all columns from the menu_items table.
--- Display the first 5 rows from the order_details table.

Select * from menu_items
Select top(5) * from order_details

--3. Filtering and Sorting:
-- Select the item_name and price columns for items in the 'Main Course' category.
-- Sort the result by price in descending order.

select item_name, price from menu_items order by price desc

--4. Aggregate Functions:
--- Calculate the average price of menu items.
--- Find the total number of orders placed.

select AVG(price) from menu_items
select COUNT(order_details_id) from order_details

--5. Joins:
--- Retrieve the item_name, order_date, and order_time for all items in the order_details table, including their respective menu item details.

select item_name, order_date, order_time from menu_items 
	right join order_details on menu_items.menu_item_id = order_details.item_id

--6. Subqueries:
--- List the menu items (item_name) with a price greater than the average price of all menu items.

select item_name from menu_items 
	where price > (select AVG(price) from menu_items)

--7. Date and Time Functions:
--- Extract the month from the order_date and count the number of orders placed in each month.

select MONTH(order_date) as 'order_month' from order_details
select COUNT(order_details_id) as 'Total_orders_by_month' from order_details group by DATEPART(MONTH, order_date) 

------------------------------OR----------

select MONTH(order_date) as 'Order_month', COUNT(*) as 'num_orders' from order_details group by MONTH(order_date)

--8. Group By and Having:
--- Show the categories with the average price greater than $15.
--- Include the count of items in each category.

select category, count(category) as 'Count' from menu_items where price > 15 group by category 

--9. Conditional Statements:
--- Display the item_name and price, and indicate if the item is priced above $20 with a new column named 'Expensive'.

select item_name, price, 
Case 
	when price > 20 then 'Yes'
	else 'No'
	end 
	as Expensive
from menu_items 

--10. Data Modification - Update:
--- Update the price of the menu item with item_id = 101 to $25.

Update menu_items
set price = 25
where menu_item_id = 101

--11. Data Modification - Insert:
--- Insert a new record into the menu_items table for a dessert item.

INSERT INTO menu_items (menu_item_id, item_name, category, price) 
VALUES (133, 'Ras_Malai', 'Dessert', 6.00);

--12. Data Modification - Delete:
--- Delete all records from the order_details table where the order_id is less than 100.

delete order_details where order_id < 100

--13. Window Functions - Rank:
--- Rank menu items based on their prices, displaying the item_name and its rank.

select item_name, RANK() over (order by price desc) as 'rank' from menu_items

--14. Window Functions - Lag and Lead:
--- Display the item_name and the price difference from the previous and next menu item.

with ordermenu(dish_name, price, lag_price, lead_price) 
as (
select item_name, price,
       LAG(price) OVER (ORDER BY item_name) AS prev_price,
       LEAD(price) OVER (ORDER BY item_name) AS next_price
from menu_items)

select 
dish_name, 
Case 
WHEN lag_price IS NOT NULL THEN price -lag_price
        ELSE NULL
    END AS price_difference_previous,
    CASE
        WHEN lead_price IS NOT NULL THEN lead_price - price
        ELSE NULL
    END AS price_difference_next
FROM 
    ordermenu;

--15. Common Table Expressions (CTE):
--- Create a CTE that lists menu items with prices above $15.
--- Use the CTE to retrieve the count of such items.

With item(item)
As(
	select item_name from menu_items where price > 15 )

select * from item

--16. Advanced Joins:
--- Retrieve the order_id, item_name, and price for all orders with their respective menu item details.
--- Include rows even if there is no matching menu item.

Select order_id, item_name, price from menu_items as m right Join order_details as o 
on m.menu_item_id = o.item_id


--17. Unpivot Data:
--- Unpivot the menu_items table to show a list of menu item properties (item_id, item_name, category, price).

SELECT *
FROM (
    SELECT menu_item_id, item_name, category, price
    FROM menu_items
) AS MenuItems
UNPIVOT (
    value FOR property IN (item_name, category)
) AS UnpivotedMenuItems;


--18. Dynamic SQL:
--- Write a dynamic SQL query that allows users to filter menu items based on category and price range.

DECLARE @category NVARCHAR(20),
        @price INT,
        @sqlcommand NVARCHAR(1000)

SET @category = 'American'
SET @price = 25
SET @sqlcommand = 'SELECT * FROM menu_items WHERE category = ''' + @category + ''' AND price = ' + CAST(@price AS NVARCHAR(10))

EXEC sp_executesql @sqlcommand


--19. Stored Procedure:
--- Create a stored procedure that takes a menu category as input and returns the average price for that category.
Create procedure category_price(@category as nvarchar(50))
as begin
select category, price from menu_items where category = @category
end

exec category_price 'American'

--20. Triggers:
--- Design a trigger that updates a log table whenever a new order is inserted into the order_details table.

-- creating order_log table

create table order_log (
	log_id int primary key,
	operation int not null
	)

-- creating trigger

CREATE TRIGGER orderinserted
ON order_details
AFTER INSERT
AS 
BEGIN
    INSERT INTO order_log (log_id, operation)
    SELECT 
        i.order_details_id,
		i.item_id
    FROM inserted i
END

--testing
insert into order_details (order_details_id, order_id, item_id)
values (12236, 53700 , 122)

-- testing
select * from order_log

