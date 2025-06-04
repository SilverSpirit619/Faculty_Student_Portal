# Faculty Student Portal

A comprehensive web application built with ASP.NET Core MVC that facilitates interaction between faculty and students. The platform features OpenAI integration for automated assignment description generation, robust file management, and a user-friendly interface for academic interactions.

## 🌟 Features

### User Management
- **Role-Based Authentication**: Separate secure login systems for faculty and students
- **User Profiles**: Manage personal information and academic details
- **Access Control**: Role-specific features and permissions

### Faculty Features
- **Assignment Management**
  - Create and edit assignments
  - Set deadlines and submission requirements
  - AI-powered description generation using OpenAI
  - Define assessment criteria and rubrics
  - Bulk assignment operations

- **Grading System**
  - Grade submissions with detailed feedback
  - Apply rubric-based assessment
  - Track submission history
  - Generate performance reports

### Student Features
- **Assignment Handling**
  - View available assignments and deadlines
  - Submit assignments with file attachments
  - Track submission status
  - View grades and feedback
  - Submission history

### File Management
- **Secure File Upload**
  - Support for multiple file formats
  - Size restrictions and validation
  - Organized storage structure
  - File version control

### AI Integration
- **OpenAI-Powered Features**
  - Automatic assignment description generation
  - Smart content suggestions
  - Academic context-aware responses
  - Rate limit handling and error management

### Reporting
- **Performance Analytics**
  - Individual student progress tracking
  - Class-wide performance metrics
  - Assignment completion statistics
  - Grade distribution analysis

## 🛠️ Technologies Used

- **Backend**
  - ASP.NET Core 8.0
  - Entity Framework Core 8.0
  - SQL Server 2019+
  - OpenAI API Integration

- **Frontend**
  - Bootstrap 5
  - jQuery 3.6+
  - Modern JavaScript
  - Responsive Design

- **Security**
  - Role-based authentication
  - Secure file handling
  - API key protection
  - XSS/CSRF prevention

## 📋 Prerequisites

- .NET 8.0 SDK or later
- SQL Server 2019+ (LocalDB or higher)
- Visual Studio 2022 or VS Code with C# extension
- Node.js (for frontend package management)
- Git

## 🚀 Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/SilverSpirit619/Faculty_Student_Portal.git
   cd Faculty_Student_Portal
   ```

2. **Restore Dependencies**
   ```bash
   dotnet restore
   ```

3. **Database Setup**
   ```bash
   cd Database
   .\setup_database.bat
   ```

4. **Configure Settings**
   - Copy `appsettings.json` to `appsettings.Development.json`
   - Update the connection string
   - Add your OpenAI API key
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=FacultyStudentPortal;Trusted_Connection=True"
     },
     "OpenAI": {
       "ApiKey": "your-api-key-here",
       "Model": "gpt-3.5-turbo",
       "MaxTokens": 150,
       "Temperature": 0.7
     }
   }
   ```

5. **Run the Application**
   ```bash
   cd ../FacultyStudentPortal.Web
   dotnet run
   ```

## 🔧 Configuration

### Database Configuration
- Update connection string in `appsettings.json`
- Configure database provider in `Startup.cs`
- Run migrations: `dotnet ef database update`

### File Upload Settings
```json
{
  "FileUpload": {
    "MaxFileSize": 10485760, // 10MB
    "AllowedExtensions": [".pdf", ".doc", ".docx", ".txt"],
    "StoragePath": "wwwroot/uploads"
  }
}
```

### OpenAI Integration
- Set API key in environment variables or secure configuration
- Configure rate limiting and retry policies
- Adjust model parameters in settings

## 🏗️ Project Structure

```
Faculty_Student_Portal/
├── FacultyStudentPortal.Core/           # Domain models and interfaces
│   ├── Models/
│   └── Interfaces/
├── FacultyStudentPortal.Infrastructure/ # Data access and services
│   ├── Data/
│   ├── Repositories/
│   └── Services/
├── FacultyStudentPortal.Web/           # MVC application
│   ├── Controllers/
│   ├── Views/
│   ├── ViewModels/
│   └── wwwroot/
├── Database/                           # Database scripts and migrations
│   ├── Migrations/
│   └── StoredProcedures/
└── FacultyStudentPortal.Tests/        # Unit and integration tests
```

## 🧪 Testing

Run the test suite:
```bash
dotnet test
```

The project includes:
- Unit tests for services
- Integration tests for repositories
- Controller tests
- End-to-end tests

## 🔐 Security

- **Authentication**: ASP.NET Core Identity
- **Authorization**: Role-based access control
- **Data Protection**: 
  - Encrypted connections
  - Secure file storage
  - Input validation
  - XSS protection
- **API Security**:
  - Rate limiting
  - API key protection
  - Request validation

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. Commit your changes
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. Push to the branch
   ```bash
   git push origin feature/AmazingFeature
   ```
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support:
- Open an issue in the GitHub repository
- Contact the development team
- Check the documentation

## 🔄 Version History

- **1.0.0** (Current)
  - Initial release
  - Basic faculty and student features
  - OpenAI integration
  - File upload system

## 🙏 Acknowledgments

- OpenAI for API integration
- ASP.NET Core team
- Bootstrap contributors
- Open source community

## 📞 Contact

[@SilverSpirit619](https://github.com/SilverSpirit619)

Project Link: [https://github.com/SilverSpirit619/Faculty_Student_Portal](https://github.com/SilverSpirit619/Faculty_Student_Portal) 
