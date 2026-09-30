using AssistQR.Api.DTOs.Auth;
using AssistQR.Api.Models;
using AssistQR.Api.DTOs;

namespace AssistQR.Api.Services.Interfaces
{
    public interface IAuthService
    {
        Task<AuthenticatedUser?> AuthenticateAsync(LoginRequest request, CancellationToken cancellationToken);

        Task<UserResponse?> RegisterStudentAsync(RegisterRequest request, CancellationToken cancellationToken);
    }
}
