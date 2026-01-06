import 'package:flutter/material.dart';
import '../../core/theme.dart';

class VehicleDetailsScreen extends StatelessWidget {
  const VehicleDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Edit',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Vehicle Image Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.2),
                    AppTheme.backgroundCard,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundCard,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Toyota Camry',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '2022 • Sedan',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'ABC-1234',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Vehicle Details
            Container(
              decoration: AppTheme.cardDecoration(),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.color_lens_outlined,
                    label: 'Color',
                    value: 'Silver',
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    icon: Icons.category_outlined,
                    label: 'Type',
                    value: 'Sedan',
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    icon: Icons.event_seat_outlined,
                    label: 'Seats',
                    value: '4 Passengers',
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Year',
                    value: '2022',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Documents Section
            Container(
              decoration: AppTheme.cardDecoration(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Documents',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.successColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: AppTheme.successColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentTile(
                    icon: Icons.description_outlined,
                    title: 'Vehicle Registration',
                    status: DocumentStatus.verified,
                    expiry: 'Dec 2026',
                  ),
                  const SizedBox(height: 12),
                  _buildDocumentTile(
                    icon: Icons.shield_outlined,
                    title: 'Insurance',
                    status: DocumentStatus.verified,
                    expiry: 'Jun 2026',
                  ),
                  const SizedBox(height: 12),
                  _buildDocumentTile(
                    icon: Icons.car_repair,
                    title: 'Inspection Certificate',
                    status: DocumentStatus.verified,
                    expiry: 'Mar 2026',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Vehicle Stats
            Container(
              decoration: AppTheme.cardDecoration(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vehicle Stats',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.speed,
                          value: '15,420',
                          label: 'Total Miles',
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.directions_car,
                          value: '847',
                          label: 'Total Trips',
                          color: AppTheme.infoColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Add New Vehicle Button
            Container(
              width: double.infinity,
              decoration: AppTheme.glassDecoration(),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: const Text(
                  'Add Another Vehicle',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Register a new vehicle to your account',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textMuted,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add vehicle feature coming soon'),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 13,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 60,
      color: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildDocumentTile({
    required IconData icon,
    required String title,
    required DocumentStatus status,
    required String expiry,
  }) {
    final color = status == DocumentStatus.verified
        ? AppTheme.successColor
        : status == DocumentStatus.pending
            ? AppTheme.warningColor
            : AppTheme.errorColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Expires: $expiry',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            status == DocumentStatus.verified
                ? Icons.check_circle
                : status == DocumentStatus.pending
                    ? Icons.pending
                    : Icons.error,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

enum DocumentStatus { verified, pending, expired }
