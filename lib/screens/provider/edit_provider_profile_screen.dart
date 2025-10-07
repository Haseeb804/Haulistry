import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class EditProviderProfileScreen extends StatefulWidget {
  const EditProviderProfileScreen({super.key});

  @override
  State<EditProviderProfileScreen> createState() => _EditProviderProfileScreenState();
}

class _EditProviderProfileScreenState extends State<EditProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers - Personal & Business Information
  final _nameController = TextEditingController(text: 'Ali Traders');
  final _businessNameController = TextEditingController(text: 'Ali Agricultural Services');
  final _emailController = TextEditingController(text: 'ali.traders@example.com');
  final _phoneController = TextEditingController(text: '+92 300 1234567');
  final _cnicController = TextEditingController(text: '12345-1234567-1');
  final _experienceController = TextEditingController(text: '5');
  final _addressController = TextEditingController(text: 'Main Street, Faisalabad');
  final _cityController = TextEditingController(text: 'Faisalabad');
  final _descriptionController = TextEditingController(
    text: 'Professional agricultural equipment provider with 5+ years of experience',
  );
  
  // Controllers - Vehicle Information
  final _vehicleNameController = TextEditingController(text: 'Heavy Duty Harvester');
  final _makeController = TextEditingController(text: 'John Deere');
  final _modelController = TextEditingController(text: '9RX');
  final _yearController = TextEditingController(text: '2023');
  final _registrationController = TextEditingController(text: 'LHR-5678');
  final _capacityController = TextEditingController(text: '500 HP');
  final _priceController = TextEditingController(text: '5000');

  String? _selectedProvince = 'Punjab';
  String? _selectedServiceType = 'Agricultural Machinery';
  String? _selectedVehicleType = 'Harvester';
  String? _selectedCondition = 'Excellent';
  bool _hasInsurance = true;
  bool _isAvailable = true;
  
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
  
  final List<String> _vehicleTypes = [
    'Harvester',
    'Tractor',
    'Crane',
    'Excavator',
    'Bulldozer',
    'Loader',
    'Dump Truck',
    'Concrete Mixer',
    'Forklift',
    'Other',
  ];
  
  final List<String> _conditions = [
    'Excellent',
    'Good',
    'Fair',
    'Average',
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
    _vehicleNameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _registrationController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            child: Text(
                              'A',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _changeProfileImage,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
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

                    SizedBox(height: 24),

                    // Vehicle Information
                    _buildSectionTitle('Vehicle / Equipment Details'),
                    SizedBox(height: 12),
                    _buildFormCard([
                      _buildDropdown(
                        label: 'Vehicle Type',
                        icon: Icons.agriculture,
                        value: _selectedVehicleType,
                        items: _vehicleTypes,
                        onChanged: (value) => setState(() => _selectedVehicleType = value),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _vehicleNameController,
                        label: 'Vehicle Name',
                        icon: Icons.directions_car,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter vehicle name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _makeController,
                              label: 'Make',
                              icon: Icons.precision_manufacturing,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _modelController,
                              label: 'Model',
                              icon: Icons.model_training,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _yearController,
                              label: 'Year',
                              icon: Icons.calendar_today,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Required';
                                }
                                final year = int.tryParse(value!);
                                if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                                  return 'Invalid year';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _registrationController,
                              label: 'Registration No.',
                              icon: Icons.assignment,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Condition',
                        icon: Icons.check_circle_outline,
                        value: _selectedCondition,
                        items: _conditions,
                        onChanged: (value) => setState(() => _selectedCondition = value),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _capacityController,
                        label: 'Capacity / Load',
                        icon: Icons.fitness_center,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter capacity';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _priceController,
                        label: 'Price per Hour (PKR)',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter price';
                          }
                          final price = double.tryParse(value!);
                          if (price == null || price <= 0) {
                            return 'Please enter valid price';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildSwitchTile(
                        icon: Icons.security,
                        title: 'Insurance',
                        subtitle: 'Vehicle has valid insurance',
                        value: _hasInsurance,
                        onChanged: (value) => setState(() => _hasInsurance = value),
                        activeColor: AppColors.primary,
                      ),
                      SizedBox(height: 12),
                      _buildSwitchTile(
                        icon: Icons.check_circle,
                        title: 'Available for Booking',
                        subtitle: 'Customers can book this vehicle',
                        value: _isAvailable,
                        onChanged: (value) => setState(() => _isAvailable = value),
                        activeColor: Colors.green,
                      ),
                    ]),

                    SizedBox(height: 32),

                    // Additional Documents
                    _buildSectionTitle('Documents'),
                    SizedBox(height: 12),
                    _buildDocumentsCard(),

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

  Widget _buildDocumentsCard() {
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
            'Business Registration',
            'registration_document.pdf',
            true,
          ),
          SizedBox(height: 12),
          _buildDocumentTile(
            'Tax Certificate',
            'Not uploaded',
            false,
          ),
          SizedBox(height: 12),
          _buildDocumentTile(
            'ID Card',
            'cnic_copy.pdf',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(String title, String subtitle, bool isUploaded) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUploaded
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isUploaded ? Icons.check_circle : Icons.upload_file,
              color: isUploaded ? Colors.green : Colors.orange,
              size: 24,
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
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUploaded ? Colors.green : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isUploaded ? Icons.visibility : Icons.upload,
              color: AppColors.primary,
            ),
            onPressed: () => _uploadDocument(title),
          ),
        ],
      ),
    );
  }

  void _changeProfileImage() {
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Camera not implemented yet'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gallery picker not implemented yet'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _uploadDocument(String documentType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upload $documentType'),
        backgroundColor: AppColors.primary,
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
      // Mock save operation - replace with actual API call
      await Future.delayed(Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: AppColors.error,
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
