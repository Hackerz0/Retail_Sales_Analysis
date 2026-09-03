-- ============================================================
-- RETAIL SALES DATA CLEANING & BASIC ANALYSIS
-- Tool: SQLite / DB Browser for SQLite
-- Dataset: Retail Sales Dataset
-- Records: 100,000
-- Purpose: Data cleaning, validation, and basic business analysis
-- ============================================================


-- ============================================================
-- 1. INSPECT TABLE STRUCTURE
-- Check column names and declared data types.
-- ============================================================

PRAGMA table_info(retail_sales_raw);


-- ============================================================
-- 2. CHECK DUPLICATE INVOICE IDs
-- Find Invoice_IDs that appear more than once.
-- Duplicate IDs are investigated rather than automatically deleted.
-- ============================================================

SELECT *
FROM retail_sales_raw
WHERE Invoice_ID IN (
    SELECT Invoice_ID
    FROM retail_sales_raw
    GROUP BY Invoice_ID
    HAVING COUNT(*) > 1
)
ORDER BY Invoice_ID;


-- ============================================================
-- 3. CHECK MISSING VALUES
-- Identify missing values in important customer fields.
-- ============================================================

SELECT
    COUNT(*) - COUNT(Customer_Age) AS missing_customer_age,
    COUNT(*) - COUNT(Customer_Gender) AS missing_customer_gender
FROM retail_sales_raw;


-- ============================================================
-- 4. CHECK DISTINCT CATEGORICAL VALUES
-- Inspect categories for unexpected or inconsistent values.
-- ============================================================

SELECT DISTINCT City
FROM retail_sales_raw
ORDER BY City;

SELECT DISTINCT Store_Format
FROM retail_sales_raw
ORDER BY Store_Format;

SELECT DISTINCT Category
FROM retail_sales_raw
ORDER BY Category;

SELECT DISTINCT Brand
FROM retail_sales_raw
ORDER BY Brand;

SELECT DISTINCT Channel
FROM retail_sales_raw
ORDER BY Channel;

SELECT DISTINCT Payment_Mode
FROM retail_sales_raw
ORDER BY Payment_Mode;

SELECT DISTINCT Customer_Gender
FROM retail_sales_raw
ORDER BY Customer_Gender;

SELECT DISTINCT Loyalty_Flag
FROM retail_sales_raw
ORDER BY Loyalty_Flag;


-- ============================================================
-- 5. INVESTIGATE CUSTOMER GENDER VALUES
-- Check the frequency of each gender value.
-- The data contains M, F, O, and 'nan'.
-- M and F are retained. O and 'nan' are treated as unknown.
-- ============================================================

SELECT
    Customer_Gender,
    COUNT(*) AS records
FROM retail_sales_raw
GROUP BY Customer_Gender
ORDER BY records DESC;


-- ============================================================
-- 6. CHECK FOR UNWANTED SPACES
-- TRIM removes leading and trailing spaces.
-- No returned rows means no trimming issue was found.
-- ============================================================

SELECT City
FROM retail_sales_raw
WHERE City <> TRIM(City);


-- ============================================================
-- 7. VALIDATE CALCULATED FINANCIAL COLUMNS
-- Check whether Revenue, Cost, and Margin match their formulas.
-- ============================================================

SELECT COUNT(*) AS incorrect_revenue
FROM retail_sales_raw
WHERE ABS(Revenue - (Units * Selling_Price)) > 0.01;

SELECT COUNT(*) AS incorrect_cost
FROM retail_sales_raw
WHERE ABS(Cost - (Units * Cost_Price)) > 0.01;

SELECT COUNT(*) AS incorrect_margin
FROM retail_sales_raw
WHERE ABS(Margin - (Revenue - Cost)) > 0.01;


-- ============================================================
-- 8. CREATE CLEANED TABLE
-- Preserve the raw table and create a separate cleaned table.
--
-- Customer_Age:
-- Convert TEXT values to INTEGER.
--
-- Customer_Gender:
-- Keep M and F.
-- Convert O and 'nan' to NULL because they represent unknown values.
-- ============================================================

CREATE TABLE retail_sales_clean AS
SELECT
    Invoice_Date,
    City,
    Store_Format,
    Category,
    Brand,
    Channel,
    Payment_Mode,
    Units,
    Revenue,
    Cost,
    Margin,
    "Margin_%",
    CAST(Customer_Age AS INTEGER) AS Customer_Age,
    CASE
        WHEN Customer_Gender IN ('M', 'F')
        THEN Customer_Gender
        ELSE NULL
    END AS Customer_Gender,
    Loyalty_Flag
FROM retail_sales_raw;


-- ============================================================
-- 9. VALIDATE THE CLEANED TABLE
-- Confirm that the cleaned table contains the expected records
-- and that important customer fields remain populated where valid.
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(Customer_Age) AS non_null_age,
    COUNT(Customer_Gender) AS non_null_gender
FROM retail_sales_clean;


-- ============================================================
-- 10. BASIC BUSINESS KPIs
-- Calculate the main financial metrics from the cleaned data.
-- These results can be used as a starting point for Excel analysis.
-- ============================================================

SELECT
    COUNT(*) AS total_sales_records,
    SUM(Revenue) AS total_revenue,
    SUM(Cost) AS total_cost,
    SUM(Margin) AS total_margin,
    AVG(Revenue) AS average_revenue
FROM retail_sales_clean;


-- ============================================================
-- END OF SQL CLEANING AND BASIC ANALYSIS
-- ============================================================
