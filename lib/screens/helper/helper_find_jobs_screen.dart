import 'package:flutter/material.dart';
import '../../models/job_opportunity.dart';
import '../../widgets/cards/job_opportunity_card.dart';

class HelperFindJobsScreen extends StatefulWidget {
  const HelperFindJobsScreen({super.key});

  @override
  State<HelperFindJobsScreen> createState() => _HelperFindJobsScreenState();
}

class _HelperFindJobsScreenState extends State<HelperFindJobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<JobOpportunity> _allJobs = [];
  List<JobOpportunity> _filteredJobs = [];
  String _selectedLocation = 'All Locations';
  String _selectedJobType = 'All Types';
  String _selectedSalaryRange = 'All Ranges';

  final List<String> _locations = [
    'All Locations',
    'Makati City',
    'BGC, Taguig',
    'Quezon City',
    'Manila',
    'Pasig',
    'Ortigas',
  ];

  final List<String> _jobTypes = [
    'All Types',
    'Full Time',
    'Part Time',
    'Contract',
    'Live-in',
  ];

  final List<String> _salaryRanges = [
    'All Ranges',
    '₱200-₱400/day',
    '₱400-₱600/day',
    '₱600-₱800/day',
    '₱800+/day',
  ];

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _searchController.addListener(_filterJobs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadJobs() {
    // In a real app, this would be an API call
    setState(() {
      _allJobs = [];  // Empty list - no mock data
      _filteredJobs = _allJobs;
    });
  }

  void _filterJobs() {
    setState(() {
      _filteredJobs = _allJobs.where((job) {
        final matchesSearch = job.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                            job.description.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                            job.employerName.toLowerCase().contains(_searchController.text.toLowerCase());
        
        final matchesLocation = _selectedLocation == 'All Locations' || job.location == _selectedLocation;
        final matchesJobType = _selectedJobType == 'All Types' || job.jobTypeDisplayText == _selectedJobType;
        
        bool matchesSalary = true;
        if (_selectedSalaryRange != 'All Ranges') {
          switch (_selectedSalaryRange) {
            case '₱200-₱400/day':
              matchesSalary = job.salary >= 200 && job.salary <= 400 && job.salaryPeriod == 'daily';
              break;
            case '₱400-₱600/day':
              matchesSalary = job.salary >= 400 && job.salary <= 600 && job.salaryPeriod == 'daily';
              break;
            case '₱600-₱800/day':
              matchesSalary = job.salary >= 600 && job.salary <= 800 && job.salaryPeriod == 'daily';
              break;
            case '₱800+/day':
              matchesSalary = job.salary >= 800 && job.salaryPeriod == 'daily';
              break;
          }
        }
        
        return matchesSearch && matchesLocation && matchesJobType && matchesSalary;
      }).toList();
    });
  }

  void _onJobTap(JobOpportunity job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing job: ${job.title}'),
        backgroundColor: const Color(0xFFFF8A50),
      ),
    );
  }

  void _onApply(JobOpportunity job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied to: ${job.title}'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search jobs, employers, or skills...',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFFF8A50)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF)),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterDropdown('Location', _selectedLocation, _locations, (value) {
            setState(() {
              _selectedLocation = value!;
              _filterJobs();
            });
          }),
          const SizedBox(width: 12),
          _buildFilterDropdown('Type', _selectedJobType, _jobTypes, (value) {
            setState(() {
              _selectedJobType = value!;
              _filterJobs();
            });
          }),
          const SizedBox(width: 12),
          _buildFilterDropdown('Salary', _selectedSalaryRange, _salaryRanges, (value) {
            setState(() {
              _selectedSalaryRange = value!;
              _filterJobs();
            });
          }),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: value.contains('All') 
            ? const Color(0xFFFF8A50).withValues(alpha: 0.1)
            : const Color(0xFFFF8A50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF8A50).withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item.contains('All') ? label : item,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: value.contains('All') 
                      ? const Color(0xFFFF8A50)
                      : Colors.white,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: value.contains('All') 
                ? const Color(0xFFFF8A50)
                : Colors.white,
            size: 18,
          ),
        ),
      ),
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
                        Icons.work_outline,
                        size: 60,
                        color: Color(0xFFFF8A50),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'No Jobs Available',
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
                        'New job opportunities will appear here when employers post them. Check back regularly!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        _buildTipItem(Icons.notifications_outlined, 'Enable notifications for new jobs'),
                        const SizedBox(height: 12),
                        _buildTipItem(Icons.star_outline, 'Complete your profile to match better'),
                        const SizedBox(height: 12),
                        _buildTipItem(Icons.refresh, 'Refresh regularly for new opportunities'),
                      ],
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

  Widget _buildTipItem(IconData icon, String text) {
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
                      'Find Jobs',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF8A50),
                      ),
                    ),
                  ),
                  if (_allJobs.isNotEmpty)
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
                        '${_filteredJobs.length} Jobs',
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

            // Search Bar
            _buildSearchBar(),

            const SizedBox(height: 16),

            // Filter Chips
            if (_allJobs.isNotEmpty) _buildFilterChips(),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _allJobs.isEmpty
                  ? _buildEmptyState()
                  : _filteredJobs.isEmpty
                      ? LayoutBuilder(
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
                                        Icon(
                                          Icons.search_off,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No jobs match your filters',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Try adjusting your search criteria',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _filteredJobs.length,
                          itemBuilder: (context, index) {
                            return JobOpportunityCard(
                              jobOpportunity: _filteredJobs[index],
                              onTap: () => _onJobTap(_filteredJobs[index]),
                              onApply: () => _onApply(_filteredJobs[index]),
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
