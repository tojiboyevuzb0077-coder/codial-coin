class Book {
  final String id;
  final String studentId;
  final String title;
  final String author;
  final String startDate; // yyyy-MM-dd
  final String? finishDate; // yyyy-MM-dd
  final String status; // 'reading', 'finished'
  final int daysCount;
  final int coinsEarned;

  Book({
    required this.id,
    required this.studentId,
    required this.title,
    required this.author,
    required this.startDate,
    this.finishDate,
    required this.status,
    required this.daysCount,
    required this.coinsEarned,
  });

  Book copyWith({
    String? id,
    String? studentId,
    String? title,
    String? author,
    String? startDate,
    String? finishDate,
    String? status,
    int? daysCount,
    int? coinsEarned,
  }) {
    return Book(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      author: author ?? this.author,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      status: status ?? this.status,
      daysCount: daysCount ?? this.daysCount,
      coinsEarned: coinsEarned ?? this.coinsEarned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'title': title,
      'author': author,
      'startDate': startDate,
      'finishDate': finishDate,
      'status': status,
      'daysCount': daysCount,
      'coinsEarned': coinsEarned,
    };
  }

  factory Book.fromJson(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      startDate: map['startDate'] ?? '',
      finishDate: map['finishDate'],
      status: map['status'] ?? 'reading',
      daysCount: map['daysCount'] ?? 0,
      coinsEarned: map['coinsEarned'] ?? 0,
    );
  }
}
