import '../models/job_posting.dart';
import '../services/supabase_service.dart';

class JobPostingService {
  static const String _tableName = 'job_postings';

  /// Create a new job posting
  static Future<JobPosting> createJobPosting({
    required String employerId,
    required String title,
    required String description,
    required double salary,
    required String paymentFrequency,
    required String barangay,
    required List<String> requiredSkills,
  }) async {
    try {
      final jobPosting = JobPosting(
        id: '',
        employerId: employerId,
        title: title,
        description: description,
        barangay: barangay,
        salary: salary,
        paymentFrequency: paymentFrequency,
        requiredSkills: requiredSkills,
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await SupabaseService.client
          .from(_tableName)
          .insert(jobPosting.toInsertMap())
          .select()
          .single();

      return JobPosting.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create job posting: $e');
    }
  }

  /// Get all job postings for a specific employer
  static Future<List<JobPosting>> getJobPostingsByEmployer(String employerId) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('employer_id', employerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => JobPosting.fromMap(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch job postings: $e');
    }
  }

  /// Get all active job postings
  static Future<List<JobPosting>> getActiveJobPostings() async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => JobPosting.fromMap(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active job postings: $e');
    }
  }

  /// Get job postings that match helper's skills and location
  static Future<List<JobPosting>> getMatchedJobsForHelper({
    required String helperSkills,
    required String helperBarangay,
    int limit = 2,
  }) async {
    try {
      // Convert helper skills string to list
      final skillsList = helperSkills
          .split(',')
          .map((skill) => skill.trim().toLowerCase())
          .where((skill) => skill.isNotEmpty)
          .toList();

      if (skillsList.isEmpty) {
        // If no skills, just return recent jobs in same barangay
        final response = await SupabaseService.client
            .from(_tableName)
            .select()
            .eq('status', 'active')
            .eq('barangay', helperBarangay)
            .order('created_at', ascending: false)
            .limit(limit);

        return (response as List)
            .map((data) => JobPosting.fromMap(data))
            .toList();
      }

      // Get all active jobs
      final allJobsResponse = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false);

      final allJobs = (allJobsResponse as List)
          .map((data) => JobPosting.fromMap(data))
          .toList();

      // Filter and score jobs based on skill matching
      final List<MapEntry<JobPosting, int>> scoredJobs = [];

      for (final job in allJobs) {
        int matchScore = 0;

        // Check skill matches
        for (final requiredSkill in job.requiredSkills) {
          final normalizedRequired = requiredSkill.toLowerCase().trim();
          for (final helperSkill in skillsList) {
            if (normalizedRequired.contains(helperSkill) || 
                helperSkill.contains(normalizedRequired)) {
              matchScore += 3; // High score for skill match
            }
          }
        }

        // Bonus points for same barangay
        if (job.barangay == helperBarangay) {
          matchScore += 2;
        }

        // Only include jobs with some match
        if (matchScore > 0) {
          scoredJobs.add(MapEntry(job, matchScore));
        }
      }

      // Sort by score and take top matches
      scoredJobs.sort((a, b) => b.value.compareTo(a.value));

      return scoredJobs
          .take(limit)
          .map((entry) => entry.key)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch matched jobs: $e');
    }
  }

  /// Get job postings by barangay
  static Future<List<JobPosting>> getJobPostingsByBarangay(String barangay) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('barangay', barangay)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => JobPosting.fromMap(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch job postings by barangay: $e');
    }
  }

  /// Update job posting
  static Future<JobPosting> updateJobPosting(JobPosting jobPosting) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .update(jobPosting.toMap())
          .eq('id', jobPosting.id)
          .select()
          .single();

      return JobPosting.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update job posting: $e');
    }
  }

  /// Update job posting status
  static Future<JobPosting> updateJobPostingStatus(String jobId, String status) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .update({'status': status})
          .eq('id', jobId)
          .select()
          .single();

      return JobPosting.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update job posting status: $e');
    }
  }

  /// Delete job posting
  static Future<void> deleteJobPosting(String jobId) async {
    try {
      await SupabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', jobId);
    } catch (e) {
      throw Exception('Failed to delete job posting: $e');
    }
  }

  /// Get job posting by ID
  static Future<JobPosting> getJobPostingById(String jobId) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('id', jobId)
          .single();

      return JobPosting.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch job posting: $e');
    }
  }
}
