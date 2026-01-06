import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_provider.dart';
import '../../models/ride_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import 'location_picker_screen.dart';

class RequestRideScreen extends StatefulWidget {
  const RequestRideScreen({Key? key}) : super(key: key);

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  final _pickupAddressController = TextEditingController();
  final _destAddressController = TextEditingController();
  
  LatLng? _pickupLocation;
  LatLng? _destLocation;

  // Mock Fare Estimate
  double _estimatedFare = 0.0;
  String _selectedVehicle = 'Standard';

  @override
  void initState() {
    super.initState();
    final loc = Provider.of<RideProvider>(context, listen: false).currentLocation;
    if (loc != null) {
      _pickupLocation = loc;
      _pickupAddressController.text = "Current Location";
    }
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
      setState(() {
        if (isPickup) {
          _pickupLocation = result;
          if (_pickupAddressController.text.isEmpty || _pickupAddressController.text == "Current Location") {
             _pickupAddressController.text = "Pinned Location (${result.latitude.toStringAsFixed(3)}, ${result.longitude.toStringAsFixed(3)})";
          }
        } else {
          _destLocation = result;
           if (_destAddressController.text.isEmpty) {
             _destAddressController.text = "Pinned Location (${result.latitude.toStringAsFixed(3)}, ${result.longitude.toStringAsFixed(3)})";
          }
        }
        _calculateFareEstimate();
      });
    }
  }

  void _calculateFareEstimate() {
    if (_pickupLocation != null && _destLocation != null) {
      // Basic mock calculation: Dist * Base + BaseFare
      // In real app use specific algo
      setState(() {
         _estimatedFare = 10.0 + (5.0 * (_selectedVehicle == 'Premium' ? 1.5 : 1.0)); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final theme = Theme.of(context);

    // Timeline connector logic visual
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Request Ride'),
        backgroundColor: Colors.white,
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
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildInputRow(
                            icon: Icons.my_location,
                            iconColor: Colors.blue,
                            controller: _pickupAddressController,
                            hint: 'Pickup Location',
                            onTap: () => _pickLocation(true),
                            showConnector: true,
                          ),
                          _buildInputRow(
                            icon: Icons.location_on,
                            iconColor: Colors.red,
                            controller: _destAddressController,
                            hint: 'Where to?',
                            onTap: () => _pickLocation(false),
                            showConnector: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Choose Vehicle', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                      Text('Estimated Fare', style: theme.textTheme.bodyLarge),
                      Text(
                        '\$${_estimatedFare.toStringAsFixed(2)}', 
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Confirm Request',
                    isLoading: rideProvider.isLoading,
                    onPressed: () async {
                      if (_pickupLocation == null || _destLocation == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both locations')));
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

  Widget _buildInputRow({
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onTap, // This is for the map icon now, or maybe the text field shouldn't trigger map on tap if editable.
    required bool showConnector,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              const SizedBox(height: 12),
              Icon(icon, color: iconColor, size: 24),
              if (showConnector)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                InputField(
                    hintText: hint,
                    controller: controller,
                    readOnly: false, // User can type address
                    suffixIcon: InkWell(
                      onTap: onTap,
                      child: const Icon(Icons.map, size: 20, color: Colors.grey),
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
    final theme = Theme.of(context);
    
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor.withOpacity(0.05) : Colors.white,
            border: Border.all(
              color: isSelected ? theme.primaryColor : Colors.grey.shade200,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.directions_car_filled, size: 40, color: isSelected ? theme.primaryColor : Colors.grey),
              const SizedBox(height: 8),
              Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? theme.primaryColor : Colors.black)),
              Text('\$${basePrice.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
