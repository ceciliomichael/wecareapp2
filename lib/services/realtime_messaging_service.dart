import 'dart:async';
import 'package:flutter/widgets.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'database_messaging_service.dart';
import 'session_service.dart';

class RealtimeMessagingService with WidgetsBindingObserver {
  static Timer? _messagePollingTimer;
  static Timer? _conversationPollingTimer;
  static String? _currentConversationId;
  static Function(List<Message>)? _onMessagesUpdated;
  static Function(List<Conversation>)? _onConversationsUpdated;
  static List<Message> _lastMessages = [];
  static List<Conversation> _lastConversations = [];
  static bool _isAppInForeground = true;
  static final RealtimeMessagingService _instance = RealtimeMessagingService._internal();
  
  RealtimeMessagingService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }
  
  factory RealtimeMessagingService() => _instance;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppInForeground = state == AppLifecycleState.resumed;
    
    if (!_isAppInForeground) {
      // Pause polling when app is in background
      _messagePollingTimer?.cancel();
      _conversationPollingTimer?.cancel();
    } else {
      // Resume polling when app comes back to foreground
      if (_currentConversationId != null && _onMessagesUpdated != null) {
        startMessagePolling(
          conversationId: _currentConversationId!,
          onMessagesUpdated: _onMessagesUpdated!,
        );
      }
      if (_onConversationsUpdated != null) {
        startConversationPolling(
          onConversationsUpdated: _onConversationsUpdated!,
        );
      }
    }
  }

  // Start polling for messages in a specific conversation
  static void startMessagePolling({
    required String conversationId,
    required Function(List<Message>) onMessagesUpdated,
    Duration interval = const Duration(seconds: 5),
  }) {
    stopMessagePolling();
    
    _currentConversationId = conversationId;
    _onMessagesUpdated = onMessagesUpdated;
    
    // Initial load
    _pollMessages();
    
    // Start periodic polling
    _messagePollingTimer = Timer.periodic(interval, (_) {
      _pollMessages();
    });
  }

  // Stop message polling
  static void stopMessagePolling() {
    _messagePollingTimer?.cancel();
    _messagePollingTimer = null;
    _currentConversationId = null;
    _onMessagesUpdated = null;
    _lastMessages.clear();
  }

  // Start polling for conversation list updates
  static void startConversationPolling({
    required Function(List<Conversation>) onConversationsUpdated,
    Duration interval = const Duration(seconds: 10),
  }) {
    stopConversationPolling();
    
    _onConversationsUpdated = onConversationsUpdated;
    
    // Initial load
    _pollConversations();
    
    // Start periodic polling
    _conversationPollingTimer = Timer.periodic(interval, (_) {
      _pollConversations();
    });
  }

  // Stop conversation polling
  static void stopConversationPolling() {
    _conversationPollingTimer?.cancel();
    _conversationPollingTimer = null;
    _onConversationsUpdated = null;
    _lastConversations.clear();
  }

  // Poll for new messages in current conversation
  static Future<void> _pollMessages() async {
    if (_currentConversationId == null || _onMessagesUpdated == null || !_isAppInForeground) return;

    try {
      final messages = await DatabaseMessagingService.getConversationMessages(_currentConversationId!);
      
      // Check if messages have changed
      if (!_areMessagesEqual(_lastMessages, messages)) {
        _lastMessages = List.from(messages);
        _onMessagesUpdated!(messages);
        
        // Auto-mark messages as read when polling detects new messages
        await _markNewMessagesAsRead(messages);
      }
    } catch (e) {
      // Handle error silently for polling
    }
  }

  // Poll for conversation updates
  static Future<void> _pollConversations() async {
    if (_onConversationsUpdated == null || !_isAppInForeground) return;

    try {
      final conversations = await DatabaseMessagingService.getUserConversations();
      
      // Check if conversations have changed
      if (!_areConversationsEqual(_lastConversations, conversations)) {
        _lastConversations = List.from(conversations);
        _onConversationsUpdated!(conversations);
      }
    } catch (e) {
      // Handle error silently for polling
    }
  }

  // Mark new messages as read automatically
  static Future<void> _markNewMessagesAsRead(List<Message> messages) async {
    try {
      final currentUserId = await SessionService.getCurrentUserId();
      if (currentUserId == null || _currentConversationId == null) return;

      // Find unread messages from other users
      final unreadMessages = messages.where((message) => 
        message.senderId != currentUserId && 
        message.status != MessageStatus.read
      ).toList();

      if (unreadMessages.isNotEmpty) {
        await DatabaseMessagingService.markMessagesAsRead(_currentConversationId!, currentUserId);
        
        // Force refresh conversations to update unread counts immediately
        if (_onConversationsUpdated != null) {
          await _pollConversations();
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Compare message lists to detect changes
  static bool _areMessagesEqual(List<Message> list1, List<Message> list2) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      final msg1 = list1[i];
      final msg2 = list2[i];
      
      if (msg1.id != msg2.id || 
          msg1.content != msg2.content ||
          msg1.status != msg2.status ||
          msg1.readAt != msg2.readAt) {
        return false;
      }
    }
    
    return true;
  }

  // Compare conversation lists to detect changes
  static bool _areConversationsEqual(List<Conversation> list1, List<Conversation> list2) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      final conv1 = list1[i];
      final conv2 = list2[i];
      
      if (conv1.id != conv2.id || 
          conv1.unreadCountEmployer != conv2.unreadCountEmployer ||
          conv1.unreadCountHelper != conv2.unreadCountHelper ||
          conv1.updatedAt != conv2.updatedAt) {
        return false;
      }
      
      // Check last message changes
      if (conv1.lastMessage?.id != conv2.lastMessage?.id ||
          conv1.lastMessage?.content != conv2.lastMessage?.content) {
        return false;
      }
    }
    
    return true;
  }

  // Force refresh messages for current conversation
  static Future<void> refreshMessages() async {
    if (_currentConversationId != null) {
      await _pollMessages();
    }
  }

  // Force refresh conversations
  static Future<void> refreshConversations() async {
    await _pollConversations();
  }

  // Get current polling status
  static bool get isMessagePollingActive => _messagePollingTimer?.isActive ?? false;
  static bool get isConversationPollingActive => _conversationPollingTimer?.isActive ?? false;
  
  // Clean up all timers
  static void dispose() {
    stopMessagePolling();
    stopConversationPolling();
    WidgetsBinding.instance.removeObserver(_instance);
  }
}
