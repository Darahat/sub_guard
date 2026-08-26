import '../../domain/entities/contract_commitment.dart';
import '../../domain/entities/price_change_record.dart';
import '../../domain/entities/subscription_entity.dart';

/// Subscription model for local storage and Firestore sync
class SubscriptionModel {
  String subscriptionId;
  String userId;
  String serviceName;
  double amount;
  String currency;
  BillingCycle billingCycle;
  DateTime nextBillingDate;
  String? description;
  String? category;
  String? logoUrl;
  String? websiteUrl;
  SubscriptionStatus status;
  List<String> notificationDays;
  DateTime? startDate;
  DateTime? cancellationDate;
  DateTime? cancelledDate;
  DateTime? lastRenewalConfirmedAt;
  DateTime? lastReviewedAt;
  DateTime? cancelledAt;
  bool isSharedPlan;
  int? splitCount;
  double? myShareAmount;
  ContractCommitment? contractCommitment;
  String? paymentMethodId;
  List<PriceChangeRecord> priceHistory;
  DateTime? createdAt;
  DateTime? updatedAt;

  SubscriptionModel({
    required this.subscriptionId,
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
    this.notificationDays = const ['1', '3'],
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

  /// Factory for building empty models
  factory SubscriptionModel.empty() {
    return SubscriptionModel(
      subscriptionId: '',
      userId: '',
      serviceName: '',
      amount: 0.0,
      currency: 'USD',
      billingCycle: BillingCycle.monthly,
      nextBillingDate: DateTime.now(),
    );
  }

  /// Convert to domain entity
  SubscriptionEntity toEntity() {
    return SubscriptionEntity(
      id: subscriptionId,
      userId: userId,
      serviceName: serviceName,
      amount: amount,
      currency: currency,
      billingCycle: billingCycle,
      nextBillingDate: nextBillingDate,
      description: description,
      category: category,
      logoUrl: logoUrl,
      websiteUrl: websiteUrl,
      status: status,
      notificationDays: notificationDays,
      startDate: startDate,
      cancellationDate: cancellationDate,
      cancelledDate: cancelledDate,
      lastRenewalConfirmedAt: lastRenewalConfirmedAt,
      lastReviewedAt: lastReviewedAt,
      cancelledAt: cancelledAt,
      isSharedPlan: isSharedPlan,
      splitCount: splitCount,
      myShareAmount: myShareAmount,
      contractCommitment: contractCommitment,
      paymentMethodId: paymentMethodId,
      priceHistory: priceHistory,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory SubscriptionModel.fromEntity(SubscriptionEntity entity) {
    return SubscriptionModel(
      subscriptionId: entity.id,
      userId: entity.userId,
      serviceName: entity.serviceName,
      amount: entity.amount,
      currency: entity.currency,
      billingCycle: entity.billingCycle,
      nextBillingDate: entity.nextBillingDate,
      description: entity.description,
      category: entity.category,
      logoUrl: entity.logoUrl,
      websiteUrl: entity.websiteUrl,
      status: entity.status,
      notificationDays: entity.notificationDays,
      startDate: entity.startDate,
      cancellationDate: entity.cancellationDate,
      cancelledDate: entity.cancelledDate,
      lastRenewalConfirmedAt: entity.lastRenewalConfirmedAt,
      lastReviewedAt: entity.lastReviewedAt,
      cancelledAt: entity.cancelledAt,
      isSharedPlan: entity.isSharedPlan,
      splitCount: entity.splitCount,
      myShareAmount: entity.myShareAmount,
      contractCommitment: entity.contractCommitment,
      paymentMethodId: entity.paymentMethodId,
      priceHistory: entity.priceHistory,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'userId': userId,
      'serviceName': serviceName,
      'amount': amount,
      'currency': currency,
      'billingCycle': billingCycle.name,
      'nextBillingDate': nextBillingDate.toIso8601String(),
      'description': description,
      'category': category,
      'logoUrl': logoUrl,
      'websiteUrl': websiteUrl,
      'status': status.name,
      'notificationDays': notificationDays,
      'startDate': startDate?.toIso8601String(),
      'cancellationDate': cancellationDate?.toIso8601String(),
      'cancelledDate': cancelledDate?.toIso8601String(),
      'lastRenewalConfirmedAt': lastRenewalConfirmedAt?.toIso8601String(),
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'isSharedPlan': isSharedPlan,
      'splitCount': splitCount,
      'myShareAmount': myShareAmount,
      'contractCommitment': contractCommitment?.toJson(),
      'paymentMethodId': paymentMethodId,
      'priceHistory': priceHistory.map((p) => p.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON Map
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      subscriptionId:
          json['subscriptionId'] as String? ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.name == json['billingCycle'],
        orElse: () => BillingCycle.monthly,
      ),
      nextBillingDate:
          json['nextBillingDate'] != null
              ? DateTime.parse(json['nextBillingDate'] as String)
              : DateTime.now(),
      description: json['description'] as String?,
      category: json['category'] as String?,
      logoUrl: json['logoUrl'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      notificationDays:
          (json['notificationDays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['1', '3'],
      startDate:
          json['startDate'] != null
              ? DateTime.parse(json['startDate'] as String)
              : null,
      cancellationDate:
          json['cancellationDate'] != null
              ? DateTime.parse(json['cancellationDate'] as String)
              : null,
      cancelledDate:
          json['cancelledDate'] != null
              ? DateTime.parse(json['cancelledDate'] as String)
              : null,
      lastRenewalConfirmedAt:
          json['lastRenewalConfirmedAt'] != null
              ? DateTime.parse(json['lastRenewalConfirmedAt'] as String)
              : null,
      lastReviewedAt:
          json['lastReviewedAt'] != null
              ? DateTime.parse(json['lastReviewedAt'] as String)
              : null,
      cancelledAt:
          json['cancelledAt'] != null
              ? DateTime.parse(json['cancelledAt'] as String)
              : null,
      isSharedPlan: json['isSharedPlan'] as bool? ?? false,
      splitCount: json['splitCount'] as int?,
      myShareAmount: (json['myShareAmount'] as num?)?.toDouble(),
      contractCommitment: json['contractCommitment'] != null
          ? ContractCommitment.fromJson(
              json['contractCommitment'] as Map<String, dynamic>,
            )
          : null,
      paymentMethodId: json['paymentMethodId'] as String?,
      priceHistory: (json['priceHistory'] as List<dynamic>?)
              ?.map((p) => PriceChangeRecord.fromJson(p as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }
}
