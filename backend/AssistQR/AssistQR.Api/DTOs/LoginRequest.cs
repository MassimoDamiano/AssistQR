using System.ComponentModel.DataAnnotations;

namespace AssistQR.Api.DTOs.Auth

{
    public class LoginRequest
    {
        [EmailAddress]
        [Required]
        public string Email { get; set; } = string.Empty;
        
        [Required]
        public string Password { get; set; } = string.Empty;

        public LoginRequest(string email, string password)
        {
            Email = email;
            Password = password;
        }
    }
}
