namespace AssistQR.Api.Models
{
    public class AuthUser
    {
        public int Id { get; set; }
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public bool IsActive { get; set; }

        public AuthUser(int id, string email, string passwordHash, string role, bool isActive)
        {
            Id = id;
            Email = email;
            PasswordHash = passwordHash;
            Role = role;
            IsActive = isActive;
        }
    }
}
