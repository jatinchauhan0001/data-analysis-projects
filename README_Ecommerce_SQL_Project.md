# E-Commerce Sales Data Analysis (SQL)

**Objective:** Analyze mock e-commerce sales data using joins and aggregation to identify top-performing products, monthly revenue trends, and geographical insights.

## Schema
- `customers` (customer_id, customer_name, city, state)
- `products` (product_id, product_name, category, unit_price)
- `orders` (order_id, customer_id, order_date)
- `order_items` (order_item_id, order_id, product_id, quantity)

## What's inside `ecommerce_sales_analysis.sql`
1. Table creation + mock data (10 customers, 10 products, 20 orders, 30 line items)
2. **Top products by revenue** — multi-table `JOIN` + `GROUP BY`
3. **Monthly revenue trend with running total** — `SUM(...) OVER (ORDER BY ...)`
4. **Geographical breakdown** (state/city revenue) — 4-table join
5. **State revenue share of total** — `SUM(...) OVER ()` (no partition)

## How to run
Import into MySQL 8.0+ or MS SQL Server 2019+ and run top to bottom — it drops/recreates the tables, loads the mock data, then runs each analysis query in sequence.

## Skills demonstrated
SQL joins, GROUP BY aggregation, the SUM() OVER() window function for running totals, and multi-table relational design.
