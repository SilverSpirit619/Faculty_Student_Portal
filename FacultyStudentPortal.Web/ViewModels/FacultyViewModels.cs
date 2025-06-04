using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;
using FacultyStudentPortal.Core.Models;

namespace FacultyStudentPortal.Web.ViewModels
{
    public class FacultyDashboardViewModel
    {
        public IEnumerable<Assignment> Assignments { get; set; } = new List<Assignment>();
        public IEnumerable<User> Students { get; set; } = new List<User>();
        public IEnumerable<Submission> Submissions { get; set; } = new List<Submission>();
    }

    public class CreateAssignmentViewModel
    {
        [Required]
        [Display(Name = "Title")]
        public string Title { get; set; } = string.Empty;

        [Required]
        [Display(Name = "Description")]
        public string Description { get; set; } = string.Empty;

        [Required]
        [Display(Name = "Due Date")]
        [DataType(DataType.DateTime)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-ddTHH:mm}", ApplyFormatInEditMode = true)]
        [FutureDate(ErrorMessage = "Due date must be in the future")]
        public DateTime DueDate { get; set; } = DateTime.Now.AddDays(7);

        [Display(Name = "Assignment File")]
        public IFormFile? File { get; set; }

        [Display(Name = "Assessment Criteria")]
        public List<AssessmentCriteriaViewModel> Criteria { get; set; } = new List<AssessmentCriteriaViewModel>
        {
            new AssessmentCriteriaViewModel { MaxScore = 100 }
        };
    }

    public class FutureDate : ValidationAttribute
    {
        public override bool IsValid(object? value)
        {
            if (value is DateTime dateTime)
            {
                return dateTime > DateTime.Now;
            }
            return false;
        }
    }

    public class AssessmentCriteriaViewModel
    {
        [Required]
        public string Name { get; set; } = string.Empty;

        [Required]
        [Display(Name = "Maximum Score")]
        [Range(1, 100)]
        public int MaxScore { get; set; }

        public string Description { get; set; } = string.Empty;
    }

    public class FacultyAssignmentViewModel
    {
        public required Assignment Assignment { get; set; }
        public IEnumerable<Submission> Submissions { get; set; } = new List<Submission>();

        public string GetStatusBadgeClass()
        {
            if (Assignment == null) return "bg-secondary";
            return Assignment.IsExpired ? "bg-danger" : "bg-success";
        }

        public string GetStatusText()
        {
            if (Assignment == null) return "Unknown";
            return Assignment.IsExpired ? "Expired" : "Active";
        }

        public string GetFormattedTimeRemaining()
        {
            if (Assignment == null) return "Unknown";
            var timeSpan = Assignment.DueDate - DateTime.UtcNow;
            return timeSpan.TotalSeconds <= 0 
                ? "Expired" 
                : $"{timeSpan.Days}d {timeSpan.Hours}h {timeSpan.Minutes}m";
        }
    }

    public class AssignmentDetailsViewModel
    {
        public required Assignment Assignment { get; set; }
        public IEnumerable<Submission> Submissions { get; set; } = new List<Submission>();
    }
} 