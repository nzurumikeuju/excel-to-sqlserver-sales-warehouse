-- Data Validation / ETL Quality Check 
--After loading data from multiple sources, I performed row count validation 
--to ensure completeness and integrity of the ETL process.
SELECT 'Central' AS Region, COUNT(*) AS [RowCount]
FROM dbo.stg_superstore_central
UNION ALL
SELECT 'East' AS Region, COUNT(*) AS [RowCount]
FROM dbo.stg_superstore_east
UNION ALL
SELECT 'West' AS Region, COUNT(*) AS [RowCount]
FROM dbo.stg_superstore_west
UNION ALL
SELECT 'All Regions Combined' AS Region, COUNT(*) AS [RowCount]
FROM dbo.stg_superstore_all;

--Data Cleaning & Quality Checks
--Step 1: Inspect the table structure
EXEC sp_help 'dbo.stg_superstore_all';
