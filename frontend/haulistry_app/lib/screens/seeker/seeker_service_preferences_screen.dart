import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../models/seeker_preferences_model.dart';
import '../../providers/seeker_preferences_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class SeekerServicePreferencesScreen extends StatefulWidget {
  const SeekerServicePreferencesScreen({super.key});

  @override
  State<SeekerServicePreferencesScreen> createState() => _SeekerServicePreferencesScreenState();
}

class _SeekerServicePreferencesScreenState extends State<SeekerServicePreferencesScreen> {
  final Map<String, bool> _selectedCategories = {};
  final Map<String, List<String>> _selectedSubcategories = {};
  final Map<String, Map<String, TextEditingController>> _requirementControllers = {};
  final Map<String, String> _frequencySelections = {};
  String _primaryPurpose = '';
  String _urgency = '';
  final TextEditingController _notesController = TextEditingController();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Initialize all categories as unselected
    for (final category in ServiceCategories.getAllCategories()) {
      _selectedCategories[category] = false;
      _selectedSubcategories[category] = [];
      _requirementControllers[category] = {};
      _frequencySelections[category] = FrequencyOption.oneTime;
      
      // Initialize controllers for each requirement field
      for (final field in ServiceCategories.getRequirementFields(category)) {
        _requirementControllers[category]![field.key] = TextEditingController();
      }
    }
  }

  void _showSkipConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Skip for now?', style: TextStyle(fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You can add your service preferences later from your profile.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Adding preferences helps us show you better matches',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continue Setup', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.go('/seeker/dashboard');
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Skip', style: TextStyle(color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    // Dispose all requirement controllers
    for (final controllers in _requirementControllers.values) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _savePreferences() async {
    final authService = context.read<AuthService>();
    final uid = authService.userProfile?['uid'];

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get selected categories
    final selectedCats = _selectedCategories.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedCats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one service category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get selected subcategories
    final Map<String, List<String>> categoryDetails = {};
    for (final cat in selectedCats) {
      categoryDetails[cat] = _selectedSubcategories[cat] ?? [];
    }

    // Build service requirements
    final Map<String, ServiceRequirement> serviceRequirements = {};
    for (final cat in selectedCats) {
      final controllers = _requirementControllers[cat] ?? {};
      final additionalDetails = <String, String>{};
      
      for (final entry in controllers.entries) {
        if (entry.value.text.trim().isNotEmpty) {
          additionalDetails[entry.key] = entry.value.text.trim();
        }
      }

      serviceRequirements[cat] = ServiceRequirement(
        category: cat,
        quantity: controllers['acres']?.text.trim() ?? 
                 controllers['trolleys']?.text.trim() ?? 
                 controllers['weight']?.text.trim(),
        duration: controllers['duration']?.text.trim(),
        frequency: _frequencySelections[cat],
        additionalDetails: additionalDetails,
      );
    }

    // Convert to JSON strings for storage
    final serviceCategoriesJson = jsonEncode(selectedCats);
    final categoryDetailsJson = jsonEncode(categoryDetails);
    final serviceRequirementsJson = jsonEncode(
      serviceRequirements.map((key, value) => MapEntry(key, value.toJson()))
    );

    // Update seeker profile with preferences
    final success = await authService.updateSeekerProfile(
      uid: uid,
      serviceCategories: serviceCategoriesJson,
      categoryDetails: categoryDetailsJson,
      serviceRequirements: serviceRequirementsJson,
      primaryPurpose: _primaryPurpose,
      urgency: _urgency,
      preferencesNotes: _notesController.text.trim(),
    );

    if (success && mounted) {
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text('Setup Complete!'),
            ],
          ),
          content: Text(
            'Your service preferences have been saved. You can now start booking services.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/seeker/dashboard');
              },
              child: Text('Go to Dashboard'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = ModalRoute.of(context)?.canPop ?? false;
    
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
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_currentStep > 0)
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () {
                              setState(() => _currentStep--);
                            },
                          ),
                        Expanded(
                          child: Text(
                            _currentStep == 0
                                ? 'What services do you need?'
                                : _currentStep == 1
                                    ? 'Select specific services'
                                    : _currentStep == 2
                                        ? 'Service requirements'
                                        : 'Additional details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (canGoBack)
                          TextButton.icon(
                            onPressed: () => _showSkipConfirmation(context),
                            icon: Icon(Icons.skip_next, color: Colors.white, size: 20),
                            label: Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      _currentStep == 0
                          ? 'Choose categories that match your needs'
                          : _currentStep == 1
                              ? 'Pick the specific services you require'
                              : _currentStep == 2
                                  ? 'Tell us about quantity, duration, and urgency'
                                  : 'Final details about your needs',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Progress indicator
                    Row(
                      children: List.generate(4, (index) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                            height: 4,
                            decoration: BoxDecoration(
                              color: index <= _currentStep
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _currentStep == 0
                ? _buildCategorySelection()
                : _currentStep == 1
                    ? _buildSubcategorySelection()
                    : _currentStep == 2
                        ? _buildRequirementsForm()
                        : _buildAdditionalDetails(),
          ),

          // Bottom button
          Container(
            padding: EdgeInsets.all(20),
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
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentStep == 3 ? 'Complete Setup' : 'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection() {
    final categories = ServiceCategories.getAllCategories();
    
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategories[category] ?? false;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategories[category] = !isSelected;
              if (!isSelected) {
                // Clear subcategories when deselecting category
                _selectedSubcategories[category] = [];
              }
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      ServiceCategories.getCategoryIcon(category),
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${ServiceCategories.getSubcategories(category).length} services available',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
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
    );
  }

  Widget _buildSubcategorySelection() {
    final selectedCats = _selectedCategories.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedCats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 80, color: Colors.grey.shade300),
            SizedBox(height: 16),
            Text(
              'No categories selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please go back and select at least one category',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: selectedCats.length,
      itemBuilder: (context, index) {
        final category = selectedCats[index];
        final subcategories = ServiceCategories.getSubcategories(category);
        final selectedSubs = _selectedSubcategories[category] ?? [];

        return Container(
          margin: EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    ServiceCategories.getCategoryIcon(category),
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 12),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: subcategories.map((sub) {
                  final isSelected = selectedSubs.contains(sub);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSubcategories[category]?.remove(sub);
                        } else {
                          if (_selectedSubcategories[category] == null) {
                            _selectedSubcategories[category] = [];
                          }
                          _selectedSubcategories[category]!.add(sub);
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            Icon(Icons.check, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                          ],
                          Text(
                            sub,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequirementsForm() {
    final selectedCats = _selectedCategories.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedCats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 80, color: Colors.grey.shade300),
            SizedBox(height: 16),
            Text(
              'No categories selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: selectedCats.length + 1, // +1 for urgency section
      itemBuilder: (context, index) {
        if (index == selectedCats.length) {
          // Urgency section
          return Container(
            margin: EdgeInsets.only(top: 16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text(
                      'When do you need these services?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ...UrgencyLevel.getAllLevels().map((level) {
                  final isSelected = _urgency == level;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _urgency = level);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            UrgencyLevel.getIcon(level),
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              level,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: AppColors.primary),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }

        // Category requirements
        final category = selectedCats[index];
        final fields = ServiceCategories.getRequirementFields(category);
        final controllers = _requirementControllers[category] ?? {};

        return Container(
          margin: EdgeInsets.only(bottom: 24),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    ServiceCategories.getCategoryIcon(category),
                    style: TextStyle(fontSize: 28),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              
              // Requirement fields
              ...fields.map((field) {
                final controller = controllers[field.key];
                return Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: controller,
                        keyboardType: field.inputType == 'number'
                            ? TextInputType.number
                            : TextInputType.text,
                        decoration: InputDecoration(
                          hintText: field.hint,
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              // Frequency selection
              SizedBox(height: 8),
              Text(
                'How often do you need this?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: FrequencyOption.getAllOptions().map((freq) {
                  final isSelected = _frequencySelections[category] == freq;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _frequencySelections[category] = freq);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        freq,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdditionalDetails() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primary Purpose',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          ...[
            'Personal/Individual Use',
            'Business/Commercial Use',
            'Agricultural Operations',
            'Construction Projects',
            'Emergency Needs',
          ].map((purpose) {
            return GestureDetector(
              onTap: () {
                setState(() => _primaryPurpose = purpose);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _primaryPurpose == purpose
                        ? AppColors.primary
                        : Colors.grey.shade200,
                    width: _primaryPurpose == purpose ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _primaryPurpose == purpose
                            ? AppColors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: _primaryPurpose == purpose
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: _primaryPurpose == purpose
                          ? Icon(Icons.check, color: Colors.white, size: 14)
                          : null,
                    ),
                    SizedBox(width: 12),
                    Text(
                      purpose,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          SizedBox(height: 24),
          Text(
            'Additional Notes (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us more about your specific requirements...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_currentStep == 0) {
      // Check if at least one category is selected
      final hasSelection = _selectedCategories.values.any((selected) => selected);
      if (!hasSelection) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select at least one service category'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      // Check if urgency is selected
      if (_urgency.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select when you need these services'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _currentStep = 3);
    } else {
      // Final step - save preferences
      if (_primaryPurpose.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select your primary purpose'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      _savePreferences();
    }
  }
}
