# E-Commerce Sales Data Analysis (SQL)

**Objective:** Analyze mock e-commerce sales data using joins and window functions to identify top-performing products, monthly revenue trends, and geographical insights.

## Schema
- `customers` (customer_id, customer_name, city, state)
- `products` (product_id, product_name, category, unit_price)
- `orders` (order_id, customer_id, order_date)
- `order_items` (order_item_id, order_id, product_id, quantity)

## What's inside `ecommerce_sales_analysis.sql`
1. Table creation + mock data (10 customers, 10 products, 20 orders, 30 line items)
2. **Top products by revenue** — multi-table `JOIN` + `GROUP BY`
3. **Top 3 products per category** — `RANK() OVER (PARTITION BY ... ORDER BY ...)`
4. **Monthly revenue trend with running total** — `SUM(...) OVER (ORDER BY ...)`
5. **Month-over-month growth %** — `LAG() OVER (...)`
6. **Geographical breakdown** (state/city revenue) — 4-table join
7. **State revenue share of total** — `SUM(...) OVER ()` (no partition)

## How to run
Import into MySQL 8.0+ or MS SQL Server 2019+ and run top to bottom — it drops/recreates the tables, loads the mock data, then runs each analysis query in sequence.

## Skills demonstrated
SQL joins, GROUP BY aggregation, window functions (RANK, LAG, SUM OVER), CTEs, and multi-table relational design.
