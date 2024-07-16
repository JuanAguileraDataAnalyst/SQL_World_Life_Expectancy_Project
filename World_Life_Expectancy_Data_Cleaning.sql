-- Title:
-- Data Cleaning for Global Life Expectancy Dataset

-- Introduction:
-- In this project, I focus on cleaning and preparing a dataset on global life expectancy for analysis. 
-- This involves removing duplicate records, filling in missing values for critical columns such as Status and Life Expectancy, 
-- and ensuring the dataset's overall integrity. The cleaned data will enable more accurate and insightful analyses, 
-- paving the way for a deeper understanding of global health trends and disparities.

-- Query 1: Select all records from the world_life_expectancy table
-- This query retrieves the complete dataset for initial inspection.
SELECT * 
FROM world_life_expectancy;

-- Removing Duplicates

-- Query 2: Identify duplicates based on Country and Year
-- This query finds records where the combination of Country and Year is repeated.
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

-- Query 3: Select duplicate records with Row_ID
-- This query selects the duplicate records identified in the previous query,
-- showing their Row_IDs for removal.
SELECT *
FROM(
    SELECT Row_ID,
    CONCAT(Country, Year),
    ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, YEAR) ORDER BY CONCAT(Country, YEAR)) AS Row_Num
    FROM world_life_expectancy
) AS Row_table
WHERE Row_Num > 1;

-- Query 4: Delete duplicate records
-- This query deletes the duplicate records based on their Row_IDs.
DELETE FROM world_life_expectancy
WHERE Row_ID IN (
    SELECT Row_ID
    FROM (
        SELECT Row_ID,
        CONCAT(Country, Year),
        ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, YEAR) ORDER BY CONCAT(Country, YEAR)) AS Row_Num
        FROM world_life_expectancy
    ) AS Row_table
    WHERE Row_Num > 1
);

-- Filling Blank Values in Status Column

-- Query 5: Select records with blank Status
-- This query retrieves records where the Status column is blank.
SELECT * 
FROM world_life_expectancy
WHERE Status = '';

-- Query 6: Get distinct non-blank Status values
-- This query retrieves all distinct non-blank Status values to understand the possible values for filling blanks.
SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> '';

-- Query 7: Get distinct countries with Status 'Developing'
-- This query lists all countries that are marked as 'Developing'.
SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing';

-- Query 8: Update blank Status to 'Developing'
-- This query updates records with blank Status to 'Developing' for countries that already have a 'Developing' status.
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing';

-- Query 9: Select records for the United States of America
-- This query checks the records for the United States of America to ensure proper updating of blank Status.
SELECT * 
FROM world_life_expectancy
WHERE Country = 'United States of America';

-- Query 10: Update blank Status to 'Developed'
-- This query updates records with blank Status to 'Developed' for countries that already have a 'Developed' status.
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';

-- Filling Blank Values in Life Expectancy Column

-- Query 11: Select records with blank Life Expectancy
-- This query retrieves records where the Life Expectancy column is blank.
SELECT * 
FROM world_life_expectancy
WHERE `Life expectancy` = '';

-- Query 12: Calculate the average Life Expectancy for adjacent years
-- This query calculates the average Life Expectancy for blank records based on the values from the previous and following years.
SELECT t1.Country, t1.YEAR, t1.`Life expectancy`, 
       t2.Country, t2.YEAR, t2.`Life expectancy`,
       t3.Country, t3.YEAR, t3.`Life expectancy`,
       ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
FROM world_life_expectancy AS t1
JOIN world_life_expectancy AS t2
    ON t1.Country = t2.Country
    AND t1.YEAR = t2.YEAR -1
JOIN world_life_expectancy AS t3
    ON t1.Country = t3.Country
    AND t1.YEAR = t3.YEAR +1
WHERE t1.`Life expectancy` = '';

-- Query 13: Update blank Life Expectancy values
-- This query updates records with blank Life Expectancy based on the average of the previous and following years' values.
UPDATE world_life_expectancy AS t1
JOIN world_life_expectancy AS t2
    ON t1.Country = t2.Country
    AND t1.YEAR = t2.YEAR -1
JOIN world_life_expectancy AS t3
    ON t1.Country = t3.Country
    AND t1.YEAR = t3.YEAR +1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = '';
