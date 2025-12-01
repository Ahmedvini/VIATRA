import 'user_model.dart';

/// Represents a message in a conversation
class Message {

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.messageType, required this.createdAt, required this.updatedAt, this.parentMessageId,
    this.content,
    this.metadata,
    this.readBy = const [],
    this.deliveredTo = const [],
    this.isEdited = false,
    this.isDeleted = false,
    this.sender,
    this.isPending = false,
    this.isFailed = false,
  });

  /// Creates a Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) => Message(
      id: json['id']?.toString() ?? '',
      conversationId: (json['conversation_id'] as String?) ?? (json['conversationId'] as String?) ?? '',
      senderId: (json['sender_id'] as String?) ?? (json['senderId'] as String?) ?? '',
      parentMessageId: (json['parent_message_id'] as String?) ?? (json['parentMessageId'] as String?),
      messageType: (json['message_type'] as String?) ?? (json['messageType'] as String?) ?? 'text',
      content: json['content'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      readBy: json['read_by'] != null
          ? List<String>.from(json['read_by'] as List)
          : json['readBy'] != null
              ? List<String>.from(json['readBy'] as List)
              : [],
      deliveredTo: json['delivered_to'] != null
          ? List<String>.from(json['delivered_to'] as List)
          : json['deliveredTo'] != null
              ? List<String>.from(json['deliveredTo'] as List)
              : [],
      isEdited: (json['is_edited'] as bool?) ?? (json['isEdited'] as bool?) ?? false,
      isDeleted: (json['is_deleted'] as bool?) ?? (json['isDeleted'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
      sender: json['sender'] != null
          ? User.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
    );

  /// Creates a temporary message for optimistic updates
  factory Message.pending({
    required String conversationId,
    required String senderId,
    required String messageType,
    String? content,
    Map<String, dynamic>? metadata,
    String? parentMessageId,
  }) {
    final now = DateTime.now();
    return Message(
      id: 'pending_${now.millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: senderId,
      messageType: messageType,
      content: content,
      metadata: metadata,
      parentMessageId: parentMessageId,
      createdAt: now,
      updatedAt: now,
      isPending: true,
    );
  }
  final String id;
  
  final String conversationId;
  
  final String senderId;
  
  final String? parentMessageId;
  
  final String messageType; // 'text', 'image', 'file', 'system'
  
  final String? content;
  
  final Map<String, dynamic>? metadata;
  
  final List<String> readBy;
  
  final List<String> deliveredTo;
  
  final bool isEdited;
  
  final bool isDeleted;
  
  final DateTime createdAt;
  
  final DateTime updatedAt;
  
  // Virtual field from API
  final User? sender;
  
  // Local-only field for optimistic updates
  final bool isPending;
  
  final bool isFailed;

  /// Converts Message to JSON
  Map<String, dynamic> toJson() => {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'parent_message_id': parentMessageId,
      'message_type': messageType,
      'content': content,
      'metadata': metadata,
      'read_by': readBy,
      'delivered_to': deliveredTo,
      'is_edited': isEdited,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (sender != null) 'sender': sender!.toJson(),
    };

  /// Creates a copy of the message with updated fields
  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? parentMessageId,
    String? messageType,
    String? content,
    Map<String, dynamic>? metadata,
    List<String>? readBy,
    List<String>? deliveredTo,
    bool? isEdited,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? sender,
    bool? isPending,
    bool? isFailed,
  }) => Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      metadata: metadata ?? this.metadata,
      readBy: readBy ?? this.readBy,
      deliveredTo: deliveredTo ?? this.deliveredTo,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
    );

  /// Checks if the message was sent by the given user
  bool isSentBy(String userId) => senderId == userId;

  /// Checks if the message has been read by the given user
  bool isReadBy(String userId) => readBy.contains(userId);

  /// Checks if the message has been delivered to the given user
  bool isDeliveredTo(String userId) => deliveredTo.contains(userId);

  /// Checks if this is a text message
  bool get isText => messageType == 'text';

  /// Checks if this is an image message
  bool get isImage => messageType == 'image';

  /// Checks if this is a file message
  bool get isFile => messageType == 'file';

  /// Checks if this is a system message
  bool get isSystem => messageType == 'system';

  /// Gets the attachment URL from metadata if available
  String? get attachmentUrl {
    if (metadata == null) return null;
    return metadata!['attachment_url'] as String?;
  }

  /// Gets the file name from metadata if available
  String? get fileName {
    if (metadata == null) return null;
    return metadata!['file_name'] as String?;
  }

  /// Gets the file size from metadata if available
  int? get fileSize {
    if (metadata == null) return null;
    return metadata!['file_size'] as int?;
  }

  /// Gets a formatted file size string
  String? get fileSizeFormatted {
    final size = fileSize;
    if (size == null) return null;

    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Marks the message as read by a user
  Message markAsReadBy(String userId) {
    if (readBy.contains(userId)) return this;
    return copyWith(
      readBy: [...readBy, userId],
      deliveredTo: deliveredTo.contains(userId)
          ? deliveredTo
          : [...deliveredTo, userId],
    );
  }

  /// Marks the message as delivered to a user
  Message markAsDeliveredTo(String userId) {
    if (deliveredTo.contains(userId)) return this;
    return copyWith(deliveredTo: [...deliveredTo, userId]);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Message(id: $id, conversationId: $conversationId, type: $messageType)';
}
