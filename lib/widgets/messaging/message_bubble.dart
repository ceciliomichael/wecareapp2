import 'package:flutter/material.dart';
import '../../models/message.dart';
import 'location_message_widget.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;
  final bool showSenderName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.showSenderName = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: isCurrentUser ? 48 : 16,
        right: isCurrentUser ? 16 : 48,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: isCurrentUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          // Sender name (if needed)
          if (showSenderName && !isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          
          // Message content based on type
          _buildMessageContent(context),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    // Handle location messages
    if (message.isLocationMessage) {
      return Column(
        crossAxisAlignment: isCurrentUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          LocationMessageWidget(
            message: message,
            isCurrentUser: isCurrentUser,
          ),
          // Message metadata for location messages
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildMessageMetadata(),
          ),
        ],
      );
    }

    // Handle regular text messages
    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? const Color(0xFF1565C0)
            : Colors.grey[100],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
          bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 16,
                  color: isCurrentUser 
                      ? Colors.white 
                      : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            
            // Message metadata
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _buildMessageMetadata(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageMetadata() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: isCurrentUser 
                ? (message.isLocationMessage 
                    ? Colors.grey[600] 
                    : Colors.white.withValues(alpha: 0.8))
                : Colors.grey[600],
          ),
        ),
        if (isCurrentUser) ...[
          const SizedBox(width: 4),
          Icon(
            _getStatusIcon(),
            size: 14,
            color: message.status == MessageStatus.read 
                ? const Color(0xFF00BCD4) // Cyan for read
                : (message.isLocationMessage 
                    ? Colors.grey[600]
                    : Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    // Debug: Let's see what's happening with dates
    // print('Now: $now');
    // print('Message DateTime: $dateTime');
    // print('Today: $today');
    // print('Message Date: $messageDate');
    
    if (messageDate == today) {
      // Today - show time only
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Other days - show date
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  IconData _getStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }
}
