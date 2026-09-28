using AssistQR.Api.Configuration;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
using MySqlConnector;
using System.Text;


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddControllers();

// Configure JwtOptions from appsettings.json
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer();

builder.Services.AddAuthorization();
builder.Services.AddSwaggerGen(options =>
{
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        Description = "Paste your access token without the Bearer prefix."
    });

    options.AddSecurityRequirement(document =>
        new OpenApiSecurityRequirement
        {
            [new OpenApiSecuritySchemeReference("Bearer", document)] = []
        });
});


builder.Services
    .AddOptions<JwtOptions>()
    .Bind(builder.Configuration.GetSection("Jwt"))
    .Validate(
        options => !string.IsNullOrWhiteSpace(options.Issuer),
        "Jwt:Issuer is required.")
    .Validate(
        options => !string.IsNullOrWhiteSpace(options.Audience),
        "Jwt:Audience is required.")
    .Validate(
        options =>
            !string.IsNullOrWhiteSpace(options.SigningKey) &&
            Encoding.UTF8.GetByteCount(options.SigningKey) >= 32,
        "Jwt:SigningKey must contain at least 32 UTF-8 bytes.")
    .Validate(
        options => options.ExpirationMinutes > 0,
        "Jwt:ExpirationMinutes must be greater than zero.")
    .ValidateOnStart();
builder.Services
    .AddOptions<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme)
    .Configure<IOptions<JwtOptions>>((bearer, configuration) =>
    {
        var jwt = configuration.Value;

        bearer.MapInboundClaims = false;

        bearer.TokenValidationParameters = new TokenValidationParameters
        {
            NameClaimType = "email",
            RoleClaimType = "role",
            ValidateIssuer = true,
            ValidIssuer = jwt.Issuer,
            ValidateAudience = true,
            ValidAudience = jwt.Audience,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.SigningKey)),
            RequireSignedTokens = true,
            RequireExpirationTime = true,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero,
            ValidAlgorithms = new[] { SecurityAlgorithms.HmacSha256 }
        };
    });


builder.Services.AddSingleton<AssistQR.Api.Services.Interfaces.ITokenService, AssistQR.Api.Services.TokenService>();



// Add MySQL data source
var connection = builder.Configuration.GetConnectionString("AssistQrDb")?? 
    throw new InvalidOperationException("Connection string 'AssistQrDb' is not found.");
builder.Services.AddMySqlDataSource(connection);

// Add repositorys

builder.Services.AddScoped<AssistQR.Api.Repositories.Interfaces.ISubjectRepository, 
    AssistQR.Api.Repositories.SubjectRepository>();
builder.Services.AddScoped<AssistQR.Api.Services.SubjectService>();
builder.Services.AddScoped<AssistQR.Api.Services.Interfaces.ISubjectService, AssistQR.Api.Services.SubjectService>();

builder.Services.AddScoped<AssistQR.Api.Repositories.Interfaces.IAuthUserRepository,
    AssistQR.Api.Repositories.AuthUserRepository>();
builder.Services.AddScoped<AssistQR.Api.Services.Interfaces.IAuthService, AssistQR.Api.Services.AuthService>();

builder.Services.AddScoped<Microsoft.AspNetCore.Identity.IPasswordHasher<AssistQR.Api.Models.AuthUser>,
    Microsoft.AspNetCore.Identity.PasswordHasher<AssistQR.Api.Models.AuthUser>>();



var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();
