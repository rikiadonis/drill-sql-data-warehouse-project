/*
==========================================================
Create database and schemas
==========================================================
Script purpose:
  This script creates a new databse named 'DrillDataWarehouse' after checking if it already exists.
  If the database exists, it dropped and recreated. Additionally, the script sets up three schemas 
  within the databse: 'bronze', 'silver', 'gold'.

WARNING:
  Running this script will drop the entire 'DrillDataWarehouse' database if it exists.
  All data in the database will be pernamentyly deleted. Proceed with caution 
  and ensure you have proper backups before running this script.

*/

USE master;

GO
-- Drop and reactrate the 'DrillDataWarehouse' database
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DrillDataWarehouse')
BEGIN 
	ALTER DATABASE DrillDataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DrillDataWarehouse;
END;

GO
-- Create 'DrillDataWarehouse' database
CREATE DATABASE DrillDataWarehouse;

GO

USE DrillDataWarehouse;

GO
-- Create schemas: bronze, silver and gold
CREATE SCHEMA bronze;

GO

CREATE SCHEMA silver;

GO

CREATE SCHEMA gold;

