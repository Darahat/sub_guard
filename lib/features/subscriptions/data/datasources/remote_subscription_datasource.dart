import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/subscription_entity.dart';
import '../models/subscription_model.dart';

/// Remote data source for subscriptions using Firestore
abstract class RemoteSubscriptionDataSource {
  /// Get all subscriptions for a user
  Future<List<SubscriptionModel>> getAllSubscriptions(String userId);

  /// Get a subscription by ID
  Future<SubscriptionModel> getSubscriptionById(
    String userId,
    String subscriptionId,
  );

  /// Create a new subscription
  Future<String> createSubscription(
    String userId,
    SubscriptionModel subscription,
  );

  /// Update a subscription
  Future<void> updateSubscription(
    String userId,
    String subscriptionId,
    SubscriptionModel subscription,
  );

  /// Delete a subscription
  Future<void> deleteSubscription(String userId, String subscriptionId);

  /// Listen to subscriptions changes in real-time
  Stream<List<SubscriptionModel>> watchSubscriptions(String userId);

  /// Get subscriptions updated after a timestamp
  Future<List<SubscriptionModel>> getSubscriptionsUpdatedAfter(
    String userId,
    DateTime timestamp,
  );
}

class RemoteSubscriptionDataSourceImpl implements RemoteSubscriptionDataSource {
  final FirebaseFirestore _firestore;

  RemoteSubscriptionDataSourceImpl(this._firestore);

  /// Get collection reference for user's subscriptions
  CollectionReference<Map<String, dynamic>> _getUserSubscriptionsRef(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('subscriptions');
  }

  @override
  Future<List<SubscriptionModel>> getAllSubscriptions(String userId) async {
    try {
      final querySnapshot = await _getUserSubscriptionsRef(
        userId,
      ).where('deletedAt', isNull: true).get();

      return querySnapshot.docs
          .map((doc) => _subscriptionFromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to fetch subscriptions',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<SubscriptionModel> getSubscriptionById(
    String userId,
    String subscriptionId,
  ) async {
    try {
      final doc = await _getUserSubscriptionsRef(
        userId,
      ).doc(subscriptionId).get();

      if (!doc.exists) {
        throw ServerException(message: 'Subscription not found');
      }

      return _subscriptionFromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to fetch subscription',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<String> createSubscription(
    String userId,
    SubscriptionModel subscription,
  ) async {
    try {
      final docRef = _getUserSubscriptionsRef(
        userId,
      ).doc(subscription.subscriptionId);
      final now = DateTime.now();

      await docRef.set({
        'subscriptionId': subscription.subscriptionId,
        'userId': userId,
        'serviceName': subscription.serviceName,
        'amount': subscription.amount,
        'currency': subscription.currency,
        'billingCycle': subscription.billingCycle.name,
        'nextBillingDate': Timestamp.fromDate(subscription.nextBillingDate),
        'description': subscription.description,
        'category': subscription.category,
        'logoUrl': subscription.logoUrl,
        'websiteUrl': subscription.websiteUrl,
        'status': subscription.status.name,
        'notificationDays': subscription.notificationDays,
        'startDate': subscription.startDate != null
            ? Timestamp.fromDate(subscription.startDate!)
            : null,
        'cancellationDate': subscription.cancellationDate != null
            ? Timestamp.fromDate(subscription.cancellationDate!)
            : null,
        'createdAt': Timestamp.fromDate(subscription.createdAt ?? now),
        'updatedAt': Timestamp.fromDate(subscription.updatedAt ?? now),
        'deletedAt': null,
      }, SetOptions(merge: true));

      return docRef.id;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to create subscription',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> updateSubscription(
    String userId,
    String subscriptionId,
    SubscriptionModel subscription,
  ) async {
    try {
      final now = DateTime.now();

      await _getUserSubscriptionsRef(userId).doc(subscriptionId).set({
        'subscriptionId': subscription.subscriptionId,
        'userId': userId,
        'serviceName': subscription.serviceName,
        'amount': subscription.amount,
        'currency': subscription.currency,
        'billingCycle': subscription.billingCycle.name,
        'nextBillingDate': Timestamp.fromDate(subscription.nextBillingDate),
        'description': subscription.description,
        'category': subscription.category,
        'logoUrl': subscription.logoUrl,
        'websiteUrl': subscription.websiteUrl,
        'status': subscription.status.name,
        'notificationDays': subscription.notificationDays,
        'startDate': subscription.startDate != null
            ? Timestamp.fromDate(subscription.startDate!)
            : null,
        'cancellationDate': subscription.cancellationDate != null
            ? Timestamp.fromDate(subscription.cancellationDate!)
            : null,
        'updatedAt': Timestamp.fromDate(subscription.updatedAt ?? now),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update subscription',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> deleteSubscription(String userId, String subscriptionId) async {
    try {
      // Soft delete by setting deletedAt timestamp
      await _getUserSubscriptionsRef(userId).doc(subscriptionId).update({
        'deletedAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete subscription',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Stream<List<SubscriptionModel>> watchSubscriptions(String userId) {
    try {
      return _getUserSubscriptionsRef(userId)
          .where('deletedAt', isNull: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => _subscriptionFromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      throw ServerException(message: 'Failed to watch subscriptions: $e');
    }
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptionsUpdatedAfter(
    String userId,
    DateTime timestamp,
  ) async {
    try {
      final querySnapshot = await _getUserSubscriptionsRef(
        userId,
      ).where('updatedAt', isGreaterThan: Timestamp.fromDate(timestamp)).get();

      return querySnapshot.docs
          .map((doc) => _subscriptionFromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to fetch updated subscriptions',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  /// Convert Firestore document to SubscriptionModel
  SubscriptionModel _subscriptionFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return SubscriptionModel.empty()
      ..subscriptionId = data['subscriptionId'] as String
      ..userId = data['userId'] as String? ?? ''
      ..serviceName = data['serviceName'] as String
      ..amount = (data['amount'] as num).toDouble()
      ..currency = data['currency'] as String
      ..billingCycle = BillingCycle.values.firstWhere(
        (e) => e.name == data['billingCycle'],
      )
      ..nextBillingDate = (data['nextBillingDate'] as Timestamp).toDate()
      ..description = data['description'] as String?
      ..category = data['category'] as String?
      ..logoUrl = data['logoUrl'] as String?
      ..websiteUrl = data['websiteUrl'] as String?
      ..status = SubscriptionStatus.values.firstWhere(
        (e) => e.name == data['status'],
      )
      ..notificationDays =
          (data['notificationDays'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          []
      ..startDate = data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null
      ..cancellationDate = data['cancellationDate'] != null
          ? (data['cancellationDate'] as Timestamp).toDate()
          : null
      ..createdAt = data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null
      ..updatedAt = data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null;
  }
}
