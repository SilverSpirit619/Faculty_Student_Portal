-- Create Users table
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(256) NOT NULL UNIQUE,
    UserName NVARCHAR(256) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    Role NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    LastLogin DATETIME2 NULL,
    IsActive BIT NOT NULL DEFAULT 1
);

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

-- Create AssessmentCriteria table
CREATE TABLE AssessmentCriteria (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    AssignmentId INT NOT NULL,
    CriteriaName NVARCHAR(200) NOT NULL,
    MaxScore INT NOT NULL,
    Description NVARCHAR(500) NULL,
    FOREIGN KEY (AssignmentId) REFERENCES Assignments(Id)
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