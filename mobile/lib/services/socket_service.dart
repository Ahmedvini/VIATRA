import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

/// Service for managing Socket.io WebSocket connections
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  String? _currentUserId;
  bool _isInitialized = false;

  // Stream controllers for events
  final _messageController = StreamController<Message>.broadcast();
  final _messageDeliveredController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageReadController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _userOnlineController = StreamController<String>.broadcast();
  final _userOfflineController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  // Public streams
  Stream<Message> get onNewMessage => _messageController.stream;
  Stream<Map<String, dynamic>> get onMessageDelivered =>
      _messageDeliveredController.stream;
  Stream<Map<String, dynamic>> get onMessageRead =>
      _messageReadController.stream;
  Stream<Map<String, dynamic>> get onUserTyping => _typingController.stream;
  Stream<String> get onUserOnline => _userOnlineController.stream;
  Stream<Map<String, dynamic>> get onUserOffline =>
      _userOfflineController.stream;
  Stream<String> get onError => _errorController.stream;
  Stream<bool> get onConnectionChange => _connectionController.stream;

  /// Initialize the socket connection
  Future<void> initialize(String token, String userId) async {
    if (_isInitialized && _socket?.connected == true) {
      return;
    }

    _currentUserId = userId;
    final serverUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setAuth({'token': token})
          .build(),
    );

    _setupEventHandlers();
    _socket!.connect();
    _isInitialized = true;
  }

  /// Setup event handlers for socket events
  void _setupEventHandlers() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      print('[SocketService] Connected to server');
      _connectionController.add(true);
    });

    _socket!.onDisconnect((_) {
      print('[SocketService] Disconnected from server');
      _connectionController.add(false);
    });

    _socket!.onConnectError((error) {
      print('[SocketService] Connection error: $error');
      _errorController.add('Connection error: ${error.toString()}');
    });

    _socket!.onError((error) {
      print('[SocketService] Socket error: $error');
      _errorController.add(error.toString());
    });

    // Chat events
    _socket!.on('new_message', (data) {
      try {
        final message = Message.fromJson(data as Map<String, dynamic>);
        _messageController.add(message);
      } catch (e) {
        print('[SocketService] Error parsing new_message: $e');
      }
    });

    _socket!.on('message_delivered', (data) {
      _messageDeliveredController.add(data as Map<String, dynamic>);
    });

    _socket!.on('message_read', (data) {
      _messageReadController.add(data as Map<String, dynamic>);
    });

    _socket!.on('user_typing', (data) {
      _typingController.add(data as Map<String, dynamic>);
    });

    _socket!.on('user_online', (data) {
      final userId = data['userId'] as String;
      _userOnlineController.add(userId);
    });

    _socket!.on('user_offline', (data) {
      _userOfflineController.add(data as Map<String, dynamic>);
    });

    _socket!.on('error', (data) {
      final message = data['message'] as String;
      _errorController.add(message);
    });
  }

  /// Join a conversation room
  void joinConversation(String conversationId) {
    if (_socket?.connected != true) return;
    _socket!.emit('join_conversation', {'conversationId': conversationId});
  }

  /// Leave a conversation room
  void leaveConversation(String conversationId) {
    if (_socket?.connected != true) return;
    _socket!.emit('leave_conversation', {'conversationId': conversationId});
  }

  /// Send a message through socket
  void sendMessage({
    required String conversationId,
    required String messageType,
    String? content,
    String? parentMessageId,
    Map<String, dynamic>? metadata,
  }) {
    if (_socket?.connected != true) return;

    _socket!.emit('send_message', {
      'conversationId': conversationId,
      'message_type': messageType,
      'content': content,
      'parent_message_id': parentMessageId,
      'metadata': metadata,
    });
  }

  /// Mark messages as delivered
  void markDelivered({
    required String conversationId,
    required List<String> messageIds,
  }) {
    if (_socket?.connected != true) return;

    _socket!.emit('mark_delivered', {
      'conversationId': conversationId,
      'messageIds': messageIds,
    });
  }

  /// Mark messages as read
  void markRead({
    required String conversationId,
    required List<String> messageIds,
  }) {
    if (_socket?.connected != true) return;

    _socket!.emit('mark_read', {
      'conversationId': conversationId,
      'messageIds': messageIds,
    });
  }

  /// Send typing start indicator
  void startTyping(String conversationId) {
    if (_socket?.connected != true) return;
    _socket!.emit('typing_start', {'conversationId': conversationId});
  }

  /// Send typing stop indicator
  void stopTyping(String conversationId) {
    if (_socket?.connected != true) return;
    _socket!.emit('typing_stop', {'conversationId': conversationId});
  }

  /// Check if socket is connected
  bool get isConnected => _socket?.connected ?? false;

  /// Get the socket instance (for advanced use cases)
  IO.Socket? get socket => _socket;

  /// Disconnect from the socket server
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    _isInitialized = false;
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _messageController.close();
    _messageDeliveredController.close();
    _messageReadController.close();
    _typingController.close();
    _userOnlineController.close();
    _userOfflineController.close();
    _errorController.close();
    _connectionController.close();
  }
}
