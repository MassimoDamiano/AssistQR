namespace AssistQR.Api.DTOs.ClassSession
{
    public class QrClassResponse
    {
        public int ClassSessionId { get; set; }
        public string QrToken { get; set; } = string.Empty;
        public DateTime QrExpiresAt { get; set; }
    }
}
