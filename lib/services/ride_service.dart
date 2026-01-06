import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ride_model.dart';

class RideService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create a new ride request
  Future<void> requestRide(RideModel ride) async {
    await _supabase.from('rides').insert(ride.toJson());
  }

  // Fetch available rides (for drivers) - status 'requested'
  Future<List<RideModel>> getAvailableRides() async {
    final response = await _supabase
        .from('rides')
        .select()
        .eq('status', 'requested')
        .order('created_at', ascending: false);
    
    return (response as List).map((e) => RideModel.fromJson(e)).toList();
  }

  // Accept a ride
  Future<void> acceptRide(String rideId, String driverId) async {
    await _supabase.from('rides').update({
      'driver_id': driverId,
      'status': 'accepted',
    }).eq('id', rideId);
  }

  // Complete a ride
  Future<void> completeRide(String rideId) async {
    await _supabase.from('rides').update({
      'status': 'completed',
    }).eq('id', rideId);
  }

  // STREAM: Realtime ride updates
  Stream<List<Map<String, dynamic>>> getRideStream(String rideId) {
    return _supabase
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('id', rideId);
  }

  // NEW: Fetch a single ride by ID (for polling fallback)
  Future<RideModel?> getRideById(String rideId) async {
    try {
      final response = await _supabase
          .from('rides')
          .select()
          .eq('id', rideId)
          .single();
      return RideModel.fromJson(response);
    } catch (e) {
      print('Error fetching ride: $e');
      return null;
    }
  }

  // UPDATE: Driver Location
  Future<void> updateDriverLocation(String rideId, double lat, double lng) async {
    await _supabase.from('rides').update({
      'driver_lat': lat,
      'driver_lng': lng,
    }).eq('id', rideId);
  }


  // Get User Ride History
  Future<List<RideModel>> getRideHistory(String userId, String role) async {
    final column = role == 'rider' ? 'rider_id' : 'driver_id';
    final response = await _supabase
        .from('rides')
        .select()
        .eq(column, userId)
        .eq('status', 'completed') // Only completed rides
        .order('created_at', ascending: false);

    return (response as List).map((e) => RideModel.fromJson(e)).toList();
  }

  // NEW: Stream of all available rides for drivers (real-time)
  Stream<List<Map<String, dynamic>>> getAvailableRidesStream() {
    return _supabase
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('status', 'requested');
  }

  // NEW: Cancel a ride
  Future<void> cancelRide(String rideId) async {
    await _supabase.from('rides').update({
      'status': 'cancelled',
    }).eq('id', rideId);
  }
}
