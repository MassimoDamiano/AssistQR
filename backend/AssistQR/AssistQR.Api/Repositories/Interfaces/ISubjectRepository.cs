namespace AssistQR.Api.Repositories.Interfaces
{
    public interface ISubjectRepository
    {
        Task<int> CreateSubjectAsync(string name, int teacherId, string? description, CancellationToken cancellationToken);
    }
}
