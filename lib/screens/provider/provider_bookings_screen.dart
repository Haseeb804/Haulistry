import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data
  final List<Map<String, dynamic>> _upcomingBookings = [
    {
      'id': 'BK001',
      'clientName': 'Ahmed Khan',
      'clientImage': 'A',
      'serviceName': 'Premium Harvester',
      'date': '2024-03-15',
      'time': '08:00 AM',
      'duration': '4 hours',
      'location': 'Farm House, Faisalabad',
      'distance': '12 km',
      'amount': 10000,
      'status': 'confirmed',
      'paymentStatus': 'pending',
    },
    {
      'id': 'BK002',
      'clientName': 'Hassan Ali',
      'clientImage': 'H',
      'serviceName': 'Harvester Pro',
      'date': '2024-03-16',
      'time': '10:00 AM',
      'duration': '6 hours',
      'location': 'Green Valley Farm, Sahiwal',
      'distance': '8 km',
      'amount': 15000,
      'status': 'confirmed',
      'paymentStatus': 'paid',
    },
  ];

  final List<Map<String, dynamic>> _inProgressBookings = [
    {
      'id': 'BK003',
      'clientName': 'Fatima Noor',
      'clientImage': 'F',
      'serviceName': 'Premium Harvester',
      'date': '2024-03-14',
      'time': '09:00 AM',
      'duration': '8 hours',
      'location': 'Agricultural Land, Multan',
      'distance': '15 km',
      'amount': 20000,
      'status': 'in_progress',
      'startedAt': '09:15 AM',
      'progress': 60,
    },
  ];

  final List<Map<String, dynamic>> _completedBookings = [
    {
      'id': 'BK004',
      'clientName': 'Usman Tariq',
      'clientImage': 'U',
      'serviceName': 'Harvester Pro',
      'date': '2024-03-10',
      'time': '07:00 AM',
      'duration': '5 hours',
      'location': 'Wheat Fields, Lahore',
      'distance': '5 km',
      'amount': 12500,
      'status': 'completed',
      'completedAt': '12:00 PM',
      'rating': 5.0,
      'hasReview': true,
    },
    {
      'id': 'BK005',
      'clientName': 'Bilal Ahmed',
      'clientImage': 'B',
      'serviceName': 'Premium Harvester',
      'date': '2024-03-08',
      'time': '11:00 AM',
      'duration': '3 hours',
      'location': 'Farm Area, Gujranwala',
      'distance': '20 km',
      'amount': 7500,
      'status': 'completed',
      'completedAt': '02:30 PM',
      'rating': 4.0,
      'hasReview': true,
    },
  ];

  final List<Map<String, dynamic>> _cancelledBookings = [
    {
      'id': 'BK006',
      'clientName': 'Sara Ali',
      'clientImage': 'S',
      'serviceName': 'Harvester Pro',
      'date': '2024-03-05',
      'time': '08:00 AM',
      'duration': '4 hours',
      'location': 'Farm House, Sialkot',
      'distance': '18 km',
      'amount': 10000,
      'status': 'cancelled',
      'cancelledBy': 'client',
      'cancelReason': 'Weather conditions',
      'cancelledAt': '2024-03-04 10:00 PM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
              child: Column(
                children: [
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
                            'My Bookings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_month, color: Colors.white),
                          onPressed: _showCalendarView,
                        ),
                        IconButton(
                          icon: Icon(Icons.filter_list, color: Colors.white),
                          onPressed: _showFilterDialog,
                        ),
                      ],
                    ),
                  ),
                  // Tabs
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.6),
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    isScrollable: true,
                    tabs: [
                      Tab(text: 'Upcoming (${_upcomingBookings.length})'),
                      Tab(text: 'In Progress (${_inProgressBookings.length})'),
                      Tab(text: 'Completed (${_completedBookings.length})'),
                      Tab(text: 'Cancelled (${_cancelledBookings.length})'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingTab(),
                _buildInProgressTab(),
                _buildCompletedTab(),
                _buildCancelledTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    if (_upcomingBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_available,
        title: 'No Upcoming Bookings',
        message: 'You have no upcoming bookings scheduled',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 1));
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _upcomingBookings.length,
        itemBuilder: (context, index) {
          return _buildUpcomingBookingCard(_upcomingBookings[index]);
        },
      ),
    );
  }

  Widget _buildInProgressTab() {
    if (_inProgressBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.hourglass_empty,
        title: 'No Active Bookings',
        message: 'You have no bookings in progress',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _inProgressBookings.length,
      itemBuilder: (context, index) {
        return _buildInProgressBookingCard(_inProgressBookings[index]);
      },
    );
  }

  Widget _buildCompletedTab() {
    if (_completedBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'No Completed Bookings',
        message: 'Your completed bookings will appear here',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _completedBookings.length,
      itemBuilder: (context, index) {
        return _buildCompletedBookingCard(_completedBookings[index]);
      },
    );
  }

  Widget _buildCancelledTab() {
    if (_cancelledBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.cancel_outlined,
        title: 'No Cancelled Bookings',
        message: 'You have no cancelled bookings',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _cancelledBookings.length,
      itemBuilder: (context, index) {
        return _buildCancelledBookingCard(_cancelledBookings[index]);
      },
    );
  }

  Widget _buildUpcomingBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking['id']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: booking['paymentStatus'] == 'paid' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking['paymentStatus'] == 'paid' ? 'PAID' : 'PENDING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Client Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        booking['clientImage'],
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['clientName'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            booking['serviceName'],
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.phone, color: AppColors.primary),
                      onPressed: () => _callClient(booking['clientName']),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 12),

                // Booking Details
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text(
                      '${booking['date']} at ${booking['time']}',
                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text(
                      'Duration: ${booking['duration']}',
                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking['location'],
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 12),

                // Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Rs ${booking['amount']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.push('/provider/booking-detail/${booking['id']}'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _startBooking(booking['id']),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Start Job',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_filled, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'IN PROGRESS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Text(
                  'Started: ${booking['startedAt']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    booking['clientImage'],
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['clientName'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        booking['serviceName'],
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${booking['progress']}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: booking['progress'] / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/provider/booking-detail/${booking['id']}'),
                    icon: Icon(Icons.info_outline, size: 18),
                    label: Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _completeBooking(booking['id']),
                    icon: Icon(Icons.check_circle, size: 18, color: Colors.white),
                    label: Text('Complete', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'COMPLETED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              if (booking['hasReview'])
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      booking['rating'].toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  booking['clientImage'],
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['clientName'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${booking['serviceName']} • ${booking['date']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rs ${booking['amount']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/provider/booking-detail/${booking['id']}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('View Details'),
                ),
              ),
              if (booking['hasReview']) ...[
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewReview(booking['id']),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber.shade700,
                      side: BorderSide(color: Colors.amber.shade700),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('View Review'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'CANCELLED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Spacer(),
              Text(
                'By ${booking['cancelledBy']}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  booking['clientImage'],
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['clientName'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${booking['serviceName']} • ${booking['date']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.error),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reason: ${booking['cancelReason']}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCalendarView() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calendar view coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Bookings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('By Service'),
              leading: Icon(Icons.agriculture),
            ),
            ListTile(
              title: Text('By Date Range'),
              leading: Icon(Icons.calendar_today),
            ),
            ListTile(
              title: Text('By Amount'),
              leading: Icon(Icons.attach_money),
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
            child: Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _callClient(String clientName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $clientName...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _startBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start Job'),
        content: Text('Are you ready to start this job?'),
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
                  content: Text('Job started successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Start', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _completeBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Job'),
        content: Text('Mark this job as completed?'),
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
                  content: Text('Job completed successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Complete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewReview(String bookingId) {
    context.push('/provider/review-detail/$bookingId');
  }
}
