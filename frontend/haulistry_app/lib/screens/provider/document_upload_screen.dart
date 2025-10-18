import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../utils/app_colors.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  
  XFile? _profileImage;
  XFile? _cnicFrontImage;
  XFile? _cnicBackImage;
  XFile? _licenseImage;
  
  bool _isUploading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _cnicController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = ModalRoute.of(context)?.canPop ?? false;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Document Verification'),
        leading: canGoBack
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => _showSkipConfirmation(context),
              )
            : null,
        actions: [
          if (canGoBack)
            TextButton.icon(
              onPressed: () => _showSkipConfirmation(context),
              icon: Icon(Icons.skip_next, color: Colors.white),
              label: Text(
                'Skip',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Header with progress
          _buildHeader(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepContent(),
                  SizedBox(height: 32),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress Indicator
          Row(
            children: List.generate(4, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 16),
          Text(
            'Step ${_currentStep + 1} of 4',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _getStepTitle(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Profile Picture';
      case 1:
        return 'CNIC Front';
      case 2:
        return 'CNIC Back';
      case 3:
        return 'Driving License';
      default:
        return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildProfilePictureStep();
      case 1:
        return _buildCNICFrontStep();
      case 2:
        return _buildCNICBackStep();
      case 3:
        return _buildLicenseStep();
      default:
        return SizedBox();
    }
  }

  Widget _buildProfilePictureStep() {
    return Column(
      children: [
        Icon(
          Icons.account_circle,
          size: 80,
          color: AppColors.primary.withOpacity(0.5),
        ),
        SizedBox(height: 24),
        Text(
          'Upload Your Profile Picture',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'This helps customers recognize you',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 32),
        _buildImageUploadCard(
          title: 'Profile Picture',
          subtitle: 'Clear photo of your face',
          image: _profileImage,
          icon: Icons.person,
          color: Colors.blue,
          onTap: () => _pickImage(0),
        ),
        SizedBox(height: 24),
        _buildRequirements([
          'Clear, recent photo',
          'Face should be visible',
          'Good lighting',
          'No filters or editing',
        ]),
      ],
    );
  }

  Widget _buildCNICFrontStep() {
    return Column(
      children: [
        Icon(
          Icons.credit_card,
          size: 80,
          color: AppColors.primary.withOpacity(0.5),
        ),
        SizedBox(height: 24),
        Text(
          'CNIC Front Side',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Upload the front side of your CNIC',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 32),
        
        // CNIC Number Input
        TextField(
          controller: _cnicController,
          keyboardType: TextInputType.number,
          maxLength: 15,
          decoration: InputDecoration(
            labelText: 'CNIC Number',
            hintText: '12345-1234567-1',
            prefixIcon: Icon(Icons.credit_card, color: Colors.green),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 24),
        
        _buildImageUploadCard(
          title: 'CNIC Front',
          subtitle: 'Front side with photo',
          image: _cnicFrontImage,
          icon: Icons.credit_card,
          color: Colors.green,
          onTap: () => _pickImage(1),
        ),
        SizedBox(height: 24),
        _buildRequirements([
          'Enter valid CNIC number',
          'All corners visible',
          'Text clearly readable',
          'No glare or shadows',
          'Valid and not expired',
        ]),
      ],
    );
  }

  Widget _buildCNICBackStep() {
    return Column(
      children: [
        Icon(
          Icons.credit_card,
          size: 80,
          color: AppColors.primary.withOpacity(0.5),
        ),
        SizedBox(height: 24),
        Text(
          'CNIC Back Side',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Upload the back side of your CNIC',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 32),
        _buildImageUploadCard(
          title: 'CNIC Back',
          subtitle: 'Back side with details',
          image: _cnicBackImage,
          icon: Icons.credit_card,
          color: Colors.orange,
          onTap: () => _pickImage(2),
        ),
        SizedBox(height: 24),
        _buildRequirements([
          'All corners visible',
          'Address clearly readable',
          'No glare or shadows',
          'Scan or clear photo',
        ]),
      ],
    );
  }

  Widget _buildLicenseStep() {
    return Column(
      children: [
        Icon(
          Icons.badge,
          size: 80,
          color: AppColors.primary.withOpacity(0.5),
        ),
        SizedBox(height: 24),
        Text(
          'Driving License',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Upload your valid driving license',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 32),
        
        // License Number Input
        TextField(
          controller: _licenseController,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          maxLength: 20,
          decoration: InputDecoration(
            labelText: 'License Number',
            hintText: 'ABC-12345678',
            prefixIcon: Icon(Icons.badge, color: Colors.purple),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.purple, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 24),
        
        _buildImageUploadCard(
          title: 'Driving License',
          subtitle: 'Valid license for vehicle category',
          image: _licenseImage,
          icon: Icons.badge,
          color: Colors.purple,
          onTap: () => _pickImage(3),
        ),
        SizedBox(height: 24),
        _buildRequirements([
          'Enter valid license number',
          'License should be valid',
          'All details visible',
          'Matches vehicle category',
          'Not expired',
        ]),
      ],
    );
  }

  // Helper method to display XFile images on both web and mobile
  Widget _buildXFileImage(XFile image, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.network(
      image.path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(Icons.error, color: Colors.red),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageUploadCard({
    required String title,
    required String subtitle,
    required XFile? image,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              if (image == null) ...[
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3), width: 2, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 60, color: color),
                      SizedBox(height: 16),
                      Text(
                        'Tap to upload',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildXFileImage(
                        image,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.white, size: 20),
                          onPressed: () {
                            setState(() {
                              switch (_currentStep) {
                                case 0:
                                  _profileImage = null;
                                  break;
                                case 1:
                                  _cnicFrontImage = null;
                                  break;
                                case 2:
                                  _cnicBackImage = null;
                                  break;
                                case 3:
                                  _licenseImage = null;
                                  break;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Uploaded',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                TextButton.icon(
                  onPressed: onTap,
                  icon: Icon(Icons.refresh),
                  label: Text('Change Photo'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirements(List<String> requirements) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Requirements',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...requirements.map((req) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        req,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        if (_hasCurrentImage())
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _currentStep < 3 ? _nextStep : _submitDocuments,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep < 3 ? 'Continue' : 'Submit & Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        
        if (_currentStep > 0)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _previousStep,
              child: Text('Back'),
            ),
          ),
        
        if (!_hasCurrentImage())
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentStep == 1
                        ? 'Please enter CNIC number and upload image to continue'
                        : _currentStep == 3
                            ? 'Please enter license number and upload image to continue'
                            : 'Please upload ${_getStepTitle().toLowerCase()} to continue',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  bool _hasCurrentImage() {
    switch (_currentStep) {
      case 0:
        return _profileImage != null;
      case 1:
        return _cnicFrontImage != null && _cnicController.text.isNotEmpty;
      case 2:
        return _cnicBackImage != null;
      case 3:
        return _licenseImage != null && _licenseController.text.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _pickImage(int step) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          switch (step) {
            case 0:
              _profileImage = image;
              break;
            case 1:
              _cnicFrontImage = image;
              break;
            case 2:
              _cnicBackImage = image;
              break;
            case 3:
              _licenseImage = image;
              break;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _nextStep() {
    if (_hasCurrentImage()) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  Future<void> _submitDocuments() async {
    if (!_hasCurrentImage()) return;

    // Validate inputs
    if (_cnicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter CNIC number')),
      );
      return;
    }

    if (_licenseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter License number')),
      );
      return;
    }

    // Show loading
    setState(() => _isUploading = true);

    // Simulate upload
    await Future.delayed(Duration(seconds: 2));

    setState(() => _isUploading = false);

    // Show success dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green, size: 60),
              ),
              SizedBox(height: 16),
              Text('Documents Uploaded!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your documents have been submitted successfully.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.credit_card, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'CNIC: ${_cnicController.text}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.badge, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'License: ${_licenseController.text}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'We\'ll verify them within 24-48 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Show business setup dialog after document upload
                _showBusinessSetupDialog(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 45),
              ),
              child: Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  void _showSkipConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(child: Text('Skip Verification?')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skipping document verification means:'),
            SizedBox(height: 12),
            _buildWarningItem('❌', 'You won\'t receive booking requests'),
            _buildWarningItem('⚠️', 'Customers can\'t find your services'),
            _buildWarningItem('🔒', 'Your account will be unverified'),
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
                      'Takes only 5 minutes to verify!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continue Verification'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/provider/dashboard');
            },
            child: Text('Skip Anyway', style: TextStyle(color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }

  void _showBusinessSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.business_center, color: AppColors.primary, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Quick Setup',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Let\'s set up your business!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text(
              'Add your business details and vehicles to start receiving booking requests.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Quick setup (5 min) • Add more vehicles later',
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            _buildSetupItem('1', 'Business Information', Colors.blue),
            SizedBox(height: 8),
            _buildSetupItem('2', 'Add Your First Vehicle', Colors.green),
            SizedBox(height: 8),
            _buildSetupItem('3', 'Set Your Services', Colors.purple),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/provider/dashboard');
            },
            child: Text('Skip for Now', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/provider/details');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Start Setup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupItem(String number, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningItem(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
