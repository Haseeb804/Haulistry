import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _upcomingBookings = [
    {
      'id': '1',
      'service': 'Harvester Service',
      'provider': 'John Doe Farming',
      'date': 'Oct 20, 2025',
      'time': '08:00 AM',
      'location': 'Lahore, Pakistan',
      'price': 10000,
      'status': 'confirmed',
      'icon': Icons.agriculture_rounded,
    },
    {
      'id': '2',
      'service': 'Sand Truck',
      'provider': 'ABC Transport',
      'date': 'Oct 22, 2025',
      'time': '10:00 AM',
      'location': 'Karachi, Pakistan',
      'price': 5000,
      'status': 'pending',
      'icon': Icons.local_shipping_rounded,
    },
  ];

  final List<Map<String, dynamic>> _inProgressBookings = [
    {
      'id': '3',
      'service': 'Crane Service',
      'provider': 'XYZ Construction',
      'date': 'Oct 1, 2025',
      'time': '09:00 AM',
      'location': 'Islamabad, Pakistan',
      'price': 15000,
      'status': 'in-progress',
      'icon': Icons.construction_rounded,
    },
  ];

  final List<Map<String, dynamic>> _completedBookings = [
    {
      'id': '4',
      'service': 'Harvester Service',
      'provider': 'John Doe Farming',
      'date': 'Sep 28, 2025',
      'time': '07:00 AM',
      'location': 'Lahore, Pakistan',
      'price': 10000,
      'status': 'completed',
      'icon': Icons.agriculture_rounded,
    },
    {
      'id': '5',
      'service': 'Brick Truck',
      'provider': 'DEF Logistics',
      'date': 'Sep 25, 2025',
      'time': '11:00 AM',
      'location': 'Faisalabad, Pakistan',
      'price': 8000,
      'status': 'completed',
      'icon': Icons.fire_truck_rounded,
    },
  ];

  final List<Map<String, dynamic>> _cancelledBookings = [
    {
      'id': '6',
      'service': 'Sand Truck',
      'provider': 'GHI Transport',
      'date': 'Sep 20, 2025',
      'time': '12:00 PM',
      'location': 'Multan, Pakistan',
      'price': 6000,
      'status': 'cancelled',
      'icon': Icons.local_shipping_rounded,
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
      body: Container(
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
          child: Column(
            children: [
              // Header
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
                      icon: Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                color: Colors.transparent,
                child: TabBar(
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
              ),

              SizedBox(height: 20),

              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookingsList(_upcomingBookings, 'upcoming'),
                      _buildBookingsList(_inProgressBookings, 'in-progress'),
                      _buildBookingsList(_completedBookings, 'completed'),
                      _buildBookingsList(_cancelledBookings, 'cancelled'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<Map<String, dynamic>> bookings, String type) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'No ${type.replaceAll('-', ' ')} bookings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your ${type.replaceAll('-', ' ')} bookings will appear here',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(bookings[index]);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    Color statusColor = _getStatusColor(booking['status']);
    String statusText = _getStatusText(booking['status']);

    return GestureDetector(
      onTap: () => context.push('/seeker/booking-detail/${booking['id']}'),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          booking['icon'],
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
                              booking['service'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              booking['provider'],
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        booking['date'],
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(width: 20),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        booking['time'],
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking['location'],
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),
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
                        'Rs ${booking['price']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildActionButtons(booking),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(Map<String, dynamic> booking) {
    String status = booking['status'];

    if (status == 'upcoming' || status == 'pending') {
      return [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _cancelBooking(booking['id']),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Cancel'),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.push('/seeker/booking-detail/${booking['id']}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('View Details'),
          ),
        ),
      ];
    } else if (status == 'in-progress') {
      return [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.location_on, size: 18),
            label: Text('Track Service'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        OutlinedButton(
          onPressed: () => context.push('/chat/${booking['id']}'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Icon(Icons.message),
        ),
      ];
    } else if (status == 'completed') {
      return [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Download Invoice'),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showReviewDialog(booking),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Rate Service'),
          ),
        ),
      ];
    } else { // cancelled
      return [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Book Again'),
          ),
        ),
      ];
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
      case 'upcoming':
        return AppColors.primary;
      case 'pending':
        return AppColors.secondary;
      case 'in-progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'in-progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  void _cancelBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking cancelled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {}); // Refresh the list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(Map<String, dynamic> booking) {
    double rating = 0;
    TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How was your experience with ${booking['service']}?'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() => rating = index + 1.0);
                  },
                );
              }),
            ),
            SizedBox(height: 16),
            TextField(
              controller: reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write your review...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thank you for your review!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
