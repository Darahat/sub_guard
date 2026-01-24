import 'package:isar/isar.dart';

import '../../domain/entities/subscription_entity.dart';

part 'subscription_model.g.dart';

/// Subscription model for Isar database
@Collection()
class SubscriptionModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String subscriptionId;

  @Index()
  late String userId;

  @Index()
  late String serviceName;

  late double amount;
  late String currency;

  @Enumerated(EnumType.name)
  late BillingCycle billingCycle;

  late DateTime nextBillingDate;

  String? description;
  String? category;
  String? logoUrl;
  String? websiteUrl;

  @Enumerated(EnumType.name)
  late SubscriptionStatus status;

  late List<String> notificationDays;

  DateTime? startDate;
  DateTime? cancellationDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Empty constructor for Isar
  SubscriptionModel();

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
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory SubscriptionModel.fromEntity(SubscriptionEntity entity) {
    return SubscriptionModel()
      ..subscriptionId = entity.id
      ..userId = entity.userId
      ..serviceName = entity.serviceName
      ..amount = entity.amount
      ..currency = entity.currency
      ..billingCycle = entity.billingCycle
      ..nextBillingDate = entity.nextBillingDate
      ..description = entity.description
      ..category = entity.category
      ..logoUrl = entity.logoUrl
      ..websiteUrl = entity.websiteUrl
      ..status = entity.status
      ..notificationDays = entity.notificationDays
      ..startDate = entity.startDate
      ..cancellationDate = entity.cancellationDate
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
  }
}
