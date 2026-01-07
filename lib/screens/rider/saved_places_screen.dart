import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';
import '../../services/saved_places_service.dart';
import '../../services/geocoding_service.dart';
import 'location_picker_screen.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  final SavedPlacesService _savedPlacesService = SavedPlacesService();
  final GeocodingService _geocodingService = GeocodingService();
  List<SavedPlace> _savedPlaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPlaces();
  }

  Future<void> _loadSavedPlaces() async {
    setState(() => _isLoading = true);
    final places = await _savedPlacesService.getSavedPlaces();
    setState(() {
      _savedPlaces = places;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Saved Places'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                          place: _getPlaceByName('Home'),
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAccessCard(
                          icon: Icons.work,
                          label: 'Work',
                          place: _getPlaceByName('Work'),
                          color: AppTheme.infoColor,
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
                ],
              ),
            ),
    );
  }

  SavedPlace? _getPlaceByName(String name) {
    try {
      return _savedPlaces.firstWhere(
        (p) => p.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String label,
    required SavedPlace? place,
    required Color color,
  }) {
    final bool hasLocation = place != null && place.lat != null && place.lng != null;
    final String subtitle = hasLocation 
        ? place!.address 
        : 'Tap to set location';
    
    return GestureDetector(
      onTap: () => _editPlace(label, place),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (hasLocation)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppTheme.successColor,
                      size: 14,
                    ),
                  ),
              ],
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
              subtitle,
              style: TextStyle(
                color: hasLocation ? AppTheme.textSecondary : color,
                fontSize: 12,
              ),
              maxLines: 2,
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
    final hasLocation = place.lat != null && place.lng != null;
    final IconData placeIcon = place.name.toLowerCase() == 'home' 
        ? Icons.home 
        : place.name.toLowerCase() == 'work' 
            ? Icons.work 
            : Icons.place;
    final Color placeColor = place.name.toLowerCase() == 'home'
        ? AppTheme.primaryColor
        : place.name.toLowerCase() == 'work'
            ? AppTheme.infoColor
            : AppTheme.accentPurple;

    return Dismissible(
      key: Key(place.id),
      direction: place.name.toLowerCase() == 'home' || place.name.toLowerCase() == 'work'
          ? DismissDirection.none  // Can't delete Home or Work
          : DismissDirection.endToStart,
      onDismissed: (_) async {
        await _savedPlacesService.deletePlace(place.id);
        await _loadSavedPlaces();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${place.name} removed')),
          );
        }
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
            color: placeColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(placeIcon, color: placeColor, size: 20),
        ),
        title: Row(
          children: [
            Text(
              place.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (hasLocation) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Set',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          hasLocation ? place.address : 'Location not set',
          style: TextStyle(
            color: hasLocation ? AppTheme.textMuted : AppTheme.warningColor,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: AppTheme.textMuted,
          onPressed: () => _editPlace(place.name, place),
        ),
      ),
    );
  }

  Future<void> _editPlace(String placeName, SavedPlace? existingPlace) async {
    final addressController = TextEditingController(
      text: existingPlace?.address != 'Tap to set location' ? existingPlace?.address : '',
    );
    LatLng? selectedLocation = 
        existingPlace?.lat != null && existingPlace?.lng != null
            ? LatLng(existingPlace!.lat!, existingPlace.lng!)
            : null;
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        placeName.toLowerCase() == 'home' 
                            ? Icons.home 
                            : placeName.toLowerCase() == 'work' 
                                ? Icons.work 
                                : Icons.place,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Set $placeName Location',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Address field
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: 'Enter address...',
                    prefixIcon: const Icon(Icons.search),
                    hintStyle: TextStyle(color: AppTheme.textMuted),
                  ),
                  onChanged: (value) {
                    // User can type, but we encourage using map picker
                  },
                ),
                const SizedBox(height: 16),
                
                // Pick on map button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push<LatLng>(
                        this.context,
                        MaterialPageRoute(
                          builder: (_) => LocationPickerScreen(
                            initialPosition: selectedLocation,
                          ),
                        ),
                      );
                      
                      if (result != null) {
                        // Get address for the location
                        final address = await _geocodingService.reverseGeocode(
                          result.latitude, 
                          result.longitude,
                        );
                        
                        // Save the place
                        final newPlace = SavedPlace(
                          id: existingPlace?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          name: placeName,
                          address: address ?? 
                              '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}',
                          lat: result.latitude,
                          lng: result.longitude,
                        );
                        
                        await _savedPlacesService.savePlace(newPlace);
                        await _loadSavedPlaces();
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$placeName location saved!')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Pick on Map'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                
                // Show current location if set
                if (selectedLocation != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppTheme.successColor, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Location set',
                                style: TextStyle(
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Save button (for manual address entry)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (addressController.text.isNotEmpty) {
                        // Try to geocode the address
                        final results = await _geocodingService.searchAddress(addressController.text);
                        
                        if (results.isNotEmpty) {
                          final result = results.first;
                          final newPlace = SavedPlace(
                            id: existingPlace?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            name: placeName,
                            address: result.displayName,
                            lat: result.lat,
                            lng: result.lng,
                          );
                          await _savedPlacesService.savePlace(newPlace);
                          await _loadSavedPlaces();
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$placeName location saved!')),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not find address. Try picking on map.')),
                            );
                          }
                        }
                      }
                    },
                    child: const Text('Save Address'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addNewPlace() {
    final nameController = TextEditingController();

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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      Navigator.pop(context);
                      // Navigate to location picker
                      final result = await Navigator.push<LatLng>(
                        this.context,
                        MaterialPageRoute(
                          builder: (_) => const LocationPickerScreen(),
                        ),
                      );
                      
                      if (result != null) {
                        final address = await _geocodingService.reverseGeocode(
                          result.latitude, 
                          result.longitude,
                        );
                        
                        final newPlace = SavedPlace(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          address: address ?? 
                              '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}',
                          lat: result.latitude,
                          lng: result.longitude,
                        );
                        
                        await _savedPlacesService.savePlace(newPlace);
                        await _loadSavedPlaces();
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${nameController.text} added!')),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Pick Location on Map'),
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
