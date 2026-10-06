using System.ComponentModel.DataAnnotations;

namespace AssistQR.Api.Models
{
    public class RegisterUser
    {
        [Required]
        public string FirstName { get; set; } = string.Empty;
        [Required]
        public string LastName { get; set; } = string.Empty;
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
        [Required]
        [MinLength(6)]
        public string PasswordHash { get; set; } = string.Empty;
        public string Role { get; set; } = "STUDENT";
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public RegisterUser( string firstName, string lastName, string email, string passwordHash, string role = "STUDENT", bool isActive = true)
        {
            
            FirstName = firstName;
            LastName = lastName;
            Email = email;
            PasswordHash = passwordHash;
            Role = role;
            IsActive = isActive;
        }
    }
}
