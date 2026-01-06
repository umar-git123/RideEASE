class MessageModel {
  final String id;
  final String rideId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.rideId,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      rideId: json['ride_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'sender_id': senderId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
