# DATA CLEANING PROJECT IN MySQL

-- 1. Remove Dublicates.
-- 2. Standardize The Data and Fix Error.
-- 3. Null Values or Blank Values And See What
-- 4. Remove Any columns and Rows That Not Neessary_In few Ways.

CREATE DATABASE `Layoff_Analysis`;
USE `Layoff_Analysis`;

/* SELECT *
FROM `Layoffs`;

SELECT 
DISTINCT `Company`, `Date`
FROM `Layoff_Analysis`.`Layoffs`
order by `Date` asc; */

-- Create an Table That Replicates the Raw Table,
-- To Escape From Cruel Difficulties.

CREATE TABLE `Layoffs_Staging`
LIKE `layoffs`;

INSERT  `Layoffs_Staging`
SELECT *FROM `layoffs`;

SELECT *
FROM `Layoffs_Staging`;

SELECT 
DISTINCT `Company`, `Date`
FROM `Layoff_Analysis`.`Layoffs_Staging`
order by `Date` asc;


-- 1. Remove Dublicates.

SELECT *
FROM `Layoffs_Staging`;

# First let's check for duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY Company, Location, Industry, Total_Laid_Off, Percentage_Laid_Off,`date`
) AS Row_Num
FROM `Layoffs_Staging`;

WITH Dublicate_CTE AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY Company, Location, Industry, Total_Laid_Off, Percentage_Laid_Off, `Date`, Stage, Country, Funds_Raised_Millions) AS Row_Num
FROM `Layoffs_Staging`
)
SELECT *
FROM Dublicate_CTE 
WHERE Row_Num > 1;

SELECT *
FROM `Layoffs_Staging` 
WHERE Company = 'Hibob';


