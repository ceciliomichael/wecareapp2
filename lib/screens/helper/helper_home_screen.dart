import 'package:flutter/material.dart';
import '../../models/job_opportunity.dart';
import '../../models/helper_service_posting.dart';
import '../../widgets/cards/job_opportunity_card.dart';
import '../../widgets/cards/helper_service_posting_card.dart';
import '../../widgets/buttons/post_service_button.dart';
import '../../widgets/common/section_header.dart';

class HelperHomeScreen extends StatelessWidget {
  const HelperHomeScreen({super.key});

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
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        'View Profile',
                        'Check your helper profile',
                        Icons.person_outline,
                        const Color(0xFF10B981),
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('View Profile - Coming Soon'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
    VoidCallback onTap,
  ) {
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
