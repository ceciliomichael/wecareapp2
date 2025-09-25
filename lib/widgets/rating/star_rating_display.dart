import 'package:flutter/material.dart';

class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final int totalRatings;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool showRatingText;
  final bool showTotalRatings;
  final MainAxisSize mainAxisSize;
  final bool isCompact;
  final bool showBackground;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.totalRatings = 0,
    this.size = 16.0,
    this.activeColor = const Color(0xFFFFB800),
    this.inactiveColor = const Color(0xFFE0E7FF),
    this.showRatingText = true,
    this.showTotalRatings = true,
    this.mainAxisSize = MainAxisSize.min,
    this.isCompact = false,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget ratingContent = Row(
      mainAxisSize: mainAxisSize,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starRating = rating - index;

            Widget starIcon;
            if (starRating >= 1.0) {
              // Full star
              starIcon = Icon(
                Icons.star,
                size: size,
                color: activeColor,
              );
            } else if (starRating >= 0.5) {
              // Half star
              starIcon = Icon(
                Icons.star_half,
                size: size,
                color: activeColor,
              );
            } else {
              // Empty star
              starIcon = Icon(
                Icons.star_border,
                size: size,
                color: inactiveColor,
              );
            }

            return starIcon;
          }),
        ),
        if (showRatingText && rating > 0) ...[
          SizedBox(width: isCompact ? 4 : 8),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isCompact ? 12 : null,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
        if (showTotalRatings && totalRatings > 0) ...[
          SizedBox(width: isCompact ? 2 : 4),
          Text(
            '($totalRatings ${totalRatings == 1 ? 'review' : 'reviews'})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontSize: isCompact ? 10 : 12,
            ),
          ),
        ],
      ],
    );

    // Add background if requested
    if (showBackground) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ratingContent,
      );
    }

    return ratingContent;
  }

  // Helper method to get rating color based on value
  static Color getRatingColor(double rating) {
    if (rating >= 4.5) return const Color(0xFF10B981); // Green
    if (rating >= 4.0) return const Color(0xFFFFB800); // Yellow
    if (rating >= 3.0) return const Color(0xFFF59E0B); // Orange
    return const Color(0xFFEF4444); // Red
  }

  // Helper method to get rating text
  static String getRatingDescription(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Very Good';
    if (rating >= 3.0) return 'Good';
    if (rating >= 2.0) return 'Fair';
    return 'Poor';
  }
}
