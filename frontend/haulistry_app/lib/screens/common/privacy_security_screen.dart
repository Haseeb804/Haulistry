import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _twoFactorAuth = false;
  bool _biometricAuth = true;
  bool _showOnlineStatus = true;
  bool _shareLocation = true;
  bool _sharePhoneNumber = false;
  bool _allowMarketingEmails = true;
  bool _allowDataAnalytics = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Privacy & Security'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Security Section
          _buildSectionHeader(context, 'Security', Icons.security),
          SizedBox(height: 12),
          _buildSecurityCard(context),
          
          SizedBox(height: 24),
          
          // Privacy Section
          _buildSectionHeader(context, 'Privacy', Icons.privacy_tip),
          SizedBox(height: 12),
          _buildPrivacyCard(context),
          
          SizedBox(height: 24),
          
          // Data Section
          _buildSectionHeader(context, 'Data & Permissions', Icons.storage),
          SizedBox(height: 12),
          _buildDataCard(context),
          
          SizedBox(height: 24),
          
          // Actions
          _buildActionButtons(context),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildSwitchTile(
            context,
            'Two-Factor Authentication',
            'Add an extra layer of security',
            Icons.verified_user,
            _twoFactorAuth,
            (value) => setState(() => _twoFactorAuth = value),
            Colors.green,
          ),
          Divider(height: 1),
          _buildSwitchTile(
            context,
            'Biometric Login',
            'Use fingerprint or face ID',
            Icons.fingerprint,
            _biometricAuth,
            (value) => setState(() => _biometricAuth = value),
            Colors.blue,
          ),
          Divider(height: 1),
          _buildNavigationTile(
            context,
            'Change Password',
            'Update your password',
            Icons.lock_reset,
            Colors.orange,
            () => _showChangePasswordDialog(context),
          ),
          Divider(height: 1),
          _buildNavigationTile(
            context,
            'Login Activity',
            'View recent login history',
            Icons.history,
            Colors.purple,
            () => _showLoginActivity(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildSwitchTile(
            context,
            'Show Online Status',
            'Let others see when you\'re online',
            Icons.circle,
            _showOnlineStatus,
            (value) => setState(() => _showOnlineStatus = value),
            Colors.green,
          ),
          Divider(height: 1),
          _buildSwitchTile(
            context,
            'Share Location',
            'Allow location sharing',
            Icons.location_on,
            _shareLocation,
            (value) => setState(() => _shareLocation = value),
            Colors.red,
          ),
          Divider(height: 1),
          _buildSwitchTile(
            context,
            'Share Phone Number',
            'Show phone to providers',
            Icons.phone,
            _sharePhoneNumber,
            (value) => setState(() => _sharePhoneNumber = value),
            Colors.blue,
          ),
          Divider(height: 1),
          _buildNavigationTile(
            context,
            'Blocked Users',
            'Manage blocked accounts',
            Icons.block,
            Colors.red,
            () => _showBlockedUsers(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildSwitchTile(
            context,
            'Marketing Emails',
            'Receive promotional emails',
            Icons.email,
            _allowMarketingEmails,
            (value) => setState(() => _allowMarketingEmails = value),
            Colors.indigo,
          ),
          Divider(height: 1),
          _buildSwitchTile(
            context,
            'Analytics',
            'Help improve the app',
            Icons.analytics,
            _allowDataAnalytics,
            (value) => setState(() => _allowDataAnalytics = value),
            Colors.teal,
          ),
          Divider(height: 1),
          _buildNavigationTile(
            context,
            'Download My Data',
            'Request your data archive',
            Icons.download,
            Colors.blue,
            () => _showDownloadDataDialog(context),
          ),
          Divider(height: 1),
          _buildNavigationTile(
            context,
            'Delete Account',
            'Permanently delete your account',
            Icons.delete_forever,
            Colors.red,
            () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    Color iconColor,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _saveSettings(context),
            icon: Icon(Icons.save),
            label: Text('Save Settings'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _resetToDefaults(context),
            icon: Icon(Icons.refresh),
            label: Text('Reset to Defaults'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _saveSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Settings saved successfully'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetToDefaults(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 12),
            Text('Reset Settings?'),
          ],
        ),
        content: Text('This will reset all privacy and security settings to default values.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _twoFactorAuth = false;
                _biometricAuth = true;
                _showOnlineStatus = true;
                _shareLocation = true;
                _sharePhoneNumber = false;
                _allowMarketingEmails = true;
                _allowDataAnalytics = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password updated successfully')),
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLoginActivity(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Recent Login Activity'),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildLoginActivityItem('Today, 10:30 AM', 'iPhone 13', 'Lahore, Pakistan'),
              _buildLoginActivityItem('Yesterday, 8:15 PM', 'Desktop', 'Lahore, Pakistan'),
              _buildLoginActivityItem('2 days ago', 'Android Device', 'Islamabad, Pakistan'),
            ],
          ),
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

  Widget _buildLoginActivityItem(String time, String device, String location) {
    return ListTile(
      leading: Icon(Icons.devices, color: Theme.of(context).colorScheme.primary),
      title: Text(time, style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('$device • $location'),
      contentPadding: EdgeInsets.symmetric(vertical: 4),
    );
  }

  void _showBlockedUsers(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Blocked Users'),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: CircleAvatar(child: Text('A')),
                title: Text('Ahmad Khan'),
                trailing: TextButton(
                  onPressed: () {},
                  child: Text('Unblock', style: TextStyle(color: Colors.blue)),
                ),
              ),
              Text(
                'No blocked users',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
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

  void _showDownloadDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.download, color: Colors.blue),
            SizedBox(width: 12),
            Text('Download My Data'),
          ],
        ),
        content: Text(
          'We\'ll prepare a copy of your data and send you a download link via email within 48 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Data request submitted. Check your email.')),
              );
            },
            child: Text('Request'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Account?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This action cannot be undone. You will lose:'),
            SizedBox(height: 12),
            _buildDeleteWarning('All your bookings and history'),
            _buildDeleteWarning('Your profile and preferences'),
            _buildDeleteWarning('All messages and conversations'),
            _buildDeleteWarning('Saved payment methods'),
          ],
        ),
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
                  content: Text('Account deletion cancelled'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteWarning(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        children: [
          Icon(Icons.close, color: Colors.red, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
