import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  bool _locationEnabled = true;
  bool _highAccuracy = true;
  bool _backgroundLocation = false;
  bool _shareWithProviders = true;
  String _defaultCity = 'Lahore';
  String _defaultArea = 'Model Town';

  final List<String> _savedLocations = [
    'Home - Model Town, Lahore',
    'Office - Gulberg, Lahore',
    'Farm - Kasur Road, Lahore',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Location Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Location Services
          _buildSectionHeader('Location Services', Icons.location_on),
          SizedBox(height: 12),
          _buildLocationServicesCard(),
          
          SizedBox(height: 24),
          
          // Default Location
          _buildSectionHeader('Default Location', Icons.home),
          SizedBox(height: 12),
          _buildDefaultLocationCard(),
          
          SizedBox(height: 24),
          
          // Saved Locations
          _buildSectionHeader('Saved Locations', Icons.bookmark),
          SizedBox(height: 12),
          _buildSavedLocationsCard(),
          
          SizedBox(height: 12),
          _buildAddLocationButton(),
          
          SizedBox(height: 24),
          
          // Permissions
          _buildSectionHeader('Permissions', Icons.security),
          SizedBox(height: 12),
          _buildPermissionsCard(),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationServicesCard() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.location_on, color: Colors.blue),
            ),
            title: Text('Enable Location'),
            subtitle: Text('Allow app to use your location'),
            value: _locationEnabled,
            onChanged: (value) => setState(() => _locationEnabled = value),
          ),
          Divider(height: 1),
          SwitchListTile(
            secondary: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.my_location, color: Colors.green),
            ),
            title: Text('High Accuracy Mode'),
            subtitle: Text('Use GPS for precise location'),
            value: _highAccuracy,
            onChanged: _locationEnabled
                ? (value) => setState(() => _highAccuracy = value)
                : null,
          ),
          Divider(height: 1),
          SwitchListTile(
            secondary: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.explore, color: Colors.orange),
            ),
            title: Text('Background Location'),
            subtitle: Text('Access location in background'),
            value: _backgroundLocation,
            onChanged: _locationEnabled
                ? (value) => setState(() => _backgroundLocation = value)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLocationCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.location_city, color: Colors.purple),
            ),
            title: Text('Default City'),
            subtitle: Text(_defaultCity),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showCityPicker(),
          ),
          Divider(height: 1),
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.maps_home_work, color: Colors.teal),
            ),
            title: Text('Default Area'),
            subtitle: Text(_defaultArea),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showAreaPicker(),
          ),
          Divider(height: 1),
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.gps_fixed, color: Colors.indigo),
            ),
            title: Text('Use Current Location'),
            subtitle: Text('Set your current location as default'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _useCurrentLocation(),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedLocationsCard() {
    return Card(
      child: Column(
        children: _savedLocations.asMap().entries.map((entry) {
          final index = entry.key;
          final location = entry.value;
          return Column(
            children: [
              if (index > 0) Divider(height: 1),
              ListTile(
                leading: Icon(Icons.bookmark, color: Colors.blue),
                title: Text(location),
                trailing: PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) => _handleLocationAction(value, location),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddLocationButton() {
    return OutlinedButton.icon(
      onPressed: () => _showAddLocationDialog(),
      icon: Icon(Icons.add_location),
      label: Text('Add New Location'),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildPermissionsCard() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.share_location, color: Colors.red),
            ),
            title: Text('Share with Providers'),
            subtitle: Text('Allow providers to see your location'),
            value: _shareWithProviders,
            onChanged: (value) => setState(() => _shareWithProviders = value),
          ),
          Divider(height: 1),
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.settings, color: Colors.amber),
            ),
            title: Text('App Permissions'),
            subtitle: Text('Manage location permissions'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showPermissionsDialog(),
          ),
        ],
      ),
    );
  }

  void _showCityPicker() {
    final cities = ['Lahore', 'Karachi', 'Islamabad', 'Faisalabad', 'Multan', 'Rawalpindi'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Select City'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: cities.map((city) => ListTile(
            title: Text(city),
            leading: Radio<String>(
              value: city,
              groupValue: _defaultCity,
              onChanged: (value) {
                setState(() => _defaultCity = value!);
                Navigator.pop(context);
              },
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showAreaPicker() {
    final areas = ['Model Town', 'Gulberg', 'DHA', 'Johar Town', 'Bahria Town'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Select Area'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: areas.map((area) => ListTile(
            title: Text(area),
            leading: Radio<String>(
              value: area,
              groupValue: _defaultArea,
              onChanged: (value) {
                setState(() => _defaultArea = value!);
                Navigator.pop(context);
              },
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _useCurrentLocation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Getting your location...'),
          ],
        ),
      ),
    );
    
    // Simulate getting location
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current location set as default')),
      );
    });
  }

  void _showAddLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Label (e.g., Home, Office)',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'City',
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Location added successfully')),
              );
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _handleLocationAction(String action, String location) {
    if (action == 'delete') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete Location?'),
          content: Text('Are you sure you want to delete this location?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location deleted')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  void _showPermissionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Location Permissions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Permission: Allowed'),
            SizedBox(height: 16),
            Text(
              'To change location permissions, go to your device settings.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening device settings...')),
              );
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
