import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_entity.freezed.dart';

/// Subscription entity representing a user's subscription
@freezed
class SubscriptionEntity with _$SubscriptionEntity {
  const factory SubscriptionEntity({
    required String id,
    required String userId,
    required String serviceName,
    required double amount,
    required String currency,
    required BillingCycle billingCycle,
    required DateTime nextBillingDate,
    String? description,
    String? category,
    String? logoUrl,
    String? websiteUrl,
    @Default(SubscriptionStatus.active) SubscriptionStatus status,
    @Default([]) List<String> notificationDays,
    DateTime? startDate,
    DateTime? cancellationDate,
    DateTime? cancelledDate, // Added for cancelled subscriptions
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SubscriptionEntity;

  const SubscriptionEntity._();

  /// Calculate yearly cost
  double get yearlyCost {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return amount * 12;
      case BillingCycle.quarterly:
        return amount * 4;
      case BillingCycle.yearly:
        return amount;
      case BillingCycle.weekly:
        return amount * 52;
      case BillingCycle.daily:
        return amount * 365;
    }
  }

  /// Calculate monthly cost
  double get monthlyCost {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return amount;
      case BillingCycle.quarterly:
        return amount / 3;
      case BillingCycle.yearly:
        return amount / 12;
      case BillingCycle.weekly:
        return amount * 4.33;
      case BillingCycle.daily:
        return amount * 30;
    }
  }

  /// Days until next billing
  int get daysUntilBilling {
    final now = DateTime.now();
    return nextBillingDate.difference(now).inDays;
  }

  /// Is subscription expiring soon (within 7 days)
  bool get isExpiringSoon {
    return daysUntilBilling <= 7 && daysUntilBilling > 0;
  }

  /// Is subscription overdue
  bool get isOverdue {
    return daysUntilBilling < 0;
  }

  /// Is subscription active
  bool get isActive {
    return status == SubscriptionStatus.active && !isOverdue;
  }

  /// Get billing cycle display text
  String get billingCycleText {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.quarterly:
        return 'Quarterly';
      case BillingCycle.yearly:
        return 'Yearly';
      case BillingCycle.weekly:
        return 'Weekly';
      case BillingCycle.daily:
        return 'Daily';
    }
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
    }
  }
}

/// Billing cycle enum
enum BillingCycle { daily, weekly, monthly, quarterly, yearly }

/// Subscription status enum
enum SubscriptionStatus { active, paused, cancelled, expired }
