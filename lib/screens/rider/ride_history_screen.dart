import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_provider.dart';
import 'package:intl/intl.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({Key? key}) : super(key: key);

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUserData != null) {
      Provider.of<RideProvider>(context, listen: false).fetchRideHistory(
        auth.currentUserData!.id,
        auth.currentUserData!.role,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Ride History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: rideProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : rideProvider.rideHistory.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async => _loadHistory(),
                  color: AppTheme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: rideProvider.rideHistory.length,
                    itemBuilder: (context, index) {
                      final ride = rideProvider.rideHistory[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: AppTheme.cardDecoration(),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          title: Text(
                            ride.destinationAddress ?? 'Trip to destination',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM d, yyyy • h:mm a').format(ride.createdAt),
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(ride.status).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _getStatusText(ride.status),
                                      style: TextStyle(
                                        color: _getStatusColor(ride.status),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (ride.fare != null) ...[
                                    const Spacer(),
                                    Text(
                                      '\$${ride.fare!.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            // TODO: Show ride details
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No rides yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your ride history will appear here',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      case 'accepted':
        return AppTheme.infoColor;
      default:
        return AppTheme.textMuted;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'accepted':
        return 'In Progress';
      case 'requested':
        return 'Pending';
      default:
        return status.toUpperCase();
    }
  }
}
