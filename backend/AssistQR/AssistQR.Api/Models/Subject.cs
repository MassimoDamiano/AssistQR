namespace AssistQR.Api.Models

//Separamos este modelo de SubjectResponse para que el repositorio no dependa del formato que enviamos a Flutter.

{
    public class Subject
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; } 
        public int TeacherId { get; set; }
        public bool IsActive { get; set; } = true;
    }
}
