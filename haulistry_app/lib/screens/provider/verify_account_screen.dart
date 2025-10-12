import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  final Map<String, dynamic> _verificationStatus = {
    'profilePicture': true,
    'cnic': true,
    'license': true,
    'businessInfo': false,
    'bankAccount': false,
    'phoneVerified': true,
    'emailVerified': true,
    'addressVerified': false,
  };

  final Map<String, String> _verificationLabels = {
    'profilePicture': 'Profile Picture',
    'cnic': 'CNIC Verification',
    'license': 'Driving License',
    'businessInfo': 'Business Information',
    'bankAccount': 'Bank Account',
    'phoneVerified': 'Phone Number',
    'emailVerified': 'Email Address',
    'addressVerified': 'Service Address',
  };

  final Map<String, String> _verificationDescriptions = {
    'profilePicture': 'Clear photo uploaded and verified',
    'cnic': 'National identity card verified',
    'license': 'Valid driving license verified',
    'businessInfo': 'Complete your business details',
    'bankAccount': 'Add bank account for payments',
    'phoneVerified': 'Phone number verified with OTP',
    'emailVerified': 'Email address confirmed',
    'addressVerified': 'Service address needs verification',
  };

  @override
  Widget build(BuildContext context) {
    final verifiedCount = _verificationStatus.values.where((v) => v == true).length;
    final totalCount = _verificationStatus.length;
    final verificationProgress = verifiedCount / totalCount;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Text(
                            'Account Verification',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Card
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getProgressColor(verificationProgress).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getProgressIcon(verificationProgress),
                                  color: _getProgressColor(verificationProgress),
                                  size: 32,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getProgressTitle(verificationProgress),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '$verifiedCount of $totalCount verified',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${(verificationProgress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _getProgressColor(verificationProgress),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: verificationProgress,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(verificationProgress),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Verified Items
                _buildSectionTitle('Verified', Icons.check_circle, Colors.green),
                SizedBox(height: 12),
                ..._getVerifiedItems().map((key) => _buildVerificationCard(
                      key,
                      _verificationLabels[key]!,
                      _verificationDescriptions[key]!,
                      true,
                    )),

                if (_getPendingItems().isNotEmpty) ...[
                  SizedBox(height: 24),
                  _buildSectionTitle('Pending Verification', Icons.pending, Colors.orange),
                  SizedBox(height: 12),
                  ..._getPendingItems().map((key) => _buildVerificationCard(
                        key,
                        _verificationLabels[key]!,
                        _verificationDescriptions[key]!,
                        false,
                      )),
                ],

                SizedBox(height: 24),
                _buildBenefitsCard(),

                SizedBox(height: 24),
                _buildHelpCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationCard(
    String key,
    String title,
    String description,
    bool isVerified,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isVerified
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isVerified ? Icons.check_circle : Icons.pending,
                color: isVerified ? Colors.green : Colors.orange,
                size: 28,
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
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isVerified)
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 18),
                color: AppColors.primary,
                onPressed: () => _handleVerificationAction(key),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: Colors.blue, size: 24),
              SizedBox(width: 12),
              Text(
                'Benefits of Full Verification',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildBenefitItem('✅', 'Get 3x more booking requests'),
          _buildBenefitItem('⭐', 'Priority listing in search results'),
          _buildBenefitItem('🔒', 'Build customer trust & credibility'),
          _buildBenefitItem('💰', 'Higher earnings potential'),
          _buildBenefitItem('🎁', 'Access to premium features'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 18)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.help_outline, color: AppColors.primary, size: 48),
            SizedBox(height: 16),
            Text(
              'Need Help with Verification?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Our support team is here to assist you with the verification process.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/help-center'),
              icon: Icon(Icons.support_agent),
              label: Text('Contact Support'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getVerifiedItems() {
    return _verificationStatus.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();
  }

  List<String> _getPendingItems() {
    return _verificationStatus.entries
        .where((e) => e.value == false)
        .map((e) => e.key)
        .toList();
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.7) return Colors.blue;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red;
  }

  IconData _getProgressIcon(double progress) {
    if (progress >= 1.0) return Icons.verified;
    if (progress >= 0.7) return Icons.hourglass_top;
    if (progress >= 0.4) return Icons.pending;
    return Icons.warning;
  }

  String _getProgressTitle(double progress) {
    if (progress >= 1.0) return 'Fully Verified!';
    if (progress >= 0.7) return 'Almost There!';
    if (progress >= 0.4) return 'Good Progress';
    return 'Get Started';
  }

  void _handleVerificationAction(String key) {
    switch (key) {
      case 'businessInfo':
        context.push('/provider/details');
        break;
      case 'bankAccount':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening bank account setup...')),
        );
        break;
      case 'addressVerified':
        context.push('/provider/service-areas');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $key verification...')),
        );
    }
  }
}
