using AssistQR.Api.DTOs.ClassSession;
using AssistQR.Api.Models;
using AssistQR.Api.Repositories.Interfaces;
using AssistQR.Api.Services;

namespace AssistQR.Api.Tests.Services;

public class ClassServiceTests
{
    [Fact]
    public async Task GetTeacherClassSummariesAsync_WhenRepositoryReturnsSummaries_MapsResultsToResponse()
    {
        var repositorySummaries = new List<TeacherClassSummary>
        {
            new()
            {
                ClassSessionId = 4,
                SubjectId = 5,
                SubjectName = "Programming I",
                SessionDate = new DateOnly(2026, 10, 5),
                StartTime = new TimeOnly(18, 0),
                EndTime = new TimeOnly(19, 20),
                AttendanceCount = 8,
                Status = "CLOSED"
            }
        };
        var sessions = new FakeSessionRepository(repositorySummaries);
        var service = new ClassService(sessions, new FakeSubjectRepository(null));

        var result = await service.GetTeacherClassSummariesAsync(12, CancellationToken.None);

        var summary = Assert.Single(result);
        Assert.Equal(12, sessions.RequestedTeacherId);
        Assert.Equal(4, summary.ClassSessionId);
        Assert.Equal(5, summary.SubjectId);
        Assert.Equal("Programming I", summary.SubjectName);
        Assert.Equal(new DateOnly(2026, 10, 5), summary.SessionDate);
        Assert.Equal(new TimeOnly(18, 0), summary.StartTime);
        Assert.Equal(new TimeOnly(19, 20), summary.EndTime);
        Assert.Equal(8, summary.AttendanceCount);
        Assert.Equal("CLOSED", summary.Status);
    }

    [Fact]
    public async Task GetTeacherClassSummariesAsync_WhenRepositoryReturnsNoSummaries_ReturnsEmptyList()
    {
        var service = new ClassService(new FakeSessionRepository(), new FakeSubjectRepository(null));

        var result = await service.GetTeacherClassSummariesAsync(12, CancellationToken.None);

        Assert.Empty(result);
    }

    [Theory]
    [InlineData("missing", typeof(KeyNotFoundException))]
    [InlineData("other-teacher", typeof(UnauthorizedAccessException))]
    [InlineData("inactive", typeof(InvalidOperationException))]
    public async Task CreateAsync_WhenSubjectIsNotEligible_DoesNotSave(string scenario, Type errorType)
    {
        Subject? subject = scenario == "missing" ? null : new Subject
        {
            Id = 7,
            TeacherId = scenario == "other-teacher" ? 99 : 12,
            IsActive = scenario != "inactive"
        };
        var sessions = new FakeSessionRepository();
        var service = new ClassService(sessions, new FakeSubjectRepository(subject));
        var request = new CreateClassRequest
        {
            SubjectId = 7,
            SessionDate = new DateOnly(2026, 10, 6),
            StartTime = new TimeOnly(18, 0),
            EndTime = new TimeOnly(19, 20),
            Latitude = -31.4201m,
            Longitude = -64.1888m,
            AllowedRadiusMeters = 50
        };

        var error = await Record.ExceptionAsync(() => service.CreateAsync(request, 12, CancellationToken.None));

        Assert.NotNull(error);
        Assert.Equal(errorType, error.GetType());
        Assert.Equal(0, sessions.CreateCalls);
    }

    [Theory]
    [InlineData("latitude")]
    [InlineData("longitude")]
    [InlineData("radius")]
    public async Task CreateAsync_WhenLocationConfigurationIsInvalid_RejectsBeforeSaving(string invalidField)
    {
        var sessions = new FakeSessionRepository();
        var subject = new Subject { Id = 7, TeacherId = 12, IsActive = true };
        var service = new ClassService(sessions, new FakeSubjectRepository(subject));
        var request = new CreateClassRequest
        {
            SubjectId = 7,
            SessionDate = new DateOnly(2026, 10, 6),
            StartTime = new TimeOnly(18, 0),
            EndTime = new TimeOnly(19, 20),
            Latitude = invalidField == "latitude" ? 95m : -31.4201m,
            Longitude = invalidField == "longitude" ? 200m : -64.1888m,
            AllowedRadiusMeters = invalidField == "radius" ? 0 : 50
        };

        var error = await Record.ExceptionAsync(() => service.CreateAsync(request, 12, CancellationToken.None));

        Assert.IsType<ArgumentOutOfRangeException>(error);
        Assert.Equal(0, sessions.CreateCalls);
    }

