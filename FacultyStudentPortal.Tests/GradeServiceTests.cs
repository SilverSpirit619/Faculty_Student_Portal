using System;
using System.Threading.Tasks;
using FacultyStudentPortal.Core.Models;
using FacultyStudentPortal.Core.Interfaces;
using FacultyStudentPortal.Infrastructure.Services;
using Moq;
using Xunit;
using System.Collections.Generic;

namespace FacultyStudentPortal.Tests
{
    public class GradeServiceTests
    {
        private readonly Mock<ISubmissionRepository> _mockSubmissionRepo;
        private readonly Mock<ISubmissionService> _mockSubmissionService;
        private readonly GradeService _service;

        public GradeServiceTests()
        {
            _mockSubmissionRepo = new Mock<ISubmissionRepository>();
            _mockSubmissionService = new Mock<ISubmissionService>();
            _service = new GradeService(_mockSubmissionRepo.Object, _mockSubmissionService.Object);
        }

        [Fact]
        public async Task SubmitGrades_ThrowsException_WhenSubmissionNotFound()
        {
            // Arrange
            var model = new GradeSubmissionModel { SubmissionId = 1 };
            _mockSubmissionService.Setup(s => s.GetSubmissionByIdAsync(1))
                .ReturnsAsync((Submission)null);

            // Act & Assert
            await Assert.ThrowsAsync<InvalidOperationException>(
                () => _service.SubmitGrades(model)
            );
        }

        [Fact]
        public async Task SubmitGrades_ThrowsException_WhenSubmissionNotValidForGrading()
        {
            // Arrange
            var model = new GradeSubmissionModel { SubmissionId = 1 };
            var submission = new Submission { Id = 1 };
            
            _mockSubmissionService.Setup(s => s.GetSubmissionByIdAsync(1))
                .ReturnsAsync(submission);
            _mockSubmissionService.Setup(s => s.IsSubmissionValidForGradingAsync(1))
                .ReturnsAsync(false);

            // Act & Assert
            await Assert.ThrowsAsync<InvalidOperationException>(
                () => _service.SubmitGrades(model)
            );
        }

        [Fact]
        public async Task SubmitGrades_CreatesAssessmentsAndUpdatesSubmission_WhenValid()
        {
            // Arrange
            var model = new GradeSubmissionModel 
            { 
                SubmissionId = 1,
                GradedByFacultyId = 1,
                Grades = new List<CriteriaGrade>
                {
                    new CriteriaGrade { CriteriaId = 1, Score = 80, MaxScore = 100 }
                }
            };

            var submission = new Submission { Id = 1, IsGraded = false };
            
            _mockSubmissionService.Setup(s => s.GetSubmissionByIdAsync(1))
                .ReturnsAsync(submission);
            _mockSubmissionService.Setup(s => s.IsSubmissionValidForGradingAsync(1))
                .ReturnsAsync(true);

            // Act
            await _service.SubmitGrades(model);

            // Assert
            _mockSubmissionRepo.Verify(r => r.AddAssessmentAsync(It.IsAny<Assessment>()), Times.Once);
            _mockSubmissionRepo.Verify(r => r.UpdateAsync(It.Is<Submission>(s => s.IsGraded)), Times.Once);
        }
    }
} 