import 'package:flutter/material.dart';
import '../../models/job_posting.dart';
import '../../models/helper_service.dart';
import '../../widgets/cards/job_posting_card.dart';
import '../../widgets/cards/helper_service_card.dart';
import '../../widgets/buttons/post_job_button.dart';
import '../../widgets/common/section_header.dart';

class EmployerHomeScreen extends StatelessWidget {
  const EmployerHomeScreen({super.key});

  void _onPostJob(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post Job functionality - Coming Soon'),
        backgroundColor: Color(0xFF1565C0),
      ),
    );
  }

  void _onJobTap(BuildContext context, JobPosting job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing job: ${job.title}'),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  void _onServiceTap(BuildContext context, HelperService service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Browse ${service.name} helpers - Coming Soon'),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobPostings = <JobPosting>[]; // Empty list - no mock data
    final services = <HelperService>[]; // Empty list - no mock data

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
                                'Find the perfect help',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF1565C0).withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Color(0xFF1565C0),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Post Job Button
              PostJobButton(
                onPressed: () => _onPostJob(context),
              ),

              const SizedBox(height: 32),

              // Recent Job Postings Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SectionHeader(
                  title: 'Recent Job Postings',
                  subtitle: 'Manage your active job listings',
                  onSeeAll: jobPostings.length > 3 ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('View All Jobs - Coming Soon'),
                        backgroundColor: Color(0xFF1565C0),
                      ),
                    );
                  } : null,
                ),
              ),

              const SizedBox(height: 16),

              // Job Postings List or Empty State
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: jobPostings.isEmpty
                    ? _buildEmptyJobsState()
                    : Column(
                        children: jobPostings.take(3).map((job) {
                          return JobPostingCard(
                            jobPosting: job,
                            onTap: () => _onJobTap(context, job),
                          );
                        }).toList(),
                      ),
              ),

              const SizedBox(height: 32),

              // Helper Services Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SectionHeader(
                  title: 'Available Services',
                  subtitle: 'Browse helpers by service type',
                  onSeeAll: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('View All Services - Coming Soon'),
                        backgroundColor: Color(0xFF1565C0),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Services Horizontal List or Empty State
              services.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildEmptyServicesState(),
                    )
                  : SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          return HelperServiceCard(
                            service: services[index],
                            onTap: () => _onServiceTap(context, services[index]),
                          );
                        },
                      ),
                    ),

              const SizedBox(height: 32),
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

  Widget _buildEmptyJobsState() {
    return Container(
      padding: const EdgeInsets.all(32),
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
              Icons.work_outline,
              size: 40,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Job Postings Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start by posting your first job to find the perfect helper',
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
              color: const Color(0xFF1565C0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.search_off,
              size: 40,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Services Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Helper services will be displayed here once they become available',
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
}
