import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/image_utils.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _hasLoadedData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedData) {
      _loadUserData();
      _hasLoadedData = true;
    }
  }

  void _loadUserData() {
    final authService = context.read<AuthService>();
    final userProfile = authService.userProfile;
    
    
    if (userProfile != null) {
      setState(() {
        _userData = userProfile;
        _isLoading = false;
      });
     
    } else {
      setState(() {
        _isLoading = false;
      });

    }
  }

  String _getMemberSince() {
    if (_userData?['createdAt'] != null) {
      try {
        final createdAt = DateTime.parse(_userData!['createdAt']);
        final months = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        return '${months[createdAt.month - 1]} ${createdAt.year}';
      } catch (e) {
        return 'Recently';
      }
    }
    return 'Recently';
  }

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
    // Listen to AuthService changes
    final authService = context.watch<AuthService>();
    
    // Auto-update when auth service changes
    if (_hasLoadedData && authService.userProfile != _userData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _userData = authService.userProfile;
          _isLoading = false;
        });
      });
    }
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (_userData == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Unable to load profile',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Please make sure you are logged in',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _hasLoadedData = false;
                      });
                      _loadUserData();
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: Icon(Icons.login),
                    label: Text('Login'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

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
                          icon: Icon(Icons.refresh, color: Colors.white),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await Future.delayed(Duration(milliseconds: 300));
                            _hasLoadedData = false;
                            _loadUserData();
                          },
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
                            Builder(
                              builder: (context) {
                                final imageBytes = ImageUtils.decodeBase64Image(_userData!['profileImage']);
                                return CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  backgroundImage: imageBytes != null
                                    ? MemoryImage(imageBytes)
                                    : null,
                                  child: imageBytes == null
                                    ? _buildInitialsAvatar()
                                    : null,
                                );
                              },
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => context.push('/seeker/edit-profile'),
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
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Name
                        Text(
                          _userData!['fullName'] ?? 'User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        // Email
                        Text(
                          _userData!['email'] ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),

                        SizedBox(height: 4),

                        // Member since
                        Text(
                          'Member since ${_getMemberSince()}',
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
                      (_userData!['completedBookings'] ?? 0).toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total\nSpent',
                      'Rs ${((_userData!['totalSpent'] ?? 0) / 1000).toStringAsFixed(0)}k',
                      Icons.account_balance_wallet,
                      Colors.orange,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Average\nRating',
                      (_userData!['avgRating'] ?? 0.0).toString(),
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

  Widget _buildInitialsAvatar() {
    final name = _userData!['fullName'] ?? 'User';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Text(
      initials,
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.white,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
            onPressed: () => context.pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close dialog first
              Navigator.of(context).pop();
              
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
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}