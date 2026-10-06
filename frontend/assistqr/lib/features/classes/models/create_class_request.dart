class CreateClassRequest {
  const CreateClassRequest({
    required this.subjectId,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.latitude,
    required this.longitude,
    required this.allowedRadiusMeters,
  });

  final int subjectId;
  final DateTime sessionDate;
  final ({int hour, int minute}) startTime;
  final ({int hour, int minute}) endTime;
  final double latitude;
  final double longitude;
  final int allowedRadiusMeters;

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'sessionDate': _formatDate(sessionDate),
      'startTime': _formatTime(startTime),
      'endTime': _formatTime(endTime),
      'latitude': latitude,
      'longitude': longitude,
      'allowedRadiusMeters': allowedRadiusMeters,
    };
  }

  static String _formatDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(({int hour, int minute}) value) {
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}:00';
  }
}
