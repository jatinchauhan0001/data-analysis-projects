-- =====================================================================
-- PROJECT: E-Commerce Sales Data Analysis (SQL)
-- Mock dataset analysis using JOINs and window functions to identify
-- top products, monthly revenue trends, and geographical insights.
-- Compatible with MySQL 8.0+ / MS SQL Server 2019+
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. SCHEMA
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city          VARCHAR(50),
    state         VARCHAR(50)
);


CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(100),
    category      VARCHAR(50),
    unit_price    DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT,
    order_date    DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id      INT,
    product_id    INT,
    quantity      INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ---------------------------------------------------------------------
-- 2. MOCK DATA
-- ---------------------------------------------------------------------
INSERT INTO customers (customer_id, customer_name, city, state) VALUES
(1,'Rahul Sharma','Faridabad','Haryana'),
(2,'Priya Verma','Delhi','Delhi'),
(3,'Aman Gupta','Gurugram','Haryana'),
(4,'Neha Singh','Mumbai','Maharashtra'),
(5,'Vikram Kumar','Pune','Maharashtra'),
(6,'Sanya Mehta','Bengaluru','Karnataka'),
(7,'Rohit Yadav','Jaipur','Rajasthan'),
(8,'Kavita Joshi','Chennai','Tamil Nadu'),
(9,'Arjun Kapoor','Lucknow','Uttar Pradesh'),
(10,'Meera Nair','Kochi','Kerala');

INSERT INTO products (product_id, product_name, category, unit_price) VALUES
(1,'Wireless Mouse','Electronics',699.00),
(2,'Bluetooth Speaker','Electronics',1899.00),
(3,'Running Shoes','Footwear',2499.00),
(4,'Yoga Mat','Fitness',899.00),
(5,'Coffee Maker','Home Appliances',3499.00),
(6,'Office Chair','Furniture',6999.00),
(7,'Backpack','Accessories',1299.00),
(8,'LED Desk Lamp','Home Appliances',999.00),
(9,'Smartwatch','Electronics',4999.00),
(10,'Water Bottle','Accessories',399.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(101,1,'2026-01-05'),(102,2,'2026-01-18'),(103,3,'2026-02-02'),
(104,4,'2026-02-14'),(105,1,'2026-02-27'),(106,5,'2026-03-03'),
(107,6,'2026-03-11'),(108,2,'2026-03-22'),(109,7,'2026-04-01'),
(110,8,'2026-04-09'),(111,3,'2026-04-19'),(112,9,'2026-05-02'),
(113,10,'2026-05-15'),(114,4,'2026-05-28'),(115,5,'2026-06-06'),
(116,6,'2026-06-17'),(117,7,'2026-07-01'),(118,8,'2026-07-12'),
(119,9,'2026-07-25'),(120,10,'2026-08-03');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES
(1,101,1,2),(2,101,7,1),(3,102,3,1),(4,102,9,1),
(5,103,2,3),(6,104,5,1),(7,104,10,4),(8,105,6,1),
(9,105,1,1),(10,106,4,2),(11,107,9,1),(12,107,8,2),
(13,108,3,2),(14,109,2,1),(15,109,10,2),(16,110,6,1),
(17,111,7,3),(18,112,5,1),(19,112,4,1),(20,113,1,5),
(21,114,9,1),(22,114,2,1),(23,115,8,3),(24,116,3,1),
(25,117,6,1),(26,117,10,6),(27,118,5,1),(28,119,9,2),
(29,120,7,1),(30,120,1,3);

-- ---------------------------------------------------------------------
-- 3. TOP PRODUCTS BY REVENUE (JOIN + aggregation)
-- ---------------------------------------------------------------------
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity)                       AS units_sold,
    SUM(oi.quantity * p.unit_price)        AS total_revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_name, p.category
ORDER BY total_revenue DESC;

-- ---------------------------------------------------------------------
-- 4. TOP 3 PRODUCTS BY REVENUE PER CATEGORY (window function: RANK)
-- ---------------------------------------------------------------------
SELECT *
FROM (
    SELECT
        p.category,
        p.product_name,
        SUM(oi.quantity * p.unit_price) AS total_revenue,
        RANK() OVER (
            PARTITION BY p.category
            ORDER BY SUM(oi.quantity * p.unit_price) DESC
        ) AS category_rank
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY p.category, p.product_name
) ranked
WHERE category_rank <= 3
ORDER BY category, category_rank;

-- ---------------------------------------------------------------------
-- 5. MONTHLY REVENUE TREND + RUNNING TOTAL (window function: SUM OVER)
-- ---------------------------------------------------------------------
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m')                         AS order_month,
    SUM(oi.quantity * p.unit_price)                            AS monthly_revenue,
    SUM(SUM(oi.quantity * p.unit_price)) OVER (
        ORDER BY DATE_FORMAT(o.order_date, '%Y-%m')
    )                                                           AS running_total_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_month;

-- ---------------------------------------------------------------------
-- 6. MONTH-OVER-MONTH GROWTH (window function: LAG)
-- ---------------------------------------------------------------------
WITH monthly AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        SUM(oi.quantity * p.unit_price)    AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p     ON p.product_id = oi.product_id
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    order_month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY order_month)        AS prev_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_month))
        / LAG(monthly_revenue) OVER (ORDER BY order_month) * 100, 1
    ) AS pct_change
FROM monthly
ORDER BY order_month;

-- ---------------------------------------------------------------------
-- 7. GEOGRAPHICAL INSIGHTS: REVENUE BY STATE / CITY (JOIN across 4 tables)
-- ---------------------------------------------------------------------
SELECT
    c.state,
    c.city,
    COUNT(DISTINCT o.order_id)             AS total_orders,
    SUM(oi.quantity * p.unit_price)        AS total_revenue
FROM customers c
JOIN orders o        ON o.customer_id = c.customer_id
JOIN order_items oi  ON oi.order_id = o.order_id
JOIN products p      ON p.product_id = oi.product_id
GROUP BY c.state, c.city
ORDER BY total_revenue DESC;

-- ---------------------------------------------------------------------
-- 8. STATE RANKED BY REVENUE SHARE (window function: SUM OVER, no partition)
-- ---------------------------------------------------------------------
SELECT
    state,
    state_revenue,
    ROUND(state_revenue / SUM(state_revenue) OVER () * 100, 1) AS pct_of_total_revenue
FROM (
    SELECT
        c.state,
        SUM(oi.quantity * p.unit_price) AS state_revenue
    FROM customers c
    JOIN orders o        ON o.customer_id = c.customer_id
    JOIN order_items oi  ON oi.order_id = o.order_id
    JOIN products p      ON p.product_id = oi.product_id
    GROUP BY c.state
) state_totals
ORDER BY state_revenue DESC;
