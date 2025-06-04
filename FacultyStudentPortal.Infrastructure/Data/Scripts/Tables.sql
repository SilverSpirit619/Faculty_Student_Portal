-- Users table
CREATE TABLE [dbo].[Users] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [FirstName] NVARCHAR(100) NOT NULL,
    [LastName] NVARCHAR(100) NOT NULL,
    [Email] NVARCHAR(256) NOT NULL UNIQUE,
    [UserName] NVARCHAR(256) NOT NULL UNIQUE,
    [PasswordHash] NVARCHAR(MAX) NOT NULL,
    [Role] NVARCHAR(50) NOT NULL
);
GO

-- Assignments table
CREATE TABLE [dbo].[Assignments] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [Title] NVARCHAR(200) NOT NULL,
    [Description] NVARCHAR(MAX) NOT NULL,
    [DueDate] DATETIME2 NOT NULL,
    [FileUrl] NVARCHAR(MAX) NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByFacultyId] INT NOT NULL,
    FOREIGN KEY ([CreatedByFacultyId]) REFERENCES [dbo].[Users] ([Id])
);
GO

-- AssessmentCriteria table
CREATE TABLE [dbo].[AssessmentCriteria] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [AssignmentId] INT NOT NULL,
    [CriteriaName] NVARCHAR(200) NOT NULL,
    [Description] NVARCHAR(MAX) NULL,
    [MaxScore] DECIMAL(5,2) NOT NULL,
    FOREIGN KEY ([AssignmentId]) REFERENCES [dbo].[Assignments] ([Id])
);
GO

-- Submissions table
CREATE TABLE [dbo].[Submissions] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [AssignmentId] INT NOT NULL,
    [StudentId] INT NOT NULL,
    [SubmissionFileUrl] NVARCHAR(MAX) NOT NULL,
    [Comments] NVARCHAR(MAX) NULL,
    [SubmittedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [IsLate] BIT NOT NULL DEFAULT 0,
    [IsGraded] BIT NOT NULL DEFAULT 0,
    FOREIGN KEY ([AssignmentId]) REFERENCES [dbo].[Assignments] ([Id]),
    FOREIGN KEY ([StudentId]) REFERENCES [dbo].[Users] ([Id])
);
GO

-- Assessments table
CREATE TABLE [dbo].[Assessments] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [SubmissionId] INT NOT NULL,
    [CriteriaId] INT NOT NULL,
    [Score] DECIMAL(5,2) NOT NULL,
    [MaxScore] DECIMAL(5,2) NOT NULL,
    [Remarks] NVARCHAR(MAX) NULL,
    [GradedByFacultyId] INT NOT NULL,
    [GradedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY ([SubmissionId]) REFERENCES [dbo].[Submissions] ([Id]),
    FOREIGN KEY ([CriteriaId]) REFERENCES [dbo].[AssessmentCriteria] ([Id]),
    FOREIGN KEY ([GradedByFacultyId]) REFERENCES [dbo].[Users] ([Id])
);
GO 