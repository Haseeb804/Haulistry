import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/app_colors.dart';
import '../../utils/image_utils.dart';
import '../../services/auth_service.dart';
import '../common/platform_location_picker.dart';

class EditProviderProfileScreen extends StatefulWidget {
  const EditProviderProfileScreen({super.key});

  @override
  State<EditProviderProfileScreen> createState() => _EditProviderProfileScreenState();
}

class _EditProviderProfileScreenState extends State<EditProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers - Personal & Business Information
  late final TextEditingController _nameController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cnicController;
  late final TextEditingController _experienceController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _descriptionController;
  
  String? _selectedProvince;
  String? _selectedServiceType;
  bool _isUploadingImage = false;
  String? _profileImagePath;
  
  // Location data for Google Maps
  LatLng? _profileLocation;
  String _profileAddress = '';
  double? _profileLatitude;
  double? _profileLongitude;
  
  // Document images
  String? _cnicFrontImage;
  String? _cnicBackImage;
  String? _licenseImage;
  bool _isUploadingDocument = false;
  String? _currentUploadingDocument; // Track which document is being uploaded

  // Vehicle management
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoadingVehicles = false;
  
  // Vehicle form controllers for adding/editing
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  String _selectedVehicleType = 'Harvester';
  XFile? _vehicleImage;
  bool _isAddingVehicle = false;
  String? _editingVehicleId; // Track which vehicle is being edited
  
  final List<String> _vehicleTypes = ['Harvester', 'Tractor', 'Crane', 'Loader Rickshaw'];

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    final userProfile = authService.userProfile;
    
    // Initialize profile image
    _profileImagePath = userProfile?['profileImage'];
    
    // Initialize document images
    _cnicFrontImage = userProfile?['cnicFrontImage'];
    _cnicBackImage = userProfile?['cnicBackImage'];
    _licenseImage = userProfile?['licenseImage'];
    
    // Initialize controllers with real user data
    _nameController = TextEditingController(text: userProfile?['fullName'] ?? '');
    _businessNameController = TextEditingController(text: userProfile?['businessName'] ?? '');
    _emailController = TextEditingController(text: userProfile?['email'] ?? '');
    _phoneController = TextEditingController(text: userProfile?['phone'] ?? '');
    _cnicController = TextEditingController(text: userProfile?['cnicNumber'] ?? '');
    _experienceController = TextEditingController(
      text: userProfile?['yearsExperience']?.toString() ?? ''
    );
    _addressController = TextEditingController(text: userProfile?['address'] ?? '');
    _cityController = TextEditingController(text: userProfile?['city'] ?? '');
    _descriptionController = TextEditingController(text: userProfile?['description'] ?? '');
    
    _selectedProvince = userProfile?['province'];
    _selectedServiceType = userProfile?['serviceType'];
    
    // Load vehicles
    _loadVehicles();
  }
  
  Future<void> _loadVehicles() async {
    setState(() => _isLoadingVehicles = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final uid = authService.userProfile?['uid'];
      
      
      
      if (uid != null) {
        final vehicles = await authService.getProviderVehicles(uid);

        
        setState(() {
          _vehicles = vehicles;
          _isLoadingVehicles = false;
        });
      } else {

        setState(() {
          _vehicles = [];
          _isLoadingVehicles = false;
        });
      }
    } catch (e) {

      setState(() {
        _vehicles = [];
        _isLoadingVehicles = false;
      });
    }
  }
  
  final List<String> _provinces = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Gilgit-Baltistan',
    'Azad Kashmir',
  ];
  
  final List<String> _serviceTypes = [
    'Heavy Machinery',
    'Transport Services',
    'Construction Equipment',
    'Agricultural Machinery',
    'Logistics & Cargo',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _experienceController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _vehicleNumberController.dispose();
    _vehicleModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userProfile = authService.userProfile;
    
    if (userProfile == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          Container(
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
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    Center(
                      child: Stack(
                        children: [
                          Builder(
                            builder: (context) {
                              final imageBytes = ImageUtils.decodeBase64Image(_profileImagePath);
                              return CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.primary.withOpacity(0.2),
                                backgroundImage: imageBytes != null
                                  ? MemoryImage(imageBytes)
                                  : null,
                                child: imageBytes == null
                                  ? Text(
                                      (userProfile['fullName'] ?? 'U')[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                              );
                            },
                          ),
                          // Loading overlay when uploading
                          if (_isUploadingImage)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isUploadingImage ? null : _showImagePickerDialog,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _isUploadingImage ? Colors.grey : AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Center(
                      child: Text(
                        _isUploadingImage 
                          ? 'Uploading image...'
                          : 'Tap to change profile picture',
                        style: TextStyle(
                          color: _isUploadingImage 
                            ? AppColors.primary 
                            : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: _isUploadingImage 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    // Personal Information
                    _buildSectionTitle('Personal Information'),
                    SizedBox(height: 12),
                    _buildFormCard([
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        enabled: false, // Make read-only - name set during registration
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        enabled: false, // Make read-only - email set during registration
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your email';
                          }
                          if (!value!.contains('@')) {
                            return 'Please enter valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                    ]),

                    SizedBox(height: 24),

                    // Business Information
                    _buildSectionTitle('Business Information'),
                    SizedBox(height: 12),
                    _buildFormCard([
                      _buildTextField(
                        controller: _businessNameController,
                        label: 'Business Name',
                        icon: Icons.business,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter business name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _cnicController,
                        label: 'CNIC Number',
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter CNIC number';
                          }
                          if (value!.length < 13) {
                            return 'Please enter valid CNIC number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Service Type',
                        icon: Icons.category,
                        value: _selectedServiceType,
                        items: _serviceTypes,
                        onChanged: (value) => setState(() => _selectedServiceType = value),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _experienceController,
                        label: 'Years of Experience',
                        icon: Icons.work_history,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter experience';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Business Description',
                        icon: Icons.description,
                        maxLines: 4,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter description';
                          }
                          if (value!.length < 50) {
                            return 'Description should be at least 50 characters';
                          }
                          return null;
                        },
                      ),
                    ]),

                    SizedBox(height: 24),

                    // Location Information (Google Maps Integration)
                    _buildSectionTitle('Location'),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
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
                                  color: _profileAddress.isEmpty 
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
                                    color: _profileAddress.isEmpty 
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
                                          _profileAddress.isEmpty 
                                            ? 'Tap to select business location on map' 
                                            : 'Business Location',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (_profileAddress.isNotEmpty) ...[
                                          SizedBox(height: 4),
                                          Text(
                                            _profileAddress,
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ] else ...[
                                          SizedBox(height: 4),
                                          Text(
                                            'Select your location for better visibility',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 12,
                                            ),
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
                        ],
                      ),
                    ),

                    SizedBox(height: 32),

                    // Additional Documents
                    _buildSectionTitle('Documents'),
                    SizedBox(height: 12),
                    _buildDocumentsCard(userProfile),

                    SizedBox(height: 32),

                    // Vehicles Section
                    _buildSectionTitle('Vehicles'),
                    SizedBox(height: 12),
                    _buildVehiclesSection(),

                    SizedBox(height: 40),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
                                'Save Changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true, // Add enabled parameter
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled, // Use the enabled parameter
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: enabled ? AppColors.primary : Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
    required Color activeColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: activeColor,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard(Map<String, dynamic> userProfile) {
    final hasProfileImage = _profileImagePath != null && _profileImagePath!.isNotEmpty;
    final hasCnicFront = _cnicFrontImage != null && _cnicFrontImage!.isNotEmpty;
    final hasCnicBack = _cnicBackImage != null && _cnicBackImage!.isNotEmpty;
    final hasLicense = _licenseImage != null && _licenseImage!.isNotEmpty;
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDocumentTile(
            'Profile Picture',
            hasProfileImage ? 'Uploaded' : 'Not uploaded',
            hasProfileImage,
            _profileImagePath,
            'profile',
          ),
          SizedBox(height: 12),
          _buildDocumentTile(
            'CNIC Front',
            hasCnicFront ? 'Uploaded' : 'Not uploaded',
            hasCnicFront,
            _cnicFrontImage,
            'cnicFront',
          ),
          SizedBox(height: 12),
          _buildDocumentTile(
            'CNIC Back',
            hasCnicBack ? 'Uploaded' : 'Not uploaded',
            hasCnicBack,
            _cnicBackImage,
            'cnicBack',
          ),
          SizedBox(height: 12),
          _buildDocumentTile(
            'License Document',
            hasLicense ? 'Uploaded' : 'Not uploaded',
            hasLicense,
            _licenseImage,
            'license',
          ),
          if (userProfile['cnicNumber'] != null) ...[
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.credit_card, color: AppColors.primary, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CNIC Number',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        userProfile['cnicNumber'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (userProfile['licenseNumber'] != null) ...[
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.badge, color: AppColors.primary, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'License Number',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        userProfile['licenseNumber'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentTile(String title, String subtitle, bool isUploaded, String? imageData, String documentType) {
    final isCurrentlyUploading = _isUploadingDocument && _currentUploadingDocument == documentType;
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Document icon or thumbnail
          GestureDetector(
            onTap: isUploaded ? () => _viewDocument(imageData, title) : null,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isUploaded
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isCurrentlyUploading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  )
                : isUploaded && imageData != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Builder(
                        builder: (context) {
                          final imageBytes = ImageUtils.decodeBase64Image(imageData);
                          if (imageBytes != null) {
                            return Image.memory(
                              imageBytes,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            );
                          }
                          return Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          );
                        },
                      ),
                    )
                  : Icon(
                      isUploaded ? Icons.check_circle : Icons.upload_file,
                      color: isUploaded ? Colors.green : Colors.orange,
                      size: 24,
                    ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  isCurrentlyUploading ? 'Uploading...' : subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isCurrentlyUploading 
                      ? AppColors.primary
                      : isUploaded 
                        ? Colors.green 
                        : AppColors.textSecondary,
                    fontWeight: isCurrentlyUploading ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isUploaded ? Icons.refresh : Icons.upload,
              color: AppColors.primary,
            ),
            onPressed: isCurrentlyUploading ? null : () => _uploadDocument(documentType),
            tooltip: isUploaded ? 'Change $title' : 'Upload $title',
          ),
        ],
      ),
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Profile Picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text('Take Photo'),
              onTap: () {
                context.pop();
                _pickImage('camera');
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: Text('Choose from Gallery'),
              onTap: () {
                context.pop();
                _pickImage('gallery');
              },
            ),
            if (_profileImagePath != null && _profileImagePath!.isNotEmpty)
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.error),
                title: Text('Remove Photo'),
                onTap: () {
                  context.pop();
                  _removeProfilePicture();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(String source) async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      XFile? pickedFile;

      if (source == 'camera') {
        if (kIsWeb) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('📷 Camera is not available on web. Please choose from gallery.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() {
            _isUploadingImage = false;
          });
          return;
        }
        
        final ImagePicker picker = ImagePicker();
        pickedFile = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
      } else {
        final ImagePicker picker = ImagePicker();
        pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
      }

      if (pickedFile == null) {
        setState(() {
          _isUploadingImage = false;
        });
        return;
      }

      final base64Image = await ImageUtils.convertImageToBase64(pickedFile);
      final fileSizeKB = ImageUtils.getBase64FileSizeKB(base64Image);
      
      if (fileSizeKB > 2048) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Image is too large (${fileSizeKB.toStringAsFixed(0)} KB). Please choose an image smaller than 2 MB.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        setState(() {
          _isUploadingImage = false;
        });
        return;
      }

      final authService = context.read<AuthService>();
      final uid = authService.userProfile?['uid'];

      if (uid == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: User not authenticated'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isUploadingImage = false;
        });
        return;
      }

      final success = await authService.updateProviderProfile(
        uid: uid,
        profileImage: base64Image,
      );

      if (success && mounted) {
        setState(() {
          _profileImagePath = base64Image;
          _isUploadingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Profile picture updated successfully! (${fileSizeKB.toStringAsFixed(0)} KB)'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to update profile picture. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isUploadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _removeProfilePicture() async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      final authService = context.read<AuthService>();
      final uid = authService.userProfile?['uid'];

      if (uid == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: User not authenticated'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isUploadingImage = false;
        });
        return;
      }

      final success = await authService.updateProviderProfile(
        uid: uid,
        profileImage: '',
      );

      if (success && mounted) {
        setState(() {
          _profileImagePath = null;
          _isUploadingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Profile picture removed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to remove profile picture. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isUploadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  void _changeProfileImage() {
    _showImagePickerDialog();
  }

  Future<void> _uploadDocument(String documentType) async {
    try {
      setState(() {
        _isUploadingDocument = true;
        _currentUploadingDocument = documentType;
      });

      // Pick image from gallery (camera not available on web)
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() {
          _isUploadingDocument = false;
          _currentUploadingDocument = null;
        });
        return;
      }

      // Convert image to Base64
      final base64Image = await ImageUtils.convertImageToBase64(pickedFile);
      
      // Get file size for validation
      final fileSizeKB = ImageUtils.getBase64FileSizeKB(base64Image);
      
      // Check file size (max 2MB)
      if (fileSizeKB > 2048) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Image is too large (${fileSizeKB.toStringAsFixed(0)} KB). Please choose an image smaller than 2 MB.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        setState(() {
          _isUploadingDocument = false;
          _currentUploadingDocument = null;
        });
        return;
      }

      // Get auth service and user ID
      final authService = context.read<AuthService>();
      final uid = authService.userProfile?['uid'];

      if (uid == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: User not authenticated'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isUploadingDocument = false;
          _currentUploadingDocument = null;
        });
        return;
      }

      // Prepare update data based on document type
      String? profileImage;
      String? cnicFrontImage;
      String? cnicBackImage;
      String? licenseImage;
      String documentName;

      switch (documentType) {
        case 'profile':
          profileImage = base64Image;
          documentName = 'Profile Picture';
          break;
        case 'cnicFront':
          cnicFrontImage = base64Image;
          documentName = 'CNIC Front';
          break;
        case 'cnicBack':
          cnicBackImage = base64Image;
          documentName = 'CNIC Back';
          break;
        case 'license':
          licenseImage = base64Image;
          documentName = 'License Document';
          break;
        default:
          documentName = 'Document';
      }

      // Update local state immediately (optimistic update)
      if (mounted) {
        setState(() {
          switch (documentType) {
            case 'profile':
              _profileImagePath = base64Image;
              break;
            case 'cnicFront':
              _cnicFrontImage = base64Image;
              break;
            case 'cnicBack':
              _cnicBackImage = base64Image;
              break;
            case 'license':
              _licenseImage = base64Image;
              break;
          }
        });
      }

      // Update document via GraphQL
      final success = await authService.updateProviderProfile(
        uid: uid,
        profileImage: profileImage,
        cnicFrontImage: cnicFrontImage,
        cnicBackImage: cnicBackImage,
        licenseImage: licenseImage,
      );

      if (mounted) {
        setState(() {
          _isUploadingDocument = false;
          _currentUploadingDocument = null;
        });
      }

      if (success && mounted) {
        // Reload user profile to ensure consistency with backend
        await authService.reloadUserProfile();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $documentName uploaded successfully! (${fileSizeKB.toStringAsFixed(0)} KB)'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        // Even if mutation timed out, the backend might have saved it
        // So we reload the profile to check
        await authService.reloadUserProfile();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ $documentName uploaded but verification pending. Reloading...'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        setState(() {
          _isUploadingDocument = false;
          _currentUploadingDocument = null;
        });
      }
    }
  }

  void _viewDocument(String? imageData, String title) {
    if (imageData == null || imageData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ No document to view'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final imageBytes = ImageUtils.decodeBase64Image(imageData);
    
    if (imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to load document'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show full-screen image viewer
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(title),
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.black87,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _uploadDocument(
                        title.contains('Profile') ? 'profile' :
                        title.contains('CNIC Front') ? 'cnicFront' :
                        title.contains('CNIC Back') ? 'cnicBack' : 'license'
                      );
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Replace'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white),
                    label: Text('Close', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final uid = authService.userProfile?['uid'];
      
      if (uid == null) {
        throw Exception('User not logged in');
      }


      // Call the updateProviderProfile method with all fields
      final success = await authService.updateProviderProfile(
        uid: uid,
        businessName: _businessNameController.text.trim().isEmpty 
            ? null 
            : _businessNameController.text.trim(),
        serviceType: _selectedServiceType,
        cnicNumber: _cnicController.text.trim().isEmpty 
            ? null 
            : _cnicController.text.trim(),
        address: _addressController.text.trim().isEmpty 
            ? null 
            : _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty 
            ? null 
            : _cityController.text.trim(),
        province: _selectedProvince,
        yearsExperience: _experienceController.text.trim().isEmpty 
            ? null 
            : int.tryParse(_experienceController.text.trim()),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );

      if (mounted) {
        if (success) {
          
          // Reload the user profile from backend to get latest data
          await authService.loadUserProfile();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Profile updated successfully!')),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          // Wait a moment then go back
          await Future.delayed(Duration(milliseconds: 500));
          if (mounted) {
            context.pop();
          }
        } else {
          throw Exception(authService.errorMessage ?? 'Failed to update profile');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Failed to update profile: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==================== VEHICLE MANAGEMENT METHODS ====================

  Widget _buildVehiclesSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Add button
          Row(
            children: [
              Icon(Icons.directions_car, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'My Vehicles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (!_isAddingVehicle)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isAddingVehicle = true;
                      _editingVehicleId = null;
                      _vehicleNumberController.clear();
                      _vehicleModelController.clear();
                      _selectedVehicleType = 'Harvester';
                      _vehicleImage = null;
                    });
                  },
                  label: Text('Add Vehicle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          
          // Add/Edit Vehicle Form
          if (_isAddingVehicle) ...[
            _buildVehicleForm(),
            SizedBox(height: 16),
          ],
          
          // Loading indicator
          if (_isLoadingVehicles)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
            )
          // Vehicle List
          else if (_vehicles.isEmpty && !_isAddingVehicle)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No vehicles added yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add your vehicles to get started',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _vehicles.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final vehicle = _vehicles[index];
                return _buildVehicleCard(vehicle, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildVehicleForm() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                _editingVehicleId != null ? 'Edit Vehicle' : 'Add New Vehicle',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _isAddingVehicle = false;
                    _editingVehicleId = null;
                    _vehicleNumberController.clear();
                    _vehicleModelController.clear();
                    _vehicleImage = null;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Vehicle Type Dropdown
          DropdownButtonFormField<String>(
            value: _selectedVehicleType,
            decoration: InputDecoration(
              labelText: 'Vehicle Type',
              prefixIcon: Icon(Icons.category, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: _vehicleTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedVehicleType = value;
                });
              }
            },
          ),
          SizedBox(height: 16),
          
          // Vehicle Number
          TextFormField(
            controller: _vehicleNumberController,
            decoration: InputDecoration(
              labelText: 'Registration Number',
              hintText: 'e.g., ABC-123',
              prefixIcon: Icon(Icons.pin, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            textCapitalization: TextCapitalization.characters,
            maxLength: 20,
          ),
          SizedBox(height: 16),
          
          // Vehicle Model
          TextFormField(
            controller: _vehicleModelController,
            decoration: InputDecoration(
              labelText: 'Model',
              hintText: 'e.g., John Deere 5075E',
              prefixIcon: Icon(Icons.precision_manufacturing, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          
          // Vehicle Image
          GestureDetector(
            onTap: _pickVehicleImage,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _vehicleImage != null 
                    ? AppColors.primary 
                    : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: _vehicleImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FutureBuilder<String>(
                      future: ImageUtils.convertImageToBase64(_vehicleImage!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final imageBytes = ImageUtils.decodeBase64Image(snapshot.data!);
                          if (imageBytes != null) {
                            return Stack(
                              children: [
                                Image.memory(
                                  imageBytes,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.edit, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            );
                          }
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap to upload vehicle photo',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
            ),
          ),
          SizedBox(height: 16),
          
          // Save Button
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isAddingVehicle = false;
                      _editingVehicleId = null;
                      _vehicleNumberController.clear();
                      _vehicleModelController.clear();
                      _vehicleImage = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_editingVehicleId != null ? 'Update' : 'Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle, int index) {
    final isEditing = _editingVehicleId == vehicle['vehicleId'];
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEditing ? AppColors.primary : Colors.grey.shade300,
          width: isEditing ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Vehicle Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Builder(
              builder: (context) {
                final imageBytes = ImageUtils.decodeBase64Image(vehicle['vehicleImage']);
                if (imageBytes != null) {
                  return Image.memory(
                    imageBytes,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  );
                }
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade300,
                  child: Icon(Icons.directions_car, size: 40, color: Colors.grey),
                );
              },
            ),
          ),
          SizedBox(width: 16),
          
          // Vehicle Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle['vehicleType'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  vehicle['model'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
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
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.primary, size: 20),
                onPressed: () => _editVehicle(vehicle),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: Icon(Icons.delete, color: AppColors.error, size: 20),
                onPressed: () => _confirmDeleteVehicle(vehicle, index),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickVehicleImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _vehicleImage = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveVehicle() async {
    // Validate inputs
    if (_vehicleNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter registration number'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_vehicleModelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter vehicle model'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_vehicleImage == null && _editingVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload vehicle photo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Convert image to Base64
      String? base64Image;
      if (_vehicleImage != null) {
        base64Image = await ImageUtils.convertImageToBase64(_vehicleImage!);
      } else if (_editingVehicleId != null) {
        // Use existing image if editing and no new image selected
        final existingVehicle = _vehicles.firstWhere(
          (v) => v['vehicleId'] == _editingVehicleId,
        );
        base64Image = existingVehicle['vehicleImage'];
      }

      final vehicleData = {
        'vehicleId': _editingVehicleId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'vehicleType': _selectedVehicleType,
        'registrationNumber': _vehicleNumberController.text.trim(),
        'model': _vehicleModelController.text.trim(),
        'vehicleImage': base64Image,
      };

      if (_editingVehicleId != null) {
        // Update existing vehicle
        final index = _vehicles.indexWhere((v) => v['vehicleId'] == _editingVehicleId);
        if (index != -1) {
          setState(() {
            _vehicles[index] = vehicleData;
          });
        }
      } else {
        // Add new vehicle
        setState(() {
          _vehicles.add(vehicleData);
        });
      }

      // Clear form
      setState(() {
        _isAddingVehicle = false;
        _editingVehicleId = null;
        _vehicleNumberController.clear();
        _vehicleModelController.clear();
        _vehicleImage = null;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingVehicleId != null 
              ? '✅ Vehicle updated successfully!' 
              : '✅ Vehicle added successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // TODO: Send to backend
      // You can call the API here to save vehicles to backend
      // await _saveVehiclesToBackend();
      
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editVehicle(Map<String, dynamic> vehicle) {
    setState(() {
      _isAddingVehicle = true;
      _editingVehicleId = vehicle['vehicleId'];
      _selectedVehicleType = vehicle['vehicleType'] ?? 'Harvester';
      _vehicleNumberController.text = vehicle['registrationNumber'] ?? '';
      _vehicleModelController.text = vehicle['model'] ?? '';
      // Note: We keep _vehicleImage as null when editing unless user picks a new one
    });

    // Scroll to form
    Future.delayed(Duration(milliseconds: 100), () {
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _confirmDeleteVehicle(Map<String, dynamic> vehicle, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(child: Text('Delete Vehicle?')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this vehicle?'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle['vehicle_type'] ?? vehicle['type'] ?? 'Unknown',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(vehicle['model'] ?? 'N/A'),
                  Text(
                    vehicle['registration_number'] ?? vehicle['number'] ?? 'N/A',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
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
              _deleteVehicle(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(int index) async {
    try {
      setState(() {
        _vehicles.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Vehicle deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // TODO: Send delete request to backend
      // await _deleteVehicleFromBackend(vehicleId);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error deleting vehicle: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Open Google Maps location picker
  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => PlatformLocationPicker(
          initialLocation: _profileLocation,
          initialAddress: _profileAddress,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _profileLocation = result['location'] as LatLng;
        _profileAddress = result['address'] as String;
        _profileLatitude = result['latitude'] as double;
        _profileLongitude = result['longitude'] as double;
        
        // Auto-fill address and city controllers
        _addressController.text = _profileAddress;
        
        // Extract city from address (simple approach)
        final parts = _profileAddress.split(',');
        if (parts.length >= 2) {
          _cityController.text = parts[parts.length - 2].trim();
        }
      });
    }
  }
}
