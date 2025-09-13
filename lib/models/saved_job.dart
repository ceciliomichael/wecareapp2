class SavedJob {
  final String id;
  final String helperId;
  final String jobPostingId;
  final DateTime savedAt;

  SavedJob({
    required this.id,
    required this.helperId,
    required this.jobPostingId,
    required this.savedAt,
  });

  factory SavedJob.fromMap(Map<String, dynamic> map) {
    return SavedJob(
      id: map['id'] as String,
      helperId: map['helper_id'] as String,
      jobPostingId: map['job_posting_id'] as String,
      savedAt: DateTime.parse(map['saved_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'helper_id': helperId,
      'job_posting_id': jobPostingId,
      'saved_at': savedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'helper_id': helperId,
      'job_posting_id': jobPostingId,
    };
  }

  SavedJob copyWith({
    String? id,
    String? helperId,
    String? jobPostingId,
    DateTime? savedAt,
  }) {
    return SavedJob(
      id: id ?? this.id,
      helperId: helperId ?? this.helperId,
      jobPostingId: jobPostingId ?? this.jobPostingId,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedJob &&
        other.id == id &&
        other.helperId == helperId &&
        other.jobPostingId == jobPostingId &&
        other.savedAt == savedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        helperId.hashCode ^
        jobPostingId.hashCode ^
        savedAt.hashCode;
  }

  @override
  String toString() {
    return 'SavedJob(id: $id, helperId: $helperId, jobPostingId: $jobPostingId, savedAt: $savedAt)';
  }
}
