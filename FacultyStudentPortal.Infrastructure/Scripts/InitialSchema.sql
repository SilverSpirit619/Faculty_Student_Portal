-- Create Users table
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(256) NOT NULL UNIQUE,
    UserName NVARCHAR(256) NOT NULL,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    Role NVARCHAR(50) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- Create Assignments table
CREATE TABLE Assignments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    DueDate DATETIME2 NOT NULL,
    FileUrl NVARCHAR(MAX) NULL,
    CreatedByFacultyId INT NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (CreatedByFacultyId) REFERENCES Users(Id)
);

-- Create AssessmentCriteria table
CREATE TABLE AssessmentCriteria (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    AssignmentId INT NOT NULL,
    CriteriaName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    MaxScore INT NOT NULL,
    FOREIGN KEY (AssignmentId) REFERENCES Assignments(Id)
);

-- Create Submissions table
CREATE TABLE Submissions (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    AssignmentId INT NOT NULL,
    StudentId INT NOT NULL,
    SubmissionFileUrl NVARCHAR(MAX) NOT NULL,
    Comments NVARCHAR(MAX) NULL,
    SubmittedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    IsLate BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (AssignmentId) REFERENCES Assignments(Id),
    FOREIGN KEY (StudentId) REFERENCES Users(Id)
);

-- Create Assessments table
CREATE TABLE Assessments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SubmissionId INT NOT NULL,
    CriteriaId INT NOT NULL,
    Score INT NOT NULL,
    Remarks NVARCHAR(MAX) NULL,
    GradedByFacultyId INT NOT NULL,
    GradedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (SubmissionId) REFERENCES Submissions(Id),
    FOREIGN KEY (CriteriaId) REFERENCES AssessmentCriteria(Id),
    FOREIGN KEY (GradedByFacultyId) REFERENCES Users(Id)
);

GO

-- User stored procedures
CREATE PROCEDURE sp_GetUserById
    @Id INT
AS
BEGIN
    SELECT * FROM Users WHERE Id = @Id;
END;
GO

CREATE PROCEDURE sp_GetUserByEmail
    @Email NVARCHAR(256)
AS
BEGIN
    SELECT * FROM Users WHERE Email = @Email;
END;
GO

CREATE PROCEDURE sp_GetAllStudents
AS
BEGIN
    SELECT * FROM Users WHERE Role = 'Student' AND IsActive = 1;
END;
GO

CREATE PROCEDURE sp_GetAllFaculty
AS
BEGIN
    SELECT * FROM Users WHERE Role = 'Faculty' AND IsActive = 1;
END;
GO

CREATE PROCEDURE sp_CreateUser
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
    
    SELECT SCOPE_IDENTITY();
END;
GO

CREATE PROCEDURE sp_UpdateUser
    @Id INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(256),
    @UserName NVARCHAR(256),
    @Role NVARCHAR(50),
    @IsActive BIT
AS
BEGIN
    UPDATE Users
    SET FirstName = @FirstName,
        LastName = @LastName,
        Email = @Email,
        UserName = @UserName,
        Role = @Role,
        IsActive = @IsActive
    WHERE Id = @Id;
END;
GO

CREATE PROCEDURE sp_DeleteUser
    @Id INT
AS
BEGIN
    UPDATE Users SET IsActive = 0 WHERE Id = @Id;
END;
GO

-- Assignment stored procedures
CREATE PROCEDURE sp_GetActiveAssignments
AS
BEGIN
    SELECT a.*
    FROM Assignments a
    WHERE a.IsActive = 1 
    AND a.DueDate >= GETUTCDATE()
    ORDER BY a.DueDate ASC;
END;
GO

CREATE PROCEDURE sp_GetAssignmentById
    @Id INT
AS
BEGIN
    -- Get assignment details
    SELECT a.*, u.FirstName + ' ' + u.LastName as CreatedByName
    FROM Assignments a
    INNER JOIN Users u ON a.CreatedByFacultyId = u.Id
    WHERE a.Id = @Id;

    -- Get assessment criteria
    SELECT ac.*
    FROM AssessmentCriteria ac
    WHERE ac.AssignmentId = @Id;
END;
GO

CREATE PROCEDURE sp_GetAssignmentsByFacultyId
    @FacultyId INT
AS
BEGIN
    SELECT * FROM Assignments WHERE CreatedByFacultyId = @FacultyId AND IsActive = 1
    ORDER BY CreatedAt DESC;
END;
GO

CREATE PROCEDURE sp_CreateAssignment
    @Title NVARCHAR(200),
    @Description NVARCHAR(MAX),
    @DueDate DATETIME2,
    @FileUrl NVARCHAR(MAX),
    @CreatedByFacultyId INT
AS
BEGIN
    INSERT INTO Assignments (Title, Description, DueDate, FileUrl, CreatedByFacultyId)
    VALUES (@Title, @Description, @DueDate, @FileUrl, @CreatedByFacultyId);
    
    SELECT SCOPE_IDENTITY();
END;
GO

CREATE PROCEDURE sp_UpdateAssignment
    @Id INT,
    @Title NVARCHAR(200),
    @Description NVARCHAR(MAX),
    @DueDate DATETIME2,
    @FileUrl NVARCHAR(MAX),
    @IsActive BIT
