import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';

class SupabaseClientManager {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }
}
