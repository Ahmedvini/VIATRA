import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'message_model.g.dart';

/// Represents a message in a conversation
@JsonSerializable(explicitToJson: true)
class Message {
  final String id;
  
  @JsonKey(name: 'conversation_id')
  final String conversationId;
  
  @JsonKey(name: 'sender_id')
  final String senderId;
  
  @JsonKey(name: 'parent_message_id')
  final String? parentMessageId;
  
  @JsonKey(name: 'message_type')
  final String messageType; // 'text', 'image', 'file', 'system'
  
  final String? content;
  
  final Map<String, dynamic>? metadata;
  
  @JsonKey(name: 'read_by')
  final List<String> readBy;
  
  @JsonKey(name: 'delivered_to')
  final List<String> deliveredTo;
  
  @JsonKey(name: 'is_edited')
  final bool isEdited;
  
  @JsonKey(name: 'is_deleted')
  final bool isDeleted;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  
  // Virtual field from API
  final User? sender;
  
  // Local-only field for optimistic updates
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isPending;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isFailed;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.parentMessageId,
    required this.messageType,
    this.content,
    this.metadata,
    this.readBy = const [],
    this.deliveredTo = const [],
    this.isEdited = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.isPending = false,
    this.isFailed = false,
  });

  /// Creates a Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  /// Converts Message to JSON
  Map<String, dynamic> toJson() => _$MessageToJson(this);

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
  }) {
    return Message(
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
  }

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
