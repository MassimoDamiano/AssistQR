using AssistQR.Api.Services.Interfaces;
using AssistQR.Api.DTOs.Auth;
using AssistQR.Api.Models;
using AssistQR.Api.Repositories.Interfaces;
using Microsoft.AspNetCore.Identity;

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
            return new AuthenticatedUser { Id = user.Id, Email = user.Email, Role = user.Role };
        }
    }
}