--Step 1: create database Sales
create database Superstore_DW;

--step 2: import the 3 tables seperately using the import wizard
--Step 3: Check that the three tables have the same structure
SELECT TOP 10 *
FROM dbo.stg_superstore_central;

SELECT TOP 10 *
FROM dbo.stg_superstore_east;

SELECT TOP 10 *
FROM dbo.stg_superstore_west;

--Step 4: Create one combined staging table

SELECT *,
       'Central' AS SourceRegion
INTO dbo.stg_superstore_all
FROM dbo.stg_superstore_central;

--Step 5: Append East and West
INSERT INTO dbo.stg_superstore_all
SELECT *,
       'East' AS SourceRegion
FROM dbo.stg_superstore_east;

INSERT INTO dbo.stg_superstore_all
SELECT *,
       'West' AS SourceRegion
FROM dbo.stg_superstore_west;

--Step 6: Check the combined table
SELECT TOP 20 *
FROM dbo.stg_superstore_all;