AS
BEGIN
    UPDATE Assignments
    SET Title = @Title,
        Description = @Description,
        DueDate = @DueDate,
        FileUrl = @FileUrl,
        IsActive = @IsActive
    WHERE Id = @Id;
END;
GO

CREATE PROCEDURE sp_DeleteAssignment
    @Id INT
AS
BEGIN
    UPDATE Assignments SET IsActive = 0 WHERE Id = @Id;
END;
GO

-- Submission stored procedures
CREATE PROCEDURE sp_GetSubmissionById
    @Id INT
AS
BEGIN
    SELECT * FROM Submissions WHERE Id = @Id;
END;
GO

CREATE PROCEDURE sp_GetSubmissionsByAssignmentId
    @AssignmentId INT
AS
BEGIN
    -- Get submissions with student names
    SELECT s.*, u.FirstName + ' ' + u.LastName as StudentName
    FROM Submissions s
    INNER JOIN Users u ON s.StudentId = u.Id
    WHERE s.AssignmentId = @AssignmentId
    ORDER BY s.SubmittedAt DESC;

    -- Get assessments for each submission
    SELECT a.*, ac.CriteriaName, ac.MaxScore, s.Id as SubmissionId
    FROM Assessments a
    INNER JOIN AssessmentCriteria ac ON a.CriteriaId = ac.Id
    INNER JOIN Submissions s ON a.SubmissionId = s.Id
    WHERE s.AssignmentId = @AssignmentId;
END;
GO

CREATE PROCEDURE sp_GetSubmissionsByStudentId
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

CREATE PROCEDURE sp_CreateSubmission
    @AssignmentId INT,
    @StudentId INT,
    @SubmissionFileUrl NVARCHAR(MAX),
    @Comments NVARCHAR(MAX)
AS
BEGIN
    DECLARE @IsLate BIT = 0;
    IF EXISTS (SELECT 1 FROM Assignments WHERE Id = @AssignmentId AND DueDate < GETUTCDATE())
        SET @IsLate = 1;

    INSERT INTO Submissions (AssignmentId, StudentId, SubmissionFileUrl, Comments, IsLate)
    VALUES (@AssignmentId, @StudentId, @SubmissionFileUrl, @Comments, @IsLate);
    
    SELECT SCOPE_IDENTITY();
END;
GO

-- Assessment stored procedures
CREATE PROCEDURE sp_GetAssessmentsBySubmissionId
    @SubmissionId INT
AS
BEGIN
    SELECT a.*, ac.CriteriaName, ac.MaxScore, u.FirstName as GraderFirstName, u.LastName as GraderLastName
    FROM Assessments a
    INNER JOIN AssessmentCriteria ac ON a.CriteriaId = ac.Id
    INNER JOIN Users u ON a.GradedByFacultyId = u.Id
    WHERE a.SubmissionId = @SubmissionId;
END;
GO

CREATE PROCEDURE sp_GetStudentAssessments
    @StudentId INT
AS
BEGIN
    SELECT a.*, ac.CriteriaName, ac.MaxScore, asn.Title as AssignmentTitle
    FROM Assessments a
    INNER JOIN AssessmentCriteria ac ON a.CriteriaId = ac.Id
    INNER JOIN Submissions s ON a.SubmissionId = s.Id
    INNER JOIN Assignments asn ON s.AssignmentId = asn.Id
    WHERE s.StudentId = @StudentId
    ORDER BY a.GradedAt DESC;
END;
GO

CREATE PROCEDURE sp_CreateAssessment
    @SubmissionId INT,
    @CriteriaId INT,
    @Score INT,
    @Remarks NVARCHAR(MAX),
    @GradedByFacultyId INT
AS
BEGIN
    INSERT INTO Assessments (SubmissionId, CriteriaId, Score, Remarks, GradedByFacultyId)
    VALUES (@SubmissionId, @CriteriaId, @Score, @Remarks, @GradedByFacultyId);
    
    SELECT SCOPE_IDENTITY();
END;
GO

CREATE PROCEDURE sp_CreateAssessmentCriteria
    @AssignmentId INT,
    @CriteriaName NVARCHAR(200),
    @Description NVARCHAR(MAX),
    @MaxScore INT
AS
BEGIN
    INSERT INTO AssessmentCriteria (AssignmentId, CriteriaName, Description, MaxScore)
    VALUES (@AssignmentId, @CriteriaName, @Description, @MaxScore);
    
    SELECT SCOPE_IDENTITY();
END;
GO

CREATE PROCEDURE sp_GetAssessmentCriteriaByAssignmentId
    @AssignmentId INT
AS
BEGIN
    SELECT * FROM AssessmentCriteria 
    WHERE AssignmentId = @AssignmentId
    ORDER BY Id ASC;
END;
GO

CREATE PROCEDURE sp_CreateDefaultFacultyIfNotExists
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE Role = 'Faculty')
    BEGIN
        INSERT INTO Users (FirstName, LastName, Email, UserName, PasswordHash, Role, IsActive)
        VALUES (
            'Default',
            'Faculty',
            'faculty@example.com',
            'faculty@example.com',
            -- Password is 'Password123!'
            'YoNGNuqaHxeVhzYaXYuPgPxNEzEsTD/+6Kj8TPQZ8kI=',
            'Faculty',
            1
        );
    END;
END;
GO 