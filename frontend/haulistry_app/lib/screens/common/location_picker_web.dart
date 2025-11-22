import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/google_maps_service.dart';
import '../../services/location_service.dart';
import '../../utils/app_colors.dart';

/// Web-specific Location Picker with Google Maps
class LocationPickerWeb extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;

  const LocationPickerWeb({
    Key? key,
    this.initialLocation,
    this.initialAddress,
  }) : super(key: key);

  @override
  State<LocationPickerWeb> createState() => _LocationPickerWebState();
}

class _LocationPickerWebState extends State<LocationPickerWeb> {
  GoogleMapController? _mapController;
  final GoogleMapsService _mapsService = GoogleMapsService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  LatLng _selectedLocation = const LatLng(31.5204, 74.3587); // Default: Lahore
  String _selectedAddress = '';
  bool _isLoading = false;
  List<PlaceSuggestion> _searchResults = [];
  String? _sessionToken;
  Set<Marker> _markers = {};

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
    _updateMarker();
    
    // Get initial address if not provided
    if (_selectedAddress.isEmpty) {
      _updateAddress();
    }
  }

  @override
  void dispose() {
    // Only dispose if controller is initialized
    // Prevents "Maps cannot be retrieved before calling buildView!" error
    try {
      _mapController?.dispose();
    } catch (e) {
      // Ignore disposal errors - controller may not be fully initialized
      print('Map controller disposal warning: $e');
    }
    _searchController.dispose();
    super.dispose();
  }

  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation,
          draggable: true,
          onDragEnd: (newPosition) {
            _selectedLocation = newPosition;
            _updateAddress();
          },
        ),
      };
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        final newLocation = LatLng(position.latitude, position.longitude);
        setState(() {
          _selectedLocation = newLocation;
        });
        _updateMarker();
        _updateAddress();
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newLocation, 15),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error getting location: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateAddress() async {
    setState(() => _isLoading = true);
    try {
      final address = await _mapsService.reverseGeocode(_selectedLocation);
      if (mounted) {
        setState(() {
          _selectedAddress = address ?? 'Unknown location';
          _searchController.text = _selectedAddress;
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      if (mounted) {
        setState(() => _searchResults = results);
      }
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

      if (details != null && mounted) {
        setState(() {
          _selectedLocation = details.location;
          _selectedAddress = suggestion.description;
          _searchController.text = suggestion.description;
          _searchResults = [];
        });
        _updateMarker();
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(details.location, 15),
        );
      }

      // Generate new session token
      _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error selecting place: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _updateMarker();
    _updateAddress();
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
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
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onMapTapped,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),

          // Top Search Bar
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Back button and search field
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search location...',
                                border: InputBorder.none,
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchResults = []);
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: _searchPlaces,
                            ),
                          ),
                        ],
                      ),
                      
                      // Search Results
                      if (_searchResults.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
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

          // Bottom Sheet with Location Info
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Location Info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_pin, color: AppColors.primary),
                              const SizedBox(width: 8),
                              const Text(
                                'Selected Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            Text(
                              _selectedAddress.isEmpty
                                  ? 'Tap on map to select location'
                                  : _selectedAddress,
                              style: const TextStyle(fontSize: 14),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            '${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Buttons Row
                          Row(
                            children: [
                              // Current Location Button
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading ? null : _getCurrentLocation,
                                  icon: const Icon(Icons.my_location),
                                  label: const Text('Current Location'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Confirm Button
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _selectedAddress.isNotEmpty && !_isLoading
                                      ? _confirmLocation
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Confirm Location',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
