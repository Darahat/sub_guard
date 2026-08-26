import '../../../../core/utils/date_helper.dart';
import 'contract_commitment.dart';
import 'price_change_record.dart';
import 'subscription_health.dart';

/// Subscription entity representing a user's subscription
class SubscriptionEntity {
  final String id;
  final String userId;
  final String serviceName;
  final double amount;
  final String currency;
  final BillingCycle billingCycle;
  final DateTime nextBillingDate;
  final String? description;
  final String? category;
  final String? logoUrl;
  final String? websiteUrl;
  final SubscriptionStatus status;
  final List<String> notificationDays;
  final DateTime? startDate;
  final DateTime? cancellationDate;
  final DateTime? cancelledDate;
  final DateTime? lastRenewalConfirmedAt;
  final DateTime? lastReviewedAt;
  final DateTime? cancelledAt;
  final bool isSharedPlan;
  final int? splitCount;
  final double? myShareAmount;
  final ContractCommitment? contractCommitment;
  final String? paymentMethodId;
  final List<PriceChangeRecord> priceHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SubscriptionEntity({
    required this.id,
    required this.userId,
    required this.serviceName,
    required this.amount,
    required this.currency,
    required this.billingCycle,
    required this.nextBillingDate,
    this.description,
    this.category,
    this.logoUrl,
    this.websiteUrl,
    this.status = SubscriptionStatus.active,
    this.notificationDays = const [],
    this.startDate,
    this.cancellationDate,
    this.cancelledDate,
    this.lastRenewalConfirmedAt,
    this.lastReviewedAt,
    this.cancelledAt,
    this.isSharedPlan = false,
    this.splitCount,
    this.myShareAmount,
    this.contractCommitment,
    this.paymentMethodId,
    this.priceHistory = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// True if this subscription has an annual or multi-month contract commitment
  bool get hasContract => contractCommitment != null;

  /// The effective personal cost for this user (used for all budget & spending calculations)
  double get effectivePersonalAmount =>
      (isSharedPlan && myShareAmount != null && myShareAmount! > 0)
          ? myShareAmount!
          : amount;

  /// Create a copy of SubscriptionEntity with updated fields
  SubscriptionEntity copyWith({
    String? id,
    String? userId,
    String? serviceName,
    double? amount,
    String? currency,
    BillingCycle? billingCycle,
    DateTime? nextBillingDate,
    String? description,
    String? category,
    String? logoUrl,
    String? websiteUrl,
    SubscriptionStatus? status,
    List<String>? notificationDays,
    DateTime? startDate,
    DateTime? cancellationDate,
    DateTime? cancelledDate,
    DateTime? lastRenewalConfirmedAt,
    DateTime? lastReviewedAt,
    DateTime? cancelledAt,
    bool? isSharedPlan,
    int? splitCount,
    double? myShareAmount,
    ContractCommitment? contractCommitment,
    bool clearContract = false,
    String? paymentMethodId,
    bool clearPaymentMethod = false,
    List<PriceChangeRecord>? priceHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceName: serviceName ?? this.serviceName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      billingCycle: billingCycle ?? this.billingCycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      description: description ?? this.description,
      category: category ?? this.category,
      logoUrl: logoUrl ?? this.logoUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      status: status ?? this.status,
      notificationDays: notificationDays ?? this.notificationDays,
      startDate: startDate ?? this.startDate,
      cancellationDate: cancellationDate ?? this.cancellationDate,
      cancelledDate: cancelledDate ?? this.cancelledDate,
      lastRenewalConfirmedAt:
          lastRenewalConfirmedAt ?? this.lastRenewalConfirmedAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      isSharedPlan: isSharedPlan ?? this.isSharedPlan,
      splitCount: splitCount ?? this.splitCount,
      myShareAmount: myShareAmount ?? this.myShareAmount,
      contractCommitment: clearContract
          ? null
          : (contractCommitment ?? this.contractCommitment),
      paymentMethodId: clearPaymentMethod
          ? null
          : (paymentMethodId ?? this.paymentMethodId),
      priceHistory: priceHistory ?? this.priceHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate annual cost based on billing cycle
  double get annualCost {
    return DateHelper.calculateAnnualCost(
      amount: amount,
      billingCycle: billingCycle,
    );
  }

  /// Alias for annualCost
  double get yearlyCost => annualCost;

  /// Calculate the next future billing date advancing beyond the given reference time
  DateTime calculateNextFutureBillingDate([DateTime? from]) {
    final reference = from ?? DateTime.now();
    return DateHelper.advanceToNextFutureBillingDate(
      previousDate: nextBillingDate,
      cycle: billingCycle,
      now: reference,
    );
  }

  /// Calculate monthly cost equivalent based on billing cycle
  double get monthlyCost {
    switch (billingCycle) {
      case BillingCycle.daily:
        return amount * 30.4375;
      case BillingCycle.weekly:
        return amount * 4.348;
      case BillingCycle.monthly:
        return amount;
      case BillingCycle.quarterly:
        return amount / 3;
      case BillingCycle.yearly:
        return amount / 12;
    }
  }

  /// Check if subscription is expiring soon (within 7 days)
  bool get isExpiringSoon {
    return DateHelper.isWithinDays(nextBillingDate, 7);
  }

  /// Check if subscription is expiring today
  bool get isExpiringToday {
    return DateHelper.isToday(nextBillingDate);
  }

  /// Get days until next billing date
  int get daysUntilBilling {
    return DateHelper.daysUntil(nextBillingDate);
  }

  /// Evaluates whether this subscription has passed its renewal date and requires confirmation
  bool requiresRenewalConfirmation(DateTime now, {Duration gracePeriod = const Duration(hours: 12)}) {
    if (status != SubscriptionStatus.active) return false;

    // Check if the current time is past the renewal timestamp plus grace period
    final confirmationWindowStart = nextBillingDate.add(gracePeriod);
    if (now.isBefore(confirmationWindowStart)) return false;

    // If last confirmed renewal was already AFTER or AT the current nextBillingDate, we don't prompt again
    if (lastRenewalConfirmedAt != null && !lastRenewalConfirmedAt!.isBefore(nextBillingDate)) {
      return false;
    }

    return true;
  }

  /// Evaluates subscription hygiene and potential disuse
  SubscriptionHealth evaluateHealth(DateTime now) {
    if (status == SubscriptionStatus.cancelled || status == SubscriptionStatus.expired) {
      return SubscriptionHealth.healthy(id);
    }

    // 1. Check for unconfirmed stale renewals (>7 days overdue)
    final daysOverdue = now.difference(nextBillingDate).inDays;
    if (daysOverdue > 7 && (lastRenewalConfirmedAt == null || lastRenewalConfirmedAt!.isBefore(nextBillingDate))) {
      return SubscriptionHealth.staleRenewal(
        subscriptionId: id,
        daysOverdue: daysOverdue,
      );
    }

    // 2. Check for potentially unused subscriptions (>60 days unreviewed)
    if (lastReviewedAt != null) {
      final daysSinceReview = now.difference(lastReviewedAt!).inDays;
      if (daysSinceReview > 60) {
        return SubscriptionHealth.potentiallyUnused(
          subscriptionId: id,
          daysSinceInteraction: daysSinceReview,
          reason: 'No review or interaction in $daysSinceReview days',
        );
      }
    } else if (startDate != null) {
      final daysSinceStart = now.difference(startDate!).inDays;
      if (daysSinceStart > 60) {
        return SubscriptionHealth.potentiallyUnused(
          subscriptionId: id,
          daysSinceInteraction: daysSinceStart,
          reason: 'Active for $daysSinceStart days without regular review',
        );
      }
    }

    return SubscriptionHealth.healthy(id);
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Billing cycle enum
enum BillingCycle { daily, weekly, monthly, quarterly, yearly }

/// Subscription status enum
enum SubscriptionStatus { active, paused, cancelled, expired }
