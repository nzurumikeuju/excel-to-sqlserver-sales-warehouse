--Create reporting views for Power BI.
CREATE VIEW dbo.vw_SalesSummary AS
SELECT
    f.DateKey,
    d.YearNumber,
    d.MonthNumber,
    d.MonthName,
    l.Region,
    p.Category,
    SUM(f.Sales) AS TotalSales,
    SUM(f.Profit) AS TotalProfit,
    SUM(f.Quantity) AS TotalQuantity
FROM dbo.FactSales f
JOIN dbo.DimDate d
    ON f.DateKey = d.DateKey
JOIN dbo.DimLocation l
    ON f.LocationKey = l.LocationKey
JOIN dbo.DimProduct p
    ON f.ProductKey = p.ProductKey
GROUP BY
    f.DateKey,
    d.YearNumber,
    d.MonthNumber,
    d.MonthName,
    l.Region,
    p.Category;


SELECT TOP 20 *
FROM dbo.vw_ProductPerformance;

--Create Customer Performance Vew
CREATE VIEW dbo.vw_CustomerPerformance AS
SELECT
    c.CustomerID,
    c.CustomerName,
    c.Segment,
    l.Region,
    SUM(f.Sales) AS TotalSales,
    SUM(f.Profit) AS TotalProfit,
    SUM(f.Quantity) AS TotalQuantity,
    COUNT(DISTINCT f.OrderID) AS TotalOrders
FROM dbo.FactSales f
JOIN dbo.DimCustomer c
    ON f.CustomerKey = c.CustomerKey
JOIN dbo.DimLocation l
    ON f.LocationKey = l.LocationKey
GROUP BY
    c.CustomerID,
    c.CustomerName,
    c.Segment,
    l.Region;

--Create product Performance View
CREATE VIEW dbo.vw_ProductPerformance AS
SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    p.SubCategory,
    l.Region,
    SUM(f.Sales) AS TotalSales,
    SUM(f.Profit) AS TotalProfit,
    SUM(f.Quantity) AS TotalQuantity,
    AVG(f.Discount) AS AvgDiscount
FROM dbo.FactSales f
JOIN dbo.DimProduct p
    ON f.ProductKey = p.ProductKey
JOIN dbo.DimLocation l
    ON f.LocationKey = l.LocationKey
GROUP BY
    p.ProductID,
    p.ProductName,
    p.Category,
    p.SubCategory,
    l.Region;

   
