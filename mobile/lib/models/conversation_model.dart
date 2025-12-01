import 'user_model.dart';
import 'message_model.dart';

/// Represents a conversation in the chat system
class Conversation {

  Conversation({
    required this.id,
    required this.type,
    required this.participantIds,
    required this.createdBy,
    required this.createdAt, required this.updatedAt, this.lastMessageAt,
    this.metadata,
    this.unreadCount,
    this.participants,
    this.lastMessage,
  });

  /// Creates a Conversation from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
      id: json['id']?.toString() ?? '',
      type: (json['type'] as String?) ?? 'direct',
      participantIds: json['participant_ids'] != null
          ? List<String>.from(json['participant_ids'] as List)
          : json['participantIds'] != null
              ? List<String>.from(json['participantIds'] as List)
              : [],
      createdBy: (json['created_by'] as String?) ?? (json['createdBy'] as String?) ?? '',
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : json['lastMessageAt'] != null
              ? DateTime.parse(json['lastMessageAt'] as String)
              : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
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
      unreadCount: (json['unread_count'] as int?) ?? (json['unreadCount'] as int?),
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
          : json['lastMessage'] != null
              ? Message.fromJson(json['lastMessage'] as Map<String, dynamic>)
              : null,
    );
  final String id;
  final String type; // 'direct', 'group', 'channel'
  
  final List<String> participantIds;
  
  final String createdBy;
  
  final DateTime? lastMessageAt;
  
  final Map<String, dynamic>? metadata;
  
  final DateTime createdAt;
  
  final DateTime updatedAt;
  
  // Virtual fields from API
  final int? unreadCount;
  
  final List<User>? participants;
  
  final Message? lastMessage;

  /// Converts Conversation to JSON
  Map<String, dynamic> toJson() => {
      'id': id,
      'type': type,
      'participant_ids': participantIds,
      'created_by': createdBy,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'unread_count': unreadCount,
      if (participants != null)
        'participants': participants!.map((e) => e.toJson()).toList(),
      if (lastMessage != null) 'last_message': lastMessage!.toJson(),
    };

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

    // For direct conversations, could return the other participant's avatar
    // User model doesn't have profilePicture field yet
    // Return null for now or implement profile picture field later
    
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
