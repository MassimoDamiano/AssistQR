using System.ComponentModel.DataAnnotations;

namespace AssistQR.Api.DTOs.ClassSession
{
    public class GenerateQrRequest
    {
        [Range(1, 30)]
        public int DurationSeconds { get; set; } = 30;
    }
}
