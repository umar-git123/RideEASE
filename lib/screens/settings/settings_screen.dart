import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _locationTracking = true;
  String _distanceUnit = 'km';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSectionTitle('Notifications'),
            const SizedBox(height: 12),
            Container(
              decoration: AppTheme.cardDecoration(),
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.notifications_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Receive ride updates and offers',
                    value: _notificationsEnabled,
                    onChanged: (v) => setState(() => _notificationsEnabled = v),
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildSwitchTile(
                    icon: Icons.volume_up_outlined,
                    title: 'Sound',
                    subtitle: 'Play sounds for notifications',
                    value: _soundEnabled,
                    onChanged: (v) => setState(() => _soundEnabled = v),
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildSwitchTile(
                    icon: Icons.vibration,
                    title: 'Vibration',
                    subtitle: 'Vibrate on notifications',
                    value: _vibrationEnabled,
                    onChanged: (v) => setState(() => _vibrationEnabled = v),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            
            // Privacy Section
            _buildSectionTitle('Privacy & Security'),
            const SizedBox(height: 12),
            Container(
              decoration: AppTheme.cardDecoration(),
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.location_on_outlined,
                    title: 'Location Tracking',
                    subtitle: 'Allow app to track your location',
                    value: _locationTracking,
                    onChanged: (v) => setState(() => _locationTracking = v),
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildNavigationTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildNavigationTile(
                    icon: Icons.shield_outlined,
                    title: 'Two-Factor Authentication',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            
            // Preferences Section
            _buildSectionTitle('Preferences'),
            const SizedBox(height: 12),
            Container(
              decoration: AppTheme.cardDecoration(),
              child: Column(
                children: [
                  _buildSelectionTile(
                    icon: Icons.straighten,
                    title: 'Distance Unit',
                    value: _distanceUnit == 'km' ? 'Kilometers' : 'Miles',
                    onTap: () => _showDistanceUnitPicker(),
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildSelectionTile(
                    icon: Icons.language,
                    title: 'Language',
                    value: _language,
                    onTap: () => _showLanguagePicker(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            
            // App Section
            _buildSectionTitle('App'),
            const SizedBox(height: 12),
            Container(
              decoration: AppTheme.cardDecoration(),
              child: Column(
                children: [
                  _buildNavigationTile(
                    icon: Icons.storage_outlined,
                    title: 'Clear Cache',
                    trailing: Text(
                      '12.5 MB',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cache cleared'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildNavigationTile(
                    icon: Icons.info_outline,
                    title: 'App Version',
                    trailing: Text(
                      '1.0.0',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    showChevron: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textMuted,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing,
          if (showChevron) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textMuted,
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSelectionTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: AppTheme.textMuted,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showDistanceUnitPicker() {
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
              'Distance Unit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Kilometers (km)'),
              leading: Radio<String>(
                value: 'km',
                groupValue: _distanceUnit,
                onChanged: (v) {
                  setState(() => _distanceUnit = v!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Miles (mi)'),
              leading: Radio<String>(
                value: 'mi',
                groupValue: _distanceUnit,
                onChanged: (v) {
                  setState(() => _distanceUnit = v!);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Portuguese'];
    
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
              'Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...languages.map((lang) => ListTile(
              title: Text(lang),
              leading: Radio<String>(
                value: lang,
                groupValue: _language,
                onChanged: (v) {
                  setState(() => _language = v!);
                  Navigator.pop(context);
                },
              ),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
