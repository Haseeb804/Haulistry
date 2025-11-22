import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/app_colors.dart';
import '../../utils/image_utils.dart';
import '../../services/auth_service.dart';
import '../../providers/service_provider.dart';
import '../../blocs/service/service_bloc.dart';
import '../../blocs/service/service_event.dart';
import '../../blocs/service/service_state.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // Load services using BLoC
    context.read<ServiceBloc>().add(LoadServicesRequested());
    
    // Keep Provider call for backward compatibility
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    await serviceProvider.loadServices();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userProfile = authService.userProfile;
    
    // 🐛 DEBUG: Print profile image data (only once when not loading)
    if (!_isLoading && userProfile != null) {
      if (userProfile['profileImage'] != null && userProfile['profileImage'] != '') {
      }
    }
    
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
                  // Top Bar
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Builder(
                          builder: (context) {
                            final imageBytes = ImageUtils.decodeBase64Image(userProfile?['profileImage']);
                            return CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              backgroundImage: imageBytes != null 
                                ? MemoryImage(imageBytes)
                                : null,
                              child: imageBytes == null
                                ? Text(
                                    (userProfile?['fullName'] ?? 'U')[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                            );
                          },
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                userProfile?['fullName'] ?? 'Provider',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.message_outlined, color: Colors.white),
                          onPressed: () => context.push('/messages'),
                        ),
                        IconButton(
                          icon: Icon(Icons.notifications, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Stats Cards Row
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Earnings',
                            'Rs 0',
                            Icons.account_balance_wallet,
                            Colors.green,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'This Month',
                            'Rs 0',
                            Icons.trending_up,
                            Colors.blue,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Pending',
                            '0',
                            Icons.pending,
                            Colors.orange,
                          ),
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
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    _buildQuickActions(),

                    SizedBox(height: 24),

                    // Performance Overview
                    _buildPerformanceOverview(),

                    // My Services - Only show if there are services
                    if (Provider.of<ServiceProvider>(context).services.isNotEmpty) ...[
                      SizedBox(height: 24),
                      _buildSectionHeader('My Services', '/provider/services'),
                      SizedBox(height: 12),
                      _buildMyServices(),
                    ],

                    SizedBox(height: 24),

                    // Recent Bookings
                    _buildSectionHeader('Recent Bookings', '/provider/bookings'),

                    SizedBox(height: 12),

                    _buildRecentBookings(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'title': 'Bookings', 'icon': Icons.calendar_today, 'color': Color(0xFF3B82F6), 'route': '/provider/bookings'},
      {'title': 'Add Service', 'icon': Icons.add_circle, 'color': AppColors.primary, 'route': '/provider/add-service'},
      {'title': 'Earnings', 'icon': Icons.account_balance_wallet, 'color': Color(0xFF10B981), 'route': '/provider/earnings'},
      {'title': 'Reviews', 'icon': Icons.star, 'color': Color(0xFFF59E0B), 'route': '/provider/reviews'},
      {'title': 'Messages', 'icon': Icons.message, 'color': Color(0xFFEF4444), 'route': '/messages'},
      {'title': 'Statistics', 'icon': Icons.bar_chart, 'color': Color(0xFF8B5CF6), 'route': '/provider/statistics'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(
              action['title'] as String,
              action['icon'] as IconData,
              action['color'] as Color,
              () => context.push(action['route'] as String),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userProfile = authService.userProfile;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildPerformanceItem(
                'Overall Rating',
                '${userProfile?['rating']?.toStringAsFixed(1) ?? '0.0'}',
                Icons.star,
                Color(0xFFF59E0B),
                '0 reviews',
              ),
              Divider(height: 32),
              _buildPerformanceItem(
                'Completed Bookings',
                '${userProfile?['totalBookings'] ?? 0}',
                Icons.check_circle,
                Color(0xFF10B981),
                'All time',
              ),
              Divider(height: 32),
              _buildPerformanceItem(
                'Verification Status',
                userProfile?['documentsUploaded'] == true ? 'Pending' : 'Not Verified',
                Icons.verified_user,
                userProfile?['documentsUploaded'] == true ? Color(0xFFF59E0B) : Colors.grey,
                userProfile?['documentsUploaded'] == true ? 'Under review' : 'Upload documents',
              ),
              Divider(height: 32),
              _buildPerformanceItem(
                'Account Status',
                userProfile?['isVerified'] == true ? 'Verified' : 'Unverified',
                Icons.check_circle_outline,
                userProfile?['isVerified'] == true ? Color(0xFF10B981) : Colors.grey,
                'Provider account',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(String title, String value, IconData icon, Color color, String subtitle) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton.icon(
          onPressed: () => context.push(route),
          icon: Text(
            'View All',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          label: Icon(Icons.arrow_forward_ios, size: 14),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMyServices() {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final services = serviceProvider.services;
    
    if (services.isEmpty) {
      return SizedBox.shrink(); // Return empty widget if no services
    }
    
    return Column(
      children: services.take(3).map((service) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Navigate to service details
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.15),
                            AppColors.primary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.construction,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.serviceName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
                              SizedBox(width: 4),
                              Text(
                                '${service.rating?.toStringAsFixed(1) ?? '0.0'}',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.textSecondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${service.totalBookings} bookings',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs ${service.pricePerHour?.toStringAsFixed(0) ?? '0'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '/hour',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: service.isActive
                                ? Color(0xFF10B981).withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            service.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: service.isActive ? Color(0xFF10B981) : Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentBookings() {
    // For now, show empty state since we don't have bookings yet
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: Color(0xFF3B82F6),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No Bookings Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your booking requests will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOldRecentBookings() {
    return Column(
      children: [].map((booking) {
        Color statusColor = _getStatusColor(booking['status']);
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking['id'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking['status'].toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                booking['service'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text(
                    booking['client'],
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text(
                    booking['location'],
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text(
                    booking['date'],
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text(
                    booking['time'],
                    style: TextStyle(fontSize: 14),
                  ),
                  Spacer(),
                  Text(
                    'Rs ${booking['amount']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              context.push('/provider/services');
              break;
            case 2:
              context.push('/provider/bookings');
              break;
            case 3:
              context.push('/messages');
              break;
            case 4:
              context.push('/provider/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