-- creating one more table to delete/remove dublicates flawless
CREATE TABLE `layoffs_staging1` (
  `Company` text,
  `Location` text,
  `Industry` text,
  `Total_Laid_Off` int DEFAULT NULL,
  `Percentage_Laid_Off` text,
  `Date` text,
  `Stage` text,
  `Country` text,
  `Funds_Raised_Millions` int DEFAULT NULL,
  `Row_Num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM `Layoffs_Staging1`;

INSERT INTO `Layoffs_Staging1`
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY Company, Location, Industry, Total_Laid_Off, Percentage_Laid_Off,
`Date`, Stage, Country, Funds_Raised_Millions) AS Row_Num
FROM `Layoffs_Staging`;


SELECT *
FROM `Layoffs_Staging1`
WHERE Row_Num > 1;

DELETE
FROM `Layoffs_Staging1`
WHERE Row_Num > 1;

-- 2. Standardize The Data and Fix Error.
#REMOVING BLANK SPACE
SELECT Company, TRIM(Company)
FROM `layoffs_staging1`;

UPDATE `layoffs_staging1`
SET Company = TRIM(Company);

SELECT DISTINCT Industry
FROM `layoffs_staging1`
ORDER BY 1;

SELECT *
FROM `Layoffs_Staging1`
WHERE Industry LIKE 'Crypto%';

UPDATE `layoffs_staging1`
SET Industry = 'Crypto'
WHERE Industry LIKE 'Crypto%';


SELECT DISTINCT Country
FROM `layoffs_staging1`
ORDER BY 1;

#REMOVE UNNECESSERY '_, . etc,'
SELECT DISTINCT Country, TRIM(TRAILING '.' FROM Country)
FROM `layoffs_staging1`
ORDER BY 1;

UPDATE `layoffs_staging1`
SET Country = TRIM(TRAILING '.' FROM Country)
WHERE Country LIKE 'United States%';

#DATE FORMATTING
SELECT `Date`,
STR_TO_DATE(`Date`, '%m/%d/%Y')
FROM `Layoffs_Staging1`;

UPDATE `Layoffs_Staging1`
SET `Date` = STR_TO_DATE(`Date`, '%m/%d/%Y');

#CHANGING COLUMN DATA TYPE
ALTER TABLE `layoffs_staging1`
MODIFY COLUMN `Date` DATE;

-- 3. Look at null values and see what 
SELECT *
FROM `Layoffs_Staging1`;

SELECT * 
FROM `Layoffs_Staging1`
WHERE Total_Laid_Off IS NULL
AND Percentage_Laid_Off IS NULL;

SELECT DISTINCT Industry
FROM `Layoffs_Staging1`
WHERE Industry IS NULL;

SELECT * 
FROM `Layoffs_Staging1`
WHERE Industry IS NULL
OR Industry = '';

SELECT * 
FROM `Layoffs_Staging1`
where company = 'airbnb';

UPDATE `Layoffs_Staging1`
SET industry = NULL
WHERE industry = '';

SELECT LSTG.Industry ,LSTG1.Industry
FROM `Layoffs_Staging1` AS LSTG
JOIN `Layoffs_Staging1`  AS LSTG1
ON LSTG.Company = LSTG1.Company
WHERE (LSTG.Industry IS NULL OR LSTG.Industry = '')
AND LSTG1.Industry IS NOT NULL;

UPDATE `Layoffs_Staging1` AS LSTG
JOIN `Layoffs_Staging1` AS LSTG1
ON LSTG.Company = LSTG1.Company
SET LSTG.Industry = LSTG1.Industry
WHERE LSTG.Industry IS NULL
AND LSTG1.Industry IS NOT NULL;

#using row to check and no more NULLs there!
SELECT * 
FROM `Layoffs_Staging1`
where company = 'airbnb';

-- 4. Remove Any columns and Rows That Not Neessary_In few Ways.

SELECT * 
FROM `Layoffs_Staging1`;
# To get clarified to remove unnecessary ROWs & COLUMNs
SELECT * 
FROM `Layoffs_Staging1`
WHERE Total_Laid_Off IS NULL
AND Percentage_Laid_Off IS NULL;
#Remove & columns and Rows That Unnecessary
DELETE
FROM `Layoffs_Staging1`
WHERE Total_Laid_Off IS NULL
AND Percentage_Laid_Off IS NULL;
 
 ALTER TABLE `Layoffs_Staging1`
 DROP COLUMN Row_Num;



# EDA (Exploratory Data Analysis) PROJECT IN MySQL

SELECT * 
FROM `Layoffs_Staging1`;

-- EDA

-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers

-- normally when you start the EDA process you have some idea of what you're looking for

-- with this info we are just going to look around and see what we find!

SELECT * 
FROM `Layoffs_Staging1`;

-- EASIER QUERIES

SELECT MAX(total_laid_off)
FROM `Layoffs_Staging1`;


-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM `Layoffs_Staging1`
WHERE  percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
FROM `Layoffs_Staging1`
WHERE  percentage_laid_off = 1;
-- these are mostly startups it looks like who all went out of business during this time

-- if we order by funcs_raised_millions we can see how big some of these companies were
SELECT *
FROM `Layoffs_Staging1`
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- BritishVolt looks like an EV company, Quibi! I recognize that company - wow raised like 2 billion dollars and went under - ouch

-- SOMEWHAT TOUGHER AND MOSTLY USING GROUP BY--------------------------------------------------------------------------------------------------

-- Companies with the biggest single Layoff

SELECT company, total_laid_off
FROM `Layoffs_Staging1`
ORDER BY 2 DESC
LIMIT 5;
-- now that's just on a single day

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM `Layoffs_Staging1`
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;



-- by location
SELECT location, SUM(total_laid_off)
FROM `Layoffs_Staging1`
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- this it total in the past 3 years or in the dataset

SELECT country, SUM(total_laid_off)
FROM `Layoffs_Staging1`
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(date), SUM(total_laid_off)
FROM `Layoffs_Staging1`
GROUP BY YEAR(date)
ORDER BY 1 ASC;


SELECT industry, SUM(total_laid_off)
FROM `Layoffs_Staging1`
GROUP BY industry
ORDER BY 2 DESC;


SELECT stage, SUM(total_laid_off)
FROM `Layoffs_Staging1`
GROUP BY stage
ORDER BY 2 DESC;


-- TOUGHER QUERIES------------------------------------------------------------------------------------------------------------------------------------

-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year. It's a little more difficult.
-- I want to look at 

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM `Layoffs_Staging1`
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 5
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;




-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM `Layoffs_Staging1`
GROUP BY dates
ORDER BY dates ASC;

-- now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM `Layoffs_Staging1`
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;

SELECT *
FROM `Layoffs`;

SELECT *
FROM `Layoffs_Staging`;

SELECT *
FROM `Layoffs_Staging1`;


                                                                   -- MYSQL LEARNING & PROJECTS WERE DONE --
																			-- GOING TO PRACTICE --