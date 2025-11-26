import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import '../services/socket_service.dart';

/// Provider for managing chat state
class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final SocketService _socketService = SocketService();

  // State
  List<Conversation> _conversations = [];
  Map<String, List<Message>> _messagesByConversation = {};
  Map<String, bool> _isLoadingMessages = {};
  Map<String, bool> _hasMoreMessages = {};
  Map<String, int> _currentPages = {};
  Map<String, Set<String>> _typingUsers = {};
  String? _currentUserId;
  bool _isLoadingConversations = false;
  bool _hasMoreConversations = true;
  int _currentConversationsPage = 1;
  String? _error;

  // Subscriptions
  StreamSubscription? _newMessageSubscription;
  StreamSubscription? _messageDeliveredSubscription;
  StreamSubscription? _messageReadSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _connectionSubscription;

  // Getters
  List<Conversation> get conversations => _conversations;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get hasMoreConversations => _hasMoreConversations;
  String? get error => _error;
  bool get isSocketConnected => _socketService.isConnected;

  List<Message> getMessages(String conversationId) {
    return _messagesByConversation[conversationId] ?? [];
  }

  bool isLoadingMessages(String conversationId) {
    return _isLoadingMessages[conversationId] ?? false;
  }

  bool hasMoreMessages(String conversationId) {
    return _hasMoreMessages[conversationId] ?? true;
  }

  Set<String> getTypingUsers(String conversationId) {
    return _typingUsers[conversationId] ?? {};
  }

  /// Initialize the provider
  Future<void> initialize(String authToken, String userId) async {
    _currentUserId = userId;
    _chatService.setAuthToken(authToken);

    // Initialize socket
    await _socketService.initialize(authToken, userId);

    // Subscribe to socket events
    _subscribeToSocketEvents();

    // Load conversations
    await loadConversations();
  }

  /// Subscribe to socket events
  void _subscribeToSocketEvents() {
    _newMessageSubscription = _socketService.onNewMessage.listen((message) {
      _handleNewMessage(message);
    });

    _messageDeliveredSubscription =
        _socketService.onMessageDelivered.listen((data) {
      _handleMessageDelivered(data);
    });

    _messageReadSubscription = _socketService.onMessageRead.listen((data) {
      _handleMessageRead(data);
    });

    _typingSubscription = _socketService.onUserTyping.listen((data) {
      _handleUserTyping(data);
    });

    _connectionSubscription =
        _socketService.onConnectionChange.listen((connected) {
      notifyListeners();
    });
  }

  /// Load conversations
  Future<void> loadConversations({bool refresh = false}) async {
    if (_isLoadingConversations) return;
    if (!refresh && !_hasMoreConversations) return;

    try {
      _isLoadingConversations = true;
      _error = null;
      if (refresh) {
        _currentConversationsPage = 1;
        _conversations = [];
      }
      notifyListeners();

      final result = await _chatService.getConversations(
        page: _currentConversationsPage,
      );

      final newConversations = result['conversations'] as List<Conversation>;
      final pagination = result['pagination'] as Map<String, dynamic>;

      if (refresh) {
        _conversations = newConversations;
      } else {
        _conversations.addAll(newConversations);
      }

      _hasMoreConversations =
          _currentConversationsPage < (pagination['pages'] as int);
      _currentConversationsPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  /// Create or get conversation
  Future<Conversation?> createConversation({
    required String type,
    required List<String> participantIds,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _error = null;
      final conversation = await _chatService.createConversation(
        type: type,
        participantIds: participantIds,
        metadata: metadata,
      );

      // Add to list if not exists
      final index = _conversations.indexWhere((c) => c.id == conversation.id);
      if (index == -1) {
        _conversations.insert(0, conversation);
      } else {
        _conversations[index] = conversation;
      }

      notifyListeners();
      return conversation;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Load messages for a conversation
  Future<void> loadMessages(String conversationId,
      {bool refresh = false}) async {
    if (_isLoadingMessages[conversationId] == true) return;
    if (!refresh && _hasMoreMessages[conversationId] == false) return;

    try {
      _isLoadingMessages[conversationId] = true;
      _error = null;
      if (refresh) {
        _currentPages[conversationId] = 1;
        _messagesByConversation[conversationId] = [];
      }
      notifyListeners();

      final page = _currentPages[conversationId] ?? 1;
      final result = await _chatService.getMessages(
        conversationId: conversationId,
        page: page,
      );

      final newMessages = result['messages'] as List<Message>;
      final pagination = result['pagination'] as Map<String, dynamic>;

      final existing = _messagesByConversation[conversationId] ?? [];
      if (refresh) {
        _messagesByConversation[conversationId] = newMessages;
      } else {
        _messagesByConversation[conversationId] = [...existing, ...newMessages];
      }

      _hasMoreMessages[conversationId] = page < (pagination['pages'] as int);
      _currentPages[conversationId] = page + 1;

      // Join conversation room
      _socketService.joinConversation(conversationId);

      // Mark unread messages as delivered
      final undeliveredIds = newMessages
          .where((m) =>
              m.senderId != _currentUserId &&
              !m.isDeliveredTo(_currentUserId!))
          .map((m) => m.id)
          .toList();

      if (undeliveredIds.isNotEmpty) {
        _socketService.markDelivered(
          conversationId: conversationId,
          messageIds: undeliveredIds,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMessages[conversationId] = false;
      notifyListeners();
    }
  }

  /// Send a message (optimistic update)
  Future<void> sendMessage({
    required String conversationId,
    required String messageType,
    String? content,
    String? parentMessageId,
    Map<String, dynamic>? metadata,
  }) async {
    if (_currentUserId == null) return;

    // Create pending message
    final pendingMessage = Message.pending(
      conversationId: conversationId,
      senderId: _currentUserId!,
      messageType: messageType,
      content: content,
      metadata: metadata,
      parentMessageId: parentMessageId,
    );

    // Add to local list
    final messages = _messagesByConversation[conversationId] ?? [];
    _messagesByConversation[conversationId] = [pendingMessage, ...messages];
    notifyListeners();

    try {
      // Send via socket for real-time delivery
      _socketService.sendMessage(
        conversationId: conversationId,
        messageType: messageType,
        content: content,
        parentMessageId: parentMessageId,
        metadata: metadata,
      );

      // The actual message will be received via socket
      // Remove pending message when real one arrives
    } catch (e) {
      // Mark as failed
      final failedMessage = pendingMessage.copyWith(
        isPending: false,
        isFailed: true,
      );
      final updatedMessages = messages.map((m) {
        return m.id == pendingMessage.id ? failedMessage : m;
      }).toList();
      _messagesByConversation[conversationId] = updatedMessages;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(
      String conversationId, List<String> messageIds) async {
    if (messageIds.isEmpty) return;

    try {
      // Update locally
      final messages = _messagesByConversation[conversationId] ?? [];
      _messagesByConversation[conversationId] = messages.map((m) {
        return messageIds.contains(m.id) && _currentUserId != null
            ? m.markAsReadBy(_currentUserId!)
            : m;
      }).toList();
      notifyListeners();

      // Send to server via socket
      _socketService.markRead(
        conversationId: conversationId,
        messageIds: messageIds,
      );
    } catch (e) {
      _error = e.toString();
    }
  }

  /// Start typing indicator
  void startTyping(String conversationId) {
    _socketService.startTyping(conversationId);
  }

  /// Stop typing indicator
  void stopTyping(String conversationId) {
    _socketService.stopTyping(conversationId);
  }

  /// Leave a conversation room
  void leaveConversation(String conversationId) {
    _socketService.leaveConversation(conversationId);
  }

  /// Handle new message from socket
  void _handleNewMessage(Message message) {
    // Remove pending message if exists
    final messages = _messagesByConversation[message.conversationId] ?? [];
    final withoutPending =
        messages.where((m) => !m.isPending || m.senderId != _currentUserId);

    _messagesByConversation[message.conversationId] = [
      message,
      ...withoutPending
    ];

    // Update conversation's last message
    final convIndex =
        _conversations.indexWhere((c) => c.id == message.conversationId);
    if (convIndex != -1) {
      final conv = _conversations[convIndex];
      _conversations[convIndex] = conv.copyWith(
        lastMessage: message,
        lastMessageAt: message.createdAt,
        unreadCount: message.senderId != _currentUserId
            ? (conv.unreadCount ?? 0) + 1
            : conv.unreadCount,
      );

      // Move to top
      _conversations.removeAt(convIndex);
      _conversations.insert(0, _conversations.removeAt(convIndex));
    }

    notifyListeners();
  }

  /// Handle message delivered
  void _handleMessageDelivered(Map<String, dynamic> data) {
    final messageId = data['messageId'] as String;
    final userId = data['userId'] as String;

    for (final conversationId in _messagesByConversation.keys) {
      final messages = _messagesByConversation[conversationId]!;
      _messagesByConversation[conversationId] = messages.map((m) {
        return m.id == messageId ? m.markAsDeliveredTo(userId) : m;
      }).toList();
    }

    notifyListeners();
  }

  /// Handle message read
  void _handleMessageRead(Map<String, dynamic> data) {
    final messageId = data['messageId'] as String;
    final userId = data['userId'] as String;

    for (final conversationId in _messagesByConversation.keys) {
      final messages = _messagesByConversation[conversationId]!;
      _messagesByConversation[conversationId] = messages.map((m) {
        return m.id == messageId ? m.markAsReadBy(userId) : m;
      }).toList();
    }

    notifyListeners();
  }

  /// Handle user typing
  void _handleUserTyping(Map<String, dynamic> data) {
    final conversationId = data['conversationId'] as String;
    final userId = data['userId'] as String;
    final isTyping = data['isTyping'] as bool;

    final typing = _typingUsers[conversationId] ?? {};
    if (isTyping) {
      typing.add(userId);
    } else {
      typing.remove(userId);
    }
    _typingUsers[conversationId] = typing;

    notifyListeners();
  }

  @override
  void dispose() {
    _newMessageSubscription?.cancel();
    _messageDeliveredSubscription?.cancel();
    _messageReadSubscription?.cancel();
    _typingSubscription?.cancel();
    _connectionSubscription?.cancel();
    _socketService.disconnect();
    super.dispose();
  }
}
