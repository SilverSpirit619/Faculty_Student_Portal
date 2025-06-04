@echo off
echo Setting up Faculty Student Portal Database...

sqlcmd -S "(localdb)\mssqllocaldb" -Q "IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'FacultyStudentPortal') CREATE DATABASE FacultyStudentPortal;"
sqlcmd -S "(localdb)\mssqllocaldb" -d FacultyStudentPortal -i Schema\initial_schema.sql
sqlcmd -S "(localdb)\mssqllocaldb" -d FacultyStudentPortal -i StoredProcedures\User_Procedures.sql
sqlcmd -S "(localdb)\mssqllocaldb" -d FacultyStudentPortal -i StoredProcedures\Assignment_Procedures.sql
sqlcmd -S "(localdb)\mssqllocaldb" -d FacultyStudentPortal -i StoredProcedures\Submission_Procedures.sql

echo Database setup completed! 