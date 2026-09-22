using AssistQR.Api.DTOs.Subjects;
using System.Threading;
using System.Threading.Tasks;

namespace AssistQR.Api.Services.Interfaces
{
    public interface ISubjectService
    {
        Task<SubjectResponse> CreateAsync(CreateSubjectRequest request, int teacherId, CancellationToken cancellationToken);
            
    }
}
