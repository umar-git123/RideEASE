import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _vehicleMakeController;
  late TextEditingController _vehicleModelController;
  late TextEditingController _vehiclePlateController;
  late TextEditingController _vehicleColorController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUserData;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _vehicleMakeController = TextEditingController(text: user?.vehicleMake ?? '');
    _vehicleModelController = TextEditingController(text: user?.vehicleModel ?? '');
    _vehiclePlateController = TextEditingController(text: user?.vehiclePlate ?? '');
    _vehicleColorController = TextEditingController(text: user?.vehicleColor ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehiclePlateController.dispose();
    _vehicleColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUserData;
    final isDriver = user?.role == 'driver';

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            TextButton(
              onPressed: () {
                setState(() => _isEditing = false);
                // Reset controllers
                _nameController.text = user?.name ?? '';
                _phoneController.text = user?.phone ?? '';
                _vehicleMakeController.text = user?.vehicleMake ?? '';
                _vehicleModelController.text = user?.vehicleModel ?? '';
                _vehiclePlateController.text = user?.vehiclePlate ?? '';
                _vehicleColorController.text = user?.vehicleColor ?? '';
              },
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isDriver 
                    ? AppTheme.accentGold.withOpacity(0.15)
                    : AppTheme.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDriver ? Icons.drive_eta : Icons.person,
                    size: 16,
                    color: isDriver ? AppTheme.accentGold : AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isDriver ? 'Driver' : 'Rider',
                    style: TextStyle(
                      color: isDriver ? AppTheme.accentGold : AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Basic Info Section
            Container(
              decoration: AppTheme.cardDecoration(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  if (_isEditing) ...[
                    InputField(
                      labelText: 'Full Name',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      labelText: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                  ] else ...[
                    _buildInfoRow(Icons.person_outline, 'Name', user?.name ?? 'Not set'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.email_outlined, 'Email', user?.email ?? 'Not set'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.phone_outlined, 'Phone', user?.phone ?? 'Not set'),
                  ],
                ],
              ),
            ),
            
            // Vehicle Info for Drivers
            if (isDriver) ...[
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_car, color: AppTheme.accentGold, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Vehicle Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    if (_isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: InputField(
                              labelText: 'Make',
                              controller: _vehicleMakeController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InputField(
                              labelText: 'Model',
                              controller: _vehicleModelController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InputField(
                              labelText: 'Color',
                              controller: _vehicleColorController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InputField(
                              labelText: 'Plate',
                              controller: _vehiclePlateController,
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildInfoRow(
                        Icons.directions_car_outlined,
                        'Vehicle',
                        '${user?.vehicleMake ?? ''} ${user?.vehicleModel ?? ''}'.trim().isEmpty 
                            ? 'Not set' 
                            : '${user?.vehicleMake} ${user?.vehicleModel}',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.color_lens_outlined,
                        'Color',
                        user?.vehicleColor ?? 'Not set',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.credit_card,
                        'Plate',
                        user?.vehiclePlate ?? 'Not set',
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            // Save Button
            if (_isEditing) ...[
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Save Changes',
                  isLoading: _isSaving,
                  icon: Icons.check,
                  onPressed: _saveChanges,
                ),
              ),
            ],
            
            // Account Stats
            if (!_isEditing) ...[
              const SizedBox(height: 20),
              Container(
                decoration: AppTheme.cardDecoration(),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.star,
                        value: '5.0',
                        label: 'Rating',
                        color: AppTheme.accentGold,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.directions_car,
                        value: '0',
                        label: 'Trips',
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.calendar_today,
                        value: _getMemberSince(user?.createdAt),
                        label: 'Member Since',
                        color: AppTheme.infoColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
    );
  }

  String _getMemberSince(DateTime? date) {
    if (date == null) return 'N/A';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays < 30) return '${diff.inDays}d';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
    return '${(diff.inDays / 365).floor()}y';
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDriver = authProvider.currentUserData?.role == 'driver';
    
    final success = await authProvider.updateProfile(
      name: _nameController.text.isNotEmpty ? _nameController.text : null,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      vehicleMake: isDriver && _vehicleMakeController.text.isNotEmpty ? _vehicleMakeController.text : null,
      vehicleModel: isDriver && _vehicleModelController.text.isNotEmpty ? _vehicleModelController.text : null,
      vehiclePlate: isDriver && _vehiclePlateController.text.isNotEmpty ? _vehiclePlateController.text : null,
      vehicleColor: isDriver && _vehicleColorController.text.isNotEmpty ? _vehicleColorController.text : null,
    );
    
    setState(() {
      _isSaving = false;
      if (success) {
        _isEditing = false;
      }
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Profile updated!' : 'Failed to update profile'),
          backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    }
  }
}
