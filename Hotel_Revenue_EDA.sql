

-- first of all we you need to create a database 
-- CREATE DATABASE Database_Name;
--I have already created database
USE PortfolioProject;

-- we have data in data in .xlsx and it contains 5 sheet, convert this .xlsx file into .csv and i only converted 2018,2019,2020 sheets into csv.
-- create table with same columns name but i set data types of all columns varchar(max) to avoid any data conversion errors and warning
CREATE TABLE [Hotel Revenue] 
(
	hotel		VARCHAR(MAX),
	is_canceled	VARCHAR(MAX),
	lead_time	VARCHAR(MAX),	
	arrival_date_year			VARCHAR(MAX),
	arrival_date_month			VARCHAR(MAX),
	arrival_date_week_number	VARCHAR(MAX),
	arrival_date_day_of_month	VARCHAR(MAX),
	stays_in_weekend_nights		VARCHAR(MAX),
	stays_in_week_nights		VARCHAR(MAX),
	adults		VARCHAR(MAX),
	children	VARCHAR(MAX),
	babies		VARCHAR(MAX),
	meal		VARCHAR(MAX),
	country		VARCHAR(MAX),
	market_segment			VARCHAR(MAX),
	distribution_channel	VARCHAR(MAX),
	is_repeated_guest		VARCHAR(MAX),
	previous_cancellations  VARCHAR(MAX),	
	previous_bookings_not_canceled	VARCHAR(MAX),
	reserved_room_type				VARCHAR(MAX),
	assigned_room_type				VARCHAR(MAX),
	booking_changes					VARCHAR(MAX),
	deposit_type					VARCHAR(MAX),
	agent					VARCHAR(MAX),
	company					VARCHAR(MAX),
	days_in_waiting_list	VARCHAR(MAX),
	customer_type			VARCHAR(MAX),
	adr						VARCHAR(MAX),
	required_car_parking_spaces	VARCHAR(MAX),
	total_of_special_requests	VARCHAR(MAX),
	reservation_status			VARCHAR(MAX),
	reservation_status_date		VARCHAR(MAX)
);

-- lets see table with columns names and datatypes
SELECT column_name, data_type from INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Hotel Revenue';


