class ClassSession {
  const ClassSession({
    required this.id,
    required this.subjectId,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.latitude,
    required this.longitude,
    required this.allowedRadiusMeters,
    required this.status,
  });

  final int id;
  final int subjectId;
  final DateTime sessionDate;
  final String startTime;
  final String endTime;
  final double latitude;
  final double longitude;
  final int allowedRadiusMeters;
  final String status;

  factory ClassSession.fromJson(Map<String, dynamic> json) {
    return ClassSession(
      id: json['id'] as int,
      subjectId: json['subjectId'] as int,
      sessionDate: DateTime.parse(json['sessionDate'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      allowedRadiusMeters: json['allowedRadiusMeters'] as int,
      status: json['status'] as String? ?? '',
    );
  }
}
