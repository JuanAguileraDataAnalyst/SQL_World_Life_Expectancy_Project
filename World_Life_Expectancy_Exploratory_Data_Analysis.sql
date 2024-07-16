-- Title:
-- Exploratory Data Analysis of Global Life Expectancy Trends

-- Introduction:
-- In this exploratory data analysis, I delve into the global trends of life expectancy, 
-- examining various factors that influence these trends across different countries. 

-- By leveraging a comprehensive dataset, I aim to uncover insights on how life expectancy has evolved over the years, 
-- the impact of GDP and BMI on life expectancy, and the disparities between countries with different economic statuses. 
-- This analysis provides a detailed look into the patterns and correlations that shape the health and longevity of populations worldwide.

-- Query 1: Select all records from the world_life_expectancy table
-- This query retrieves the complete dataset for world life expectancy
SELECT * 
FROM world_life_expectancy;

-- Query 2: Calculate the life expectancy range for each country
-- This query finds the minimum and maximum life expectancy for each country,
-- and calculates the increase in life expectancy over a 15-year period.
SELECT Country, 
MIN(`Life expectancy`),
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`)-MIN(`Life expectancy`),1) AS Life_Increase_15_Years 
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Years ASC;

-- Query 3: Calculate the average life expectancy for each year
-- This query computes the average life expectancy globally for each year in the dataset.
SELECT YEAR, ROUND(AVG(`Life expectancy`),1) AS AVG_Life_expectancy
FROM  world_life_expectancy
GROUP BY YEAR
ORDER BY Year;

-- Query 4: Calculate the average life expectancy and GDP for each country
-- This query computes the average life expectancy and GDP for each country,
-- excluding records with zero values.
SELECT Country,  ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING GDP > 0
AND Life_Exp > 0
ORDER BY GDP ASC;

-- Query 5: Compare life expectancy based on GDP levels
-- This query compares the number of countries and average life expectancy
-- between countries with GDP above and below 1500.
SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END)  AS High_GDP_Count,
Round(AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END),1)  AS High_GDP_LIfe_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END)  AS Low_GDP_Count,
Round(AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END),1)  AS Low_GDP_LIfe_Expectancy
FROM world_life_expectancy;

-- Query 6: Calculate life expectancy by status
-- This query calculates the average life expectancy and counts the number of countries
-- based on their status (e.g., developed, developing).
SELECT Status, COUNT(DISTINCT(Country)) AS Countries, ROUND(AVG(`Life expectancy`),1) AS Life_Expectancy
FROM world_life_expectancy
GROUP BY Status;

-- Query 7: Calculate average life expectancy and BMI for each country
-- This query computes the average life expectancy and BMI for each country,
-- excluding records with zero values.
SELECT Country,  ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING BMI > 0
AND Life_Exp > 0
ORDER BY BMI ASC;

-- Query 8: Calculate the rolling total of adult mortality for each country
-- This query computes the rolling total of adult mortality over the years for each country,
-- providing a cumulative view of adult mortality trends.
SELECT Country,
YEAR,
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER( PARTITION BY Country ORDER BY YEAR) As Rolling_Total 
FROM world_life_expectancy;
