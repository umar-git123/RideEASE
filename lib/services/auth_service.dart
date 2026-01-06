import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password, String role) async {
    try {
      // 1. Sign up with Supabase Auth
      print('DEBUG: Starting signup for $email');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      print('DEBUG: Auth signup response: ${response.user?.id}');

      // 2. Insert into public.users table if sign up is successful
      if (response.user != null) {
        print('DEBUG: Inserting user into public.users table...');
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'role': role,
          'created_at': DateTime.now().toIso8601String(),
        });
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
      // Handle error or return null
      return null;
    }
  }
}
