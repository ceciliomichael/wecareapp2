import 'package:flutter/material.dart';

class StarRatingInput extends StatefulWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool enabled;
  final String? label;

  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 32.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.enabled = true,
    this.label,
  });

  @override
  State<StarRatingInput> createState() => _StarRatingInputState();
}

class _StarRatingInputState extends State<StarRatingInput> {
  int _hoveredStar = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isActive = starIndex <= (_hoveredStar > 0 ? _hoveredStar : widget.rating);

            return GestureDetector(
              onTap: widget.enabled
                  ? () => widget.onRatingChanged(starIndex)
                  : null,
              child: MouseRegion(
                onEnter: widget.enabled
                    ? (_) => setState(() => _hoveredStar = starIndex)
                    : null,
                onExit: widget.enabled
                    ? (_) => setState(() => _hoveredStar = 0)
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isActive ? Icons.star : Icons.star_border,
                    size: widget.size,
                    color: isActive ? widget.activeColor : widget.inactiveColor,
                  ),
                ),
              ),
            );
          }),
        ),
        if (widget.rating > 0) ...[
          const SizedBox(height: 4),
          Text(
            _getRatingText(widget.rating),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
