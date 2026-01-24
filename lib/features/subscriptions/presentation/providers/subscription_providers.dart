import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/isar_provider.dart';
import '../../data/datasources/local_subscription_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/usecases/add_subscription_usecase.dart';
import '../../domain/usecases/cancel_subscription_usecase.dart';
import '../../domain/usecases/delete_subscription_usecase.dart';
import '../../domain/usecases/get_all_subscriptions_usecase.dart';
import '../../domain/usecases/get_subscription_by_id_usecase.dart';
import '../../domain/usecases/get_total_spending_usecase.dart';
import '../../domain/usecases/update_subscription_usecase.dart';

// UUID generator
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

// Local Data Source
final localSubscriptionDataSourceProvider =
    Provider<LocalSubscriptionDataSource>((ref) {
      return LocalSubscriptionDataSourceImpl(isar: ref.watch(isarProvider));
    });

// Repository
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(
    localDataSource: ref.watch(localSubscriptionDataSourceProvider),
    uuid: ref.watch(uuidProvider),
  );
});

// Use Cases
final getAllSubscriptionsUseCaseProvider = Provider<GetAllSubscriptionsUseCase>(
  (ref) {
    return GetAllSubscriptionsUseCase(
      ref.watch(subscriptionRepositoryProvider),
    );
  },
);

final getSubscriptionByIdUseCaseProvider = Provider<GetSubscriptionByIdUseCase>(
  (ref) {
    return GetSubscriptionByIdUseCase(
      ref.watch(subscriptionRepositoryProvider),
    );
  },
);

final addSubscriptionUseCaseProvider = Provider<AddSubscriptionUseCase>((ref) {
  return AddSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});

final updateSubscriptionUseCaseProvider = Provider<UpdateSubscriptionUseCase>((
  ref,
) {
  return UpdateSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});

final deleteSubscriptionUseCaseProvider = Provider<DeleteSubscriptionUseCase>((
  ref,
) {
  return DeleteSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});

final cancelSubscriptionUseCaseProvider = Provider<CancelSubscriptionUseCase>((
  ref,
) {
  return CancelSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});

final getTotalMonthlySpendingUseCaseProvider =
    Provider<GetTotalMonthlySpendingUseCase>((ref) {
      return GetTotalMonthlySpendingUseCase(
        ref.watch(subscriptionRepositoryProvider),
      );
    });

final getTotalYearlySpendingUseCaseProvider =
    Provider<GetTotalYearlySpendingUseCase>((ref) {
      return GetTotalYearlySpendingUseCase(
        ref.watch(subscriptionRepositoryProvider),
      );
    });
