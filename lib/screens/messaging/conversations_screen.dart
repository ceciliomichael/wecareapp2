import 'package:flutter/material.dart';
import '../../models/conversation.dart';
import '../../services/database_messaging_service.dart';
import '../../services/session_service.dart';
import '../../services/realtime_messaging_service.dart';
import '../../widgets/messaging/conversation_card.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<Conversation> _conversations = [];
  String? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _startRealtimePolling();
  }

  @override
  void dispose() {
    RealtimeMessagingService.stopConversationPolling();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    try {
      final currentUserId = await SessionService.getCurrentUserId();
      final conversations = await DatabaseMessagingService.getUserConversations();
      
      if (mounted) {
        setState(() {
          _currentUserId = currentUserId;
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startRealtimePolling() {
    RealtimeMessagingService.startConversationPolling(
      onConversationsUpdated: _onConversationsUpdated,
    );
  }

  void _onConversationsUpdated(List<Conversation> conversations) {
    if (mounted) {
      setState(() {
        _conversations = conversations;
      });
    }
  }

  Future<void> _navigateToChat(Conversation conversation) async {
    if (_currentUserId == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversation: conversation,
          currentUserId: _currentUserId!,
        ),
      ),
    );

    // Force refresh conversations when returning from chat
    RealtimeMessagingService.refreshConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.black12,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _conversations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      return ConversationCard(
                        conversation: conversation,
                        currentUserId: _currentUserId!,
                        onTap: () async {
                          await _navigateToChat(conversation);
                          // Hard refresh after returning to ensure badges clear immediately
                          _loadConversations();
                        },
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 40,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Messages Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When helpers apply to your jobs or when your applications are accepted, you can start conversations here.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
