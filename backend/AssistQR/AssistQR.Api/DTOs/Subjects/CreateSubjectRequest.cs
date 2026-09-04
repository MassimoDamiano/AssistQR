using System.ComponentModel.DataAnnotations;

namespace AssistQR.Api.DTOs.Subjects
{
    public class CreateSubjectRequest
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [StringLength(255)]
        public string? Description { get; set; }
    }
}
