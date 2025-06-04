-- Get assignment by ID
CREATE OR ALTER PROCEDURE [dbo].[GetAssignmentById]
    @Id INT
AS
BEGIN
    SELECT 
        a.*,
        CASE 
            WHEN DueDate < GETUTCDATE() THEN 'Expired'
            ELSE 'Active'
        END as Status
    FROM Assignments a 
    WHERE Id = @Id;
END
GO

-- Get all assignments
CREATE OR ALTER PROCEDURE [dbo].[GetAllAssignments]
AS
BEGIN
    SELECT 
        a.*,
        CASE 
            WHEN DueDate < GETUTCDATE() THEN 'Expired'
            ELSE 'Active'
        END as Status
    FROM Assignments a 
    WHERE IsActive = 1;
END
GO

-- Get assignments by faculty ID
CREATE OR ALTER PROCEDURE [dbo].[GetAssignmentsByFacultyId]
    @FacultyId INT
AS
BEGIN
    SELECT 
        a.*,
        CASE 
            WHEN DueDate < GETUTCDATE() THEN 'Expired'
            ELSE 'Active'
        END as Status
    FROM Assignments a
    WHERE CreatedByFacultyId = @FacultyId AND IsActive = 1
    ORDER BY CreatedAt DESC;
END
GO

-- Get active assignments
CREATE OR ALTER PROCEDURE [dbo].[GetActiveAssignments]
AS
BEGIN
    SELECT 
        a.*,
        CASE 
            WHEN DueDate < GETUTCDATE() THEN 'Expired'
            ELSE 'Active'
        END as Status
    FROM Assignments a
    WHERE IsActive = 1
    ORDER BY DueDate ASC;
END
GO

-- Create assignment
CREATE OR ALTER PROCEDURE [dbo].[CreateAssignment]
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
END
GO

-- Update assignment
CREATE OR ALTER PROCEDURE [dbo].[UpdateAssignment]
    @Id INT,
    @Title NVARCHAR(200),
    @Description NVARCHAR(MAX),
    @DueDate DATETIME2,
    @FileUrl NVARCHAR(500),
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
END
GO

-- Add assessment criteria
CREATE OR ALTER PROCEDURE [dbo].[AddAssessmentCriteria]
    @AssignmentId INT,
    @CriteriaName NVARCHAR(200),
    @MaxScore INT,
    @Description NVARCHAR(500)
AS
BEGIN
    INSERT INTO AssessmentCriteria (AssignmentId, CriteriaName, MaxScore, Description)
    VALUES (@AssignmentId, @CriteriaName, @MaxScore, @Description);
    
    SELECT SCOPE_IDENTITY() AS Id;
END
GO

-- Get assessment criteria by assignment ID
CREATE OR ALTER PROCEDURE [dbo].[GetAssessmentCriteriaByAssignmentId]
    @AssignmentId INT
AS
BEGIN
    SELECT * FROM AssessmentCriteria 
    WHERE AssignmentId = @AssignmentId;
END
GO

-- Create assessment criteria
CREATE OR ALTER PROCEDURE [dbo].[CreateAssessmentCriteria]
    @AssignmentId INT,
    @CriteriaName NVARCHAR(100),
    @MaxScore INT,
    @Description NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO AssessmentCriteria (AssignmentId, CriteriaName, MaxScore, Description)
    VALUES (@AssignmentId, @CriteriaName, @MaxScore, @Description);
    
    SELECT SCOPE_IDENTITY() AS Id;
END
GO 