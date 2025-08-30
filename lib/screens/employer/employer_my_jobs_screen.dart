import 'package:flutter/material.dart';
import '../../models/job_posting.dart';
import '../../widgets/cards/job_posting_card.dart';

class EmployerMyJobsScreen extends StatefulWidget {
  const EmployerMyJobsScreen({super.key});

  @override
  State<EmployerMyJobsScreen> createState() => _EmployerMyJobsScreenState();
}

class _EmployerMyJobsScreenState extends State<EmployerMyJobsScreen> {
  List<JobPosting> _jobPostings = [];

  void _onPostJob() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post Job functionality - Coming Soon'),
        backgroundColor: Color(0xFF1565C0),
      ),
    );
  }

  void _onJobTap(JobPosting job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing job: ${job.title}'),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.post_add,
                size: 60,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Job Postings Yet',
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
                'Start finding the perfect helpers by posting your first job. It only takes a few minutes!',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            // Post Job Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _onPostJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: const Color(0xFF1565C0).withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF1565C0),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Post Your First Job',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Benefits list
            Column(
              children: [
                _buildBenefitItem(Icons.search, 'Find qualified helpers quickly'),
                const SizedBox(height: 12),
                _buildBenefitItem(Icons.schedule, 'Set your own schedule'),
                const SizedBox(height: 12),
                _buildBenefitItem(Icons.verified_user, 'All helpers are verified'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF1565C0),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Post Job Button
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'My Jobs',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                  if (_jobPostings.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1565C0).withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: _onPostJob,
                        icon: const Icon(
                          Icons.add,
                          color: Color(0xFF1565C0),
                          size: 24,
                        ),
                        tooltip: 'Post New Job',
                      ),
                    ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _jobPostings.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _jobPostings.length,
                      itemBuilder: (context, index) {
                        return JobPostingCard(
                          jobPosting: _jobPostings[index],
                          onTap: () => _onJobTap(_jobPostings[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
