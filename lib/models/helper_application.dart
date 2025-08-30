import 'package:flutter/material.dart';

class HelperApplication {
  final String id;
  final String jobId;
  final String jobTitle;
  final String employerName;
  final String jobLocation;
  final double jobSalary;
  final String jobSalaryPeriod;
  final String coverLetter;
  final DateTime appliedDate;
  final String status; // 'pending', 'accepted', 'rejected', 'withdrawn'
  final DateTime? responseDate;
  final String? employerMessage;
  final List<String> requiredSkills;

  HelperApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.employerName,
    required this.jobLocation,
    required this.jobSalary,
    required this.jobSalaryPeriod,
    required this.coverLetter,
    required this.appliedDate,
    required this.status,
    this.responseDate,
    this.employerMessage,
    required this.requiredSkills,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isWithdrawn => status == 'withdrawn';

  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Under Review';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Not Selected';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF8A50);
      case 'accepted':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFF44336);
      case 'withdrawn':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'withdrawn':
        return Icons.remove_circle;
      default:
        return Icons.help;
    }
  }

  String formatAppliedDate() {
    final now = DateTime.now();
    final difference = now.difference(appliedDate).inDays;
    
    if (difference == 0) return 'Applied today';
    if (difference == 1) return 'Applied yesterday';
    if (difference < 7) return 'Applied $difference days ago';
    if (difference < 30) return 'Applied ${(difference / 7).floor()} weeks ago';
    return 'Applied ${(difference / 30).floor()} months ago';
  }

  String formatResponseDate() {
    if (responseDate == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(responseDate!).inDays;
    
    if (difference == 0) return 'Response today';
    if (difference == 1) return 'Response yesterday';
    if (difference < 7) return 'Response $difference days ago';
    return 'Response ${(difference / 7).floor()} weeks ago';
  }

  String formatSalary() {
    return '₱${jobSalary.toStringAsFixed(0)}/$jobSalaryPeriod';
  }

  bool get hasEmployerMessage => employerMessage != null && employerMessage!.isNotEmpty;
}
