-- Add IsGraded column to Submissions table
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[Submissions]') 
    AND name = 'IsGraded'
)
BEGIN
    ALTER TABLE [dbo].[Submissions]
    ADD [IsGraded] BIT NOT NULL DEFAULT 0;
END;
GO

-- Add MaxScore column to Assessments table
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[Assessments]') 
    AND name = 'MaxScore'
)
BEGIN
    ALTER TABLE [dbo].[Assessments]
    ADD [MaxScore] DECIMAL(5,2) NOT NULL DEFAULT 100;
END;
GO 