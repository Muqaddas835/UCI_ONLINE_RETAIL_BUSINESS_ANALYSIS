# 🛒 Online Retail Business Analysis (SQL + Python)

**End-to-end business analysis of a UK-based online gift-ware retailer: from raw Excel data to cleaned dataset, MySQL database and 30+ business questions answered with SQL.**

![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql&logoColor=white)
![Python](https://img.shields.io/badge/Python-Pandas-3776AB?logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-CTEs%20%7C%20Window%20Functions-orange)
![Status](https://img.shields.io/badge/Status-Analysis%20Complete-brightgreen)

> 📄 **Full business report with problems, evidence and recommendations:** [Business_Insights_Report.md](Business_Insights_Report.md)

---

## 📌 Table of Contents
1. [Project Overview](#-project-overview)
2. [Business Problem](#-business-problem)
3. [Dataset](#-dataset)
4. [Tools & Skills](#-tools--skills)
5. [Workflow](#-workflow)
6. [Data Cleaning](#-data-cleaning-python)
7. [Database Setup](#-database-setup-mysql)
8. [Business Questions Answered](#-business-questions-answered)
9. [Key Findings](#-key-findings)
10. [Recommendations](#-recommendations-summary)
11. [Repository Structure](#-repository-structure)
12. [How to Run](#-how-to-run)
13. [Limitations](#-limitations)
14. [Next Steps](#-next-steps)
15. [About Me](#-about-me)

---

## 📖 Project Overview

This project analyses **one year of transactions (1 Dec 2009 – 9 Dec 2010)** of an online retailer that sells gift-ware and home-décor products, mostly to wholesale customers.

The goal is to turn raw transaction data into answers a business owner actually cares about:

- How big is the business and how is it growing?
- Which products, customers and countries bring the money?
- When do customers buy, and do they come back?
- How much revenue is lost to returns and credit notes?

The analysis is organised in **six sections (A–F)**, each answering a group of business questions in SQL.

## 🎯 Business Problem

The management wants to understand sales performance and find where revenue is **concentrated, at risk, or being lost**, so that it can:

- Protect its most valuable customers and products
- Plan stock and marketing around seasonality
- Reduce losses from returns and credit notes
- Reduce dependence on a single market (the UK)
- Improve customer retention

## 📂 Dataset

| Item | Detail |
|---|---|
| Source | [UCI Machine Learning Repository: Online Retail II](https://archive.ics.uci.edu/dataset/502/online+retail+ii) |
| Period used | 01 Dec 2009 – 09 Dec 2010 |
| Raw size | 525,461 rows × 8 columns |
| Cleaned size | 515,667 rows × 9 columns (added `Category`) |
| Countries | 40 |

**Columns:** `Invoice`, `StockCode`, `Description`, `Quantity`, `InvoiceDate`, `Price`, `Customer ID`, `Country` (+ `Category` created during cleaning).

## 🛠 Tools & Skills

- **Python** (Pandas, Matplotlib, Seaborn): data cleaning and categorisation
- **MySQL 8 / MySQL Workbench**: database design, bulk loading, analysis
- **SQL concepts used:** Views, CTEs, window functions (`RANK`, `LAG`, `NTILE`, `SUM() OVER`), conditional aggregation, joins, subqueries, date functions
- **Business skills:** KPI design, Pareto (80/20) analysis, customer retention, return analysis, insight storytelling

## 🔄 Workflow

```
Raw Excel  →  Python cleaning  →  Cleaned CSV  →  MySQL (LOAD DATA)  →  SQL Analysis (A–F)  →  Insights & Recommendations
```

## 🧹 Data Cleaning (Python)

Notebook: [`notebooks/online_retail_cleaning.ipynb`](notebooks/online_retail_cleaning.ipynb)

| Step | Action | Result |
|---|---|---|
| 1 | Loaded raw Excel file | 525,461 rows |
| 2 | Checked missing values | `Customer ID` missing in 20.5%, `Description` in 0.56% |
| 3 | Removed exact duplicate rows | 6,865 rows removed |
| 4 | Dropped rows with missing `Description` | 2,928 rows removed |
| 5 | Replaced missing `Customer ID` with `"Missing"` (kept the sales, since they still count as revenue) | – |
| 6 | Verified no zero-quantity rows | 0 found |
| 7 | **Categorised every record** into `Sales`, `Returns`, `Adjustments` | see below |
| 8 | Checked categories do not overlap | 0 overlaps |
| 9 | Exported cleaned file | 515,667 rows |

**Categorisation logic**

| Category | Rule | Rows |
|---|---|---|
| **Sales** | Quantity > 0, Price > 0, invoice not starting with `C` | 504,730 |
| **Returns** | Quantity < 0 and invoice starts with `C` (credit note) | 10,181 |
| **Adjustments** | Price ≤ 0, or negative quantity without a credit note | 756 |

> Separating returns and adjustments from sales keeps revenue figures honest. Without this step, revenue would be mixed with refunds, bad-debt entries and stock corrections.

## 🗄 Database Setup (MySQL)

File: [`sql/01_setup_database.sql`](sql/01_setup_database.sql)

- Database: `UCI_BUSINESS_ANALYSIS`
- Table: `online_retail` (with an auto-increment `Transaction_ID` primary key)
- The cleaned CSV is bulk-loaded with `LOAD DATA LOCAL INFILE` (the Workbench import wizard was too slow and stalled on 500k+ rows)
- Reusable **views** keep the analysis clean:

| View | Purpose |
|---|---|
| `sales` | Sales records only, with `Revenue = Quantity × Price` |
| `product_sales` | Sales excluding non-product codes (postage, manual entries, fees, test codes) |
| `customer_sales` | Sales from identified customers only |
| `return_records` / `product_returns` | Credit notes, with `ReturnQty` and `ReturnValue` |

## ❓ Business Questions Answered

| Section | File | Questions |
|---|---|---|
| **A. Sales Performance** | `02_sales_performance.sql` | A1 Overall business size (revenue, orders, customers, AOV) · A2 Monthly revenue, MoM growth and ranking · A3 Best days of the week |
| **B. Product Performance** | `03_product_performance.sql` | B1 Top 10 products by revenue and by quantity · B2 Revenue distribution and cumulative % · B3 Lowest-revenue products · B4 High-revenue / low-volume products · B5 Top 3 products in every country |
| **C. Customer Analysis** | `04_customer_analysis.sql` | C1 Average orders and spend per customer · C2 Top 10 customers · C3 Share of revenue from top 10 · C4 Most frequent customers · C5 Above-average spenders · C6 80/20 analysis (quintiles) |
| **D. Country Analysis** | `05_country_analysis.sql` | D1 Revenue, orders, customers, AOV and ranks per country · D2 Countries whose order rank beats their revenue rank |
| **E. Returns** | `06_returns_analysis.sql` | E1 Returns overview · E2 Gross vs net revenue · E3 Most returned products · E4 Return rate by country · E5 Products with abnormal return rates |
| **F. Advanced Customer Analysis** | `07_customer_retention.sql` | F1 Repeat vs one-time customers · F2 High-value, high-frequency customers · F3 Monthly new vs returning customers |

## 🔍 Key Findings

### Business size
| Metric | Value |
|---|---|
| Gross revenue | **£10.27M** |
| Units sold | 5.81M |
| Orders | 20,951 |
| Identified customers | 4,312 |
| Average order value | £490.28 |
| Products / Countries | 4,102 / 40 |

### Highlights

| Area | Finding |
|---|---|
| 📈 **Seasonality** | Sep–Nov generates **34.5%** of annual revenue. November (£1.46M) is **2.7×** the weakest month, February (£0.55M). |
| 📅 **Trading days** | Mon–Fri produce **~90%** of revenue. Thursday is the best day (£2.10M); Saturday is almost zero (30 orders) → a **B2B / wholesale pattern**. |
| 🌍 **Market concentration** | The UK provides **85.8%** of revenue. EIRE and the Netherlands are next (3.7% and 2.6%). |
| 💎 **Customer concentration** | The top 20% of customers bring **73.6%** of revenue. The top 10 customers alone bring 16.5%. |
| 🔁 **Retention** | Repeat customers are 67% of the base but **94.4%** of revenue. One-time buyers (33%) bring only 5.6%. |
| ↩️ **Returns** | Credit notes equal **6.13%** of gross revenue (£630K), but only **2.41%** is real goods returned. About **61%** of credit value is non-goods (manual/adjustment-type entries). |
| 🧺 **Product mix** | Cake stands and T-light holders lead on revenue. Cake cases and small novelty items lead on volume but earn very little per unit. |
| ⚠️ **Problem products** | Some items show return rates above 100% of units sold in the period (e.g. Black Cherry Lights), which points to quality or data issues worth investigating. |

### Top 5 products by revenue
| Rank | Product | Revenue |
|---|---|---|
| 1 | Regency Cakestand 3 Tier | £169,913 |
| 2 | White Hanging Heart T-Light Holder | £160,346 |
| 3 | Red Retrospot Jumbo Bag | £91,088 |
| 4 | Assorted Colour Bird Ornament | £72,890 |
| 5 | Paper Chain Kit 50's Christmas | £58,127 |

👉 Read the full analysis in **[Business_Insights_Report.md](Business_Insights_Report.md)**.

## ✅ Recommendations (Summary)

1. **Build a key-account programme** for the top 20% of customers (dedicated contact, volume discounts, early access to new stock).
2. **Prepare for Q4 early**: stock up and run campaigns from August–September; use the Feb–Aug slow period for clearance and B2B offers.
3. **Grow outside the UK** by targeting high-AOV markets (Netherlands, Denmark, Norway, EIRE) and fixing low-basket markets with minimum order values.
4. **Convert one-time buyers** with a second-order incentive and follow-up emails after the first purchase.
5. **Cut return losses**: audit products with abnormal return rates, and separate goods returns from manual credit notes in reporting.
6. **Tune the product range**: protect hero products, bundle high-volume low-price items, and review the long tail of tiny-revenue products.

## 📁 Repository Structure

```
online-retail-business-analysis/
│
├── README.md
├── Business_Insights_Report.md
│
├── notebooks/
│   └── online_retail_cleaning.ipynb
│
├── sql/
│   ├── 01_setup_database.sql
│   ├── 02_sales_performance.sql
│   ├── 03_product_performance.sql
│   ├── 04_customer_analysis.sql
│   ├── 05_country_analysis.sql
│   ├── 06_returns_analysis.sql
│   └── 07_customer_retention.sql
│
├── images/            # screenshots of query results
└── data/              # link to dataset (large files not stored in repo)
```

## ▶️ How to Run

1. **Download** the dataset from the [UCI repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii) and place `online_retail_II.xlsx` next to the notebook.
2. **Run** `notebooks/online_retail_cleaning.ipynb` to produce `online_retail_cleaned.csv`.
3. **Enable local infile** in MySQL:
   ```sql
   SHOW VARIABLES LIKE 'local_infile';
   SET GLOBAL local_infile = 1;
   ```
   (In MySQL Workbench also add `OPT_LOCAL_INFILE=1` under *Connection → Advanced*.)
4. **Edit the file path** in `01_setup_database.sql` and run it to create the database, table and load the data.
5. **Run the SQL files in order** (`02` → `07`). Each file creates the views it needs, so run `02` first.

## ⚠️ Limitations

- The data covers **only ~12 months**, so year-over-year growth cannot be measured.
- **December 2010 is a partial month** (data ends on 9 Dec), so its drop (−70%) is not a real decline.
- **December 2009 customers all appear "new"** because the observation window starts there.
- **~14% of revenue (£1.47M) has no Customer ID**, so it is excluded from customer-level analysis.
- Return rates for **small markets** (e.g. Spain) are based on low sales volumes and should be read with care.
- Returns may relate to purchases made **before the data window**, which can inflate some product return rates.

## 🚀 Next Steps

- [ ] Interactive dashboard (Power BI / Tableau / Excel) with revenue, customers, countries and returns pages
- [ ] RFM customer segmentation
- [ ] Market-basket analysis (products bought together)
- [ ] Extend to the second year of the dataset for growth and cohort retention analysis

## 👩‍💻 About Me

**[Your Name]**: Aspiring Data Analyst with a focus on e-commerce and retail analytics.

- 🔗 LinkedIn: [your-linkedin-url]
- 🐙 GitHub: [your-github-url]
- 📧 Email: [your-email]

> 💼 Open to freelance data analytics projects: sales analysis, customer insights and reporting for online stores.

⭐ If you found this project useful, please give it a star!
