import 'package:flutter/material.dart';
import '../../models/job_opportunity.dart';
import '../../models/helper_service_posting.dart';
import '../../services/subscription_service.dart';
import '../../services/messaging_service.dart';
import '../../widgets/cards/job_opportunity_card.dart';
import '../../widgets/cards/helper_service_posting_card.dart';
import '../../widgets/buttons/post_service_button.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/subscription/subscription_status_banner.dart';
import '../helper/helper_subscription_screen.dart';
import '../messaging/conversations_screen.dart';

class HelperHomeScreen extends StatefulWidget {
  const HelperHomeScreen({super.key});

  @override
  State<HelperHomeScreen> createState() => _HelperHomeScreenState();
}

class _HelperHomeScreenState extends State<HelperHomeScreen> {
  Map<String, dynamic>? _subscriptionStatus;
  int _unreadMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
    _loadUnreadMessageCount();
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
      final count = await MessagingService.getTotalUnreadCount();
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
        builder: (context) => const ConversationsScreen(),
      ),
    ).then((_) {
      // Refresh unread count when returning
      _loadUnreadMessageCount();
    });
  }

  void _onPostService(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post Service functionality - Coming Soon'),
        backgroundColor: Color(0xFFFF8A50),
      ),
    );
  }

  void _onJobTap(BuildContext context, JobOpportunity job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing job: ${job.title}'),
        backgroundColor: const Color(0xFFFF8A50),
      ),
    );
  }

  void _onApply(BuildContext context, JobOpportunity job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied to: ${job.title}'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _onServiceTap(BuildContext context, HelperServicePosting service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing service: ${service.title}'),
        backgroundColor: const Color(0xFFFF8A50),
      ),
    );
  }

  void _onEditService(BuildContext context, HelperServicePosting service) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit Service functionality - Coming Soon'),
        backgroundColor: Color(0xFFFF8A50),
      ),
    );
  }

  void _onServiceStatusChange(BuildContext context, HelperServicePosting service, String newStatus) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Service ${newStatus == 'active' ? 'activated' : 'paused'}'),
        backgroundColor: newStatus == 'active' 
            ? const Color(0xFF10B981) 
            : const Color(0xFFF59E0B),
      ),
    );
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
            'No Job Opportunities Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Job opportunities from employers will appear here when available',
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
    final jobOpportunities = <JobOpportunity>[]; // Empty list - no mock data
    final myServices = <HelperServicePosting>[]; // Empty list - no mock data

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
                        'Update Skills',
                        'Add new skills to your profile',
                        Icons.star_outline,
                        const Color(0xFF3B82F6),
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Update Skills - Coming Soon'),
                              backgroundColor: Color(0xFF3B82F6),
                            ),
                          );
                        },
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
                  title: 'Recent Job Opportunities',
                  subtitle: 'Find jobs that match your skills',
                  onSeeAll: jobOpportunities.length > 3 ? () {
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
                child: jobOpportunities.isEmpty
                    ? _buildEmptyJobsState()
                    : Column(
                        children: jobOpportunities.take(3).map((job) {
                          return JobOpportunityCard(
                            jobOpportunity: job,
                            onTap: () => _onJobTap(context, job),
                            onApply: () => _onApply(context, job),
                          );
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
                  onSeeAll: myServices.length > 2 ? () {
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
                child: myServices.isEmpty
                    ? _buildEmptyServicesState()
                    : Column(
                        children: myServices.take(2).map((service) {
                          return HelperServicePostingCard(
                            servicePosting: service,
                            onTap: () => _onServiceTap(context, service),
                            onEdit: () => _onEditService(context, service),
                            onStatusChange: (status) => _onServiceStatusChange(context, service, status),
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
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
