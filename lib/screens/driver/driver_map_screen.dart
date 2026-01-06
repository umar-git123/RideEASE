import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/map_widget.dart';
import '../chat/chat_screen.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({Key? key}) : super(key: key);

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  @override
  void initState() {
    super.initState();
    // Start tracking when map screen opens (ride is accepted)
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    if (rideProvider.currentRide != null) {
      rideProvider.startLocationTracking(rideProvider.currentRide!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Use Consumer to rebuild only when needed
    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
        final ride = rideProvider.currentRide;

        if (ride == null) {
           return const Center(child: Text('No active ride')); 
        }

        List<CustomMarker> markers = [
          CustomMarker(
             id: 'pickup',
             point: LatLng(ride.pickupLat, ride.pickupLng),
             color: Colors.green,
             title: 'Pickup',
          ),
          CustomMarker(
             id: 'dest',
             point: LatLng(ride.destinationLat, ride.destinationLng),
             color: Colors.red,
             title: 'Dest',
          ),
        ];

        if (rideProvider.currentLocation != null) {
          markers.add(CustomMarker(
            id: 'me',
            point: rideProvider.currentLocation!,
            color: Colors.blue,
            icon: Icons.directions_car,
            title: 'Me',
          ));
        }

        return Stack(
          children: [
            MapWidget(
              initialPosition: rideProvider.currentLocation ?? LatLng(ride.pickupLat, ride.pickupLng),
              markers: markers,
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Ride in Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        'Pickup: ${ride.pickupAddress ?? "Location"}',
                        style: const TextStyle(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('Chat'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      rideId: ride.id,
                                      currentUserId: authProvider.currentUserData!.id,
                                      otherUserName: 'Rider',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Complete',
                              onPressed: () async {
                                await rideProvider.completeRide(ride.id);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
