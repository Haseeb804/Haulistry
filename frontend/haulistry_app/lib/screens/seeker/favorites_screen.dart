import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isGridView = true;

  // Mock favorites data - replace with actual data from provider
  final List<Map<String, dynamic>> _favorites = [
    {
      'id': '1',
      'name': 'Premium Harvester Service',
      'provider': 'John Doe Farming',
      'location': 'Lahore, Pakistan',
      'price': 2500,
      'rating': 4.8,
      'reviews': 124,
      'image': 'harvester',
      'available': true,
      'serviceType': 'harvester',
      'addedDate': '2 days ago',
    },
    {
      'id': '2',
      'name': 'Heavy Duty Sand Truck',
      'provider': 'ABC Transport',
      'location': 'Karachi, Pakistan',
      'price': 1800,
      'rating': 4.6,
      'reviews': 89,
      'image': 'sand_truck',
      'available': true,
      'serviceType': 'sand_truck',
      'addedDate': '1 week ago',
    },
    {
      'id': '3',
      'name': 'Brick Transportation',
      'provider': 'DEF Logistics',
      'location': 'Faisalabad, Pakistan',
      'price': 2200,
      'rating': 4.7,
      'reviews': 156,
      'image': 'brick_truck',
      'available': false,
      'serviceType': 'brick_truck',
      'addedDate': '3 days ago',
    },
    {
      'id': '4',
      'name': 'Mobile Crane Service',
      'provider': 'XYZ Construction',
      'location': 'Islamabad, Pakistan',
      'price': 3500,
      'rating': 4.9,
      'reviews': 78,
      'image': 'crane',
      'available': true,
      'serviceType': 'crane',
      'addedDate': '1 day ago',
    },
    {
      'id': '5',
      'name': 'Agricultural Harvester',
      'provider': 'Farm Solutions',
      'location': 'Multan, Pakistan',
      'price': 2800,
      'rating': 4.5,
      'reviews': 92,
      'image': 'harvester',
      'available': true,
      'serviceType': 'harvester',
      'addedDate': '5 days ago',
    },
  ];

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
                        'My Favorites',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isGridView ? Icons.list : Icons.grid_view,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Favorites count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_favorites.length} Favorite Services',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Spacer(),
                TextButton.icon(
                  onPressed: _showClearFavoritesDialog,
                  icon: Icon(
                    Icons.clear_all,
                    size: 18,
                    color: AppColors.error,
                  ),
                  label: Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // Content
          Expanded(
            child: _favorites.isEmpty
                ? _buildEmptyState()
                : _isGridView
                    ? _buildGridView()
                    : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start adding services to your favorites\nto see them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/seeker/service-listing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Browse Services',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        return _buildGridCard(_favorites[index]);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        return _buildListCard(_favorites[index]);
      },
    );
  }

  Widget _buildGridCard(Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () => context.push('/seeker/service-detail/${service['id']}'),
      child: Container(
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
            // Image and favorite button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: _getServiceColor(service['serviceType']).withOpacity(0.1),
                    child: Icon(
                      _getServiceIcon(service['serviceType']),
                      size: 50,
                      color: _getServiceColor(service['serviceType']),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeFromFavorites(service['id']),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                if (!service['available'])
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Unavailable',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      service['provider'],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          service['rating'].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          ' (${service['reviews']})',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Text(
                      'Rs ${service['price']}/hr',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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

  Widget _buildListCard(Map<String, dynamic> service) {
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
      child: Row(
        children: [
          // Service Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getServiceColor(service['serviceType']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getServiceIcon(service['serviceType']),
              size: 40,
              color: _getServiceColor(service['serviceType']),
            ),
          ),

          SizedBox(width: 16),

          // Service Info
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeFromFavorites(service['id']),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  service['provider'],
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        service['location'],
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          service['rating'].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          ' (${service['reviews']})',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Text(
                      'Rs ${service['price']}/hr',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: service['available'] 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service['available'] ? 'Available' : 'Unavailable',
                        style: TextStyle(
                          color: service['available'] ? Colors.green : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Added ${service['addedDate']}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
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

  Color _getServiceColor(String serviceType) {
    switch (serviceType) {
      case 'harvester':
        return Colors.orange;
      case 'sand_truck':
        return Colors.purple;
      case 'brick_truck':
        return Colors.pink;
      case 'crane':
        return Colors.cyan;
      default:
        return AppColors.primary;
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'harvester':
        return Icons.agriculture_rounded;
      case 'sand_truck':
        return Icons.local_shipping_rounded;
      case 'brick_truck':
        return Icons.fire_truck_rounded;
      case 'crane':
        return Icons.construction_rounded;
      default:
        return Icons.build;
    }
  }

  void _removeFromFavorites(String serviceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove from Favorites'),
        content: Text('Are you sure you want to remove this service from your favorites?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              setState(() {
                _favorites.removeWhere((service) => service['id'] == serviceId);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed from favorites'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showClearFavoritesDialog() {
    if (_favorites.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Favorites'),
        content: Text('Are you sure you want to remove all services from your favorites? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              setState(() {
                _favorites.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All favorites cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }
}