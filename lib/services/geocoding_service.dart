import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingResult {
  final String displayName;
  final double lat;
  final double lng;
  final String? type;

  GeocodingResult({
    required this.displayName,
    required this.lat,
    required this.lng,
    this.type,
  });

  factory GeocodingResult.fromNominatim(Map<String, dynamic> json) {
    return GeocodingResult(
      displayName: json['display_name'] ?? '',
      lat: double.parse(json['lat'].toString()),
      lng: double.parse(json['lon'].toString()),
      type: json['type'],
    );
  }
}

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  
  /// Search for addresses based on query string
  /// Returns a list of matching locations
  Future<List<GeocodingResult>> searchAddress(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '5',
        'addressdetails': '1',
      });
      
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'RideEase/1.0 (Flutter App)',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => GeocodingResult.fromNominatim(item)).toList();
      } else {
        print('Geocoding error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Geocoding exception: $e');
      return [];
    }
  }
  
  /// Reverse geocode coordinates to get address
  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse('$_baseUrl/reverse').replace(queryParameters: {
        'lat': lat.toString(),
        'lon': lng.toString(),
        'format': 'json',
        'addressdetails': '1',
      });
      
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'RideEase/1.0 (Flutter App)',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'];
      } else {
        return null;
      }
    } catch (e) {
      print('Reverse geocoding exception: $e');
      return null;
    }
  }
}
