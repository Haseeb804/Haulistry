import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';

class ProviderSettingsScreen extends StatefulWidget {
  const ProviderSettingsScreen({super.key});

  @override
  State<ProviderSettingsScreen> createState() => _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState extends State<ProviderSettingsScreen> {
  // Notification Settings
  bool _bookingNotifications = true;
  bool _messageNotifications = true;
  bool _paymentNotifications = true;
  bool _reviewNotifications = true;
  bool _promotionalNotifications = false;

  // Business Settings
  bool _instantBooking = false;
  bool _autoAcceptBookings = false;
  String _workingHours = '9:00 AM - 6:00 PM';
  List<String> _workingDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  // App Settings
  String _language = 'English';

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
                        'Settings',
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
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Settings
                  _buildSectionTitle('Notifications'),
                  SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      'Booking Notifications',
                      'Get notified about new booking requests',
                      Icons.event,
                      _bookingNotifications,
                      (value) => setState(() => _bookingNotifications = value),
                    ),
                    Divider(height: 1),
                    _buildSwitchTile(
                      'Message Notifications',
                      'Get notified when you receive messages',
                      Icons.message,
                      _messageNotifications,
                      (value) => setState(() => _messageNotifications = value),
                    ),
                    Divider(height: 1),
                    _buildSwitchTile(
                      'Payment Notifications',
                      'Get notified about payments and earnings',
                      Icons.payment,
                      _paymentNotifications,
                      (value) => setState(() => _paymentNotifications = value),
                    ),
                    Divider(height: 1),
                    _buildSwitchTile(
                      'Review Notifications',
                      'Get notified when you receive new reviews',
                      Icons.star,
                      _reviewNotifications,
                      (value) => setState(() => _reviewNotifications = value),
                    ),
                    Divider(height: 1),
                    _buildSwitchTile(
                      'Promotional Notifications',
                      'Receive offers and promotional content',
                      Icons.local_offer,
                      _promotionalNotifications,
                      (value) => setState(() => _promotionalNotifications = value),
                    ),
                  ]),

                  SizedBox(height: 24),

                  // Business Settings
                  _buildSectionTitle('Business Settings'),
                  SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      'Instant Booking',
                      'Allow clients to book without approval',
                      Icons.flash_on,
                      _instantBooking,
                      (value) => setState(() => _instantBooking = value),
                    ),
                    Divider(height: 1),
                    _buildSwitchTile(
                      'Auto-Accept Bookings',
                      'Automatically accept all booking requests',
                      Icons.check_circle,
                      _autoAcceptBookings,
                      (value) => setState(() => _autoAcceptBookings = value),
                    ),
                    Divider(height: 1),
                    _buildNavTile(
                      'Working Hours',
                      _workingHours,
                      Icons.access_time,
                      () => _editWorkingHours(),
                    ),
                    Divider(height: 1),
                    _buildNavTile(
                      'Working Days',
                      '${_workingDays.length} days selected',
                      Icons.calendar_today,
                      () => _editWorkingDays(),
                    ),
                    Divider(height: 1),
                    _buildNavTile(
                      'Service Areas',
                      'Manage your service locations',
                      Icons.location_on,
                      () => context.push('/provider/service-areas'),
                    ),
                  ]),

                  SizedBox(height: 24),

                  // Payment Settings
                  _buildSectionTitle('Payment Settings'),
                  SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildNavTile(
                      'Bank Account',
                      'Manage withdrawal account',
                      Icons.account_balance,
                      () => context.push('/provider/bank-account'),
                    ),
                    Divider(height: 1),
                    _buildNavTile(
                      'Payment History',
                      'View all transactions',
                      Icons.history,
                      () => context.push('/provider/earnings'),
                    ),
                  ]),

                  SizedBox(height: 24),

                  // App Settings
                  _buildSectionTitle('App Settings'),
                  SizedBox(height: 12),
                  _buildSettingsCard([
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return _buildSwitchTile(
                          'Dark Mode',
                          'Enable dark theme',
                          Icons.dark_mode,
                          themeProvider.isDarkMode,
                          (value) => themeProvider.setDarkMode(value),
                        );
                      },
                    ),
                    Divider(height: 1),
                    _buildNavTile(
                      'Language',
                      _language,
                      Icons.language,
                      () => _changeLanguage(),
                    ),
                    Divider(height: 1),
                    _buildNavTile(
                      'Clear Cache',
                      'Free up storage space',
                      Icons.cleaning_services,
                      () => _clearCache(),
                    ),
                  ]),

                  SizedBox(height: 24),

                  // Account Settings
                  _buildSectionTitle('Account'),
                  SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildNavTile(
                      'Privacy & Security',
                      'Manage privacy settings',
                      Icons.security,
                      () => context.push('/privacy-security'),
                    ),
                    Divider(height: 1),
                    _buildNavTile(
                      'Payment Settings',
                      'Manage payment methods',
                      Icons.payment,
                      () => context.push('/payment-settings'),
                    ),
                    Divider(height: 1),
                    _buildNavTile(
                      'Location Settings',
                      'Manage location preferences',
                      Icons.location_on,
                      () => context.push('/location-settings'),
                    ),
                    Divider(height: 1),
                    _buildNavTile(
                      'Change Password',
                      'Update your password',
                      Icons.lock,
                      () => context.push('/provider/change-password'),
                    ),
                    Divider(height: 1),
                    _buildNavTile(
                      'Verify Account',
                      'Complete business verification',
                      Icons.verified_user,
                      () => context.push('/provider/verification'),
                    ),
                  ]),

                  SizedBox(height: 24),

                  // Support
                  _buildSectionTitle('Support & About'),
                  SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildNavTile(
                      'Help Center',
                      'Get help and support',
                      Icons.help,
                      () => context.push('/help-center'),
                    ),
                    Divider(height: 1),
                    _buildNavTile(
                      'About',
                      'App version and info',
                      Icons.info,
                      () => context.push('/about'),
                    ),
                  ]),

                  SizedBox(height: 24),

                  // Dangerous Actions
                  _buildSectionTitle('Account Actions'),
                  SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildNavTile(
                      'Logout',
                      'Sign out from your account',
                      Icons.logout,
                      () => _logout(),
                      color: AppColors.primary,
                    ),
                    Divider(height: 1),
                    _buildNavTile(
                      'Delete Account',
                      'Permanently delete your account',
                      Icons.delete_forever,
                      () => _deleteAccount(),
                      color: AppColors.error,
                    ),
                  ]),

                  SizedBox(height: 24),

                  // Support & Legal
                  _buildSectionTitle('Support & Legal'),
                  SizedBox(height: 12),
                  _buildSettingsCard([
                    Divider(height: 1),
                    _buildNavTile(
                      'Privacy Policy',
                      'Read our privacy policy',
                      Icons.privacy_tip,
                      () => _showPrivacyPolicy(),
                    ),
                    Divider(height: 1),
                    _buildNavTile(
                      'Terms of Service',
                      'Read terms and conditions',
                      Icons.description,
                      () => _showTerms(),
                    ),
                  ]),

                  SizedBox(height: 24),

                  // App Version
                  Center(
                    child: Text(
                      'Haulistry Provider v1.0.0',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  SizedBox(height: 40),
                ],
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

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
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

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      secondary: Icon(icon, color: AppColors.primary),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildNavTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _editWorkingHours() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Working Hours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('9:00 AM - 6:00 PM'),
              leading: Radio(value: true, groupValue: true, onChanged: (v) {}),
            ),
            ListTile(
              title: Text('8:00 AM - 8:00 PM'),
              leading: Radio(value: false, groupValue: true, onChanged: (v) {}),
            ),
            ListTile(
              title: Text('Custom Hours'),
              leading: Radio(value: false, groupValue: true, onChanged: (v) {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editWorkingDays() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Working Days'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday'
          ]
              .map((day) => CheckboxListTile(
                    value: _workingDays.contains(day),
                    onChanged: (v) {},
                    title: Text(day),
                    activeColor: AppColors.primary,
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('English'),
              leading: Radio(value: 'English', groupValue: _language, onChanged: (v) {}),
            ),
            ListTile(
              title: Text('اردو (Urdu)'),
              leading: Radio(value: 'Urdu', groupValue: _language, onChanged: (v) {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cache'),
        content: Text('This will clear all cached data and free up storage space.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );

              // Logout
              final authService = context.read<AuthService>();
              await authService.logout();

              // Close loading
              if (mounted) Navigator.of(context).pop();

              // Navigate to login
              if (mounted) {
                context.go('/login');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Logged out successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 12),
            Text('Delete Account'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform account deletion
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

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text('Privacy policy content goes here...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text('Terms and conditions content goes here...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
