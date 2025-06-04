using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using FacultyStudentPortal.Core.Interfaces;
using FacultyStudentPortal.Core.Models;
using FacultyStudentPortal.Web.ViewModels;
using System.Security.Claims;
using System.IO;
using Microsoft.AspNetCore.Hosting;
using System.Collections.Generic;
using System.Linq;

namespace FacultyStudentPortal.Web.Controllers
{
    [Authorize(Roles = "Faculty")]
    public class FacultyController : Controller
    {
        private readonly IUserRepository _userRepository;
        private readonly IAssignmentRepository _assignmentRepository;
        private readonly ISubmissionRepository _submissionRepository;
        private readonly IWebHostEnvironment _webHostEnvironment;
        private readonly ISubmissionService _submissionService;
        private readonly IGradeService _gradeService;
        private readonly IOpenAIService _openAIService;

        public FacultyController(
            IUserRepository userRepository,
            IAssignmentRepository assignmentRepository,
            ISubmissionRepository submissionRepository,
            IWebHostEnvironment webHostEnvironment,
            ISubmissionService submissionService,
            IGradeService gradeService,
            IOpenAIService openAIService)
        {
            _userRepository = userRepository;
            _assignmentRepository = assignmentRepository;
            _submissionRepository = submissionRepository;
            _webHostEnvironment = webHostEnvironment;
            _submissionService = submissionService;
            _gradeService = gradeService;
            _openAIService = openAIService;
        }

        public async Task<IActionResult> Dashboard()
        {
            var userId = int.Parse(User.FindFirst("UserId")?.Value ?? "0");
            if (userId == 0)
                return RedirectToAction("Login", "Account");

            var assignments = await _assignmentRepository.GetByFacultyIdAsync(userId);
            var students = await _userRepository.GetAllStudentsAsync();
            var allSubmissions = new List<Submission>();

            // Get submissions for each assignment
            foreach (var assignment in assignments)
            {
                var submissions = await _submissionRepository.GetByAssignmentIdAsync(assignment.Id);
                allSubmissions.AddRange(submissions);
            }

            var viewModel = new FacultyDashboardViewModel
            {
                Assignments = assignments,
                Students = students,
                Submissions = allSubmissions
            };

            return View(viewModel);
        }

        [HttpGet]
        public IActionResult CreateAssignment()
        {
            return View(new CreateAssignmentViewModel());
        }

        [HttpPost]
        public async Task<IActionResult> CreateAssignment(CreateAssignmentViewModel model)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    foreach (var error in ModelState.Values.SelectMany(v => v.Errors))
                    {
                        ModelState.AddModelError("", error.ErrorMessage);
                    }
                    return View(model);
                }

                var userId = int.Parse(User.FindFirst("UserId")?.Value ?? "0");
                if (userId == 0)
                    return RedirectToAction("Login", "Account");

                string fileUrl = null;
                if (model.File != null)
                {
                    var uploadsFolder = Path.Combine(_webHostEnvironment.WebRootPath, "uploads", "assignments");
                    if (!Directory.Exists(uploadsFolder))
                        Directory.CreateDirectory(uploadsFolder);

                    var uniqueFileName = $"{Guid.NewGuid()}_{model.File.FileName}";
                    var filePath = Path.Combine(uploadsFolder, uniqueFileName);

                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await model.File.CopyToAsync(stream);
                    }

