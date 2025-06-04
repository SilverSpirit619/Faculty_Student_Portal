using System.Collections.Generic;
using System.Threading.Tasks;
using FacultyStudentPortal.Core.Interfaces;
using FacultyStudentPortal.Core.Models;
using FacultyStudentPortal.Infrastructure.Data;
using Microsoft.Extensions.Configuration;

namespace FacultyStudentPortal.Infrastructure.Repositories
{
    public class AssignmentRepository : BaseRepository, IAssignmentRepository
    {
        public AssignmentRepository(IConfiguration configuration) : base(configuration)
        {
        }

        public async Task<Assignment> GetByIdAsync(int id)
        {
            var assignment = await QuerySingleOrDefaultAsync<Assignment>("[dbo].[GetAssignmentById]",
                new { Id = id });

            if (assignment != null)
            {
                assignment.AssessmentCriteria = (await GetCriteriaByAssignmentIdAsync(id)).ToList();
            }

            return assignment;
        }

        public async Task<IEnumerable<Assignment>> GetAllAsync()
        {
            return await QueryAsync<Assignment>("[dbo].[GetAllAssignments]");
        }

        public async Task<IEnumerable<Assignment>> GetByFacultyIdAsync(int facultyId)
        {
            return await QueryAsync<Assignment>("[dbo].[GetAssignmentsByFacultyId]",
                new { FacultyId = facultyId });
        }

        public async Task<IEnumerable<Assignment>> GetActiveAssignmentsAsync()
        {
            return await QueryAsync<Assignment>("[dbo].[GetActiveAssignments]");
        }

        public async Task<int> CreateAsync(Assignment assignment)
        {
            var assignmentId = await ExecuteAsync("[dbo].[CreateAssignment]",
                new
                {
                    assignment.Title,
                    assignment.Description,
                    assignment.DueDate,
                    assignment.FileUrl,
                    assignment.CreatedByFacultyId
                });

            if (assignment.AssessmentCriteria != null)
            {
                foreach (var criteria in assignment.AssessmentCriteria)
                {
                    criteria.AssignmentId = assignmentId;
                    await AddCriteriaAsync(criteria);
                }
            }

            return assignmentId;
        }

        public async Task UpdateAsync(Assignment assignment)
        {
            await ExecuteAsync("[dbo].[UpdateAssignment]",
                new
                {
                    assignment.Id,
                    assignment.Title,
                    assignment.Description,
                    assignment.DueDate,
                    assignment.FileUrl,
                    assignment.IsActive
                });
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var result = await ExecuteAsync("[dbo].[DeleteAssignment]",
                new { Id = id });
            return result > 0;
        }

        public async Task<IEnumerable<AssessmentCriteria>> GetCriteriaByAssignmentIdAsync(int assignmentId)
        {
            return await QueryAsync<AssessmentCriteria>("[dbo].[GetAssessmentCriteriaByAssignmentId]",
                new { AssignmentId = assignmentId });
        }

        public async Task<int> AddCriteriaAsync(AssessmentCriteria criteria)
        {
            return await ExecuteAsync("[dbo].[CreateAssessmentCriteria]",
                new
                {
                    criteria.AssignmentId,
                    criteria.CriteriaName,
                    criteria.Description,
                    criteria.MaxScore
                });
        }

        public async Task<bool> DeleteCriteriaAsync(int criteriaId)
        {
            var result = await ExecuteAsync("[dbo].[DeleteAssessmentCriteria]",
                new { Id = criteriaId });
            return result > 0;
        }
    }
} 