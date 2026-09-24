using AssistQR.Api.Models;

namespace AssistQR.Api.Repositories.Interfaces
{
    public interface IAuthUserRepository
    {
        Task<AuthUser?> FindByEmailAsync(string email, CancellationToken cancellationToken);
    }
}
