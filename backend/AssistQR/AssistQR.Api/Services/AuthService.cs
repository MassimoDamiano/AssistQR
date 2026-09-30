using AssistQR.Api.Services.Interfaces;
using AssistQR.Api.DTOs.Auth;
using AssistQR.Api.Models;
using AssistQR.Api.Repositories.Interfaces;
using Microsoft.AspNetCore.Identity;
using AssistQR.Api.DTOs;

namespace AssistQR.Api.Services
{
    public class AuthService : IAuthService
    {
        private readonly IAuthUserRepository repo;
        private readonly IPasswordHasher<AuthUser> passwordHasher;

        public AuthService(IAuthUserRepository repo, IPasswordHasher<AuthUser> passwordHasher)
        {
            this.repo = repo;
            this.passwordHasher = passwordHasher;
        }

        public async Task<AuthenticatedUser?> AuthenticateAsync(LoginRequest request, CancellationToken cancellationToken)
        {

            var user = await repo.FindByEmailAsync(request.Email, cancellationToken);
            if (user == null) return null;
            if (!user.IsActive) return null;

            var passwordVerificationResult = passwordHasher.VerifyHashedPassword(user, user.PasswordHash, request.Password);
            if (passwordVerificationResult == PasswordVerificationResult.Failed) return null;
            return new AuthenticatedUser { Id = user.Id, FirstName = user.FirstName, LastName = user.LastName, Email = user.Email, Role = user.Role };
        }

        public async Task<UserResponse?> RegisterStudentAsync(RegisterRequest request, CancellationToken cancellationToken)
        {
           
            var existingUser = await repo.FindByEmailAsync(request.Email, cancellationToken);
            if (existingUser != null)
            {
                return null;
            }
            var passwordHash = passwordHasher.HashPassword(null!, request.Password);

            var userId = await repo.CreateStudentAsync(request.FirstName, request.LastName, request.Email, passwordHash, cancellationToken);
            if (userId == null)
            {
                return null;
            }

            return new UserResponse { Id = userId.Value, FirstName = request.FirstName, LastName = request.LastName, Email = request.Email, Role = "STUDENT" };
        }
    }
}