class Message {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final String timestamp;
  final bool isRead;
  final List<String> readBy;
  final String? mediaUrl;
  final String? mediaType;
  final double? mediaSize;
  final String? replyToMessageId;

  Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.readBy = const [],
    this.mediaUrl,
    this.mediaType,
    this.mediaSize,
    this.replyToMessageId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatRoomId: json['chatRoomId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderAvatar: json['senderAvatar'] as String?,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      timestamp: json['timestamp'] as String,
      isRead: json['isRead'] as bool? ?? false,
      readBy: (json['readBy'] as List<dynamic>?)?.cast<String>() ?? [],
      mediaUrl: json['mediaUrl'] as String?,
      mediaType: json['mediaType'] as String?,
      mediaSize: json['mediaSize'] as double?,
      replyToMessageId: json['replyToMessageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp,
      'isRead': isRead,
      'readBy': readBy,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'mediaSize': mediaSize,
      'replyToMessageId': replyToMessageId,
    };
  }

  Message copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    MessageType? type,
    String? timestamp,
    bool? isRead,
    List<String>? readBy,
    String? mediaUrl,
    String? mediaType,
    double? mediaSize,
    String? replyToMessageId,
  }) {
    return Message(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      readBy: readBy ?? this.readBy,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      mediaSize: mediaSize ?? this.mediaSize,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    );
  }
}

enum MessageType {
  text,
  image,
  video,
  audio,
  document,
  location,
  system,
}

class ChatRoom {
  final String id;
  final String name;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantAvatars;
  final String? lastMessage;
  final String? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final String? chatType; // 'direct' or 'group'
  final String createdAt;
  final String? bookingId;
  final Map<String, bool>? participantTyping;
  final Map<String, String>? participantStatus; // online, offline, away

  ChatRoom({
    required this.id,
    required this.name,
    required this.participantIds,
    required this.participantNames,
    required this.participantAvatars,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unreadCount = const {},
    this.chatType = 'direct',
    required this.createdAt,
    this.bookingId,
    this.participantTyping,
    this.participantStatus,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      participantIds: (json['participantIds'] as List<dynamic>).cast<String>(),
      participantNames: Map<String, String>.from(json['participantNames'] as Map),
      participantAvatars: Map<String, String?>.from(json['participantAvatars'] as Map),
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] as String?,
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
      unreadCount: Map<String, int>.from(json['unreadCount'] as Map? ?? {}),
      chatType: json['chatType'] as String? ?? 'direct',
      createdAt: json['createdAt'] as String,
      bookingId: json['bookingId'] as String?,
      participantTyping: json['participantTyping'] != null
          ? Map<String, bool>.from(json['participantTyping'] as Map)
          : null,
      participantStatus: json['participantStatus'] != null
          ? Map<String, String>.from(json['participantStatus'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'chatType': chatType,
      'createdAt': createdAt,
      'bookingId': bookingId,
      'participantTyping': participantTyping,
      'participantStatus': participantStatus,
    };
  }

  ChatRoom copyWith({
    String? id,
    String? name,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String?>? participantAvatars,
    String? lastMessage,
    String? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    String? chatType,
    String? createdAt,
    String? bookingId,
    Map<String, bool>? participantTyping,
    Map<String, String>? participantStatus,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantAvatars: participantAvatars ?? this.participantAvatars,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      chatType: chatType ?? this.chatType,
      createdAt: createdAt ?? this.createdAt,
      bookingId: bookingId ?? this.bookingId,
      participantTyping: participantTyping ?? this.participantTyping,
      participantStatus: participantStatus ?? this.participantStatus,
    );
  }

  // Helper to get other participant's name in direct chat
  String getOtherParticipantName(String currentUserId) {
    if (chatType == 'group') return name;
    return participantNames.entries
        .firstWhere((entry) => entry.key != currentUserId)
        .value;
  }

  // Helper to get other participant's avatar in direct chat
  String? getOtherParticipantAvatar(String currentUserId) {
    if (chatType == 'group') return null;
    return participantAvatars.entries
        .firstWhere((entry) => entry.key != currentUserId)
        .value;
  }

  // Helper to check if someone is typing
  bool isAnyoneTyping(String currentUserId) {
    if (participantTyping == null) return false;
    return participantTyping!.entries
        .any((entry) => entry.key != currentUserId && entry.value == true);
  }

  // Get unread count for specific user
  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }
}

class TypingIndicator {
  final String chatRoomId;
  final String userId;
  final bool isTyping;
  final String timestamp;

  TypingIndicator({
    required this.chatRoomId,
    required this.userId,
    required this.isTyping,
    required this.timestamp,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      chatRoomId: json['chatRoomId'] as String,
      userId: json['userId'] as String,
      isTyping: json['isTyping'] as bool,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': chatRoomId,
      'userId': userId,
      'isTyping': isTyping,
      'timestamp': timestamp,
    };
  }
}

class ReadReceipt {
  final String messageId;
  final String userId;
  final String readAt;

  ReadReceipt({
    required this.messageId,
    required this.userId,
    required this.readAt,
  });

  factory ReadReceipt.fromJson(Map<String, dynamic> json) {
    return ReadReceipt(
      messageId: json['messageId'] as String,
      userId: json['userId'] as String,
      readAt: json['readAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'userId': userId,
      'readAt': readAt,
    };
  }
}
