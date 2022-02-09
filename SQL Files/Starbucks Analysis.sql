USE Starbucks;

#What is the most expensive mobile order (by city)? 
SELECT s.city AS Store_City, max(o.order_total) AS Max_Order_Total
FROM customer_order o, store s 
WHERE s.store_id = o.store_id
GROUP BY s.city;

#What is the least expensive item on the menu?
SELECT item_description, item_type, item_price
FROM menu
WHERE item_price = (SELECT min(item_price) FROM menu);

#What is the average wait time of customers? 
SELECT order_type, COUNT(order_type) as order_type_count, 
AVG(TIMESTAMPDIFF(MINUTE, time_ordered, time_order_complete)) AS avg_time_in_mins
FROM customer_order
GROUP BY customer_order.order_type
ORDER BY avg_time_in_mins DESC;

#What is the peak time of the day for ordering?
SELECT COUNT(order_id) as Orders,
CONCAT(Hour(time_ordered)) as Hour_Ordered
FROM customer_order
GROUP BY Hour_Ordered
ORDER BY Orders desc;

#Which items were ordered the most from the menu?
SELECT menu.menu_id, menu.item_description AS Item_Name,
COUNT(customer_order_detail.order_line_id) AS Number_of_Customer_Orders
FROM Starbucks.menu
INNER JOIN Starbucks.customer_order_detail
ON menu.menu_id = customer_order_detail.menu_id
GROUP BY menu.menu_id
ORDER BY COUNT(customer_order_detail.order_line_id) DESC LIMIT 5;

#What payment types have been used and how much was the order total of each?
SELECT customer_order.payment_id, payment.payment_source, customer_order.order_total
FROM customer_order
LEFT JOIN payment ON customer_order.payment_id = payment.payment_id
ORDER BY customer_order.order_total desc;

#Which zipcode has the most number of online mobile orders?
SELECT zipcode , sum(order_count) AS total_online_mobile_order from (
SELECT customer_order.store_id, count(customer_order.store_id) AS order_count, zipcode
FROM customer_order 
INNER JOIN store ON store.store_id = customer_order.store_id 
WHERE customer_order.order_type = "Mobile" 
GROUP BY customer_order.store_id) as T1
GROUP BY zipcode order by total_online_mobile_order desc LIMIT 1;

#How many Starbucks are there in Santa Clara and San Jose ?
SELECT city, COUNT(store_id) AS store_count  
FROM store 
WHERE city in ('Santa Clara', 'San Jose') 
GROUP BY city;

#How many people have loyalty program?
SELECT l.loyalty_status AS Rewards_Status, COUNT(DISTINCT l.customer_id) AS Rewards_Members_Count
FROM customer c 
INNER JOIN loyalty_rewards_info l ON l.customer_id = c.customer_id
GROUP BY l.loyalty_status;

#How often do loyalty program customers order beverages?
SELECT loyalty_rewards_info.loyalty_status as loyalty_status, 
COUNT(DISTINCT customer_order.customer_id) AS loyalty_members_count,
COUNT(DISTINCT customer_order_detail.menu_id) AS distinct_beverages_ordered
FROM loyalty_rewards_info 
JOIN customer_order
ON customer_order.customer_id = loyalty_rewards_info.customer_id
JOIN customer_order_detail
ON customer_order.order_id = customer_order_detail.order_id
WHERE customer_order_detail.menu_id < 'm065'
GROUP BY loyalty_rewards_info.loyalty_status;

#What is the peak day of the week for ordering?
DELIMITER $$

CREATE PROCEDURE GetPeakDay()
BEGIN
	SELECT COUNT(order_id) AS Orders,
	ELT(DAYOFWEEK(date_ordered),
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat') as Day_of_Week
	FROM customer_order
	GROUP BY Day_of_Week;
END$$
DELIMITER ;
call Starbucks.GetPeakDay();

#Which preparation type is most popular for drinks?
SELECT
    customer_order_detail.preparation_type AS Preparation_type,
    COUNT(customer_order_detail.order_line_id) AS Count_prep_type
FROM
	Starbucks.customer_order_detail
INNER JOIN
	Starbucks.menu
ON 
	menu.menu_id = customer_order_detail.menu_id
WHERE menu.item_type = "drink"
GROUP BY customer_order_detail.preparation_type
HAVING COUNT(customer_order_detail.order_line_id)= (
	SELECT 
		MAX(mycount) 
		FROM ( 
			SELECT customer_order_detail.preparation_type, 
			COUNT(customer_order_detail.order_line_id) AS mycount 
			FROM 
				Starbucks.customer_order_detail
			INNER JOIN
				Starbucks.menu
			ON 
				menu.menu_id = customer_order_detail.menu_id 
			WHERE menu.item_type = "drink"
			GROUP BY customer_order_detail.preparation_type
			) AS results
	)
;

























