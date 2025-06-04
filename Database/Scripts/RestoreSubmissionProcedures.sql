-- Drop existing procedures if they exist
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.GetSubmissionById'))
    DROP PROCEDURE [dbo].[GetSubmissionById]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.GetSubmissionsByAssignmentId'))
    DROP PROCEDURE [dbo].[GetSubmissionsByAssignmentId]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.GetSubmissionsByStudentId'))
    DROP PROCEDURE [dbo].[GetSubmissionsByStudentId]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.CreateSubmission'))
    DROP PROCEDURE [dbo].[CreateSubmission]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.UpdateSubmission'))
    DROP PROCEDURE [dbo].[UpdateSubmission]
GO

-- Create procedures
CREATE PROCEDURE [dbo].[GetSubmissionById]
    @SubmissionId INT
AS
BEGIN
    SELECT s.*, a.Title as AssignmentTitle, a.DueDate
    FROM Submissions s
    INNER JOIN Assignments a ON s.AssignmentId = a.Id
    WHERE s.Id = @SubmissionId;
END
GO

CREATE PROCEDURE [dbo].[GetSubmissionsByAssignmentId]
    @AssignmentId INT
AS
BEGIN
    SELECT s.*, u.FirstName, u.LastName
    FROM Submissions s
    INNER JOIN Users u ON s.StudentId = u.Id
    WHERE s.AssignmentId = @AssignmentId;
END
GO

CREATE PROCEDURE [dbo].[GetSubmissionsByStudentId]
    @StudentId INT
AS
BEGIN
    SELECT s.*, a.Title as AssignmentTitle, a.DueDate
    FROM Submissions s
    INNER JOIN Assignments a ON s.AssignmentId = a.Id
    WHERE s.StudentId = @StudentId;
END
GO

CREATE PROCEDURE [dbo].[CreateSubmission]
    @AssignmentId INT,
    @StudentId INT,
    @SubmissionFileUrl NVARCHAR(MAX),
    @Comments NVARCHAR(MAX) = NULL
AS
BEGIN
    DECLARE @DueDate DATETIME = (SELECT DueDate FROM Assignments WHERE Id = @AssignmentId);
    DECLARE @IsLate BIT = CASE WHEN GETUTCDATE() > @DueDate THEN 1 ELSE 0 END;

    INSERT INTO Submissions (AssignmentId, StudentId, SubmissionFileUrl, Comments, SubmittedAt, IsLate, IsGraded)
    VALUES (@AssignmentId, @StudentId, @SubmissionFileUrl, @Comments, GETUTCDATE(), @IsLate, 0);
    
    SELECT SCOPE_IDENTITY() AS Id;
END
GO

CREATE PROCEDURE [dbo].[UpdateSubmission]
    @Id INT,
    @IsGraded BIT
AS
BEGIN
    UPDATE Submissions
    SET IsGraded = @IsGraded
    WHERE Id = @Id;
END
GO 