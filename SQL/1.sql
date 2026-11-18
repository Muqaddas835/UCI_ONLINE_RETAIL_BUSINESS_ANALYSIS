create database UCI_BUSINESS_ANALYSIS;
USE UCI_BUSINESS_ANALYSIS;

USE UCI_BUSINESS_ANALYSIS;

CREATE TABLE online_retail (
    Transaction_ID BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    Invoice VARCHAR(20) NOT NULL,
    StockCode VARCHAR(20) NOT NULL,
    Description VARCHAR(100),
    Quantity INT NOT NULL,
    InvoiceDate DATETIME NOT NULL,
    Price DECIMAL(12,2) NOT NULL,
    Customer_ID VARCHAR(20),
    Country VARCHAR(100) NOT NULL,
    Category VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
USE UCI_BUSINESS_ANALYSIS;

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Desktop/python/online_retail_cleaned.csv'
INTO TABLE online_retail
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country, Category);











