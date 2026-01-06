import 'package:flutter/material.dart';
import '../models/ride_model.dart';
import '../models/user_model.dart';
import '../core/theme.dart';
import 'custom_button.dart';

class ActiveRidePanel extends StatelessWidget {
  final RideModel ride;
  final UserModel? driver;
  final VoidCallback? onCancel;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onDone;

  const ActiveRidePanel({
    Key? key,
    required this.ride,
    this.driver,
    this.onCancel,
    this.onCall,
    this.onMessage,
    this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDriverAssigned = ride.driverId != null && ride.status != 'requested';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Status Header with animated indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _getStatusColor(ride.status),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _getStatusColor(ride.status).withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _getStatusText(ride.status),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusSubtext(ride.status),
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '\$${(ride.fare ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (isDriverAssigned) ...[
                // Driver Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (driver?.name ?? 'D').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 22,
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
                              driver?.name ?? 'Driver',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.star, size: 16, color: AppTheme.accentGold),
                                const SizedBox(width: 4),
                                const Text(
                                  '4.8',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppTheme.textMuted,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Flexible(
                                  child: Text(
                                    'Toyota Camry • ABC 1234',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.call,
                        label: 'Call',
                        color: AppTheme.successColor,
                        onTap: onCall,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.message,
                        label: 'Chat',
                        color: AppTheme.infoColor,
                        onTap: onMessage,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      icon: Icons.sos,
                      label: '',
                      color: AppTheme.errorColor,
                      onTap: () {},
                      isCompact: true,
                    ),
                  ],
                ),
              ] else ...[
                // Searching State
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Finding your driver...',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'re matching you with a nearby driver',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Ride Details
              Container(
                padding: const EdgeInsets.all(16),
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
                      text: ride.pickupAddress ?? 'Pickup location',
                      isFirst: true,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 11),
                      height: 20,
                      width: 2,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    _buildLocationRow(
                      icon: Icons.location_on,
                      color: AppTheme.errorColor,
                      text: ride.destinationAddress ?? 'Destination',
                      isFirst: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              
              // Cancel Button
              if (ride.status == 'requested' || ride.status == 'accepted')
                CustomButton(
                  text: 'Cancel Ride',
                  color: AppTheme.errorColor.withOpacity(0.15),
                  textColor: AppTheme.errorColor,
                  onPressed: onCancel ?? () {},
                ),
              
              if (ride.status == 'completed') ...[
                CustomButton(
                  text: 'Rate Your Driver',
                  icon: Icons.star,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Done',
                  icon: Icons.check_circle,
                  color: AppTheme.successColor,
                  onPressed: onDone ?? () {},
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color color,
    required String text,
    required bool isFirst,
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
          child: Text(
            text,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    bool isCompact = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 14,
          horizontal: isCompact ? 14 : 0,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Icon(icon, color: color, size: 20),
            if (!isCompact) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'requested':
        return AppTheme.warningColor;
      case 'accepted':
        return AppTheme.primaryColor;
      case 'arrived':
        return AppTheme.successColor;
      case 'completed':
        return AppTheme.successColor;
      default:
        return AppTheme.textMuted;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'requested':
        return 'Finding Driver';
      case 'accepted':
        return 'Driver En Route';
      case 'arrived':
        return 'Driver Arrived!';
      case 'completed':
        return 'Ride Complete';
      default:
        return status;
    }
  }

  String _getStatusSubtext(String status) {
    switch (status) {
      case 'requested':
        return 'Please wait...';
      case 'accepted':
        return 'Arriving in ~5 mins';
      case 'arrived':
        return 'Your driver is at the pickup location!';
      case 'completed':
        return 'Hope you enjoyed your ride!';
      default:
        return '';
    }
  }
}
