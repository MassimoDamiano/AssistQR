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
    }
}
            