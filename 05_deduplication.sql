--Step 2: Check for duplicate business rows
--I used ROW_NUMBER() with PARTITION BY to identify duplicate records based 
--on business keys and isolate duplicate rows before removing them.”
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY 
                   [Order ID],
                   [Product ID],
                   [Order Date],
                   [Customer ID]
               ORDER BY [Row ID]
           ) AS rn
    FROM dbo.stg_superstore_all
)
SELECT *
FROM CTE
WHERE rn > 1;

--Step 3: Delete duplicate
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY 
                   [Order ID],
                   [Product ID],
                   [Order Date],
                   [Customer ID]
               ORDER BY [Row ID]
           ) AS rn
    FROM dbo.stg_superstore_all
)
DELETE FROM CTE
WHERE rn > 1;

--Step 4: Check for missing values in important columns
--I performed null value checks across critical columns using CASE 
--and aggregation to ensure data completeness before transformation
SELECT
    SUM(CASE WHEN [Order ID] IS NULL THEN 1 ELSE 0 END) AS Missing_OrderID,
    SUM(CASE WHEN [Order Date] IS NULL THEN 1 ELSE 0 END) AS Missing_OrderDate,
    SUM(CASE WHEN [Customer ID] IS NULL THEN 1 ELSE 0 END) AS Missing_CustomerID,
    SUM(CASE WHEN [Customer Name] IS NULL THEN 1 ELSE 0 END) AS Missing_CustomerName,
    SUM(CASE WHEN [Product ID] IS NULL THEN 1 ELSE 0 END) AS Missing_ProductID,
    SUM(CASE WHEN [Sales] IS NULL THEN 1 ELSE 0 END) AS Missing_Sales,
    SUM(CASE WHEN [Quantity] IS NULL THEN 1 ELSE 0 END) AS Missing_Quantity,
    SUM(CASE WHEN [Profit] IS NULL THEN 1 ELSE 0 END) AS Missing_Profit
FROM dbo.stg_superstore_all;

--1. Check date logic e.g A shipped order should not be shipped before it was ordered.
SELECT *
FROM dbo.stg_superstore_all
WHERE [Ship Date] < [Order Date];

--2. Check for negative sales FROM dbo.stg_superstore_all
--WHERE [Sales] < 0;Negative sales can indicate:returns, corrections, or bad data
SELECT *
FROM dbo.stg_superstore_all
WHERE [Sales] < 0;


--3. Check for zero or negative quantity
SELECT *
FROM dbo.stg_superstore_all
WHERE [Quantity] <= 0;


--4. Check for discount values above 1
SELECT *
FROM dbo.stg_superstore_all
WHERE [Discount] > 1;

--5. Check blank text values
SELECT
    SUM(CASE WHEN LTRIM(RTRIM([Customer Name])) = '' THEN 1 ELSE 0 END) AS Blank_CustomerName,
    SUM(CASE WHEN LTRIM(RTRIM([City])) = '' THEN 1 ELSE 0 END) AS Blank_City,
    SUM(CASE WHEN LTRIM(RTRIM([State])) = '' THEN 1 ELSE 0 END) AS Blank_State,
    SUM(CASE WHEN LTRIM(RTRIM([Region])) = '' THEN 1 ELSE 0 END) AS Blank_Region
FROM dbo.stg_superstore_all;

--Performed business-rule validation on staging data, including date sequence checks, discount threshold 
--validation, quantity integrity checks, and category consistencyprofiling before dimensional modeling.