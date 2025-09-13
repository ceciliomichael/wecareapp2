import '../models/saved_job.dart';
import '../models/job_posting.dart';
import '../services/supabase_service.dart';

class SavedJobService {
  static const String _tableName = 'saved_jobs';

  /// Save/bookmark a job for a helper
  static Future<SavedJob> saveJob({
    required String helperId,
    required String jobPostingId,
  }) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .insert({
            'helper_id': helperId,
            'job_posting_id': jobPostingId,
          })
          .select()
          .single();

      return SavedJob.fromMap(response);
    } catch (e) {
      throw Exception('Failed to save job: $e');
    }
  }

  /// Remove saved/bookmarked job for a helper
  static Future<void> unsaveJob({
    required String helperId,
    required String jobPostingId,
  }) async {
    try {
      await SupabaseService.client
          .from(_tableName)
          .delete()
          .eq('helper_id', helperId)
          .eq('job_posting_id', jobPostingId);
    } catch (e) {
      throw Exception('Failed to unsave job: $e');
    }
  }

  /// Check if a job is saved by a helper
  static Future<bool> isJobSaved({
    required String helperId,
    required String jobPostingId,
  }) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('id')
          .eq('helper_id', helperId)
          .eq('job_posting_id', jobPostingId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check if job is saved: $e');
    }
  }

  /// Get all saved jobs for a helper with job posting details
  static Future<List<JobPosting>> getSavedJobsForHelper(String helperId) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('''
            *,
            job_postings (
              id,
              employer_id,
              title,
              description,
              barangay,
              salary,
              payment_frequency,
              required_skills,
              status,
              created_at,
              updated_at,
              assigned_helper_id,
              assigned_helper_name
            )
          ''')
          .eq('helper_id', helperId)
          .order('saved_at', ascending: false);

      return (response as List)
          .where((data) => data['job_postings'] != null)
          .map((data) {
            final jobData = data['job_postings'] as Map<String, dynamic>;
            return JobPosting.fromMap(jobData);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch saved jobs: $e');
    }
  }

  /// Get saved job IDs for a helper (for quick lookup)
  static Future<Set<String>> getSavedJobIds(String helperId) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('job_posting_id')
          .eq('helper_id', helperId);

      return (response as List)
          .map((data) => data['job_posting_id'] as String)
          .toSet();
    } catch (e) {
      throw Exception('Failed to fetch saved job IDs: $e');
    }
  }

  /// Toggle save status for a job (save if not saved, unsave if saved)
  static Future<bool> toggleSaveJob({
    required String helperId,
    required String jobPostingId,
  }) async {
    try {
      final isSaved = await isJobSaved(
        helperId: helperId,
        jobPostingId: jobPostingId,
      );

      if (isSaved) {
        await unsaveJob(
          helperId: helperId,
          jobPostingId: jobPostingId,
        );
        return false; // Job is now unsaved
      } else {
        await saveJob(
          helperId: helperId,
          jobPostingId: jobPostingId,
        );
        return true; // Job is now saved
      }
    } catch (e) {
      throw Exception('Failed to toggle save job: $e');
    }
  }

  /// Get count of saved jobs for a helper
  static Future<int> getSavedJobsCount(String helperId) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('id')
          .eq('helper_id', helperId);

      return (response as List).length;
    } catch (e) {
      throw Exception('Failed to get saved jobs count: $e');
    }
  }

  /// Clean up saved jobs for deleted job postings
  static Future<void> cleanupDeletedJobs() async {
    try {
      // This query will remove saved jobs where the referenced job posting no longer exists
      await SupabaseService.client.rpc('cleanup_saved_jobs_for_deleted_postings');
    } catch (e) {
      // Silently handle error as this is a cleanup operation
      // In production, this should be logged to a proper logging service
      throw Exception('Failed to cleanup deleted job postings from saved jobs: $e');
    }
  }
}
