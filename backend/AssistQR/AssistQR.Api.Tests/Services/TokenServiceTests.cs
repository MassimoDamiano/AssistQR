using System;
using AssistQR.Api.Configuration;
using AssistQR.Api.Models;
using AssistQR.Api.Services;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Cryptography;
using System.Text;

namespace AssistQR.Api.Tests.Services
{
    public class TokenServiceTests
    {
        [Fact]
        public void CreateToken_WhenUserIsValid_ReturnsSignedTokenWithExpectedClaims()
        {
            // Arrange: configuración aislada, sin leer secretos de la aplicación.
            var options = new JwtOptions
            {
                Issuer = "AssistQR.Tests",
                Audience = "AssistQR.TestClient",
                ExpirationMinutes = 15,
                SigningKey = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32))
            };
            var service = new TokenService(Options.Create(options));
            var user = new AuthenticatedUser
            {
                Id = 12,
                Email = "teacher@example.com",
                Role = "TEACHER"
            };
            var handler = new JwtSecurityTokenHandler { MapInboundClaims = false };
            var validationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidIssuer = options.Issuer,
                ValidateAudience = true,
                ValidAudience = options.Audience,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(options.SigningKey)),
                RequireSignedTokens = true,
                RequireExpirationTime = true,
                ValidateLifetime = true,
                ClockSkew = TimeSpan.Zero,
                ValidAlgorithms = new[] { SecurityAlgorithms.HmacSha256 }
            };

            // Act
            var before = DateTimeOffset.UtcNow;
            var response = service.CreateToken(user);
            var after = DateTimeOffset.UtcNow;

            // Assert: respuesta pública y duración configurada.
            Assert.False(string.IsNullOrWhiteSpace(response.AccessToken));
            Assert.Equal("Bearer", response.TokenType);
            Assert.NotNull(response.User);
            Assert.Equal(user.Id, response.User.Id);
            Assert.Equal(user.Email, response.User.Email);
            Assert.Equal(user.Role, response.User.Role);
            Assert.InRange(response.ExpiresAtUtc,
                before.AddMinutes(options.ExpirationMinutes),
                after.AddMinutes(options.ExpirationMinutes));

            // Validar la firma y la vigencia antes de confiar en los claims.
            var principal = handler.ValidateToken(response.AccessToken,
                validationParameters, out var validatedToken);

            Assert.Equal(user.Id.ToString(), principal.FindFirst("sub")?.Value);
            Assert.Equal(user.Email, principal.FindFirst("email")?.Value);
            Assert.Equal(user.Role, principal.FindFirst("role")?.Value);

            var jwt = Assert.IsType<JwtSecurityToken>(validatedToken);
            Assert.Equal(SecurityAlgorithms.HmacSha256, jwt.Header.Alg);
            Assert.Equal(response.ExpiresAtUtc.ToUnixTimeSeconds(), jwt.Payload.Expiration);
            Assert.NotNull(jwt.Payload.NotBefore);
            Assert.InRange(jwt.Payload.NotBefore.Value,
                before.ToUnixTimeSeconds(), after.ToUnixTimeSeconds());
        }
    }
}
