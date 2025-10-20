import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_colors.dart';
import '../../utils/image_utils.dart';
import '../../providers/vehicle_provider.dart';
import '../../models/vehicle_model.dart';
import '../../services/auth_service.dart';

class AddEditVehicleScreen extends StatefulWidget {
  final String? vehicleId; // null for add, id for edit
  final bool isOnboarding; // true if coming from onboarding flow

  const AddEditVehicleScreen({
    super.key,
    this.vehicleId,
    this.isOnboarding = false,
  });

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNameController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _registrationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _pricePerHourController = TextEditingController();
  final _pricePerDayController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _insuranceExpiryController = TextEditingController();
  
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _vehicleImage;

  String? _selectedVehicleType;
  String? _selectedCondition;
  bool _hasInsurance = false;
  bool _isAvailable = true;
  bool _isLoading = false;

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

  bool get isEditMode => widget.vehicleId != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _loadVehicleData();
    }
  }

  void _loadVehicleData() {
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
    final vehicle = vehicleProvider.getVehicleById(widget.vehicleId!);

    if (vehicle != null) {
      _vehicleNameController.text = vehicle.vehicleName;
      _makeController.text = vehicle.make;
      _modelController.text = vehicle.model;
      _yearController.text = vehicle.year.toString();
      _registrationController.text = vehicle.registrationNumber;
      _capacityController.text = vehicle.capacity ?? '';
      _pricePerHourController.text = vehicle.pricePerHour?.toString() ?? '';
      _pricePerDayController.text = vehicle.pricePerDay?.toString() ?? '';
      _cityController.text = vehicle.city ?? '';
      _provinceController.text = vehicle.province ?? '';
      _descriptionController.text = vehicle.description ?? '';
      _insuranceExpiryController.text = vehicle.insuranceExpiry ?? '';
      _selectedVehicleType = vehicle.vehicleType;
      _selectedCondition = vehicle.condition;
      _hasInsurance = vehicle.hasInsurance;
      _isAvailable = vehicle.isAvailable;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _vehicleNameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _registrationController.dispose();
    _capacityController.dispose();
    _pricePerHourController.dispose();
    _pricePerDayController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _descriptionController.dispose();
    _insuranceExpiryController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
        final authService = AuthService();
        final providerUid = authService.userProfile?['uid'];

        if (providerUid == null) {
          throw Exception('User not logged in');
        }

        // Convert image to Base64 if selected
        String? vehicleImageBase64;
        if (_vehicleImage != null) {
          vehicleImageBase64 = await ImageUtils.convertImageToBase64(_vehicleImage!);
        }

        final vehicle = Vehicle(
          vehicleId: widget.vehicleId ?? 'VEH${DateTime.now().millisecondsSinceEpoch}',
          providerUid: providerUid,
          vehicleName: _vehicleNameController.text.trim(),
          vehicleType: _selectedVehicleType!,
          make: _makeController.text.trim(),
          model: _modelController.text.trim(),
          year: int.parse(_yearController.text),
          registrationNumber: _registrationController.text.trim(),
          capacity: _capacityController.text.trim().isEmpty ? null : _capacityController.text.trim(),
          condition: _selectedCondition!,
          vehicleImage: vehicleImageBase64,
          hasInsurance: _hasInsurance,
          insuranceExpiry: _hasInsurance && _insuranceExpiryController.text.isNotEmpty 
              ? _insuranceExpiryController.text.trim() 
              : null,
          isAvailable: _isAvailable,
          city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
          province: _provinceController.text.trim().isEmpty ? null : _provinceController.text.trim(),
          pricePerHour: _pricePerHourController.text.isEmpty 
              ? null 
              : double.tryParse(_pricePerHourController.text),
          pricePerDay: _pricePerDayController.text.isEmpty 
              ? null 
              : double.tryParse(_pricePerDayController.text),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
        );

        bool success;
        if (isEditMode) {
          success = await vehicleProvider.updateVehicle(widget.vehicleId!, vehicle);
        } else {
          success = await vehicleProvider.addVehicle(vehicle);
        }

        setState(() => _isLoading = false);

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(isEditMode
                        ? 'Vehicle updated successfully!'
                        : 'Vehicle added successfully!'),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
            
            // Navigate based on context
            if (widget.isOnboarding && !isEditMode) {
              // Show option to add more or go to dashboard
              _showOnboardingOptions();
            } else {
              context.pop();
            }
          }
        } else {
          if (mounted) {
            final errorMsg = vehicleProvider.error ?? 
                (isEditMode ? 'Failed to update vehicle' : 'Failed to add vehicle');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(errorMsg)),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Error: ${e.toString()}')),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  Future<void> _pickVehicleImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _vehicleImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showOnboardingOptions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Vehicle Added!'),
          ],
        ),
        content: const Text(
          'Your vehicle has been added successfully. Would you like to add another vehicle or go to dashboard?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Stay on screen, reset form for next vehicle
              _resetForm();
            },
            child: const Text('Add Another'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.go('/provider/dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _vehicleNameController.clear();
    _makeController.clear();
    _modelController.clear();
    _yearController.clear();
    _registrationController.clear();
    _capacityController.clear();
    _pricePerHourController.clear();
    _pricePerDayController.clear();
    _cityController.clear();
    _provinceController.clear();
    _descriptionController.clear();
    _insuranceExpiryController.clear();
    setState(() {
      _selectedVehicleType = null;
      _selectedCondition = null;
      _hasInsurance = false;
      _isAvailable = true;
      _vehicleImage = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 12),
            Text('Ready to add another vehicle'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEditMode ? 'Edit Vehicle' : 'Add Vehicle',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                isEditMode ? 'Update vehicle details' : 'Add a new vehicle',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isEditMode
                    ? 'Make changes to your vehicle information'
                    : 'Fill in the details of your vehicle',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Vehicle Type Dropdown
              _buildDropdown(
                label: 'Vehicle Type',
                hint: 'Select vehicle type',
                icon: Icons.agriculture,
                value: _selectedVehicleType,
                items: _vehicleTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedVehicleType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select vehicle type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Vehicle Name
              _buildTextField(
                controller: _vehicleNameController,
                label: 'Vehicle Name',
                hint: 'e.g., Heavy Duty Harvester',
                icon: Icons.directions_car,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Make & Model Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _makeController,
                      label: 'Make',
                      hint: 'e.g., John Deere',
                      icon: Icons.precision_manufacturing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _modelController,
                      label: 'Model',
                      hint: 'e.g., 9RX',
                      icon: Icons.model_training,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Year & Registration Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _yearController,
                      label: 'Year',
                      hint: '2024',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final year = int.tryParse(value);
                        if (year == null ||
                            year < 1900 ||
                            year > DateTime.now().year + 1) {
                          return 'Invalid year';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _registrationController,
                      label: 'Registration No.',
                      hint: 'ABC-1234',
                      icon: Icons.assignment,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Condition Dropdown
              _buildDropdown(
                label: 'Condition',
                hint: 'Select condition',
                icon: Icons.check_circle_outline,
                value: _selectedCondition,
                items: _conditions,
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select condition';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Capacity
              _buildTextField(
                controller: _capacityController,
                label: 'Capacity / Load',
                hint: 'e.g., 10 tons, 500 HP',
                icon: Icons.fitness_center,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter capacity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Price per hour
              _buildTextField(
                controller: _pricePerHourController,
                label: 'Price per Hour (PKR)',
                hint: 'Enter hourly rate',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Insurance Switch
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.security,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Insurance',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Vehicle has valid insurance',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _hasInsurance,
                      onChanged: (value) {
                        setState(() {
                          _hasInsurance = value;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Availability Switch
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available for Booking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Customers can book this vehicle',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isEditMode ? 'Update Vehicle' : 'Add Vehicle',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isEditMode ? Icons.check : Icons.add,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
