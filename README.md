# World Bank International Debt Analytics (SQL)

## Executive Summary
This financial analytics project explores World Bank international debt statistics across developing nations. Built on a local **PostgreSQL** database managed via **DBeaver**, this analysis evaluates total debt distribution, debt category indicators, principal repayment leadership, and macro-economic debt concentration.

---

## Database & Schema Setup

```sql
-- 1. Create Schema & Set Search Path
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

-- 3. Automated Self-Lookup Data Imputation
UPDATE international_debt.international_debt_with_missing_values t1
SET country_name = t2.country_name
FROM international_debt.international_debt_with_missing_values t2
WHERE t1.country_code = t2.country_code AND t1.country_name IS NULL AND t2.country_name IS NOT NULL;

UPDATE international_debt.international_debt_with_missing_values t1
SET country_code = t2.country_code
FROM international_debt.international_debt_with_missing_values t2
WHERE t1.country_name = t2.country_name AND t1.country_code IS NULL AND t2.country_code IS NOT NULL;


## Repository Structure

```text
sql-international-debt-analysis/
├── data/           # Raw World Bank debt CSV dataset
├── report/           # Written findings report ( .pdf)
├── queries/        # SQL analytical query scripts (.sql)
├── screenshots/    # DBeaver query execution screenshots
└── README.md       # Complete project documentation