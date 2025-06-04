-- Drop existing procedure if it exists
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.GetSubmissionsByAssignmentId'))
    DROP PROCEDURE [dbo].[GetSubmissionsByAssignmentId]
GO

-- Create updated procedure
CREATE PROCEDURE [dbo].[GetSubmissionsByAssignmentId]
    @AssignmentId INT
AS
BEGIN
    SELECT 
        s.*,
        CONCAT(u.FirstName, ' ', u.LastName) AS StudentName,
        a.Title AS AssignmentTitle,
        a.DueDate
    FROM 
        dbo.Submissions s
        INNER JOIN dbo.Users u ON s.StudentId = u.Id
        INNER JOIN dbo.Assignments a ON s.AssignmentId = a.Id
    WHERE 
        s.AssignmentId = @AssignmentId
    ORDER BY 
        s.SubmittedAt DESC;
END
GO

-- Drop existing procedure if it exists
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.CreateAssessment'))
    DROP PROCEDURE [dbo].[CreateAssessment]
GO

-- Create updated assessment procedure
CREATE PROCEDURE [dbo].[CreateAssessment]
    @SubmissionId INT,
    @CriteriaId INT,
    @Score DECIMAL(5,2),
    @Remarks NVARCHAR(MAX),
    @GradedByFacultyId INT
AS
BEGIN
    DECLARE @MaxScore DECIMAL(5,2);
    
    -- Get MaxScore from AssessmentCriteria
    SELECT @MaxScore = MaxScore
    FROM dbo.AssessmentCriteria
    WHERE Id = @CriteriaId;

    -- Insert the assessment
    INSERT INTO dbo.Assessments (
        SubmissionId,
        CriteriaId,
        Score,
        MaxScore,
        Remarks,
        GradedByFacultyId,
        GradedAt
    )
    VALUES (
        @SubmissionId,
        @CriteriaId,
        @Score,
        @MaxScore,
        @Remarks,
        @GradedByFacultyId,
        GETUTCDATE()
    );

    -- Update the submission's IsGraded status
    UPDATE dbo.Submissions
    SET IsGraded = 1
    WHERE Id = @SubmissionId;

    -- Return the new assessment ID
    SELECT SCOPE_IDENTITY() AS Id;
END
GO

-- Drop existing procedure if it exists
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.GetSubmissionById'))
    DROP PROCEDURE [dbo].[GetSubmissionById]
GO

-- Create updated GetSubmissionById procedure
CREATE PROCEDURE [dbo].[GetSubmissionById]
    @Id INT
AS
BEGIN
    SELECT 
        s.*,
        CONCAT(u.FirstName, ' ', u.LastName) AS StudentName,
        a.Title AS AssignmentTitle,
        a.Description AS AssignmentDescription,
        a.DueDate AS AssignmentDueDate
    FROM 
        dbo.Submissions s
        INNER JOIN dbo.Users u ON s.StudentId = u.Id
        INNER JOIN dbo.Assignments a ON s.AssignmentId = a.Id
    WHERE 
        s.Id = @Id;
END
GO 