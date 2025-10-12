import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isOnline = true;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  late AnimationController _typingAnimationController;
  AnimationController? _recordingAnimationController;

  // Mock chat data - replace with actual data from provider
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'senderId': 'provider_1',
      'senderName': 'John Doe Farming',
      'message': 'Hello! Thank you for booking our harvester service.',
      'timestamp': DateTime.now().subtract(Duration(hours: 2)),
      'type': 'text',
      'isRead': true,
    },
    {
      'id': '2',
      'senderId': 'seeker_1',
      'senderName': 'Muhammad Ahmad',
      'message': 'Hi, when will you arrive at the location?',
      'timestamp': DateTime.now().subtract(Duration(hours: 2, minutes: -5)),
      'type': 'text',
      'isRead': true,
    },
    {
      'id': '3',
      'senderId': 'provider_1',
      'senderName': 'John Doe Farming',
      'message': 'We will be there at 8:00 AM sharp. Our team is already on the way.',
      'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 45)),
      'type': 'text',
      'isRead': true,
    },
    {
      'id': '4',
      'senderId': 'provider_1',
      'senderName': 'John Doe Farming',
      'message': 'location',
      'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
      'type': 'location',
      'isRead': true,
      'locationData': {
        'latitude': 31.5497,
        'longitude': 74.3436,
        'address': 'Main Road, Lahore, Pakistan',
      },
    },
    {
      'id': '5',
      'senderId': 'seeker_1',
      'senderName': 'Muhammad Ahmad',
      'message': 'Perfect! Thank you for sharing the location.',
      'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 20)),
      'type': 'text',
      'isRead': true,
    },
    {
      'id': '6',
      'senderId': 'provider_1',
      'senderName': 'John Doe Farming',
      'message': 'image',
      'timestamp': DateTime.now().subtract(Duration(minutes: 30)),
      'type': 'image',
      'isRead': false,
      'imageUrl': 'https://via.placeholder.com/300x200',
    },
    {
      'id': '7',
      'senderId': 'provider_1',
      'senderName': 'John Doe Farming',
      'message': 'Here is our harvester ready for your field work!',
      'timestamp': DateTime.now().subtract(Duration(minutes: 29)),
      'type': 'text',
      'isRead': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    _recordingAnimationController?.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName.isNotEmpty ? widget.userName : 'User',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _isOnline ? 'Online' : 'Last seen 2 hours ago',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () => _makeCall(),
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: () => _makeVideoCall(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'view_profile', child: Text('View Profile')),
              PopupMenuItem(value: 'media', child: Text('Media & Files')),
              PopupMenuItem(value: 'clear_chat', child: Text('Clear Chat')),
              PopupMenuItem(value: 'block', child: Text('Block User')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),

          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isMe = message['senderId'] == 'seeker_1'; // Current user ID
    bool showAvatar = !isMe;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                message['senderName'] != null && message['senderName'].toString().isNotEmpty 
                    ? message['senderName'][0].toUpperCase() 
                    : 'U',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message['type'] == 'image')
                    _buildImageMessage(message)
                  else if (message['type'] == 'location')
                    _buildLocationMessage(message, isMe)
                  else if (message['type'] == 'voice')
                    _buildVoiceMessage(message, isMe)
                  else
                    _buildTextMessage(message, isMe),
                  
                  SizedBox(height: 4),
                  
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message['timestamp']),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey.shade600,
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: 4),
                        Icon(
                          message['isRead'] ? Icons.done_all : Icons.done,
                          size: 12,
                          color: message['isRead'] ? Colors.lightBlue : Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!showAvatar) SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> message, bool isMe) {
    return Text(
      message['message'],
      style: TextStyle(
        fontSize: 14,
        color: isMe ? Colors.white : AppColors.textPrimary,
        height: 1.4,
      ),
    );
  }

  Widget _buildImageMessage(Map<String, dynamic> message) {
    return GestureDetector(
      onTap: () => _viewImage(message['imageUrl']),
      child: Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            Icons.image,
            size: 50,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationMessage(Map<String, dynamic> message, bool isMe) {
    return GestureDetector(
      onTap: () => _openLocation(message['locationData']),
      child: Container(
        width: 200,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: isMe ? Colors.white : AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Location',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              message['locationData']['address'],
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.white.withOpacity(0.9) : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.map,
                  color: Colors.grey.shade600,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceMessage(Map<String, dynamic> message, bool isMe) {
    final duration = message['duration'] ?? 0;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              color: isMe ? Colors.white : AppColors.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 8),
          // Waveform visualization
          Row(
            children: List.generate(20, (index) {
              final heights = [3.0, 8.0, 5.0, 12.0, 7.0, 10.0, 6.0, 14.0, 4.0, 11.0, 
                              9.0, 6.0, 13.0, 5.0, 8.0, 7.0, 10.0, 6.0, 9.0, 5.0];
              return Container(
                width: 2,
                height: heights[index],
                margin: EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isMe ? Colors.white.withOpacity(0.7) : AppColors.primary.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          ),
          SizedBox(width: 8),
          Text(
            '${duration}s',
            style: TextStyle(
              fontSize: 12,
              color: isMe ? Colors.white.withOpacity(0.9) : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                SizedBox(width: 4),
                _buildTypingDot(1),
                SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedBuilder(
      animation: _typingAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + 0.3 * 
              (0.5 + 0.5 * 
                  math.sin((_typingAnimationController.value * 2 * math.pi) - (index * 0.5))),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    if (_isRecording) {
      return _buildRecordingUI();
    }
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: AppColors.primary),
            onPressed: () => _showAttachmentOptions(),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onChanged: (text) {
                  // Handle typing indicator
                },
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade200,
            child: IconButton(
              icon: Icon(
                Icons.mic,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: _recordVoiceMessage,
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'senderId': 'seeker_1',
      'senderName': 'Muhammad Ahmad',
      'message': _messageController.text.trim(),
      'timestamp': DateTime.now(),
      'type': 'text',
      'isRead': false,
    };

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    _scrollToBottom();
  }

  void _showAttachmentOptions() {
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
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentOption(Icons.photo_camera, 'Camera', () => _attachCamera()),
                  _buildAttachmentOption(Icons.photo_library, 'Gallery', () => _attachGallery()),
                  _buildAttachmentOption(Icons.location_on, 'Location', () => _attachLocation()),
                  _buildAttachmentOption(Icons.insert_drive_file, 'Document', () => _attachDocument()),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        context.pop();
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _makeCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling ${widget.userName}...')),
    );
  }

  void _makeVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting video call with ${widget.userName}...')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'view_profile':
        // Navigate to provider profile
        break;
      case 'media':
        // Show media and files
        break;
      case 'clear_chat':
        _clearChat();
        break;
      case 'block':
        _blockUser();
        break;
    }
  }

  void _viewImage(String imageUrl) {
    // Show full screen image viewer
  }

  void _openLocation(Map<String, dynamic> locationData) {
    // Open maps with location
  }

  void _attachCamera() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Camera attachment not implemented yet')),
    );
  }

  void _attachGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gallery attachment not implemented yet')),
    );
  }

  void _attachLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location sharing not implemented yet')),
    );
  }

  void _attachDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Document attachment not implemented yet')),
    );
  }

  void _recordVoiceMessage() {
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });
    
    // Start timer
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (_isRecording && mounted) {
        setState(() {
          _recordingSeconds++;
        });
        return true;
      }
      return false;
    });
    
    // In a real app, you would:
    // 1. Request microphone permission
    // 2. Start audio recording using a package like record, flutter_sound, or audio_recorder
    // 3. Save the audio file
  }
  
  void _cancelRecording() {
    setState(() {
      _isRecording = false;
      _recordingSeconds = 0;
    });
    // Stop and delete the recording
  }
  
  void _sendVoiceMessage() {
    if (!_isRecording) return;
    
    final duration = _recordingSeconds;
    
    setState(() {
      _isRecording = false;
      _recordingSeconds = 0;
    });
    
    // In a real app, save the recording and upload it
    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'senderId': 'seeker_1',
      'senderName': 'Muhammad Ahmad',
      'message': 'Voice message',
      'timestamp': DateTime.now(),
      'type': 'voice',
      'isRead': false,
      'duration': duration,
    };

    setState(() {
      _messages.add(newMessage);
    });

    _scrollToBottom();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice message sent (${duration}s)'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Widget _buildRecordingUI() {
    // Initialize controller if not already done
    _recordingAnimationController ??= AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel button
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: _cancelRecording,
          ),
          
          SizedBox(width: 8),
          
          // Recording animation
          AnimatedBuilder(
            animation: _recordingAnimationController!,
            builder: (context, child) {
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.5 + 0.5 * _recordingAnimationController!.value),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          
          SizedBox(width: 12),
          
          // Timer
          Text(
            _formatRecordingTime(_recordingSeconds),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          
          Spacer(),
          
          // Waveform animation (decorative)
          Row(
            children: List.generate(5, (index) {
              return AnimatedBuilder(
                animation: _recordingAnimationController!,
                builder: (context, child) {
                  final height = 4.0 + 20.0 * 
                    (0.5 + 0.5 * math.sin((_recordingAnimationController!.value * 2 * math.pi) - (index * 0.3)));
                  return Container(
                    width: 3,
                    height: height,
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              );
            }),
          ),
          
          Spacer(),
          
          // Send button
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.red,
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _sendVoiceMessage,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatRecordingTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat'),
        content: Text('Are you sure you want to clear this chat? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              setState(() {
                _messages.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chat cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _blockUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block User'),
        content: Text('Are you sure you want to block ${widget.userName}? You will no longer receive messages from this user.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              context.pop(); // Go back to messages list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.userName} has been blocked'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Block'),
          ),
        ],
      ),
    );
  }
}
