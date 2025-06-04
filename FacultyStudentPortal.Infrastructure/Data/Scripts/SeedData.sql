-- Insert test users
INSERT INTO [dbo].[Users] (FirstName, LastName, Email, UserName, PasswordHash, Role)
VALUES 
    ('John', 'Doe', 'john.doe@faculty.edu', 'john.doe', 'AQAAAAIAAYagAAAAEPxuvKQF+mxZhnyJYBNiVxWWUeOxL4lq3ckJoEK7J+vhy0GBGzKsGzELJXz+RGxQqw==', 'Faculty'),
    ('Jane', 'Smith', 'jane.smith@student.edu', 'jane.smith', 'AQAAAAIAAYagAAAAEPxuvKQF+mxZhnyJYBNiVxWWUeOxL4lq3ckJoEK7J+vhy0GBGzKsGzELJXz+RGxQqw==', 'Student');
GO

-- Insert test assignments
INSERT INTO [dbo].[Assignments] (Title, Description, DueDate, FileUrl, CreatedByFacultyId)
VALUES 
    ('Assignment 1', 'This is a test assignment', DATEADD(day, 7, GETUTCDATE()), '/uploads/assignments/test.pdf', 1),
    ('Assignment 2', 'This is another test assignment', DATEADD(day, 14, GETUTCDATE()), '/uploads/assignments/test2.pdf', 1);
GO

-- Insert test assessment criteria
INSERT INTO [dbo].[AssessmentCriteria] (AssignmentId, CriteriaName, Description, MaxScore)
VALUES 
    (1, 'Code Quality', 'Code follows best practices and is well documented', 40),
    (1, 'Functionality', 'All requirements are implemented correctly', 60),
    (2, 'Design', 'Solution design is elegant and efficient', 50),
    (2, 'Implementation', 'Implementation is complete and correct', 50);
GO 