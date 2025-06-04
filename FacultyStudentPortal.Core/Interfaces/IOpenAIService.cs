namespace FacultyStudentPortal.Core.Interfaces
{
    public interface IOpenAIService
    {
        Task<string> GenerateDescription(string prompt);
    }
} 