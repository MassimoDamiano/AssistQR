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
            Assert.Equal(user.Email, result.Email);
            Assert.Equal(user.Role, result.Role);
        }
    }
}
