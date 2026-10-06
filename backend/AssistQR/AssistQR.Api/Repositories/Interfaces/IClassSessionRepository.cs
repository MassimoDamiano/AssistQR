using AssistQR.Api.DTOs.ClassSession;
using AssistQR.Api.Models;

namespace AssistQR.Api.Repositories.Interfaces

{
    public interface IClassSessionRepository
    {
        Task<int> CreateClassSessionAsync(
            int subjectId,
            DateOnly sessionDate,
            TimeOnly startTime,
            TimeOnly endTime,
            decimal latitude,
            decimal longitude,
            int allowedRadiusMeters,
            CancellationToken cancellationToken);
        Task<IReadOnlyList<TeacherClassSummary>> GetTeacherClassSummariesAsync(
            int teacherId,
            CancellationToken cancellationToken);

        Task<QrClassContext?> GetQrClassContextAsync(
            int classSessionId,
            CancellationToken cancellationToken);

        Task<bool> SaveQrAsync(
            int classSessionId,
            int teacherId,
            string qrToken,
            DateTime qrExpiresAt,
            CancellationToken cancellationToken);
    }
}
