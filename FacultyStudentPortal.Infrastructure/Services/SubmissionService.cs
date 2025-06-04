using System.Threading.Tasks;
using FacultyStudentPortal.Core.Interfaces;
using FacultyStudentPortal.Core.Models;

namespace FacultyStudentPortal.Infrastructure.Services
{
    public class SubmissionService : ISubmissionService
    {
        private readonly ISubmissionRepository _submissionRepository;

        public SubmissionService(ISubmissionRepository submissionRepository)
        {
            _submissionRepository = submissionRepository;
        }

        public async Task<Submission> GetSubmissionByIdAsync(int submissionId)
        {
            return await _submissionRepository.GetByIdAsync(submissionId);
        }

        public async Task<bool> IsSubmissionValidForGradingAsync(int submissionId)
        {
            var submission = await GetSubmissionByIdAsync(submissionId);
            return submission != null && !submission.IsGraded;
        }
    }
} 