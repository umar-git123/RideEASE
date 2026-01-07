import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_provider.dart';
import '../../models/ride_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../services/geocoding_service.dart';
import '../../services/saved_places_service.dart';
import 'location_picker_screen.dart';

class RequestRideScreen extends StatefulWidget {
  final LatLng? prefilledDestination;
  final String? prefilledDestinationAddress;
  
  const RequestRideScreen({
    Key? key,
    this.prefilledDestination,
    this.prefilledDestinationAddress,
  }) : super(key: key);

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  final _pickupAddressController = TextEditingController();
  final _destAddressController = TextEditingController();
  final GeocodingService _geocodingService = GeocodingService();
  final SavedPlacesService _savedPlacesService = SavedPlacesService();
  
  LatLng? _pickupLocation;
  LatLng? _destLocation;

  // Mock Fare Estimate
  double _estimatedFare = 0.0;
  String _selectedVehicle = 'Standard';
  
  // Search state
  List<GeocodingResult> _pickupSearchResults = [];
  List<GeocodingResult> _destSearchResults = [];
  bool _isSearchingPickup = false;
  bool _isSearchingDest = false;
  bool _showPickupResults = false;
  bool _showDestResults = false;
  
  // Saved places
  List<SavedPlace> _savedPlaces = [];

  @override
  void initState() {
    super.initState();
    final loc = Provider.of<RideProvider>(context, listen: false).currentLocation;
    if (loc != null) {
      _pickupLocation = loc;
      _pickupAddressController.text = "Current Location";
    }
    
    // Handle prefilled destination
    if (widget.prefilledDestination != null) {
      _destLocation = widget.prefilledDestination;
      _destAddressController.text = widget.prefilledDestinationAddress ?? 
          "Location (${widget.prefilledDestination!.latitude.toStringAsFixed(3)}, ${widget.prefilledDestination!.longitude.toStringAsFixed(3)})";
      _calculateFareEstimate();
    }
    
    _loadSavedPlaces();
  }
  
  Future<void> _loadSavedPlaces() async {
    final places = await _savedPlacesService.getSavedPlaces();
    setState(() {
      _savedPlaces = places;
    });
  }

  Future<void> _searchAddress(String query, bool isPickup) async {
    if (query.length < 3) {
      setState(() {
        if (isPickup) {
          _pickupSearchResults = [];
          _showPickupResults = false;
        } else {
          _destSearchResults = [];
          _showDestResults = false;
        }
      });
      return;
    }
    
    setState(() {
      if (isPickup) {
        _isSearchingPickup = true;
        _showPickupResults = true;
      } else {
        _isSearchingDest = true;
        _showDestResults = true;
      }
    });
    
    final results = await _geocodingService.searchAddress(query);
    
    setState(() {
      if (isPickup) {
        _pickupSearchResults = results;
        _isSearchingPickup = false;
      } else {
        _destSearchResults = results;
        _isSearchingDest = false;
      }
    });
  }
  
  void _selectSearchResult(GeocodingResult result, bool isPickup) {
    setState(() {
      if (isPickup) {
        _pickupLocation = LatLng(result.lat, result.lng);
        _pickupAddressController.text = result.displayName;
        _pickupSearchResults = [];
        _showPickupResults = false;
      } else {
        _destLocation = LatLng(result.lat, result.lng);
        _destAddressController.text = result.displayName;
        _destSearchResults = [];
        _showDestResults = false;
      }
      _calculateFareEstimate();
    });
  }

