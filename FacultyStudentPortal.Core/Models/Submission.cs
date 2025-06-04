using System;
using System.Collections.Generic;

namespace FacultyStudentPortal.Core.Models
{
    public class Submission
    {
        public int Id { get; set; }
        public int AssignmentId { get; set; }
        public int StudentId { get; set; }
        public string SubmissionFileUrl { get; set; } = string.Empty;
        public string Comments { get; set; } = string.Empty;
        public DateTime SubmittedAt { get; set; }
        public bool IsLate { get; set; }
        public bool IsGraded { get; set; }
        public string AssignmentStatus { get; set; } = string.Empty;
        public string StudentName { get; set; } = string.Empty;
        public string StudentEmail { get; set; } = string.Empty;
        public string AssignmentTitle { get; set; } = string.Empty;
        public DateTime DueDate { get; set; }
        public List<Assessment> Assessments { get; set; } = new List<Assessment>();
    }
} 