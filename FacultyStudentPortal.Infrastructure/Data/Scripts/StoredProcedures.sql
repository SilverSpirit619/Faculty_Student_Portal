-- GetActiveAssignments
CREATE OR ALTER PROCEDURE [dbo].[GetActiveAssignments]
AS
BEGIN
    SELECT 
        a.*,
        u.FirstName + ' ' + u.LastName AS CreatedByName,
        (
            SELECT COUNT(*)
            FROM dbo.Submissions s
            WHERE s.AssignmentId = a.Id
        ) AS SubmissionCount,
        (
            SELECT COUNT(DISTINCT ac.Id)
            FROM dbo.AssessmentCriteria ac
            WHERE ac.AssignmentId = a.Id
        ) AS CriteriaCount
    FROM 
        dbo.Assignments a
        INNER JOIN dbo.Users u ON a.CreatedByFacultyId = u.Id
    WHERE 
        a.DueDate >= DATEADD(day, -7, GETUTCDATE())  -- Show assignments due within the last 7 days or future
    ORDER BY 
        a.DueDate ASC;
END;
GO

-- GetAssessmentsByStudentId
CREATE OR ALTER PROCEDURE [dbo].[GetAssessmentsByStudentId]
    @StudentId INT
AS
BEGIN
    SELECT 
        a.Id,
        a.SubmissionId,
        a.CriteriaId,
        a.Score,
        ac.MaxScore,
        a.Remarks,
        ac.CriteriaName,
        asn.Title AS AssignmentTitle,
        CONCAT(u.FirstName, ' ', u.LastName) AS GraderName
    FROM 
        dbo.Assessments a
        INNER JOIN dbo.Submissions s ON a.SubmissionId = s.Id
        INNER JOIN dbo.AssessmentCriteria ac ON a.CriteriaId = ac.Id
        INNER JOIN dbo.Assignments asn ON s.AssignmentId = asn.Id
        LEFT JOIN dbo.Users u ON a.GradedByFacultyId = u.Id
    WHERE 
        s.StudentId = @StudentId
    ORDER BY 
        asn.DueDate DESC;
END;
GO

-- GetSubmissionsByStudentId
CREATE OR ALTER PROCEDURE [dbo].[GetSubmissionsByStudentId]
    @StudentId INT
AS
BEGIN
    SELECT 
        s.*,
        a.Title AS AssignmentTitle,
        a.Description AS AssignmentDescription,
        a.DueDate AS AssignmentDueDate
    FROM 
        dbo.Submissions s
        INNER JOIN dbo.Assignments a ON s.AssignmentId = a.Id
    WHERE 
        s.StudentId = @StudentId
    ORDER BY 
        s.SubmittedAt DESC;
END;
GO

-- GetSubmissionById
CREATE OR ALTER PROCEDURE [dbo].[GetSubmissionById]
    @Id INT
AS
BEGIN
    SELECT 
        s.*,
        a.Title AS AssignmentTitle,
        a.Description AS AssignmentDescription,
        a.DueDate AS AssignmentDueDate
    FROM 
        dbo.Submissions s
        INNER JOIN dbo.Assignments a ON s.AssignmentId = a.Id
    WHERE 
        s.Id = @Id;
END;
GO

-- GetSubmissionByAssignmentAndStudentId
CREATE OR ALTER PROCEDURE [dbo].[GetSubmissionByAssignmentAndStudentId]
    @AssignmentId INT,
    @StudentId INT
AS
BEGIN
    SELECT 
        s.*,
        a.Title AS AssignmentTitle,
        a.Description AS AssignmentDescription,
        a.DueDate AS AssignmentDueDate
    FROM 
        dbo.Submissions s
        INNER JOIN dbo.Assignments a ON s.AssignmentId = a.Id
    WHERE 
        s.AssignmentId = @AssignmentId
        AND s.StudentId = @StudentId;
END;
GO

