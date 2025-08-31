import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/rating.dart';
import '../models/rating_statistics.dart';
import 'supabase_service.dart';

class RatingService {
  final SupabaseClient _supabase = SupabaseService.client;
  
  static const String _tableName = 'ratings';

  // Create a new rating
  Future<Rating?> createRating(Rating rating) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(rating.toCreateMap())
          .select()
          .single();

      return Rating.fromMap(response);
    } catch (e) {
      debugPrint('Error creating rating: $e');
      return null;
    }
  }

  // Update an existing rating
  Future<Rating?> updateRating(String ratingId, {
    int? rating,
    String? reviewText,
    bool? isAnonymous,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (rating != null) updateData['rating'] = rating;
      if (reviewText != null) updateData['review_text'] = reviewText;
      if (isAnonymous != null) updateData['is_anonymous'] = isAnonymous;

      if (updateData.isEmpty) return null;

      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', ratingId)
          .select()
          .single();

      return Rating.fromMap(response);
    } catch (e) {
      debugPrint('Error updating rating: $e');
      return null;
    }
  }

  // Get ratings for a specific user (received ratings)
  Future<List<Rating>> getUserRatings(String userId, String userType) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('rated_id', userId)
          .eq('rated_type', userType)
          .order('created_at', ascending: false);

      return response.map<Rating>((rating) => Rating.fromMap(rating)).toList();
    } catch (e) {
      debugPrint('Error fetching user ratings: $e');
      return [];
    }
  }

  // Get ratings given by a specific user
  Future<List<Rating>> getRatingsGivenByUser(String userId, String userType) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('rater_id', userId)
          .eq('rater_type', userType)
          .order('created_at', ascending: false);

      return response.map<Rating>((rating) => Rating.fromMap(rating)).toList();
    } catch (e) {
      debugPrint('Error fetching ratings given by user: $e');
      return [];
    }
  }

  // Get rating statistics for a user
  Future<RatingStatistics> getUserRatingStatistics(String userId, String userType) async {
    try {
      final ratings = await getUserRatings(userId, userType);
      
      if (ratings.isEmpty) {
        return RatingStatistics.empty(userId, userType);
      }

      // Calculate average rating
      final totalRating = ratings.fold<int>(0, (sum, rating) => sum + rating.rating);
      final averageRating = totalRating / ratings.length;

      // Calculate rating distribution
      final Map<int, int> ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final rating in ratings) {
        ratingDistribution[rating.rating] = (ratingDistribution[rating.rating] ?? 0) + 1;
      }

      return RatingStatistics(
        userId: userId,
        userType: userType,
        averageRating: averageRating,
        totalRatings: ratings.length,
        ratingDistribution: ratingDistribution,
      );
    } catch (e) {
      debugPrint('Error calculating rating statistics: $e');
      return RatingStatistics.empty(userId, userType);
    }
  }

  // Check if a rating already exists for a specific engagement
  Future<Rating?> getExistingRating({
    required String raterId,
    required String raterType,
    required String ratedId,
    required String ratedType,
    String? jobPostingId,
    String? servicePostingId,
  }) async {
    try {
      var query = _supabase
          .from(_tableName)
          .select()
          .eq('rater_id', raterId)
          .eq('rater_type', raterType)
          .eq('rated_id', ratedId)
          .eq('rated_type', ratedType);

      if (jobPostingId != null) {
        query = query.eq('job_posting_id', jobPostingId);
      } else {
        query = query.isFilter('job_posting_id', null);
      }

      if (servicePostingId != null) {
        query = query.eq('service_posting_id', servicePostingId);
      } else {
        query = query.isFilter('service_posting_id', null);
      }

      final response = await query.maybeSingle();

      return response != null ? Rating.fromMap(response) : null;
    } catch (e) {
      debugPrint('Error checking existing rating: $e');
      return null;
    }
  }

  // Get recent ratings for a user (last 10)
  Future<List<Rating>> getRecentRatings(String userId, String userType, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('rated_id', userId)
          .eq('rated_type', userType)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map<Rating>((rating) => Rating.fromMap(rating)).toList();
    } catch (e) {
      debugPrint('Error fetching recent ratings: $e');
      return [];
    }
  }

  // Delete a rating (if needed)
  Future<bool> deleteRating(String ratingId) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', ratingId);

      return true;
    } catch (e) {
      debugPrint('Error deleting rating: $e');
      return false;
    }
  }

  // Get all ratings for a specific job or service posting
  Future<List<Rating>> getRatingsForPosting({
    String? jobPostingId,
    String? servicePostingId,
  }) async {
    try {
      if (jobPostingId != null) {
        final response = await _supabase
            .from(_tableName)
            .select()
            .eq('job_posting_id', jobPostingId)
            .order('created_at', ascending: false);
        return response.map<Rating>((rating) => Rating.fromMap(rating)).toList();
      } else if (servicePostingId != null) {
        final response = await _supabase
            .from(_tableName)
            .select()
            .eq('service_posting_id', servicePostingId)
            .order('created_at', ascending: false);
        return response.map<Rating>((rating) => Rating.fromMap(rating)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching ratings for posting: $e');
      return [];
    }
  }
}
