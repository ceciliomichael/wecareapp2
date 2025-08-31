class RatingStatistics {
  final String userId;
  final String userType;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution; // star count -> number of ratings

  const RatingStatistics({
    required this.userId,
    required this.userType,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  factory RatingStatistics.empty(String userId, String userType) {
    return RatingStatistics(
      userId: userId,
      userType: userType,
      averageRating: 0.0,
      totalRatings: 0,
      ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
    );
  }

  factory RatingStatistics.fromMap(Map<String, dynamic> map) {
    return RatingStatistics(
      userId: map['user_id'] as String,
      userType: map['user_type'] as String,
      averageRating: (map['average_rating'] as num).toDouble(),
      totalRatings: map['total_ratings'] as int,
      ratingDistribution: Map<int, int>.from(map['rating_distribution'] as Map),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_type': userType,
      'average_rating': averageRating,
      'total_ratings': totalRatings,
      'rating_distribution': ratingDistribution,
    };
  }

  bool get hasRatings => totalRatings > 0;

  String get formattedAverageRating => averageRating.toStringAsFixed(1);

  double get ratingPercentage => (averageRating / 5.0) * 100;

  RatingStatistics copyWith({
    String? userId,
    String? userType,
    double? averageRating,
    int? totalRatings,
    Map<int, int>? ratingDistribution,
  }) {
    return RatingStatistics(
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
    );
  }
}
