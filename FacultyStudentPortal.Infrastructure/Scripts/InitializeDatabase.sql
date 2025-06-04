USE master;
GO

-- Drop database if it exists
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'FacultyStudentPortal')
BEGIN
    ALTER DATABASE FacultyStudentPortal SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FacultyStudentPortal;
END
GO

-- Create database
CREATE DATABASE FacultyStudentPortal;
GO

USE FacultyStudentPortal;
GO 