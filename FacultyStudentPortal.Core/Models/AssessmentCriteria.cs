namespace FacultyStudentPortal.Core.Models
{
    public class AssessmentCriteria
    {
        public int Id { get; set; }
        public int AssignmentId { get; set; }
        public string CriteriaName { get; set; }
        public int MaxScore { get; set; }
        public string Description { get; set; }
    }
} 