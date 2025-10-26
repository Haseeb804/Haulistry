import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  bool _locationServices = true;
  bool _autoBackup = true;
  String _language = 'English';
  String _currency = 'PKR';

  final List<Map<String, dynamic>> _accountSettings = [
    {
      'icon': Icons.person,
      'title': 'Account Information',
      'subtitle': 'Edit your personal details',
      'route': '/seeker/edit-profile',
      'color': AppColors.primary,
    },
    {
      'icon': Icons.security,
      'title': 'Privacy & Security',
      'subtitle': 'Manage your privacy settings',
      'route': '/privacy-security',
      'color': Colors.green,
    },
    {
      'icon': Icons.payment,
      'title': 'Payment Settings',
      'subtitle': 'Manage payment methods',
      'route': '/payment-settings',
      'color': Colors.orange,
    },
    {
      'icon': Icons.location_on,
      'title': 'Location Settings',
      'subtitle': 'Manage location preferences',
      'route': '/location-settings',
      'color': Colors.red,
    },
  ];

  final List<Map<String, dynamic>> _appSettings = [
    {
      'icon': Icons.language,
      'title': 'Language',
      'subtitle': 'Change app language',
      'action': 'language',
      'color': Colors.blue,
    },
    {
      'icon': Icons.currency_exchange,
      'title': 'Currency',
      'subtitle': 'Set preferred currency',
      'action': 'currency',
      'color': Colors.purple,
    },
    {
      'icon': Icons.backup,
      'title': 'Data Backup',
      'subtitle': 'Backup your data',
      'action': 'backup',
      'color': Colors.teal,
    },
    {
      'icon': Icons.storage,
      'title': 'Storage',
      'subtitle': 'Manage app storage',
      'action': 'storage',
      'color': Colors.indigo,
    },
  ];

  final List<Map<String, dynamic>> _supportSettings = [
    {
      'icon': Icons.help,
      'title': 'Help Center',
      'subtitle': 'Get help and support',
      'route': '/help-center',
      'color': Colors.cyan,
    },
    {
      'icon': Icons.feedback,
      'title': 'Send Feedback',
      'subtitle': 'Share your feedback',
      'action': 'feedback',
      'color': Colors.pink,
    },
    {
      'icon': Icons.star_rate,
      'title': 'Rate App',
      'subtitle': 'Rate us on app store',
      'action': 'rate',
      'color': Colors.amber,
    },
    {
      'icon': Icons.info,
      'title': 'About',
      'subtitle': 'App version and info',
      'route': '/about',
      'color': Colors.grey,
    },
  ];

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
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notifications Section
                    _buildSectionTitle('Notifications'),
                    SizedBox(height: 12),
                    _buildNotificationSettings(),

                    SizedBox(height: 24),

                    // Account Section
                    _buildSectionTitle('Account'),
                    SizedBox(height: 12),
                    _buildSettingsGroup(_accountSettings),

                    SizedBox(height: 24),

                    // App Settings Section
                    _buildSectionTitle('App Settings'),
                    SizedBox(height: 12),
                    _buildSettingsGroup(_appSettings, showActions: true),

                    SizedBox(height: 24),

                    // Support Section
                    _buildSectionTitle('Support'),
                    SizedBox(height: 12),
                    _buildSettingsGroup(_supportSettings, showActions: true),

                    SizedBox(height: 24),

                    // Dangerous Actions
                    _buildSectionTitle('Account Actions'),
                    SizedBox(height: 12),
                    _buildDangerousActions(),

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

  Widget _buildNotificationSettings() {
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
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive push notifications',
            value: _pushNotifications,
            onChanged: (value) => setState(() => _pushNotifications = value),
            color: Colors.blue,
          ),
          Divider(height: 1),
          _buildSwitchTile(
            icon: Icons.email,
            title: 'Email Notifications',
            subtitle: 'Receive email updates',
            value: _emailNotifications,
            onChanged: (value) => setState(() => _emailNotifications = value),
            color: Colors.red,
          ),
          Divider(height: 1),
          _buildSwitchTile(
            icon: Icons.sms,
            title: 'SMS Notifications',
            subtitle: 'Receive SMS alerts',
            value: _smsNotifications,
            onChanged: (value) => setState(() => _smsNotifications = value),
            color: Colors.green,
          ),
          Divider(height: 1),
          _buildSwitchTile(
            icon: Icons.location_on,
            title: 'Location Services',
            subtitle: 'Allow location access',
            value: _locationServices,
            onChanged: (value) => setState(() => _locationServices = value),
            color: Colors.orange,
          ),
          Divider(height: 1),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.setDarkMode(value);
                },
                color: Colors.purple,
                isLast: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
    bool isLast = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSettingsGroup(List<Map<String, dynamic>> settings, {bool showActions = false}) {
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
      child: Column(
        children: List.generate(settings.length, (index) {
          final setting = settings[index];
          return Column(
            children: [
              ListTile(
                onTap: () => _handleSettingTap(setting, showActions),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: setting['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    setting['icon'],
                    color: setting['color'],
                    size: 24,
                  ),
                ),
                title: Text(
                  setting['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  setting['subtitle'],
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                trailing: _buildTrailing(setting, showActions),
              ),
              if (index < settings.length - 1) Divider(height: 1),
            ],
          );
        }),
      ),
    );
  }

  Widget? _buildTrailing(Map<String, dynamic> setting, bool showActions) {
    if (showActions && setting.containsKey('action')) {
      switch (setting['action']) {
        case 'language':
          return Text(
            _language,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          );
        case 'currency':
          return Text(
            _currency,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          );
        default:
          return Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textSecondary,
          );
      }
    }
    return Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: AppColors.textSecondary,
    );
  }

  Widget _buildDangerousActions() {
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
      child: Column(
        children: [
          ListTile(
            onTap: () => _logout(),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.logout,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Sign out from your account',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          Divider(height: 1),
          ListTile(
            onTap: () => _clearCache(),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.clear_all,
                color: Colors.orange,
                size: 24,
              ),
            ),
            title: Text(
              'Clear Cache',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Clear app cache and temporary files',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          Divider(height: 1),
          ListTile(
            onTap: () => _deleteAccount(),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_forever,
                color: AppColors.error,
                size: 24,
              ),
            ),
            title: Text(
              'Delete Account',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.error,
              ),
            ),
            subtitle: Text(
              'Permanently delete your account',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSettingTap(Map<String, dynamic> setting, bool showActions) {
    if (setting.containsKey('route')) {
      context.push(setting['route']);
    } else if (showActions && setting.containsKey('action')) {
      switch (setting['action']) {
        case 'language':
          _showLanguageDialog();
          break;
        case 'currency':
          _showCurrencyDialog();
          break;
        case 'backup':
          _performBackup();
          break;
        case 'storage':
          _showStorageInfo();
          break;
        case 'feedback':
          _sendFeedback();
          break;
        case 'rate':
          _rateApp();
          break;
      }
    }
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Urdu', 'Arabic', 'Chinese'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              value: lang,
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                context.pop();
              },
              title: Text(lang),
              activeColor: AppColors.primary,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    final currencies = ['PKR', 'USD', 'EUR', 'GBP'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((curr) {
            return RadioListTile<String>(
              value: curr,
              groupValue: _currency,
              onChanged: (value) {
                setState(() => _currency = value!);
                context.pop();
              },
              title: Text(curr),
              activeColor: AppColors.primary,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _performBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Backup Data'),
        content: Text('Do you want to backup your data to cloud storage?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Backup started successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _showStorageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Storage Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Size: 45.2 MB'),
            SizedBox(height: 8),
            Text('Cache: 12.1 MB'),
            SizedBox(height: 8),
            Text('User Data: 8.7 MB'),
            SizedBox(height: 8),
            Text('Total: 66.0 MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _sendFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening feedback form...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening app store...'),
        backgroundColor: AppColors.primary,
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
            onPressed: () => context.pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop(); // Close dialog
              
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Logout'),
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
        content: Text('This will clear all cached data and temporary files. Continue?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: TextStyle(color: AppColors.error),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This action cannot be undone. All your data will be permanently deleted:'),
            SizedBox(height: 12),
            Text('• Profile information'),
            Text('• Booking history'),
            Text('• Messages'),
            Text('• Favorites'),
            Text('• Payment methods'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              _confirmDeleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Final Confirmation'),
        content: Text('Type "DELETE" to confirm account deletion:'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel'),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: 'Type DELETE',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              if (value == 'DELETE') {
                context.pop();
                context.go('/login');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Account deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}