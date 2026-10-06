using AssistQR.Api.DTOs.ClassSession;
using AssistQR.Api.Models;
using AssistQR.Api.Repositories.Interfaces;
using MySqlConnector;

namespace AssistQR.Api.Repositories
{
    public class ClassSessionRepository : IClassSessionRepository
    {
        private readonly MySqlDataSource _dataSource;

        public ClassSessionRepository(MySqlDataSource dataSource)
        {
            _dataSource = dataSource;
        }
        public async Task<int> CreateClassSessionAsync(
            int subjectId,
            DateOnly sessionDate,
            TimeOnly startTime,
            TimeOnly endTime,
            decimal latitude,
            decimal longitude,
            int allowedRadiusMeters,
            CancellationToken cancellationToken)
        {

            await using var connection = await _dataSource.OpenConnectionAsync(cancellationToken);
            await using var command = connection.CreateCommand();

            command.CommandText = @"
                INSERT INTO class_sessions (subject_id, session_date, start_time, end_time, latitude, longitude, allowed_radius_meters, status, qr_active)
                VALUES (@SubjectId, @SessionDate, @StartTime, @EndTime, @Latitude, @Longitude, @AllowedRadiusMeters, 'SCHEDULED', 0);";
            
            command.Parameters.AddWithValue("@SubjectId", subjectId);
            command.Parameters.AddWithValue("@SessionDate", sessionDate.ToString("yyyy-MM-dd"));
            command.Parameters.AddWithValue("@StartTime", startTime.ToString("HH:mm:ss"));
            command.Parameters.AddWithValue("@EndTime", endTime.ToString("HH:mm:ss"));
            command.Parameters.AddWithValue("@Latitude", latitude);
            command.Parameters.AddWithValue("@Longitude", longitude);
            command.Parameters.AddWithValue("@AllowedRadiusMeters", allowedRadiusMeters);


            await command.ExecuteNonQueryAsync(cancellationToken);
            return Convert.ToInt32(command.LastInsertedId);

        }

        public async Task<IReadOnlyList<TeacherClassSummary>> GetTeacherClassSummariesAsync(
            int teacherId,
            CancellationToken cancellationToken)
        {
            var summaries = new List<TeacherClassSummary>();
            await using var connection = await _dataSource.OpenConnectionAsync(cancellationToken);
            await using var command = connection.CreateCommand();
            command.CommandText = @"
                SELECT
                    cs.class_session_id,
                    cs.subject_id,
                    s.name AS subject_name,
                    cs.session_date,
                    cs.start_time,
                    cs.end_time,
                    cs.status,
                    COUNT(a.attendance_id) AS attendance_count
                FROM class_sessions AS cs
                INNER JOIN subjects AS s ON cs.subject_id = s.subject_id
                LEFT JOIN attendances AS a ON cs.class_session_id = a.class_session_id
                WHERE s.teacher_id = @TeacherId
                GROUP BY
                    cs.class_session_id,
                    cs.subject_id,
                    s.name,
                    cs.session_date,
                    cs.start_time,
                    cs.end_time,
                    cs.status
                ORDER BY cs.session_date DESC, cs.start_time DESC;";
            command.Parameters.AddWithValue("@TeacherId", teacherId);
            await using var reader = await command.ExecuteReaderAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                summaries.Add(new TeacherClassSummary
                {
                    ClassSessionId = reader.GetInt32("class_session_id"),
                    SubjectId = reader.GetInt32("subject_id"),
                    SubjectName = reader.GetString("subject_name"),
                    SessionDate = DateOnly.FromDateTime(reader.GetDateTime("session_date")),
                    StartTime = TimeOnly.FromTimeSpan(reader.GetTimeSpan("start_time")),
                    EndTime = TimeOnly.FromTimeSpan(reader.GetTimeSpan("end_time")),
                    Status = reader.GetString("status"),
                    AttendanceCount = checked((int)reader.GetInt64("attendance_count"))
                });
            }
            return summaries;
        }

        public async Task<QrClassContext?> GetQrClassContextAsync(
            int classSessionId,
            CancellationToken cancellationToken)
        {
            await using var connection = await _dataSource.OpenConnectionAsync(cancellationToken);
            await using var command = connection.CreateCommand();
            command.CommandText = @"
                SELECT
                    cs.class_session_id,
                    s.teacher_id,
                    s.active AS subject_active,
                    cs.status,
                    cs.latitude,
                    cs.longitude,
                    cs.allowed_radius_meters
                FROM class_sessions AS cs
                INNER JOIN subjects AS s ON s.subject_id = cs.subject_id
                WHERE cs.class_session_id = @ClassSessionId;";
            command.Parameters.AddWithValue("@ClassSessionId", classSessionId);

            await using var reader = await command.ExecuteReaderAsync(cancellationToken);
            if (!await reader.ReadAsync(cancellationToken))
            {
                return null;
            }

            return new QrClassContext
            {
                ClassSessionId = reader.GetInt32("class_session_id"),
                TeacherId = reader.GetInt32("teacher_id"),
                SubjectIsActive = reader.GetBoolean("subject_active"),
                Status = reader.GetString("status"),
                Latitude = reader.GetDecimal("latitude"),
                Longitude = reader.GetDecimal("longitude"),
                AllowedRadiusMeters = reader.GetInt32("allowed_radius_meters")
            };
        }

        public async Task<bool> SaveQrAsync(
            int classSessionId,
            int teacherId,
            string qrToken,
            DateTime qrExpiresAt,
            CancellationToken cancellationToken)
        {
            await using var connection = await _dataSource.OpenConnectionAsync(cancellationToken);
            await using var command = connection.CreateCommand();
            command.CommandText = @"
                UPDATE class_sessions AS cs
                INNER JOIN subjects AS s ON s.subject_id = cs.subject_id
                SET cs.qr_token = @QrToken,
                    cs.qr_expires_at = @QrExpiresAt,
                    cs.qr_active = 1
                WHERE cs.class_session_id = @ClassSessionId
                    AND s.teacher_id = @TeacherId
                    AND s.active = 1
                    AND cs.status <> 'CLOSED';";
            command.Parameters.AddWithValue("@ClassSessionId", classSessionId);
            command.Parameters.AddWithValue("@TeacherId", teacherId);
            command.Parameters.AddWithValue("@QrToken", qrToken);
            command.Parameters.AddWithValue("@QrExpiresAt", qrExpiresAt);

            var affectedRows = await command.ExecuteNonQueryAsync(cancellationToken);
            return affectedRows == 1;
        }


    }
}
