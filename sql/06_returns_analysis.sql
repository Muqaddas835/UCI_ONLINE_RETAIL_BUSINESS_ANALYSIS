-- SECTION (E): Returns
USE UCI_BUSINESS_ANALYSIS;

CREATE OR REPLACE VIEW return_records AS
SELECT *, ABS(Quantity) AS ReturnQty, ABS(Quantity) * Price AS ReturnValue
FROM online_retail
WHERE Category = 'Returns';

CREATE OR REPLACE VIEW product_returns AS
SELECT * FROM return_records
WHERE StockCode NOT IN ('M','DOT','POST','AMAZONFEE','ADJUST','ADJUST2',
                        'C2','D','BANK CHARGES','S','TEST001','TEST002','PADS')
  AND StockCode NOT LIKE 'gift%';
  
-- E1. Returns overview
SELECT (SELECT COUNT(*) FROM return_records)                     AS return_records,
       (SELECT COUNT(DISTINCT Invoice) FROM return_records)      AS credit_notes,
       (SELECT ROUND(SUM(ReturnValue), 2) FROM return_records)   AS total_credit_value,
       (SELECT ROUND(SUM(ReturnValue), 2) FROM product_returns)  AS goods_returned_value,
       (SELECT ROUND(SUM(ReturnValue), 2) FROM return_records)
     - (SELECT ROUND(SUM(ReturnValue), 2) FROM product_returns)  AS non_goods_credit_value;  
  -- E2. Returns ka asar (gross vs net)
  SELECT ROUND((SELECT SUM(Revenue) FROM sales), 2)         AS gross_revenue,
       ROUND((SELECT SUM(ReturnValue) FROM return_records), 2) AS total_credits,
       ROUND((SELECT SUM(Revenue) FROM sales)
           - (SELECT SUM(ReturnValue) FROM return_records), 2) AS net_revenue,
       ROUND((SELECT SUM(ReturnValue) FROM return_records)
           / (SELECT SUM(Revenue) FROM sales) * 100, 2)        AS credit_pct_of_gross,
       ROUND((SELECT SUM(ReturnValue) FROM product_returns)
           / (SELECT SUM(Revenue) FROM sales) * 100, 2)        AS goods_return_pct_of_gross;
  -- E3. Products ki returns sabse zyada
  -- Value ke hisaab se top 10
SELECT StockCode, MAX(Description) AS description,
       COUNT(*)                    AS return_records,
       SUM(ReturnQty)              AS returned_qty,
       ROUND(SUM(ReturnValue), 2)  AS returned_value
FROM product_returns
GROUP BY StockCode
ORDER BY returned_value DESC
LIMIT 10;

-- Quantity ke hisaab se top 10
SELECT StockCode, MAX(Description) AS description,
       SUM(ReturnQty)              AS returned_qty,
       ROUND(SUM(ReturnValue), 2)  AS returned_value
FROM product_returns
GROUP BY StockCode
ORDER BY returned_qty DESC
LIMIT 10;
-- E4. Countries mein return activity
WITH r AS (
  SELECT Country, COUNT(*) AS return_records,
         COUNT(DISTINCT Invoice) AS credit_notes,
         SUM(ReturnValue) AS return_value
  FROM product_returns
  GROUP BY Country
),
s AS (
  SELECT Country, SUM(Revenue) AS sales
  FROM product_sales
  GROUP BY Country
)
SELECT r.Country, r.return_records, r.credit_notes,
       ROUND(r.return_value, 2) AS return_value,
       ROUND(s.sales, 2)        AS sales,
       ROUND(r.return_value / s.sales * 100, 2) AS return_rate_pct
FROM r JOIN s USING (Country)
ORDER BY return_value DESC;
-- E5. Ghair-mamooli returns wale products
WITH r AS (
  SELECT StockCode, MAX(Description) AS description,
         SUM(ReturnQty) AS returned_qty,
         ROUND(SUM(ReturnValue), 2) AS returned_value,
         COUNT(*) AS return_records
  FROM product_returns
  GROUP BY StockCode
),
s AS (
  SELECT StockCode, SUM(Quantity) AS sold_qty
  FROM product_sales
  GROUP BY StockCode
),
avg_rate AS (
  SELECT SUM(r.returned_qty) / SUM(s.sold_qty) * 100 AS avg_rate
  FROM r JOIN s USING (StockCode)
)
SELECT r.StockCode, r.description, s.sold_qty, r.returned_qty,
       ROUND(r.returned_qty / s.sold_qty * 100, 2) AS return_rate_pct,
       r.returned_value, r.return_records
FROM r JOIN s USING (StockCode), avg_rate a
WHERE s.sold_qty >= 100
  AND r.returned_qty >= 10
  AND r.returned_qty / s.sold_qty * 100 > 3 * a.avg_rate
ORDER BY return_rate_pct DESC
LIMIT 10;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  