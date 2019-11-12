CREATE DATABASE TestDB;
GO
CREATE LOGIN test_user WITH PASSWORD = 'test_pass123';
USE TestDB
CREATE USER test_user FOR LOGIN test_user;
EXEC sp_addrolemember 'db_owner', 'test_user';
GO