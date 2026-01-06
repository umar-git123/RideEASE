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

  Future<bool> signUp(
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
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _authService.signUp(
        email,
        password,
        role,
        name: name,
        phone: phone,
        vehicleMake: vehicleMake,
        vehicleModel: vehicleModel,
        vehiclePlate: vehiclePlate,
        vehicleColor: vehicleColor,
        vehicleYear: vehicleYear,
      );
      
      final user = _authService.currentUser;
      if (user != null) {
        await _fetchUserData(user.id);
        return true;
      }
      _error = 'Email confirmation may be required. Check your inbox.';
      return false;
    } catch (e) {
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
      _error = 'Login failed: ${e.toString()}';
      debugPrint(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? vehicleMake,
    String? vehicleModel,
    String? vehiclePlate,
    String? vehicleColor,
    String? vehicleYear,
  }) async {
    if (_currentUserData == null) return false;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final success = await _authService.updateUserProfile(
        userId: _currentUserData!.id,
        name: name,
        phone: phone,
        vehicleMake: vehicleMake,
        vehicleModel: vehicleModel,
        vehiclePlate: vehiclePlate,
        vehicleColor: vehicleColor,
        vehicleYear: vehicleYear,
      );
      
      if (success) {
        // Update local data
        _currentUserData = _currentUserData!.copyWith(
          name: name,
          phone: phone,
          vehicleMake: vehicleMake,
          vehicleModel: vehicleModel,
          vehiclePlate: vehiclePlate,
          vehicleColor: vehicleColor,
          vehicleYear: vehicleYear,
        );
      }
      
      return success;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh user data from server
  Future<void> refreshUserData() async {
    if (_currentUserData != null) {
      await _fetchUserData(_currentUserData!.id);
    }
  }

  Future<void> signOut() async {
    _error = null;
    await _authService.signOut();
    _currentUserData = null;
    notifyListeners();
  }
}
