import 'package:flutter/material.dart';
import '../../models/helper_application.dart';
import '../../widgets/cards/helper_application_card.dart';

class HelperMyApplicationsScreen extends StatefulWidget {
  const HelperMyApplicationsScreen({super.key});

  @override
  State<HelperMyApplicationsScreen> createState() => _HelperMyApplicationsScreenState();
}

class _HelperMyApplicationsScreenState extends State<HelperMyApplicationsScreen> {
  final List<HelperApplication> _applications = [];
  String _selectedFilter = 'all'; // 'all', 'pending', 'accepted', 'rejected'

  void _onApplicationTap(HelperApplication application) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing application for: ${application.jobTitle}'),
        backgroundColor: const Color(0xFFFF8A50),
      ),
    );
  }

  void _onWithdrawApplication(HelperApplication application) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Withdraw Application'),
          content: Text('Are you sure you want to withdraw your application for "${application.jobTitle}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  final index = _applications.indexWhere((app) => app.id == application.id);
                  if (index != -1) {
                    _applications[index] = HelperApplication(
                      id: application.id,
                      jobId: application.jobId,
                      jobTitle: application.jobTitle,
                      employerName: application.employerName,
                      jobLocation: application.jobLocation,
                      jobSalary: application.jobSalary,
                      jobSalaryPeriod: application.jobSalaryPeriod,
                      coverLetter: application.coverLetter,
                      appliedDate: application.appliedDate,
                      status: 'withdrawn',
                      responseDate: DateTime.now(),
                      employerMessage: application.employerMessage,
                      requiredSkills: application.requiredSkills,
                    );
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application withdrawn successfully'),
                    backgroundColor: Color(0xFF6B7280),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFF44336)),
              child: const Text('Withdraw'),
            ),
          ],
        );
      },
    );
  }

  List<HelperApplication> get _filteredApplications {
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
              ? const Color(0xFFFF8A50) 
              : const Color(0xFFFF8A50).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFF8A50).withValues(alpha: isSelected ? 1.0 : 0.3),
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
                color: isSelected ? Colors.white : const Color(0xFFFF8A50),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFFFF8A50).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFFFF8A50),
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
                color: const Color(0xFFFF8A50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFFF8A50).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 60,
                color: Color(0xFFFF8A50),
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
                'Start applying to job opportunities to track your application status here.',
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
                _buildBenefitItem(Icons.schedule, 'Track application status in real-time'),
                const SizedBox(height: 12),
                _buildBenefitItem(Icons.message_outlined, 'Receive messages from employers'),
                const SizedBox(height: 12),
                _buildBenefitItem(Icons.history, 'View your application history'),
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
          color: const Color(0xFFFF8A50),
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
                      'My Applications',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF8A50),
                      ),
                    ),
                  ),
                  if (_applications.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8A50).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFF8A50).withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${_applications.length} Total',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8A50),
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
                    _buildFilterChip('pending', 'Under Review', _pendingCount),
                    const SizedBox(width: 12),
                    _buildFilterChip('accepted', 'Accepted', _acceptedCount),
                    const SizedBox(width: 12),
                    _buildFilterChip('rejected', 'Not Selected', _rejectedCount),
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
                            return HelperApplicationCard(
                              application: filteredApplications[index],
                              onTap: () => _onApplicationTap(filteredApplications[index]),
                              onWithdraw: filteredApplications[index].isPending 
                                  ? () => _onWithdrawApplication(filteredApplications[index])
                                  : null,
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
