import 'package:flutter/material.dart';
import '../../core/theme.dart';

class EmergencyScreen extends StatelessWidget {
  final String? rideId;
  final String? driverName;
  
  const EmergencyScreen({
    Key? key,
    this.rideId,
    this.driverName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Emergency'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // SOS Button
            GestureDetector(
              onTap: () => _showSOSConfirmation(context),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF416C),
                      Color(0xFFFF4B2B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.errorColor.withOpacity(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sos,
                        size: 48,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap for emergency help',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Quick Actions
            Container(
              decoration: AppTheme.cardDecoration(),
              child: Column(
                children: [
                  _buildEmergencyAction(
                    context,
                    icon: Icons.local_police,
                    title: 'Call Police',
                    subtitle: 'Emergency: 911',
                    color: AppTheme.infoColor,
                    onTap: () => _callEmergency(context, 'Police'),
                  ),
                  _buildDivider(),
                  _buildEmergencyAction(
                    context,
                    icon: Icons.local_hospital,
                    title: 'Call Ambulance',
                    subtitle: 'Medical emergency',
                    color: AppTheme.errorColor,
                    onTap: () => _callEmergency(context, 'Ambulance'),
                  ),
                  _buildDivider(),
                  _buildEmergencyAction(
                    context,
                    icon: Icons.fire_truck,
                    title: 'Call Fire Department',
                    subtitle: 'Fire emergency',
                    color: AppTheme.warningColor,
                    onTap: () => _callEmergency(context, 'Fire Department'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Share Location
            Container(
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
                    Icons.share_location,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: const Text(
                  'Share Ride Details',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Send your current location and trip details',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textMuted,
                ),
                onTap: () => _shareRideDetails(context),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Emergency Contacts
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
                        'Emergency Contacts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _addEmergencyContact(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildContactTile(
                    name: 'Mom',
                    phone: '+1 (555) 123-4567',
                    onCall: () {},
                  ),
                  const SizedBox(height: 8),
                  _buildContactTile(
                    name: 'Dad',
                    phone: '+1 (555) 987-6543',
                    onCall: () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Safety Tips
            Container(
              decoration: AppTheme.cardDecoration(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.accentGold,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Safety Tips',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTip('Always verify driver details before entering'),
                  _buildTip('Share your trip with trusted contacts'),
                  _buildTip('Sit in the back seat when possible'),
                  _buildTip('Trust your instincts – end the trip if uncomfortable'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.call,
          color: color,
          size: 20,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 70,
      color: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildContactTile({
    required String name,
    required String phone,
    required VoidCallback onCall,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  phone,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCall,
            icon: const Icon(
              Icons.call,
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.successColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSOSConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('Emergency SOS'),
          ],
        ),
        content: const Text(
          'This will immediately call emergency services and share your location. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calling emergency services...'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            child: const Text(
              'Call Now',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _callEmergency(BuildContext context, String service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $service...'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _shareRideDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share with',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(Icons.message, 'SMS', () => Navigator.pop(context)),
                _buildShareOption(Icons.ios_share, 'Share', () => Navigator.pop(context)),
                _buildShareOption(Icons.copy, 'Copy', () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _addEmergencyContact(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Emergency Contact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Emergency contact added'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  },
                  child: const Text('Save Contact'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
