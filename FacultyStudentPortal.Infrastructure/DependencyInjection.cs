using FacultyStudentPortal.Core.Interfaces;
using FacultyStudentPortal.Infrastructure.Repositories;
using FacultyStudentPortal.Infrastructure.Services;
using Microsoft.Extensions.DependencyInjection;

namespace FacultyStudentPortal.Infrastructure
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddInfrastructure(this IServiceCollection services)
        {
            services.AddScoped<IUserRepository, UserRepository>();
            services.AddScoped<IAssignmentRepository, AssignmentRepository>();
            services.AddScoped<ISubmissionRepository, SubmissionRepository>();
            services.AddScoped<ISubmissionService, SubmissionService>();
            services.AddScoped<IGradeService, GradeService>();

            return services;
        }
    }
} 