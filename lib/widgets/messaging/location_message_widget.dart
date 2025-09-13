import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/message.dart';
import '../../services/location_service.dart';

class LocationMessageWidget extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;

  const LocationMessageWidget({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    if (!message.hasValidLocation) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser 
              ? const Color(0xFF1565C0).withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Invalid location data',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? const Color(0xFF1565C0).withValues(alpha: 0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser 
              ? const Color(0xFF1565C0).withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map preview placeholder
          _buildMapPreview(),
          
          // Location details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location icon and title
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: const Color(0xFFE53E3E),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Live Location',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCurrentUser 
                              ? const Color(0xFF1565C0)
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Address
                if (message.address != null && message.address!.isNotEmpty) ...[
                  Text(
                    message.address!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Coordinates
                Text(
                  '${message.latitude!.toStringAsFixed(6)}, ${message.longitude!.toStringAsFixed(6)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.map,
                        label: 'Open Maps',
                        onTap: () => _openInMaps(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.share,
                        label: 'Share',
                        onTap: () => _shareLocation(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          // Static map preview (simplified representation)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  const Color(0xFF2196F3).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: CustomPaint(
              painter: _MapGridPainter(),
            ),
          ),
          
          // Location pin in center
          Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          // Top-right corner info
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Live',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentUser 
              ? const Color(0xFF1565C0).withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentUser 
                ? const Color(0xFF1565C0).withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isCurrentUser 
                  ? const Color(0xFF1565C0)
                  : Colors.grey[700],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isCurrentUser 
                    ? const Color(0xFF1565C0)
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInMaps(BuildContext context) async {
    try {
      final googleMapsUrl = LocationService.getGoogleMapsUrl(
        message.latitude!,
        message.longitude!,
      );
      
      final appleMapsUrl = LocationService.getAppleMapsUrl(
        message.latitude!,
        message.longitude!,
      );

      // Show dialog to choose maps app
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Open in Maps'),
          content: const Text('Choose your preferred maps application:'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final uri = Uri.parse(googleMapsUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    _showError(context, 'Could not open Google Maps');
                  }
                }
              },
              child: const Text('Google Maps'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final uri = Uri.parse(appleMapsUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    _showError(context, 'Could not open Apple Maps');
                  }
                }
              },
              child: const Text('Apple Maps'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error opening maps: $e');
      }
    }
  }

  Future<void> _shareLocation(BuildContext context) async {
    try {
      final googleMapsUrl = LocationService.getGoogleMapsUrl(
        message.latitude!,
        message.longitude!,
      );
      
      // For now, we'll just copy to clipboard (you can integrate with share_plus package later)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location: $googleMapsUrl'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      _showError(context, 'Error sharing location: $e');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Custom painter for map grid background
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    // Draw grid lines
    const spacing = 20.0;
    
    // Vertical lines
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Horizontal lines
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
