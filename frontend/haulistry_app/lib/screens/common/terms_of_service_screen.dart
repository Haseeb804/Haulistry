import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
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
                        'Terms of Service',
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
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Last Updated
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.update, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Effective Date: January 1, 2024',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Introduction
                  _buildSection(
                    '1. Acceptance of Terms',
                    'By accessing or using the Haulistry mobile application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.',
                  ),

                  _buildSection(
                    '2. Description of Service',
                    'Haulistry is a platform that connects service seekers with service providers for agricultural machinery, construction equipment, logistics, and related services. We facilitate bookings, payments, and communications between users.',
                  ),

                  _buildSection(
                    '3. User Accounts',
                    'Account Registration:\n'
                    '• You must be at least 18 years old\n'
                    '• Provide accurate and complete information\n'
                    '• Maintain the security of your account\n'
                    '• Notify us of unauthorized access\n\n'
                    'Account Types:\n'
                    '• Service Seeker: Book and manage services\n'
                    '• Service Provider: Offer services and manage bookings\n\n'
                    'Account Termination:\n'
                    '• You may close your account at any time\n'
                    '• We may suspend or terminate accounts for violations',
                  ),

                  _buildSection(
                    '4. Service Provider Obligations',
                    'As a service provider, you agree to:\n\n'
                    '• Provide accurate service information\n'
                    '• Maintain valid licenses and permits\n'
                    '• Keep vehicles and equipment properly maintained\n'
                    '• Provide services as described and agreed\n'
                    '• Respond promptly to booking requests\n'
                    '• Maintain insurance coverage\n'
                    '• Follow all applicable laws and regulations\n'
                    '• Treat customers professionally and respectfully',
                  ),

                  _buildSection(
                    '5. Service Seeker Obligations',
                    'As a service seeker, you agree to:\n\n'
                    '• Provide accurate booking information\n'
                    '• Be present at agreed upon times\n'
                    '• Treat service providers respectfully\n'
                    '• Pay for services as agreed\n'
                    '• Cancel bookings according to policy\n'
                    '• Provide honest feedback and reviews\n'
                    '• Not misuse the platform or services',
                  ),

                  _buildSection(
                    '6. Booking and Payments',
                    'Booking Process:\n'
                    '• Bookings are subject to provider availability\n'
                    '• Prices are shown before confirmation\n'
                    '• Bookings are confirmed upon acceptance\n\n'
                    'Payment Terms:\n'
                    '• Payment is processed through our secure gateway\n'
                    '• Service fees and taxes may apply\n'
                    '• Providers receive payment after service completion\n'
                    '• Refunds are subject to our cancellation policy\n\n'
                    'Cancellation Policy:\n'
                    '• Free cancellation up to 24 hours before service\n'
                    '• Cancellation fees apply for late cancellations\n'
                    '• No-show may result in full charge',
                  ),

                  _buildSection(
                    '7. Platform Fees',
                    'Haulistry charges service fees for use of the platform:\n\n'
                    '• Service Seekers: Booking fees may apply\n'
                    '• Service Providers: Commission on completed bookings\n'
                    '• Payment Processing: Transaction fees\n\n'
                    'Fees are clearly displayed before booking confirmation.',
                  ),

                  _buildSection(
                    '8. User Conduct',
                    'Users must NOT:\n\n'
                    '• Use the platform for illegal activities\n'
                    '• Harass, threaten, or harm other users\n'
                    '• Provide false or misleading information\n'
                    '• Attempt to circumvent our systems\n'
                    '• Share account credentials\n'
                    '• Post inappropriate content\n'
                    '• Spam or solicit users\n'
                    '• Violate intellectual property rights',
                  ),

                  _buildSection(
                    '9. Reviews and Ratings',
                    'Review Guidelines:\n'
                    '• Reviews must be honest and accurate\n'
                    '• No offensive or discriminatory content\n'
                    '• Based on actual experience\n'
                    '• Respect privacy of others\n\n'
                    'We reserve the right to remove reviews that violate our guidelines.',
                  ),

                  _buildSection(
                    '10. Intellectual Property',
                    'All content, features, and functionality of Haulistry are owned by us and protected by intellectual property laws. You may not:\n\n'
                    '• Copy or reproduce our content\n'
                    '• Modify or create derivative works\n'
                    '• Use our trademarks without permission\n'
                    '• Reverse engineer our software',
                  ),

                  _buildSection(
                    '11. Liability and Disclaimers',
                    'Service Quality:\n'
                    '• We are a platform connecting users\n'
                    '• We do not directly provide services\n'
                    '• Service quality is the provider\'s responsibility\n\n'
                    'Limitations:\n'
                    '• Services provided "as is"\n'
                    '• We do not guarantee continuous availability\n'
                    '• We are not liable for disputes between users\n'
                    '• Maximum liability limited to fees paid\n\n'
                    'Insurance:\n'
                    '• Providers must maintain adequate insurance\n'
                    '• Users are responsible for their own insurance needs',
                  ),

                  _buildSection(
                    '12. Indemnification',
                    'You agree to indemnify and hold Haulistry harmless from claims, damages, and expenses arising from:\n\n'
                    '• Your use of the platform\n'
                    '• Your violation of these terms\n'
                    '• Your violation of any laws\n'
                    '• Services provided or received',
                  ),

                  _buildSection(
                    '13. Dispute Resolution',
                    'Resolution Process:\n'
                    '1. Contact our support team first\n'
                    '2. We will mediate between parties\n'
                    '3. Formal complaint process if needed\n'
                    '4. Arbitration or legal action as last resort\n\n'
                    'Governing Law:\n'
                    '• These terms are governed by Pakistani law\n'
                    '• Disputes subject to courts of Faisalabad, Pakistan',
                  ),

                  _buildSection(
                    '14. Changes to Terms',
                    'We may modify these terms at any time. We will notify you of significant changes through:\n\n'
                    '• Email notification\n'
                    '• In-app notification\n'
                    '• Updated terms in the app\n\n'
                    'Continued use after changes constitutes acceptance of new terms.',
                  ),

                  _buildSection(
                    '15. Termination',
                    'We may terminate or suspend your account for:\n\n'
                    '• Violation of these terms\n'
                    '• Fraudulent activity\n'
                    '• Abusive behavior\n'
                    '• Legal requirements\n'
                    '• Prolonged inactivity\n\n'
                    'Upon termination, your right to use the service ceases immediately.',
                  ),

                  _buildSection(
                    '16. Contact Information',
                    'For questions about these Terms of Service:\n\n'
                    '📧 Email: legal@haulistry.com\n'
                    '📞 Phone: +92 300 1234567\n'
                    '🌐 Website: www.haulistry.com\n'
                    '📍 Address: Faisalabad, Punjab, Pakistan',
                  ),

                  SizedBox(height: 32),

                  // Agreement Notice
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.gavel, color: Colors.orange, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Legal Agreement',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'By using Haulistry, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
