class Rating {
  final String id;
  final String raterId;
  final String raterType;
  final String ratedId;
  final String ratedType;
  final String? jobPostingId;
  final String? servicePostingId;
  final int rating;
  final String? reviewText;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Rating({
    required this.id,
    required this.raterId,
    required this.raterType,
    required this.ratedId,
    required this.ratedType,
    this.jobPostingId,
    this.servicePostingId,
    required this.rating,
    this.reviewText,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'] as String,
      raterId: map['rater_id'] as String,
      raterType: map['rater_type'] as String,
      ratedId: map['rated_id'] as String,
      ratedType: map['rated_type'] as String,
      jobPostingId: map['job_posting_id'] as String?,
      servicePostingId: map['service_posting_id'] as String?,
      rating: map['rating'] as int,
      reviewText: map['review_text'] as String?,
      isAnonymous: map['is_anonymous'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rater_id': raterId,
      'rater_type': raterType,
      'rated_id': ratedId,
      'rated_type': ratedType,
      'job_posting_id': jobPostingId,
      'service_posting_id': servicePostingId,
      'rating': rating,
      'review_text': reviewText,
      'is_anonymous': isAnonymous,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateMap() {
    final map = <String, dynamic>{
      'rater_id': raterId,
      'rater_type': raterType,
      'rated_id': ratedId,
      'rated_type': ratedType,
      'rating': rating,
      'is_anonymous': isAnonymous,
    };

    if (jobPostingId != null) {
      map['job_posting_id'] = jobPostingId;
    }
    if (servicePostingId != null) {
      map['service_posting_id'] = servicePostingId;
    }
    if (reviewText != null && reviewText!.isNotEmpty) {
      map['review_text'] = reviewText;
    }

    return map;
  }

  Rating copyWith({
    String? id,
    String? raterId,
    String? raterType,
    String? ratedId,
    String? ratedType,
    String? jobPostingId,
    String? servicePostingId,
    int? rating,
    String? reviewText,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Rating(
      id: id ?? this.id,
      raterId: raterId ?? this.raterId,
      raterType: raterType ?? this.raterType,
      ratedId: ratedId ?? this.ratedId,
      ratedType: ratedType ?? this.ratedType,
      jobPostingId: jobPostingId ?? this.jobPostingId,
      servicePostingId: servicePostingId ?? this.servicePostingId,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
