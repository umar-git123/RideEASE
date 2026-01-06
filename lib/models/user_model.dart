class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'rider' or 'driver'
  final String? phone;
  // Vehicle info for drivers
  final String? vehicleMake;
  final String? vehicleModel;
  final String? vehiclePlate;
  final String? vehicleColor;
  final String? vehicleYear;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.vehicleMake,
    this.vehicleModel,
    this.vehiclePlate,
    this.vehicleColor,
    this.vehicleYear,
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
      vehicleMake: json['vehicle_make'] as String?,
      vehicleModel: json['vehicle_model'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      vehicleColor: json['vehicle_color'] as String?,
      vehicleYear: json['vehicle_year'] as String?,
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
      'vehicle_make': vehicleMake,
      'vehicle_model': vehicleModel,
      'vehicle_plate': vehiclePlate,
      'vehicle_color': vehicleColor,
      'vehicle_year': vehicleYear,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Copy with for updating user data
  UserModel copyWith({
    String? name,
    String? phone,
    String? vehicleMake,
    String? vehicleModel,
    String? vehiclePlate,
    String? vehicleColor,
    String? vehicleYear,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role,
      phone: phone ?? this.phone,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      createdAt: createdAt,
    );
  }
}


