using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using FacultyStudentPortal.Core.Interfaces;
using FacultyStudentPortal.Core.Models;
using FacultyStudentPortal.Web.ViewModels;
using Microsoft.AspNetCore.Hosting;
using System.Linq;
using System.Collections.Generic;
using Microsoft.Extensions.Logging;
using System.Security.Claims;

namespace FacultyStudentPortal.Web.Controllers
{
    [Authorize(Roles = "Student")]
    public class StudentController : Controller
    {
        private readonly IUserRepository _userRepository;
        private readonly IAssignmentRepository _assignmentRepository;
        private readonly ISubmissionRepository _submissionRepository;
        private readonly IWebHostEnvironment _webHostEnvironment;
        private readonly ILogger<StudentController> _logger;

        public StudentController(
            IUserRepository userRepository,
            IAssignmentRepository assignmentRepository,
            ISubmissionRepository submissionRepository,
            IWebHostEnvironment webHostEnvironment,
            ILogger<StudentController> logger)
        {
            _userRepository = userRepository;
            _assignmentRepository = assignmentRepository;
            _submissionRepository = submissionRepository;
            _webHostEnvironment = webHostEnvironment;
            _logger = logger;
        }

        public async Task<IActionResult> Dashboard()
        {
            var userId = int.Parse(User.FindFirst("UserId")?.Value ?? "0");
            if (userId == 0)
                return RedirectToAction("Login", "Account");

            var assignments = await _assignmentRepository.GetActiveAssignmentsAsync();
            var submissions = await _submissionRepository.GetByStudentIdAsync(userId);
            var assessments = await _submissionRepository.GetAssessmentsByStudentIdAsync(userId);

            var viewModel = new StudentDashboardViewModel
            {
                ActiveAssignments = assignments.ToList(),
                Submissions = submissions.ToList(),
                Assessments = assessments.ToList()
            };

            return View(viewModel);
        }

        public async Task<IActionResult> Assignment(int id)
        {
            var assignment = await _assignmentRepository.GetByIdAsync(id);
            if (assignment == null)
                return NotFound();

            var userId = int.Parse(User.FindFirst("UserId")?.Value ?? "0");
            var submission = await _submissionRepository.GetByAssignmentAndStudentIdAsync(id, userId);

            var viewModel = new SubmitAssignmentViewModel
            {
                Assignment = assignment,
                Submission = submission
            };

            return View(viewModel);
        }

        [HttpPost]
        [RequestSizeLimit(100 * 1024 * 1024)]
        public async Task<IActionResult> SubmitAssignment(SubmitAssignmentViewModel model)
        {
            try
            {
                var userId = int.Parse(User.FindFirst("UserId")?.Value ?? "0");
                if (userId == 0)
                    return RedirectToAction("Login", "Account");

                if (!ModelState.IsValid)
                {
                    if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                    {
                        return Json(new { success = false, message = "Please select a file to submit." });
                    }
                    return View(model);
                }

                // Validate file
                if (model.File == null || model.File.Length == 0)
                {
                    ModelState.AddModelError("File", "Please select a file to submit.");
                    if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                    {
                        return Json(new { success = false, message = "Please select a file to submit." });
                    }
                    return View(model);
                }

                // Validate file size (max 100MB)
                if (model.File.Length > 100 * 1024 * 1024)
                    {
                    ModelState.AddModelError("File", "File size cannot exceed 100MB.");
                    if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                    {
                        return Json(new { success = false, message = "File size cannot exceed 100MB." });
                    }
                    return View(model);
                }

                // Validate file extension
                var allowedExtensions = new[] { ".pdf", ".doc", ".docx", ".txt", ".zip", ".rar" };
                var extension = Path.GetExtension(model.File.FileName).ToLowerInvariant();
                if (!allowedExtensions.Contains(extension))
                {
                    ModelState.AddModelError("File", "Invalid file type. Allowed types: PDF, DOC, DOCX, TXT, ZIP, RAR");
                    if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                    {
                        return Json(new { success = false, message = "Invalid file type. Allowed types: PDF, DOC, DOCX, TXT, ZIP, RAR" });
                    }
                    return View(model);
                }

                string fileUrl = null;
                if (model.File != null)
                {
                    var uploadsFolder = Path.Combine(_webHostEnvironment.WebRootPath, "uploads", "submissions");
                    if (!Directory.Exists(uploadsFolder))
                        Directory.CreateDirectory(uploadsFolder);

                    var uniqueFileName = $"{Guid.NewGuid()}_{model.File.FileName}";
                    var filePath = Path.Combine(uploadsFolder, uniqueFileName);

                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await model.File.CopyToAsync(stream);
                    }

                    fileUrl = $"/uploads/submissions/{uniqueFileName}";
                }

                var uaeTimeZone = TimeZoneInfo.FindSystemTimeZoneById("Arabian Standard Time");
                var nowUae = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, uaeTimeZone);
                var dueDateUae = TimeZoneInfo.ConvertTimeFromUtc(model.Assignment.DueDate, uaeTimeZone);

                var submission = new Submission
                {
                    AssignmentId = model.Assignment.Id,
                    StudentId = userId,
                    SubmissionFileUrl = fileUrl ?? string.Empty,
                    Comments = model.Comments ?? string.Empty,
                    SubmittedAt = DateTime.UtcNow,
                    IsLate = nowUae > dueDateUae
                };

                await _submissionRepository.CreateAsync(submission);

                if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                {
                    return Json(new { success = true, message = "Assignment submitted successfully!" });
                }

                TempData["SuccessMessage"] = "Assignment submitted successfully!";
                return RedirectToAction(nameof(Dashboard));
            }
            catch (Exception ex)
            {
                if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                {
                    return Json(new { success = false, message = "Error submitting assignment: " + ex.Message });
                }
                ModelState.AddModelError("", $"Error submitting assignment: {ex.Message}");
                return View(model);
            }
        }
    }
} 