using AssistQR.Api.DTOs.Auth;
using AssistQR.Api.Models;
using AssistQR.Api.Repositories.Interfaces;
using AssistQR.Api.Services;


namespace AssistQR.Api.Tests.Services
{
    public class AuthServiceTest
    {

        private sealed class FakeAuthUserRepository : IAuthUserRepository
        {
            private readonly AuthUser? authUser;

            public FakeAuthUserRepository(AuthUser? authUser)
            {
                this.authUser = authUser;
            }

            public Task<AuthUser?> FindByEmailAsync(
                string email,
                CancellationToken cancellationToken)
            {
                return Task.FromResult<AuthUser?>(authUser);
            }
            public Task<int?> CreateStudentAsync(
                string firstName,
                string lastName,
                string email,
                string passwordHash,
                CancellationToken cancellationToken)
            {
                return Task.FromResult<int?>(42);
            }
        }

        [Fact]

        public async Task AuthenticateAsync_WhenUserDoesNotExist_ReturnsNull()
        {
            // Arrange

            IAuthUserRepository authUserRepository = new FakeAuthUserRepository(null);
            var passwordHasher = new Microsoft.AspNetCore.Identity.PasswordHasher<AuthUser>();
            AuthService authService = new AuthService(authUserRepository, passwordHasher);
            LoginRequest loginRequest = new LoginRequest("sda@gmail.com", "password");

            // Act
            var result = await authService.AuthenticateAsync(loginRequest, CancellationToken.None);

            // Assert
            Assert.Null(result);
        }

        [Fact]
        public async Task AuthenticateAsync_WhenUserIsInactive_ReturnsNull()
        {
            // Arrange
            const string password = "test-password";
            var user = new AuthUser(
                id: 1,
                firstName: "Test",
                lastName: "User",
                email: "inactive@example.com",
                passwordHash: string.Empty,
                role: "STUDENT",
                isActive: false);

            var passwordHasher = new Microsoft.AspNetCore.Identity.PasswordHasher<AuthUser>();
            user.PasswordHash = passwordHasher.HashPassword(user, password);

            IAuthUserRepository authUserRepository = new FakeAuthUserRepository(user);
            AuthService authService = new AuthService(authUserRepository, passwordHasher);
            LoginRequest loginRequest = new LoginRequest(user.Email, password);

            // Act
            var result = await authService.AuthenticateAsync(loginRequest, CancellationToken.None);

            // Assert
            Assert.Null(result);
        }
        [Fact]
        public async Task AuthenticateAsync_WhenPasswordIsIncorrect_ReturnsNull()
        {
            // Arrange
            const string correctPassword = "correct-password";
            const string incorrectPassword = "incorrect-password";
            var user = new AuthUser(
                id: 1,
                firstName: "Test",
                lastName: "User",
                email: "test@example.com",
                passwordHash: string.Empty,
                role: "STUDENT",
                isActive: true);

            var passwordHasher = new Microsoft.AspNetCore.Identity.PasswordHasher<AuthUser>();
            user.PasswordHash = passwordHasher.HashPassword(user, correctPassword);

            IAuthUserRepository authUserRepository = new FakeAuthUserRepository(user);
            AuthService authService = new AuthService(authUserRepository, passwordHasher);
            LoginRequest loginRequest = new LoginRequest(user.Email, incorrectPassword);

            // Act
            var result = await authService.AuthenticateAsync(loginRequest, CancellationToken.None);

            // Assert
            Assert.Null(result);
        }
        [Fact]
        public async Task AuthenticateAsync_WhenCredentialsAreValid_ReturnsAuthenticatedUser()
        {
            // Arrange
            const string password = "valid-password";
            var user = new AuthUser(
                id: 1,
                firstName: "Test",
                lastName: "User",
                email: "test@example.com",
                passwordHash: string.Empty,
                role: "STUDENT",
                isActive: true);

            var passwordHasher = new Microsoft.AspNetCore.Identity.PasswordHasher<AuthUser>();
            user.PasswordHash = passwordHasher.HashPassword(user, password);

            IAuthUserRepository authUserRepository = new FakeAuthUserRepository(user);
            AuthService authService = new AuthService(authUserRepository, passwordHasher);
            LoginRequest loginRequest = new LoginRequest(user.Email, password);

            // Act
            var result = await authService.AuthenticateAsync(loginRequest, CancellationToken.None);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(user.Id, result.Id);
            Assert.Equal(user.FirstName, result.FirstName);
            Assert.Equal(user.LastName, result.LastName);
            Assert.Equal(user.Email, result.Email);
            Assert.Equal(user.Role, result.Role);
        }

        [Fact]
        public async Task RegisterStudentAsync_WhenEmailIsAvailable_CreatesStudentAndReturnsUser()
        {
            // Arrange: el correo no pertenece a ninguna cuenta.
            var repository = new FakeAuthUserRepository(null);
            var passwordHasher =
                new Microsoft.AspNetCore.Identity.PasswordHasher<AuthUser>();

            var service = new AuthService(repository, passwordHasher);

            var request = new RegisterRequest(
                "Ana",
                "Perez",
                "ana@example.com",
                "valid-password");

            // Act: el servicio genera el hash y solicita guardar al alumno.
            var result = await service.RegisterStudentAsync(
                request,
                CancellationToken.None);

            // Assert: devuelve el ID del repositorio y los datos esperados.
            Assert.NotNull(result);
            Assert.Equal(42, result.Id);
            Assert.Equal(request.FirstName, result.FirstName);
            Assert.Equal(request.LastName, result.LastName);
            Assert.Equal(request.Email, result.Email);
            Assert.Equal("STUDENT", result.Role);
        }

        [Fact]
        public async Task RegisterStudentAsync_WhenEmailAlreadyExists_ReturnsNull()
        {
            // Arrange: el correo ya pertenece a una cuenta.
            var existingUser = new AuthUser(
                id: 1,
                firstName: "Existing",
                lastName: "User",
                email: "existing@example.com"
                , passwordHash: string.Empty,
                role: "STUDENT",
                isActive: true
            );
            var repository = new FakeAuthUserRepository(existingUser);
            var passwordHasher = new Microsoft.AspNetCore.Identity.PasswordHasher<AuthUser>();
            var service = new AuthService(repository, passwordHasher);

            var request = new RegisterRequest(
                "Ana",
                "Perez",
                "existing@example.com",
                "valid-password"
            );

            // Act & Assert
            Assert.Null(await service.RegisterStudentAsync(request, CancellationToken.None));
        }
    }
}
