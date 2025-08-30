import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';
import '../models/subscription_plan.dart';
import '../models/usage_tracking.dart';
import '../utils/constants/subscription_constants.dart';
import 'session_service.dart';

class SubscriptionService {
  static const String _keyUsageTracking = 'usage_tracking_';
  static const String _keySubscription = 'subscription_';

  // Get user usage tracking
  static Future<UsageTracking?> getUserUsageTracking(String userId, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyUsageTracking$userId';
    final jsonString = prefs.getString(key);
    
    if (jsonString != null) {
      try {
        final Map<String, dynamic> data = {
          'id': userId,
          'user_id': userId,
          'user_type': userType,
          'usage_count': prefs.getInt('${key}_count') ?? 0,
          'trial_limit': SubscriptionConstants.getTrialLimitForUserType(userType),
          'last_used_at': prefs.getString('${key}_last_used') ?? DateTime.now().toIso8601String(),
          'created_at': prefs.getString('${key}_created') ?? DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        return UsageTracking.fromMap(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Initialize usage tracking for new user
  static Future<UsageTracking> initializeUsageTracking(String userId, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyUsageTracking$userId';
    final now = DateTime.now();
    
    final tracking = UsageTracking(
      id: userId,
      userId: userId,
      userType: userType,
      usageCount: 0,
      trialLimit: SubscriptionConstants.getTrialLimitForUserType(userType),
      lastUsedAt: now,
      createdAt: now,
      updatedAt: now,
    );

    await prefs.setInt('${key}_count', tracking.usageCount);
    await prefs.setString('${key}_last_used', tracking.lastUsedAt.toIso8601String());
    await prefs.setString('${key}_created', tracking.createdAt.toIso8601String());
    
    return tracking;
  }

  // Increment usage count
  static Future<UsageTracking> incrementUsage(String userId, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyUsageTracking$userId';
    
    final currentCount = prefs.getInt('${key}_count') ?? 0;
    final newCount = currentCount + 1;
    final now = DateTime.now();
    
    await prefs.setInt('${key}_count', newCount);
    await prefs.setString('${key}_last_used', now.toIso8601String());
    
    final tracking = UsageTracking(
      id: userId,
      userId: userId,
      userType: userType,
      usageCount: newCount,
      trialLimit: SubscriptionConstants.getTrialLimitForUserType(userType),
      lastUsedAt: now,
      createdAt: DateTime.parse(prefs.getString('${key}_created') ?? now.toIso8601String()),
      updatedAt: now,
    );
    
    return tracking;
  }

  // Check if user can use the app (trial or subscription)
  static Future<bool> canUserUseApp(String userId, String userType) async {
    // Check if user has active subscription
    final subscription = await getUserSubscription(userId);
    if (subscription != null && subscription.isValidSubscription) {
      return true;
    }

    // Check trial usage
    final usage = await getUserUsageTracking(userId, userType);
    if (usage == null) {
      return true; // New user, allow usage
    }

    return !usage.hasExceededTrial;
  }

  // Get user subscription
  static Future<Subscription?> getUserSubscription(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keySubscription$userId';
    final jsonString = prefs.getString(key);
    
    if (jsonString != null) {
      try {
        final Map<String, dynamic> data = {
          'id': prefs.getString('${key}_id') ?? '',
          'user_id': userId,
          'user_type': prefs.getString('${key}_user_type') ?? '',
          'plan_type': prefs.getString('${key}_plan_type') ?? '',
          'is_active': prefs.getBool('${key}_active') ?? false,
          'expiry_date': prefs.getString('${key}_expiry'),
          'created_at': prefs.getString('${key}_created') ?? DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        return Subscription.fromMap(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Create subscription
  static Future<Subscription> createSubscription(
    String userId,
    String userType,
    SubscriptionPlan plan,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keySubscription$userId';
    final now = DateTime.now();
    final expiryDate = now.add(Duration(days: plan.durationInDays));
    
    final subscription = Subscription(
      id: '${userId}_${plan.id}_${now.millisecondsSinceEpoch}',
      userId: userId,
      userType: userType,
      planType: plan.id,
      isActive: true,
      expiryDate: expiryDate,
      createdAt: now,
      updatedAt: now,
    );

    await prefs.setString('${key}_id', subscription.id);
    await prefs.setString('${key}_user_type', subscription.userType);
    await prefs.setString('${key}_plan_type', subscription.planType);
    await prefs.setBool('${key}_active', subscription.isActive);
    await prefs.setString('${key}_expiry', subscription.expiryDate!.toIso8601String());
    await prefs.setString('${key}_created', subscription.createdAt.toIso8601String());
    
    return subscription;
  }

  // Check subscription status for current user
  static Future<Map<String, dynamic>> getCurrentUserSubscriptionStatus() async {
    final userId = await SessionService.getCurrentUserId();
    final userType = await SessionService.getCurrentUserType();
    
    if (userId == null || userType == null) {
      return {
        'canUse': false,
        'hasSubscription': false,
        'isTrialUser': false,
        'error': 'User not found',
      };
    }

    final subscription = await getUserSubscription(userId);
    final hasValidSubscription = subscription?.isValidSubscription ?? false;
    
    if (hasValidSubscription) {
      return {
        'canUse': true,
        'hasSubscription': true,
        'isTrialUser': false,
        'subscription': subscription,
      };
    }

    // Check trial status
    final canUse = await canUserUseApp(userId, userType);
    final usage = await getUserUsageTracking(userId, userType) ??
        await initializeUsageTracking(userId, userType);

    return {
      'canUse': canUse,
      'hasSubscription': false,
      'isTrialUser': true,
      'usage': usage,
      'needsSubscription': usage.hasExceededTrial,
    };
  }

  // Record app usage for current user
  static Future<void> recordAppUsage() async {
    final userId = await SessionService.getCurrentUserId();
    final userType = await SessionService.getCurrentUserType();
    
    if (userId == null || userType == null) return;

    // Check if user has active subscription
    final subscription = await getUserSubscription(userId);
    if (subscription?.isValidSubscription == true) {
      return; // Don't track usage for subscribed users
    }

    // Increment trial usage
    await incrementUsage(userId, userType);
  }

  // Clear subscription data
  static Future<void> clearSubscriptionData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptionKey = '$_keySubscription$userId';
    final usageKey = '$_keyUsageTracking$userId';
    
    // Clear subscription data
    await prefs.remove('${subscriptionKey}_id');
    await prefs.remove('${subscriptionKey}_user_type');
    await prefs.remove('${subscriptionKey}_plan_type');
    await prefs.remove('${subscriptionKey}_active');
    await prefs.remove('${subscriptionKey}_expiry');
    await prefs.remove('${subscriptionKey}_created');
    
    // Clear usage tracking
    await prefs.remove('${usageKey}_count');
    await prefs.remove('${usageKey}_last_used');
    await prefs.remove('${usageKey}_created');
  }
}
