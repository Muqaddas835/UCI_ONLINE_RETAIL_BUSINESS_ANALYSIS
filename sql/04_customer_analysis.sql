-- SECTION (C): Customer Analysis
USE UCI_BUSINESS_ANALYSIS;
CREATE OR REPLACE VIEW customer_sales AS
SELECT * FROM sales
WHERE Customer_ID <> 'Missing';
-- C1. Average orders aur average spend per customer
WITH c AS (
  SELECT Customer_ID,
         COUNT(DISTINCT Invoice) AS orders,
         SUM(Revenue)            AS revenue
  FROM customer_sales
  GROUP BY Customer_ID
)
SELECT COUNT(*)                     AS total_customers,
       ROUND(AVG(orders), 2)        AS avg_orders_per_customer,
       ROUND(AVG(revenue), 2)       AS avg_spend_per_customer,
       ROUND(SUM(revenue), 2)       AS total_revenue
FROM c;
-- C2. Top 10 customers by revenue
SELECT Customer_ID,
       MAX(Country)                AS country,
       COUNT(DISTINCT Invoice)     AS total_orders,
       ROUND(SUM(Revenue), 2)      AS total_revenue,
       ROUND(SUM(Revenue) / (SELECT SUM(Revenue) FROM customer_sales) * 100, 2)
                                   AS pct_of_revenue
FROM customer_sales
GROUP BY Customer_ID
ORDER BY total_revenue DESC
LIMIT 10;
-- C3. Top 10 customers ka total % revenue
SELECT ROUND(SUM(t.total_revenue) / (SELECT SUM(Revenue) FROM customer_sales) * 100, 2)
         AS top10_pct_of_revenue
FROM (
  SELECT SUM(Revenue) AS total_revenue
  FROM customer_sales
  GROUP BY Customer_ID
  ORDER BY total_revenue DESC
  LIMIT 10
) t;
-- C4. Top 10 customers by orders
SELECT Customer_ID,
       MAX(Country)                AS country,
       COUNT(DISTINCT Invoice)     AS total_orders,
       ROUND(SUM(Revenue), 2)      AS total_revenue
FROM customer_sales
GROUP BY Customer_ID
ORDER BY total_orders DESC, total_revenue DESC
LIMIT 10;
-- C5. Average se zyada kharch karne wale customers
WITH c AS (
  SELECT Customer_ID, SUM(Revenue) AS total_revenue
  FROM customer_sales
  GROUP BY Customer_ID
),
a AS (SELECT AVG(total_revenue) AS avg_revenue FROM c)
SELECT COUNT(*)                                                   AS customers_above_avg,
       ROUND(COUNT(*) / (SELECT COUNT(*) FROM c) * 100, 2)        AS pct_of_customers,
       ROUND(SUM(c.total_revenue) / (SELECT SUM(total_revenue) FROM c) * 100, 2)
                                                                  AS pct_of_revenue
FROM c, a
WHERE c.total_revenue > a.avg_revenue;

-- C6. Top 20% customers (80/20 analysis)
WITH c AS (
  SELECT Customer_ID, SUM(Revenue) AS total_revenue
  FROM customer_sales
  GROUP BY Customer_ID
),
t AS (
  SELECT *, NTILE(5) OVER (ORDER BY total_revenue DESC) AS segment
  FROM c
)
SELECT segment,
       COUNT(*)                                   AS customers,
       ROUND(SUM(total_revenue), 2)               AS revenue,
       ROUND(SUM(total_revenue) / SUM(SUM(total_revenue)) OVER () * 100, 2)
                                                  AS pct_of_revenue
FROM t
GROUP BY segment
ORDER BY segment;






















