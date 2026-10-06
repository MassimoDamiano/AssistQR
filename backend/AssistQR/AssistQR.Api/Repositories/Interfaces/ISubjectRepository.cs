using AssistQR.Api.Models;

namespace AssistQR.Api.Repositories.Interfaces
{
    public interface ISubjectRepository
    {
        Task<int> CreateSubjectAsync(string name, int teacherId, string? description, CancellationToken cancellationToken);

        Task<IReadOnlyList<Subject>> GetByTeacherIdAsync(int teacherId, CancellationToken cancellationToken);

        Task<Subject?> GetSubjectByIdAsync(int subjectId, CancellationToken cancellationToken);
    }
}
