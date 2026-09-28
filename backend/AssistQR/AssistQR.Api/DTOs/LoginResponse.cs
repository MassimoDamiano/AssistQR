namespace AssistQR.Api.DTOs
{
    public class LoginResponse
    {
        public string AccessToken { get; set; } = string.Empty;
        public string TokenType { get; set; } = "Bearer";
        public DateTimeOffset ExpiresAtUtc { get; set; }
        public UserResponse User { get; set; } = new UserResponse();

        public LoginResponse(string accessToken, DateTimeOffset expiresAtUtc, UserResponse user)
        {
            AccessToken = accessToken;
            TokenType = "Bearer";
            ExpiresAtUtc = expiresAtUtc;
            User = user;
        }
    }
}
