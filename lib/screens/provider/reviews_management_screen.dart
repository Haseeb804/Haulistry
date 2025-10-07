import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class ReviewsManagementScreen extends StatefulWidget {
  const ReviewsManagementScreen({super.key});

  @override
  State<ReviewsManagementScreen> createState() => _ReviewsManagementScreenState();
}

class _ReviewsManagementScreenState extends State<ReviewsManagementScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', '5 Stars', '4 Stars', '3 Stars', '2 Stars', '1 Star', 'With Comments'];

  // Mock data
  final Map<String, dynamic> _stats = {
    'averageRating': 4.8,
    'totalReviews': 124,
    'fiveStars': 98,
    'fourStars': 18,
    'threeStars': 5,
    'twoStars': 2,
    'oneStars': 1,
  };

  final List<Map<String, dynamic>> _reviews = [
    {
      'id': 'R001',
      'clientName': 'Ahmed Khan',
      'clientImage': 'A',
      'rating': 5.0,
      'date': '2024-03-10',
      'serviceName': 'Premium Harvester',
      'bookingId': 'BK001',
      'comment': 'Excellent service! The harvester was in perfect condition and the operator was very professional. Completed the work much faster than expected.',
      'response': null,
      'helpful': 15,
    },
    {
      'id': 'R002',
      'clientName': 'Hassan Ali',
      'clientImage': 'H',
      'rating': 4.5,
      'date': '2024-03-08',
      'serviceName': 'Harvester Pro',
      'bookingId': 'BK002',
      'comment': 'Good service overall. Equipment was well-maintained. Would recommend to others.',
      'response': 'Thank you for your feedback! We appreciate your business.',
      'helpful': 8,
    },
    {
      'id': 'R003',
      'clientName': 'Fatima Noor',
      'clientImage': 'F',
      'rating': 5.0,
      'date': '2024-03-05',
      'serviceName': 'Premium Harvester',
      'bookingId': 'BK003',
      'comment': 'Outstanding experience! Professional, punctual, and efficient. The harvester performed excellently and saved us a lot of time.',
      'response': 'We\'re thrilled to hear you had a great experience! Thank you for choosing our service.',
      'helpful': 22,
    },
    {
      'id': 'R004',
      'clientName': 'Usman Tariq',
      'clientImage': 'U',
      'rating': 4.0,
      'date': '2024-03-03',
      'serviceName': 'Harvester Pro',
      'bookingId': 'BK004',
      'comment': 'Satisfied with the service. Minor delay in arrival but work quality was good.',
      'response': null,
      'helpful': 5,
    },
    {
      'id': 'R005',
      'clientName': 'Bilal Ahmed',
      'clientImage': 'B',
      'rating': 3.0,
      'date': '2024-03-01',
      'serviceName': 'Premium Harvester',
      'bookingId': 'BK005',
      'comment': 'Average experience. Service was okay but expected better performance.',
      'response': 'We apologize for not meeting your expectations. We\'d like to understand what went wrong. Please contact us.',
      'helpful': 3,
    },
  ];

  List<Map<String, dynamic>> get _filteredReviews {
    if (_selectedFilter == 'All') return _reviews;
    if (_selectedFilter == 'With Comments') {
      return _reviews.where((r) => r['comment'] != null && r['comment'].isNotEmpty).toList();
    }
    int stars = int.parse(_selectedFilter.split(' ')[0]);
    return _reviews.where((r) => r['rating'].floor() == stars).toList();
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
                            'Reviews',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.download, color: Colors.white),
                          onPressed: _downloadReviews,
                        ),
                      ],
                    ),
                  ),

                  // Overall Rating Card
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      _stats['averageRating'].toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < _stats['averageRating'].floor()
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.white,
                                          size: 20,
                                        );
                                      }),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${_stats['totalReviews']} Reviews',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildRatingBar(5, _stats['fiveStars'], _stats['totalReviews']),
                                    SizedBox(height: 8),
                                    _buildRatingBar(4, _stats['fourStars'], _stats['totalReviews']),
                                    SizedBox(height: 8),
                                    _buildRatingBar(3, _stats['threeStars'], _stats['totalReviews']),
                                    SizedBox(height: 8),
                                    _buildRatingBar(2, _stats['twoStars'], _stats['totalReviews']),
                                    SizedBox(height: 8),
                                    _buildRatingBar(1, _stats['oneStars'], _stats['totalReviews']),
                                  ],
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
          ),

          // Filter Chips
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_filters[index]),
                    selected: _selectedFilter == _filters[index],
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = _filters[index];
                      });
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedFilter == _filters[index]
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: _selectedFilter == _filters[index]
                          ? AppColors.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              },
            ),
          ),

          // Reviews List
          Expanded(
            child: _filteredReviews.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredReviews.length,
                    itemBuilder: (context, index) {
                      return _buildReviewCard(_filteredReviews[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    double percentage = (count / total) * 100;
    return Row(
      children: [
        Text(
          '$stars',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 4),
        Icon(Icons.star, color: Colors.white, size: 14),
        SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(
          '$count',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
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
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Info & Rating
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    review['clientImage'],
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
                        review['clientName'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < review['rating'].floor()
                                  ? Icons.star
                                  : (index < review['rating'] ? Icons.star_half : Icons.star_border),
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                          SizedBox(width: 8),
                          Text(
                            review['date'],
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag, size: 18),
                          SizedBox(width: 12),
                          Text('Report Review'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'report') {
                      _reportReview(review['id']);
                    }
                  },
                ),
              ],
            ),

            SizedBox(height: 12),

            // Service Info
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.agriculture, size: 14, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    review['serviceName'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '• ${review['bookingId']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            if (review['comment'] != null && review['comment'].isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                review['comment'],
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],

            // Response Section
            if (review['response'] != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.reply, size: 16, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Your Response',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      review['response'],
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 8),

            // Actions
            Row(
              children: [
                Icon(Icons.thumb_up_outlined, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text(
                  '${review['helpful']} found helpful',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Spacer(),
                if (review['response'] == null)
                  TextButton.icon(
                    onPressed: () => _respondToReview(review['id']),
                    icon: Icon(Icons.reply, size: 18),
                    label: Text('Respond'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => _editResponse(review['id'], review['response']),
                    icon: Icon(Icons.edit, size: 18),
                    label: Text('Edit Response'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: 24),
            Text(
              'No Reviews Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Reviews from your customers will appear here',
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

  void _respondToReview(String reviewId) {
    final responseController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Respond to Review',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: responseController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your response...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Response posted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Post Response',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editResponse(String reviewId, String currentResponse) {
    final responseController = TextEditingController(text: currentResponse);
    _respondToReview(reviewId); // Reuse the same UI
  }

  void _reportReview(String reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Review'),
        content: Text('Are you sure you want to report this review as inappropriate?'),
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
                  content: Text('Review reported successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Report', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _downloadReviews() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading reviews report...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

