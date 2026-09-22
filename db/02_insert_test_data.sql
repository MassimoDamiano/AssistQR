USE db_assistqr;

-- Limpiar datos de prueba anteriores
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE attendances;
TRUNCATE TABLE class_sessions;
TRUNCATE TABLE enrollments;
TRUNCATE TABLE subjects;
TRUNCATE TABLE users;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================
-- USERS
-- =====================================

INSERT INTO users (
    first_name,
    last_name,
    email,
    password_hash,
    role
)
VALUES (
    'Laura',
    'Gomez',
    'laura.gomez@assistqr.test',
    'TEST_HASH_NOT_FOR_PRODUCTION',
    'TEACHER'
);

SET @laura_id = LAST_INSERT_ID();

INSERT INTO users (
    first_name,
    last_name,
    email,
    password_hash,
    role
)
VALUES (
    'Carlos',
    'Fernandez',
    'carlos.fernandez@assistqr.test',
    'TEST_HASH_NOT_FOR_PRODUCTION',
    'TEACHER'
);

SET @carlos_id = LAST_INSERT_ID();

INSERT INTO users (
    first_name,
    last_name,
    email,
    password_hash,
    role
)
VALUES (
    'Ana',
    'Lopez',
    'ana.lopez@assistqr.test',
    'TEST_HASH_NOT_FOR_PRODUCTION',
    'STUDENT'
);

SET @ana_id = LAST_INSERT_ID();

INSERT INTO users (
    first_name,
    last_name,
    email,
    password_hash,
    role
)
VALUES (
    'Martin',
    'Diaz',
    'martin.diaz@assistqr.test',
    'TEST_HASH_NOT_FOR_PRODUCTION',
    'STUDENT'
);

SET @martin_id = LAST_INSERT_ID();

-- =====================================
-- SUBJECTS
-- =====================================

INSERT INTO subjects (
    name,
    description,
    teacher_id
)
VALUES (
    'Programming I',
    'Introduction to programming',
    @laura_id
);

SET @programming_id = LAST_INSERT_ID();

INSERT INTO subjects (
    name,
    description,
    teacher_id
)
VALUES (
    'Databases I',
    'Introduction to relational databases',
    @carlos_id
);

SET @databases_id = LAST_INSERT_ID();

-- =====================================
-- ENROLLMENTS
-- =====================================

INSERT INTO enrollments (
    student_id,
    subject_id
)
VALUES
    (@ana_id, @programming_id),
    (@martin_id, @programming_id),
    (@ana_id, @databases_id);

-- =====================================
-- CLASS SESSION
-- =====================================

INSERT INTO class_sessions (
    subject_id,
    session_date,
    start_time,
    end_time,
    qr_token,
    qr_expires_at,
    latitude,
    longitude,
    allowed_radius_meters,
    status,
    qr_active
)
VALUES (
    @programming_id,
    CURRENT_DATE(),
    '18:00:00',
    '20:00:00',
    'QR-TEST-001',
    DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 30 MINUTE),
    -34.60372200,
    -58.38159200,
    50,
    'OPEN',
    1
);

SET @class_session_id = LAST_INSERT_ID();

-- =====================================
-- ATTENDANCE
-- =====================================

INSERT INTO attendances (
    class_session_id,
    student_id,
    registration_latitude,
    registration_longitude,
    distance_meters
)
VALUES (
    @class_session_id,
    @ana_id,
    -34.60370000,
    -58.38160000,
    12.50
);

-- =====================================
-- VERIFICATION
-- =====================================

SELECT * FROM users;
SELECT * FROM subjects;
SELECT * FROM enrollments;
SELECT * FROM class_sessions;
SELECT * FROM attendances;