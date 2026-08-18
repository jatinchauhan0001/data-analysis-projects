-- PROJECT: E-Commerce Sales Analysis (SQL) 
-- ---------------------------------------------------------------------
-- STEP 1: Create two tables
-- "products" = list of items we sell
-- "sales"    = each row is one sale (which product, how many, when)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(100),
    category      VARCHAR(50),
    unit_price    DECIMAL(10,2)
);

CREATE TABLE sales (
    sale_id       INT PRIMARY KEY,
    product_id    INT,
    quantity      INT,
    sale_date     DATE,
    city          VARCHAR(50),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ---------------------------------------------------------------------
-- STEP 2: Insert some data
-- ---------------------------------------------------------------------
INSERT INTO products (product_id, product_name, category, unit_price) VALUES
(1, 'Wireless Mouse',    'Electronics', 699.00),
(2, 'Bluetooth Speaker', 'Electronics', 1899.00),
(3, 'Running Shoes',     'Footwear',    2499.00),
(4, 'Yoga Mat',          'Fitness',     899.00),
(5, 'Coffee Maker',      'Appliances',  3499.00),
(6, 'Backpack',          'Accessories', 1299.00);

INSERT INTO sales (sale_id, product_id, quantity, sale_date, city) VALUES
(1, 1, 3, '2026-01-05', 'Delhi'),
(2, 2, 2, '2026-01-12', 'Mumbai'),
(3, 3, 1, '2026-01-20', 'Delhi'),
(4, 1, 5, '2026-02-02', 'Bengaluru'),
(5, 4, 4, '2026-02-15', 'Mumbai'),
(6, 5, 1, '2026-02-25', 'Delhi'),
(7, 6, 2, '2026-03-03', 'Bengaluru'),
(8, 2, 1, '2026-03-14', 'Delhi'),
(9, 3, 2, '2026-03-22', 'Mumbai'),
(10, 1, 4, '2026-04-01', 'Delhi'),
(11, 5, 2, '2026-04-10', 'Bengaluru'),
(12, 6, 1, '2026-04-18', 'Mumbai');


-- ---------------------------------------------------------------------
-- QUERY 1: See all sales with the product name attached
-- (This is a JOIN - combining two tables using product_id)
-- ---------------------------------------------------------------------
SELECT
    s.sale_id,
    p.product_name,
    s.quantity,
    s.sale_date,
    s.city
FROM sales s
JOIN products p ON s.product_id = p.product_id
ORDER BY s.sale_date;


-- ---------------------------------------------------------------------
-- QUERY 2: Total quantity and revenue sold per product
-- (JOIN + GROUP BY + SUM - the most common pattern in SQL analysis)
-- ---------------------------------------------------------------------
SELECT
    p.product_name,
    SUM(s.quantity)                  AS total_units_sold,
    SUM(s.quantity * p.unit_price)   AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;


-- ---------------------------------------------------------------------
-- QUERY 3: Which category made the most money?
-- (Same pattern as Query 2, just grouped by category instead of product)
-- ---------------------------------------------------------------------
SELECT
    p.category,
    SUM(s.quantity * p.unit_price) AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- ---------------------------------------------------------------------
-- QUERY 4: Revenue by city (geographical insight)
-- ---------------------------------------------------------------------
SELECT
    s.city,
    COUNT(s.sale_id)                 AS number_of_sales,
    SUM(s.quantity * p.unit_price)   AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY s.city
ORDER BY total_revenue DESC;


-- ---------------------------------------------------------------------
-- QUERY 5: Revenue by month (simple trend over time)
-- ---------------------------------------------------------------------
SELECT
    DATE_FORMAT(s.sale_date, '%Y-%m') AS sale_month,
    SUM(s.quantity * p.unit_price)    AS monthly_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY DATE_FORMAT(s.sale_date, '%Y-%m')
ORDER BY sale_month;


-- ---------------------------------------------------------------------
-- QUERY 6: Only show products that sold for more than 5000 total
-- (This introduces HAVING - like WHERE, but used after GROUP BY)
-- ---------------------------------------------------------------------
SELECT
    p.product_name,
    SUM(s.quantity * p.unit_price) AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
HAVING SUM(s.quantity * p.unit_price) > 5000
ORDER BY total_revenue DESC;
