-- SECTION (F): Advanced Customer Analysis (Retention)
-- F1. Repeat vs one-time customers
WITH c AS (
  SELECT Customer_ID,
         COUNT(DISTINCT Invoice) AS orders,
         SUM(Revenue)            AS revenue
  FROM customer_sales
  GROUP BY Customer_ID
)
SELECT CASE WHEN orders = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
       COUNT(*)                                                    AS customers,
       ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2)            AS pct_of_customers,
       ROUND(SUM(revenue), 2)                                      AS revenue,
       ROUND(SUM(revenue) / SUM(SUM(revenue)) OVER () * 100, 2)    AS pct_of_revenue,
       ROUND(AVG(revenue), 2)                                      AS avg_spend,
       ROUND(AVG(orders), 2)                                       AS avg_orders
FROM c
GROUP BY customer_type;

WITH c AS (
  SELECT Customer_ID,
         MIN(InvoiceDate)        AS first_purchase,
         COUNT(DISTINCT Invoice) AS orders
  FROM customer_sales
  GROUP BY Customer_ID
)
SELECT COUNT(*)                                  AS customers_acquired_before_oct,
       SUM(orders = 1)                           AS one_time_customers,
       ROUND(SUM(orders = 1) / COUNT(*) * 100, 2) AS one_time_pct
FROM c
WHERE first_purchase < '2010-10-01';

SELECT Customer_ID,
       MAX(Country)           AS country,
       MIN(InvoiceDate)       AS purchase_date,
       ROUND(SUM(Revenue), 2) AS revenue
FROM customer_sales
GROUP BY Customer_ID
HAVING COUNT(DISTINCT Invoice) = 1
ORDER BY revenue DESC;
-- F2. Above-average revenue aur frequent orders
WITH c AS (
  SELECT Customer_ID,
         COUNT(DISTINCT Invoice) AS orders,
         SUM(Revenue)            AS revenue
  FROM customer_sales
  GROUP BY Customer_ID
),
a AS (
  SELECT AVG(revenue) AS avg_revenue, AVG(orders) AS avg_orders FROM c
)
SELECT COUNT(*)                                                      AS customers,
       ROUND(COUNT(*) / (SELECT COUNT(*) FROM c) * 100, 2)           AS pct_of_customers,
       ROUND(SUM(c.revenue) / (SELECT SUM(revenue) FROM c) * 100, 2) AS pct_of_revenue
FROM c, a
WHERE c.revenue > a.avg_revenue
  AND c.orders  > a.avg_orders;
  -- F3. Customer behaviour time ke saath
  WITH first_p AS (
  SELECT Customer_ID, DATE_FORMAT(MIN(InvoiceDate), '%Y-%m') AS first_month
  FROM customer_sales
  GROUP BY Customer_ID
),
m AS (
  SELECT DATE_FORMAT(s.InvoiceDate, '%Y-%m') AS month,
         s.Customer_ID, s.Invoice, s.Revenue, f.first_month
  FROM customer_sales s
  JOIN first_p f USING (Customer_ID)
)
SELECT month,
       COUNT(DISTINCT Customer_ID)                                            AS active_customers,
       COUNT(DISTINCT CASE WHEN month = first_month THEN Customer_ID END)     AS new_customers,
       COUNT(DISTINCT CASE WHEN month > first_month THEN Customer_ID END)     AS returning_customers,
       COUNT(DISTINCT Invoice)                                                AS orders,
       ROUND(COUNT(DISTINCT Invoice) / COUNT(DISTINCT Customer_ID), 2)        AS orders_per_customer,
       ROUND(SUM(Revenue) / COUNT(DISTINCT Customer_ID), 2)                   AS avg_spend_per_customer
FROM m
GROUP BY month
ORDER BY month;











