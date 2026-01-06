class RideModel {
  final String id;
  final String riderId;
  final String? driverId;
  final double pickupLat;
  final double pickupLng;
  final String? pickupAddress;
  final double destinationLat;
  final double destinationLng;
  final String? destinationAddress;
  final double? driverLat;
  final double? driverLng;
  final String status;
  final double? fare;
  final DateTime createdAt;

  RideModel({
    required this.id,
    required this.riderId,
    this.driverId,
    required this.pickupLat,
    required this.pickupLng,
    this.pickupAddress,
    required this.destinationLat,
    required this.destinationLng,
    this.destinationAddress,
    this.driverLat,
    this.driverLng,
    required this.status,
    this.fare,
    required this.createdAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'],
      riderId: json['rider_id'],
      driverId: json['driver_id'],
      pickupLat: (json['pickup_lat'] as num).toDouble(),
      pickupLng: (json['pickup_lng'] as num).toDouble(),
      pickupAddress: json['pickup_address'],
      destinationLat: (json['destination_lat'] as num).toDouble(),
      destinationLng: (json['destination_lng'] as num).toDouble(),
      destinationAddress: json['destination_address'],
      driverLat: json['driver_lat'] != null ? (json['driver_lat'] as num).toDouble() : null,
      driverLng: json['driver_lng'] != null ? (json['driver_lng'] as num).toDouble() : null,
      status: json['status'],
      fare: json['fare'] != null ? (json['fare'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rider_id': riderId,
      'driver_id': driverId,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'pickup_address': pickupAddress,
      'destination_lat': destinationLat,
      'destination_lng': destinationLng,
      'destination_address': destinationAddress,
      'driver_lat': driverLat,
      'driver_lng': driverLng,
      'status': status,
      'fare': fare,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
