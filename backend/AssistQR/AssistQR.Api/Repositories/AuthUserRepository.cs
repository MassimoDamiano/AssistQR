using AssistQR.Api.Models;
using AssistQR.Api.Repositories.Interfaces;
using MySqlConnector;

namespace AssistQR.Api.Repositories
{
    public class AuthUserRepository : IAuthUserRepository
    {
        private readonly MySqlDataSource _dataSource;
        public AuthUserRepository(MySqlDataSource dataSource)
        {
            _dataSource = dataSource;
        }
        

        public async Task<AuthUser?> FindByEmailAsync(string email, CancellationToken cancellationToken)
        {
            await using var connection = await _dataSource.OpenConnectionAsync(cancellationToken);
            await using var command = connection.CreateCommand();

            command.CommandText = "SELECT user_id, first_name, last_name, email, password_hash, role, active FROM users WHERE email = @email";
            command.Parameters.AddWithValue("@email", email);
            await using var reader = await command.ExecuteReaderAsync(cancellationToken);
            return await reader.ReadAsync(cancellationToken)
                ? new AuthUser(
                    id: reader.GetInt32("user_id"),
                    firstName: reader.GetString("first_name"),
                    lastName: reader.GetString("last_name"),
                    email: reader.GetString("email"),
                    passwordHash: reader.GetString("password_hash"),
                    role: reader.GetString("role"),
                    isActive: reader.GetBoolean("active")
                )
                : null;

        }

        public async Task<int?> CreateStudentAsync(
            string firstName,
            string lastName,
            string email,
            string passwordHash,
            CancellationToken cancellationToken)
        {
            await using var connection = await _dataSource.OpenConnectionAsync(cancellationToken);
            await using var command = connection.CreateCommand();
            command.CommandText = @"
                INSERT INTO users (first_name, last_name, email, password_hash, role, active) 
                VALUES (@firstName, @lastName, @email, @passwordHash, 'STUDENT', 1);
            ";
            command.Parameters.AddWithValue("@firstName", firstName);
            command.Parameters.AddWithValue("@lastName", lastName);
            command.Parameters.AddWithValue("@email", email);
            command.Parameters.AddWithValue("@passwordHash", passwordHash);

            try
            {
                await command.ExecuteNonQueryAsync(cancellationToken);
            }
            catch (MySqlException ex)
                when (ex.ErrorCode == MySqlErrorCode.DuplicateKeyEntry)
            {
                return null;
            }


            return Convert.ToInt32(command.LastInsertedId);
        }
    }
}

                  