import 'package:flutter/material.dart';

class JobOpportunity {
  final String id;
  final String title;
  final String description;
  final String employerName;
  final String location;
  final double salary;
  final String salaryPeriod; // 'hourly', 'daily', 'weekly', 'monthly'
  final DateTime postedDate;
  final List<String> requiredSkills;
  final String experienceLevel;
  final String jobType; // 'full-time', 'part-time', 'contract', 'live-in'
  final bool isUrgent;
  final int applicationsCount;

  JobOpportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.employerName,
    required this.location,
    required this.salary,
    required this.salaryPeriod,
    required this.postedDate,
    required this.requiredSkills,
    required this.experienceLevel,
    required this.jobType,
    this.isUrgent = false,
    this.applicationsCount = 0,
  });

  String formatSalary() {
    return '₱${salary.toStringAsFixed(0)}/$salaryPeriod';
  }

  String formatPostedDate() {
    final now = DateTime.now();
    final difference = now.difference(postedDate).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    return '${(difference / 7).floor()} weeks ago';
  }

  Color get jobTypeColor {
    switch (jobType) {
      case 'full-time':
        return const Color(0xFF10B981);
      case 'part-time':
        return const Color(0xFF3B82F6);
      case 'contract':
        return const Color(0xFF8B5CF6);
      case 'live-in':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String get jobTypeDisplayText {
    switch (jobType) {
      case 'full-time':
        return 'Full Time';
      case 'part-time':
        return 'Part Time';
      case 'contract':
        return 'Contract';
      case 'live-in':
        return 'Live-in';
      default:
        return jobType;
    }
  }

  bool get isRecentlyPosted => DateTime.now().difference(postedDate).inDays <= 3;
}
