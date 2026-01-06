class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'rider' or 'driver'
  final String? phone;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final email = json['email'] as String;
    return UserModel(
      id: json['id'] as String,
      email: email,
      name: json['name'] as String? ?? email.split('@')[0],
      role: json['role'] as String,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

