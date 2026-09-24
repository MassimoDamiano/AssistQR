namespace AssistQR.Api.Models
{
    public class AuthenticatedUser
    {
        public int Id { get; set; }
        public string Email { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
    }
}
