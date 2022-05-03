CREATE SCHEMA sales;

USE sales;

DROP TABLE IF EXISTS property_sales;
CREATE TABLE property_sales(
    datesold DATETIME ,
    postcode CHAR(4),
    price INT,
    propertyType VARCHAR(6),
    bedrooms INT );
    
/** Data Exploration **/

SELECT * 
FROM property_sales
LIMIT 5;

SELECT MIN(datesold),MAX(datesold), MIN(price), MAX(price), AVG(price)
FROM property_sales;

SELECT COUNT(DISTINCT datesold) AS number_of_days,
       COUNT(DISTINCT postcode) AS number_of_postcodes, 
       COUNT(DISTINCT propertyType) AS property_type, 
       COUNT(DISTINCT bedrooms) AS distinct_number_of_rooms
FROM property_Sales;

SELECT DISTINCT bedrooms FROM property_sales;

/** We have total 29,580 records from 7th Feb 2007 to 27th Feb 2019. The data covers 27 postal codes and 2 property types (House & Unit). 
Number of bedrooms range from 0 to 5 and, property sold price range from minimum= 56500, maximum = 8000000 and average price of 609736. **/

-- Dataset contain data for 3582 days. Let's explore the date with highest frequency of sales 
SELECT datesold, COUNT(*) AS number_of_sales, SUM(price) AS price_Sold, AVG(price)
FROM property_sales
GROUP BY datesold
ORDER BY number_of_sales DESC
LIMIT 10;

-- Number of sales per year per property type
SELECT YEAR(datesold) AS 'Year', 
       SUM(CASE WHEN propertyType = 'house' THEN 1 ELSE 0 END) AS House_sold,
       SUM(CASE WHEN propertyType = 'unit' THEN 1 ELSE 0 END ) AS Unit_sold
FROM property_Sales
GROUP BY Year;

-- Average price per year per property type
SELECT YEAR(datesold) AS 'Year', 
       ROUND(AVG(CASE WHEN propertyType = 'house' THEN price ELSE null END)) AS avg_price_House_sold,
       ROUND(AVG(CASE WHEN propertyType = 'unit' THEN price ELSE null END )) AS avg_price_Unit_sold
FROM property_Sales
GROUP BY Year;

-- Average price of property per bedroom
SELECT YEAR(datesold) AS 'Year', 
       ROUND(AVG(CASE WHEN propertyType = 'house' THEN price/bedrooms ELSE null END)) AS avg_price_House_sold,
       ROUND(AVG(CASE WHEN propertyType = 'unit' THEN price/bedrooms ELSE null END )) AS avg_price_Unit_sold
FROM property_Sales
GROUP BY Year;

-- Combine them all
SELECT YEAR(datesold) AS 'Year', 
	SUM(CASE WHEN propertyType = 'house' THEN 1 ELSE 0 END) AS House_sold,
       SUM(CASE WHEN propertyType = 'unit' THEN 1 ELSE 0 END ) AS Unit_sold,
       ROUND(AVG(CASE WHEN propertyType = 'house' THEN price ELSE null END)) AS avg_price_House_sold,
       ROUND(AVG(CASE WHEN propertyType = 'unit' THEN price ELSE null END )) AS avg_price_Unit_sold,
       ROUND(AVG(CASE WHEN propertyType = 'house' THEN price/bedrooms ELSE null END)) AS avg_house_price_per_room,
       ROUND(AVG(CASE WHEN propertyType = 'unit' THEN price/bedrooms ELSE null END )) AS avg_unit_price_per_room
FROM property_Sales
GROUP BY Year;

-- Number of sales Per year 
WITH CTE AS (
	SELECT YEAR(datesold) AS 'Year', COUNT(*) AS num_of_sales, SUM(price) AS sale_amount
	FROM property_Sales
	GROUP BY YEAR(datesold))
SELECT Year, num_of_sales, sale_amount,
	ROUND(100 *(sale_amount - LAG(sale_amount) OVER (ORDER BY Year))/LAG(sale_amount) OVER (ORDER BY Year),1) AS YOY_growth
FROM CTE;
/** number of sales doubled in 2009 and hence forth increased continously before decreasing in 2018 and a major drop in 2019 **/

-- monthly sales
SELECT Month(datesold) AS 'Month', COUNT(*) AS num_of_sales, ROUND(Avg(price)) AS sale_amount
FROM property_Sales
GROUP BY Month
ORDER BY num_of_sales DESC;

-- Which postcode has the highest average price per sales?
SELECT postcode, ROUND(AVG(price)) AS avg_price , COUNT(*)
FROM property_sales
GROUP BY postcode
ORDER BY avg_price DESC
LIMIT 10;

-- Which postcode has highest number of property sold
SELECT postcode, ROUND(AVG(price)) AS avg_price , COUNT(*)
FROM property_sales
GROUP BY postcode
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Top 5 postcodes each year
WITH CTE AS 
(SELECT *, RANK() OVER (PARTITION BY Year ORDER BY price_sum DESC) AS Ranking
FROM (
	SELECT YEAR(datesold) AS 'Year', postcode, SUM(price) AS price_sum
	FROM property_Sales
	GROUP BY YEAR(datesold), postcode) per_year)
SELECT * 
FROM CTE 
WHERE Ranking <= 5;

-- Property type
WITH CTE AS (SELECT propertyType, COUNT(*) AS num_sold
FROM property_sales
GROUP BY propertyType)
SELECT propertyType, num_sold , CONCAT(100*num_sold/SUM(num_sold) OVER(),'%')
FROM CTE;
/** 83% percent of property sold are property and only 17% are units **/

-- Average price as per number of bedrooms
SELECT propertyType, bedrooms, COUNT(*) AS num_sold, ROUND(AVG(price)) AS Average_price
FROM property_sales
GROUP BY propertyType,bedrooms
ORDER BY propertyType,bedrooms;
/** Houses with 4 bedrooms are sold more and at good price, while units with 2 bedrooms are more popular **/

