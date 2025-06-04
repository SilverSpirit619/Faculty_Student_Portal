using System.Threading.Tasks;
using FacultyStudentPortal.Core.Models;

namespace FacultyStudentPortal.Core.Interfaces
{
    public interface IGradeService
    {
        Task SubmitGrades(GradeSubmissionModel model);
    }
} 