using System;

namespace FacultyStudentPortal.Core.Models
{
    public class Assessment
    {
        public int Id { get; set; }
        public int SubmissionId { get; set; }
        public int CriteriaId { get; set; }
        public decimal Score { get; set; }
        public decimal MaxScore { get; set; }
        public string Remarks { get; set; } = string.Empty;
        public int GradedByFacultyId { get; set; }
        public DateTime GradedAt { get; set; }
        public string CriteriaName { get; set; } = string.Empty;
        public string AssignmentTitle { get; set; } = string.Empty;
        public string GraderName { get; set; } = string.Empty;
    }
} 