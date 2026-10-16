class Group {
  final String id;
  final String name;
  final String courseId;
  final String teacherId;
  final List<String> days; // e.g. ['Du', 'Ch', 'Ju']
  final String time; // e.g. '14:00'
  final List<String> studentIds;

  Group({
    required this.id,
    required this.name,
    required this.courseId,
    required this.teacherId,
    required this.days,
    required this.time,
    required this.studentIds,
  });

  Group copyWith({
    String? id,
    String? name,
    String? courseId,
    String? teacherId,
    List<String>? days,
    String? time,
    List<String>? studentIds,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      courseId: courseId ?? this.courseId,
      teacherId: teacherId ?? this.teacherId,
      days: days ?? this.days,
      time: time ?? this.time,
      studentIds: studentIds ?? this.studentIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'courseId': courseId,
      'teacherId': teacherId,
      'days': days,
      'time': time,
      'studentIds': studentIds,
    };
  }

  factory Group.fromJson(Map<String, dynamic> map) {
    return Group(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      courseId: map['courseId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      days: List<String>.from(map['days'] ?? []),
      time: map['time'] ?? '12:00',
      studentIds: List<String>.from(map['studentIds'] ?? []),
    );
  }
}
