using System.Threading.Tasks;
using FacultyStudentPortal.Core.Models;

namespace FacultyStudentPortal.Core.Interfaces
{
    public interface ISubmissionService
    {
        Task<Submission> GetSubmissionByIdAsync(int submissionId);
        Task<bool> IsSubmissionValidForGradingAsync(int submissionId);
    }
} 