-- Lets Populate the Table 
-- BULK INSERT used to insert csv file data into table in one go, you need to mention dbo.tablename 
BULK INSERT dbo.[Hotel Revenue] FROM 'C:\Users\Public\2020.csv' WITH(FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');

-- let see our table is populated or not 
SELECT TOP 20 * FROM [Hotel Revenue];

---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------


-- Lets start our data analysis


-- First find the revenue
-- In this query i am using CTE (Common Table Expression) to find revenue 
WITH cteRevenue (hotel,
    arrival_date_year,
    arrival_date_month,
    arrival_date_day_of_month,
    stays_in_weekend_nights,
    stays_in_week_nights,
    adr,revenue) AS
(
SELECT
    hotel,
    arrival_date_year,
    arrival_date_month,
    arrival_date_day_of_month,
    stays_in_weekend_nights,
    stays_in_week_nights,
    adr,
    (CAST(stays_in_weekend_nights AS DECIMAL(7,2)) + CAST(stays_in_week_nights AS DECIMAL(7,2))) * adr  AS revenue
FROM
    [Hotel Revenue]
	)
SELECT  SUM(revenue)/1000000 AS [Total Revenue (in Millions)] from cteRevenue;


----------------------------------------------
-- Alternative of CTE query to find revenue is
SELECT
    SUM(revenue) / 1000000 AS [Total Revenue (in Millions)]
FROM (
    SELECT
        stays_in_weekend_nights,
        stays_in_week_nights,
        adr,
        (CAST(stays_in_weekend_nights AS DECIMAL(7, 2)) + CAST(stays_in_week_nights AS DECIMAL(7, 2))) * adr AS revenue
    FROM
        [Hotel Revenue]
) AS Revenue;


---------------------------------------------------
-- Let write a query to check reservation cancelled
SELECT 
	SUM(CAST(is_canceled AS INT)) as [Total Canceled] 
from 
	[Hotel Revenue];


----------------------------------------------
-- Average of adr
SELECT
    SUM(CAST(adr AS DECIMAL(7, 2))) / COUNT(adr) AS [Average of adr]
FROM
    [Hotel Revenue];


----------------------------------------------
-- Total nights stays
SELECT 
	SUM(CAST(stays_in_week_nights AS INT) + CAST(stays_in_weekend_nights AS INT)) AS [Total Nights (in K)] 
	FROM 
		[Hotel Revenue];


----------------------------------------------
-- Required car parking space
SELECT 
	SUM(CAST(required_car_parking_spaces AS INT)) AS [Required Car Space] 
FROM 
	[Hotel Revenue];

----------------------------------------------

-- Count repeated guested
SELECT 
	SUM(CAST(is_repeated_guest as INT)) AS [Repeated Guest] 
FROM 
	[Hotel Revenue];


----------------------------------------------
-- Top 5 Market Segment by Revenue
SELECT ToP 5 market_segment, 
	SUM((CAST(stays_in_weekend_nights AS DECIMAL(7,2)) + CAST(stays_in_week_nights AS DECIMAL(7,2))) * adr)  AS [Revenue],
	(SUM((CAST(stays_in_weekend_nights AS DECIMAL(7,2)) + CAST(stays_in_week_nights AS DECIMAL(7,2))) * adr) 
	/
	(SELECT SUM((CAST(stays_in_weekend_nights AS DECIMAL(7, 2)) + CAST(stays_in_week_nights AS DECIMAL(7, 2))) * adr) 
FROM 
[Hotel Revenue])) * 100 AS [Percentage]

FROM 
	[Hotel Revenue] 
GROUP BY 
	market_segment 
ORDER BY 
	[Revenue] DESC;



---------------------------------------
-- Total nights by Customer type
SELECT [Hotel Revenue].customer_type, SUM(CAST(stays_in_week_nights AS INT) + CAST(stays_in_weekend_nights AS INT)) AS [Total Nights],
	CAST(ROUND((SUM(CAST(stays_in_week_nights AS INT) + CAST(stays_in_weekend_nights AS INT)) * 100.0
	/
	((SELECT SUM(CAST(stays_in_week_nights AS INT) + CAST(stays_in_weekend_nights AS INT)) 
FROM
	[Hotel Revenue]))),2) AS DECIMAL(7,2)) AS [Percentage]  
FROM 
	[Hotel Revenue] 
GROUP BY 
	[Hotel Revenue].customer_type
ORDER BY 
[Total Nights] DESC;


----------------------------------------
-- Total Revenue generated ny each hotel
SELECT hotel,
    SUM(revenue) / 1000000 AS [Total Revenue (in Millions)]
FROM (
    SELECT
	hotel,
        stays_in_weekend_nights,
        stays_in_week_nights,
        adr,
        (CAST(stays_in_weekend_nights AS DECIMAL(7, 2)) + CAST(stays_in_week_nights AS DECIMAL(7, 2))) * adr AS revenue
    FROM
        [Hotel Revenue]
) AS Revenue
GROUP BY 
	hotel
ORDER BY
	hotel;

----------------------------------------------
-- Revenue by Year
SELECT Years,Months,
	SUM(revenue) / 1000000 AS [Total Revenue (in Millions)]
FROM (
    SELECT
        stays_in_weekend_nights,
        stays_in_week_nights,
        adr,
        (CAST(stays_in_weekend_nights AS DECIMAL(7, 2)) + CAST(stays_in_week_nights AS DECIMAL(7, 2))) * adr AS revenue,
		YEAR(CONVERT(DATE, RTRIM(LTRIM(REPLACE(reservation_status_date, ',', ''))), 101)) AS Years,
		MONTH(CONVERT(DATE, RTRIM(LTRIM(REPLACE(reservation_status_date, ',', ''))), 101)) AS Months
    FROM
        [Hotel Revenue]
) AS Revenue
GROUP BY 
	Years ,Months
ORDER BY
	Months,Years ASC;


----------------------------------------------
-- Top 15 countries by revenue
SELECT TOP 15 country,
	SUM(revenue) AS Total_Revenue
FROM (
    SELECT
        stays_in_weekend_nights,
        stays_in_week_nights,
        adr,
        (CAST(stays_in_weekend_nights AS DECIMAL(7, 2)) + CAST(stays_in_week_nights AS DECIMAL(7, 2))) * adr AS revenue,
		country
    FROM
        [Hotel Revenue]
) AS Revenue
GROUP BY 
	country 
ORDER BY
	Total_Revenue DESC;


