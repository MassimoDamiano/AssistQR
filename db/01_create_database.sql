CREATE DATABASE IF NOT EXISTS db_asistqr;
USE db_assistqr;

/* USUARIOS */

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('TEACHER', 'STUDENT') NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    active TINYINT NOT NULL DEFAULT 1
);

/* SUBJECTS / MATERIAS */

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    teacher_id INT NOT NULL,
    active TINYINT NOT NULL DEFAULT 1,
    CONSTRAINT fk_subjects_teacher
        FOREIGN KEY (teacher_id)
        REFERENCES users(user_id),
    CONSTRAINT chk_subjects_active
        CHECK (active IN (0, 1))
);

           /* INSCRIPCIONES - ENROLLMENTS */
           
create table enrollments(
enrollment_id int primary key auto_increment,
student_id int not null,
subject_id int not null,
enrolled_at datetime not null default current_timestamp,
active TINYINT NOT NULL DEFAULT 1,

constraint fk_enrollments_student
foreign key (student_id)
references users(user_id),


constraint fk_enrollments_subject
foreign key (subject_id) 
references subjects(subject_id),

constraint uq_enrollments_student_subject
unique (student_id,subject_id),

constraint chk_enrollments_active
check (active in (0,1))

);
		

		/*CLASES*/

create table class_sessions(
class_session_id int primary key auto_increment,
subject_id int not null,
session_date date not null,
start_time time not null,
end_time time not null,
qr_token varchar(255) ,
qr_expires_at datetime ,
latitude decimal (10,8) not null,
longitude decimal(11,8) not null,
allowed_radius_meters int not null default 50,
status enum('SCHEDULED','OPEN','CLOSED') NOT NULL DEFAULT 'SCHEDULED',
qr_active tinyint not null default 0,

constraint fk_class_sessions_subject
foreign key (subject_id)
references subjects(subject_id),

constraint uq_class_sessions_qr_token
unique (qr_token),

constraint chk_class_sessions_time
check (end_time > start_time),

constraint chk_class_sessions_radius
check (allowed_radius_meters > 0),

constraint chk_class_sessions_qr_active
check (qr_active in (1,0))
);

/* ATTENDANCES / ASISTENCIAS */

CREATE TABLE attendances (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    class_session_id INT NOT NULL,
    student_id INT NOT NULL,
    registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    registration_latitude DECIMAL(10,8) NOT NULL,
    registration_longitude DECIMAL(11,8) NOT NULL,
    distance_meters DECIMAL(8,2) NOT NULL,

    CONSTRAINT fk_attendances_class_session
        FOREIGN KEY (class_session_id)
        REFERENCES class_sessions(class_session_id),

    CONSTRAINT fk_attendances_student
        FOREIGN KEY (student_id)
        REFERENCES users(user_id),

    CONSTRAINT uq_attendances_class_student
        UNIQUE (class_session_id, student_id),

    CONSTRAINT chk_attendances_distance
        CHECK (distance_meters >= 0)
);




describe class_sessions;





