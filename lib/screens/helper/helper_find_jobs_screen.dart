import 'package:flutter/material.dart';
import '../../models/job_posting.dart';
import '../../models/helper.dart';
import '../../services/job_posting_service.dart';
import '../../services/application_service.dart';
import '../../services/session_service.dart';
import '../../utils/constants/barangay_constants.dart';
import '../../utils/constants/payment_frequency_constants.dart';
import '../../widgets/cards/job_card_with_rating.dart';
import 'apply_job_screen.dart';

class HelperFindJobsScreen extends StatefulWidget {
  const HelperFindJobsScreen({super.key});

  @override
  State<HelperFindJobsScreen> createState() => _HelperFindJobsScreenState();
}

class _HelperFindJobsScreenState extends State<HelperFindJobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<JobPosting> _allJobs = [];
  List<JobPosting> _filteredJobs = [];
  String _selectedLocation = 'All Locations';
  String _selectedPaymentFreq = 'All Frequencies';
  bool _isLoading = true;
  String? _errorMessage;
  Helper? _currentHelper;
  Set<String> _appliedJobIds = {};

  final List<String> _locations = [
    'All Locations',
    ...BarangayConstants.tagbilaranBarangays,
  ];

  final List<String> _paymentFrequencies = [
    'All Frequencies',
    ...PaymentFrequencyConstants.frequencies,
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentHelper();
    _loadJobs();
    _searchController.addListener(_filterJobs);
    
    // Add periodic refresh to keep job list updated
    Future.delayed(const Duration(seconds: 5), _startPeriodicRefresh);
  }

  void _startPeriodicRefresh() {
    if (!mounted) return;
    
    // Refresh jobs every 60 seconds to catch deleted jobs
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted) {
        _loadJobs();
        _startPeriodicRefresh();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentHelper() async {
    try {
      final helper = await SessionService.getCurrentHelper();
      if (helper != null) {
        setState(() {
          _currentHelper = helper;
        });
        
        // Load helper's applied jobs
        await _loadAppliedJobs();
      }
    } catch (e) {
      // Handle error silently
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

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final jobs = await JobPostingService.getActiveJobPostings();
      
      if (mounted) {
        setState(() {
          _allJobs = jobs;
          _filteredJobs = jobs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load jobs: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _filterJobs() {
    setState(() {
      _filteredJobs = _allJobs.where((job) {
        final matchesSearch = job.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                            job.description.toLowerCase().contains(_searchController.text.toLowerCase());
        
        final matchesLocation = _selectedLocation == 'All Locations' || job.barangay == _selectedLocation;
        final matchesPaymentFreq = _selectedPaymentFreq == 'All Frequencies' || job.paymentFrequency == _selectedPaymentFreq;
        
        return matchesSearch && matchesLocation && matchesPaymentFreq;
      }).toList();
    });
  }

  Future<void> _onJobTap(JobPosting job) async {
    if (_currentHelper == null) return;

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
          _buildFilterDropdown('Payment', _selectedPaymentFreq, _paymentFrequencies, (value) {
            setState(() {
              _selectedPaymentFreq = value!;
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF8A50),
        ),
      );
    }

    if (_errorMessage != null) {
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
                'Error Loading Jobs',
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
                onPressed: _loadJobs,
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

    if (_allJobs.isEmpty) {
      return _buildEmptyState();
    }

    if (_filteredJobs.isEmpty) {
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
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      color: const Color(0xFFFF8A50),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _filteredJobs.length,
        itemBuilder: (context, index) {
          final job = _filteredJobs[index];
          return JobCardWithRating(
            job: job,
            hasApplied: _appliedJobIds.contains(job.id),
            onTap: () => _onJobTap(job),
          );
        },
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
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }
}
