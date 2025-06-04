using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using FacultyStudentPortal.Core.Models;
using Microsoft.AspNetCore.Http;

namespace FacultyStudentPortal.Web.ViewModels
{
    public class StudentDashboardViewModel
    {
        public List<Assignment> ActiveAssignments { get; set; } = new();
        public List<Submission> Submissions { get; set; } = new();
        public List<Assessment> Assessments { get; set; } = new();
    }

    public class SubmitAssignmentViewModel
    {
        [Required]
        public Assignment Assignment { get; set; } = null!;
        public Submission? Submission { get; set; }

        [Required(ErrorMessage = "Please select a file to submit")]
        [Display(Name = "Assignment File")]
        public IFormFile? File { get; set; }

        [Required(ErrorMessage = "Please provide comments for your submission")]
        [StringLength(1000, ErrorMessage = "Comments cannot exceed 1000 characters")]
        [Display(Name = "Comments")]
        public string Comments { get; set; } = string.Empty;
    }

    public class GradeSubmissionViewModel
    {
        public int SubmissionId { get; set; }
        public int AssignmentId { get; set; }
        public int StudentId { get; set; }
        public List<CriteriaGradeViewModel> Grades { get; set; } = new();
        public string Comments { get; set; } = string.Empty;
    }

    public class CriteriaGradeViewModel
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

    public class AssessmentViewModel
    {
        public int Id { get; set; }
        public int SubmissionId { get; set; }
        public int CriteriaId { get; set; }
        public decimal Score { get; set; }
        public decimal MaxScore { get; set; }
        public string Remarks { get; set; } = string.Empty;
        public string CriteriaName { get; set; } = string.Empty;
        public string AssignmentTitle { get; set; } = string.Empty;
        public string GraderName { get; set; } = string.Empty;
    }
} 