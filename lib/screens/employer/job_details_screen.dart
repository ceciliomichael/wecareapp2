import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/job_posting.dart';
import '../../models/application.dart';
import '../../services/job_posting_service.dart';
import '../../services/application_service.dart';
import '../../utils/constants/payment_frequency_constants.dart';
import '../../widgets/cards/application_card.dart';
import 'edit_job_screen.dart';
import 'application_details_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobPosting jobPosting;

  const JobDetailsScreen({
    super.key,
    required this.jobPosting,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late JobPosting _jobPosting;
  List<Application> _applications = [];
  bool _isLoadingApplications = true;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _jobPosting = widget.jobPosting;
    _loadApplications();
    
    // Refresh applications every 30 seconds when screen is visible
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadApplications();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoadingApplications = true;
    });

    try {
      final applications = await ApplicationService.getApplicationsForJob(_jobPosting.id);
      
      if (mounted) {
        setState(() {
          _applications = applications;
          _isLoadingApplications = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingApplications = false;
        });
      }
    }
  }

  Future<void> _editJob() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditJobScreen(jobPosting: _jobPosting),
      ),
    );

    if (result != null && result is JobPosting && mounted) {
      setState(() {
        _jobPosting = result;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job updated successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _updateJobStatus(String status) async {
    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final updatedJob = await JobPostingService.updateJobPostingStatus(_jobPosting.id, status);
      
      if (mounted) {
        setState(() {
          _jobPosting = updatedJob;
          _isUpdatingStatus = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job ${status == 'active' ? 'activated' : status}!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update job status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteJob() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job Posting'),
        content: const Text('Are you sure you want to delete this job posting? This action cannot be undone and all applications will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;

    if (!shouldDelete) return;

    try {
      await JobPostingService.deleteJobPosting(_jobPosting.id);
      
      if (mounted) {
        // Navigate back with deletion flag first
        Navigator.pop(context, 'deleted');
        // Show success message using the parent context
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posting deleted successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete job posting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onApplicationStatusChange(String applicationId, String newStatus) async {
    try {
      await ApplicationService.updateApplicationStatus(applicationId, newStatus);
      
      // Refresh applications list
      _loadApplications();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application $newStatus successfully'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update application: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  Color _getStatusColor() {
    switch (_jobPosting.status) {
      case 'active':
        return const Color(0xFF10B981);
      case 'paused':
        return const Color(0xFFFF9800);
      case 'closed':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusDisplayText() {
    switch (_jobPosting.status) {
      case 'active':
        return 'Active';
      case 'paused':
        return 'Paused';
      case 'closed':
        return 'Closed';
      default:
        return 'Unknown';
    }
  }

  Widget _buildJobInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and status
          Row(
            children: [
              Expanded(
                child: Text(
                  _jobPosting.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor().withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getStatusDisplayText(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Location and salary
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                _jobPosting.barangay,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                '₱${_jobPosting.salary.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                PaymentFrequencyConstants.frequencyLabels[_jobPosting.paymentFrequency] ?? _jobPosting.paymentFrequency,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description
          const Text(
            'Job Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _jobPosting.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Required skills
          const Text(
            'Required Skills',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _jobPosting.requiredSkills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Posted date
          Text(
            'Posted ${_formatDate(_jobPosting.createdAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Edit button
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _editJob,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit Job'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Status button
        Expanded(
          child: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteJob();
              } else {
                _updateJobStatus(value);
              }
            },
            enabled: !_isUpdatingStatus,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1565C0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isUpdatingStatus
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF1565C0),
                      ),
                    )
                  : Icon(
                      Icons.more_vert,
                      color: const Color(0xFF1565C0),
                    ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'active',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, color: Color(0xFF10B981), size: 18),
                    SizedBox(width: 8),
                    Text('Activate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'paused',
                child: Row(
                  children: [
                    Icon(Icons.pause, color: Color(0xFFFF9800), size: 18),
                    SizedBox(width: 8),
                    Text('Pause'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'closed',
                child: Row(
                  children: [
                    Icon(Icons.stop, color: Color(0xFFF44336), size: 18),
                    SizedBox(width: 8),
                    Text('Close'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Applications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_applications.length} Applications',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_isLoadingApplications)
          const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF1565C0),
            ),
          )
        else if (_applications.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    size: 40,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Applications Yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'When helpers apply to your job, their applications will appear here.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: _applications.map((application) {
              return ApplicationCard(
                application: application,
                onTap: () async {
                  // Navigate to application details screen
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplicationDetailsScreen(application: application),
                    ),
                  );
                  
                  // If application was updated, refresh the list
                  if (result != null) {
                    _loadApplications();
                  }
                },
                onStatusChange: (status) => _onApplicationStatusChange(application.id, status),
              );
            }).toList(),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'today';
    if (difference == 1) return 'yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).floor()} weeks ago';
    return '${(difference / 30).floor()} months ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1565C0),
          ),
        ),
        title: const Text(
          'Job Details',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job information
              _buildJobInfo(),
              
              const SizedBox(height: 24),
              
              // Action buttons
              _buildActionButtons(),
              
              const SizedBox(height: 32),
              
              // Applications section
              _buildApplicationsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
