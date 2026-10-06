class QrClass {
  const QrClass({
    required this.classSessionId,
    required this.qrToken,
    required this.expiresAtUtc,
  });

  final int classSessionId;
  final String qrToken;
  final DateTime expiresAtUtc;

  factory QrClass.fromJson(Map<String, dynamic> json) {
    return QrClass(
      classSessionId: json['classSessionId'] as int,
      qrToken: json['qrToken'] as String,
      expiresAtUtc: DateTime.parse(json['qrExpiresAt'] as String).toUtc(),
    );
  }
}
