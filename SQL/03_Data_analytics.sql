use Pizza_Sales;

select * from pizza_sales;

select sum(total_price) as Total Revenue
from pizza_sales;

select (SUM(total_price) / COUNT(distinct order_id)) as Avg_order_Value 
from pizza_sales;

select sum(quantity) as Total_Pizzas_sold
from pizza_sales;

select count(distinct order_id) as Total_Orders
from pizza_sales;

select cast(cast(sum(quantity) as Decimal(10,2))/cast(count(distinct order_id) as decimal(10,2)) as decimal(10,2)) as Average_Pizzas_Per_Order
from pizza_sales;

select dayname(order_date) as order_day, count(distinct order_id) as total_orders
from pizza_sales
group by order_day;

select hour(order_time) as order_hour, count(distinct order_id) as total_orders
from pizza_sales
group by order_hour;

select pizza_category, cast(sum(total_price) as decimal(10,2)) as total_revenue,
cast(sum(total_price) * 100 / (select sum(total_price) from pizza_sales) as decimal(10,2)) as Percentage
from pizza_sales
group by pizza_category;

select pizza_size, cast(sum(total_price) as decimal(10,2)) as total_revenue,
cast(sum(total_price) * 100 / (select sum(total_price) from pizza_sales) as decimal(10,2)) as Percentage
from pizza_sales
group by pizza_size
order by pizza_size;

select pizza_category, SUM(quantity) as Total_Quantity_Sold
from pizza_sales
group by pizza_category
order by Total_Quantity_sold desc;

select pizza_name, sum(quantity) as Total_Pizza_sold
from pizza_sales
group by pizza_name
order by Total_Pizza_Sold desc
limit 5;

select pizza_name, sum(quantity) as Total_Pizza_sold
from pizza_sales
group by pizza_name
order by Total_Pizza_Sold asc
limit 5;

-- Additional Note
-- can use where clause to find the monthly sales of pizzas, revenue etc. Example for the same is below.
select pizza_name, sum(quantity) as Total_Pizza_sold
from pizza_sales
where month(order_date) = 2
group by pizza_name
order by Total_Pizza_Sold desc
limit 5;

-- Self Join to Find pairs of Pizzas
create table pizza_combinations as

with unique_pizzas as (
select distinct order_id, pizza_name
from pizza_sales),

order_counts as (
select count(distinct order_id) as total_orders
from unique_pizzas
),

pizza_counts as (
select pizza_name, count(*) as pizza_orders
from unique_pizzas
group by pizza_name
),

pizza_pairs as (select p1.order_id,
	   p1.pizza_name as pizza_1,
	   p2.pizza_name as pizza_2
from unique_pizzas p1
join unique_pizzas p2
on p1.order_id = p2.order_id and p1.pizza_name < p2.pizza_name),

pair_counts as (
select pizza_1, pizza_2, count(*) as pair_orders
from pizza_pairs
group by pizza_1, pizza_2)

select
	pc.pizza_1,
	pc.pizza_2,
    pc.pair_orders,
    round(pc.pair_orders/oc.total_orders, 4) as support,
    round((pc.pair_orders/oc.total_orders)/
            (
            (p1.pizza_orders / oc.total_orders) *
            (p2.pizza_orders / oc.total_orders)
          ),
          4) as lift
	from pair_counts pc
    cross join order_counts oc
	join pizza_counts p1
		on pc.pizza_1 = p1.pizza_name
	join pizza_counts p2
		on pc.pizza_2 = p2.pizza_name
	where pc.pair_orders >= 50
	order by lift desc;