-- GetAssessmentsBySubmissionId
CREATE OR ALTER PROCEDURE [dbo].[GetAssessmentsBySubmissionId]
    @SubmissionId INT
AS
BEGIN
    SELECT 
        a.Id,
        a.SubmissionId,
        a.CriteriaId,
        a.Score,
        ac.MaxScore,
        a.Remarks,
        ac.CriteriaName,
        asn.Title AS AssignmentTitle,
        CONCAT(u.FirstName, ' ', u.LastName) AS GraderName
    FROM 
        dbo.Assessments a
        INNER JOIN dbo.AssessmentCriteria ac ON a.CriteriaId = ac.Id
        INNER JOIN dbo.Submissions s ON a.SubmissionId = s.Id
        INNER JOIN dbo.Assignments asn ON s.AssignmentId = asn.Id
        LEFT JOIN dbo.Users u ON a.GradedByFacultyId = u.Id
    WHERE 
        a.SubmissionId = @SubmissionId;
END;
GO

-- CreateSubmission
CREATE OR ALTER PROCEDURE [dbo].[CreateSubmission]
    @AssignmentId INT,
    @StudentId INT,
    @SubmissionFileUrl NVARCHAR(MAX),
    @Comments NVARCHAR(MAX),
    @IsLate BIT,
    @SubmittedAt DATETIME2
AS
BEGIN
    INSERT INTO dbo.Submissions (
        AssignmentId,
        StudentId,
        SubmissionFileUrl,
        Comments,
        IsLate,
        SubmittedAt
    )
    VALUES (
        @AssignmentId,
        @StudentId,
        @SubmissionFileUrl,
        @Comments,
        @IsLate,
        @SubmittedAt
    );

    SELECT SCOPE_IDENTITY();
END;
GO

-- UpdateSubmission
CREATE OR ALTER PROCEDURE [dbo].[UpdateSubmission]
    @Id INT,
    @Comments NVARCHAR(MAX),
    @IsLate BIT,
    @IsGraded BIT
AS
BEGIN
    UPDATE dbo.Submissions
    SET 
        Comments = @Comments,
        IsLate = @IsLate,
        IsGraded = @IsGraded
    WHERE 
        Id = @Id;
END;
GO

-- CreateAssessment
CREATE OR ALTER PROCEDURE [dbo].[CreateAssessment]
    @SubmissionId INT,
    @CriteriaId INT,
    @Score DECIMAL(5,2),
    @MaxScore DECIMAL(5,2),
    @Remarks NVARCHAR(MAX),
    @GradedByFacultyId INT,
    @GradedAt DATETIME2
AS
BEGIN
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
        @GradedAt
    );

    SELECT SCOPE_IDENTITY();
END;
GO

-- DeleteAssessmentCriteria
CREATE OR ALTER PROCEDURE [dbo].[DeleteAssessmentCriteria]
    @Id INT
AS
BEGIN
    DELETE FROM dbo.AssessmentCriteria
    WHERE Id = @Id;

    SELECT @@ROWCOUNT;
END;
GO

-- DeleteAssignment
CREATE OR ALTER PROCEDURE [dbo].[DeleteAssignment]
    @Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Delete all assessments for submissions of this assignment
        DELETE a
        FROM dbo.Assessments a
        INNER JOIN dbo.Submissions s ON a.SubmissionId = s.Id
        WHERE s.AssignmentId = @Id;

        -- Delete all submissions for this assignment
        DELETE FROM dbo.Submissions
        WHERE AssignmentId = @Id;

        -- Delete all assessment criteria for this assignment
        DELETE FROM dbo.AssessmentCriteria
        WHERE AssignmentId = @Id;

        -- Finally, delete the assignment
        DELETE FROM dbo.Assignments
        WHERE Id = @Id;

        COMMIT TRANSACTION;
        SELECT @@ROWCOUNT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- GetSubmissionsByAssignmentId
CREATE OR ALTER PROCEDURE [dbo].[GetSubmissionsByAssignmentId]
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
END;
GO 