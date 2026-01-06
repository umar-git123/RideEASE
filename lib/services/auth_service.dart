import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signUp(
    String email,
    String password,
    String role, {
    String? name,
    String? phone,
    String? vehicleMake,
    String? vehicleModel,
    String? vehiclePlate,
    String? vehicleColor,
    String? vehicleYear,
  }) async {
    try {
      print('DEBUG: Starting signup for $email');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      print('DEBUG: Auth signup response: ${response.user?.id}');

      if (response.user != null) {
        print('DEBUG: Inserting user into public.users table...');
        
        final userData = {
          'id': response.user!.id,
          'email': email,
          'name': name ?? email.split('@')[0],
          'role': role,
          'phone': phone,
          'created_at': DateTime.now().toIso8601String(),
        };

        // Add vehicle info for drivers
        if (role == 'driver') {
          userData['vehicle_make'] = vehicleMake;
          userData['vehicle_model'] = vehicleModel;
          userData['vehicle_plate'] = vehiclePlate;
          userData['vehicle_color'] = vehicleColor;
          userData['vehicle_year'] = vehicleYear;
        }

        await _supabase.from('users').insert(userData);
        print('DEBUG: User inserted successfully');
      }

      return response;
    } catch (e) {
      print('DEBUG SIGNUP ERROR: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  Future<UserModel?> getUserData(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? vehicleMake,
    String? vehicleModel,
    String? vehiclePlate,
    String? vehicleColor,
    String? vehicleYear,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (vehicleMake != null) updateData['vehicle_make'] = vehicleMake;
      if (vehicleModel != null) updateData['vehicle_model'] = vehicleModel;
      if (vehiclePlate != null) updateData['vehicle_plate'] = vehiclePlate;
      if (vehicleColor != null) updateData['vehicle_color'] = vehicleColor;
      if (vehicleYear != null) updateData['vehicle_year'] = vehicleYear;

      if (updateData.isNotEmpty) {
        await _supabase
            .from('users')
            .update(updateData)
            .eq('id', userId);
      }
      return true;
    } catch (e) {
      print('DEBUG UPDATE ERROR: $e');
      return false;
    }
  }
}
