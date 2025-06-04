using System;
using System.Threading.Tasks;
using FacultyStudentPortal.Core.Models;
using FacultyStudentPortal.Core.Interfaces;
using FacultyStudentPortal.Infrastructure.Services;
using Moq;
using Xunit;

namespace FacultyStudentPortal.Tests
{
    public class SubmissionServiceTests
    {
        private readonly Mock<ISubmissionRepository> _mockSubmissionRepo;
        private readonly SubmissionService _service;

        public SubmissionServiceTests()
        {
            _mockSubmissionRepo = new Mock<ISubmissionRepository>();
            _service = new SubmissionService(_mockSubmissionRepo.Object);
        }

        [Fact]
        public async Task GetSubmissionById_ReturnsSubmission_WhenExists()
        {
            // Arrange
            var expectedSubmission = new Submission { Id = 1, StudentId = 1, AssignmentId = 1 };
            _mockSubmissionRepo.Setup(repo => repo.GetByIdAsync(1))
                .ReturnsAsync(expectedSubmission);

            // Act
            var result = await _service.GetSubmissionByIdAsync(1);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(expectedSubmission.Id, result.Id);
            Assert.Equal(expectedSubmission.StudentId, result.StudentId);
        }

        [Fact]
        public async Task GetSubmissionById_ReturnsNull_WhenNotExists()
        {
            // Arrange
            _mockSubmissionRepo.Setup(repo => repo.GetByIdAsync(1))
                .ReturnsAsync((Submission)null);

            // Act
            var result = await _service.GetSubmissionByIdAsync(1);

            // Assert
            Assert.Null(result);
        }

        [Fact]
        public async Task IsSubmissionValidForGrading_ReturnsFalse_WhenSubmissionNotFound()
        {
            // Arrange
            _mockSubmissionRepo.Setup(repo => repo.GetByIdAsync(1))
                .ReturnsAsync((Submission)null);

            // Act
            var result = await _service.IsSubmissionValidForGradingAsync(1);

            // Assert
            Assert.False(result);
        }

        [Fact]
        public async Task IsSubmissionValidForGrading_ReturnsFalse_WhenAlreadyGraded()
        {
            // Arrange
            var submission = new Submission { Id = 1, IsGraded = true };
            _mockSubmissionRepo.Setup(repo => repo.GetByIdAsync(1))
                .ReturnsAsync(submission);

            // Act
            var result = await _service.IsSubmissionValidForGradingAsync(1);

            // Assert
            Assert.False(result);
        }

        [Fact]
        public async Task IsSubmissionValidForGrading_ReturnsTrue_WhenValidForGrading()
        {
            // Arrange
            var submission = new Submission { Id = 1, IsGraded = false };
            _mockSubmissionRepo.Setup(repo => repo.GetByIdAsync(1))
                .ReturnsAsync(submission);

            // Act
            var result = await _service.IsSubmissionValidForGradingAsync(1);

            // Assert
            Assert.True(result);
        }
    }
} 