namespace AssistQR.Api.Configuration
{
    public class JwtOptions
    {
        public string Issuer { get; set; } = string.Empty; // Quien lo creó
        public string Audience { get; set; } = string.Empty; // Quien lo va a consumir
        public string SigningKey { get; set; } = string.Empty; // Clave para firmar el token
        public int ExpirationMinutes { get; set; } = 15; // Tiempo de expiración en minutos
    }
}
