import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/hive_provider.dart';
import '../../../../core/services/csv_service.dart';
import '../../../../core/sync/sync_service.dart';
import '../../data/datasources/local_subscription_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/usecases/add_subscription_usecase.dart';
import '../../domain/usecases/cancel_subscription_usecase.dart';
import '../../domain/usecases/delete_subscription_usecase.dart';
import '../../domain/usecases/export_subscriptions_csv_usecase.dart';
import '../../domain/usecases/get_all_subscriptions_usecase.dart';
import '../../domain/usecases/get_subscription_by_id_usecase.dart';
import '../../domain/usecases/get_total_spending_usecase.dart';
import '../../domain/usecases/import_subscriptions_csv_usecase.dart';
import '../../domain/usecases/update_subscription_usecase.dart';

// UUID generator
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

// CSV Service
final csvServiceProvider = Provider<CsvService>((ref) {
  return CsvService(uuid: ref.watch(uuidProvider));
});

// Local Data Source
final localSubscriptionDataSourceProvider =
    Provider<LocalSubscriptionDataSource>((ref) {
      return LocalSubscriptionDataSourceImpl(
        box: ref.watch(subscriptionsBoxProvider),
      );
    });

// Repository
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(
    localDataSource: ref.watch(localSubscriptionDataSourceProvider),
    remoteDataSource: ref.watch(remoteSubscriptionDataSourceProvider),
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

final exportSubscriptionsCsvUseCaseProvider =
    Provider<ExportSubscriptionsCsvUseCase>((ref) {
      return ExportSubscriptionsCsvUseCase(ref.watch(csvServiceProvider));
    });

final importSubscriptionsCsvUseCaseProvider =
    Provider<ImportSubscriptionsCsvUseCase>((ref) {
      return ImportSubscriptionsCsvUseCase(
        csvService: ref.watch(csvServiceProvider),
        repository: ref.watch(subscriptionRepositoryProvider),
      );
    });
