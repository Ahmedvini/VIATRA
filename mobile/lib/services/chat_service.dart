import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Service for handling chat-related API calls
class ChatService {
  factory ChatService() => _instance;
  ChatService._internal();
  static final ChatService _instance = ChatService._internal();

  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  String? _authToken;

  /// Set the authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Get headers with authentication
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  /// Get user's conversations
  Future<Map<String, dynamic>> getConversations({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (type != null) 'type': type,
      };

      final uri = Uri.parse('$_baseUrl/api/v1/chat/conversations')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'conversations': (data['data']['conversations'] as List)
              .map((json) => Conversation.fromJson(json))
              .toList(),
          'pagination': data['data']['pagination'],
        };
      } else {
        throw Exception('Failed to load conversations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching conversations: $e');
    }
  }

  /// Create or get existing conversation
  Future<Conversation> createConversation({
    required List<String> participantIds,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/chat/conversations');
      final body = json.encode({
        'participantIds': participantIds,
      });

      final response = await http.post(
        uri,
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return Conversation.fromJson(data['data']);
      } else {
        throw Exception('Failed to create conversation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating conversation: $e');
    }
  }

  /// Get messages in a conversation
  Future<Map<String, dynamic>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse(
              '$_baseUrl/api/v1/chat/conversations/$conversationId/messages')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'messages': (data['data']['messages'] as List)
              .map((json) => Message.fromJson(json))
              .toList(),
          'pagination': data['data']['pagination'],
        };
      } else {
        throw Exception('Failed to load messages: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  /// Send a message (via REST API, not socket)
  Future<Message> sendMessage({
    required String conversationId,
    required String messageType,
    String? content,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final uri = Uri.parse(
          '$_baseUrl/api/v1/chat/conversations/$conversationId/messages');
      final body = json.encode({
        'messageType': messageType,
        'content': content,
        if (metadata != null) 'metadata': metadata,
      });

      final response = await http.post(
        uri,
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Message.fromJson(data['data']);
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    try {
      final uri = Uri.parse(
          '$_baseUrl/api/v1/chat/conversations/$conversationId/read');
      final body = json.encode({
        'messageIds': messageIds,
      });

      final response = await http.post(
        uri,
        headers: _headers,
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark messages as read: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error marking messages as read: $e');
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/chat/messages/$messageId');

      final response = await http.delete(uri, headers: _headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }

  /// Update FCM token for push notifications
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/auth/fcm-token');
      final body = json.encode({
        'fcm_token': fcmToken,
      });

      final response = await http.post(
        uri,
        headers: _headers,
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update FCM token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating FCM token: $e');
    }
  }
}
