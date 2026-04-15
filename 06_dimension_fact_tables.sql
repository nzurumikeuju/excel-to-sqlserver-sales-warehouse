--C. DATA MODELLING STAGE
--Step 1: Create the dimension tables
CREATE TABLE dbo.DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(50),
    CustomerName NVARCHAR(100),
    Segment NVARCHAR(50)
);


CREATE TABLE dbo.DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID NVARCHAR(50),
    ProductName NVARCHAR(255),
    Category NVARCHAR(100),
    SubCategory NVARCHAR(100)
);
GO
CREATE TABLE dbo.DimLocation (
    LocationKey INT IDENTITY(1,1) PRIMARY KEY,
    Country NVARCHAR(100),
    City NVARCHAR(100),
    State NVARCHAR(100),
    PostalCode NVARCHAR(20),
    Region NVARCHAR(50)
);

CREATE TABLE dbo.DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    DayNumber INT,
    MonthNumber INT,
    MonthName NVARCHAR(20),
    QuarterNumber INT,
    YearNumber INT
);

--Create the Fact table
CREATE TABLE dbo.FactSales (
    SalesKey INT IDENTITY(1,1) PRIMARY KEY,
    OrderID NVARCHAR(50),
    DateKey INT,
    CustomerKey INT,
    ProductKey INT,
    LocationKey INT,
    ShipDate DATE,
    ShipMode NVARCHAR(50),
    Sales DECIMAL(18,2),
    Quantity INT,
    Discount DECIMAL(10,2),
    Profit DECIMAL(18,2)
);
-- insert into the tables
INSERT INTO dbo.DimCustomer (CustomerID, CustomerName, Segment)
SELECT DISTINCT
    [Customer ID],
    [Customer Name],
    [Segment]
FROM dbo.stg_superstore_all;

INSERT INTO dbo.DimProduct (ProductID, ProductName, Category, SubCategory)
SELECT
    [Product ID] AS ProductID,
    MAX([Product Name]) AS ProductName,
    MAX([Category]) AS Category,
    MAX([Sub-Category]) AS SubCategory
FROM dbo.stg_superstore_all
GROUP BY [Product ID];

INSERT INTO dbo.DimLocation (Country, City, State, PostalCode, Region)
SELECT DISTINCT
    [Country],
    [City],
    [State],
    CAST([Postal Code] AS NVARCHAR(20)),
    [Region]
FROM dbo.stg_superstore_all;

--Load DimDate- This creates one row per distinct order date.

INSERT INTO dbo.DimDate (
    DateKey,
    FullDate,
    DayNumber,
    MonthNumber,
    MonthName,
    QuarterNumber,
    YearNumber
)
SELECT DISTINCT
    CAST(CONVERT(VARCHAR(8), [Order Date], 112) AS INT),
    CAST([Order Date] AS DATE),
    DAY([Order Date]),
    MONTH([Order Date]),
    DATENAME(MONTH, [Order Date]),
    DATEPART(QUARTER, [Order Date]),
    YEAR([Order Date])
FROM dbo.stg_superstore_all;

--check the Dimension Tables
SELECT COUNT(*) AS CustomerCount FROM dbo.DimCustomer;
SELECT COUNT(*) AS ProductCount FROM dbo.DimProduct;
SELECT COUNT(*) AS LocationCount FROM dbo.DimLocation;
SELECT COUNT(*) AS DateCount FROM dbo.DimDate;


--Load FactSales
INSERT INTO dbo.FactSales (
    OrderID,
    DateKey,
    CustomerKey,
    ProductKey,
    LocationKey,
    ShipDate,
    ShipMode,
    Sales,
    Quantity,
    Discount,
    Profit
)
SELECT
    s.[Order ID] AS OrderID,
    d.DateKey,
    c.CustomerKey,
    p.ProductKey,
    l.LocationKey,
    CAST(s.[Ship Date] AS DATE) AS ShipDate,
    s.[Ship Mode] AS ShipMode,
    CAST(s.[Sales] AS DECIMAL(18,2)) AS Sales,
    CAST(s.[Quantity] AS INT) AS Quantity,
    CAST(s.[Discount] AS DECIMAL(10,2)) AS Discount,
    CAST(s.[Profit] AS DECIMAL(18,2)) AS Profit
FROM dbo.stg_superstore_all s
JOIN dbo.DimCustomer c
    ON s.[Customer ID] = c.CustomerID
JOIN dbo.DimProduct p
    ON s.[Product ID] = p.ProductID
JOIN dbo.DimLocation l
    ON s.[Country] = l.Country
   AND s.[City] = l.City
   AND s.[State] = l.State
   AND CAST(s.[Postal Code] AS NVARCHAR(20)) = l.PostalCode
   AND s.[Region] = l.Region
JOIN dbo.DimDate d
    ON CAST(CONVERT(VARCHAR(8), s.[Order Date], 112) AS INT) = d.DateKey;

--crosschecks StagingCount = factCount
SELECT COUNT(*) AS StagingCount
FROM dbo.stg_superstore_all;

SELECT COUNT(*) AS FactCount
FROM dbo.FactSales;

SELECT COUNT(*) AS MissingLocationMatches
FROM dbo.stg_superstore_all s
LEFT JOIN dbo.DimLocation l
    ON s.[Country] = l.Country
   AND s.[City] = l.City
   AND s.[State] = l.State
   AND CAST(s.[Postal Code] AS NVARCHAR(20)) = l.PostalCode
   AND s.[Region] = l.Region
WHERE l.LocationKey IS NULL;

SELECT 
    s.[Country],
    s.[City],
    s.[State],
    s.[Postal Code],
    s.[Region]
FROM dbo.stg_superstore_all s
LEFT JOIN dbo.DimLocation l
    ON s.[Country] = l.Country
   AND s.[City] = l.City
   AND s.[State] = l.State
   AND CAST(s.[Postal Code] AS NVARCHAR(20)) = l.PostalCode
   AND s.[Region] = l.Region
WHERE l.LocationKey IS NULL;



--Preview the fact table
SELECT TOP 10 *
FROM dbo.FactSales;

SELECT COUNT(*) AS StagingCount
FROM dbo.stg_superstore_all;

SELECT COUNT(*) AS FactCount
FROM dbo.FactSales;
