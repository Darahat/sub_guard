import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../../features/budget/domain/entities/budget_health.dart';
import '../../features/subscriptions/domain/entities/subscription_entity.dart';
import '../utils/currency_helper.dart';

/// Centralized service to sync subscription snapshot data to Android Home Screen Widgets
class HomeWidgetService {
  static const String _kUpcomingProvider = 'UpcomingRenewalWidgetProvider';
  static const String _kOverviewProvider = 'SpendingOverviewWidgetProvider';

  /// Syncs current subscriptions and budget data to home screen widgets
  static Future<void> updateWidgets({
    required List<SubscriptionEntity> subscriptions,
    required BudgetEvaluation budget,
    required String primaryCurrency,
  }) async {
    try {
      final activeSubs =
          subscriptions
              .where((s) => s.status == SubscriptionStatus.active)
              .toList()
            ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));

      if (activeSubs.isEmpty) {
        await HomeWidget.saveWidgetData<String>(
          'upcoming_service_name',
          'No upcoming renewals',
        );
        await HomeWidget.saveWidgetData<String>('upcoming_amount', '\$0.00');
        await HomeWidget.saveWidgetData<String>(
          'upcoming_date',
          'All caught up',
        );
        await HomeWidget.saveWidgetData<String>('upcoming_badge', 'Active');

        await HomeWidget.saveWidgetData<String>(
          'overview_spending',
          '${CurrencyHelper.formatAmount(0, currency: primaryCurrency)} / mo',
        );
        await HomeWidget.saveWidgetData<String>('overview_health', 'On Track');
        await HomeWidget.saveWidgetData<String>(
          'overview_sub1_name',
          'No active subscriptions',
        );
        await HomeWidget.saveWidgetData<String>('overview_sub1_due', '');
        await HomeWidget.saveWidgetData<String>('overview_sub1_amount', '');
        await HomeWidget.saveWidgetData<String>('overview_sub2_name', '');
        await HomeWidget.saveWidgetData<String>('overview_sub2_due', '');
        await HomeWidget.saveWidgetData<String>('overview_sub2_amount', '');
      } else {
        // 1. Compact Widget (Next upcoming renewal)
        final nextSub = activeSubs.first;
        final formattedDate = DateFormat(
          'MMM d',
        ).format(nextSub.nextBillingDate);
        final dueBadge = nextSub.daysUntilBilling < 0
            ? 'Overdue'
            : (nextSub.daysUntilBilling == 0
                  ? 'Due Today'
                  : (nextSub.daysUntilBilling == 1
                        ? 'Tomorrow'
                        : 'In ${nextSub.daysUntilBilling}d'));

        await HomeWidget.saveWidgetData<String>(
          'upcoming_service_name',
          nextSub.serviceName,
        );
        await HomeWidget.saveWidgetData<String>(
          'upcoming_amount',
          CurrencyHelper.formatAmount(
            nextSub.effectivePersonalAmount,
            currency: nextSub.currency,
          ),
        );
        await HomeWidget.saveWidgetData<String>(
          'upcoming_date',
          'Due $formattedDate',
        );
        await HomeWidget.saveWidgetData<String>('upcoming_badge', dueBadge);

        // 2. Spending Overview Widget (Budget + Top 2 Renewals)
        await HomeWidget.saveWidgetData<String>(
          'overview_spending',
          '${CurrencyHelper.formatAmount(budget.totalMonthlySpent, currency: primaryCurrency)} / mo',
        );
        await HomeWidget.saveWidgetData<String>(
          'overview_health',
          budget.health.label,
        );

        // Sub 1
        await HomeWidget.saveWidgetData<String>(
          'overview_sub1_name',
          nextSub.serviceName,
        );
        await HomeWidget.saveWidgetData<String>(
          'overview_sub1_due',
          formattedDate,
        );
        await HomeWidget.saveWidgetData<String>(
          'overview_sub1_amount',
          CurrencyHelper.formatAmount(
            nextSub.effectivePersonalAmount,
            currency: nextSub.currency,
          ),
        );

        // Sub 2 (if present)
        if (activeSubs.length > 1) {
          final sub2 = activeSubs[1];
          final formattedDate2 = DateFormat(
            'MMM d',
          ).format(sub2.nextBillingDate);
          await HomeWidget.saveWidgetData<String>(
            'overview_sub2_name',
            sub2.serviceName,
          );
          await HomeWidget.saveWidgetData<String>(
            'overview_sub2_due',
            formattedDate2,
          );
          await HomeWidget.saveWidgetData<String>(
            'overview_sub2_amount',
            CurrencyHelper.formatAmount(
              sub2.effectivePersonalAmount,
              currency: sub2.currency,
            ),
          );
        } else {
          await HomeWidget.saveWidgetData<String>('overview_sub2_name', '');
          await HomeWidget.saveWidgetData<String>('overview_sub2_due', '');
          await HomeWidget.saveWidgetData<String>('overview_sub2_amount', '');
        }
      }

      // Refresh native widget views
      await HomeWidget.updateWidget(
        name: _kUpcomingProvider,
        androidName: _kUpcomingProvider,
      );
      await HomeWidget.updateWidget(
        name: _kOverviewProvider,
        androidName: _kOverviewProvider,
      );
    } catch (_) {
      // Gracefully handle platform channel errors on unsupported environments
    }
  }
}
