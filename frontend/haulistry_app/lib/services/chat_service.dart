import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/message_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  // Stream controllers for real-time updates
  final _messagesController = StreamController<List<Message>>.broadcast();
  final _chatRoomsController = StreamController<List<ChatRoom>>.broadcast();
  final _typingController = StreamController<TypingIndicator>.broadcast();
  final _readReceiptController = StreamController<ReadReceipt>.broadcast();

  Stream<List<Message>> get messagesStream => _messagesController.stream;
  Stream<List<ChatRoom>> get chatRoomsStream => _chatRoomsController.stream;
  Stream<TypingIndicator> get typingStream => _typingController.stream;
  Stream<ReadReceipt> get readReceiptStream => _readReceiptController.stream;

  // Initialize chat service
  Future<void> initialize() async {
    // TODO: Initialize Firebase Database or Socket.IO connection
    print('Chat service initialized');
  }

  // Get all chat rooms for a user
  Future<List<ChatRoom>> getChatRooms(String userId) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    return [
      ChatRoom(
        id: '1',
        name: 'Ahmad Transport',
        participantIds: [userId, 'provider1'],
        participantNames: {
          userId: 'You',
          'provider1': 'Ahmad Transport',
        },
        participantAvatars: {
          userId: null,
          'provider1': 'https://via.placeholder.com/150',
        },
        lastMessage: 'The harvester is on the way',
        lastMessageTime: now.subtract(const Duration(minutes: 5)).toString(),
        lastMessageSenderId: 'provider1',
        unreadCount: {userId: 2},
        chatType: 'direct',
        createdAt: now.subtract(const Duration(days: 1)).toString(),
        bookingId: 'booking123',
        participantStatus: {
          userId: 'online',
          'provider1': 'online',
        },
      ),
      ChatRoom(
        id: '2',
        name: 'Support Team',
        participantIds: [userId, 'support1'],
        participantNames: {
          userId: 'You',
          'support1': 'Support Team',
        },
        participantAvatars: {
          userId: null,
          'support1': null,
        },
        lastMessage: 'How can we help you today?',
        lastMessageTime: now.subtract(const Duration(hours: 2)).toString(),
        lastMessageSenderId: 'support1',
        unreadCount: {userId: 0},
        chatType: 'direct',
        createdAt: now.subtract(const Duration(days: 3)).toString(),
        participantStatus: {
          userId: 'online',
          'support1': 'away',
        },
      ),
    ];
  }

  // Get messages for a chat room
  Future<List<Message>> getMessages(String chatRoomId) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    return [
      Message(
        id: '1',
        chatRoomId: chatRoomId,
        senderId: 'provider1',
        senderName: 'Ahmad Transport',
        content: 'Hello! I\'m ready to provide service.',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(hours: 1)).toString(),
        isRead: true,
        readBy: ['user1'],
      ),
      Message(
        id: '2',
        chatRoomId: chatRoomId,
        senderId: 'user1',
        senderName: 'You',
        content: 'Great! When can you arrive?',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(minutes: 55)).toString(),
        isRead: true,
        readBy: ['provider1'],
      ),
      Message(
        id: '3',
        chatRoomId: chatRoomId,
        senderId: 'provider1',
        senderName: 'Ahmad Transport',
        content: 'I\'ll be there in 30 minutes',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(minutes: 50)).toString(),
        isRead: true,
        readBy: ['user1'],
      ),
      Message(
        id: '4',
        chatRoomId: chatRoomId,
        senderId: 'provider1',
        senderName: 'Ahmad Transport',
        content: 'The harvester is on the way',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(minutes: 5)).toString(),
        isRead: false,
        readBy: [],
      ),
    ];
  }

  // Send a text message
  Future<Message> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String content,
    String? replyToMessageId,
  }) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatRoomId: chatRoomId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now().toString(),
      isRead: false,
      readBy: [],
      replyToMessageId: replyToMessageId,
    );

    // Update chat room's last message
    await _updateChatRoomLastMessage(chatRoomId, message);

    return message;
  }

  // Send a media message (image, video, document)
  Future<Message?> sendMediaMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required MessageType type,
    String? caption,
  }) async {
    // Pick file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type == MessageType.image
          ? FileType.image
          : type == MessageType.video
              ? FileType.video
              : FileType.any,
    );

    if (result == null) return null;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;
    final fileSize = result.files.single.size.toDouble();

    // TODO: Upload file to storage and get URL
    await Future.delayed(const Duration(seconds: 2));
    final mockMediaUrl = 'https://example.com/media/$fileName';

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatRoomId: chatRoomId,
      senderId: senderId,
      senderName: senderName,
      content: caption ?? fileName,
      type: type,
      timestamp: DateTime.now().toString(),
      isRead: false,
      readBy: [],
      mediaUrl: mockMediaUrl,
      mediaType: result.files.single.extension,
      mediaSize: fileSize,
    );

    // Update chat room's last message
    await _updateChatRoomLastMessage(chatRoomId, message);

    return message;
  }

  // Send location message
  Future<Message> sendLocationMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatRoomId: chatRoomId,
      senderId: senderId,
      senderName: senderName,
      content: address ?? 'Location: $latitude, $longitude',
      type: MessageType.location,
      timestamp: DateTime.now().toString(),
      isRead: false,
      readBy: [],
    );

    await _updateChatRoomLastMessage(chatRoomId, message);

    return message;
  }

  // Mark message as read
  Future<void> markAsRead(String messageId, String userId) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 200));

    final receipt = ReadReceipt(
      messageId: messageId,
      userId: userId,
      readAt: DateTime.now().toString(),
    );

    _readReceiptController.add(receipt);
  }

  // Mark all messages in chat room as read
  Future<void> markChatRoomAsRead(String chatRoomId, String userId) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Send typing indicator
  Future<void> sendTypingIndicator({
    required String chatRoomId,
    required String userId,
    required bool isTyping,
  }) async {
    final indicator = TypingIndicator(
      chatRoomId: chatRoomId,
      userId: userId,
      isTyping: isTyping,
      timestamp: DateTime.now().toString(),
    );

    _typingController.add(indicator);

    // TODO: Send to server via WebSocket or Firebase
  }

  // Get or create a chat room between users
  Future<ChatRoom> getOrCreateChatRoom({
    required String userId,
    required String otherUserId,
    required String otherUserName,
    String? otherUserAvatar,
    String? bookingId,
  }) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));

    return ChatRoom(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: otherUserName,
      participantIds: [userId, otherUserId],
      participantNames: {
        userId: 'You',
        otherUserId: otherUserName,
      },
      participantAvatars: {
        userId: null,
        otherUserId: otherUserAvatar,
      },
      chatType: 'direct',
      createdAt: DateTime.now().toString(),
      bookingId: bookingId,
      unreadCount: {},
      participantStatus: {
        userId: 'online',
        otherUserId: 'offline',
      },
    );
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Delete a chat room
  Future<void> deleteChatRoom(String chatRoomId) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Update chat room's last message
  Future<void> _updateChatRoomLastMessage(
    String chatRoomId,
    Message message,
  ) async {
    // TODO: Update chat room in database
  }

  // Listen to new messages in real-time
  Stream<Message> listenToMessages(String chatRoomId) async* {
    // TODO: Implement real-time listener with Firebase or Socket.IO
    // This is a mock implementation
    while (true) {
      await Future.delayed(const Duration(seconds: 10));
      // Emit mock messages occasionally
    }
  }

  // Listen to chat room updates
  Stream<ChatRoom> listenToChatRoom(String chatRoomId) async* {
    // TODO: Implement real-time listener with Firebase or Socket.IO
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      // Emit chat room updates
    }
  }

  // Get total unread message count
  Future<int> getTotalUnreadCount(String userId) async {
    final chatRooms = await getChatRooms(userId);
    return chatRooms.fold(
      0,
      (sum, room) => sum + room.getUnreadCount(userId),
    );
  }

  // Dispose streams
  void dispose() {
    _messagesController.close();
    _chatRoomsController.close();
    _typingController.close();
    _readReceiptController.close();
  }
}
