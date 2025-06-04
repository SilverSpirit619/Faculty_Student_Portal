-- Drop existing procedures if they exist
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.GetUserById'))
    DROP PROCEDURE [dbo].[GetUserById]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.GetUserByEmail'))
    DROP PROCEDURE [dbo].[GetUserByEmail]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.CreateUser'))
    DROP PROCEDURE [dbo].[CreateUser]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.UpdateUser'))
    DROP PROCEDURE [dbo].[UpdateUser]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.GetAllStudents'))
    DROP PROCEDURE [dbo].[GetAllStudents]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.GetAllFaculty'))
    DROP PROCEDURE [dbo].[GetAllFaculty]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.UpdateLastLogin'))
    DROP PROCEDURE [dbo].[UpdateLastLogin]
GO

-- Recreate all procedures
-- Get user by ID
CREATE PROCEDURE [dbo].[GetUserById]
    @Id INT
AS
BEGIN
    SELECT * FROM Users WHERE Id = @Id;
END
GO

-- Get user by email
CREATE PROCEDURE [dbo].[GetUserByEmail]
    @Email NVARCHAR(256)
AS
BEGIN
    SELECT * FROM Users WHERE Email = @Email;
END
GO

-- Create new user
CREATE PROCEDURE [dbo].[CreateUser]
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(256),
    @UserName NVARCHAR(256),
    @PasswordHash NVARCHAR(MAX),
    @Role NVARCHAR(50)
AS
BEGIN
    INSERT INTO Users (FirstName, LastName, Email, UserName, PasswordHash, Role)
    VALUES (@FirstName, @LastName, @Email, @UserName, @PasswordHash, @Role);
    
    SELECT SCOPE_IDENTITY() AS Id;
END
GO

-- Update user
CREATE PROCEDURE [dbo].[UpdateUser]
    @Id INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(256),
    @UserName NVARCHAR(256),
    @IsActive BIT
AS
BEGIN
    UPDATE Users
    SET FirstName = @FirstName,
        LastName = @LastName,
        Email = @Email,
        UserName = @UserName,
        IsActive = @IsActive
    WHERE Id = @Id;
END
GO

-- Get all students
CREATE PROCEDURE [dbo].[GetAllStudents]
AS
BEGIN
    SELECT * FROM Users WHERE Role = 'Student' AND IsActive = 1;
END
GO

-- Get all faculty
CREATE PROCEDURE [dbo].[GetAllFaculty]
AS
BEGIN
    SELECT * FROM Users WHERE Role = 'Faculty' AND IsActive = 1;
END
GO

-- Update last login
CREATE PROCEDURE [dbo].[UpdateLastLogin]
    @Id INT
AS
BEGIN
    UPDATE Users
    SET LastLogin = GETUTCDATE()
    WHERE Id = @Id;
END
GO 