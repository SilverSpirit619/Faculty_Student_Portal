using System.Collections.Generic;
using System.Threading.Tasks;
using FacultyStudentPortal.Core.Models;

namespace FacultyStudentPortal.Core.Interfaces
{
    public interface IAssignmentRepository
    {
        Task<Assignment> GetByIdAsync(int id);
        Task<IEnumerable<Assignment>> GetByFacultyIdAsync(int facultyId);
        Task<IEnumerable<Assignment>> GetActiveAssignmentsAsync();
        Task<int> CreateAsync(Assignment assignment);
        Task UpdateAsync(Assignment assignment);
        Task<bool> DeleteAsync(int id);
        Task<IEnumerable<AssessmentCriteria>> GetCriteriaByAssignmentIdAsync(int assignmentId);
        Task<int> AddCriteriaAsync(AssessmentCriteria criteria);
        Task<bool> DeleteCriteriaAsync(int criteriaId);
    }
} 