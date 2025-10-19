import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_colors.dart';
import '../../utils/image_utils.dart';
import '../../services/auth_service.dart';

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
  
  // Document images
  String? _cnicFrontImage;
  String? _cnicBackImage;
  String? _licenseImage;
  bool _isUploadingDocument = false;
  String? _currentUploadingDocument; // Track which document is being uploaded

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

                    // Location Information
                    _buildSectionTitle('Location'),
                    SizedBox(height: 12),
                    _buildFormCard([
                      _buildTextField(
                        controller: _addressController,
                        label: 'Business Address',
                        icon: Icons.location_on,
                        maxLines: 2,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _cityController,
                        label: 'City',
                        icon: Icons.location_city,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter city';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Province',
                        icon: Icons.map,
                        value: _selectedProvince,
                        items: _provinces,
                        onChanged: (value) => setState(() => _selectedProvince = value),
                      ),
                    ]),

                    SizedBox(height: 32),

                    // Additional Documents
                    _buildSectionTitle('Documents'),
                    SizedBox(height: 12),
                    _buildDocumentsCard(userProfile),

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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
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
      debugPrint('Error picking image: $e');
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
      debugPrint('Error removing profile picture: $e');
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
      debugPrint('Error uploading document: $e');
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

      print('\n🔄 UPDATING PROVIDER PROFILE');
      print('   UID: $uid');
      print('   Business Name: ${_businessNameController.text}');
      print('   Service Type: $_selectedServiceType');
      print('   City: ${_cityController.text}');
      print('   Province: $_selectedProvince');

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
          print('✅ Profile updated successfully');
          
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
      print('❌ Profile update error: $e');
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
}
