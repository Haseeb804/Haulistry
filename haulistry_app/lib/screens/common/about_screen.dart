import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('About'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // App Logo and Name
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Haulistry',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Version 1.0.0 (Build 100)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Latest Version',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 32),
          
          // Description
          Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary),
                      SizedBox(width: 12),
                      Text(
                        'About Haulistry',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Haulistry is Pakistan\'s premier platform connecting service seekers with reliable providers for agriculture, construction, logistics, and emergency services.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Features
          Card(
            child: Column(
              children: [
                _buildInfoTile(
                  context,
                  'Total Users',
                  '50,000+',
                  Icons.people,
                  Colors.blue,
                ),
                Divider(height: 1),
                _buildInfoTile(
                  context,
                  'Active Providers',
                  '10,000+',
                  Icons.business,
                  Colors.green,
                ),
                Divider(height: 1),
                _buildInfoTile(
                  context,
                  'Bookings Completed',
                  '100,000+',
                  Icons.check_circle,
                  Colors.orange,
                ),
                Divider(height: 1),
                _buildInfoTile(
                  context,
                  'Cities Covered',
                  '50+',
                  Icons.location_city,
                  Colors.purple,
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Links
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.language, color: Colors.blue),
                  ),
                  title: Text('Website'),
                  subtitle: Text('www.haulistry.com'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _openLink(context, 'Website'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.email, color: Colors.red),
                  ),
                  title: Text('Contact Us'),
                  subtitle: Text('support@haulistry.com'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _openLink(context, 'Email'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.phone, color: Colors.green),
                  ),
                  title: Text('Helpline'),
                  subtitle: Text('+92 300 1234567'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _openLink(context, 'Phone'),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Legal
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.description, color: Colors.blue),
                  title: Text('Terms of Service'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showDocument(context, 'Terms of Service'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.privacy_tip, color: Colors.orange),
                  title: Text('Privacy Policy'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showDocument(context, 'Privacy Policy'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.gavel, color: Colors.purple),
                  title: Text('Licenses'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLicenses(context),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Social Media
          Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Follow Us',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSocialButton(context, Icons.facebook, Colors.blue[800]!),
                      _buildSocialButton(context, Icons.camera_alt, Colors.pink),
                      _buildSocialButton(context, Icons.send, Colors.blue),
                      _buildSocialButton(context, Icons.link, Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Credits
          Center(
            child: Column(
              children: [
                Text(
                  'Made with ❤️ in Pakistan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '© 2025 Haulistry. All rights reserved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context, IconData icon, Color color) {
    return InkWell(
      onTap: () => _openSocialMedia(context, icon),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  void _openLink(BuildContext context, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening $type...')),
    );
  }

  void _openSocialMedia(BuildContext context, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening social media...')),
    );
  }

  void _showDocument(BuildContext context, String title) {
    if (title == 'Terms of Service') {
      context.push('/terms-of-service');
    } else if (title == 'Privacy Policy') {
      context.push('/privacy-policy');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: SingleChildScrollView(
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.\n\n'
                'Duis aute irure dolor in reprehenderit in voluptate velit esse '
                'cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat '
                'cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n'
                'This is a sample document. The actual content will be loaded from the server.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
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
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Haulistry',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(Icons.local_shipping, color: Colors.white, size: 30),
      ),
    );
  }
}
