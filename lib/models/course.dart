class Course {
  final String id;
  final String name;
  final String description;
  final double uzsPrice;
  final int durationMonths;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.uzsPrice,
    required this.durationMonths,
  });

  Course copyWith({
    String? id,
    String? name,
    String? description,
    double? uzsPrice,
    int? durationMonths,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      uzsPrice: uzsPrice ?? this.uzsPrice,
      durationMonths: durationMonths ?? this.durationMonths,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'uzsPrice': uzsPrice,
      'durationMonths': durationMonths,
    };
  }

  factory Course.fromJson(Map<String, dynamic> map) {
    return Course(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      uzsPrice: (map['uzsPrice'] ?? 0.0).toDouble(),
      durationMonths: map['durationMonths'] ?? 1,
    );
  }
}
