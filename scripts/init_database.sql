/*
==========================================
Create Database and Schemas 
==========================================
Script purpose:
    This script creates a new database named "DataWareHouse" after checking if it is already exists.
    If it exists then drop it and recreate it again. Additionally, the script sets up three schemas
    within the database: 'bronze', 'silver', 'gold'

WARNING:
    Running this script will drop the entire 'DataWareHouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution and ensure you have proper backups before running this scripts.
*/

USE master;
GO

-- Drop and recreate the "DataWareHouse" database if it already exists
IF EXISTS (SELECT 1 FROM sys.database WHERE name = "DataWareHouse")
BEGIN 
  ALTER DATABASE DataWareHouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE DataWareHouse;
END;
GO

-- Create the "DataWareHouse" Database
CREATE DATABASE DataWareHouse;

USE DataWareHouse;
GO
  
--CREATE SCHEMAS

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
