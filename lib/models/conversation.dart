import 'message.dart';

class Conversation {
  final String id;
  final String employerId;
  final String employerName;
  final String helperId;
  final String helperName;
  final String jobId;
  final String jobTitle;
  final ConversationStatus status;
  final Message? lastMessage;
  final int unreadCount; // Deprecated - kept for backward compatibility
  final int unreadCountEmployer;
  final int unreadCountHelper;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.employerId,
    required this.employerName,
    required this.helperId,
    required this.helperName,
    required this.jobId,
    required this.jobTitle,
    required this.status,
    this.lastMessage,
    this.unreadCount = 0, // Default for backward compatibility
    this.unreadCountEmployer = 0,
    this.unreadCountHelper = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] ?? '',
      employerId: map['employer_id'] ?? '',
      employerName: map['employer_name'] ?? '',
      helperId: map['helper_id'] ?? '',
      helperName: map['helper_name'] ?? '',
      jobId: map['job_id'] ?? '',
      jobTitle: map['job_title'] ?? '',
      status: ConversationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ConversationStatus.active,
      ),
      lastMessage: map['last_message'] != null 
          ? Message.fromMap(map['last_message']) 
          : null,
      unreadCount: map['unread_count'] ?? 0,
      unreadCountEmployer: map['unread_count_employer'] ?? 0,
      unreadCountHelper: map['unread_count_helper'] ?? 0,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employer_id': employerId,
      'employer_name': employerName,
      'helper_id': helperId,
      'helper_name': helperName,
      'job_id': jobId,
      'job_title': jobTitle,
      'status': status.name,
      'last_message': lastMessage?.toMap(),
      'unread_count': unreadCount,
      'unread_count_employer': unreadCountEmployer,
      'unread_count_helper': unreadCountHelper,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String getParticipantName(String currentUserId) {
    return currentUserId == employerId ? helperName : employerName;
  }

  String getParticipantId(String currentUserId) {
    return currentUserId == employerId ? helperId : employerId;
  }

  String getParticipantType(String currentUserId) {
    return currentUserId == employerId ? 'Helper' : 'Employer';
  }

  bool hasUnreadMessages(String currentUserId) {
    final userUnreadCount = currentUserId == employerId ? unreadCountEmployer : unreadCountHelper;
    return userUnreadCount > 0;
  }

  int getUserUnreadCount(String currentUserId) {
    return currentUserId == employerId ? unreadCountEmployer : unreadCountHelper;
  }

  Conversation copyWith({
    String? id,
    String? employerId,
    String? employerName,
    String? helperId,
    String? helperName,
    String? jobId,
    String? jobTitle,
    ConversationStatus? status,
    Message? lastMessage,
    int? unreadCount,
    int? unreadCountEmployer,
    int? unreadCountHelper,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      employerId: employerId ?? this.employerId,
      employerName: employerName ?? this.employerName,
      helperId: helperId ?? this.helperId,
      helperName: helperName ?? this.helperName,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      status: status ?? this.status,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      unreadCountEmployer: unreadCountEmployer ?? this.unreadCountEmployer,
      unreadCountHelper: unreadCountHelper ?? this.unreadCountHelper,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ConversationStatus {
  active,
  archived,
  blocked,
}
