using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using AssistQR.Api.DTOs;
using AssistQR.Api.Services.Interfaces;
using AssistQR.Api.DTOs.Auth;
using Microsoft.AspNetCore.Authorization;

namespace AssistQR.Api.Controllers
{
    [ApiController]
    [Route("api/v1/auth")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ITokenService _tokenService;

        public AuthController(IAuthService authService, ITokenService tokenService)
        {
            this._authService = authService;
            this._tokenService = tokenService;
        }





        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request, CancellationToken cancellationToken)
        {
            var user = await _authService.AuthenticateAsync(request, cancellationToken);
            if (user == null)
            {
                return Unauthorized();
            }
            var tokenResponse = _tokenService.CreateToken(user);
            return Ok(tokenResponse);
        }
    }
}
