namespace AssistQR.Api.DTOs.ClassSession
{
    public class ClassResponse
    {
        public int Id { get; set; }
        public int SubjectId { get; set; }

        public DateOnly SessionDate { get; set; }
        public TimeOnly StartTime { get; set; }
        public TimeOnly EndTime { get; set; }
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
        public int AllowedRadiusMeters { get; set; }
        public string Status { get; set; } = string.Empty;

        public string? QrToken { get; set; }
        public DateTime? QrExpiresAt { get; set; }

        public bool QrActive { get; set; }
    }
}
