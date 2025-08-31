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

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.totalRatings = 0,
    this.size = 16.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.showRatingText = true,
    this.showTotalRatings = true,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (showTotalRatings && totalRatings > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($totalRatings)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}
