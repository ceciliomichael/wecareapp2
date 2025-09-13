import 'package:flutter/material.dart';
import '../../models/job_posting.dart';
import '../../models/helper.dart';
import '../../services/job_posting_service.dart';
import '../../services/application_service.dart';
import '../../services/session_service.dart';
import '../../services/saved_job_service.dart';
import '../../widgets/ui/job_tabs_widget.dart';
import '../../widgets/feature/recent_jobs_widget.dart';
import '../../widgets/feature/best_matches_widget.dart';
import '../../widgets/feature/saved_jobs_widget.dart';
import 'apply_job_screen.dart';

class HelperFindJobsScreen extends StatefulWidget {
  const HelperFindJobsScreen({super.key});

  @override
  State<HelperFindJobsScreen> createState() => _HelperFindJobsScreenState();
}

class _HelperFindJobsScreenState extends State<HelperFindJobsScreen> {
  int _selectedTab = 0;
  Helper? _currentHelper;
  Set<String> _appliedJobIds = {};
  Set<String> _savedJobIds = {};
  bool _isLoadingHelper = true;

  // Tab counts for display
  int _recentCount = 0;
  int _bestMatchesCount = 0;
  int _savedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentHelper();
    _loadTabCounts();
  }

  Future<void> _loadCurrentHelper() async {
    try {
      final helper = await SessionService.getCurrentHelper();
      if (helper != null && mounted) {
        setState(() {
          _currentHelper = helper;
        });
        
        // Load helper's applied jobs and saved jobs in parallel
        await Future.wait([
          _loadAppliedJobs(),
          _loadSavedJobs(),
        ]);
      }
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHelper = false;
        });
      }
    }
  }

  Future<void> _loadAppliedJobs() async {
    if (_currentHelper == null) return;
    
    try {
      final applications = await ApplicationService.getApplicationsByHelper(_currentHelper!.id);
      
      if (mounted) {
        setState(() {
          _appliedJobIds = applications.map((app) => app.jobId).toSet();
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadSavedJobs() async {
    if (_currentHelper == null) return;
    
    try {
      final savedJobIds = await SavedJobService.getSavedJobIds(_currentHelper!.id);
      
      if (mounted) {
        setState(() {
          _savedJobIds = savedJobIds;
          _savedCount = savedJobIds.length;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadTabCounts() async {
    try {
      // Load counts for tab indicators
      final results = await Future.wait([
        JobPostingService.getRecentJobPostings(limit: 50).then((jobs) => jobs.length),
        _currentHelper != null 
            ? JobPostingService.getBestMatchesForHelper(
                helperSkills: _currentHelper!.skill,
                helperBarangay: _currentHelper!.barangay,
                limit: 50,
              ).then((jobs) => jobs.length)
            : Future.value(0),
      ]);

      if (mounted) {
        setState(() {
          _recentCount = results[0];
          _bestMatchesCount = results[1];
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  Future<void> _onJobTap(JobPosting job) async {
    if (_currentHelper == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to apply for jobs'),
          backgroundColor: Color(0xFFFF9800),
        ),
      );
      return;
    }

    // Check if already applied
    try {
      final hasApplied = await ApplicationService.hasApplied(job.id, _currentHelper!.id);
      
      if (hasApplied && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already applied to this job'),
            backgroundColor: Color(0xFFFF9800),
          ),
        );
        return;
      }

      // Navigate to apply screen
      if (!mounted) return;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApplyJobScreen(jobPosting: job),
        ),
      );

      if (result == true && mounted) {
        // Application submitted successfully - add to applied jobs set
        setState(() {
          _appliedJobIds.add(job.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onSaveToggle(JobPosting job, bool shouldSave) async {
    if (_currentHelper == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to save jobs'),
          backgroundColor: Color(0xFFFF9800),
        ),
      );
      return;
    }

    try {
      if (shouldSave) {
        await SavedJobService.saveJob(
          helperId: _currentHelper!.id,
          jobPostingId: job.id,
        );
        
        setState(() {
          _savedJobIds.add(job.id);
          _savedCount = _savedJobIds.length;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved "${job.title}" to your bookmarks'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } else {
        await SavedJobService.unsaveJob(
          helperId: _currentHelper!.id,
          jobPostingId: job.id,
        );
        
        setState(() {
          _savedJobIds.remove(job.id);
          _savedCount = _savedJobIds.length;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed "${job.title}" from bookmarks'),
              backgroundColor: const Color(0xFF6B7280),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCurrentTab() {
    switch (_selectedTab) {
      case 0:
        return RecentJobsWidget(
          currentHelper: _currentHelper,
          onJobTap: _onJobTap,
          appliedJobIds: _appliedJobIds,
          savedJobIds: _savedJobIds,
          onSaveToggle: _onSaveToggle,
        );
      case 1:
        return BestMatchesWidget(
          currentHelper: _currentHelper,
          onJobTap: _onJobTap,
          appliedJobIds: _appliedJobIds,
          savedJobIds: _savedJobIds,
          onSaveToggle: _onSaveToggle,
        );
      case 2:
        return SavedJobsWidget(
          currentHelper: _currentHelper,
          onJobTap: _onJobTap,
          appliedJobIds: _appliedJobIds,
          onSaveToggle: _onSaveToggle,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Find Jobs',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8A50),
                  ),
                ),
              ),
              if (_currentHelper != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person,
                        size: 14,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_currentHelper!.firstName} ${_currentHelper!.lastName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (_currentHelper != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF8A50).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Color(0xFFFF8A50),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Location: ${_currentHelper!.barangay}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF8A50),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.work,
                    size: 16,
                    color: Color(0xFFFF8A50),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Skills: ${_currentHelper!.skill}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF8A50),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header with title and user info
            _buildHeader(),

            // Tab navigation
            JobTabsWidget(
              selectedTab: _selectedTab,
              onTabChanged: _onTabChanged,
              recentCount: _recentCount,
              bestMatchesCount: _bestMatchesCount,
              savedCount: _savedCount,
            ),

            const SizedBox(height: 16),

            // Tab content
            Expanded(
              child: _isLoadingHelper 
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF8A50),
                      ),
                    )
                  : _buildCurrentTab(),
            ),
          ],
        ),
      ),
    );
  }
}
