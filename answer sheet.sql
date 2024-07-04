use pizza;
-- Retrieve the total number of orders placed.;
SELECT 
    COUNT(order_id)
FROM
    pizza.orders;

-- Calculate the total revenue generated from pizza sales.;

select sum(order_details.quantity * pizzas.price) as revenue from
order_details inner join pizzas 
on 
order_details.pizza_id=pizzas.pizza_id;



-- Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price AS max_price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
 SELECT 
    pizzas.size, SUM(order_id) as count
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
order by count desc;



-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, sum(order_details.quantity) as qnt
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY qnt DESC
LIMIT 5;

-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category, sum(order_details.quantity) as qnt
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY qnt DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) hours, COUNT(order_id) AS count
FROM
    orders
GROUP BY hours;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, count(name) 
FROM
    pizza_types group by category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quan), 0) as average 
FROM
    (SELECT 
        orders.order_date AS day,
            SUM(order_details.quantity) AS quan
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY day) AS order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name, round(sum(pizzas.price * order_details.quantity),1)as revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
    group by pizza_types.name
    order by revenue desc limit 5;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.


SELECT 
    pizza_types.category AS category,
    SUM(pizzas.price * order_details.quantity) / (SELECT 
            SUM(order_details.quantity * pizzas.price) AS revenue
        FROM
            order_details
                INNER JOIN
            pizzas ON order_details.pizza_id = pizzas.pizza_id) *100 as percentage
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category;

-- Analyze the cumulative revenue generated over time.
 select order_date,sum(revenue) over (order by  order_date) as cummulative_revenue from
 (SELECT 
    orders.order_Date , sum(pizzas.price * order_details.quantity) as revenue
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
    group by order_date) as revenue_per_day;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category
select name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;