using System;
using System.Collections.Generic;

namespace FacultyStudentPortal.Core.Models
{
    public class Assignment
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime DueDate { get; set; }
        public string FileUrl { get; set; } = string.Empty;
        public int CreatedByFacultyId { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsActive { get; set; }
        public string Status { get; set; } = string.Empty;
        public List<AssessmentCriteria> AssessmentCriteria { get; set; } = new List<AssessmentCriteria>();

        private static readonly TimeSpan UAEOffset = TimeSpan.FromHours(4);

        private DateTime GetUAETime(DateTime utcTime)
        {
            return utcTime.Add(UAEOffset);
        }

        private DateTime GetCurrentUAETime()
        {
            return GetUAETime(DateTime.UtcNow);
        }

        public bool IsExpired => GetCurrentUAETime() > GetUAETime(DueDate);
        
        public TimeSpan TimeRemaining => IsExpired ? TimeSpan.Zero : GetUAETime(DueDate) - GetCurrentUAETime();
        
        public string GetStatusBadgeClass() => IsExpired ? "bg-danger" : "bg-success";
        
        public string GetStatusText() => IsExpired ? "Expired" : "Active";

        public string GetFormattedDueDate()
        {
            return GetUAETime(DueDate).ToString("MMM dd, yyyy HH:mm");
        }
        
        public string GetFormattedTimeRemaining()
        {
            if (IsExpired) return "Expired";
            
            var remaining = TimeRemaining;
            return $"{remaining.Days}d {remaining.Hours}h {remaining.Minutes}m";
        }

        public string GetTimeRemainingJson()
        {
            return System.Text.Json.JsonSerializer.Serialize(new
            {
                dueDate = DueDate.ToString("O"),
                uaeOffset = UAEOffset.TotalHours,
                isExpired = IsExpired
            });
        }
    }
} 