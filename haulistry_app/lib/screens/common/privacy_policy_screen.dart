import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                        'Privacy Policy',
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
                          'Last updated: January 1, 2024',
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
                    '1. Introduction',
                    'Welcome to Haulistry. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you visit our app and tell you about your privacy rights.',
                  ),

                  _buildSection(
                    '2. Information We Collect',
                    'We collect the following types of information:\n\n'
                    '• Personal Information: Name, email, phone number, address\n'
                    '• Profile Information: Profile picture, business details, vehicle information\n'
                    '• Identity Documents: CNIC, driving license (for providers)\n'
                    '• Location Data: GPS location for service delivery\n'
                    '• Payment Information: Bank account details, transaction history\n'
                    '• Usage Data: How you interact with our app\n'
                    '• Device Information: Device model, operating system, unique identifiers',
                  ),

                  _buildSection(
                    '3. How We Use Your Information',
                    'We use your personal data for:\n\n'
                    '• Providing Services: To facilitate bookings and transactions\n'
                    '• Account Management: To create and manage your account\n'
                    '• Communication: To send you updates, notifications, and support\n'
                    '• Verification: To verify your identity and credentials\n'
                    '• Payments: To process payments and maintain transaction records\n'
                    '• Improvement: To improve our services and user experience\n'
                    '• Safety: To ensure platform safety and prevent fraud\n'
                    '• Legal Compliance: To comply with legal obligations',
                  ),

                  _buildSection(
                    '4. Information Sharing',
                    'We may share your information with:\n\n'
                    '• Service Providers: To complete bookings and transactions\n'
                    '• Payment Processors: To handle financial transactions\n'
                    '• Business Partners: For service delivery and support\n'
                    '• Legal Authorities: When required by law or to protect rights\n'
                    '• Analytics Partners: To improve our services (anonymized data)\n\n'
                    'We do NOT sell your personal information to third parties.',
                  ),

                  _buildSection(
                    '5. Data Security',
                    'We implement appropriate security measures to protect your personal data:\n\n'
                    '• 256-bit SSL encryption for data transmission\n'
                    '• Secure servers with regular security audits\n'
                    '• Access controls and authentication systems\n'
                    '• Regular data backups\n'
                    '• Employee training on data protection\n'
                    '• Compliance with industry security standards',
                  ),

                  _buildSection(
                    '6. Your Rights',
                    'You have the right to:\n\n'
                    '• Access: Request access to your personal data\n'
                    '• Correction: Request correction of inaccurate data\n'
                    '• Deletion: Request deletion of your data\n'
                    '• Restriction: Request restriction of processing\n'
                    '• Portability: Request transfer of your data\n'
                    '• Objection: Object to processing of your data\n'
                    '• Withdraw Consent: Withdraw consent at any time\n\n'
                    'To exercise these rights, contact us at privacy@haulistry.com',
                  ),

                  _buildSection(
                    '7. Data Retention',
                    'We retain your personal data for as long as necessary to:\n\n'
                    '• Provide our services to you\n'
                    '• Comply with legal obligations\n'
                    '• Resolve disputes and enforce agreements\n'
                    '• Maintain business records\n\n'
                    'When data is no longer needed, we securely delete or anonymize it.',
                  ),

                  _buildSection(
                    '8. Cookies and Tracking',
                    'We use cookies and similar technologies to:\n\n'
                    '• Remember your preferences and settings\n'
                    '• Analyze app usage and performance\n'
                    '• Provide personalized content\n'
                    '• Improve user experience\n\n'
                    'You can control cookies through your device settings.',
                  ),

                  _buildSection(
                    '9. Children\'s Privacy',
                    'Our services are not intended for users under 18 years of age. We do not knowingly collect personal information from children. If you believe we have collected data from a child, please contact us immediately.',
                  ),

                  _buildSection(
                    '10. International Data Transfers',
                    'Your data may be transferred to and processed in countries other than Pakistan. We ensure appropriate safeguards are in place to protect your data in compliance with applicable data protection laws.',
                  ),

                  _buildSection(
                    '11. Changes to This Policy',
                    'We may update this privacy policy from time to time. We will notify you of any changes by:\n\n'
                    '• Posting the new policy in the app\n'
                    '• Sending you an email notification\n'
                    '• Showing an in-app notification\n\n'
                    'Continued use of our services after changes constitutes acceptance.',
                  ),

                  _buildSection(
                    '12. Contact Us',
                    'If you have questions about this privacy policy or our privacy practices:\n\n'
                    '📧 Email: privacy@haulistry.com\n'
                    '📞 Phone: +92 300 1234567\n'
                    '🌐 Website: www.haulistry.com\n'
                    '📍 Address: Faisalabad, Punjab, Pakistan',
                  ),

                  SizedBox(height: 32),

                  // Agreement Notice
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_user, color: Colors.green, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Privacy Matters',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'By using Haulistry, you agree to this privacy policy. We are committed to protecting your personal information and respecting your privacy rights.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green.shade800,
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
