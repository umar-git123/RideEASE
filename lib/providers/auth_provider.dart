import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUserData;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUserData => _currentUserData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isAuthenticated => _authService.currentUser != null;

  Future<void> initialize() async {
    _error = null;
    final user = _authService.currentUser;
    if (user != null) {
      await _fetchUserData(user.id);
    }
  }

  Future<void> _fetchUserData(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUserData = await _authService.getUserData(userId);
    } catch (e) {
      _error = 'Failed to load user data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password, String role) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _authService.signUp(email, password, role);
      // After sign up, we usually need to sign in logic or just fetch data, 
      // Supabase auto signs in on sign up if email confirmation is disabled.
      final user = _authService.currentUser;
      if (user != null) {
        await _fetchUserData(user.id);
        return true;
      }
      _error = 'Email confirmation may be required. Check your inbox.';
      return false; // Email confirmation might be required
    } catch (e) {
      // Show the actual error message
      _error = e.toString();
      debugPrint('Signup error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _authService.signIn(email, password);
      final user = _authService.currentUser;
      if (user != null) {
        await _fetchUserData(user.id);
        return true;
      }
      _error = 'Login failed. Please check your credentials.';
      return false;
    } catch (e) {
      _error = 'Login failed: ${e.toString()}'; // Simple error message
      debugPrint(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _error = null;
    await _authService.signOut();
    _currentUserData = null;
    notifyListeners();
  }
}
