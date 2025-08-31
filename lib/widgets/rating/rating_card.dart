import 'package:flutter/material.dart';
import '../../models/rating.dart';
import 'star_rating_display.dart';

class RatingCard extends StatelessWidget {
  final Rating rating;
  final String? raterName;
  final VoidCallback? onTap;
  final bool showRaterInfo;

  const RatingCard({
    super.key,
    required this.rating,
    this.raterName,
    this.onTap,
    this.showRaterInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showRaterInfo && !rating.isAnonymous) ...[
                          Text(
                            raterName ?? 'Unknown User',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        if (showRaterInfo && rating.isAnonymous) ...[
                          Text(
                            'Anonymous User',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        StarRatingDisplay(
                          rating: rating.rating.toDouble(),
                          showTotalRatings: false,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatDate(rating.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (rating.reviewText != null && rating.reviewText!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  rating.reviewText!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
}
