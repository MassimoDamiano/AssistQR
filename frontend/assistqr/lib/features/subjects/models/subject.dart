class Subject {
  const Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.teacherId,
    required this.isActive,
  });

  final int id;
  final String name;
  final String? description;
  final int teacherId;
  final bool isActive;

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      teacherId: json['teacherId'] as int,
      isActive: json['isActive'] as bool,
    );
  }
}
