using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;
using FacultyStudentPortal.Core.Interfaces;
using FacultyStudentPortal.Core.Models;
using FacultyStudentPortal.Infrastructure.Data;
using Microsoft.Extensions.Configuration;

namespace FacultyStudentPortal.Infrastructure.Repositories
{
    public class SubmissionRepository : BaseRepository, ISubmissionRepository
    {
        public SubmissionRepository(IConfiguration configuration) : base(configuration)
        {
        }

        public async Task<Submission> GetByIdAsync(int id)
        {
            var submission = await QuerySingleOrDefaultAsync<Submission>("[dbo].[GetSubmissionById]",
                new { Id = id });

            if (submission != null)
            {
                submission.Assessments = (await GetAssessmentsBySubmissionIdAsync(id)).ToList();
            }

            return submission;
        }

        public async Task<IEnumerable<Submission>> GetByAssignmentIdAsync(int assignmentId)
        {
            return await QueryAsync<Submission>("[dbo].[GetSubmissionsByAssignmentId]",
                new { AssignmentId = assignmentId });
        }

        public async Task<IEnumerable<Submission>> GetByStudentIdAsync(int studentId)
        {
            return await QueryAsync<Submission>("[dbo].[GetSubmissionsByStudentId]",
                new { StudentId = studentId });
        }

        public async Task<Submission> GetByAssignmentAndStudentIdAsync(int assignmentId, int studentId)
        {
            var submission = await QuerySingleOrDefaultAsync<Submission>("[dbo].[GetSubmissionByAssignmentAndStudentId]",
                new { AssignmentId = assignmentId, StudentId = studentId });

            if (submission != null)
            {
                submission.Assessments = (await GetAssessmentsBySubmissionIdAsync(submission.Id)).ToList();
            }

            return submission;
        }

        public async Task<int> CreateAsync(Submission submission)
        {
            return await QuerySingleOrDefaultAsync<int>("[dbo].[CreateSubmission]",
                new
                {
                    submission.AssignmentId,
                    submission.StudentId,
                    submission.SubmissionFileUrl,
                    submission.Comments
                });
        }

        public async Task UpdateAsync(Submission submission)
        {
            await ExecuteAsync("[dbo].[UpdateSubmission]",
                new
                {
                    submission.Id,
                    submission.Comments,
                    submission.IsLate,
                    submission.IsGraded
                });
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var result = await ExecuteAsync("[dbo].[DeleteSubmission]",
                new { Id = id });
            return result > 0;
        }

        public async Task<IEnumerable<Assessment>> GetAssessmentsBySubmissionIdAsync(int submissionId)
        {
            return await QueryAsync<Assessment>("[dbo].[GetAssessmentsBySubmissionId]",
                new { SubmissionId = submissionId });
        }

        public async Task<IEnumerable<Assessment>> GetAssessmentsByStudentIdAsync(int studentId)
        {
            return await QueryAsync<Assessment>("[dbo].[GetAssessmentsByStudentId]",
                new { StudentId = studentId });
        }

        public async Task<int> AddAssessmentAsync(Assessment assessment)
        {
            return await QuerySingleOrDefaultAsync<int>("[dbo].[CreateAssessment]",
                new
                {
                    assessment.SubmissionId,
                    assessment.CriteriaId,
                    assessment.Score,
                    assessment.Remarks,
                    assessment.GradedByFacultyId
                });
        }
    }
} 