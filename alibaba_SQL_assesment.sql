-- MY_PlacementDost_Intern_Projects

use alibaba 
go
select * from alibaba_data;

--1. Define a SQL table to store the given dataset
-- Completed through SQL Server GUI

--2. Load the provided dataset into the SQL table.
-- Completed through SQL Server GUI

--3. Retrieve all columns from the table for the first 10 rows.
select Top 10 * from alibaba_data; 

--4. Display the products where the shipping city is 'New York'.
select Item_NM as Products from dbo.alibaba_data 
where Shipping_city = 'New York';

--5. Retrieve the top 5 products with the highest item price
Select distinct top 5 Item_NM as products, Item_Price from dbo.alibaba_data
order by Item_Price desc ;

--6. Calculate the average quantity sold.
select AVG(Quantity) as avg_quantity_sold from dbo.alibaba_data;

--7. Group the data by category and display the total quantity sold for each category.
select category, COUNT(Quantity) As Total_Quant_Sold from dbo.alibaba_data group by Category

--8. Create a new table for payment methods and join it with the main table to display product names and
--their payment methods.
select S_no, Item_NM as products, Payment_Method Into payment_methods 
from alibaba_data

Select * from payment_methods

--9. Find products where the cost price is greater than the average cost price.
select Item_NM as Products from alibaba_data where Cost_Price > (Select AVG(Cost_Price) from alibaba_data)

-- 10. Calculate the total special price for products in the 'Electronics' category.
select SUM(Special_price) from alibaba_data where Category = 'Electronics'

-- 11. Increase the cost price by 10% for products in the 'Clothing' category.
UPDATE alibaba_data 
SET cost_price = cost_price * 1.1
where Category = 'Clothing';

-- 12. Add a new record for a product with necessary details
Insert into alibaba_data values
('Adarsh', 'Indore', 'Shoes', 'Men Footwear', 'MEN', 'MENS FOOTWEAR', 'NULL', 'CASUAL', 'CLARKS', 
' LOAFERS', 'Brown Loafers', 'BLACK', 8, 'On Sale', 'COD', 150, 9, 1, 2340, 1897, 2334, 2300, 2350, 2250, 
2300);

--13. Remove all products where the sale flag is 0.
Delete  from alibaba_data where Sale_Flag = 'Not on Sale';

-- 14. Create a new column 'Discount_Type' that categorizes products based on their item price: 'High' if
-- above $200, 'Medium' if between $100 and $200, 'Low' if below $100.
alter table alibaba_data 
add Discount_Type varchar(20);

update alibaba_data set Discount_Type = (
Case  
when Item_Price > 5000 then 'High'
When Item_Price < 5000 And Item_Price > 3500 then 'Medium'
When Item_Price < 200 then 'Low'
end )

-- 15. Rank the products based on their special prices within each category.
Select Item_NM, RANK() over(partition by Item_NM order by Special_price Desc) as rank
from alibaba_data

--16. Calculate the running total of the quantity sold for each product.
select Distinct(Item_NM), SUM(Quantity) over(partition by Item_NM) as Running_Total from alibaba_data

--17. Create a CTE that lists products in the 'Fashion' sub-category with their corresponding brand and color.
With my_first_CTE(Products, brands, color) 
AS(
	Select Item_NM, Brand, Color 
		from alibaba_data
		where Sub_category = 'Ethnic'
		)

Select * from my_first_CTE

--18. Pivot the data to show the total quantity sold for each category and sub-category.
Select 'Quantity' as Category, 
[Women Apparel], [Men Footwear], [Bags], [Sports Equipment], [SUNGLASSES], [WATCHES], [Women Footwear], 
[Furniture]
from (
select Category, Quantity 
from alibaba_data
) as source_table
Pivot (
sum(Quantity) for Category in ([Women Apparel], [Men Footwear], [Bags], [Sports Equipment], [SUNGLASSES], 
[WATCHES], [Women Footwear], [Furniture]))
as pivot_table 

Select 'Quantity' as Sub_category, 
[Sports Apparel], [Ethnic], [Bags], [Womens Footwear], [LIVING], [Mens Footwear], [SUNGLASSES], [WATCHES]
from (
select Sub_category, Quantity 
from alibaba_data
) as source_table
Pivot (
count(Quantity) for Sub_category in ([Sports Apparel], [Ethnic], [Bags], [Womens Footwear], [LIVING], 
[Mens Footwear], [SUNGLASSES], [WATCHES]))
as pivot_table 

-- 19. Unpivot the table to transform the 'Value_CM1' and 'Value_CM2' columns into a single column named 'CM_Value'.

Select CM_Value, CM_column
from (
select Value_CM1, Value_CM2
from alibaba_data)
as source_table

unpivot ( 
CM_Value for CM_column  in (Value_CM1, Value_CM2)
) as unpivot_table

--20. Create a stored procedure that accepts a category name as input and returns the total quantity sold for that category.

Create procedure Category_sold
as 
Begin 
	Select * from alibaba_data 
ENd

Alter procedure Category_sold(@category as nVarchar(50))
As
Begin 
	Select Category, sum(Quantity) as Quantity_Sold from alibaba_data 
		where Category = @category 
		group by Category

End

Execute Category_sold WATCHES

