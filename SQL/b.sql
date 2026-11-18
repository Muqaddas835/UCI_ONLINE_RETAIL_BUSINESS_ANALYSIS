-- SECTION (B): Product Performance
USE UCI_BUSINESS_ANALYSIS;
CREATE OR REPLACE VIEW product_sales AS
SELECT *
FROM sales
WHERE StockCode NOT IN ('M','DOT','POST','AMAZONFEE','ADJUST','ADJUST2',
                        'C2','D','BANK CHARGES','S','TEST001','TEST002','PADS')
  AND StockCode NOT LIKE 'gift%';

-- Top 10 by revenue
SELECT StockCode, MAX(Description) AS description,
       ROUND(SUM(Revenue), 2) AS revenue, SUM(Quantity) AS quantity
FROM product_sales
GROUP BY StockCode
ORDER BY revenue DESC
LIMIT 10;

-- Top 10 by quantity
SELECT StockCode, MAX(Description) AS description,
       ROUND(SUM(Revenue), 2) AS revenue, SUM(Quantity) AS quantity
FROM product_sales
GROUP BY StockCode
ORDER BY quantity DESC
LIMIT 10;

-- B2. Revenue distribution aur cumulative %
WITH p AS (
  SELECT StockCode, MAX(Description) AS description, SUM(Revenue) AS revenue
  FROM product_sales
  GROUP BY StockCode
)
SELECT StockCode, description,
       ROUND(revenue, 2) AS revenue,
       ROUND(revenue / SUM(revenue) OVER () * 100, 2) AS pct_of_total,
       ROUND(SUM(revenue) OVER (ORDER BY revenue DESC
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
             / SUM(revenue) OVER () * 100, 2) AS cumulative_pct
FROM p
ORDER BY revenue DESC;
-- B3. Sabse kam revenue wale products
SELECT StockCode, MAX(Description) AS description,
       ROUND(SUM(Revenue), 2) AS revenue, SUM(Quantity) AS quantity
FROM product_sales
GROUP BY StockCode
ORDER BY revenue ASC
LIMIT 10;
-- B4. High revenue, low volume

WITH p AS (
  SELECT StockCode, MAX(Description) AS description,
         SUM(Revenue) AS revenue, SUM(Quantity) AS quantity
  FROM product_sales
  GROUP BY StockCode
),
t AS (
  SELECT *, NTILE(4) OVER (ORDER BY revenue)  AS rev_quartile,
            NTILE(4) OVER (ORDER BY quantity) AS qty_quartile
  FROM p
)
SELECT StockCode, description, ROUND(revenue, 2) AS revenue, quantity
FROM t
WHERE rev_quartile = 4 AND qty_quartile = 1
ORDER BY revenue DESC;
-- B5. Har country mein product ranking
WITH c AS (
  SELECT Country, StockCode, MAX(Description) AS description,
         SUM(Revenue) AS revenue
  FROM product_sales
  GROUP BY Country, StockCode
),
r AS (
  SELECT *, RANK() OVER (PARTITION BY Country ORDER BY revenue DESC) AS rnk
  FROM c
)
SELECT Country, rnk, StockCode, description, ROUND(revenue, 2) AS revenue
FROM r
WHERE rnk <= 3
ORDER BY Country, rnk;





