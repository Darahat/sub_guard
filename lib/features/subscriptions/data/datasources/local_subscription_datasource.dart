import 'dart:convert';
import 'package:hive_ce/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/subscription_entity.dart';
import '../models/subscription_model.dart';

/// Local subscription data source using Hive
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
  final Box<String> box;

  LocalSubscriptionDataSourceImpl({required this.box});

  @override
  Future<List<SubscriptionModel>> getAllSubscriptions() async {
    try {
      return box.values
          .map((jsonStr) =>
              SubscriptionModel.fromJson(json.decode(jsonStr) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get subscriptions: ${e.toString()}');
    }
  }

  @override
  Future<SubscriptionModel?> getSubscriptionById(String id) async {
    try {
      final jsonStr = box.get(id);
      if (jsonStr == null) return null;
      return SubscriptionModel.fromJson(
          json.decode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      throw CacheException('Failed to get subscription: ${e.toString()}');
    }
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptionsByStatus(
    SubscriptionStatus status,
  ) async {
    try {
      final all = await getAllSubscriptions();
      return all.where((s) => s.status == status).toList();
    } catch (e) {
      throw CacheException(
        'Failed to get subscriptions by status: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptionsByCategory(
    String category,
  ) async {
    try {
      final all = await getAllSubscriptions();
      return all.where((s) => s.category?.toLowerCase() == category.toLowerCase()).toList();
    } catch (e) {
      throw CacheException(
        'Failed to get subscriptions by category: ${e.toString()}',
      );
    }
  }

  @override
  Future<SubscriptionModel> addSubscription(
    SubscriptionModel subscription,
  ) async {
    try {
      await box.put(
        subscription.subscriptionId,
        json.encode(subscription.toJson()),
      );
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
      await box.put(
        subscription.subscriptionId,
        json.encode(subscription.toJson()),
      );
      return subscription;
    } catch (e) {
      throw CacheException('Failed to update subscription: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSubscription(String id) async {
    try {
      await box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete subscription: ${e.toString()}');
    }
  }

  @override
  Future<List<SubscriptionModel>> searchSubscriptions(String query) async {
    try {
      final all = await getAllSubscriptions();
      final q = query.toLowerCase();
      return all.where((s) => s.serviceName.toLowerCase().contains(q)).toList();
    } catch (e) {
      throw CacheException('Failed to search subscriptions: ${e.toString()}');
    }
  }

  @override
  Future<List<SubscriptionModel>> getExpiringSoonSubscriptions(int days) async {
    try {
      final all = await getAllSubscriptions();
      final now = DateTime.now();
      final threshold = now.add(Duration(days: days));

      return all.where((sub) {
        return sub.nextBillingDate.isAfter(now) &&
            sub.nextBillingDate.isBefore(threshold) &&
            sub.status == SubscriptionStatus.active;
      }).toList();
    } catch (e) {
      throw CacheException(
        'Failed to get expiring subscriptions: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear subscriptions: ${e.toString()}');
    }
  }
}
