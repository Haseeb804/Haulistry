import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class ServicesManagementScreen extends StatefulWidget {
  const ServicesManagementScreen({super.key});

  @override
  State<ServicesManagementScreen> createState() => _ServicesManagementScreenState();
}

class _ServicesManagementScreenState extends State<ServicesManagementScreen> {
  String _selectedFilter = 'all';
  
  // Mock services data
  List<Map<String, dynamic>> _services = [
    {
      'id': '1',
      'name': 'Premium Harvester Service',
      'description': 'High-end harvester with GPS and auto-guidance system',
      'price': 2500,
      'category': 'harvester',
      'status': 'active',
      'bookings': 45,
      'revenue': 112500,
      'rating': 4.9,
      'reviews': 38,
      'availability': true,
      'image': null,
      'specifications': {
        'Model': 'John Deere S770',
        'Year': '2023',
        'Capacity': '500 acres/day',
      },
    },
    {
      'id': '2',
      'name': 'Standard Harvester',
      'description': 'Reliable harvester for medium-sized farms',
      'price': 2000,
      'category': 'harvester',
      'status': 'active',
      'bookings': 32,
      'revenue': 64000,
      'rating': 4.7,
      'reviews': 28,
      'availability': true,
      'image': null,
      'specifications': {
        'Model': 'Massey Ferguson',
        'Year': '2022',
        'Capacity': '350 acres/day',
      },
    },
    {
      'id': '3',
      'name': 'Mini Harvester',
      'description': 'Compact harvester for small fields',
      'price': 1500,
      'category': 'harvester',
      'status': 'inactive',
      'bookings': 10,
      'revenue': 15000,
      'rating': 4.5,
      'reviews': 8,
      'availability': false,
      'image': null,
      'specifications': {
        'Model': 'Kubota DC-70',
        'Year': '2021',
        'Capacity': '200 acres/day',
      },
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    switch (_selectedFilter) {
      case 'active':
        return _services.where((s) => s['status'] == 'active').toList();
      case 'inactive':
        return _services.where((s) => s['status'] == 'inactive').toList();
      case 'high_rated':
        return _services.where((s) => s['rating'] >= 4.8).toList();
      default:
        return _services;
    }
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
                  // Top Bar
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
                            'My Services',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search, color: Colors.white),
                          onPressed: () => _showSearchDialog(),
                        ),
                      ],
                    ),
                  ),

                  // Filter Chips
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', 'all'),
                          SizedBox(width: 8),
                          _buildFilterChip('Active', 'active'),
                          SizedBox(width: 8),
                          _buildFilterChip('Inactive', 'inactive'),
                          SizedBox(width: 8),
                          _buildFilterChip('High Rated', 'high_rated'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _filteredServices.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      return _buildServiceCard(_filteredServices[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/provider/add-service'),
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Service',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
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
            Icons.business_center_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No Services Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first service to\nstart receiving bookings',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/provider/add-service'),
            icon: Icon(Icons.add),
            label: Text('Add Service'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
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
          // Service Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.agriculture_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: service['status'] == 'active'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              service['status'] == 'active' ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: service['status'] == 'active' ? Colors.green : Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        service['description'],
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Stats Row
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.star,
                    '${service['rating']}',
                    '${service['reviews']} reviews',
                    Colors.amber,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                Expanded(
                  child: _buildStatItem(
                    Icons.bookmark,
                    '${service['bookings']}',
                    'Bookings',
                    Colors.blue,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                Expanded(
                  child: _buildStatItem(
                    Icons.account_balance_wallet,
                    'Rs ${(service['revenue'] / 1000).toStringAsFixed(0)}k',
                    'Revenue',
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Actions Row
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleServiceStatus(service),
                    icon: Icon(
                      service['availability'] ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                    ),
                    label: Text(service['availability'] ? 'Hide' : 'Show'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/provider/edit-service/${service['id']}'),
                    icon: Icon(Icons.edit, size: 18),
                    label: Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewServiceDetails(service),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'View',
                      style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Services'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Enter service name...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            // Implement search functionality
          },
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  void _toggleServiceStatus(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service['availability'] ? 'Hide Service' : 'Show Service'),
        content: Text(
          service['availability']
              ? 'This service will be hidden from customers. You can show it again anytime.'
              : 'This service will be visible to customers and they can book it.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                service['availability'] = !service['availability'];
              });
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    service['availability']
                        ? 'Service is now visible'
                        : 'Service is now hidden',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(service['availability'] ? 'Hide' : 'Show'),
          ),
        ],
      ),
    );
  }

  void _viewServiceDetails(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      service['name'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),

            Divider(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      service['description'],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 20),

                    Text(
                      'Specifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...service['specifications'].entries.map((entry) {
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

                    SizedBox(height: 20),

                    Text(
                      'Pricing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Rs ${service['price']} per hour',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                    SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.pop();
                              _deleteService(service);
                            },
                            icon: Icon(Icons.delete, color: AppColors.error),
                            label: Text('Delete', style: TextStyle(color: AppColors.error)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.error),
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
                            onPressed: () {
                              context.pop();
                              context.push('/provider/edit-service/${service['id']}');
                            },
                            icon: Icon(Icons.edit),
                            label: Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(vertical: 16),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteService(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _services.removeWhere((s) => s['id'] == service['id']);
              });
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Service deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
