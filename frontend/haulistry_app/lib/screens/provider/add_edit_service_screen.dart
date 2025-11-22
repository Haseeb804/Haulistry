import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/app_colors.dart';
import '../../utils/image_utils.dart';
import '../../services/auth_service.dart';
import '../../services/pricing_calculator.dart';
import '../../providers/service_provider.dart';
import '../../models/service_model.dart';
import '../common/platform_location_picker.dart';

class AddEditServiceScreen extends StatefulWidget {
  final String? serviceId;

  const AddEditServiceScreen({
    super.key,
    this.serviceId,
  });

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pricePerHourController = TextEditingController();
  final _pricePerDayController = TextEditingController();
  final _cityController = TextEditingController();
  
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isLoadingVehicles = true;
  
  // Vehicle Selection
  Map<String, dynamic>? _selectedVehicle;
  List<Map<String, dynamic>> _userVehicles = [];
  
  // Service Details
  String? _selectedProvince;
  List<XFile> _serviceImages = [];
  List<String> _selectedFeatures = [];
  
  // Location data for Google Maps
  LatLng? _serviceLocation;
  String _serviceAddress = '';
  double? _serviceLatitude;
  double? _serviceLongitude;
  
  // Pricing calculator data
  PriceBreakdown? _calculatedPricing;
  
  // Service Categories based on vehicle type
  Map<String, List<String>> _vehicleServiceTypes = {
    'Harvester': [
      'Crop Harvesting',
      'Wheat Harvesting',
      'Rice Harvesting',
      'Corn Harvesting',
      'Custom Harvesting',
    ],
    'Tractor': [
      'Land Plowing',
      'Seed Drilling',
      'Spraying',
      'Transportation',
      'Rotavator Service',
    ],
    'Crane': [
      'Heavy Lifting',
      'Construction Support',
      'Material Handling',
      'Equipment Installation',
    ],
    'Loader Rickshaw': [
      'Goods Transportation',
      'Local Delivery',
      'Material Loading',
      'Short Distance Hauling',
    ],
  };
  
  String? _selectedServiceType;
  
