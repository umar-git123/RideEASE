import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/custom_button.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  const LocationPickerScreen({Key? key, this.initialPosition}) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _currentPosition;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Default to San Francisco if null
    _currentPosition = widget.initialPosition ?? const LatLng(37.7749, -122.4194);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Location')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 15,
              onPositionChanged: (pos, hasGesture) {
                if (pos.center != null) {
                  _currentPosition = pos.center!;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.rideease.app',
              ),
            ],
          ),
          const Center(
            child: Icon(Icons.location_pin, size: 50, color: Colors.red),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: CustomButton(
              text: 'Confirm Location',
              onPressed: () {
                Navigator.pop(context, _currentPosition);
              },
            ),
          ),
        ],
      ),
    );
  }
}
