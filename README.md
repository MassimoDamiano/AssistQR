# AssistQR

AssistQR is a full-stack attendance management system that uses time-limited QR codes and geolocation validation to provide a reliable attendance workflow for educational institutions.

The platform is being developed with Flutter for the mobile application and ASP.NET Core for the REST API.

> **Project status:** Early development. The backend and database schema have been initialized. The application is not production-ready yet.

## Main Features

- Teacher and student accounts.
- JWT-based authentication and role-based authorization.
- Subject and enrollment management.
- Class session scheduling.
- Time-limited QR code generation.
- Student geolocation validation.
- Duplicate attendance prevention.
- Attendance history and class statistics.
- Unit testing for business rules.

## Technology Stack

### Frontend

- Flutter
- Dart
- Provider
- REST API consumption
- JSON serialization

### Backend

- ASP.NET Core
- C#
- RESTful controllers
- Dependency injection
- Swagger / OpenAPI
- JWT authentication
- Asynchronous programming

### Database and Tools

- MySQL
- Git
- GitHub
- Unit testing and mocks

## Application Flow

```text
Flutter UI
    -> Provider
    -> HTTP service
    -> ASP.NET Core controller
    -> Service interface
    -> Application service
    -> Repository
    -> MySQL
    -> JSON response
```

Each layer has a specific responsibility:

- **Controllers** handle HTTP requests and responses.
- **DTOs** define the data exchanged through the API.
- **Interfaces** establish contracts between components.
- **Services** contain business rules.
- **Repositories** manage data persistence.
- **Providers** manage application state in Flutter.

## Repository Structure

```text
AssistQR/
|-- backend/       ASP.NET Core REST API
|-- db/            Database scripts and schema
|-- frontend/      Flutter application (planned)
|-- docs/          Technical documentation (planned)
|-- .gitignore
`-- README.md
```

## API Conventions

- Base path: `/api/v1`
- Data format: JSON
- Authentication: Bearer JWT
- Local communication: HTTP/HTTPS
- Standard HTTP status codes

### Successful response

```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {}
}
```

### Error response

```json
{
  "success": false,
  "message": "A description of the error",
  "errors": []
}
```

Endpoint-specific documentation will be added as each feature is implemented and tested.

## Prerequisites

Install the following tools:

- .NET 10 SDK
- Git
- Visual Studio, Visual Studio Code, or JetBrains Rider

MySQL and Flutter will be required when database integration and frontend development begin.

## Running the Backend

From the repository root:

```powershell
cd backend\AssistQR
dotnet restore
dotnet run --project AssistQR.Api\AssistQR.Api.csproj
```

Swagger is available in the default development profile at:

```text
https://localhost:7059/swagger
http://localhost:5169/swagger
```

## Configuration and Secrets

Passwords, JWT signing keys, database credentials, and third-party API tokens must never be committed.

Sensitive development values should be stored using:

- ASP.NET Core User Secrets
- Environment variables
- Secure configuration provided by the deployment platform

## Development Workflow

1. Implement one small and testable change at a time.
2. Review modified files before staging them.
3. Build the affected project.
4. Run the relevant automated tests.
5. Create a clear commit.
6. Push only after verifying the change locally.

Examples of professional commit messages:

```text
chore: initialize project repository
feat(auth): add user registration endpoint
test(attendance): validate expired QR tokens
fix(classes): prevent attendance on closed sessions
docs: update local setup instructions
```

## Roadmap

- [ ] Clean the initial ASP.NET Core template.
- [ ] Define the backend project structure.
- [ ] Create the first API module.
- [ ] Add unit tests.
- [ ] Integrate MySQL persistence.
- [ ] Implement authentication and authorization.
- [ ] Implement subjects and enrollments.
- [ ] Implement class sessions and temporary QR codes.
- [ ] Implement attendance and geolocation validation.
- [ ] Add the Flutter application.
- [ ] Configure continuous integration.
- [ ] Deploy the backend and frontend.

## License

No license has been selected for this project yet.
