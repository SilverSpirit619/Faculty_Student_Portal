using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using FacultyStudentPortal.Web.ViewModels;

namespace FacultyStudentPortal.Web.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;

    public HomeController(ILogger<HomeController> logger)
    {
        _logger = logger;
    }

    public IActionResult Index()
    {
        if (User.Identity?.IsAuthenticated == true)
        {
            if (User.IsInRole("Faculty"))
            {
                return RedirectToAction("Dashboard", "Faculty");
            }
            else if (User.IsInRole("Student"))
            {
                return RedirectToAction("Dashboard", "Student");
            }
        }

        return View();
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