                    fileUrl = $"/uploads/assignments/{uniqueFileName}";
                }

                // Convert the input due date (assumed to be UAE local time) to UTC before saving
                var uaeTimeZone = TimeZoneInfo.FindSystemTimeZoneById("Arabian Standard Time");
                var dueDateUtc = TimeZoneInfo.ConvertTimeToUtc(model.DueDate, uaeTimeZone);

                var assignment = new Assignment
                {
                    Title = model.Title,
                    Description = model.Description,
                    DueDate = dueDateUtc, // Store as UTC
                    FileUrl = fileUrl,
                    CreatedByFacultyId = userId,
                    IsActive = true,
                    AssessmentCriteria = model.Criteria?.Select(c => new AssessmentCriteria
                    {
                        CriteriaName = c.Name,
                        Description = c.Description,
                        MaxScore = c.MaxScore
                    }).ToList() ?? new List<AssessmentCriteria>()
                };

                var assignmentId = await _assignmentRepository.CreateAsync(assignment);

                TempData["SuccessMessage"] = "Assignment created successfully!";
                return RedirectToAction(nameof(Dashboard));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", $"Error details: {ex.Message}");
                if (ex.InnerException != null)
                {
                    ModelState.AddModelError("", $"Inner error: {ex.InnerException.Message}");
                }
                return View(model);
            }
        }

        public async Task<IActionResult> Assignment(int id)
        {
            var assignment = await _assignmentRepository.GetByIdAsync(id);
            if (assignment == null)
                return NotFound();

            var submissions = await _submissionRepository.GetByAssignmentIdAsync(id);

            // Load assessments for each submission
            foreach (var submission in submissions)
            {
                submission.Assessments = (await _submissionRepository.GetAssessmentsBySubmissionIdAsync(submission.Id)).ToList();
            }

            var viewModel = new FacultyAssignmentViewModel
            {
                Assignment = assignment,
                Submissions = submissions
            };

            return View(viewModel);
        }

        [HttpPost]
        public async Task<IActionResult> GradeSubmission([FromBody] GradeSubmissionModel model)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var userId = int.Parse(User.FindFirst("UserId")?.Value ?? "0");
                if (userId == 0)
                    return RedirectToAction("Login", "Account");

                // Set the faculty ID
                model.GradedByFacultyId = userId;

                // Validate submission exists and can be graded
                var submission = await _submissionService.GetSubmissionByIdAsync(model.SubmissionId);
                if (submission == null)
                {
                    return NotFound("Submission not found");
                }

                // Validate criteria scores
                var criteria = await _assignmentRepository.GetCriteriaByAssignmentIdAsync(model.AssignmentId);
                foreach (var grade in model.Grades)
                {
                    var criteriaItem = criteria.FirstOrDefault(c => c.Id == grade.CriteriaId);
                    if (criteriaItem == null)
                    {
                        return BadRequest($"Invalid criteria ID: {grade.CriteriaId}");
                    }

                    if (grade.Score > criteriaItem.MaxScore)
                    {
                        return BadRequest($"Score for {criteriaItem.CriteriaName} cannot exceed maximum score of {criteriaItem.MaxScore}");
                    }
                }

                // Submit grades using the grade service
                await _gradeService.SubmitGrades(model);

                return Ok(new { message = "Submission graded successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> DeleteAssignment(int id)
        {
            try
            {
                var assignment = await _assignmentRepository.GetByIdAsync(id);
                if (assignment == null)
                    return NotFound();

                // Delete assignment file if exists
                if (!string.IsNullOrEmpty(assignment.FileUrl))
                {
                    var filePath = Path.Combine(_webHostEnvironment.WebRootPath, assignment.FileUrl.TrimStart('/'));
                    if (System.IO.File.Exists(filePath))
                        System.IO.File.Delete(filePath);
                }

                // Delete the assignment (this should cascade delete criteria and submissions)
                await _assignmentRepository.DeleteAsync(id);

                return Json(new { success = true, message = "Assignment deleted successfully!" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error deleting assignment: {ex.Message}" });
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetStudentProgress(int id)
        {
            try
            {
                var student = await _userRepository.GetByIdAsync(id);
                if (student == null)
                    return NotFound("Student not found");

                var submissions = await _submissionRepository.GetByStudentIdAsync(id);
                var assessments = await _submissionRepository.GetAssessmentsByStudentIdAsync(id);

                var progress = new
                {
                    student = new
                    {
                        id = student.Id,
                        name = $"{student.FirstName} {student.LastName}"
                    },
                    submissions = submissions.Select(s => new
                    {
                        s.Id,
                        s.AssignmentTitle,
                        s.SubmittedAt,
                        s.IsLate,
                        s.IsGraded,
                        TotalScore = s.Assessments.Sum(a => a.Score),
                        MaxScore = s.Assessments.Sum(a => a.MaxScore)
                    }),
                    assessments = assessments.Select(a => new
                    {
                        a.AssignmentTitle,
                        a.CriteriaName,
                        a.Score,
                        a.MaxScore,
                        a.Remarks,
                        a.GradedAt
                    })
                };

                return Json(progress);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> GenerateDescription([FromBody] string prompt)
        {
            try
            {
                var description = await _openAIService.GenerateDescription(prompt);
                return Json(new { success = true, description });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, error = "Failed to generate description. Please try again." });
            }
        }
    }
} 