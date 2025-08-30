import '../models/conversation.dart';
import '../models/message.dart';
import 'session_service.dart';
import 'supabase_service.dart';

class DatabaseMessagingService {
  static const String _conversationsTable = 'conversations';
  static const String _messagesTable = 'messages';

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
    
    try {
      // Check if conversation already exists
      final existingConversation = await getConversationById(conversationId);
      if (existingConversation != null) {
        return existingConversation;
      }

      // Create new conversation
      final conversationData = {
        'id': conversationId,
        'employer_id': employerId,
        'employer_name': employerName,
        'helper_id': helperId,
        'helper_name': helperName,
        'job_id': jobId,
        'job_title': jobTitle,
        'status': 'active',
        'unread_count_employer': 0,
        'unread_count_helper': 0,
      };

      final response = await SupabaseService.client
          .from(_conversationsTable)
          .insert(conversationData)
          .select()
          .single();

      return _mapToConversation(response);
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  // Get conversation by ID
  static Future<Conversation?> getConversationById(String conversationId) async {
    try {
      final response = await SupabaseService.client
          .from(_conversationsTable)
          .select()
          .eq('id', conversationId)
          .maybeSingle();

      if (response == null) return null;
      return _mapToConversation(response);
    } catch (e) {
      return null;
    }
  }

  // Get user conversations
  static Future<List<Conversation>> getUserConversations() async {
    try {
      final currentUserId = await SessionService.getCurrentUserId();
      if (currentUserId == null) return [];

      final response = await SupabaseService.client
          .from(_conversationsTable)
          .select()
          .or('employer_id.eq.$currentUserId,helper_id.eq.$currentUserId')
          .order('updated_at', ascending: false);

      return (response as List)
          .map((data) => _mapToConversation(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch conversations: $e');
    }
  }

  // Send message
  static Future<Message> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final currentUserId = await SessionService.getCurrentUserId();
      final currentUserType = await SessionService.getCurrentUserType();
      
      if (currentUserId == null || currentUserType == null) {
        throw Exception('User not found');
      }

      String senderName;
      if (currentUserType == 'Employer') {
        final employer = await SessionService.getCurrentEmployer();
        senderName = '${employer?.firstName ?? ''} ${employer?.lastName ?? ''}'.trim();
        if (senderName.isEmpty) senderName = 'Unknown Employer';
      } else {
        final helper = await SessionService.getCurrentHelper();
        senderName = '${helper?.firstName ?? ''} ${helper?.lastName ?? ''}'.trim();
        if (senderName.isEmpty) senderName = 'Unknown Helper';
      }

      final messageId = '${DateTime.now().millisecondsSinceEpoch}';
      final messageData = {
        'id': messageId,
        'conversation_id': conversationId,
        'sender_id': currentUserId,
        'sender_type': currentUserType,
        'sender_name': senderName,
        'content': content,
        'message_type': type.name,
        'status': MessageStatus.sent.name,
      };

      final response = await SupabaseService.client
          .from(_messagesTable)
          .insert(messageData)
          .select()
          .single();

      final message = _mapToMessage(response);
      
      // Update conversation with this new message
      await _updateConversationLastMessage(conversationId, message);
      
      return message;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages for conversation
  static Future<List<Message>> getConversationMessages(String conversationId) async {
    try {
      final response = await SupabaseService.client
          .from(_messagesTable)
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((data) => _mapToMessage(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(String conversationId, String currentUserId) async {
    try {
      final currentUserType = await SessionService.getCurrentUserType();
      if (currentUserType == null) return;

      // Update message status to read for messages from other users
      await SupabaseService.client
          .from(_messagesTable)
          .update({
            'status': MessageStatus.read.name,
            'read_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('conversation_id', conversationId)
          .neq('sender_id', currentUserId)
          .neq('status', MessageStatus.read.name);

      // Ensure conversation unread counter is reset for the viewing user
      if (currentUserType == 'Employer') {
        await SupabaseService.client
            .from(_conversationsTable)
            .update({
              'unread_count_employer': 0,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', conversationId);
      } else {
        await SupabaseService.client
            .from(_conversationsTable)
            .update({
              'unread_count_helper': 0,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', conversationId);
      }

      // Also call the RPC (if present) for any additional metadata updates
      try {
        await SupabaseService.client.rpc('mark_messages_as_read', params: {
          'conversation_id_param': conversationId,
          'user_id_param': currentUserId,
          'user_type_param': currentUserType,
        });
      } catch (_) {
        // Ignore if RPC isn't installed; direct updates above already applied
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Get total unread messages count
  static Future<int> getTotalUnreadCount() async {
    try {
      final currentUserId = await SessionService.getCurrentUserId();
      final currentUserType = await SessionService.getCurrentUserType();
      if (currentUserId == null || currentUserType == null) return 0;

      final conversations = await getUserConversations();
      int totalUnread = 0;

      for (final conversation in conversations) {
        if (currentUserType == 'Employer') {
          totalUnread += conversation.unreadCountEmployer;
        } else {
          totalUnread += conversation.unreadCountHelper;
        }
      }

      return totalUnread;
    } catch (e) {
      return 0;
    }
  }

  // Delete conversation
  static Future<void> deleteConversation(String conversationId) async {
    try {
      await SupabaseService.client
          .from(_conversationsTable)
          .delete()
          .eq('id', conversationId);
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }

  // Update conversation with last message
  static Future<void> _updateConversationLastMessage(String conversationId, Message message) async {
    try {
      final currentUserId = await SessionService.getCurrentUserId();
      final currentUserType = await SessionService.getCurrentUserType();
      if (currentUserId == null || currentUserType == null) return;

      // Get the conversation to update unread counts
      final conversation = await getConversationById(conversationId);
      if (conversation == null) return;

      // Update unread counts based on who sent the message
      int newUnreadCountEmployer = conversation.unreadCountEmployer;
      int newUnreadCountHelper = conversation.unreadCountHelper;
      
      if (message.senderId != conversation.employerId) {
        // Message from helper, increment employer's unread count
        newUnreadCountEmployer = conversation.unreadCountEmployer + 1;
      } else {
        // Message from employer, increment helper's unread count  
        newUnreadCountHelper = conversation.unreadCountHelper + 1;
      }

      // Update the conversation with the last message and unread counts
      await SupabaseService.client
          .from(_conversationsTable)
          .update({
            'last_message_id': message.id,
            'last_message_content': message.content,
            'last_message_sender_id': message.senderId,
            'last_message_created_at': message.createdAt.toUtc().toIso8601String(),
            'unread_count_employer': newUnreadCountEmployer,
            'unread_count_helper': newUnreadCountHelper,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', conversationId);
    } catch (e) {
      // Handle error silently
    }
  }

  // Generate conversation ID
  static String _generateConversationId(String employerId, String helperId, String jobId) {
    return '${employerId}_${helperId}_$jobId';
  }

  // Map database response to Conversation model
  static Conversation _mapToConversation(Map<String, dynamic> data) {
    Message? lastMessage;
    if (data['last_message_id'] != null) {
      lastMessage = Message(
        id: data['last_message_id'] as String,
        conversationId: data['id'] as String,
        senderId: data['last_message_sender_id'] as String,
        senderType: '', // We don't store this in conversation table
        senderName: '', // We don't store this in conversation table
        content: data['last_message_content'] as String,
        type: MessageType.text,
        status: MessageStatus.sent,
        createdAt: DateTime.parse(data['last_message_created_at'] as String).toLocal(),
      );
    }

    return Conversation(
      id: data['id'] as String,
      employerId: data['employer_id'] as String,
      employerName: data['employer_name'] as String,
      helperId: data['helper_id'] as String,
      helperName: data['helper_name'] as String,
      jobId: data['job_id'] as String,
      jobTitle: data['job_title'] as String,
      status: ConversationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ConversationStatus.active,
      ),
      lastMessage: lastMessage,
      unreadCount: 0, // Deprecated field
      unreadCountEmployer: (data['unread_count_employer'] as num?)?.toInt() ?? 0,
      unreadCountHelper: (data['unread_count_helper'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(data['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(data['updated_at'] as String).toLocal(),
    );
  }

  // Map database response to Message model
  static Message _mapToMessage(Map<String, dynamic> data) {
    return Message(
      id: data['id'] as String,
      conversationId: data['conversation_id'] as String,
      senderId: data['sender_id'] as String,
      senderType: data['sender_type'] as String,
      senderName: data['sender_name'] as String,
      content: data['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == data['message_type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MessageStatus.sent,
      ),
      createdAt: DateTime.parse(data['created_at'] as String).toLocal(),
      readAt: data['read_at'] != null ? DateTime.parse(data['read_at']).toLocal() : null,
    );
  }
}
