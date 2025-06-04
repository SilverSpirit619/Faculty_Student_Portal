-- Drop existing foreign key constraints
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Assessments_Users')
    ALTER TABLE Assessments DROP CONSTRAINT FK_Assessments_Users;
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Submissions_Users')
    ALTER TABLE Submissions DROP CONSTRAINT FK_Submissions_Users;
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Assignments_Users')
    ALTER TABLE Assignments DROP CONSTRAINT FK_Assignments_Users;

-- Drop and recreate Users table
DROP TABLE IF EXISTS Users;

CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(256) NOT NULL UNIQUE,
    UserName NVARCHAR(256) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    Role NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    LastLogin DATETIME2 NULL,
    IsActive BIT NOT NULL DEFAULT 1
);

-- Insert default admin user
INSERT INTO Users (FirstName, LastName, Email, UserName, PasswordHash, Role, IsActive)
VALUES (
    'Admin',
    'User',
    'admin@example.com',
    'admin@example.com',
    -- Password is 'Admin123!'
    'AQAAAAIAAYagAAAAELbhHXRPsEW+KYGPt8qJeYGU7g7+dZKbBqoYIoT5tg2fZ8nGGO9hY1h0qkH+zGWxmA==',
    'Faculty',
    1
); 