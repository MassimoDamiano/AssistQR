namespace AssistQR.Api.Models
{
    public class QrClassContext
    {
        public int ClassSessionId { get; set; }
        public int TeacherId { get; set; }
        public bool SubjectIsActive { get; set; }
        public string Status { get; set; } = string.Empty;
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
        public int AllowedRadiusMeters { get; set; }
    }
}
