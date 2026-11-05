USE Pizza_Sales;

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/karan/Desktop/Data Analysts Projects/Pizza Sales Analytics/Dataset/pizza_sales.csv'
INTO TABLE pizza_sales
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
	pizza_id, order_id, pizza_name_id, quantity, @order_date, order_time, unit_price, total_price, pizza_size, pizza_category, 
    pizza_ingredients, pizza_name)
    set order_date = str_to_date(@order_date, '%d-%m-%Y');