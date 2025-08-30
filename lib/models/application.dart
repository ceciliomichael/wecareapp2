import 'package:flutter/material.dart';

class Application {
  final String id;
  final String jobId;
  final String jobTitle;
  final String helperId;
  final String helperName;
  final String helperProfileImage;
  final String helperLocation;
  final double helperRating;
  final int helperReviewsCount;
  final String coverLetter;
  final DateTime appliedDate;
  final String status; // 'pending', 'accepted', 'rejected', 'withdrawn'
  final String? helperPhone;
  final String? helperEmail;
  final List<String> helperSkills;
  final String helperExperience;

  Application({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.helperId,
    required this.helperName,
    this.helperProfileImage = '',
    required this.helperLocation,
    required this.helperRating,
    required this.helperReviewsCount,
    required this.coverLetter,
    required this.appliedDate,
    required this.status,
    this.helperPhone,
    this.helperEmail,
    required this.helperSkills,
    required this.helperExperience,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isWithdrawn => status == 'withdrawn';

  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'accepted':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFF44336);
      case 'withdrawn':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String formatAppliedDate() {
    final now = DateTime.now();
    final difference = now.difference(appliedDate).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).floor()} weeks ago';
    return '${(difference / 30).floor()} months ago';
  }
}
