import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/google_maps_service.dart';
import '../../services/location_service.dart';
import '../../utils/app_colors.dart';

/// Modern Location Picker Screen with Google Maps
/// Features:
/// - Interactive map with draggable marker
/// - Search with autocomplete
/// - Current location button
/// - Address display
/// - Distance calculator
class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;

  const LocationPickerScreen({
    Key? key,
    this.initialLocation,
    this.initialAddress,
  }) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  final GoogleMapsService _mapsService = GoogleMapsService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  LatLng _selectedLocation = const LatLng(31.5204, 74.3587); // Default: Lahore
  String _selectedAddress = '';
  bool _isLoading = false;
  List<PlaceSuggestion> _searchResults = [];
  String? _sessionToken;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation!;
    }
    if (widget.initialAddress != null) {
      _selectedAddress = widget.initialAddress!;
      _searchController.text = widget.initialAddress!;
    }
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final newLocation = LatLng(position.latitude, position.longitude);
        await _updateLocation(newLocation);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newLocation, 15),
        );
      }
    } catch (e) {
      _showSnackBar('Error getting location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLocation(LatLng location) async {
    setState(() {
      _selectedLocation = location;
      _isLoading = true;
    });

    try {
      final address = await _mapsService.reverseGeocode(location);
      setState(() {
        _selectedAddress = address ?? 'Unknown location';
        _searchController.text = _selectedAddress;
      });
    } catch (e) {
      print('Error updating location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    try {
      final results = await _mapsService.searchPlaces(
        query,
        location: _selectedLocation,
        sessionToken: _sessionToken,
      );
      setState(() => _searchResults = results);
    } catch (e) {
      print('Error searching places: $e');
    }
  }

  Future<void> _selectPlace(PlaceSuggestion suggestion) async {
    setState(() => _isLoading = true);

    try {
      final details = await _mapsService.getPlaceDetails(
        suggestion.placeId,
        sessionToken: _sessionToken,
      );

      if (details != null) {
        await _updateLocation(details.location);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(details.location, 15),
        );
      }

      setState(() {
        _searchResults = [];
        _searchController.text = suggestion.description;
      });

      // Generate new session token after selecting
      _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      _showSnackBar('Error selecting place: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _confirmLocation() {
    Navigator.pop(context, {
      'location': _selectedLocation,
      'address': _selectedAddress,
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) {
              setState(() => _selectedLocation = position.target);
            },
            onCameraIdle: () {
              _updateLocation(_selectedLocation);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: _selectedLocation,
                draggable: true,
                onDragEnd: (newPosition) {
                  _updateLocation(newPosition);
                },
              ),
            },
          ),

          // Top App Bar with Search
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search Bar
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search location...',
                                border: InputBorder.none,
                              ),
                              onChanged: _searchPlaces,
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            ),
                        ],
                      ),

                      // Search Results
                      if (_searchResults.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final suggestion = _searchResults[index];
                              return ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(suggestion.mainText),
                                subtitle: Text(suggestion.secondaryText),
                                onTap: () => _selectPlace(suggestion),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sheet with Address and Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selected Location Title
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Selected Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Address
                    Text(
                      _selectedAddress.isEmpty 
                          ? 'Select a location on the map' 
                          : _selectedAddress,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Coordinates
                    Text(
                      '${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _getCurrentLocation,
                            icon: const Icon(Icons.my_location),
                            label: const Text('Current Location'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading || _selectedAddress.isEmpty
                                ? null
                                : _confirmLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Confirm Location',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
