import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_provider.dart';
import '../../widgets/map_widget.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../support/support_screen.dart';
import '../notifications/notifications_screen.dart';
import '../common/emergency_screen.dart';
import 'request_ride_screen.dart';
import 'ride_history_screen.dart';
import 'saved_places_screen.dart';
import '../../widgets/active_ride_panel.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../chat/chat_screen.dart';

class RiderDashboard extends StatefulWidget {
  const RiderDashboard({Key? key}) : super(key: key);

  @override
  State<RiderDashboard> createState() => _RiderDashboardState();
}

class _RiderDashboardState extends State<RiderDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();
  UserModel? _driverData;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    try {
      setState(() => _locationError = null);
      await rideProvider.getCurrentLocation();
    } catch (e) {
      if (mounted) {
        setState(() => _locationError = e.toString());
      }
    }
  }

  Future<void> _fetchDriverData(String driverId) async {
    final userData = await AuthService().getUserData(driverId);
    if (mounted) {
      setState(() {
        _driverData = userData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final theme = Theme.of(context);
    final currentRide = rideProvider.currentRide;

    if (currentRide?.driverId != null && _driverData?.id != currentRide?.driverId) {
      _fetchDriverData(currentRide!.driverId!);
    }

    List<CustomMarker> markers = [];
    
    final defaultLocation = LatLng(40.7128, -74.0060);
    final mapCenter = rideProvider.currentLocation ?? defaultLocation;
    
    if (rideProvider.currentLocation != null) {
      markers.add(CustomMarker(
        id: 'my_loc',
        point: rideProvider.currentLocation!,
        title: 'Me',
        color: AppTheme.primaryColor,
        icon: Icons.my_location,
      ));
    }
    
    if (currentRide != null) {
      if (currentRide.status == 'accepted' && currentRide.driverLat != null && currentRide.driverLng != null) {
        markers.add(CustomMarker(
          id: 'driver',
          point: LatLng(currentRide.driverLat!, currentRide.driverLng!),
          icon: Icons.directions_car,
          color: AppTheme.accentGold,
          title: 'Driver',
        ));
      }
      
      markers.add(CustomMarker(
        id: 'pickup',
        point: LatLng(currentRide.pickupLat, currentRide.pickupLng),
        color: AppTheme.successColor,
        title: 'Pickup',
      ));
      markers.add(CustomMarker(
        id: 'dest',
        point: LatLng(currentRide.destinationLat, currentRide.destinationLng),
        color: AppTheme.errorColor,
        title: 'Dest',
      ));
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundDark,
      drawer: _buildDrawer(context, authProvider),
      body: Stack(
        children: [
          MapWidget(
            mapController: _mapController,
            initialPosition: mapCenter,
            markers: markers,
          ),
          
          // Location Error Banner
          if (_locationError != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warningColor.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off, color: AppTheme.warningColor),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Location unavailable. Enable location to see your position.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ),
                    TextButton(
                      onPressed: _initLocation,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          
          // Menu Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundCard,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.menu, color: AppTheme.textPrimary),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),
          ),
          
          // Emergency Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.errorColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.sos, color: Colors.white, size: 22),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                  );
                },
              ),
            ),
          ),
          
          // My Location Button - moved to top near SOS button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 76, // Left of SOS button
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundCard,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.my_location, color: AppTheme.primaryColor),
                onPressed: () async {
                  await _initLocation();
                  if (rideProvider.currentLocation != null) {
                    _mapController.move(rideProvider.currentLocation!, 15);
                  }
                },
              ),
            ),
          ),

          // Bottom Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(context, rideProvider, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUserData;
    
    return Drawer(
      backgroundColor: AppTheme.backgroundDark,
      child: Column(
        children: [
          // User Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.backgroundCard,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Passenger',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppTheme.accentGold,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '5.0',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                      },
                      icon: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  title: 'Home',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: 'Ride History',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RideHistoryScreen()));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.bookmark_outline,
                  title: 'Saved Places',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedPlacesScreen()));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  badge: '3',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                  },
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Divider(color: Colors.white.withOpacity(0.1)),
                ),
                
                _buildDrawerItem(
                  icon: Icons.shield_outlined,
                  title: 'Emergency',
                  iconColor: AppTheme.errorColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen()));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  },
                ),
              ],
            ),
          ),
          
          // Logout
          Container(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.errorColor.withOpacity(0.2)),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.errorColor),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  await authProvider.signOut();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? badge,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppTheme.primaryColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, RideProvider rideProvider, ThemeData theme) {
    final currentRide = rideProvider.currentRide;

    if (currentRide != null) {
      return ActiveRidePanel(
        ride: currentRide,
        driver: _driverData,
        onCancel: () async {
          await rideProvider.cancelRide(currentRide.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ride cancelled')),
            );
          }
        },
        onCall: () {},
        onMessage: () {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                rideId: currentRide.id,
                currentUserId: authProvider.currentUserData!.id,
                otherUserName: _driverData?.email ?? 'Driver',
              ),
            ),
          );
        },
        onDone: () {
          rideProvider.clearCurrentRide();
          _driverData = null;
        },
      );
    }
    
    // "Where to?" panel with dark theme
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Where to?', 
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestRideScreen()));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.search, color: AppTheme.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Search for a destination',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Quick access buttons
            Row(
              children: [
                Expanded(
                  child: _buildQuickAccessButton(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAccessButton(
                    icon: Icons.work_outline,
                    label: 'Work',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.textMuted, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
