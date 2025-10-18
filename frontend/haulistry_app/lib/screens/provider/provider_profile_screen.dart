import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  // Mock provider data
  final Map<String, dynamic> _providerData = {
    'name': 'Ali Traders',
    'email': 'ali.traders@example.com',
    'phone': '+92 300 1234567',
    'businessName': 'Ali Agricultural Services',
    'businessType': 'Sole Proprietorship',
    'registrationNumber': 'REG-2024-001',
    'address': 'Main Street, Faisalabad, Punjab',
    'joinedDate': 'January 2024',
    'verified': true,
  };

  final Map<String, dynamic> _stats = {
    'totalEarnings': 450000,
    'completedBookings': 87,
    'activeServices': 3,
    'rating': 4.8,
    'reviews': 124,
    'responseRate': 98,
    'responseTime': '< 1 hour',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header with Profile Info
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
              child: Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: () => context.push('/provider/edit-profile'),
                        ),
                        IconButton(
                          icon: Icon(Icons.settings, color: Colors.white),
                          onPressed: () => context.push('/provider/settings'),
                        ),
                      ],
                    ),
                  ),

                  // Profile Card
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      children: [
                        // Avatar & Name
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Text(
                                _providerData['name'][0],
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            if (_providerData['verified'])
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _providerData['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_providerData['verified']) ...[
                              SizedBox(width: 8),
                              Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          _providerData['businessName'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 20),
                            SizedBox(width: 4),
                            Text(
                              '${_stats['rating']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '(${_stats['reviews']} reviews)',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
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
                  // Stats Grid
                  _buildStatsGrid(),

                  SizedBox(height: 24),

                  // Business Information
                  _buildSectionTitle('Business Information'),
                  SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoTile(
                      Icons.business,
                      'Business Name',
                      _providerData['businessName'],
                    ),
                    Divider(height: 1),
                    _buildInfoTile(
                      Icons.category,
                      'Business Type',
                      _providerData['businessType'],
                    ),
                    Divider(height: 1),
                    _buildInfoTile(
                      Icons.numbers,
                      'Registration Number',
                      _providerData['registrationNumber'],
                    ),
                    Divider(height: 1),
                    _buildInfoTile(
                      Icons.location_on,
                      'Address',
                      _providerData['address'],
                    ),
                  ]),

                  SizedBox(height: 24),

                  // Contact Information
                  _buildSectionTitle('Contact Information'),
                  SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoTile(
                      Icons.email,
                      'Email',
                      _providerData['email'],
                    ),
                    Divider(height: 1),
                    _buildInfoTile(
                      Icons.phone,
                      'Phone',
                      _providerData['phone'],
                    ),
                  ]),

                  SizedBox(height: 24),

                  // Performance Metrics
                  _buildSectionTitle('Performance Metrics'),
                  SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoTile(
                      Icons.speed,
                      'Response Rate',
                      '${_stats['responseRate']}%',
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Excellent',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Divider(height: 1),
                    _buildInfoTile(
                      Icons.access_time,
                      'Response Time',
                      _stats['responseTime'],
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Fast',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ]),

                  SizedBox(height: 24),

                  // Action Buttons
                  _buildSectionTitle('Quick Actions'),
                  SizedBox(height: 12),
                  _buildActionButtons(),

                  SizedBox(height: 24),

                  // Account Settings
                  _buildSectionTitle('Account'),
                  SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuTile(
                      Icons.share,
                      'Share Profile',
                      () => _shareProfile(),
                    ),
                    Divider(height: 1),
                    _buildMenuTile(
                      Icons.help_outline,
                      'Help & Support',
                      () => context.push('/provider/support'),
                    ),
                    Divider(height: 1),
                    _buildMenuTile(
                      Icons.privacy_tip_outlined,
                      'Privacy Policy',
                      () => _showPrivacyPolicy(),
                    ),
                    Divider(height: 1),
                    _buildMenuTile(
                      Icons.description_outlined,
                      'Terms & Conditions',
                      () => _showTerms(),
                    ),
                  ]),

                  SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: Icon(Icons.logout, color: AppColors.error),
                      label: Text(
                        'Logout',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.error, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // Joined Date
                  Center(
                    child: Text(
                      'Member since ${_providerData['joinedDate']}',
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

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Earnings',
          'Rs ${_stats['totalEarnings']}',
          Icons.account_balance_wallet,
          AppColors.primary,
        ),
        _buildStatCard(
          'Completed',
          '${_stats['completedBookings']} Bookings',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Active Services',
          '${_stats['activeServices']} Services',
          Icons.agriculture,
          Colors.blue,
        ),
        _buildStatCard(
          'Rating',
          '${_stats['rating']}/5.0',
          Icons.star,
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
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

  Widget _buildInfoTile(IconData icon, String label, String value, {Widget? trailing}) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'View Services',
            Icons.agriculture,
            () => context.push('/provider/services'),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'View Reviews',
            Icons.star,
            () => context.push('/provider/reviews'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
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

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile link copied to clipboard'),
        backgroundColor: AppColors.primary,
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
        title: Text('Terms & Conditions'),
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

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Perform logout
              context.go('/role-selection');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

