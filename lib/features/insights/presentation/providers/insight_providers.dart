import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../subscriptions/presentation/providers/subscription_providers.dart';
import '../../data/repositories/insight_repository_impl.dart';
import '../../domain/repositories/insight_repository.dart';
import '../../domain/usecases/get_category_breakdown_usecase.dart';
import '../../domain/usecases/get_spending_trends_usecase.dart';
import '../../domain/usecases/get_subscription_stats_usecase.dart';
import '../../domain/usecases/get_top_subscriptions_usecase.dart';

// Repository provider
final insightRepositoryProvider = Provider<InsightRepository>((ref) {
  final subscriptionDataSource = ref.watch(localSubscriptionDataSourceProvider);
  return InsightRepositoryImpl(subscriptionDataSource);
});

// Use case providers
final getSpendingTrendsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(insightRepositoryProvider);
  return GetSpendingTrendsUseCase(repository);
});

final getCategoryBreakdownUseCaseProvider = Provider((ref) {
  final repository = ref.watch(insightRepositoryProvider);
  return GetCategoryBreakdownUseCase(repository);
});

final getSubscriptionStatsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(insightRepositoryProvider);
  return GetSubscriptionStatsUseCase(repository);
});

final getTopSubscriptionsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(insightRepositoryProvider);
  return GetTopSubscriptionsUseCase(repository);
});
