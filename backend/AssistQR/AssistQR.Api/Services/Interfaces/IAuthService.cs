using AssistQR.Api.DTOs.Auth;
using AssistQR.Api.Models;

namespace AssistQR.Api.Services.Interfaces
{
    public interface IAuthService
    {
        Task<AuthenticatedUser?> AuthenticateAsync(LoginRequest request, CancellationToken cancellationToken);
    }
}
