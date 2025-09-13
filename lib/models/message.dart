class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderType; // 'Employer' or 'Helper'
  final String senderName;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? readAt;
  // Location data for location messages
  final double? latitude;
  final double? longitude;
  final String? address;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.senderName,
    required this.content,
    required this.type,
    required this.status,
    required this.createdAt,
    this.readAt,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      conversationId: map['conversation_id'] ?? '',
      senderId: map['sender_id'] ?? '',
      senderType: map['sender_type'] ?? '',
      senderName: map['sender_name'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      readAt: map['read_at'] != null ? DateTime.parse(map['read_at']) : null,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_type': senderType,
      'sender_name': senderName,
      'content': content,
      'type': type.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  bool get isRead => readAt != null;

  bool get isLocationMessage => type == MessageType.location;

  bool get hasValidLocation => latitude != null && longitude != null;

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderType,
    String? senderName,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
    );
  }
}

enum MessageType {
  text,
  image,
  file,
  system,
  location,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}
