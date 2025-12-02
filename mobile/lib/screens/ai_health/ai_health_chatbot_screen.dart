import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ai_health_chatbot_service.dart';
import '../../services/api_service.dart';

class AIHealthChatbotScreen extends StatefulWidget {
  const AIHealthChatbotScreen({Key? key}) : super(key: key);

  @override
  _AIHealthChatbotScreenState createState() => _AIHealthChatbotScreenState();
}

class _AIHealthChatbotScreenState extends State<AIHealthChatbotScreen> {
  late AIHealthChatbotService _chatbotService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<AIChatMessage> _messages = [];
  bool _isLoading = false;
  bool _hasConsent = false;
  bool _isCheckingConsent = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _chatbotService = AIHealthChatbotService(context.read<ApiService>());
    _checkConsent();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkConsent() async {
    setState(() => _isCheckingConsent = true);
    
    try {
      final hasConsent = await _chatbotService.checkConsent();
      
      setState(() {
        _hasConsent = hasConsent;
        _isCheckingConsent = false;
      });

      if (hasConsent) {
        _loadChatHistory();
        _addWelcomeMessage();
      }
    } catch (e) {
      setState(() => _isCheckingConsent = false);
      
      // Check if it's an authentication error
      final errorMessage = e.toString();
      final isAuthError = errorMessage.contains('401') || 
                          errorMessage.contains('Authentication') ||
                          errorMessage.contains('Token') ||
                          errorMessage.contains('Unauthorized');
      
      if (mounted) {
        if (isAuthError) {
          // Show auth error and go back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Please log in to use the AI Health Assistant'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Navigate back after delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        } else {
          // Other error - allow user to try granting consent
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error checking consent: ${errorMessage.replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  Future<void> _loadChatHistory() async {
    setState(() => _isLoading = true);
    
    try {
      final history = await _chatbotService.getChatHistory(limit: 50);
      
      setState(() {
        _messages = history;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
      }
    }
  }

  void _addWelcomeMessage() {
    if (_messages.isEmpty) {
      setState(() {
        _messages.add(AIChatMessage(
          id: 'welcome',
          content: 'Hello! 👋 I\'m your AI health assistant. I can help you understand your health data including sleep patterns, nutrition, and mental wellness (PHQ-9 scores).\n\nFeel free to share how you\'re feeling, and I\'ll provide personalized recommendations based on your health data.\n\n⚠️ Remember: I\'m here to support you, but if you\'re experiencing serious symptoms, please consult with a doctor immediately.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  Future<void> _requestConsent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.privacy_tip, color: Colors.blue),
            SizedBox(width: 8),
            Text('Data Consent'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To provide personalized health insights, the AI assistant needs access to your health data:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _buildConsentItem(Icons.bedtime, 'Sleep tracking data'),
              _buildConsentItem(Icons.restaurant, 'Food & nutrition logs'),
              _buildConsentItem(Icons.psychology, 'PHQ-9 mental health assessments'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your data is secure and only used to provide health recommendations. You can revoke consent anytime.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This AI assistant provides guidance only. Always consult a healthcare professional for medical advice.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('I Consent'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Processing consent...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      try {
        final success = await _chatbotService.requestDataConsent();
        
        if (success && mounted) {
          setState(() {
            _hasConsent = true;
          });
          
          // Add welcome message after state update
          _addWelcomeMessage();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Consent granted. AI assistant is ready!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (mounted) {
          // Failed to grant consent
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Failed to grant consent. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          // Show detailed error message
          final errorMessage = e.toString();
          final isAuthError = errorMessage.contains('401') || 
                              errorMessage.contains('Authentication') ||
                              errorMessage.contains('Token');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isAuthError 
                  ? '❌ Authentication error. Please log in again.'
                  : '❌ Failed to grant consent: ${errorMessage.replaceAll('Exception: ', '')}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
          
          // If auth error, consider navigating back to login
          if (isAuthError) {
            // Wait a moment then pop back
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.of(context).pop();
            }
          }
        }
      }
    }
  }

  Widget _buildConsentItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          const Icon(Icons.check_circle, size: 20, color: Colors.green),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    // Add user message
    final userMessage = AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _isSending = true;
    });

    _scrollToBottom();

    try {
      // Send to AI and get response
      final aiResponse = await _chatbotService.sendMessage(
        message: message,
        includeHealthData: _hasConsent,
      );

      setState(() {
        _messages.add(aiResponse);
        _isSending = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isSending = false);
      
      // Add error message
      setState(() {
        _messages.add(AIChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: '❌ Sorry, I encountered an error. Please try again.\n\nError: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _showOptions() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.insights, color: Colors.blue),
              title: const Text('Get Health Insights'),
              subtitle: const Text('Analyze your overall health data'),
              onTap: () {
                Navigator.pop(context);
                _getHealthInsights();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.orange),
              title: const Text('Clear Chat History'),
              subtitle: const Text('Remove all conversations'),
              onTap: () {
                Navigator.pop(context);
                _clearHistory();
              },
            ),
            if (_hasConsent)
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Revoke Data Access'),
                subtitle: const Text('Stop sharing health data'),
                onTap: () {
                  Navigator.pop(context);
                  _revokeConsent();
                },
              ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('Learn about the AI assistant'),
              onTap: () {
                Navigator.pop(context);
                _showAbout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getHealthInsights() async {
    setState(() => _isLoading = true);

    try {
      final insights = await _chatbotService.getHealthInsights();
      
      setState(() => _isLoading = false);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('🔍 Health Insights'),
            content: SingleChildScrollView(
              child: Text(insights['summary'] as String? ?? 'No insights available'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History?'),
        content: const Text('This will permanently delete all conversations with the AI assistant.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _chatbotService.clearHistory();
        setState(() => _messages.clear());
        _addWelcomeMessage();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat history cleared')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _revokeConsent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Data Access?'),
        content: const Text(
          'The AI assistant will no longer have access to your health data. '
          'You can grant consent again anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _chatbotService.revokeConsent();
        setState(() => _hasConsent = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data access revoked'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🤖 AI Health Assistant'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This AI-powered assistant analyzes your health data to provide personalized recommendations.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Sleep pattern analysis'),
              Text('• Nutrition guidance'),
              Text('• Mental health support (PHQ-9)'),
              Text('• Personalized recommendations'),
              SizedBox(height: 12),
              Text(
                '⚠️ Important Disclaimer:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              Text(
                'This assistant provides general guidance only and is NOT a substitute for professional medical advice. Always consult qualified healthcare providers for diagnosis and treatment.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Assistant'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptions,
          ),
        ],
      ),
      body: _isCheckingConsent
          ? const Center(child: CircularProgressIndicator())
          : !_hasConsent
              ? _buildConsentRequired()
              : _buildChatInterface(),
    );
  }

  Widget _buildConsentRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety,
              size: 100,
              color: Colors.teal.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'AI Health Assistant',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Get personalized health insights based on your sleep, nutrition, and mental wellness data.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _requestConsent,
              icon: const Icon(Icons.verified_user),
              label: const Text('Grant Data Access'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '🔒 Your privacy is protected',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        // Messages list
        Expanded(
          child: _isLoading && _messages.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
        ),

        // Typing indicator
        if (_isSending)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.teal.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('AI is thinking...'),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Input field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Message AI assistant...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.teal,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(AIChatMessage message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: const Icon(Icons.smart_toy, color: Colors.teal),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.teal : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.teal.shade700,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
