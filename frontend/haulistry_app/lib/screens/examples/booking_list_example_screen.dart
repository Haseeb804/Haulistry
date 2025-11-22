import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/booking/booking_bloc.dart';
import '../../blocs/booking/booking_event.dart';
import '../../blocs/booking/booking_state.dart';
import '../../models/booking_model.dart';
import '../../utils/app_colors.dart';

/// Example screen showing complete BLoC integration for bookings
/// This can be used as a template for other screens
class BookingListExampleScreen extends StatefulWidget {
  const BookingListExampleScreen({super.key});

  @override
  State<BookingListExampleScreen> createState() => _BookingListExampleScreenState();
}

class _BookingListExampleScreenState extends State<BookingListExampleScreen> {
  String _filterType = 'all'; // all, pending, accepted, completed

  @override
  void initState() {
    super.initState();
    // Load bookings when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  void _loadBookings() {
    context.read<BookingBloc>().add(FetchBookingsRequested());
  }

  List<BookingModel> _filterBookings(List<BookingModel> bookings) {
    if (_filterType == 'all') return bookings;
    return bookings.where((b) => b.status == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        // Listener for side effects (snackbars, navigation)
        listener: (context, state) {
          if (state is BookingCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Booking created successfully!'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'View',
                  textColor: Colors.white,
                  onPressed: () {
                    context.push('/booking-details/${state.booking.id}');
                  },
                ),
              ),
            );
            _loadBookings(); // Reload list
          } else if (state is BookingUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking status updated'),
                backgroundColor: Colors.green,
              ),
            );
            _loadBookings(); // Reload list
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        // Builder for UI updates
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is BookingListLoaded) {
            final filteredBookings = _filterBookings(state.bookings);

            if (filteredBookings.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadBookings();
                // Wait for state to update
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  return _buildBookingCard(filteredBookings[index]);
                },
              ),
            );
          }

          if (state is BookingError) {
            return _buildErrorState(state.message);
          }

          // Initial state - show empty or loading
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/create-booking');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Booking'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          context.push('/booking-details/${booking.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.serviceName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              const SizedBox(height: 8),
              
              // Provider info
              Text(
                booking.providerName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              
              // Details
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDate(booking.date)} • ${booking.startTime}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.location,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Price and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PKR ${booking.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (booking.status == 'pending')
                    ElevatedButton(
                      onPressed: () => _cancelBooking(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Cancel'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'accepted':
        color = Colors.blue;
        label = 'Accepted';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filterType == 'all' 
              ? 'Create your first booking'
              : 'No $_filterType bookings',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/service-listing');
            },
            icon: const Icon(Icons.search),
            label: const Text('Browse Services'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading bookings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadBookings,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Dispatch cancel event
              context.read<BookingBloc>().add(
                UpdateBookingStatusRequested(
                  bookingId: booking.id,
                  status: 'cancelled',
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Bookings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('All'),
              value: 'all',
              groupValue: _filterType,
              onChanged: (value) {
                setState(() => _filterType = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Pending'),
              value: 'pending',
              groupValue: _filterType,
              onChanged: (value) {
                setState(() => _filterType = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Accepted'),
              value: 'accepted',
              groupValue: _filterType,
              onChanged: (value) {
                setState(() => _filterType = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Completed'),
              value: 'completed',
              groupValue: _filterType,
              onChanged: (value) {
                setState(() => _filterType = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
