import 'dart:convert';

class User {
  final String id;
  final String name;
  final String login;
  final String password;
  final String role; // 'admin', 'teacher', 'student'
  final String phone;
  final String avatarUrl;
  final int coins;
  final List<String> groupIds;

  User({
    required this.id,
    required this.name,
    required this.login,
    required this.password,
    required this.role,
    required this.phone,
    this.avatarUrl = '',
    this.coins = 0,
    this.groupIds = const [],
  });

  User copyWith({
    String? id,
    String? name,
    String? login,
    String? password,
    String? role,
    String? phone,
    String? avatarUrl,
    int? coins,
    List<String>? groupIds,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      login: login ?? this.login,
      password: password ?? this.password,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coins: coins ?? this.coins,
      groupIds: groupIds ?? this.groupIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'login': login,
      'password': password,
      'role': role,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'coins': coins,
      'groupIds': groupIds,
    };
  }

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      login: map['login'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'student',
      phone: map['phone'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      coins: map['coins'] ?? 0,
      groupIds: List<String>.from(map['groupIds'] ?? []),
    );
  }

  String toJsonString() => json.encode(toJson());

  factory User.fromJsonString(String source) => User.fromJson(json.decode(source));
}
