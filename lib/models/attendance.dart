class Attendance {
  final String id;
  final String groupId;
  final String date; // yyyy-MM-dd
  final String studentId;
  final String status; // 'present', 'absent', 'late', 'bonus'
  final bool awarded;

  Attendance({
    required this.id,
    required this.groupId,
    required this.date,
    required this.studentId,
    required this.status,
    required this.awarded,
  });

  Attendance copyWith({
    String? id,
    String? groupId,
    String? date,
    String? studentId,
    String? status,
    bool? awarded,
  }) {
    return Attendance(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      date: date ?? this.date,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      awarded: awarded ?? this.awarded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'date': date,
      'studentId': studentId,
      'status': status,
      'awarded': awarded,
    };
  }

  factory Attendance.fromJson(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] ?? '',
      groupId: map['groupId'] ?? '',
      date: map['date'] ?? '',
      studentId: map['studentId'] ?? '',
      status: map['status'] ?? 'absent',
      awarded: map['awarded'] ?? false,
    );
  }
}
