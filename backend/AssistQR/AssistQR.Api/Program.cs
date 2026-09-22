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

// Add repository
builder.Services.AddScoped<AssistQR.Api.Repositories.Interfaces.ISubjectRepository, 
    AssistQR.Api.Repositories.SubjectRepository>();

builder.Services.AddScoped<AssistQR.Api.Services.SubjectService>();
builder.Services.AddScoped<AssistQR.Api.Services.Interfaces.ISubjectService, AssistQR.Api.Services.SubjectService>();

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
