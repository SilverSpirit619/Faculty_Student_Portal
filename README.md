# Faculty Student Portal

A full-stack web application built with .NET Core 6.0 MVC for managing faculty-student assignments and assessments.

## Features

- Faculty and Student role-based authentication
- Assignment creation and management
- File upload for assignments
- Assessment creation with multiple criteria
- Performance visualization
- Secure data access using stored procedures

## Tech Stack

- Backend: .NET Core 6.0 MVC
- Database: SQL Server
- ORM: Dapper
- Frontend: Bootstrap, jQuery, Chart.js
- Authentication: ASP.NET Core Identity

## Prerequisites

- .NET 6.0 SDK
- SQL Server 2019 or later
- Visual Studio 2022 or VS Code

## Setup Instructions

1. Clone the repository
2. Update the connection string in `appsettings.json`
3. Run the database migrations:
   ```bash
   dotnet ef database update
   ```
4. Run the application:
   ```bash
   dotnet run --project FacultyStudentPortal.Web
   ```

## Project Structure

- **FacultyStudentPortal.Core**: Contains domain models and interfaces
- **FacultyStudentPortal.Infrastructure**: Contains data access implementation
- **FacultyStudentPortal.Web**: Contains MVC controllers, views, and frontend assets
- **FacultyStudentPortal.Tests**: Contains unit tests

## Development

1. Create new stored procedures in the `Database/StoredProcedures` folder
2. Implement repository interfaces in the Infrastructure project
3. Add new controllers in the Web project
4. Add corresponding views in the Views folder

## Testing

Run the tests using:
```bash
dotnet test
``` 