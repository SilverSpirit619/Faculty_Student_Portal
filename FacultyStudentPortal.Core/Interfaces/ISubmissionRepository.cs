using System.Collections.Generic;
using System.Threading.Tasks;
using FacultyStudentPortal.Core.Models;

namespace FacultyStudentPortal.Core.Interfaces
{
    public interface ISubmissionRepository
    {
        Task<Submission> GetByIdAsync(int id);
        Task<IEnumerable<Submission>> GetByAssignmentIdAsync(int assignmentId);
        Task<IEnumerable<Submission>> GetByStudentIdAsync(int studentId);
        Task<Submission> GetByAssignmentAndStudentIdAsync(int assignmentId, int studentId);
        Task<IEnumerable<Assessment>> GetAssessmentsBySubmissionIdAsync(int submissionId);
        Task<IEnumerable<Assessment>> GetAssessmentsByStudentIdAsync(int studentId);
        Task<int> CreateAsync(Submission submission);
        Task UpdateAsync(Submission submission);
        Task<bool> DeleteAsync(int id);
        Task<int> AddAssessmentAsync(Assessment assessment);
    }
} 