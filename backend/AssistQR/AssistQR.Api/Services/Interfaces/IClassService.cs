using AssistQR.Api.DTOs.ClassSession;

namespace AssistQR.Api.Services.Interfaces
{
    public interface IClassService
    {
        Task<ClassResponse> CreateAsync(CreateClassRequest request, int teacherId, CancellationToken cancellationToken);
        
        Task<IReadOnlyList<TeacherClassSummaryResponse>> GetTeacherClassSummariesAsync(
            int teacherId,
            CancellationToken cancellationToken);

        Task<QrClassResponse> CreateQrClassAsync(
            int classSessionId,
            int teacherId,
            GenerateQrRequest request,
            CancellationToken cancellationToken);
    }
}