    [Fact]
    public async Task CreateQrClassAsync_WhenTeacherOwnsValidClass_SavesAndReturnsTemporaryQr()
    {
        var classContext = new QrClassContext
        {
            ClassSessionId = 4,
            TeacherId = 12,
            SubjectIsActive = true,
            Status = "SCHEDULED",
            Latitude = -31.4201m,
            Longitude = -64.1888m,
            AllowedRadiusMeters = 50
        };
        var sessions = new FakeSessionRepository(qrClassContext: classContext);
        var service = new ClassService(sessions, new FakeSubjectRepository(null));
        var request = new GenerateQrRequest { DurationSeconds = 30 };
        var before = DateTime.UtcNow;

        var result = await service.CreateQrClassAsync(4, 12, request, CancellationToken.None);

        var after = DateTime.UtcNow;
        Assert.Equal(4, result.ClassSessionId);
        Assert.False(string.IsNullOrWhiteSpace(result.QrToken));
        Assert.Equal(result.QrToken, sessions.SavedQrToken);
        Assert.Equal(4, sessions.SavedClassSessionId);
        Assert.Equal(12, sessions.SavedTeacherId);
        Assert.InRange(result.QrExpiresAt, before.AddSeconds(30), after.AddSeconds(30));
        Assert.Equal(result.QrExpiresAt, sessions.SavedQrExpiresAt);
    }

    [Theory]
    [InlineData("missing", typeof(KeyNotFoundException))]
    [InlineData("other-teacher", typeof(UnauthorizedAccessException))]
    [InlineData("inactive-subject", typeof(InvalidOperationException))]
    [InlineData("closed", typeof(InvalidOperationException))]
    [InlineData("invalid-location", typeof(InvalidOperationException))]
    public async Task CreateQrClassAsync_WhenClassIsNotEligible_DoesNotSave(string scenario, Type errorType)
    {
        QrClassContext? classContext = scenario == "missing" ? null : new QrClassContext
        {
            ClassSessionId = 4,
            TeacherId = scenario == "other-teacher" ? 99 : 12,
            SubjectIsActive = scenario != "inactive-subject",
            Status = scenario == "closed" ? "CLOSED" : "SCHEDULED",
            Latitude = scenario == "invalid-location" ? 95m : -31.4201m,
            Longitude = -64.1888m,
            AllowedRadiusMeters = 50
        };
        var sessions = new FakeSessionRepository(qrClassContext: classContext);
        var service = new ClassService(sessions, new FakeSubjectRepository(null));

        var error = await Record.ExceptionAsync(() => service.CreateQrClassAsync(
            4,
            12,
            new GenerateQrRequest { DurationSeconds = 30 },
            CancellationToken.None));

        Assert.NotNull(error);
        Assert.Equal(errorType, error.GetType());
        Assert.Equal(0, sessions.SaveQrCalls);
    }

    private sealed class FakeSessionRepository : IClassSessionRepository
    {
        private readonly IReadOnlyList<TeacherClassSummary> _summaries;
        private readonly QrClassContext? _qrClassContext;

        public FakeSessionRepository(
            IReadOnlyList<TeacherClassSummary>? summaries = null,
            QrClassContext? qrClassContext = null)
        {
            _summaries = summaries ?? Array.Empty<TeacherClassSummary>();
            _qrClassContext = qrClassContext;
        }

        public int CreateCalls { get; private set; }
        public int? RequestedTeacherId { get; private set; }
        public int SaveQrCalls { get; private set; }
        public int? SavedClassSessionId { get; private set; }
        public int? SavedTeacherId { get; private set; }
        public string? SavedQrToken { get; private set; }
        public DateTime? SavedQrExpiresAt { get; private set; }

        public Task<int> CreateClassSessionAsync(int subjectId, DateOnly sessionDate,
            TimeOnly startTime, TimeOnly endTime, decimal latitude, decimal longitude,
            int allowedRadiusMeters, CancellationToken cancellationToken)
        {
            CreateCalls++;
            return Task.FromResult(42);
        }

        public Task<IReadOnlyList<TeacherClassSummary>> GetTeacherClassSummariesAsync(
            int teacherId,
            CancellationToken cancellationToken)
        {
            RequestedTeacherId = teacherId;
            return Task.FromResult(_summaries);
        }

        public Task<QrClassContext?> GetQrClassContextAsync(
            int classSessionId,
            CancellationToken cancellationToken)
            => Task.FromResult(_qrClassContext);

        public Task<bool> SaveQrAsync(
            int classSessionId,
            int teacherId,
            string qrToken,
            DateTime qrExpiresAt,
            CancellationToken cancellationToken)
        {
            SaveQrCalls++;
            SavedClassSessionId = classSessionId;
            SavedTeacherId = teacherId;
            SavedQrToken = qrToken;
            SavedQrExpiresAt = qrExpiresAt;
            return Task.FromResult(true);
        }
    }

    private sealed class FakeSubjectRepository(Subject? subject) : ISubjectRepository
    {
        public Task<Subject?> GetSubjectByIdAsync(int subjectId, CancellationToken cancellationToken)
            => Task.FromResult(subject);

        public Task<int> CreateSubjectAsync(string name, int teacherId, string? description,
            CancellationToken cancellationToken) => throw new NotImplementedException();

        public Task<IReadOnlyList<Subject>> GetByTeacherIdAsync(int teacherId,
            CancellationToken cancellationToken) => throw new NotImplementedException();
    }
}
