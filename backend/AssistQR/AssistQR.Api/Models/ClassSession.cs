namespace AssistQR.Api.Models
{
    public class ClassSession
    {
        public int Id { get; set; }
        public int SubjectId { get; set; }

        public DateOnly SessionDate { get; set; }
        public TimeOnly StartTime { get; set; }
        public TimeOnly EndTime { get; set; }

        public string? QrToken { get; set; }
        public DateTime? QrExpiresAt { get; set; }

        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
        public int AllowedRadiusMeters { get; set; }

        public string Status { get; set; } = string.Empty;
        public bool QrActive { get; set; }

        public ClassSession(int id, int subjectId, DateOnly sessionDate, TimeOnly startTime, TimeOnly endTime, string? qrToken, DateTime? qrExpiresAt, decimal latitude, decimal longitude, int allowedRadiusMeters, string status, bool qrActive)
        {
            Id = id;
            SubjectId = subjectId;
            SessionDate = sessionDate;
            StartTime = startTime;
            EndTime = endTime;
            QrToken = qrToken;
            QrExpiresAt = qrExpiresAt;
            Latitude = latitude;
            Longitude = longitude;
            AllowedRadiusMeters = allowedRadiusMeters;
            Status = status;
            QrActive = qrActive;
        }
    }
}
