import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/conversation.dart';
import '../models/message.dart';
import 'session_service.dart';

class MessagingService {
  static const String _keyConversations = 'conversations';
  static const String _keyMessages = 'messages_';

  // Create or get existing conversation
  static Future<Conversation> createOrGetConversation({
    required String employerId,
    required String employerName,
    required String helperId,
    required String helperName,
    required String jobId,
    required String jobTitle,
  }) async {
    final conversationId = _generateConversationId(employerId, helperId, jobId);
    
    // Check if conversation already exists
    final existingConversation = await getConversationById(conversationId);
    if (existingConversation != null) {
      return existingConversation;
    }

    // Create new conversation
    final conversation = Conversation(
      id: conversationId,
      employerId: employerId,
      employerName: employerName,
      helperId: helperId,
      helperName: helperName,
      jobId: jobId,
      jobTitle: jobTitle,
      status: ConversationStatus.active,
      unreadCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _saveConversation(conversation);
    return conversation;
  }

  // Get conversation by ID
  static Future<Conversation?> getConversationById(String conversationId) async {
    final conversations = await getUserConversations();
    try {
      return conversations.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  // Get user conversations
  static Future<List<Conversation>> getUserConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = prefs.getStringList(_keyConversations) ?? [];
    
    final currentUserId = await SessionService.getCurrentUserId();
    if (currentUserId == null) return [];

    final conversations = conversationsJson
        .map((json) => Conversation.fromMap(jsonDecode(json)))
        .where((conversation) => 
            conversation.employerId == currentUserId || 
            conversation.helperId == currentUserId)
        .toList();

    // Sort by last message time
    conversations.sort((a, b) {
      final aTime = a.lastMessage?.createdAt ?? a.updatedAt;
      final bTime = b.lastMessage?.createdAt ?? b.updatedAt;
      return bTime.compareTo(aTime);
    });

    return conversations;
  }

  // Send message
  static Future<Message> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final currentUserId = await SessionService.getCurrentUserId();
    final currentUserType = await SessionService.getCurrentUserType();
    
    if (currentUserId == null || currentUserType == null) {
      throw Exception('User not found');
    }

    String senderName;
    if (currentUserType == 'Employer') {
      final employer = await SessionService.getCurrentEmployer();
      senderName = employer?.fullName ?? 'Unknown Employer';
    } else {
      final helper = await SessionService.getCurrentHelper();
      senderName = helper?.fullName ?? 'Unknown Helper';
    }

    final message = Message(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: currentUserId,
      senderType: currentUserType,
      senderName: senderName,
      content: content,
      type: type,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
    );

    await _saveMessage(message);
    await _updateConversationLastMessage(conversationId, message);

    return message;
  }

  // Get messages for conversation
  static Future<List<Message>> getConversationMessages(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList('$_keyMessages$conversationId') ?? [];
    
    final messages = messagesJson
        .map((json) => Message.fromMap(jsonDecode(json)))
        .toList();

    // Sort by creation time (oldest first)
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return messages;
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(String conversationId, String currentUserId) async {
    final messages = await getConversationMessages(conversationId);
    final unreadMessages = messages
        .where((m) => m.senderId != currentUserId && !m.isRead)
        .toList();

    if (unreadMessages.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final updatedMessages = messages.map((message) {
      if (message.senderId != currentUserId && !message.isRead) {
        return message.copyWith(
          status: MessageStatus.read,
          readAt: DateTime.now(),
        );
      }
      return message;
    }).toList();

    final messagesJson = updatedMessages
        .map((message) => jsonEncode(message.toMap()))
        .toList();

    await prefs.setStringList('$_keyMessages$conversationId', messagesJson);

    // Update conversation unread count
    await _updateConversationUnreadCount(conversationId);
  }

  // Update conversation unread count
  static Future<void> _updateConversationUnreadCount(String conversationId) async {
    final conversation = await getConversationById(conversationId);
    if (conversation == null) return;

    final currentUserId = await SessionService.getCurrentUserId();
    if (currentUserId == null) return;

    final messages = await getConversationMessages(conversationId);
    final unreadCount = messages
        .where((m) => m.senderId != currentUserId && !m.isRead)
        .length;

    final updatedConversation = conversation.copyWith(
      unreadCount: unreadCount,
      updatedAt: DateTime.now(),
    );

    await _saveConversation(updatedConversation);
  }

  // Save conversation
  static Future<void> _saveConversation(Conversation conversation) async {
    final prefs = await SharedPreferences.getInstance();
    final conversations = await getUserConversations();
    
    // Remove existing conversation with same ID
    conversations.removeWhere((c) => c.id == conversation.id);
    
    // Add updated conversation
    conversations.add(conversation);
    
    final conversationsJson = conversations
        .map((c) => jsonEncode(c.toMap()))
        .toList();
    
    await prefs.setStringList(_keyConversations, conversationsJson);
  }

  // Save message
  static Future<void> _saveMessage(Message message) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyMessages${message.conversationId}';
    final messagesJson = prefs.getStringList(key) ?? [];
    
    messagesJson.add(jsonEncode(message.toMap()));
    await prefs.setStringList(key, messagesJson);
  }

  // Update conversation with last message
  static Future<void> _updateConversationLastMessage(String conversationId, Message message) async {
    final conversation = await getConversationById(conversationId);
    if (conversation == null) return;

    final currentUserId = await SessionService.getCurrentUserId();
    final unreadCount = message.senderId == currentUserId 
        ? conversation.unreadCount 
        : conversation.unreadCount + 1;

    final updatedConversation = conversation.copyWith(
      lastMessage: message,
      unreadCount: unreadCount,
      updatedAt: DateTime.now(),
    );

    await _saveConversation(updatedConversation);
  }

  // Generate conversation ID
  static String _generateConversationId(String employerId, String helperId, String jobId) {
    return '${employerId}_${helperId}_$jobId';
  }

  // Delete conversation
  static Future<void> deleteConversation(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Delete messages
    await prefs.remove('$_keyMessages$conversationId');
    
    // Remove conversation from list
    final conversations = await getUserConversations();
    conversations.removeWhere((c) => c.id == conversationId);
    
    final conversationsJson = conversations
        .map((c) => jsonEncode(c.toMap()))
        .toList();
    
    await prefs.setStringList(_keyConversations, conversationsJson);
  }

  // Get total unread messages count
  static Future<int> getTotalUnreadCount() async {
    final conversations = await getUserConversations();
    final currentUserId = await SessionService.getCurrentUserId();
    if (currentUserId == null) return 0;

    int totalUnread = 0;
    for (final conversation in conversations) {
      if (conversation.hasUnreadMessages(currentUserId)) {
        totalUnread += conversation.unreadCount;
      }
    }
    return totalUnread;
  }
}
