import 'package:flutter/material.dart';
import '../../models/usage_tracking.dart';

class TrialStatusCard extends StatelessWidget {
  final UsageTracking usage;
  final String userType;

  const TrialStatusCard({
    super.key,
    required this.usage,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final isNearLimit = usage.remainingTrialUses <= 2;
    final isAtLimit = usage.hasExceededTrial;
    
    Color statusColor;
    Color backgroundColor;
    IconData statusIcon;
    String statusText;

    if (isAtLimit) {
      statusColor = Colors.red[600]!;
      backgroundColor = Colors.red[50]!;
      statusIcon = Icons.warning;
      statusText = 'Trial Expired';
    } else if (isNearLimit) {
      statusColor = Colors.orange[600]!;
      backgroundColor = Colors.orange[50]!;
      statusIcon = Icons.access_time;
      statusText = 'Trial Ending Soon';
    } else {
      statusColor = Colors.blue[600]!;
      backgroundColor = Colors.blue[50]!;
      statusIcon = Icons.rocket_launch;
      statusText = 'Trial Active';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trial Usage',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '${usage.usageCount} / ${usage.trialLimit}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: usage.trialUsagePercentage,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Status message
          if (isAtLimit)
            Text(
              'Your trial has ended. Subscribe now to continue using WeCare.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            )
          else
            Text(
              'You have ${usage.remainingTrialUses} free ${usage.remainingTrialUses == 1 ? 'use' : 'uses'} remaining. Subscribe for unlimited access.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }
}
