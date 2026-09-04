namespace AssistQR.Api.DTOs.Subjects
{
    public class SubjectResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public int TeacherId { get; set; }
        public bool IsActive { get; set; }
    }
}
