-- SECTION (D): Country Analysis
USE UCI_BUSINESS_ANALYSIS;
-- D1. Country performance: revenue, orders, customers, AOV aur ranks
WITH c AS (
  SELECT Country,
         ROUND(SUM(Revenue), 2)  AS revenue,
         COUNT(DISTINCT Invoice) AS orders,
         COUNT(DISTINCT CASE WHEN Customer_ID <> 'Missing'
                             THEN Customer_ID END) AS customers
  FROM sales
  GROUP BY Country
)
SELECT Country,
       revenue,
       ROUND(revenue / SUM(revenue) OVER () * 100, 2) AS pct_of_revenue,
       orders,
       customers,
       ROUND(revenue / orders, 2)                     AS avg_order_value,
       RANK() OVER (ORDER BY revenue DESC)            AS revenue_rank,
       RANK() OVER (ORDER BY orders DESC)             AS order_rank,
       RANK() OVER (ORDER BY customers DESC)          AS customer_rank
FROM c
ORDER BY revenue DESC;
-- D2. Order rank revenue rank se behtar ho
WITH c AS (
  SELECT Country,
         ROUND(SUM(Revenue), 2)  AS revenue,
         COUNT(DISTINCT Invoice) AS orders
  FROM sales
  GROUP BY Country
),
r AS (
  SELECT *,
         RANK() OVER (ORDER BY orders  DESC) AS order_rank,
         RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
  FROM c
)
SELECT Country, orders, revenue, order_rank, revenue_rank,
       revenue_rank - order_rank AS rank_gap
FROM r
WHERE revenue_rank > order_rank
  AND orders >= 10
ORDER BY rank_gap DESC, orders DESC;



















