using MySqlConnector;
using AssistQR.Api.Repositories.Interfaces;

namespace AssistQR.Api.Repositories
{
    public class SubjectRepository : ISubjectRepository
    {
       private readonly MySqlDataSource _dataSource;

        public SubjectRepository(MySqlDataSource dataSource)
        {
            _dataSource = dataSource;
        }

        public async Task<int> CreateSubjectAsync(string name, int teacherId,string? description, CancellationToken cancellationToken)
        {
            await using var connection = await _dataSource.OpenConnectionAsync(cancellationToken);
            await using var command = connection.CreateCommand();
            command.CommandText = "INSERT INTO subjects (name, teacher_id, description) VALUES (@name, @teacherId, @description);";
            command.Parameters.AddWithValue("@name", name);
            command.Parameters.AddWithValue("@teacherId", teacherId);
            command.Parameters.AddWithValue("@description", (object?)description ?? DBNull.Value);
            await command.ExecuteNonQueryAsync(cancellationToken);
            return Convert.ToInt32(command.LastInsertedId);
        }

        public async Task<IReadOnlyList<AssistQR.Api.Models.Subject>> GetByTeacherIdAsync(int teacherId, CancellationToken cancellationToken)
        {
            var subjects = new List<AssistQR.Api.Models.Subject>();
            await using var connection = await _dataSource.OpenConnectionAsync(cancellationToken);
            await using var command = connection.CreateCommand();
            command.CommandText = "SELECT subject_id, name, description, teacher_id, active FROM subjects WHERE teacher_id = @teacherId ORDER BY subject_id;";
            command.Parameters.AddWithValue("@teacherId", teacherId);
            await using var reader = await command.ExecuteReaderAsync(cancellationToken);
           
            while (await reader.ReadAsync(cancellationToken))
            {
                subjects.Add(new AssistQR.Api.Models.Subject
                {
                    Id = reader.GetInt32("subject_id"),
                    Name = reader.GetString("name"),
                    Description = reader.IsDBNull(reader.GetOrdinal("description")) ? null : reader.GetString("description"),
                    TeacherId = reader.GetInt32("teacher_id"),
                    IsActive = reader.GetBoolean("active")
                });
            }
            return subjects;
        }
    }
}
            