  final List<String> _provinces = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Gilgit-Baltistan',
    'Azad Kashmir',
  ];
  
  final List<Map<String, dynamic>> _availableFeatures = [
    {'id': 'gps', 'label': 'GPS Tracking', 'icon': Icons.gps_fixed},
    {'id': 'operator', 'label': 'Operator Included', 'icon': Icons.person},
    {'id': 'fuel', 'label': 'Fuel Included', 'icon': Icons.local_gas_station},
    {'id': 'insurance', 'label': 'Insurance Covered', 'icon': Icons.shield},
    {'id': '24x7', 'label': '24/7 Available', 'icon': Icons.access_time},
    {'id': 'support', 'label': 'Technical Support', 'icon': Icons.support_agent},
    {'id': 'maintenance', 'label': 'Well Maintained', 'icon': Icons.build},
    {'id': 'certified', 'label': 'Certified Operator', 'icon': Icons.verified},
  ];

  bool get _isEditMode => widget.serviceId != null;

  @override
  void initState() {
    super.initState();
    _loadUserVehicles();
    if (_isEditMode) {
      _loadServiceData();
    }
  }

  Future<void> _loadUserVehicles() async {
    setState(() => _isLoadingVehicles = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final uid = authService.userProfile?['uid'];
      
      if (uid != null) {
        final vehicles = await authService.getProviderVehicles(uid);
        setState(() {
          _userVehicles = vehicles;
          _isLoadingVehicles = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingVehicles = false);
    }
  }

  void _loadServiceData() {
    // Load existing service data for editing
    // This will be implemented when backend is ready
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _descriptionController.dispose();
    _pricePerHourController.dispose();
    _pricePerDayController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(),
          _buildStepIndicator(),
          Expanded(
            child: _isLoadingVehicles
                ? Center(child: CircularProgressIndicator())
                : _buildStepContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditMode ? 'Edit Service' : 'Add New Service',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Step ${_currentStep + 1} of 3',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          _buildStepDot(0, 'Vehicle', Icons.directions_car),
          _buildStepLine(0),
          _buildStepDot(1, 'Details', Icons.edit_note),
          _buildStepLine(1),
          _buildStepDot(2, 'Preview', Icons.visibility),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label, IconData icon) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive || isCompleted ? AppColors.primary : Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isActive || isCompleted ? Colors.white : Colors.grey.shade400,
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.primary : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isCompleted = step < _currentStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 30),
        color: isCompleted ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildVehicleSelectionStep();
      case 1:
        return _buildServiceDetailsStep();
      case 2:
        return _buildPreviewStep();
      default:
        return Container();
    }
  }

  Widget _buildVehicleSelectionStep() {
    if (_userVehicles.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_car_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'No Vehicles Found',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'You need to add vehicles first before creating services',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push('/provider/edit-profile'),
                label: Text('Add Vehicles'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Vehicle',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Choose the vehicle you want to offer as a service',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _userVehicles.length,
            itemBuilder: (context, index) {
              final vehicle = _userVehicles[index];
              final isSelected = _selectedVehicle?['vehicleId'] == vehicle['vehicleId'];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVehicle = vehicle;
                    _selectedServiceType = null; // Reset service type when vehicle changes
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Vehicle Image
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: vehicle['vehicleImage'] != null
                              ? Image.memory(
                                  ImageUtils.decodeBase64Image(vehicle['vehicleImage'])!,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.directions_car, size: 40, color: Colors.grey.shade400),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Vehicle Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    vehicle['vehicleType'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              vehicle['model'] ?? 'No Model',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.pin, size: 14, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  vehicle['registrationNumber'] ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Selection Indicator
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade300,
                            width: 2,
                          ),
                          color: isSelected ? AppColors.primary : Colors.transparent,
                        ),
                        child: isSelected
                            ? Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsStep() {
    if (_selectedVehicle == null) {
      return Center(
        child: Text('Please select a vehicle first'),
      );
    }

    final vehicleType = _selectedVehicle!['vehicleType'] ?? '';
    final availableServiceTypes = _vehicleServiceTypes[vehicleType] ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Type Selection
            Text(
              'Service Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.category, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Available for $vehicleType',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableServiceTypes.map((serviceType) {
                      final isSelected = _selectedServiceType == serviceType;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedServiceType = serviceType),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            serviceType,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Service Name
            Text(
              'Service Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _serviceNameController,
                    decoration: InputDecoration(
                      labelText: 'Service Name',
                      hintText: 'e.g., Professional Wheat Harvesting',
                      prefixIcon: Icon(Icons.title, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe your service in detail...',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(Icons.description, color: AppColors.primary),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      return null;
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Pricing with Smart Calculator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pricing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _showPriceCalculator,
                  icon: Icon(Icons.calculate, size: 18),
                  label: Text('Smart Pricing'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _pricePerHourController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price per Hour (PKR)',
                      hintText: '2000',
                      prefixIcon: Icon(Icons.attach_money, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      helperText: 'Use Smart Pricing button for suggestions',
                      helperStyle: TextStyle(fontSize: 11),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (double.tryParse(value!) == null) return 'Invalid amount';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _pricePerDayController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price per Day (PKR)',
                      hintText: '15000',
                      prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (double.tryParse(value!) == null) return 'Invalid amount';
                      return null;
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Location (Google Maps Integration)
            Text(
              'Service Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => _openLocationPicker(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(
                          color: _serviceAddress.isEmpty 
                            ? Colors.grey.shade400 
                            : AppColors.primary,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: _serviceAddress.isEmpty 
                              ? Colors.grey.shade600 
                              : AppColors.primary,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _serviceAddress.isEmpty 
                                    ? 'Tap to select location on map' 
                                    : 'Selected Location',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                if (_serviceAddress.isNotEmpty) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    _serviceAddress,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_serviceAddress.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8, left: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Location is required',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Service Images
            Text(
              'Service Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add photos to showcase your service (Max 5 images)',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Image Grid
                  if (_serviceImages.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: _serviceImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FutureBuilder(
                                future: _serviceImages[index].readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Image.memory(
                                      snapshot.data!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _serviceImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  
                  if (_serviceImages.isNotEmpty) SizedBox(height: 16),
                  
                  // Add Image Button
                  if (_serviceImages.length < 5)
                    OutlinedButton.icon(
                      onPressed: _pickServiceImages,
                      icon: Icon(Icons.add_photo_alternate),
                      label: Text(_serviceImages.isEmpty ? 'Add Images' : 'Add More Images'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Features
            Text(
              'Service Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Select features that apply to your service',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: _availableFeatures.length,
                itemBuilder: (context, index) {
                  final feature = _availableFeatures[index];
                  final isSelected = _selectedFeatures.contains(feature['id']);
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedFeatures.remove(feature['id']);
                        } else {
                          _selectedFeatures.add(feature['id']);
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            feature['icon'],
                            color: isSelected ? AppColors.primary : Colors.grey.shade600,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature['label'],
                              style: TextStyle(
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview Your Service',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Review all details before publishing',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 20),

          // Service Card Preview
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Info
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _selectedVehicle?['vehicleImage'] != null
                            ? Image.memory(
                                ImageUtils.decodeBase64Image(_selectedVehicle!['vehicleImage'])!,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.directions_car, color: Colors.grey.shade400),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _selectedVehicle?['vehicleType'] ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _selectedVehicle?['model'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                Divider(height: 32),

                // Service Images
                if (_serviceImages.isNotEmpty) ...[
                  Text(
                    'Service Images',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _serviceImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FutureBuilder(
                              future: _serviceImages[index].readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(height: 32),
                ],

                // Service Name & Type
                Text(
                  _serviceNameController.text.isEmpty 
                      ? 'Service Name' 
                      : _serviceNameController.text,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                if (_selectedServiceType != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedServiceType!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                
                SizedBox(height: 16),

                // Description
                Text(
                  _descriptionController.text.isEmpty 
                      ? 'Service description...' 
                      : _descriptionController.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                Divider(height: 32),

                // Pricing
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hourly Rate',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Rs ${_pricePerHourController.text.isEmpty ? "0" : _pricePerHourController.text}/hr',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Rate',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Rs ${_pricePerDayController.text.isEmpty ? "0" : _pricePerDayController.text}/day',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Divider(height: 32),

                // Location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _serviceAddress.isNotEmpty 
                            ? _serviceAddress 
                            : '${_cityController.text.isEmpty ? "City" : _cityController.text}, ${_selectedProvince ?? "Province"}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_selectedFeatures.isNotEmpty) ...[
                  Divider(height: 32),

                  // Features
                  Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedFeatures.map((featureId) {
                      final feature = _availableFeatures.firstWhere(
                        (f) => f['id'] == featureId,
                        orElse: () => {'label': '', 'icon': Icons.check},
                      );
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              feature['icon'],
                              size: 16,
                              color: Colors.green.shade700,
                            ),
                            SizedBox(width: 6),
                            Text(
                              feature['label'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _currentStep--);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) SizedBox(width: 12),
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _currentStep == 2 ? 'Publish Service' : 'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNextStep() {
    if (_currentStep == 0) {
      // Validate vehicle selection
      if (_selectedVehicle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a vehicle'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 1) {
      // Validate form
      if (_formKey.currentState?.validate() ?? false) {
        if (_selectedServiceType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select a service type'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        if (_serviceAddress.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select service location on map'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        if (_serviceImages.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please add at least one service image'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 2) {
      // Submit service
      _submitService();
    }
  }

  // Open Google Maps location picker
  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => PlatformLocationPicker(
          initialLocation: _serviceLocation,
          initialAddress: _serviceAddress,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _serviceLocation = result['location'] as LatLng;
        _serviceAddress = result['address'] as String;
        _serviceLatitude = result['latitude'] as double;
        _serviceLongitude = result['longitude'] as double;
        
        // Auto-fill city from address if city controller is empty
        if (_cityController.text.isEmpty) {
          // Extract city from address (simple approach)
          final parts = _serviceAddress.split(',');
          if (parts.length >= 2) {
            _cityController.text = parts[parts.length - 2].trim();
          }
        }
      });
    }
  }

  // Show pricing calculator dialog
  void _showPriceCalculator() {
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a vehicle first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.calculate, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Smart Price Calculator',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Based on your ${_selectedVehicle!['vehicleType']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 20),
                
                // Calculate suggested pricing
                Builder(
                  builder: (context) {
                    final vehicleType = _selectedVehicle!['vehicleType'] as String;
                    final priceRange = PricingCalculator.getSuggestedPriceRange(
                      serviceType: vehicleType,
                      durationHours: 8.0,
                      distanceKm: 0.0,
                    );
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPriceCard(
                          'Minimum Rate',
                          priceRange['minimum']!,
                          'Competitive pricing',
                          Colors.blue,
                        ),
                        SizedBox(height: 12),
                        _buildPriceCard(
                          'Recommended',
                          priceRange['recommended']!,
                          'Balanced pricing',
                          Colors.green,
                        ),
                        SizedBox(height: 12),
                        _buildPriceCard(
                          'Maximum Rate',
                          priceRange['maximum']!,
                          'Premium pricing',
                          Colors.orange,
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tap a price to auto-fill your rate',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    ));
  }

  Widget _buildPriceCard(String title, double price, String subtitle, Color color) {
    return InkWell(
      onTap: () {
        _pricePerHourController.text = price.toStringAsFixed(0);
        _pricePerDayController.text = (price * 8).toStringAsFixed(0); // Assume 8 hours per day
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Price updated to PKR ${price.toStringAsFixed(0)}/hour'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(Icons.monetization_on, color: color, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'PKR ${price.toStringAsFixed(0)}/hour',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickServiceImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        // Limit to 5 images total
        final int remainingSlots = 5 - _serviceImages.length;
        final List<XFile> imagesToAdd = images.take(remainingSlots).toList();
        
        setState(() {
          _serviceImages.addAll(imagesToAdd);
        });
        
        if (images.length > remainingSlots) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum 5 images allowed. ${remainingSlots} images added.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitService() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      
      // Try to get UID from multiple sources
      String? uid = authService.userProfile?['uid'];
      
      // Fallback to Firebase currentUser if profile is not loaded
      if (uid == null && authService.currentUser != null) {
        uid = authService.currentUser!.uid;
        print('Using Firebase UID: $uid');
      }
      
      // Try to reload user profile if still null
      if (uid == null) {
        await authService.loadUserProfile();
        uid = authService.userProfile?['uid'];
      }

      if (uid == null) {
        throw Exception('User not logged in. Please log out and log in again.');
      }

      print('Creating service for user: $uid');

      // Convert images to base64
      List<String> base64Images = [];
      for (var imageFile in _serviceImages) {
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        base64Images.add(base64Image);
      }
      
      // Convert images list to JSON string
      final serviceImagesJson = jsonEncode(base64Images);

      // Build service area string
      final serviceArea = '${_cityController.text}, $_selectedProvince';

      // Create Service object
      final service = Service(
        serviceId: '', // Will be generated by backend
        vehicleId: _selectedVehicle!['vehicleId'],
        providerUid: uid,
        serviceName: _serviceNameController.text,
        serviceCategory: _selectedServiceType!,
        pricePerHour: double.tryParse(_pricePerHourController.text),
        pricePerDay: double.tryParse(_pricePerDayController.text),
        description: _descriptionController.text,
        serviceArea: serviceArea,
        isActive: true,
        operatorIncluded: _selectedFeatures.contains('operator'),
        fuelIncluded: _selectedFeatures.contains('fuel'),
        transportationIncluded: false,
        // Location fields from Google Maps
        latitude: _serviceLatitude,
        longitude: _serviceLongitude,
        fullAddress: _serviceAddress.isNotEmpty ? _serviceAddress : serviceArea,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        province: _selectedProvince,
      );

      // Add service with images
      final success = await serviceProvider.addService(service, serviceImages: serviceImagesJson);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Service added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/provider/services');
      } else if (mounted) {
        throw Exception(serviceProvider.error ?? 'Failed to add service');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