  Future<void> _pickLocation(bool isPickup) async {
    final initialPos = isPickup ? _pickupLocation : _destLocation;
    final RideProvider rideProvider = Provider.of<RideProvider>(context, listen: false);
    
    // Use current location as fallback
    final center = initialPos ?? rideProvider.currentLocation;

    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialPosition: center),
      ),
    );

    if (result != null) {
      // Try to get address for the picked location
      final address = await _geocodingService.reverseGeocode(result.latitude, result.longitude);
      
      setState(() {
        if (isPickup) {
          _pickupLocation = result;
          _pickupAddressController.text = address ?? 
              "Location (${result.latitude.toStringAsFixed(3)}, ${result.longitude.toStringAsFixed(3)})";
          _showPickupResults = false;
        } else {
          _destLocation = result;
          _destAddressController.text = address ?? 
              "Location (${result.latitude.toStringAsFixed(3)}, ${result.longitude.toStringAsFixed(3)})";
          _showDestResults = false;
        }
        _calculateFareEstimate();
      });
    }
  }

  void _calculateFareEstimate() {
    if (_pickupLocation != null && _destLocation != null) {
      // Calculate distance between pickup and destination
      final Distance distance = Distance();
      final double km = distance.as(LengthUnit.Kilometer, _pickupLocation!, _destLocation!);
      
      // Base fare + per km rate
      final baseFare = _selectedVehicle == 'Premium' ? 5.0 : 3.0;
      final perKmRate = _selectedVehicle == 'Premium' ? 2.5 : 1.5;
      
      setState(() {
         _estimatedFare = baseFare + (km * perKmRate);
         if (_estimatedFare < 5.0) _estimatedFare = 5.0; // Minimum fare
      });
    }
  }
  
  void _selectSavedPlace(SavedPlace place, bool isPickup) {
    if (place.lat == null || place.lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${place.name} location not set. Please set it first.')),
      );
      return;
    }
    
    setState(() {
      if (isPickup) {
        _pickupLocation = LatLng(place.lat!, place.lng!);
        _pickupAddressController.text = place.address;
        _showPickupResults = false;
      } else {
        _destLocation = LatLng(place.lat!, place.lng!);
        _destAddressController.text = place.address;
        _showDestResults = false;
      }
      _calculateFareEstimate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Request Ride'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Location Input Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.cardDecoration(borderRadius: 16),
                      child: Column(
                        children: [
                          _buildInputRow(
                            icon: Icons.my_location,
                            iconColor: AppTheme.primaryColor,
                            controller: _pickupAddressController,
                            hint: 'Current Location',
                            onTap: () => _pickLocation(true),
                            onChanged: (value) => _searchAddress(value, true),
                            showConnector: true,
                            isPickup: true,
                          ),
                          // Pickup search results
                          if (_showPickupResults) _buildSearchResults(true),
                          _buildInputRow(
                            icon: Icons.location_on,
                            iconColor: AppTheme.errorColor,
                            controller: _destAddressController,
                            hint: 'Where to?',
                            onTap: () => _pickLocation(false),
                            onChanged: (value) => _searchAddress(value, false),
                            showConnector: false,
                            isPickup: false,
                          ),
                          // Destination search results
                          if (_showDestResults) _buildSearchResults(false),
                        ],
                      ),
                    ),
                    
                    // Quick saved places
                    if (_savedPlaces.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSavedPlacesQuickAccess(),
                    ],
                    
                    const SizedBox(height: 32),
                    Text(
                      'Choose Vehicle', 
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Vehicle Selection
                    Row(
                      children: [
                        _buildVehicleOption('Standard', 'assets/car_std.png', 10.0),
                        const SizedBox(width: 16),
                        _buildVehicleOption('Premium', 'assets/car_prem.png', 15.0),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Panel
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.backgroundCard,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estimated Fare', 
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '\$${_estimatedFare.toStringAsFixed(2)}', 
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Confirm Request',
                    isLoading: rideProvider.isLoading,
                    onPressed: () async {
                      if (_pickupLocation == null || _destLocation == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select both locations')),
                        );
                        return;
                      }

                      final ride = RideModel(
                        id: const Uuid().v4(),
                        riderId: authProvider.currentUserData!.id,
                        pickupLat: _pickupLocation!.latitude,
                        pickupLng: _pickupLocation!.longitude,
                        pickupAddress: _pickupAddressController.text,
                        destinationLat: _destLocation!.latitude,
                        destinationLng: _destLocation!.longitude,
                        destinationAddress: _destAddressController.text,
                        status: 'requested',
                        fare: _estimatedFare,
                        createdAt: DateTime.now(),
                      );

                      await rideProvider.requestRide(ride);
                      if (mounted) {
                         Navigator.pop(context); // Go back to dashboard
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSavedPlacesQuickAccess() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _savedPlaces.where((p) => p.lat != null && p.lng != null).map((place) {
        return GestureDetector(
          onTap: () => _selectSavedPlace(place, false), // Set as destination
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.backgroundElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  place.name.toLowerCase() == 'home' ? Icons.home : 
                  place.name.toLowerCase() == 'work' ? Icons.work : Icons.place,
                  size: 16, 
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  place.name,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildSearchResults(bool isPickup) {
    final results = isPickup ? _pickupSearchResults : _destSearchResults;
    final isSearching = isPickup ? _isSearchingPickup : _isSearchingDest;
    
    return Container(
      margin: const EdgeInsets.only(left: 40, bottom: 8),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: AppTheme.backgroundElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: isSearching
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : results.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No results found',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return InkWell(
                      onTap: () => _selectSearchResult(result, isPickup),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 18, color: AppTheme.textMuted),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                result.displayName,
                                style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInputRow({
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onTap,
    required Function(String) onChanged,
    required bool showConnector,
    required bool isPickup,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (showConnector)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [iconColor, AppTheme.errorColor],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: hint,
                            hintStyle: TextStyle(color: AppTheme.textMuted),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          onChanged: onChanged,
                          onTap: () {
                            setState(() {
                              if (isPickup) {
                                _showPickupResults = controller.text.length >= 3;
                              } else {
                                _showDestResults = controller.text.length >= 3;
                              }
                            });
                          },
                        ),
                      ),
                      InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.map_outlined, size: 20, color: AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                if (showConnector) const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleOption(String name, String asset, double basePrice) {
    final isSelected = _selectedVehicle == name;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedVehicle = name;
            _calculateFareEstimate();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor.withOpacity(0.1) 
                : AppTheme.backgroundCard,
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor.withOpacity(0.15) 
                      : AppTheme.backgroundElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_car_filled, 
                  size: 32, 
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${basePrice.toStringAsFixed(0)}+', 
                style: TextStyle(
                  color: AppTheme.textMuted, 
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
