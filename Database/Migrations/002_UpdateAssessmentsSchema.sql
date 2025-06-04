-- Drop existing foreign key constraints
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Assessments_Submissions')
    ALTER TABLE Assessments DROP CONSTRAINT FK_Assessments_Submissions;
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Submissions_Assignments')
    ALTER TABLE Submissions DROP CONSTRAINT FK_Submissions_Assignments;

-- Drop existing tables in correct order
DROP TABLE IF EXISTS Assessments;
DROP TABLE IF EXISTS GradingCriteria;
DROP TABLE IF EXISTS Submissions;
DROP TABLE IF EXISTS AssessmentCriteria;
DROP TABLE IF EXISTS Assignments;

-- Create Assignments table
CREATE TABLE Assignments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    DueDate DATETIME2 NOT NULL,
    FileUrl NVARCHAR(500) NULL,
    CreatedByFacultyId INT NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    IsActive BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (CreatedByFacultyId) REFERENCES Users(Id)
);

-- Create Submissions table
CREATE TABLE Submissions (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    AssignmentId INT NOT NULL,
    StudentId INT NOT NULL,
    SubmissionFileUrl NVARCHAR(500) NOT NULL,
    Comments NVARCHAR(MAX) NULL,
    SubmittedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    IsLate BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (AssignmentId) REFERENCES Assignments(Id),
    FOREIGN KEY (StudentId) REFERENCES Users(Id)
);

-- Create AssessmentCriteria table
CREATE TABLE AssessmentCriteria (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    AssignmentId INT NOT NULL,
    CriteriaName NVARCHAR(200) NOT NULL,
    MaxScore INT NOT NULL,
    Description NVARCHAR(500) NULL,
    FOREIGN KEY (AssignmentId) REFERENCES Assignments(Id)
);

-- Create Assessments table
CREATE TABLE Assessments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SubmissionId INT NOT NULL,
    CriteriaId INT NOT NULL,
    Score INT NOT NULL,
    Remarks NVARCHAR(500) NULL,
    GradedByFacultyId INT NOT NULL,
    GradedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (SubmissionId) REFERENCES Submissions(Id),
    FOREIGN KEY (CriteriaId) REFERENCES AssessmentCriteria(Id),
    FOREIGN KEY (GradedByFacultyId) REFERENCES Users(Id)
);

-- Create or update stored procedures for assignments
CREATE OR ALTER PROCEDURE [dbo].[sp_GetAssignmentById]
    @Id INT
AS
BEGIN
    SELECT * FROM Assignments WHERE Id = @Id;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetAllAssignments]
AS
BEGIN
    SELECT * FROM Assignments WHERE IsActive = 1;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetAssignmentsByFacultyId]
    @FacultyId INT
AS
BEGIN
    SELECT * FROM Assignments 
    WHERE CreatedByFacultyId = @FacultyId AND IsActive = 1
    ORDER BY CreatedAt DESC;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetActiveAssignments]
AS
BEGIN
    SELECT * FROM Assignments 
    WHERE IsActive = 1 AND DueDate > GETUTCDATE()
    ORDER BY DueDate ASC;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_CreateAssignment]
    @Title NVARCHAR(200),
    @Description NVARCHAR(MAX),
    @DueDate DATETIME2,
    @FileUrl NVARCHAR(500),
    @CreatedByFacultyId INT
AS
BEGIN
    INSERT INTO Assignments (Title, Description, DueDate, FileUrl, CreatedByFacultyId)
    VALUES (@Title, @Description, @DueDate, @FileUrl, @CreatedByFacultyId);
    
    SELECT SCOPE_IDENTITY() AS Id;
END;
GO

-- Create or update stored procedures for submissions
CREATE OR ALTER PROCEDURE [dbo].[sp_GetSubmissionById]
    @Id INT
AS
BEGIN
    SELECT * FROM Submissions WHERE Id = @Id;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetSubmissionsByAssignmentId]
    @AssignmentId INT
AS
BEGIN
    SELECT s.*, u.FirstName + ' ' + u.LastName as StudentName
    FROM Submissions s
    INNER JOIN Users u ON s.StudentId = u.Id
    WHERE s.AssignmentId = @AssignmentId
    ORDER BY s.SubmittedAt DESC;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetSubmissionsByStudentId]
    @StudentId INT
AS
BEGIN
    SELECT s.*, a.Title as AssignmentTitle, a.DueDate
    FROM Submissions s
    INNER JOIN Assignments a ON s.AssignmentId = a.Id
    WHERE s.StudentId = @StudentId
    ORDER BY s.SubmittedAt DESC;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_CreateSubmission]
    @AssignmentId INT,
    @StudentId INT,
    @SubmissionFileUrl NVARCHAR(500),
    @Comments NVARCHAR(MAX)
AS
BEGIN
    DECLARE @IsLate BIT = 0;
    IF EXISTS (SELECT 1 FROM Assignments WHERE Id = @AssignmentId AND DueDate < GETUTCDATE())
        SET @IsLate = 1;

    INSERT INTO Submissions (AssignmentId, StudentId, SubmissionFileUrl, Comments, IsLate)
    VALUES (@AssignmentId, @StudentId, @SubmissionFileUrl, @Comments, @IsLate);
    
    SELECT SCOPE_IDENTITY() AS Id;
END;
GO

-- Create or update stored procedures for assessments
CREATE OR ALTER PROCEDURE [dbo].[sp_GetStudentAssessments]
    @StudentId INT
AS
BEGIN
    SELECT 
        a.*,
        ac.CriteriaName,
        ac.MaxScore,
        asn.Title as AssignmentTitle,
        u.FirstName + ' ' + u.LastName as GraderName
    FROM Assessments a
    INNER JOIN AssessmentCriteria ac ON a.CriteriaId = ac.Id
    INNER JOIN Submissions s ON a.SubmissionId = s.Id
    INNER JOIN Assignments asn ON s.AssignmentId = asn.Id
    INNER JOIN Users u ON a.GradedByFacultyId = u.Id
    WHERE s.StudentId = @StudentId
    ORDER BY a.GradedAt DESC;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetAssessmentsBySubmissionId]
    @SubmissionId INT
AS
BEGIN
    SELECT a.*, ac.CriteriaName, ac.MaxScore
    FROM Assessments a
    INNER JOIN AssessmentCriteria ac ON a.CriteriaId = ac.Id
    WHERE a.SubmissionId = @SubmissionId;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_CreateAssessment]
    @SubmissionId INT,
    @CriteriaId INT,
    @Score INT,
    @Remarks NVARCHAR(500),
    @GradedByFacultyId INT
AS
BEGIN
    INSERT INTO Assessments (SubmissionId, CriteriaId, Score, Remarks, GradedByFacultyId)
    VALUES (@SubmissionId, @CriteriaId, @Score, @Remarks, @GradedByFacultyId);
    
    SELECT SCOPE_IDENTITY() AS Id;
END;
GO 