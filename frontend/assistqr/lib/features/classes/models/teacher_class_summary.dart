class TeacherClassSummary {
  const TeacherClassSummary({
    required this.classSessionId,
    required this.subjectId,
    required this.subjectName,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.attendanceCount,
    required this.status,
  });

  final int classSessionId;
  final int subjectId;
  final String subjectName;
  final DateTime sessionDate;
  final String startTime;
  final String endTime;
  final int attendanceCount;
  final String status;

  bool get isClosed => status.toUpperCase() == 'CLOSED';

  factory TeacherClassSummary.fromJson(Map<String, dynamic> json) {
    return TeacherClassSummary(
      classSessionId: json['classSessionId'] as int,
      subjectId: json['subjectId'] as int,
      subjectName: json['subjectName'] as String,
      sessionDate: DateTime.parse(json['sessionDate'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      attendanceCount: json['attendanceCount'] as int,
      status: json['status'] as String,
    );
  }
}
