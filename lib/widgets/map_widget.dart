import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/theme.dart';

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
  final List<LatLng>? routePoints; // Route line from pickup to destination
  final Color? routeColor;
  final double routeStrokeWidth;
  final bool showRouteShadow;

  const MapWidget({
    Key? key,
    required this.initialPosition,
    this.markers = const [],
    this.onTap,
    this.mapController,
    this.routePoints,
    this.routeColor,
    this.routeStrokeWidth = 5.0,
    this.showRouteShadow = true,
  }) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _internalController = MapController();

  MapController get _controller => widget.mapController ?? _internalController;

  @override
  Widget build(BuildContext context) {
    final routeColor = widget.routeColor ?? AppTheme.primaryColor;
    
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: widget.initialPosition,
        initialZoom: 15.0,
        onTap: widget.onTap,
      ),
      children: [
        // Dark themed map tiles
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.rideease.app',
        ),
        
        // Route line (polyline) - with shadow effect
        if (widget.routePoints != null && widget.routePoints!.length >= 2) ...[
          // Shadow/glow layer
          if (widget.showRouteShadow)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: widget.routePoints!,
                  strokeWidth: widget.routeStrokeWidth + 6,
                  color: routeColor.withOpacity(0.3),
                ),
              ],
            ),
          // Main route line
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.routePoints!,
                strokeWidth: widget.routeStrokeWidth,
                color: routeColor,
                borderStrokeWidth: 2,
                borderColor: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ],
        
        // Markers
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
                  // Marker with shadow
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: m.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: m.color.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(m.icon, color: Colors.white, size: 24),
                  ),
                  if (m.title != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundCard.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        m.title!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
