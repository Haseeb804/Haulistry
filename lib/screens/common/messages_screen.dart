import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock messages data - replace with actual data from provider
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'name': 'John Doe Farming',
      'lastMessage': 'Thank you for choosing our harvester service. We will be there on time.',
      'timestamp': '2 min ago',
      'unreadCount': 2,
      'avatar': null,
      'isOnline': true,
      'messageType': 'text',
      'bookingId': 'BK001',
      'serviceType': 'Harvester Service',
    },
    {
      'id': '2',
      'name': 'ABC Transport',
      'lastMessage': 'Your sand truck has been dispatched and will arrive in 30 minutes.',
      'timestamp': '1 hour ago',
      'unreadCount': 0,
      'avatar': null,
      'isOnline': false,
      'messageType': 'text',
      'bookingId': 'BK002',
      'serviceType': 'Sand Truck',
    },
    {
      'id': '3',
      'name': 'XYZ Construction',
      'lastMessage': 'Photo',
      'timestamp': '3 hours ago',
      'unreadCount': 1,
      'avatar': null,
      'isOnline': true,
      'messageType': 'image',
      'bookingId': 'BK003',
      'serviceType': 'Crane Service',
    },
    {
      'id': '4',
      'name': 'DEF Logistics',
      'lastMessage': 'The brick truck service has been completed successfully. Please rate us.',
      'timestamp': 'Yesterday',
      'unreadCount': 0,
      'avatar': null,
      'isOnline': false,
      'messageType': 'text',
      'bookingId': 'BK004',
      'serviceType': 'Brick Truck',
    },
    {
      'id': '5',
      'name': 'Farm Solutions',
      'lastMessage': 'Location shared',
      'timestamp': '2 days ago',
      'unreadCount': 0,
      'avatar': null,
      'isOnline': true,
      'messageType': 'location',
      'bookingId': 'BK005',
      'serviceType': 'Harvester Service',
    },
  ];

  List<Map<String, dynamic>> get _filteredMessages {
    if (_searchQuery.isEmpty) {
      return _messages;
    }
    return _messages.where((message) {
      return message['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
             message['lastMessage'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
             message['serviceType'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
                            'Messages',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () => _showMoreOptions(),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search messages...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: _filteredMessages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredMessages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageCard(_filteredMessages[index]);
                    },
                  ),
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
            _searchQuery.isEmpty ? Icons.chat_bubble_outline : Icons.search_off,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No Messages Yet' : 'No Results Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Your conversations with service providers\nwill appear here'
                : 'Try searching with different keywords',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> message) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => context.push('/chat/${message['id']}'),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: message['avatar'] != null
                  ? ClipOval(
                      child: Image.network(
                        message['avatar'],
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      message['name'][0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
            ),
            if (message['isOnline'])
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                message['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              message['timestamp'],
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              message['serviceType'],
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (message['messageType'] == 'image')
                        Icon(
                          Icons.image,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      if (message['messageType'] == 'location')
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      if (message['messageType'] == 'image' || message['messageType'] == 'location')
                        SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          message['lastMessage'],
                          style: TextStyle(
                            color: message['unreadCount'] > 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: message['unreadCount'] > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (message['unreadCount'] > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['unreadCount'].toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMessageAction(value, message),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'mark_read',
              child: Row(
                children: [
                  Icon(Icons.mark_chat_read, size: 20),
                  SizedBox(width: 8),
                  Text('Mark as Read'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
          child: Icon(
            Icons.more_vert,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.mark_chat_read, color: AppColors.primary),
              title: Text('Mark All as Read'),
              onTap: () {
                context.pop();
                _markAllAsRead();
              },
            ),
            ListTile(
              leading: Icon(Icons.archive, color: AppColors.primary),
              title: Text('Archived Chats'),
              onTap: () {
                context.pop();
                // Navigate to archived chats
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: AppColors.primary),
              title: Text('Chat Settings'),
              onTap: () {
                context.pop();
                // Navigate to chat settings
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleMessageAction(String action, Map<String, dynamic> message) {
    switch (action) {
      case 'mark_read':
        setState(() {
          message['unreadCount'] = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked as read'),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case 'delete':
        _showDeleteDialog(message);
        break;
    }
  }

  void _showDeleteDialog(Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Conversation'),
        content: Text('Are you sure you want to delete this conversation with ${message['name']}?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              setState(() {
                _messages.removeWhere((m) => m['id'] == message['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Conversation deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var message in _messages) {
        message['unreadCount'] = 0;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All messages marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
