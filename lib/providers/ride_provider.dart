import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ride_model.dart';
import '../services/ride_service.dart';
import '../services/location_service.dart';

class RideProvider extends ChangeNotifier {
  final RideService _rideService = RideService();
  final LocationService _locationService = LocationService();

  RideModel? _currentRide;
  List<RideModel> _rideHistory = [];
  List<RideModel> _availableRides = []; // For drivers
  LatLng? _currentLocation;
  bool _isLoading = false;
  
  // Realtime subscriptions
  StreamSubscription<Position>? _positionStream;
  StreamSubscription? _availableRidesSubscription;
  StreamSubscription? _rideStreamSubscription;
  Timer? _pollingTimer; // Polling fallback for mobile

  RideModel? get currentRide => _currentRide;
  List<RideModel> get rideHistory => _rideHistory;
  List<RideModel> get availableRides => _availableRides;
  LatLng? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;

  Future<void> getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      _currentLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // Start tracking location and updating DB if rideId is provided (Driver Mode)
  void startLocationTracking(String rideId) {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10, // Update every 10 meters
    );
    
    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (position != null) {
        _currentLocation = LatLng(position.latitude, position.longitude);
        notifyListeners(); // Update local map
        
        // Update DB
        _rideService.updateDriverLocation(rideId, position.latitude, position.longitude);
      }
    });
  }

  void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  Future<void> requestRide(RideModel ride) async {
    _isLoading = true;
    notifyListeners();
    await _rideService.requestRide(ride);
    _currentRide = ride;
    subscribeToRideStream(ride.id); // Start listening to updates immediately
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAvailableRides() async {
    _isLoading = true;
    notifyListeners();
    _availableRides = await _rideService.getAvailableRides();
    _isLoading = false;
    notifyListeners();
  }

  Timer? _availableRidesPollingTimer; // Add polling timer for available rides
  
  // NEW: Subscribe to real-time available rides stream (for drivers)
  void subscribeToAvailableRides() {
    _availableRidesSubscription?.cancel();
    _availableRidesPollingTimer?.cancel();
    
    print('DEBUG: Subscribing to available rides stream');
    
    // Subscribe to realtime stream
    _availableRidesSubscription = _rideService.getAvailableRidesStream().listen(
      (data) {
        print('DEBUG: Available rides stream update: ${data.length} rides');
        _availableRides = data.map((e) => RideModel.fromJson(e)).toList();
        // Sort by created_at descending
        _availableRides.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      },
      onError: (error) {
        print('DEBUG: Available rides stream error: $error');
      },
    );
    
    // Also start polling as fallback (every 5 seconds)
    _availableRidesPollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      print('DEBUG: Polling available rides');
      try {
        final rides = await _rideService.getAvailableRides();
        if (rides.length != _availableRides.length || 
            (rides.isNotEmpty && _availableRides.isEmpty) ||
            (rides.isEmpty && _availableRides.isNotEmpty)) {
          print('DEBUG: Polling found ${rides.length} rides');
          _availableRides = rides;
          notifyListeners();
        }
      } catch (e) {
        print('DEBUG: Polling error: $e');
      }
    });
  }

  // NEW: Unsubscribe from available rides stream
  void unsubscribeFromAvailableRides() {
    _availableRidesSubscription?.cancel();
    _availableRidesSubscription = null;
    _availableRidesPollingTimer?.cancel();
    _availableRidesPollingTimer = null;
  }

  Future<void> acceptRide(RideModel ride, String driverId) async {
    _isLoading = true;
    notifyListeners();
    
    await _rideService.acceptRide(ride.id, driverId);
    
    // Update local state
    _currentRide = RideModel(
      id: ride.id,
      riderId: ride.riderId,
      driverId: driverId,
      pickupLat: ride.pickupLat,
      pickupLng: ride.pickupLng,
      destinationLat: ride.destinationLat,
      destinationLng: ride.destinationLng,
      status: 'accepted',
      createdAt: ride.createdAt,
    );
    
    _availableRides.removeWhere((r) => r.id == ride.id);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeRide(String rideId) async {
    stopLocationTracking(); // Stop tracking
    await _rideService.completeRide(rideId);
    // Don't clear currentRide here, let the UI show completion summary
    if (_currentRide != null) {
      _currentRide = RideModel(
        id: _currentRide!.id,
        riderId: _currentRide!.riderId,
        driverId: _currentRide!.driverId,
        pickupLat: _currentRide!.pickupLat,
        pickupLng: _currentRide!.pickupLng,
        destinationLat: _currentRide!.destinationLat,
        destinationLng: _currentRide!.destinationLng,
        pickupAddress: _currentRide!.pickupAddress,
        destinationAddress: _currentRide!.destinationAddress,
        fare: _currentRide!.fare,
        status: 'completed',
        createdAt: _currentRide!.createdAt,
      );
    }
    notifyListeners();
  }

  // Driver arrived at pickup - notify rider
  Future<void> arrivedAtPickup(String rideId) async {
    await _rideService.arrivedAtPickup(rideId);
    if (_currentRide != null) {
      _currentRide = RideModel(
        id: _currentRide!.id,
        riderId: _currentRide!.riderId,
        driverId: _currentRide!.driverId,
        pickupLat: _currentRide!.pickupLat,
        pickupLng: _currentRide!.pickupLng,
        destinationLat: _currentRide!.destinationLat,
        destinationLng: _currentRide!.destinationLng,
        pickupAddress: _currentRide!.pickupAddress,
        destinationAddress: _currentRide!.destinationAddress,
        fare: _currentRide!.fare,
        status: 'arrived',
        createdAt: _currentRide!.createdAt,
      );
    }
    notifyListeners();
  }

  // Clear ride after viewing summary
  void clearCurrentRide() {
    _currentRide = null;
    _rideStreamSubscription?.cancel();
    _rideStreamSubscription = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    notifyListeners();
  }


  // NEW: Cancel a ride
  Future<void> cancelRide(String rideId) async {
    _isLoading = true;
    notifyListeners();
    await _rideService.cancelRide(rideId);
    _currentRide = null;
    _rideStreamSubscription?.cancel();
    _rideStreamSubscription = null;
    _isLoading = false;
    notifyListeners();
  }
  
  void subscribeToRideStream(String rideId) {
    _rideStreamSubscription?.cancel();
    _pollingTimer?.cancel();
    print('DEBUG: Subscribing to ride stream for ride: $rideId');
    
    // Subscribe to realtime stream
    _rideStreamSubscription = _rideService.getRideStream(rideId).listen(
      (data) {
        print('DEBUG: Ride stream update received: ${data.length} records');
        if (data.isNotEmpty) {
          final newRide = RideModel.fromJson(data.first);
          print('DEBUG: Ride status: ${newRide.status}, driverId: ${newRide.driverId}');
          _currentRide = newRide;
          notifyListeners();
        }
      },
      onError: (error) {
        print('DEBUG: Ride stream error: $error');
      },
      onDone: () {
        print('DEBUG: Ride stream closed');
      },
    );
    
    // Also start polling as fallback (every 3 seconds)
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      print('DEBUG: Polling ride status for: $rideId');
      final ride = await _rideService.getRideById(rideId);
      if (ride != null && _currentRide?.status != ride.status) {
        print('DEBUG: Polling found status change: ${ride.status}');
        _currentRide = ride;
        notifyListeners();
        
        // Stop polling once ride is completed or cancelled
        if (ride.status == 'completed' || ride.status == 'cancelled') {
          timer.cancel();
        }
      }
    });
  }

  Future<void> fetchRideHistory(String userId, String role) async {
      _isLoading = true;
      notifyListeners();
      _rideHistory = await _rideService.getRideHistory(userId, role);
      _isLoading = false;
      notifyListeners();
  }

  @override
  void dispose() {
    stopLocationTracking();
    unsubscribeFromAvailableRides();
    _rideStreamSubscription?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }
}
