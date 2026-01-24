import 'package:isar/isar.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/subscription_entity.dart';
import '../models/subscription_model.dart';

/// Local subscription data source using Isar
abstract class LocalSubscriptionDataSource {
  /// Get all subscriptions
  Future<List<SubscriptionModel>> getAllSubscriptions();

  /// Get subscription by ID
  Future<SubscriptionModel?> getSubscriptionById(String id);

  /// Get subscriptions by status
  Future<List<SubscriptionModel>> getSubscriptionsByStatus(
    SubscriptionStatus status,
  );

  /// Get subscriptions by category
  Future<List<SubscriptionModel>> getSubscriptionsByCategory(String category);

  /// Add subscription
  Future<SubscriptionModel> addSubscription(SubscriptionModel subscription);

  /// Update subscription
  Future<SubscriptionModel> updateSubscription(SubscriptionModel subscription);

  /// Delete subscription
  Future<void> deleteSubscription(String id);

  /// Search subscriptions
  Future<List<SubscriptionModel>> searchSubscriptions(String query);

  /// Get subscriptions expiring within days
  Future<List<SubscriptionModel>> getExpiringSoonSubscriptions(int days);

  /// Clear all subscriptions
  Future<void> clearAll();
}

class LocalSubscriptionDataSourceImpl implements LocalSubscriptionDataSource {
  final Isar isar;

  LocalSubscriptionDataSourceImpl({required this.isar});

  @override
  Future<List<SubscriptionModel>> getAllSubscriptions() async {
    try {
      return await isar.subscriptionModels.where().findAll();
    } catch (e) {
      throw CacheException('Failed to get subscriptions: ${e.toString()}');
    }
  }

  @override
  Future<SubscriptionModel?> getSubscriptionById(String id) async {
    try {
      return await isar.subscriptionModels
          .filter()
          .subscriptionIdEqualTo(id)
          .findFirst();
    } catch (e) {
      throw CacheException('Failed to get subscription: ${e.toString()}');
    }
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptionsByStatus(
    SubscriptionStatus status,
  ) async {
    try {
      return await isar.subscriptionModels
          .filter()
          .statusEqualTo(status)
          .findAll();
    } catch (e) {
      throw CacheException('Failed to get subscriptions by status: ${e.toString()}');
    }
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptionsByCategory(
    String category,
  ) async {
    try {
      return await isar.subscriptionModels
          .filter()
          .categoryEqualTo(category)
          .findAll();
    } catch (e) {
      throw CacheException('Failed to get subscriptions by category: ${e.toString()}');
    }
  }

  @override
  Future<SubscriptionModel> addSubscription(
    SubscriptionModel subscription,
  ) async {
    try {
      await isar.writeTxn(() async {
        await isar.subscriptionModels.put(subscription);
      });
      return subscription;
    } catch (e) {
      throw CacheException('Failed to add subscription: ${e.toString()}');
    }
  }

  @override
  Future<SubscriptionModel> updateSubscription(
    SubscriptionModel subscription,
  ) async {
    try {
      await isar.writeTxn(() async {
        await isar.subscriptionModels.put(subscription);
      });
      return subscription;
    } catch (e) {
      throw CacheException('Failed to update subscription: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSubscription(String id) async {
    try {
      await isar.writeTxn(() async {
        final subscription = await isar.subscriptionModels
            .filter()
            .subscriptionIdEqualTo(id)
            .findFirst();
        if (subscription != null) {
          await isar.subscriptionModels.delete(subscription.id);
        }
      });
    } catch (e) {
      throw CacheException('Failed to delete subscription: ${e.toString()}');
    }
  }

  @override
  Future<List<SubscriptionModel>> searchSubscriptions(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      return await isar.subscriptionModels
          .filter()
          .serviceNameContains(lowerQuery, caseSensitive: false)
          .or()
          .descriptionContains(lowerQuery, caseSensitive: false)
          .findAll();
    } catch (e) {
      throw CacheException('Failed to search subscriptions: ${e.toString()}');
    }
  }

  @override
  Future<List<SubscriptionModel>> getExpiringSoonSubscriptions(int days) async {
    try {
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: days));

      return await isar.subscriptionModels
          .filter()
          .statusEqualTo(SubscriptionStatus.active)
          .and()
          .nextBillingDateBetween(now, futureDate)
          .findAll();
    } catch (e) {
      throw CacheException('Failed to get expiring subscriptions: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await isar.writeTxn(() async {
        await isar.subscriptionModels.clear();
      });
    } catch (e) {
      throw CacheException('Failed to clear subscriptions: ${e.toString()}');
    }
  }
}

