import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/map_widget.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../chat/chat_screen.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({Key? key}) : super(key: key);

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  UserModel? _riderData;

  @override
  void initState() {
    super.initState();
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    if (rideProvider.currentRide != null) {
      rideProvider.startLocationTracking(rideProvider.currentRide!.id);
      _fetchRiderData(rideProvider.currentRide!.riderId);
    }
  }

  Future<void> _fetchRiderData(String riderId) async {
    final userData = await AuthService().getUserData(riderId);
    if (mounted) {
      setState(() => _riderData = userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
        final ride = rideProvider.currentRide;

        if (ride == null) {
          return const Center(
            child: Text('No active ride', style: TextStyle(color: AppTheme.textMuted)),
          );
        }

        // Show completion summary
        if (ride.status == 'completed') {
          return _buildCompletionSummary(context, rideProvider, ride);
        }

        List<CustomMarker> markers = [
          CustomMarker(
            id: 'pickup',
            point: LatLng(ride.pickupLat, ride.pickupLng),
            color: AppTheme.successColor,
            title: 'Pickup',
            icon: Icons.trip_origin,
          ),
          CustomMarker(
            id: 'dest',
            point: LatLng(ride.destinationLat, ride.destinationLng),
            color: AppTheme.errorColor,
            title: 'Destination',
            icon: Icons.place,
          ),
        ];
        
        final isArrived = ride.status == 'arrived';
        
        // Build route points
        List<LatLng>? routePoints;
        final pickupPoint = LatLng(ride.pickupLat, ride.pickupLng);
        final destPoint = LatLng(ride.destinationLat, ride.destinationLng);

        if (rideProvider.currentLocation != null) {
          markers.add(CustomMarker(
            id: 'me',
            point: rideProvider.currentLocation!,
            color: AppTheme.primaryColor,
            icon: Icons.directions_car,
            title: 'Me',
          ));
          
          // Route from driver to pickup to destination
          if (isArrived) {
            // Already at pickup, just show pickup to destination
            routePoints = [pickupPoint, destPoint];
          } else {
            // Show full route: driver -> pickup -> destination
            routePoints = [rideProvider.currentLocation!, pickupPoint, destPoint];
          }
        } else {
          // Just show pickup to destination
          routePoints = [pickupPoint, destPoint];
        }


        return Stack(
          children: [
            MapWidget(
              initialPosition: rideProvider.currentLocation ?? LatLng(ride.pickupLat, ride.pickupLng),
              markers: markers,
              routePoints: routePoints,
              routeColor: isArrived ? AppTheme.successColor : AppTheme.accentGold,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        
                        // Status header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (isArrived ? AppTheme.successColor : AppTheme.primaryColor).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isArrived ? Icons.location_on : Icons.directions_car,
                                color: isArrived ? AppTheme.successColor : AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArrived ? 'At Pickup Location' : 'Heading to Pickup',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isArrived ? 'Passenger has been notified' : 'Passenger is waiting...',
                                    style: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '\$${(ride.fare ?? 0).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Location info
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            children: [
                              _buildLocationRow(
                                icon: Icons.trip_origin,
                                color: AppTheme.successColor,
                                label: 'PICKUP',
                                value: ride.pickupAddress ?? 'Pickup Location',
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 11),
                                child: Container(
                                  height: 16,
                                  width: 2,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              _buildLocationRow(
                                icon: Icons.location_on,
                                color: AppTheme.errorColor,
                                label: 'DROP-OFF',
                                value: ride.destinationAddress ?? 'Destination',
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: AppTheme.successColor.withOpacity(0.5)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.phone, color: AppTheme.successColor),
                                label: const Text('Call', style: TextStyle(color: AppTheme.successColor)),
                                onPressed: () => _callRider(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: AppTheme.infoColor.withOpacity(0.5)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.infoColor),
                                label: const Text('Chat', style: TextStyle(color: AppTheme.infoColor)),
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
                              flex: 2,
                              child: CustomButton(
                                text: isArrived ? 'Complete Ride' : 'Arrived at Pickup',
                                icon: isArrived ? Icons.check : Icons.location_on,
                                onPressed: () async {
                                  if (isArrived) {
                                    await rideProvider.completeRide(ride.id);
                                  } else {
                                    await rideProvider.arrivedAtPickup(ride.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Passenger notified that you\'ve arrived!'),
                                          backgroundColor: AppTheme.successColor,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Cancel Ride Button
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: AppTheme.errorColor,
                            ),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Cancel Ride'),
                            onPressed: () => _showCancelDialog(context, rideProvider, ride.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 12),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionSummary(BuildContext context, RideProvider rideProvider, ride) {
    return Container(
      color: AppTheme.backgroundDark,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Success icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.successColor, AppTheme.successColor.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ride Completed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Great job, you earned',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '\$${(ride.fare ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              
              // Trip summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trip Summary',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Pickup', ride.pickupAddress ?? 'Location'),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Drop-off', ride.destinationAddress ?? 'Destination'),
                  ],
                ),
              ),
              
              const SizedBox(height: 28),
              
              // Back button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Back to Dashboard',
                  icon: Icons.home,
                  onPressed: () {
                    rideProvider.clearCurrentRide();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context, RideProvider rideProvider, String rideId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Ride?'),
        content: const Text('Are you sure you want to cancel this ride? The passenger will be notified.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('No', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await rideProvider.cancelRide(rideId);
              rideProvider.clearCurrentRide();
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _callRider(BuildContext context) async {
    if (_riderData?.phone != null && _riderData!.phone!.isNotEmpty) {
      final Uri phoneUri = Uri(scheme: 'tel', path: _riderData!.phone);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open phone app')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rider phone number not available')),
        );
      }
    }
  }
}
