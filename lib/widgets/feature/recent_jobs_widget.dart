import 'package:flutter/material.dart';
import '../../models/job_posting.dart';
import '../../models/helper.dart';
import '../../services/job_posting_service.dart';
import '../cards/job_card_with_rating.dart';

class RecentJobsWidget extends StatefulWidget {
  final Helper? currentHelper;
  final Function(JobPosting) onJobTap;
  final Set<String> appliedJobIds;
  final Set<String> savedJobIds;
  final Function(JobPosting, bool) onSaveToggle;

  const RecentJobsWidget({
    super.key,
    required this.currentHelper,
    required this.onJobTap,
    required this.appliedJobIds,
    required this.savedJobIds,
    required this.onSaveToggle,
  });

  @override
  State<RecentJobsWidget> createState() => _RecentJobsWidgetState();
}

class _RecentJobsWidgetState extends State<RecentJobsWidget> {
  List<JobPosting> _recentJobs = [];
  List<JobPosting> _todaysJobs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecentJobs();
  }

  Future<void> _loadRecentJobs() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load both recent jobs and today's jobs in parallel
      final results = await Future.wait([
        JobPostingService.getRecentJobPostings(limit: 20),
        JobPostingService.getTodaysJobPostings(),
      ]);

      if (mounted) {
        setState(() {
          _recentJobs = results[0];
          _todaysJobs = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load recent jobs: $e';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTodaysJobsSection() {
    if (_todaysJobs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.today,
                  size: 16,
                  color: Color(0xFFFF8A50),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Posted Today',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF8A50).withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  '${_todaysJobs.length} new',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF8A50),
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _todaysJobs.length,
          itemBuilder: (context, index) {
            final job = _todaysJobs[index];
            return JobCardWithRating(
              job: job,
              hasApplied: widget.appliedJobIds.contains(job.id),
              isSaved: widget.savedJobIds.contains(job.id),
              onTap: () => widget.onJobTap(job),
              onSaveToggle: (isSaved) => widget.onSaveToggle(job, isSaved),
            );
          },
        ),
        if (_recentJobs.length > _todaysJobs.length) ...[
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: Color(0xFFE5E7EB)),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildRecentJobsSection() {
    // Filter out today's jobs from recent jobs to avoid duplicates
    final otherRecentJobs = _recentJobs
        .where((job) => !_todaysJobs.any((todayJob) => todayJob.id == job.id))
        .toList();

    if (otherRecentJobs.isEmpty && _todaysJobs.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (otherRecentJobs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B7280).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Recent Jobs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: otherRecentJobs.length,
            itemBuilder: (context, index) {
              final job = otherRecentJobs[index];
              return JobCardWithRating(
                job: job,
                hasApplied: widget.appliedJobIds.contains(job.id),
                isSaved: widget.savedJobIds.contains(job.id),
                onTap: () => widget.onJobTap(job),
                onSaveToggle: (isSaved) => widget.onSaveToggle(job, isSaved),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8A50).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFFF8A50).withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.schedule,
                        size: 60,
                        color: Color(0xFFFF8A50),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'No Recent Jobs',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'New job opportunities will appear here when employers post them. Check back regularly for fresh opportunities!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _loadRecentJobs,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8A50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error Loading Recent Jobs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadRecentJobs,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF8A50),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _loadRecentJobs,
      color: const Color(0xFFFF8A50),
      child: ListView(
        children: [
          _buildTodaysJobsSection(),
          _buildRecentJobsSection(),
          const SizedBox(height: 24), // Bottom padding
        ],
      ),
    );
  }
}
