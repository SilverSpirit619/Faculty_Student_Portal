using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace FacultyStudentPortal.Core.Models
{
    public class GradeSubmissionModel
    {
        public int SubmissionId { get; set; }
        public int AssignmentId { get; set; }
        public int StudentId { get; set; }
        public int GradedByFacultyId { get; set; }
        public List<CriteriaGrade> Grades { get; set; } = new();
        public string Comments { get; set; } = string.Empty;
    }

    public class CriteriaGrade
    {
        public int CriteriaId { get; set; }
        
        [Required]
        public string CriteriaName { get; set; } = string.Empty;
        
        [Required]
        [Range(0, 100)]
        public decimal Score { get; set; }
        
        [Required]
        public decimal MaxScore { get; set; }

        public string Remarks { get; set; } = string.Empty;
    }
} 