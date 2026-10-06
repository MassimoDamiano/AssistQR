using AssistQR.Api.Repositories.Interfaces;
using AssistQR.Api.Services.Interfaces;
using AssistQR.Api.DTOs.ClassSession;
using System.Security.Cryptography;

namespace AssistQR.Api.Services
{
    public class ClassService : IClassService
    {

        private readonly IClassSessionRepository _classRepository;
        private readonly ISubjectRepository _subjectRepository;
        public ClassService(IClassSessionRepository classRepository, ISubjectRepository subjectRepository)
        {
            _classRepository = classRepository;
            _subjectRepository = subjectRepository;
        }

        public async Task<ClassResponse> CreateAsync(CreateClassRequest request, int teacherId, CancellationToken cancellationToken)
        {
            ArgumentNullException.ThrowIfNull(request);
            if (teacherId <= 0)
            {
                throw new ArgumentOutOfRangeException(nameof(teacherId), "Teacher ID must be greater than zero.");
            }
            if (request.SubjectId <= 0)
            {
                throw new ArgumentOutOfRangeException(nameof(request.SubjectId), "Subject ID must be greater than zero.");
            }
            if (request.EndTime <= request.StartTime)
            {
                throw new ArgumentException("Class end time must be later than start time.", nameof(request.EndTime));
            }
            if (request.Latitude is < -90 or > 90)
            {
                throw new ArgumentOutOfRangeException(nameof(request.Latitude), "Latitude must be between -90 and 90 degrees.");
            }
            if (request.Longitude is < -180 or > 180)
            {
                throw new ArgumentOutOfRangeException(nameof(request.Longitude), "Longitude must be between -180 and 180 degrees.");
            }
            if (request.AllowedRadiusMeters <= 0)
            {
                throw new ArgumentOutOfRangeException(nameof(request.AllowedRadiusMeters), "Allowed radius must be greater than zero.");
            }

            var subject = await _subjectRepository.GetSubjectByIdAsync(request.SubjectId, cancellationToken);
            if (subject == null)
            {
                throw new KeyNotFoundException("Subject not found");
            }
            if (subject.TeacherId != teacherId)
            {
                throw new UnauthorizedAccessException("You are not authorized to create a class for this subject.");
            }
            if (subject.IsActive == false)
            {
                throw new InvalidOperationException("Cannot create a class for an inactive subject.");
            }

            var id = await _classRepository.CreateClassSessionAsync(request.SubjectId, request.SessionDate, request.StartTime, request.EndTime, request.Latitude, request.Longitude, request.AllowedRadiusMeters, cancellationToken);




            var response = new ClassResponse
            {
                Id = id,
                SubjectId = request.SubjectId,
                SessionDate = request.SessionDate,
                StartTime = request.StartTime,
                EndTime = request.EndTime,
                Latitude = request.Latitude,
                Longitude = request.Longitude,
                AllowedRadiusMeters = request.AllowedRadiusMeters
            };
            return response;
        }



        public async Task<IReadOnlyList<TeacherClassSummaryResponse>> GetTeacherClassSummariesAsync(int teacherId, CancellationToken cancellationToken)
        {
            if (teacherId <= 0)
            {
                throw new ArgumentOutOfRangeException(nameof(teacherId), "Teacher ID must be greater than zero.");
            }
            var classSummaries = await _classRepository.GetTeacherClassSummariesAsync(teacherId, cancellationToken);

            TeacherClassSummaryResponse[] response = classSummaries.Select(cs => new TeacherClassSummaryResponse
            {
                ClassSessionId = cs.ClassSessionId,
                SubjectId = cs.SubjectId,
                SubjectName = cs.SubjectName,
                SessionDate = cs.SessionDate,
                StartTime = cs.StartTime,
                EndTime = cs.EndTime,
                AttendanceCount = cs.AttendanceCount,
                Status = cs.Status
            }).ToArray();

            return response;
        }
    
        public async Task<QrClassResponse> CreateQrClassAsync(
            int classSessionId,
            int teacherId,
            GenerateQrRequest request,
            CancellationToken cancellationToken)
        {
            if (classSessionId <= 0)
            {
                throw new ArgumentOutOfRangeException(nameof(classSessionId), "Class session ID must be greater than zero.");
            }
            if (teacherId <= 0)
            {
                throw new ArgumentOutOfRangeException(nameof(teacherId), "Teacher ID must be greater than zero.");
            }
            ArgumentNullException.ThrowIfNull(request);
            if (request.DurationSeconds is < 1 or > 30)
            {
                throw new ArgumentOutOfRangeException(nameof(request.DurationSeconds), "QR duration must be between 1 and 30 seconds.");
            }

            var classContext = await _classRepository.GetQrClassContextAsync(classSessionId, cancellationToken);
            if (classContext is null)
            {
                throw new KeyNotFoundException("Class session not found.");
            }
            if (classContext.TeacherId != teacherId)
            {
                throw new UnauthorizedAccessException("You are not authorized to generate a QR code for this class.");
            }
            if (!classContext.SubjectIsActive)
            {
                throw new InvalidOperationException("Cannot generate a QR code for a class with an inactive subject.");
            }
            if (classContext.Status == "CLOSED")
            {
                throw new InvalidOperationException("Cannot generate a QR code for a closed class.");
            }
            if (classContext.Latitude is < -90 or > 90 ||
                classContext.Longitude is < -180 or > 180 ||
                classContext.AllowedRadiusMeters <= 0)
            {
                throw new InvalidOperationException("The class has invalid location settings.");
            }

            var qrToken = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32))
                .TrimEnd('=')
                .Replace('+', '-')
                .Replace('/', '_');
            var qrExpiresAt = DateTime.UtcNow.AddSeconds(request.DurationSeconds);

            var saved = await _classRepository.SaveQrAsync(
                classSessionId,
                teacherId,
                qrToken,
                qrExpiresAt,
                cancellationToken);
            if (!saved)
            {
                throw new InvalidOperationException("The QR code could not be saved. The class may have changed or been closed.");
            }

            return new QrClassResponse
            {
                ClassSessionId = classSessionId,
                QrToken = qrToken,
                QrExpiresAt = qrExpiresAt
            };
        }




    }
}
