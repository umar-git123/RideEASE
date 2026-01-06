import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMarker {
  final String id;
  final LatLng point;
  final IconData icon;
  final Color color;
  final String? title;

  CustomMarker({
    required this.id,
    required this.point,
    this.icon = Icons.location_on,
    this.color = Colors.red,
    this.title,
  });
}

class MapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final List<CustomMarker> markers;
  final Function(TapPosition, LatLng)? onTap;
  final MapController? mapController;

  const MapWidget({
    Key? key,
    required this.initialPosition,
    this.markers = const [],
    this.onTap,
    this.mapController,
  }) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _internalController = MapController();

  MapController get _controller => widget.mapController ?? _internalController;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: widget.initialPosition,
        initialZoom: 15.0,
        onTap: widget.onTap,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.rideease.app',
        ),
        MarkerLayer(
          markers: widget.markers.map((m) {
            return Marker(
              point: m.point,
              width: 120,
              height: 120,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(m.icon, color: m.color, size: 40),
                  if (m.title != null)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        m.title!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
