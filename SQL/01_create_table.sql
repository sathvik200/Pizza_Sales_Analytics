create database Pizza_Sales;

use Pizza_Sales;

create table pizza_sales(
	pizza_id int primary key,
    order_id int,
    pizza_name_id varchar(30),
    quantity tinyint,
    order_date date,
    order_time time,
    unit_price float,
    total_price float,
    pizza_size varchar(10),
    pizza_category varchar(50),
    pizza_ingredients varchar(150),
    pizza_name varchar(50)
);