-- 1. Create Schema
CREATE SCHEMA IF NOT EXISTS international_debt;
SET search_path TO international_debt;

-- 2. Create Table Structure
CREATE TABLE IF NOT EXISTS international_debt.international_debt_with_missing_values (
    country_name VARCHAR(255),
    country_code VARCHAR(10),
    indicator_name TEXT,
    indicator_code VARCHAR(50),
    debt NUMERIC
);
----------------------------------------------------------------------------------------------
SET search_path TO international_debt;

-----------------------------------------------------

-- 1. Heal missing country_name (handles both NULL and empty strings '')
UPDATE international_debt.international_debt_with_missing_values
SET country_name = sub.country_name
FROM (
    SELECT DISTINCT country_code, country_name 
    FROM international_debt.international_debt_with_missing_values 
    WHERE country_name IS NOT NULL AND TRIM(country_name) != ''
) sub
WHERE international_debt.international_debt_with_missing_values.country_code = sub.country_code
  AND (international_debt.international_debt_with_missing_values.country_name IS NULL 
       OR TRIM(international_debt.international_debt_with_missing_values.country_name) = '');

-- 2. Heal missing country_code (handles both NULL and empty strings '')
UPDATE international_debt.international_debt_with_missing_values
SET country_code = sub.country_code
FROM (
    SELECT DISTINCT country_name, country_code 
    FROM international_debt.international_debt_with_missing_values 
    WHERE country_code IS NOT NULL AND TRIM(country_code) != ''
) sub
WHERE international_debt.international_debt_with_missing_values.country_name = sub.country_name
  AND (international_debt.international_debt_with_missing_values.country_code IS NULL 
       OR TRIM(international_debt.international_debt_with_missing_values.country_code) = '');

-----------------------------------------
-- Query 1: Total Debt Owed
SELECT 
    ROUND(SUM(debt)::NUMERIC, 2) AS total_debt_usd
FROM international_debt_with_missing_values
WHERE debt IS NOT NULL;

-- Query 2: Distinct Country Count
SELECT 
    COUNT(DISTINCT country_name) AS distinct_country_count
FROM international_debt_with_missing_values
WHERE country_name IS NOT NULL 
  AND TRIM(country_name) != '';

-- Query 3: Distinct Debt Indicators
SELECT DISTINCT 
    indicator_code, 
    indicator_name
FROM international_debt_with_missing_values
WHERE indicator_code IS NOT NULL AND TRIM(indicator_code) != ''
  AND indicator_name IS NOT NULL AND TRIM(indicator_name) != ''
ORDER BY indicator_code;

-- Query 4: Highest Total Debt Country
SELECT 
    country_name, 
    country_code, 
    ROUND(SUM(debt)::NUMERIC, 2) AS total_debt_usd
FROM international_debt_with_missing_values
WHERE country_name IS NOT NULL 
  AND TRIM(country_name) != ''
  AND debt IS NOT NULL
GROUP BY country_name, country_code
ORDER BY total_debt_usd DESC NULLS LAST
LIMIT 5;

-- Query 5: Average Debt by Indicator
SELECT 
    indicator_code, 
    indicator_name, 
    ROUND(AVG(debt)::NUMERIC, 2) AS average_debt_usd,
    COUNT(*) AS record_count
FROM international_debt_with_missing_values
WHERE indicator_code IS NOT NULL AND TRIM(indicator_code) != ''
  AND indicator_name IS NOT NULL AND TRIM(indicator_name) != ''
  AND debt IS NOT NULL
GROUP BY indicator_code, indicator_name
ORDER BY average_debt_usd DESC NULLS LAST;

-- Query 6: Principal Repayments Leaderboard
SELECT 
    country_name, 
    ROUND(SUM(debt)::NUMERIC, 2) AS total_principal_repayments_usd
FROM international_debt_with_missing_values
WHERE indicator_name ILIKE '%principal repayments%' 
  AND country_name IS NOT NULL 
  AND TRIM(country_name) != ''
  AND debt IS NOT NULL
GROUP BY country_name
ORDER BY total_principal_repayments_usd DESC NULLS LAST
LIMIT 10;




--Query 7: Most Common Debt Indicators
SELECT 
    indicator_name, 
    indicator_code, 
    COUNT(*) AS indicator_frequency
FROM international_debt_with_missing_values
WHERE indicator_name IS NOT NULL AND TRIM(indicator_name) != ''
GROUP BY indicator_name, indicator_code
ORDER BY indicator_frequency DESC
LIMIT 5;



--Query 8: Debt Concentration and Macro Disparity
-- Top 10 Debtors
SELECT 
    country_name, 
    ROUND(SUM(debt)::NUMERIC, 2) AS total_debt_usd
FROM international_debt_with_missing_values
WHERE country_name IS NOT NULL AND TRIM(country_name) != '' AND debt IS NOT NULL
GROUP BY country_name
ORDER BY total_debt_usd DESC NULLS LAST
LIMIT 10;

-- Least Indebted Nations
SELECT 
    country_name, 
    ROUND(SUM(debt)::NUMERIC, 2) AS total_debt_usd
FROM international_debt_with_missing_values
WHERE country_name IS NOT NULL AND TRIM(country_name) != '' AND debt IS NOT NULL
GROUP BY country_name
ORDER BY total_debt_usd ASC NULLS LAST
LIMIT 10;
