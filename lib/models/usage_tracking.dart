class UsageTracking {
  final String id;
  final String userId;
  final String userType; // 'Employer' or 'Helper'
  final int usageCount;
  final int trialLimit;
  final DateTime lastUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UsageTracking({
    required this.id,
    required this.userId,
    required this.userType,
    required this.usageCount,
    required this.trialLimit,
    required this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UsageTracking.fromMap(Map<String, dynamic> map) {
    return UsageTracking(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      userType: map['user_type'] ?? '',
      usageCount: map['usage_count'] ?? 0,
      trialLimit: map['trial_limit'] ?? 0,
      lastUsedAt: DateTime.parse(map['last_used_at'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_type': userType,
      'usage_count': usageCount,
      'trial_limit': trialLimit,
      'last_used_at': lastUsedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get hasExceededTrial {
    return usageCount >= trialLimit;
  }

  int get remainingTrialUses {
    final remaining = trialLimit - usageCount;
    return remaining > 0 ? remaining : 0;
  }

  double get trialUsagePercentage {
    if (trialLimit == 0) return 1.0;
    return (usageCount / trialLimit).clamp(0.0, 1.0);
  }

  UsageTracking copyWith({
    String? id,
    String? userId,
    String? userType,
    int? usageCount,
    int? trialLimit,
    DateTime? lastUsedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UsageTracking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      usageCount: usageCount ?? this.usageCount,
      trialLimit: trialLimit ?? this.trialLimit,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
