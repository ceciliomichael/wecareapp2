import 'package:flutter/material.dart';
import '../../models/job_posting.dart';
import '../../models/helper_service_posting.dart';
import '../../models/helper.dart';
import '../../services/subscription_service.dart';
import '../../services/database_messaging_service.dart';
import '../../services/job_posting_service.dart';
import '../../services/helper_service_posting_service.dart';
import '../../services/session_service.dart';
import '../../widgets/cards/helper_service_posting_card.dart';
import '../../widgets/buttons/post_service_button.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/subscription/subscription_status_banner.dart';
import '../helper/helper_subscription_screen.dart';
import '../helper/apply_job_screen.dart';
import '../helper/post_service_screen.dart';
import '../helper/edit_service_screen.dart';
import '../messaging/conversations_screen.dart';
import '../shared/completed_jobs_screen.dart';

class HelperHomeScreen extends StatefulWidget {
  const HelperHomeScreen({super.key});

  @override
  State<HelperHomeScreen> createState() => _HelperHomeScreenState();
}

class _HelperHomeScreenState extends State<HelperHomeScreen> {
  Map<String, dynamic>? _subscriptionStatus;
  int _unreadMessageCount = 0;
  Helper? _currentHelper;
  List<JobPosting> _matchedJobs = [];
  List<HelperServicePosting> _myServices = [];
  bool _isLoadingJobs = true;
  bool _isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentHelper();
    _loadSubscriptionStatus();
    _loadUnreadMessageCount();
    _loadMatchedJobs(); // Load all job opportunities
  }

  Future<void> _loadCurrentHelper() async {
    try {
      final helper = await SessionService.getCurrentHelper();
      if (helper != null && mounted) {
        setState(() {
          _currentHelper = helper;
        });
        _loadMyServices();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadMatchedJobs() async {
    setState(() {
      _isLoadingJobs = true;
    });

    try {
      final allJobs = await JobPostingService.getActiveJobPostings();
      
      // Take only the first 2 jobs for the home screen
      final jobs = allJobs.take(2).toList();
      
      if (mounted) {
        setState(() {
          _matchedJobs = jobs;
          _isLoadingJobs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingJobs = false;
        });
      }
    }
  }

  Future<void> _loadMyServices() async {
    if (_currentHelper == null) return;
    
    setState(() {
      _isLoadingServices = true;
    });

    try {
      final services = await HelperServicePostingService.getServicePostingsByHelper(_currentHelper!.id);
      
      if (mounted) {
        setState(() {
          _myServices = services;
          _isLoadingServices = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingServices = false;
        });
      }
    }
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final status = await SubscriptionService.getCurrentUserSubscriptionStatus();
      if (mounted) {
        setState(() {
          _subscriptionStatus = status;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadUnreadMessageCount() async {
    try {
      final count = await DatabaseMessagingService.getTotalUnreadCount();
      if (mounted) {
        setState(() {
          _unreadMessageCount = count;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _onSubscriptionTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelperSubscriptionScreen(),
      ),
    );
  }

  void _onMessagesTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/conversations'),
        builder: (context) => const ConversationsScreen(),
      ),
    ).then((_) {
      // Refresh unread count when returning
      _loadUnreadMessageCount();
    });
    
    // Also schedule a short delayed refresh to catch async updates
    Future.delayed(const Duration(milliseconds: 400), _loadUnreadMessageCount);
  }

  void _onCompletedJobsTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CompletedJobsScreen(),
      ),
    );
  }

  void _onPostService(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PostServiceScreen(),
      ),
    ).then((_) {
      // Refresh services when returning
      _loadMyServices();
    });
  }

  Future<void> _onJobTap(BuildContext context, JobPosting job) async {
    if (_currentHelper == null) return;

    // Navigate to apply screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplyJobScreen(jobPosting: job),
      ),
    );

    if (result == true) {
      if (mounted) {
        // Application submitted successfully
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        
        // Refresh matched jobs
        _loadMatchedJobs();
      }
    }
  }

  void _onServiceTap(BuildContext context, HelperServicePosting service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing service: ${service.title}'),
        backgroundColor: const Color(0xFFFF8A50),
      ),
    );
  }

  void _onEditService(BuildContext context, HelperServicePosting service) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditServiceScreen(servicePosting: service),
      ),
    );

    // Always refresh the services list when returning from edit screen
    // This handles updates, deletions, and status changes
    _loadMyServices();

    if (result == 'deleted') {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(
            content: Text('Service deleted successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    }
  }



  Widget _buildEmptyJobsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.work_outline,
              size: 40,
              color: Color(0xFFFF8A50),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Job Opportunities Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new job postings from employers',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyServicesState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 40,
              color: Color(0xFFFF8A50),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Services Posted Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start offering your services to employers by posting your first service above',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good ${_getGreeting()}!',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Ready to help today?',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF8A50),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8A50).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFF8A50).withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Color(0xFFFF8A50),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Subscription Status Banner
              if (_subscriptionStatus != null)
                SubscriptionStatusBanner(
                  subscriptionStatus: _subscriptionStatus!,
                  onTap: _onSubscriptionTap,
                ),

              // Quick Actions Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SectionHeader(
                  title: 'Quick Actions',
                  subtitle: 'Manage your helper profile',
                ),
              ),

              const SizedBox(height: 16),

              // Quick Action Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        'Messages',
                        'Chat with employers',
                        Icons.chat_bubble_outline,
                        const Color(0xFFFF8A50),
                        _onMessagesTap,
                        badgeCount: _unreadMessageCount,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        'Completed Jobs',
                        'Rate your past experiences',
                        Icons.history_outlined,
                        const Color(0xFF10B981),
                        _onCompletedJobsTap,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Post Service Button
              PostServiceButton(
                onPressed: () => _onPostService(context),
              ),

              const SizedBox(height: 32),

              // Recent Job Opportunities Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SectionHeader(
                  title: 'Latest Job Opportunities',
                  subtitle: 'Explore all available job postings',
                  onSeeAll: _matchedJobs.isNotEmpty ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('View All Jobs - Coming Soon'),
                        backgroundColor: Color(0xFFFF8A50),
                      ),
                    );
                  } : null,
                ),
              ),

              const SizedBox(height: 16),

              // Job Opportunities List or Empty State
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _isLoadingJobs
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF8A50),
                          ),
                        ),
                      )
                    : _matchedJobs.isEmpty
                        ? _buildEmptyJobsState()
                        : Column(
                            children: _matchedJobs.map((job) {
                              return _buildJobCard(job);
                            }).toList(),
                          ),
              ),

              const SizedBox(height: 32),

              // My Posted Services Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SectionHeader(
                  title: 'My Posted Services',
                  subtitle: 'Manage your service offerings',
                  onSeeAll: _myServices.length > 2 ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('View All Services - Coming Soon'),
                        backgroundColor: Color(0xFFFF8A50),
                      ),
                    );
                  } : null,
                ),
              ),

              const SizedBox(height: 16),

              // My Services List or Empty State
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _isLoadingServices
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF8A50),
                          ),
                        ),
                      )
                    : _myServices.isEmpty
                        ? _buildEmptyServicesState()
                        : Column(
                            children: _myServices.take(2).map((service) {
                              return HelperServicePostingCard(
                                servicePosting: service,
                                onTap: () => _onServiceTap(context, service),
                                onEdit: () => _onEditService(context, service),
                              );
                            }).toList(),
                          ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(JobPosting job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        shadowColor: const Color(0xFFFF8A50).withValues(alpha: 0.1),
        child: InkWell(
          onTap: () => _onJobTap(context, job),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and salary
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Text(
                      '₱${job.salary.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Payment frequency and location
                Row(
                  children: [
                    Text(
                      job.paymentFrequency,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.barangay,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  job.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Required skills
                if (job.requiredSkills.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: job.requiredSkills.take(3).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF8A50),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Apply button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => _onJobTap(context, job),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    int? badgeCount,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      shadowColor: color.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: color,
                    ),
                  ),
                  if (badgeCount != null && badgeCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}
