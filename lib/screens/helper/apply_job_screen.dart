import 'package:flutter/material.dart';
import '../../models/job_posting.dart';
import '../../models/helper.dart';
import '../../services/application_service.dart';
import '../../services/session_service.dart';
import '../../utils/constants/payment_frequency_constants.dart';

class ApplyJobScreen extends StatefulWidget {
  final JobPosting jobPosting;

  const ApplyJobScreen({
    super.key,
    required this.jobPosting,
  });

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  final _coverLetterController = TextEditingController();
  bool _isLoading = false;
  Helper? _currentHelper;
  String? _coverLetterError;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentHelper();
    _coverLetterController.addListener(_updateCharacterCount);
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _coverLetterController.text.length;
    });
  }

  @override
  void dispose() {
    _coverLetterController.removeListener(_updateCharacterCount);
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentHelper() async {
    try {
      final helper = await SessionService.getCurrentHelper();
      if (helper != null) {
        setState(() {
          _currentHelper = helper;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  bool _validateForm() {
    bool isValid = true;
    
    setState(() {
      _coverLetterError = null;

      if (_characterCount == 0) {
        _coverLetterError = 'Cover letter is required';
        isValid = false;
      } else if (_characterCount < 50) {
        _coverLetterError = 'Cover letter must be at least 50 characters';
        isValid = false;
      }
    });

    return isValid;
  }

  Future<void> _applyForJob() async {
    if (!_validateForm()) return;
    if (_currentHelper == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ApplicationService.applyForJob(
        jobPostingId: widget.jobPosting.id,
        helperId: _currentHelper!.id,
        coverLetter: _coverLetterController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit application: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildJobInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.jobPosting.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 16),

          // Location and salary
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                widget.jobPosting.barangay,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                '₱${widget.jobPosting.salary.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                PaymentFrequencyConstants.frequencyLabels[widget.jobPosting.paymentFrequency] ?? widget.jobPosting.paymentFrequency,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description
          const Text(
            'Job Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.jobPosting.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Required skills
          const Text(
            'Required Skills',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.jobPosting.requiredSkills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF8F00).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    color: Color(0xFFFF8F00),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Application',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell the employer why you\'re the perfect fit for this job.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          // Cover Letter
          const Text(
            'Cover Letter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _coverLetterError != null 
                  ? Colors.red.shade400 
                  : const Color(0xFFD1D5DB),
                width: 1,
              ),
              color: Colors.white,
            ),
            child: TextField(
              controller: _coverLetterController,
              maxLines: 8,
              maxLength: 500,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
                counterText: '', // Hide the built-in counter
                hintText: 'Explain your experience, skills, and why you\'re interested in this position. Include relevant achievements and what makes you stand out...',
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
              ),
            ),
          ),
          if (_coverLetterError != null) ...[
            const SizedBox(height: 8),
            Text(
              _coverLetterError!,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            '$_characterCount/500 characters (minimum 50)',
            style: TextStyle(
              fontSize: 12,
              color: _characterCount < 50 
                ? Colors.orange.shade600 
                : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFFF8F00),
          ),
        ),
        title: const Text(
          'Apply for Job',
          style: TextStyle(
            color: Color(0xFFFF8F00),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job information
              _buildJobInfo(),
              
              const SizedBox(height: 24),
              
              // Application form
              _buildApplicationForm(),
              
              const SizedBox(height: 32),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _applyForJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8F00),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: const Color(0xFFFF8F00).withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Application',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
