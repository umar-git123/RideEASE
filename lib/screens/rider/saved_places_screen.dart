import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  final List<SavedPlace> _savedPlaces = [
    SavedPlace(
      id: '1',
      name: 'Home',
      address: '123 Main Street, Apt 4B',
      icon: Icons.home,
      color: AppTheme.primaryColor,
    ),
    SavedPlace(
      id: '2',
      name: 'Work',
      address: '456 Business Ave, Floor 12',
      icon: Icons.work,
      color: AppTheme.infoColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Saved Places'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Access Section
            Text(
              'Quick Access',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Home and Work Cards
            Row(
              children: [
                Expanded(
                  child: _buildQuickAccessCard(
                    icon: Icons.home,
                    label: 'Home',
                    address: _getAddressForType('Home'),
                    color: AppTheme.primaryColor,
                    onTap: () => _editPlace('Home'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAccessCard(
                    icon: Icons.work,
                    label: 'Work',
                    address: _getAddressForType('Work'),
                    color: AppTheme.infoColor,
                    onTap: () => _editPlace('Work'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // All Saved Places
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Places',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _addNewPlace(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add new'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Container(
              decoration: AppTheme.cardDecoration(),
              child: _savedPlaces.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _savedPlaces.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.white.withOpacity(0.05),
                      ),
                      itemBuilder: (context, index) {
                        final place = _savedPlaces[index];
                        return _buildPlaceTile(place, index);
                      },
                    ),
            ),
            
            const SizedBox(height: 32),
            
            // Recent Destinations
            Text(
              'Recent Destinations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              decoration: AppTheme.cardDecoration(),
              child: Column(
                children: [
                  _buildRecentTile(
                    'Central Park',
                    '59th St to 110th St, New York',
                    Icons.park,
                  ),
                  Divider(height: 1, color: Colors.white.withOpacity(0.05)),
                  _buildRecentTile(
                    'Times Square',
                    'Manhattan, New York, NY',
                    Icons.location_city,
                  ),
                  Divider(height: 1, color: Colors.white.withOpacity(0.05)),
                  _buildRecentTile(
                    'JFK Airport',
                    'Queens, NY 11430',
                    Icons.flight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getAddressForType(String type) {
    final place = _savedPlaces.where((p) => p.name == type).firstOrNull;
    return place?.address;
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String label,
    String? address,
    required Color color,
    required VoidCallback onTap,
  }) {
    final hasAddress = address != null && address.isNotEmpty;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasAddress ? address! : 'Tap to add',
              style: TextStyle(
                color: hasAddress ? AppTheme.textSecondary : color,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.bookmark_border,
            size: 48,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No saved places yet',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Save your favorite places for quick access',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceTile(SavedPlace place, int index) {
    return Dismissible(
      key: Key(place.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(() => _savedPlaces.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${place.name} removed')),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorColor,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: place.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(place.icon, color: place.color, size: 20),
        ),
        title: Text(
          place.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          place.address,
          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: AppTheme.textMuted,
          onPressed: () => _editPlace(place.name),
        ),
      ),
    );
  }

  Widget _buildRecentTile(String name, String address, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.textMuted.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.textSecondary, size: 18),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      subtitle: Text(
        address,
        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.bookmark_border, size: 20),
        color: AppTheme.textMuted,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to saved places')),
          );
        },
      ),
    );
  }

  void _editPlace(String placeName) {
    final controller = TextEditingController();
    final existingPlace = _savedPlaces.where((p) => p.name == placeName).firstOrNull;
    if (existingPlace != null) {
      controller.text = existingPlace.address;
    }

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
              Text(
                'Set $placeName Address',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter address...',
                  prefixIcon: const Icon(Icons.search),
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      setState(() {
                        final index = _savedPlaces.indexWhere((p) => p.name == placeName);
                        if (index != -1) {
                          _savedPlaces[index] = SavedPlace(
                            id: _savedPlaces[index].id,
                            name: placeName,
                            address: controller.text,
                            icon: _savedPlaces[index].icon,
                            color: _savedPlaces[index].color,
                          );
                        }
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewPlace() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

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
                'Add New Place',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Place name',
                  hintText: 'e.g. Gym, School',
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter address...',
                  prefixIcon: const Icon(Icons.search),
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && addressController.text.isNotEmpty) {
                      setState(() {
                        _savedPlaces.add(SavedPlace(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          address: addressController.text,
                          icon: Icons.place,
                          color: AppTheme.accentPurple,
                        ));
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Add Place'),
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

class SavedPlace {
  final String id;
  final String name;
  final String address;
  final IconData icon;
  final Color color;

  SavedPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.icon,
    required this.color,
  });
}
