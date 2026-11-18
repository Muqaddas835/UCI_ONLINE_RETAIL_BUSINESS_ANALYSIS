-- SECTION (A): SALES PERFORMANCE (BUSINESS KPIs)
USE UCI_BUSINESS_ANALYSIS;
CREATE OR REPLACE VIEW sales AS
SELECT *, Quantity * Price AS Revenue
FROM online_retail
WHERE Category = 'Sales';

-- A1. What is the overall size of the business?
SELECT ROUND(SUM(Revenue), 2)                                        AS total_revenue,
       SUM(Quantity)                                                 AS total_units_sold,
       COUNT(DISTINCT Invoice)                                       AS total_orders,
       COUNT(DISTINCT CASE WHEN Customer_ID <> 'Missing'
                           THEN Customer_ID END)                     AS total_customers,
       COUNT(DISTINCT StockCode)                                     AS total_products,
       COUNT(DISTINCT Country)                                       AS total_countries,
       ROUND(SUM(Revenue) / COUNT(DISTINCT Invoice), 2)              AS avg_order_value,
       MIN(InvoiceDate)                                              AS first_order,
       MAX(InvoiceDate)                                              AS last_order,
       DATEDIFF(MAX(InvoiceDate), MIN(InvoiceDate)) + 1              AS days_covered
FROM sales;

-- A2. Monthly performance: revenue, orders, MoM growth aur ranking
WITH monthly AS (
  SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS month,
         SUM(Revenue)                      AS revenue,
         COUNT(DISTINCT Invoice)           AS orders
  FROM sales
  GROUP BY month
)
SELECT month,
       ROUND(revenue, 2)                                           AS revenue,
       orders,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month) * 100, 2)        AS mom_change_pct,
       RANK() OVER (ORDER BY revenue DESC)                         AS revenue_rank,
       RANK() OVER (ORDER BY orders  DESC)                         AS order_rank
FROM monthly
ORDER BY month;
-- A3. Which days of the week generate the most sales?
SELECT DAYNAME(InvoiceDate) AS day_name,
       ROUND(SUM(Revenue), 2) AS revenue,
       COUNT(DISTINCT Invoice) AS orders
FROM sales
GROUP BY day_name, DAYOFWEEK(InvoiceDate)
ORDER BY revenue DESC;








