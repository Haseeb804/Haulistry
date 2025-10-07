import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock user data - replace with actual data from provider
  final Map<String, dynamic> _userData = {
    'name': 'Muhammad Ahmad',
    'email': 'ahmad@example.com',
    'phone': '+92 300 1234567',
    'profileImage': null,
    'memberSince': 'January 2024',
    'completedBookings': 15,
    'totalSpent': 125000,
    'avgRating': 4.8,
    'location': 'Lahore, Pakistan',
  };

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.edit,
      'title': 'Edit Profile',
      'subtitle': 'Update your personal information',
      'route': '/seeker/edit-profile',
      'color': AppColors.primary,
    },
    {
      'icon': Icons.favorite,
      'title': 'My Favorites',
      'subtitle': 'View your favorite services',
      'route': '/seeker/favorites',
      'color': Colors.red,
    },
    {
      'icon': Icons.payment,
      'title': 'Payment Methods',
      'subtitle': 'Manage your payment options',
      'route': '/seeker/payment-methods',
      'color': Colors.green,
    },
    {
      'icon': Icons.location_on,
      'title': 'Saved Addresses',
      'subtitle': 'Manage your delivery addresses',
      'route': '/seeker/addresses',
      'color': Colors.orange,
    },
    {
      'icon': Icons.notifications,
      'title': 'Notifications',
      'subtitle': 'Manage notification preferences',
      'route': '/seeker/notifications',
      'color': Colors.purple,
    },
    {
      'icon': Icons.security,
      'title': 'Privacy & Security',
      'subtitle': 'Account security settings',
      'route': '/seeker/security',
      'color': Colors.indigo,
    },
    {
      'icon': Icons.help,
      'title': 'Help & Support',
      'subtitle': 'Get help and contact support',
      'route': '/seeker/help',
      'color': Colors.teal,
    },
    {
      'icon': Icons.info,
      'title': 'About',
      'subtitle': 'App version and information',
      'route': '/seeker/about',
      'color': Colors.grey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header with gradient
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
                  // Top bar
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
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.settings, color: Colors.white),
                          onPressed: () => context.push('/seeker/settings'),
                        ),
                      ],
                    ),
                  ),

                  // Profile Info
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
                    child: Column(
                      children: [
                        // Profile Picture
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: _userData['profileImage'] != null
                                  ? ClipOval(
                                      child: Image.network(
                                        _userData['profileImage'],
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Text(
                                      _userData['name'][0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Name
                        Text(
                          _userData['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        // Email
                        Text(
                          _userData['email'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),

                        SizedBox(height: 4),

                        // Member since
                        Text(
                          'Member since ${_userData['memberSince']}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats Cards
          Transform.translate(
            offset: Offset(0, -20),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Completed\nBookings',
                      _userData['completedBookings'].toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total\nSpent',
                      'Rs ${(_userData['totalSpent'] / 1000).toStringAsFixed(0)}k',
                      Icons.account_balance_wallet,
                      Colors.orange,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Average\nRating',
                      _userData['avgRating'].toString(),
                      Icons.star,
                      Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _menuItems.length + 1, // +1 for logout button
              itemBuilder: (context, index) {
                if (index == _menuItems.length) {
                  return _buildLogoutButton();
                }
                return _buildMenuItem(_menuItems[index]);
              },
            ),
          ),
        ],
      ),
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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        onTap: () => context.push(item['route']),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            item['icon'],
            color: item['color'],
            size: 24,
          ),
        ),
        title: Text(
          item['title'],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          item['subtitle'],
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
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
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
            onPressed: () {
              // Clear user data and navigate to login
              context.pop(); // Close dialog
              context.go('/login'); // Navigate to login
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}