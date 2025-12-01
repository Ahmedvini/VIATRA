import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import 'message_model.dart';

part 'conversation_model.g.dart';

/// Represents a conversation in the chat system
@JsonSerializable(explicitToJson: true)
class Conversation {

  Conversation({
    required this.id,
    required this.type,
    required this.participantIds,
    required this.createdBy,
    this.lastMessageAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.unreadCount,
    this.participants,
    this.lastMessage,
  });

  /// Creates a Conversation from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
  final String id;
  final String type; // 'direct', 'group', 'channel'
  
  @JsonKey(name: 'participant_ids')
  final List<String> participantIds;
  
  @JsonKey(name: 'created_by')
  final String createdBy;
  
  @JsonKey(name: 'last_message_at')
  final DateTime? lastMessageAt;
  
  final Map<String, dynamic>? metadata;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  
  // Virtual fields from API
  @JsonKey(name: 'unread_count')
  final int? unreadCount;
  
  final List<User>? participants;
  
  @JsonKey(name: 'last_message')
  final Message? lastMessage;

  /// Converts Conversation to JSON
  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  /// Creates a copy of the conversation with updated fields
  Conversation copyWith({
    String? id,
    String? type,
    List<String>? participantIds,
    String? createdBy,
    DateTime? lastMessageAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? unreadCount,
    List<User>? participants,
    Message? lastMessage,
  }) => Conversation(
      id: id ?? this.id,
      type: type ?? this.type,
      participantIds: participantIds ?? this.participantIds,
      createdBy: createdBy ?? this.createdBy,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
    );

  /// Gets the conversation name based on type and participants
  String getName(String currentUserId) {
    // Check metadata for custom name first
    if (metadata?['name'] != null) {
      return metadata!['name'] as String;
    }

    // For direct conversations, return the other participant's name
    if (type == 'direct' && participants != null && participants!.isNotEmpty) {
      final otherParticipant = participants!.firstWhere(
        (p) => p.id != currentUserId,
        orElse: () => participants!.first,
      );
      return '${otherParticipant.firstName} ${otherParticipant.lastName}';
    }

    // For group/channel, return generic name if no custom name
    if (type == 'group') {
      return 'Group Chat';
    }

    return 'Conversation';
  }

  /// Gets the conversation avatar URL
  String? getAvatarUrl(String currentUserId) {
    // Check metadata for custom avatar first
    if (metadata?['avatar_url'] != null) {
      return metadata!['avatar_url'] as String;
    }

    // User model doesn't have profilePicture property
    // Avatar could be added to User model in the future or retrieved from profiles
    return null;
  }

  /// Gets a preview of the last message
  String? getLastMessagePreview() {
    if (lastMessage == null) return null;

    if (lastMessage!.isDeleted) {
      return 'Message deleted';
    }

    switch (lastMessage!.messageType) {
      case 'text':
        return lastMessage!.content;
      case 'image':
        return '📷 Image';
      case 'file':
        return '📎 File';
      case 'system':
        return lastMessage!.content;
      default:
        return 'Message';
    }
  }

  /// Checks if current user is a participant
  bool isParticipant(String userId) => participantIds.contains(userId);

  /// Gets the number of participants
  int get participantCount => participantIds.length;

  /// Checks if it's a direct conversation
  bool get isDirect => type == 'direct';

  /// Checks if it's a group conversation
  bool get isGroup => type == 'group';

  /// Checks if it's a channel conversation
  bool get isChannel => type == 'channel';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Conversation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Conversation(id: $id, type: $type)';
}
