import '../../models/subscription_plan.dart';

class SubscriptionConstants {
  // Trial limits
  static const int employerTrialLimit = 5;
  static const int helperTrialLimit = 8;

  // Subscription plans
  static const List<SubscriptionPlan> availablePlans = [
    SubscriptionPlan(
      id: 'starter',
      name: 'Starter Plan',
      description: 'Perfect for getting started with WeCare',
      price: 50.0,
      durationInDays: 28, // 4 weeks
      currency: 'PHP',
    ),
    SubscriptionPlan(
      id: 'standard',
      name: 'Standard Plan',
      description: 'Best value for regular users',
      price: 100.0,
      durationInDays: 90, // 3 months
      currency: 'PHP',
    ),
    SubscriptionPlan(
      id: 'premium',
      name: 'Premium Plan',
      description: 'Maximum benefits for power users',
      price: 199.0,
      durationInDays: 180, // 6 months
      currency: 'PHP',
    ),
  ];

  // Helper methods
  static int getTrialLimitForUserType(String userType) {
    switch (userType.toLowerCase()) {
      case 'employer':
        return employerTrialLimit;
      case 'helper':
        return helperTrialLimit;
      default:
        return 0;
    }
  }

  static SubscriptionPlan? getPlanById(String planId) {
    try {
      return availablePlans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  static List<SubscriptionPlan> getActivePlans() {
    return availablePlans.where((plan) => plan.isActive).toList();
  }

  // Plan colors for UI
  static const Map<String, int> planColors = {
    'starter': 0xFF4CAF50,   // Green
    'standard': 0xFF2196F3,  // Blue
    'premium': 0xFF9C27B0,   // Purple
  };

  // Plan icons
  static const Map<String, String> planIcons = {
    'starter': '🌱',
    'standard': '⭐',
    'premium': '👑',
  };
}
