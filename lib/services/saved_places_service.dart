import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedPlace {
  final String id;
  final String name;
  final String address;
  final double? lat;
  final double? lng;
  final String? icon;

  SavedPlace({
    required this.id,
    required this.name,
    required this.address,
    this.lat,
    this.lng,
    this.icon,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'lat': lat,
    'lng': lng,
    'icon': icon,
  };

  factory SavedPlace.fromJson(Map<String, dynamic> json) => SavedPlace(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    address: json['address'] ?? '',
    lat: json['lat']?.toDouble(),
    lng: json['lng']?.toDouble(),
    icon: json['icon'],
  );
  
  SavedPlace copyWith({
    String? id,
    String? name,
    String? address,
    double? lat,
    double? lng,
    String? icon,
  }) {
    return SavedPlace(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      icon: icon ?? this.icon,
    );
  }
}

class SavedPlacesService {
  static const String _prefsKey = 'saved_places';
  
  /// Get all saved places
  Future<List<SavedPlace>> getSavedPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final String? placesJson = prefs.getString(_prefsKey);
    
    if (placesJson == null || placesJson.isEmpty) {
      // Return default Home and Work entries
      return [
        SavedPlace(id: 'home', name: 'Home', address: 'Tap to set location'),
        SavedPlace(id: 'work', name: 'Work', address: 'Tap to set location'),
      ];
    }
    
    try {
      final List<dynamic> data = json.decode(placesJson);
      final places = data.map((item) => SavedPlace.fromJson(item)).toList();
      
      // Ensure Home and Work exist
      if (!places.any((p) => p.name.toLowerCase() == 'home')) {
        places.insert(0, SavedPlace(id: 'home', name: 'Home', address: 'Tap to set location'));
      }
      if (!places.any((p) => p.name.toLowerCase() == 'work')) {
        places.insert(1, SavedPlace(id: 'work', name: 'Work', address: 'Tap to set location'));
      }
      
      return places;
    } catch (e) {
      print('Error loading saved places: $e');
      return [
        SavedPlace(id: 'home', name: 'Home', address: 'Tap to set location'),
        SavedPlace(id: 'work', name: 'Work', address: 'Tap to set location'),
      ];
    }
  }
  
  /// Save all places
  Future<void> savePlaces(List<SavedPlace> places) async {
    final prefs = await SharedPreferences.getInstance();
    final String placesJson = json.encode(places.map((p) => p.toJson()).toList());
    await prefs.setString(_prefsKey, placesJson);
  }
  
  /// Get a specific saved place by name
  Future<SavedPlace?> getSavedPlaceByName(String name) async {
    final places = await getSavedPlaces();
    try {
      return places.firstWhere(
        (p) => p.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Update or add a saved place
  Future<void> savePlace(SavedPlace place) async {
    final places = await getSavedPlaces();
    final index = places.indexWhere((p) => p.id == place.id || p.name.toLowerCase() == place.name.toLowerCase());
    
    if (index != -1) {
      places[index] = place;
    } else {
      places.add(place);
    }
    
    await savePlaces(places);
  }
  
  /// Delete a saved place
  Future<void> deletePlace(String id) async {
    final places = await getSavedPlaces();
    places.removeWhere((p) => p.id == id);
    await savePlaces(places);
  }
  
  /// Check if Home location is set
  Future<bool> isHomeSet() async {
    final home = await getSavedPlaceByName('Home');
    return home != null && home.lat != null && home.lng != null;
  }
  
  /// Check if Work location is set
  Future<bool> isWorkSet() async {
    final work = await getSavedPlaceByName('Work');
    return work != null && work.lat != null && work.lng != null;
  }
}
