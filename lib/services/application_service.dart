import '../models/application.dart';
import '../services/supabase_service.dart';

class ApplicationService {
  static const String _tableName = 'applications';

  /// Apply for a job
  static Future<Application> applyForJob({
    required String jobPostingId,
    required String helperId,
    required String coverLetter,
  }) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .insert({
            'job_posting_id': jobPostingId,
            'helper_id': helperId,
            'cover_letter': coverLetter,
            'status': 'pending',
          })
          .select()
          .single();

      return _mapToApplication(response);
    } catch (e) {
      throw Exception('Failed to apply for job: $e');
    }
  }

  /// Get applications for a specific job posting (for employers)
  static Future<List<Application>> getApplicationsForJob(String jobPostingId) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('''
            *,
            helpers (
              first_name,
              last_name,
              email,
              phone,
              skill,
              experience,
              barangay
            ),
            job_postings (
              title
            )
          ''')
          .eq('job_posting_id', jobPostingId)
          .order('applied_at', ascending: false);

      return (response as List)
          .map((data) => _mapToApplicationWithDetails(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch applications for job: $e');
    }
  }

  /// Get applications by helper (for helpers to see their applications)
  static Future<List<Application>> getApplicationsByHelper(String helperId) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('''
            *,
            job_postings (
              title,
              description,
              salary,
              payment_frequency,
              barangay,
              status
            )
          ''')
          .eq('helper_id', helperId)
          .order('applied_at', ascending: false);

      return (response as List)
          .map((data) => _mapToApplicationWithJobDetails(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch helper applications: $e');
    }
  }

  /// Update application status (for employers)
  static Future<Application> updateApplicationStatus(String applicationId, String status) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .update({'status': status})
          .eq('id', applicationId)
          .select('''
            *,
            helpers (
              first_name,
              last_name,
              email,
              phone,
              skill,
              experience,
              barangay
            ),
            job_postings (
              title
            )
          ''')
          .single();

      return _mapToApplicationWithDetails(response);
    } catch (e) {
      throw Exception('Failed to update application status: $e');
    }
  }

  /// Withdraw application (for helpers)
  static Future<Application> withdrawApplication(String applicationId) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .update({'status': 'withdrawn'})
          .eq('id', applicationId)
          .select('''
            *,
            job_postings (
              title,
              description,
              salary,
              payment_frequency,
              barangay,
              status
            )
          ''')
          .single();

      return _mapToApplicationWithJobDetails(response);
    } catch (e) {
      throw Exception('Failed to withdraw application: $e');
    }
  }

  /// Check if helper has already applied for a job
  static Future<bool> hasApplied(String jobPostingId, String helperId) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('id')
          .eq('job_posting_id', jobPostingId)
          .eq('helper_id', helperId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check application status: $e');
    }
  }

  /// Get application by ID
  static Future<Application> getApplicationById(String applicationId) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('''
            *,
            helpers (
              first_name,
              last_name,
              email,
              phone,
              skill,
              experience,
              barangay
            ),
            job_postings (
              title
            )
          ''')
          .eq('id', applicationId)
          .single();

      return _mapToApplicationWithDetails(response);
    } catch (e) {
      throw Exception('Failed to fetch application: $e');
    }
  }

  /// Get application count for a job posting
  static Future<int> getApplicationCount(String jobPostingId) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('id')
          .eq('job_posting_id', jobPostingId);

      return (response as List).length;
    } catch (e) {
      throw Exception('Failed to get application count: $e');
    }
  }

  // Helper methods to map database response to Application model
  static Application _mapToApplication(Map<String, dynamic> data) {
    return Application(
      id: data['id'] as String,
      jobId: data['job_posting_id'] as String,
      jobTitle: '', // Will be filled when needed
      helperId: data['helper_id'] as String,
      helperName: '', // Will be filled when needed
      helperLocation: '', // Will be filled when needed
      helperRating: 4.5, // Default rating - replace with actual rating system
      helperReviewsCount: 0, // Default - replace with actual review count
      coverLetter: data['cover_letter'] as String,
      appliedDate: DateTime.parse(data['applied_at'] as String),
      status: data['status'] as String,
      helperSkills: [], // Will be filled when needed
      helperExperience: '', // Will be filled when needed
    );
  }

  static Application _mapToApplicationWithDetails(Map<String, dynamic> data) {
    final helper = data['helpers'] as Map<String, dynamic>;
    final jobPosting = data['job_postings'] as Map<String, dynamic>;
    
    return Application(
      id: data['id'] as String,
      jobId: data['job_posting_id'] as String,
      jobTitle: jobPosting['title'] as String,
      helperId: data['helper_id'] as String,
      helperName: '${helper['first_name']} ${helper['last_name']}',
      helperEmail: helper['email'] as String?,
      helperPhone: helper['phone'] as String?,
      helperLocation: helper['barangay'] as String,
      helperRating: 4.5, // Default rating - replace with actual rating system
      helperReviewsCount: 0, // Default - replace with actual review count
      coverLetter: data['cover_letter'] as String,
      appliedDate: DateTime.parse(data['applied_at'] as String),
      status: data['status'] as String,
      helperSkills: [helper['skill'] as String], // For now, single skill
      helperExperience: helper['experience'] as String,
    );
  }

  static Application _mapToApplicationWithJobDetails(Map<String, dynamic> data) {
    final jobPosting = data['job_postings'] as Map<String, dynamic>;
    
    return Application(
      id: data['id'] as String,
      jobId: data['job_posting_id'] as String,
      jobTitle: jobPosting['title'] as String,
      helperId: data['helper_id'] as String,
      helperName: '', // Not needed for helper's own applications
      helperLocation: '', // Not needed for helper's own applications
      helperRating: 4.5, // Default rating
      helperReviewsCount: 0, // Default
      coverLetter: data['cover_letter'] as String,
      appliedDate: DateTime.parse(data['applied_at'] as String),
      status: data['status'] as String,
      helperSkills: [],
      helperExperience: '',
    );
  }
}
