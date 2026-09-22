use db_assistqr;
/*	BACKLOGS */
SET @ana_id = (SELECT user_id FROM users WHERE email = 'ana.lopez@assistqr.test');
SET @martin_id = (SELECT user_id FROM users WHERE email = 'martin.diaz@assistqr.test');
SET @programming_id = (SELECT subject_id FROM subjects WHERE name = 'Programming I');
SET @class_session_id = (SELECT class_session_id FROM class_sessions WHERE qr_token = 'QR-TEST-001');
/* 	
DB-TC-001 — Email duplicado
 Precondición: Ana ya existe.
 Acción: insertar otro usuario con el email de Ana.
 Resultado esperado: MySQL rechaza el INSERT por uq_users_email.
*/
use db_assistqr;

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

/*
 DB-TC-002 — Docente inexistente
- Acción: insertar una materia con teacher_id = 999999.
- Resultado esperado: rechazo por fk_subjects_teacher.
 
 **/

insert into subjects (
name,description,teacher_id

)values (
'MATH','LOGICS',999999
);

/*
  DB-TC-003 — Inscripción duplicada
- Precondición: Ana ya está inscripta en Programming I.
- Acción: repetir esa inscripción.
- Resultado esperado: rechazo por uq_enrollments_student_subject.
 * */

insert into enrollments(
	student_id,
	subject_id
)values (
	@ana_id,@programming_id
);

/*
  DB-TC-004 — Estudiante inexistente
- Acción: insertar una inscripción con student_id = 999999.
- Resultado esperado: rechazo por fk_enrollments_student.
*/

insert into enrollments(
	student_id,
	subject_id
)values (999999,@programming_id);


/*
 DB-TC-005 — Horario inválido
- Acción: crear una clase con start_time = '20:00:00' y end_time = '18:00:00'.
- Resultado esperado: rechazo por chk_class_sessions_time.
 **/


insert into class_sessions(
	
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
	
	
)VALUES (
	@programming_id,
    CURRENT_DATE(),
    '20:00:00',
	'18:00:00',
    'QR-TEST-002',
    DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 30 second),
    -34.60372200,
    -58.38159200,
    50,
    'OPEN',
    1
);


/*
 DB-TC-006 — Radio inválido
- Acción: crear una clase con allowed_radius_meters = -50.
- Resultado esperado: rechazo por chk_class_sessions_radius.
 **/


insert into class_sessions(
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
	
	
)VALUES (
    @programming_id,
    CURRENT_DATE(),
    '17:00:00',
    '21:00:00',
    'QR-TEST-003',
    DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 30 second),
    -34.60372200,
    -58.38159200,
    -50,
    'OPEN',
    1
);


/* 
 DB-TC-007 — QR duplicado
- Precondición: existe QR-TEST-001.
- Acción: crear otra clase con el mismo token.
- Resultado esperado: rechazo por uq_class_sessions_qr_token.
 
 */


insert into class_sessions(
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
	
	
)VALUES (
    @programming_id,
    CURRENT_DATE(),
    '14:00:00',
    '21:00:00',
    'QR-TEST-001',
    DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 30 second),
    -34.60372200,
    -58.38159200,
    50,
    'OPEN',
    1
);


/*
 * DB-TC-008 — Asistencia duplicada
- Precondición: Ana ya registró asistencia en la clase.
- Acción: repetir esa asistencia.
- Resultado esperado: rechazo por uq_attendances_class_student.
 */

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


/*
 DB-TC-009 — Distancia negativa
- Acción: insertar una asistencia con distance_meters = -1.
- Resultado esperado: rechazo por chk_attendances_distance.
 */

insert into attendances(
	class_session_id,
	student_id,
	registration_latitude,
	registration_longitude,
	distance_meters
) values (@class_session_id,@martin_id,-34.60370000,
    -58.38160000,-1);

/*
 *DB-TC-010 — Clase inexistente
- Acción: insertar una asistencia con class_session_id = 999999.
- Resultado esperado: rechazo por fk_attendances_class_session.
 */


insert into attendances(
	class_session_id,
	student_id,
	registration_latitude,
	registration_longitude,
	distance_meters
	
) values (999999,@ana_id,-34.60370000,
    -58.38160000,1);
















