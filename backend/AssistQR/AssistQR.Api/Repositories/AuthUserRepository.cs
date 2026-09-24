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

            command.CommandText = "SELECT user_id, email, password_hash, role, active FROM users WHERE email = @email";
            command.Parameters.AddWithValue("@email", email);
            await using var reader = await command.ExecuteReaderAsync(cancellationToken);
            return await reader.ReadAsync(cancellationToken)
                ? new AuthUser(
                    id: reader.GetInt32("user_id"),
                    email: reader.GetString("email"),
                    passwordHash: reader.GetString("password_hash"),
                    role: reader.GetString("role"),
                    isActive: reader.GetBoolean("active")
                )
                : null;

        }
    }
}

                  