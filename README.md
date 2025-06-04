# Faculty Student Portal

A web application built with .NET Core MVC that facilitates interaction between faculty and students. Faculty can create assignments, grade submissions, and view performance reports, while students can submit assignments and track their progress.

## Features

- **User Authentication**: Separate login for faculty and students
- **Assignment Management**: Faculty can create, edit, and manage assignments
- **File Submissions**: Students can submit assignments with file attachments
- **Grading System**: Faculty can grade submissions and provide comments
- **Performance Tracking**: View submission history and grades
- **File Upload**: Secure file upload system with size and type restrictions
- **Responsive Design**: Works on desktop and mobile devices

## Technologies Used

- ASP.NET Core MVC (.NET 8.0)
- Entity Framework Core 8.0
- SQL Server 2019+
- Bootstrap 5
- jQuery 3.6+

## Prerequisites

- .NET 8.0 SDK or later
- SQL Server (LocalDB or higher)
- Visual Studio 2022 or VS Code with C# extension
- Git

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/SilverSpirit619/Faculty_Student_Portal.git
   ```

2. Navigate to the project directory:
   ```bash
   cd Faculty_Student_Portal
   ```

3. Restore dependencies:
   ```bash
   dotnet restore
   ```

4. Update the database:
   ```bash
   dotnet ef database update
   ```

5. Run the application:
   ```bash
   dotnet run --project FacultyStudentPortal.Web
   ```

## Configuration

1. Database Configuration:
   - Update connection string in `appsettings.json`
   - For production, use `appsettings.Production.json`
   - Default uses SQL Server LocalDB

2. File Upload Settings:
   - Configure maximum file size
   - Set allowed file types
   - Adjust storage path
   All these can be configured in `appsettings.json`

3. Authentication:
   - Default admin credentials are in `appsettings.json`
   - Change passwords on first login
   - Configure password requirements in `Startup.cs`

## Usage

1. Access the application at `https://localhost:<port>` (The port number will be shown in the console when you run the application)
2. Register faculty and students.
3. Log in using their respective credentials.
4. Faculty Features:
   - Create and manage assignments
   - Grade student submissions
   - View student performance reports
5. Student Features:
   - View available assignments
   - Submit work with attachments
   - Track grades and feedback

## Project Structure

```
Faculty_Student_Portal/
├── FacultyStudentPortal.Core/        # Domain models and interfaces
├── FacultyStudentPortal.Infrastructure/  # Data access and services
├── FacultyStudentPortal.Web/         # MVC application
│   ├── Controllers/
│   ├── Views/
│   ├── wwwroot/
│   └── appsettings.json
└── FacultyStudentPortal.Tests/       # Unit and integration tests
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please open an issue in the GitHub repository. 
