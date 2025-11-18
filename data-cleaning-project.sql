SELECT * 
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standarized the Data
-- 3. Null values or blank values
-- 4. Remove any columns

CREATE TABLE layoffs_staging
like layoffs; 

INSERT layoffs_staging
SELECT *
FROM layoffs;

SHOW COLUMNS FROM layoffs_staging;

SELECT * 
FROM layoffs_staging;

-- Getting duplicate data

-- Finding Completely Identical Rows
SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    date,
    stage,
    country,
    funds_raised_millions,
    COUNT(*) AS duplicate_count
FROM
    layoffs_staging
GROUP BY
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    date,
    stage,
    country,
    funds_raised_millions
HAVING
    COUNT(*) > 1;

-- Finding Duplicates Based on Specific Columns    
SELECT
    company,
    date,
    COUNT(*) AS duplicate_count
FROM
    layoffs_staging
GROUP BY
    company,
    date
HAVING
    COUNT(*) > 1;
    
-- Retrieving the Full Duplicate Rows
WITH DuplicateRows AS (
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY company, date
            ORDER BY (SELECT NULL) -- Used when no specific sorting is needed
        ) as rn
    FROM
        layoffs_staging
)
SELECT
    *
FROM
    DuplicateRows
WHERE
    rn > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, 
funds_raised_millions) as row_num 
FROM layoffs_staging; 

SELECT * 
FROM layoffs_staging2 
WHERE row_num > 1;

DELETE FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;

-- Standardizing Data 
-- A. Remove Leading/Trailing Whitespace
UPDATE layoffs_staging2
SET company = TRIM(company); 

-- Standardize Specific Industry/Company Names
SELECT DISTINCT industry FROM layoffs_staging2  ORDER BY 1;

UPDATE layoffs_staging2
SET industry = "Crypto" 
WHERE industry like "Crypto%"; 

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country like "United States%";

SELECT COUNTRY FROM layoffs_staging2;

-- Change Data Type
SELECT `date`, str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2; 

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2; 

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` date; 

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb'; 


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = ''; 

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 
ON t1.company = t2.company
AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;