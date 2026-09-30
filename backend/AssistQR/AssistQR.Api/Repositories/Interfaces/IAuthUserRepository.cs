using AssistQR.Api.Models;

namespace AssistQR.Api.Repositories.Interfaces
{
    public interface IAuthUserRepository
    {
        Task<AuthUser?> FindByEmailAsync(string email, CancellationToken cancellationToken);
        
        Task<int?> CreateStudentAsync(string firstName, string lastName, string email, string password,CancellationToken cancellationToken);
    }
}
