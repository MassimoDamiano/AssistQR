using MySqlConnector;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddControllers();


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

app.UseAuthorization();

app.MapControllers();

app.Run();
