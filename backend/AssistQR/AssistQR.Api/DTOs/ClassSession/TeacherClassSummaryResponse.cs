

namespace AssistQR.Api.DTOs.ClassSession
{
    
    public class TeacherClassSummaryResponse
    {
        public int ClassSessionId { get; set; }
        public int SubjectId { get; set; }
        public string SubjectName { get; set; } = string.Empty;
        public DateOnly SessionDate { get; set; }
        public TimeOnly StartTime { get; set; }
        public TimeOnly EndTime { get; set; }
        public int AttendanceCount { get; set; }
        public string Status { get; set; } = string.Empty;


    }
}
