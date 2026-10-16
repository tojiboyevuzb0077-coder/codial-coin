class CoinTransaction {
  final String id;
  final String userId;
  final int amount;
  final String reason;
  final String date; // yyyy-MM-dd HH:mm
  final String type; // 'earn', 'spend'

  CoinTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.reason,
    required this.date,
    required this.type,
  });

  CoinTransaction copyWith({
    String? id,
    String? userId,
    int? amount,
    String? reason,
    String? date,
    String? type,
  }) {
    return CoinTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'reason': reason,
      'date': date,
      'type': type,
    };
  }

  factory CoinTransaction.fromJson(Map<String, dynamic> map) {
    return CoinTransaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: map['amount'] ?? 0,
      reason: map['reason'] ?? '',
      date: map['date'] ?? '',
      type: map['type'] ?? 'earn',
    );
  }
}
