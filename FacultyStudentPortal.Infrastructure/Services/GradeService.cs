using System;
using System.Threading.Tasks;
using FacultyStudentPortal.Core.Interfaces;
using FacultyStudentPortal.Core.Models;

namespace FacultyStudentPortal.Infrastructure.Services
{
    public class GradeService : IGradeService
    {
        private readonly ISubmissionRepository _submissionRepository;
        private readonly ISubmissionService _submissionService;

        public GradeService(
            ISubmissionRepository submissionRepository,
            ISubmissionService submissionService)
        {
            _submissionRepository = submissionRepository;
            _submissionService = submissionService;
        }

        public async Task SubmitGrades(GradeSubmissionModel model)
        {
            var submission = await _submissionService.GetSubmissionByIdAsync(model.SubmissionId);
            if (submission == null)
            {
                throw new InvalidOperationException("Submission not found.");
            }

            if (!await _submissionService.IsSubmissionValidForGradingAsync(model.SubmissionId))
            {
                throw new InvalidOperationException("This submission cannot be graded.");
            }

            foreach (var grade in model.Grades)
            {
                var assessment = new Assessment
                {
                    SubmissionId = model.SubmissionId,
                    CriteriaId = grade.CriteriaId,
                    Score = grade.Score,
                    Remarks = grade.Remarks,
                    GradedByFacultyId = model.GradedByFacultyId,
                    GradedAt = DateTime.UtcNow
                };

                await _submissionRepository.AddAssessmentAsync(assessment);
            }

            // Update submission status
            submission.IsGraded = true;
            submission.Comments = model.Comments;
            await _submissionRepository.UpdateAsync(submission);
        }
    }
} 