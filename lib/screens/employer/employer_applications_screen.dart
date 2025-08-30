import 'package:flutter/material.dart';
import '../../models/application.dart';
import '../../widgets/cards/application_card.dart';

class EmployerApplicationsScreen extends StatefulWidget {
  const EmployerApplicationsScreen({super.key});

  @override
  State<EmployerApplicationsScreen> createState() => _EmployerApplicationsScreenState();
}

class _EmployerApplicationsScreenState extends State<EmployerApplicationsScreen> {
  final List<Application> _applications = [];
  String _selectedFilter = 'all'; // 'all', 'pending', 'accepted', 'rejected'

  void _onApplicationTap(Application application) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing application from ${application.helperName}'),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  void _onStatusChange(Application application, String newStatus) {
    setState(() {
      final index = _applications.indexWhere((app) => app.id == application.id);
      if (index != -1) {
        // In a real app, this would be an API call
        _applications[index] = Application(
          id: application.id,
          jobId: application.jobId,
          jobTitle: application.jobTitle,
          helperId: application.helperId,
          helperName: application.helperName,
          helperProfileImage: application.helperProfileImage,
          helperLocation: application.helperLocation,
          helperRating: application.helperRating,
          helperReviewsCount: application.helperReviewsCount,
          coverLetter: application.coverLetter,
          appliedDate: application.appliedDate,
          status: newStatus,
          helperPhone: application.helperPhone,
          helperEmail: application.helperEmail,
          helperSkills: application.helperSkills,
          helperExperience: application.helperExperience,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Application ${newStatus == 'accepted' ? 'accepted' : 'rejected'}'),
        backgroundColor: newStatus == 'accepted' 
            ? const Color(0xFF4CAF50) 
            : const Color(0xFFF44336),
      ),
    );
  }

  List<Application> get _filteredApplications {
    if (_selectedFilter == 'all') return _applications;
    return _applications.where((app) => app.status == _selectedFilter).toList();
  }

  int get _pendingCount => _applications.where((app) => app.isPending).length;
  int get _acceptedCount => _applications.where((app) => app.isAccepted).length;
  int get _rejectedCount => _applications.where((app) => app.isRejected).length;

  Widget _buildFilterChip(String filter, String label, int count) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF1565C0) 
              : const Color(0xFF1565C0).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1565C0).withValues(alpha: isSelected ? 1.0 : 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1565C0),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFF1565C0).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF1565C0),
                  ),
                ),
              ),
            ],
          ],
        ),
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
                Icons.inbox_outlined,
                size: 60,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Applications Yet',
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
                'Once you post jobs, helper applications will appear here for you to review and manage.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            // Benefits list
            Column(
              children: [
                _buildBenefitItem(Icons.person_search, 'Review helper profiles and ratings'),
                const SizedBox(height: 12),
                _buildBenefitItem(Icons.chat_bubble_outline, 'Read cover letters and experience'),
                const SizedBox(height: 12),
                _buildBenefitItem(Icons.thumb_up_outlined, 'Accept or reject applications easily'),
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
    final filteredApplications = _filteredApplications;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Applications',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                  if (_applications.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1565C0).withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${_applications.length} Total',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Filter chips
            if (_applications.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('all', 'All', _applications.length),
                    const SizedBox(width: 12),
                    _buildFilterChip('pending', 'Pending', _pendingCount),
                    const SizedBox(width: 12),
                    _buildFilterChip('accepted', 'Accepted', _acceptedCount),
                    const SizedBox(width: 12),
                    _buildFilterChip('rejected', 'Rejected', _rejectedCount),
                  ],
                ),
              ),
            
            // Content
            Expanded(
              child: _applications.isEmpty
                  ? _buildEmptyState()
                  : filteredApplications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_list_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No $_selectedFilter applications',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          itemCount: filteredApplications.length,
                          itemBuilder: (context, index) {
                            return ApplicationCard(
                              application: filteredApplications[index],
                              onTap: () => _onApplicationTap(filteredApplications[index]),
                              onStatusChange: (status) => _onStatusChange(filteredApplications[index], status),
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
