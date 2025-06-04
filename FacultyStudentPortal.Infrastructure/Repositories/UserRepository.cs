using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Security.Cryptography;
using System.Text;
using FacultyStudentPortal.Core.Interfaces;
using FacultyStudentPortal.Core.Models;
using FacultyStudentPortal.Infrastructure.Data;
using Microsoft.Extensions.Configuration;

namespace FacultyStudentPortal.Infrastructure.Repositories
{
    public class UserRepository : BaseRepository, IUserRepository
    {
        public UserRepository(IConfiguration configuration) : base(configuration)
        {
        }

        public async Task<User> GetByIdAsync(int id)
        {
            return await QuerySingleOrDefaultAsync<User>("[dbo].[GetUserById]",
                new { Id = id });
        }

        public async Task<User> GetByEmailAsync(string email)
        {
            return await QuerySingleOrDefaultAsync<User>("[dbo].[GetUserByEmail]",
                new { Email = email });
        }

        public async Task<IEnumerable<User>> GetAllStudentsAsync()
        {
            return await QueryAsync<User>("[dbo].[GetAllStudents]");
        }

        public async Task<IEnumerable<User>> GetAllFacultyAsync()
        {
            return await QueryAsync<User>("[dbo].[GetAllFaculty]");
        }

        public async Task<int> CreateAsync(User user)
        {
            // Hash the password before storing
            user.PasswordHash = HashPassword(user.PasswordHash);

            return await ExecuteAsync("[dbo].[CreateUser]",
                new
                {
                    user.FirstName,
                    user.LastName,
                    user.Email,
                    user.UserName,
                    user.PasswordHash,
                    user.Role
                });
        }

        public async Task UpdateAsync(User user)
        {
            await ExecuteAsync("[dbo].[UpdateUser]",
                new
                {
                    user.Id,
                    user.FirstName,
                    user.LastName,
                    user.Email,
                    user.UserName,
                    user.Role,
                    user.IsActive
                });
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var result = await ExecuteAsync("[dbo].[DeleteUser]",
                new { Id = id });
            return result > 0;
        }

        public async Task<bool> ValidateCredentialsAsync(string email, string password)
        {
            try
            {
                var user = await GetByEmailAsync(email);
                if (user == null || !user.IsActive)
                    return false;

                var hashedPassword = HashPassword(password);
                var result = user.PasswordHash == hashedPassword;
                return result;
            }
            catch (Exception ex)
            {
                // Log the error details
                Console.WriteLine($"Error validating credentials: {ex.Message}");
                throw;
            }
        }

        private string HashPassword(string password)
        {
            using (var sha256 = SHA256.Create())
            {
                var hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                return Convert.ToBase64String(hashedBytes);
            }
        }
    }
} 