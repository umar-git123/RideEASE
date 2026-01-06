import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Send a message
  Future<void> sendMessage(String rideId, String senderId, String message) async {
    await _supabase.from('messages').insert({
      'ride_id': rideId,
      'sender_id': senderId,
      'message': message,
    });
  }

  // Get real-time stream of messages for a ride
  Stream<List<Map<String, dynamic>>> getMessagesStream(String rideId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('ride_id', rideId)
        .order('created_at', ascending: true);
  }

  // Fetch all messages for a ride (one-time)
  Future<List<MessageModel>> getMessages(String rideId) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('ride_id', rideId)
        .order('created_at', ascending: true);

    return (response as List).map((e) => MessageModel.fromJson(e)).toList();
  }
}
