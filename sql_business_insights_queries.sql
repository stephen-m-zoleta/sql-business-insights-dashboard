-- SQL Business Insights Dashboard Starter
-- Use this with PostgreSQL / pgAdmin

DROP TABLE IF EXISTS sales;

CREATE TABLE sales (
    order_id        VARCHAR(20) PRIMARY KEY,
    order_date      DATE NOT NULL,
    customer_id     VARCHAR(20) NOT NULL,
    region          VARCHAR(30) NOT NULL,
    city            VARCHAR(40) NOT NULL,
    category        VARCHAR(40) NOT NULL,
    sub_category    VARCHAR(40) NOT NULL,
    product_name    VARCHAR(80) NOT NULL,
    quantity        INTEGER NOT NULL,
    sales           NUMERIC(12,2) NOT NULL,
    profit          NUMERIC(12,2) NOT NULL
);

-- Option 1: Import the CSV using pgAdmin's Import/Export Data feature.
-- Option 2: Use COPY if your PostgreSQL service can access the file path.
-- Replace the path below with your actual local path.
-- COPY sales(order_id, order_date, customer_id, region, city, category, sub_category, product_name, quantity, sales, profit)
-- FROM 'C:/path/to/sales_data_sample.csv'
-- DELIMITER ','
-- CSV HEADER;

-- Basic checks
SELECT COUNT(*) AS total_rows FROM sales;
SELECT MIN(order_date) AS min_date, MAX(order_date) AS max_date FROM sales;

-- 1) KPI summary
SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(sales), 2) AS average_order_value
FROM sales;

-- 2) Monthly sales trend
SELECT
    DATE_TRUNC('month', order_date)::date AS month,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM sales
GROUP BY 1
ORDER BY 1;

-- 3) Sales by region
SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(*) AS total_orders
FROM sales
GROUP BY region
ORDER BY total_sales DESC;

-- 4) Sales by category
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_units
FROM sales
GROUP BY category
ORDER BY total_sales DESC;

-- 5) Profit by sub-category
SELECT
    sub_category,
    ROUND(SUM(profit), 2) AS total_profit
FROM sales
GROUP BY sub_category
ORDER BY total_profit DESC;

-- 6) Top 10 products by sales
SELECT
    product_name,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_units
FROM sales
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

-- 7) Highest-value cities
SELECT
    city,
    ROUND(SUM(sales), 2) AS total_sales
FROM sales
GROUP BY city
ORDER BY total_sales DESC
LIMIT 10;

-- 8) Monthly category trend
SELECT
    DATE_TRUNC('month', order_date)::date AS month,
    category,
    ROUND(SUM(sales), 2) AS total_sales
FROM sales
GROUP BY 1, 2
ORDER BY 1, total_sales DESC;

-- 9) Profit margin by category
SELECT
    category,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_pct
FROM sales
GROUP BY category
ORDER BY profit_margin_pct DESC;

-- 10) Reusable view for dashboard export
CREATE OR REPLACE VIEW v_monthly_sales AS
SELECT
    DATE_TRUNC('month', order_date)::date AS month,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM sales
GROUP BY 1
ORDER BY 1;

SELECT * FROM v_monthly_sales;
