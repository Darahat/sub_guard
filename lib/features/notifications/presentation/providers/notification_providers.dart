import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/hive_provider.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../data/datasources/local_notification_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/services/contract_notification_scheduler.dart';
import '../../domain/usecases/notification_usecases.dart';

/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final plugin = FlutterLocalNotificationsPlugin();
  final service = NotificationService(plugin);

  // Initialize on first access
  service.initialize();

  return service;
});

/// Provider for LocalNotificationDataSource
final localNotificationDataSourceProvider =
    Provider<LocalNotificationDataSource>((ref) {
      return LocalNotificationDataSourceImpl(
        notificationsBox: ref.watch(notificationsBoxProvider),
        settingsBox: ref.watch(settingsBoxProvider),
      );
    });

/// Provider for NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final localDataSource = ref.watch(localNotificationDataSourceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  const uuid = Uuid();

  return NotificationRepositoryImpl(localDataSource, notificationService, uuid);
});

/// Provider for ScheduleRenewalReminderUseCase
final scheduleRenewalReminderUseCaseProvider =
    Provider<ScheduleRenewalReminderUseCase>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return ScheduleRenewalReminderUseCase(repository);
    });

/// Provider for CancelNotificationUseCase
final cancelNotificationUseCaseProvider = Provider<CancelNotificationUseCase>((
  ref,
) {
  final repository = ref.watch(notificationRepositoryProvider);
  return CancelNotificationUseCase(repository);
});

/// Provider for CancelNotificationsBySubscriptionUseCase
final cancelNotificationsBySubscriptionUseCaseProvider =
    Provider<CancelNotificationsBySubscriptionUseCase>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return CancelNotificationsBySubscriptionUseCase(repository);
    });

/// Provider for GetNotificationSettingsUseCase
final getNotificationSettingsUseCaseProvider =
    Provider<GetNotificationSettingsUseCase>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return GetNotificationSettingsUseCase(repository);
    });

/// Provider for UpdateNotificationSettingsUseCase
final updateNotificationSettingsUseCaseProvider =
    Provider<UpdateNotificationSettingsUseCase>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return UpdateNotificationSettingsUseCase(repository);
    });

/// Provider for ContractNotificationScheduler
final contractNotificationSchedulerProvider =
    Provider<ContractNotificationScheduler>((ref) {
      final notificationService = ref.watch(notificationServiceProvider);
      return ContractNotificationScheduler(
        notificationService: notificationService,
      );
    });
