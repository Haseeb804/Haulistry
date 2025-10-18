import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

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
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _brandController = TextEditingController();

  String _selectedCategory = 'harvester';
  String _selectedCondition = 'excellent';
  String _selectedFuelType = 'diesel';
  bool _isAvailable = true;
  bool _isLoading = false;
  List<String> _selectedFeatures = [];
  List<String> _images = [];

  final List<String> _categories = [
    'harvester',
    'sand_truck',
    'brick_truck',
    'crane',
  ];

  final List<String> _conditions = [
    'excellent',
    'good',
    'fair',
  ];

  final List<String> _fuelTypes = [
    'diesel',
    'petrol',
    'electric',
    'hybrid',
  ];

  final List<Map<String, dynamic>> _availableFeatures = [
    {'label': 'GPS Tracking', 'icon': Icons.gps_fixed},
    {'label': 'Auto-Guidance', 'icon': Icons.navigation},
    {'label': 'Climate Control', 'icon': Icons.ac_unit},
    {'label': 'Advanced Safety', 'icon': Icons.security},
    {'label': '24/7 Support', 'icon': Icons.support_agent},
    {'label': 'Insurance Included', 'icon': Icons.shield},
  ];

  bool get _isEditMode => widget.serviceId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadServiceData();
    }
  }

  void _loadServiceData() {
    // Mock loading existing service data
    _nameController.text = 'Premium Harvester Service';
    _descriptionController.text = 'High-end harvester with GPS and auto-guidance system';
    _priceController.text = '2500';
    _capacityController.text = '500';
    _modelController.text = 'John Deere S770';
    _yearController.text = '2023';
    _brandController.text = 'John Deere';
    _selectedFeatures = ['GPS Tracking', 'Auto-Guidance', 'Insurance Included'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _brandController.dispose();
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
                        _isEditMode ? 'Edit Service' : 'Add New Service',
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
                    // Images Section
                    _buildSectionTitle('Service Images'),
                    SizedBox(height: 12),
                    _buildImageSection(),

                    SizedBox(height: 24),

                    // Basic Information
                    _buildSectionTitle('Basic Information'),
                    SizedBox(height: 12),
                    _buildFormCard([
                      _buildTextField(
                        controller: _nameController,
                        label: 'Service Name',
                        icon: Icons.title,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter service name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        icon: Icons.description,
                        maxLines: 3,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Category',
                        icon: Icons.category,
                        value: _selectedCategory,
                        items: _categories,
                        onChanged: (value) => setState(() => _selectedCategory = value!),
                      ),
                    ]),

                    SizedBox(height: 24),

                    // Pricing
                    _buildSectionTitle('Pricing'),
                    SizedBox(height: 12),
                    _buildFormCard([
                      _buildTextField(
                        controller: _priceController,
                        label: 'Hourly Rate (PKR)',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter price';
                          }
                          if (double.tryParse(value!) == null) {
                            return 'Please enter valid price';
                          }
                          return null;
                        },
                      ),
                    ]),

                    SizedBox(height: 24),

                    // Specifications
                    _buildSectionTitle('Specifications'),
                    SizedBox(height: 12),
                    _buildFormCard([
                      _buildTextField(
                        controller: _brandController,
                        label: 'Brand',
                        icon: Icons.business,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _modelController,
                        label: 'Model',
                        icon: Icons.label,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _yearController,
                        label: 'Year',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _capacityController,
                        label: 'Capacity (acres/day)',
                        icon: Icons.speed,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Condition',
                        icon: Icons.verified,
                        value: _selectedCondition,
                        items: _conditions,
                        onChanged: (value) => setState(() => _selectedCondition = value!),
                      ),
                      SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Fuel Type',
                        icon: Icons.local_gas_station,
                        value: _selectedFuelType,
                        items: _fuelTypes,
                        onChanged: (value) => setState(() => _selectedFuelType = value!),
                      ),
                    ]),

                    SizedBox(height: 24),

                    // Features
                    _buildSectionTitle('Features'),
                    SizedBox(height: 12),
                    _buildFeaturesSection(),

                    SizedBox(height: 24),

                    // Availability
                    _buildSectionTitle('Availability'),
                    SizedBox(height: 12),
                    _buildFormCard([
                      SwitchListTile(
                        value: _isAvailable,
                        onChanged: (value) => setState(() => _isAvailable = value),
                        title: Text('Service Available'),
                        subtitle: Text(
                          _isAvailable
                              ? 'Customers can book this service'
                              : 'Service hidden from customers',
                        ),
                        activeColor: AppColors.primary,
                      ),
                    ]),

                    SizedBox(height: 40),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveService,
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
                                _isEditMode ? 'Update Service' : 'Add Service',
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
    required String value,
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
          child: Text(value.replaceAll('_', ' ').toUpperCase()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildImageSection() {
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
          if (_images.isEmpty)
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Add Service Images',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap to upload photos',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _images.length + 1,
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 32,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(Icons.image, size: 40, color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _images.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
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
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _availableFeatures.map((feature) {
          bool isSelected = _selectedFeatures.contains(feature['label']);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedFeatures.remove(feature['label']);
                } else {
                  _selectedFeatures.add(feature['label']);
                }
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    feature['icon'],
                    size: 18,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    feature['label'],
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isSelected) ...[
                    SizedBox(width: 8),
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _pickImages() {
    // Mock image picker - implement actual image picker
    setState(() {
      _images.add('image_${_images.length + 1}');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image picker not implemented yet'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _saveService() async {
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
            content: Text(
              _isEditMode ? 'Service updated successfully' : 'Service added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save service'),
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
