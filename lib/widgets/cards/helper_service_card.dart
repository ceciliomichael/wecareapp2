import 'package:flutter/material.dart';
import '../../models/helper_service.dart';

class HelperServiceCard extends StatelessWidget {
  final HelperService service;
  final VoidCallback? onTap;

  const HelperServiceCard({
    super.key,
    required this.service,
    this.onTap,
  });

  IconData _getIcon() {
    switch (service.iconName) {
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'restaurant':
        return Icons.restaurant;
      case 'child_care':
        return Icons.child_care;
      case 'elderly':
        return Icons.elderly;
      case 'directions_car':
        return Icons.directions_car;
      case 'handyman':
        return Icons.handyman;
      default:
        return Icons.help_outline;
    }
  }

  Color _getServiceColor() {
    switch (service.iconName) {
      case 'cleaning_services':
        return const Color(0xFF2196F3);
      case 'restaurant':
        return const Color(0xFFFF9800);
      case 'child_care':
        return const Color(0xFFE91E63);
      case 'elderly':
        return const Color(0xFF9C27B0);
      case 'directions_car':
        return const Color(0xFF4CAF50);
      case 'handyman':
        return const Color(0xFFFF5722);
      default:
        return const Color(0xFF607D8B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceColor = _getServiceColor();
    
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(16),
        shadowColor: serviceColor.withValues(alpha: 0.2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              border: Border.all(
                color: serviceColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: serviceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: serviceColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getIcon(),
                    size: 28,
                    color: serviceColor,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Service name
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                
                const SizedBox(height: 6),
                
                // Description
                Text(
                  service.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Rating row
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: Color(0xFFFFC107),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      service.averageRating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${service.availableHelpersCount}+',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Price range
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: serviceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service.priceRange,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: serviceColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
