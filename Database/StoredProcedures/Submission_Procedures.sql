-- Get submission by ID
CREATE OR ALTER PROCEDURE [dbo].[GetSubmissionById]
    @Id INT
AS
BEGIN
    SELECT s.*, 
           CASE 
               WHEN a.DueDate < GETUTCDATE() THEN 'Expired'
               ELSE 'Active'
           END as AssignmentStatus
    FROM Submissions s
    INNER JOIN Assignments a ON s.AssignmentId = a.Id
    WHERE s.Id = @Id;
END
GO

-- Get submissions by assignment ID
CREATE OR ALTER PROCEDURE [dbo].[GetSubmissionsByAssignmentId]
    @AssignmentId INT
AS
BEGIN
    SELECT 
        s.Id,
        s.AssignmentId,
        s.StudentId,
        s.SubmissionFileUrl,
        s.Comments,
        s.SubmittedAt,
        s.IsLate,
        s.IsGraded,
        CASE 
            WHEN a.DueDate < GETUTCDATE() THEN 'Expired'
            ELSE 'Active'
        END as AssignmentStatus,
        COALESCE(NULLIF(RTRIM(CONCAT(COALESCE(u.FirstName, ''), ' ', COALESCE(u.LastName, ''))), ' '), u.Email) as StudentName,
        u.Email as StudentEmail,
        a.Title as AssignmentTitle,
        a.DueDate
    FROM Submissions s
    INNER JOIN Users u ON s.StudentId = u.Id
    INNER JOIN Assignments a ON s.AssignmentId = a.Id
    WHERE s.AssignmentId = @AssignmentId
    ORDER BY s.SubmittedAt DESC;
END
GO

-- Get submissions by student ID
CREATE OR ALTER PROCEDURE [dbo].[GetSubmissionsByStudentId]
    @StudentId INT
AS
BEGIN
    SELECT s.*, 
           a.Title as AssignmentTitle, 
           a.DueDate,
           CASE 
               WHEN a.DueDate < GETUTCDATE() THEN 'Expired'
               ELSE 'Active'
           END as AssignmentStatus
    FROM Submissions s
    INNER JOIN Assignments a ON s.AssignmentId = a.Id
    WHERE s.StudentId = @StudentId
    ORDER BY s.SubmittedAt DESC;
END
GO

-- Create submission
CREATE OR ALTER PROCEDURE [dbo].[CreateSubmission]
    @AssignmentId INT,
    @StudentId INT,
    @SubmissionFileUrl NVARCHAR(500),
    @Comments NVARCHAR(MAX)
AS
BEGIN
    DECLARE @DueDate DATETIME2;
    SELECT @DueDate = DueDate FROM Assignments WHERE Id = @AssignmentId;

    IF @DueDate < GETUTCDATE()
    BEGIN
        RAISERROR('Cannot submit after due date', 16, 1);
        RETURN;
    END

    INSERT INTO Submissions (AssignmentId, StudentId, SubmissionFileUrl, Comments, IsLate)
    VALUES (@AssignmentId, @StudentId, @SubmissionFileUrl, @Comments, 0);
    
    SELECT SCOPE_IDENTITY() AS Id;
END
GO

-- Update submission
CREATE PROCEDURE [dbo].[UpdateSubmission]
    @Id INT,
    @SubmissionFileUrl NVARCHAR(500),
    @Comments NVARCHAR(MAX)
AS
BEGIN
    UPDATE Submissions
    SET SubmissionFileUrl = @SubmissionFileUrl,
        Comments = @Comments
    WHERE Id = @Id;
END
GO

-- Get assessments by submission ID
CREATE OR ALTER PROCEDURE [dbo].[GetAssessmentsBySubmissionId]
    @SubmissionId INT
AS
BEGIN
    SELECT a.*, ac.CriteriaName, ac.MaxScore
    FROM Assessments a
    INNER JOIN AssessmentCriteria ac ON a.CriteriaId = ac.Id
    WHERE a.SubmissionId = @SubmissionId;
END
GO

-- Get student assessments
CREATE OR ALTER PROCEDURE [dbo].[GetStudentAssessments]
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
END
GO

-- Create assessment
CREATE OR ALTER PROCEDURE [dbo].[CreateAssessment]
    @SubmissionId INT,
    @CriteriaId INT,
    @Score INT,
    @Remarks NVARCHAR(500),
    @GradedByFacultyId INT
AS
BEGIN
    -- Check if assessment already exists for this criteria and submission
    IF EXISTS (SELECT 1 FROM Assessments WHERE SubmissionId = @SubmissionId AND CriteriaId = @CriteriaId)
    BEGIN
        -- Update existing assessment
        UPDATE Assessments
        SET Score = @Score,
            Remarks = @Remarks,
            GradedByFacultyId = @GradedByFacultyId,
            GradedAt = GETUTCDATE()
        WHERE SubmissionId = @SubmissionId AND CriteriaId = @CriteriaId;
        
        SELECT Id FROM Assessments WHERE SubmissionId = @SubmissionId AND CriteriaId = @CriteriaId;
    END
    ELSE
    BEGIN
        -- Create new assessment
        INSERT INTO Assessments (SubmissionId, CriteriaId, Score, Remarks, GradedByFacultyId)
        VALUES (@SubmissionId, @CriteriaId, @Score, @Remarks, @GradedByFacultyId);
        
        SELECT SCOPE_IDENTITY() AS Id;
    END
END
GO 