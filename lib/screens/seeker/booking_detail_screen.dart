
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  // Mock booking data - replace with actual data from provider
  final Map<String, dynamic> _bookingData = {
    'id': '1',
    'service': 'Harvester Service',
    'provider': 'John Doe Farming',
    'providerPhone': '+92 300 1234567',
    'providerEmail': 'john@farming.com',
    'providerRating': 4.8,
    'date': 'October 20, 2025',
    'time': '08:00 AM',
    'duration': '4 hours',
    'location': 'Farm House, Main Road, Lahore, Pakistan',
    'status': 'confirmed', // pending, confirmed, in-progress, completed, cancelled
    'totalPrice': 10000,
    'paymentMethod': 'Cash',
    'bookingDate': 'October 1, 2025',
    'notes': 'Please bring your own fuel. The field is approximately 5 acres.',
    'serviceImage': 'https://via.placeholder.com/400x200',
    'specifications': {
      'Service Type': 'Harvester',
      'Equipment Model': 'John Deere S770',
      'Capacity': '500 acres/day',
      'Year': '2023',
    },
  };

  final List<Map<String, dynamic>> _timeline = [
    {
      'title': 'Booking Placed',
      'description': 'Your booking has been placed successfully',
      'time': 'Oct 1, 2025 - 10:30 AM',
      'status': 'completed',
    },
    {
      'title': 'Booking Confirmed',
      'description': 'Provider has confirmed your booking',
      'time': 'Oct 1, 2025 - 11:15 AM',
      'status': 'completed',
    },
    {
      'title': 'Service Scheduled',
      'description': 'Service is scheduled for Oct 20, 2025',
      'time': 'Oct 1, 2025 - 11:15 AM',
      'status': 'completed',
    },
    {
      'title': 'Service In Progress',
      'description': 'Service will start at scheduled time',
      'time': 'Oct 20, 2025 - 08:00 AM',
      'status': 'pending',
    },
    {
      'title': 'Service Completed',
      'description': 'Service will be marked as completed',
      'time': 'Pending',
      'status': 'pending',
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
                        'Booking Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.help_outline, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  _buildStatusCard(),

                  SizedBox(height: 16),

                  // Service Details
                  _buildServiceDetails(),

                  SizedBox(height: 16),

                  // Booking Information
                  _buildBookingInformation(),

                  SizedBox(height: 16),

                  // Timeline
                  _buildTimeline(),

                  SizedBox(height: 16),

                  // Provider Information
                  _buildProviderInfo(),

                  SizedBox(height: 16),

                  // Payment Details
                  _buildPaymentDetails(),

                  SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor = _getStatusColor(_bookingData['status']);
    String statusText = _getStatusText(_bookingData['status']);
    IconData statusIcon = _getStatusIcon(_bookingData['status']);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusIcon,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _getStatusDescription(_bookingData['status']),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetails() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
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
          // Service Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Container(
              height: 180,
              width: double.infinity,
              color: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.agriculture_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _bookingData['service'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Booking ID: #${_bookingData['id']}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 16),
                Text(
                  'Specifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                ..._bookingData['specifications'].entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          entry.value,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInformation() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
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
          Text(
            'Booking Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            Icons.calendar_today,
            'Date',
            _bookingData['date'],
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time,
            'Time',
            _bookingData['time'],
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            Icons.timer,
            'Duration',
            _bookingData['duration'],
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on,
            'Location',
            _bookingData['location'],
          ),
          if (_bookingData['notes'] != null && _bookingData['notes'].isNotEmpty) ...[
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Additional Notes',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _bookingData['notes'],
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
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
          Text(
            'Booking Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          ...List.generate(_timeline.length, (index) {
            return _buildTimelineItem(
              _timeline[index],
              isLast: index == _timeline.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item, {bool isLast = false}) {
    bool isCompleted = item['status'] == 'completed';
    Color color = isCompleted ? Colors.green : AppColors.textSecondary.withOpacity(0.3);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                color: isCompleted ? Colors.white : AppColors.textSecondary,
                size: isCompleted ? 20 : 12,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: color,
              ),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  item['description'],
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  item['time'],
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
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
          Text(
            'Provider Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  _bookingData['provider'][0],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _bookingData['provider'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4),
                        Text(
                          _bookingData['providerRating'].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
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
          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.phone, size: 20),
                  label: Text('Call'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/chat/${widget.bookingId}'),
                  icon: Icon(Icons.message, size: 20),
                  label: Text('Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
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
          Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                _bookingData['paymentMethod'],
                style: TextStyle(fontWeight: FontWeight.w600),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rs ${_bookingData['totalPrice']}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomActions() {
    String status = _bookingData['status'];

    if (status == 'pending') {
      return Container(
        padding: EdgeInsets.all(16),
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _cancelBooking(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel Booking',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (status == 'confirmed') {
      return Container(
        padding: EdgeInsets.all(16),
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _cancelBooking(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Cancel'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _rescheduleBooking(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Reschedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (status == 'in-progress') {
      return Container(
        padding: EdgeInsets.all(16),
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
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.location_on),
          label: Text(
            'Track Service',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    } else if (status == 'completed') {
      return Container(
        padding: EdgeInsets.all(16),
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.download, size: 20),
                label: Text('Invoice'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showReviewDialog(),
                icon: Icon(Icons.star, size: 20),
                label: Text('Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return null; // No actions for cancelled bookings
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
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
        return 'Booking Confirmed';
      case 'pending':
        return 'Pending Confirmation';
      case 'in-progress':
        return 'Service In Progress';
      case 'completed':
        return 'Service Completed';
      case 'cancelled':
        return 'Booking Cancelled';
      default:
        return status;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'confirmed':
        return 'Your booking has been confirmed by the provider';
      case 'pending':
        return 'Waiting for provider confirmation';
      case 'in-progress':
        return 'Service is currently being provided';
      case 'completed':
        return 'Service has been successfully completed';
      case 'cancelled':
        return 'This booking has been cancelled';
      default:
        return '';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'in-progress':
        return Icons.sync;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _cancelBooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel this booking?'),
            SizedBox(height: 16),
            Text(
              'Note: Cancellation charges may apply based on the cancellation policy.',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              context.pop(); // Go back to bookings list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking cancelled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
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

  void _rescheduleBooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reschedule Booking'),
        content: Text('Would you like to reschedule this booking?'),
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
                  content: Text('Redirecting to reschedule page...'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Reschedule'),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog() {
    double rating = 0;
    TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Rate Your Experience'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How was your experience with ${_bookingData['service']}?'),
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
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: rating > 0
                  ? () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Thank you for your review!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
