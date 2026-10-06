namespace AssistQR.Api.DTOs.ClassSession
{
    public class CreateClassRequest
    {
        public int SubjectId { get; set; }
        public DateOnly SessionDate { get; set; }
        public TimeOnly StartTime { get; set; }
        public TimeOnly EndTime { get; set; }
        [System.ComponentModel.DataAnnotations.Range(typeof(decimal), "-90", "90")]
        public decimal Latitude { get; set; }
        [System.ComponentModel.DataAnnotations.Range(typeof(decimal), "-180", "180")]
        public decimal Longitude { get; set; }
        [System.ComponentModel.DataAnnotations.Range(1, int.MaxValue)]
        public int AllowedRadiusMeters { get; set; }
    }
}
