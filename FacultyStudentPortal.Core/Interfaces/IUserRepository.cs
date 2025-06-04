using System.Collections.Generic;
using System.Threading.Tasks;
using FacultyStudentPortal.Core.Models;

namespace FacultyStudentPortal.Core.Interfaces
{
    public interface IUserRepository
    {
        Task<User> GetByIdAsync(int id);
        Task<User> GetByEmailAsync(string email);
        Task<IEnumerable<User>> GetAllStudentsAsync();
        Task<IEnumerable<User>> GetAllFacultyAsync();
        Task<int> CreateAsync(User user);
        Task UpdateAsync(User user);
        Task<bool> DeleteAsync(int id);
        Task<bool> ValidateCredentialsAsync(string email, string passwordHash);
    }
} 