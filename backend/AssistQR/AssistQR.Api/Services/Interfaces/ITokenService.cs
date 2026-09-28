using AssistQR.Api.DTOs;
using AssistQR.Api.Models;

namespace AssistQR.Api.Services.Interfaces
{
    public interface ITokenService
    {
        LoginResponse CreateToken(AuthenticatedUser user);

    }
}
