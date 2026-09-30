using AssistQR.Api.DTOs.Subjects;
using AssistQR.Api.Repositories.Interfaces;
using AssistQR.Api.Services.Interfaces;

namespace AssistQR.Api.Services
{
    public class SubjectService : ISubjectService
    {
        ISubjectRepository _subjectRepository;

        public SubjectService(ISubjectRepository subjectRepository)
        {
            _subjectRepository = subjectRepository;
        }

        public async Task<SubjectResponse> CreateAsync(CreateSubjectRequest request, int teacherId, CancellationToken cancellationToken)
        {
            if (teacherId <= 0)
            {
                throw new ArgumentOutOfRangeException( nameof(teacherId), "Teacher ID must be greater than zero.");
            }

            if (string.IsNullOrWhiteSpace(request.Name))
            {
                throw new ArgumentException("Subject name cannot be null or whitespace.", nameof(request.Name));
            }

            var id = await _subjectRepository.CreateSubjectAsync(request.Name, teacherId, request.Description,cancellationToken);

            var response = new SubjectResponse
            {
                Id = id,
                Name = request.Name,
                Description = request.Description,
                TeacherId = teacherId,
                IsActive = true
            };



            return response;
        }


        public async Task<IReadOnlyList<SubjectResponse>> GetByTeacherIdAsync(int teacherId, CancellationToken cancellationToken)
        {
            if (teacherId <= 0)
            {
                throw new ArgumentOutOfRangeException(nameof(teacherId), "Teacher ID must be greater than zero.");
            }
            var subjects = await _subjectRepository.GetByTeacherIdAsync(teacherId, cancellationToken);
            var response = subjects.Select(s => new SubjectResponse
            {
                Id = s.Id,
                Name = s.Name,
                Description = s.Description,
                TeacherId = s.TeacherId,
                IsActive = s.IsActive
            }).ToList();
            return response;
        }

    }
}
