import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/layout/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';
import '../../../subscriptions/presentation/providers/subscription_notifier.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/enums/payment_method_type.dart';
import '../../domain/services/payment_shield_evaluator.dart';
import '../providers/payment_method_providers.dart';
import 'reassign_payment_method_sheet.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _cardsPageController;
  int _currentCardIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cardsPageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardsPageController.dispose();
    super.dispose();
  }

  void _showAddEditDialog([PaymentMethodEntity? existing]) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: Breakpoints.isTablet(context)
          ? const BoxConstraints(maxWidth: 600)
          : null,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _AddEditPaymentMethodDialog(existing: existing),
      ),
    );
  }

  void _showLinkSubscriptionsSheet(
    PaymentMethodEntity method,
    List<SubscriptionEntity> allSubscriptions,
  ) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: Breakpoints.isTablet(context)
          ? const BoxConstraints(maxWidth: 600)
          : null,
      builder: (_) => _BulkLinkSubscriptionsSheet(
        paymentMethod: method,
        allSubscriptions: allSubscriptions,
      ),
    );
  }

  void _confirmDelete(PaymentMethodEntity method, int linkedCount) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment Method?'),
        content: Text(
          linkedCount > 0
              ? '"${method.displayLabel}" is linked to $linkedCount active subscription(s).\n\nDeleting it will remove the payment method assignment from those subscriptions.'
              : 'Are you sure you want to remove "${method.displayLabel}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(paymentMethodNotifierProvider.notifier)
                  .deletePaymentMethod(method.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showActionSheet(
    PaymentMethodEntity method,
    List<SubscriptionEntity> linkedSubs,
    List<SubscriptionEntity> allSubs,
  ) {
    HapticFeedback.lightImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(method.displayLabel),
        message: Text('${linkedSubs.length} linked subscriptions'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showLinkSubscriptionsSheet(method, allSubs);
            },
            child: const Text('Link / Manage Subscriptions'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showAddEditDialog(method);
            },
            child: const Text('Edit Payment Method'),
          ),
          if (linkedSubs.isNotEmpty)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  constraints: Breakpoints.isTablet(context)
                      ? const BoxConstraints(maxWidth: 600)
                      : null,
                  builder: (_) => ReassignPaymentMethodSheet(
                    currentPaymentMethod: method,
                    affectedSubscriptions: linkedSubs,
                  ),
                );
              },
              child: const Text('Reassign Subscriptions to Another Card'),
            ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete(method, linkedSubs.length);
            },
            child: const Text('Delete'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentMethodNotifierProvider);
    final breakdown = ref.watch(paymentMethodSpendBreakdownProvider);
    final primaryCurrency = ref.watch(primaryCurrencyProvider);
    final subscriptions = ref.watch(subscriptionNotifierProvider).subscriptions;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods & Shield'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: HeroIcon(HeroIcons.creditCard, size: 20),
              text: 'Payment Methods',
            ),
            Tab(
              icon: HeroIcon(HeroIcons.chartPie, size: 20),
              text: 'Spend Breakdown',
            ),
          ],
        ),
      ),
      floatingActionButton: state.paymentMethods.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddEditDialog(),
              icon: const HeroIcon(HeroIcons.plus, size: 20),
              label: const Text('Add Payment Method'),
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Breakpoints.isDesktop(context)
                ? 900
                : (Breakpoints.isTablet(context) ? 720 : double.infinity),
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              // 1. Horizontal Carousel + Linked Subscriptions List
              _buildPaymentMethodsTab(state, subscriptions, now),

              // 2. Spending Breakdown Tab
              _buildSpendBreakdownTab(breakdown, primaryCurrency),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsTab(
    PaymentMethodState state,
    List<SubscriptionEntity> allSubscriptions,
    DateTime now,
  ) {
    if (state.paymentMethods.isEmpty) {
      return _buildEmptyState();
    }

    final safeIndex = _currentCardIndex.clamp(
      0,
      state.paymentMethods.length - 1,
    );
    final activeMethod = state.paymentMethods[safeIndex];
    final activeLinkedSubs = allSubscriptions
        .where((s) => s.paymentMethodId == activeMethod.id)
        .toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16, bottom: 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YOUR PAYMENT CARDS (${state.paymentMethods.length})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  'Swipe to view',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 1. Horizontal Card Carousel (168px Compact Height)
          SizedBox(
            height: 168,
            child: PageView.builder(
              controller: _cardsPageController,
              itemCount: state.paymentMethods.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                HapticFeedback.selectionClick();
                setState(() => _currentCardIndex = index);
              },
              itemBuilder: (context, index) {
                final method = state.paymentMethods[index];
                final linkedSubs = allSubscriptions
                    .where((s) => s.paymentMethodId == method.id)
                    .toList();
                return _buildCompactCreditCard(
                  method,
                  linkedSubs,
                  allSubscriptions,
                  now,
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // 2. Pagination Indicator Dots
          if (state.paymentMethods.length > 1)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(state.paymentMethods.length, (index) {
                  final isSelected = safeIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isSelected ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          const SizedBox(height: 24),

          // 3. Subscriptions Attached to this Card Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LINKED SUBSCRIPTIONS (${activeLinkedSubs.length})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => _showLinkSubscriptionsSheet(
                    activeMethod,
                    allSubscriptions,
                  ),
                  icon: const HeroIcon(HeroIcons.link, size: 14),
                  label: const Text(
                    'Link / Manage',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 4. Linked Subscriptions List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildLinkedSubscriptionsGroup(
              activeLinkedSubs,
              activeMethod,
              allSubscriptions,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCreditCard(
    PaymentMethodEntity method,
    List<SubscriptionEntity> linkedSubs,
    List<SubscriptionEntity> allSubs,
    DateTime now,
  ) {
    final status = method.evaluateStatus(now);
    final isExpiring = status.isActionable;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: () => _showActionSheet(method, linkedSubs, allSubs),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isExpiring
                  ? (status == PaymentExpiryStatus.expired
                        ? [Colors.red.shade900, Colors.red.shade700]
                        : [Colors.amber.shade900, Colors.amber.shade700])
                  : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background decorative glow circle
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Row 1: Brand Icon & Type + Status Chips & Menu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          HeroIcon(
                            method.type.heroIcon,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            method.type.label.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (method.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'DEFAULT',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          const SizedBox(width: 4),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const HeroIcon(
                              HeroIcons.ellipsisHorizontal,
                              color: Colors.white70,
                              size: 20,
                            ),
                            onPressed: () =>
                                _showActionSheet(method, linkedSubs, allSubs),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Row 2: Masked Card Number
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      method.last4 != null && method.last4!.isNotEmpty
                          ? '••••  ••••  ••••  ${method.last4}'
                          : method.displayLabel,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.8,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),

                  // Row 3: Cardholder Label + Expiration Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          method.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        method.formattedExpiry != null
                            ? 'Exp: ${method.formattedExpiry}'
                            : '${linkedSubs.length} SUBS',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkedSubscriptionsGroup(
    List<SubscriptionEntity> linkedSubs,
    PaymentMethodEntity activeMethod,
    List<SubscriptionEntity> allSubs,
  ) {
    final theme = Theme.of(context);

    if (linkedSubs.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const HeroIcon(
                HeroIcons.link,
                size: 24,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'No Subscriptions Linked',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Attach subscriptions to "${activeMethod.displayLabel}" to track card expenses automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () =>
                  _showLinkSubscriptionsSheet(activeMethod, allSubs),
              icon: const HeroIcon(HeroIcons.plus, size: 16),
              label: const Text('Link Subscriptions Now'),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.12)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: linkedSubs.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: theme.dividerColor.withValues(alpha: 0.08),
        ),
        itemBuilder: (context, index) {
          final sub = linkedSubs[index];
          final formattedNextDate = DateFormat(
            'MMM dd, yyyy',
          ).format(sub.nextBillingDate);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  sub.serviceName.isNotEmpty
                      ? sub.serviceName.substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            title: Text(
              sub.serviceName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              'Renews $formattedNextDate • ${sub.billingCycle.name.toUpperCase()}',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            trailing: Text(
              CurrencyHelper.formatAmount(sub.amount, currency: sub.currency),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: -0.3,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpendBreakdownTab(
    List<PaymentMethodSpendSummary> breakdown,
    String primaryCurrency,
  ) {
    final theme = Theme.of(context);

    if (breakdown.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HeroIcon(HeroIcons.chartPie, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'No Spend Data Available',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Add subscriptions and payment methods to see spend distributions.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: breakdown.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = breakdown[index];
        final label = item.paymentMethod?.displayLabel ?? 'Unassigned';
        final heroIcon =
            item.paymentMethod?.type.heroIcon ?? HeroIcons.questionMarkCircle;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  HeroIcon(heroIcon, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    CurrencyHelper.formatAmount(
                      item.totalMonthlySpend,
                      currency: primaryCurrency,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: item.percentageOfTotal / 100,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
                minHeight: 6,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.subscriptions.length} subscription(s)',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${item.percentageOfTotal.toStringAsFixed(1)}% of total',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const HeroIcon(
                HeroIcons.creditCard,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Payment Methods Added',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your payment cards or wallets to track expirations and prevent subscription disruptions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _showAddEditDialog(),
              icon: const HeroIcon(HeroIcons.plus, size: 18),
              label: const Text('Add Payment Method'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bulk Sheet allowing linking/unlinking subscriptions in 1 tap
class _BulkLinkSubscriptionsSheet extends ConsumerStatefulWidget {
  final PaymentMethodEntity paymentMethod;
  final List<SubscriptionEntity> allSubscriptions;

  const _BulkLinkSubscriptionsSheet({
    required this.paymentMethod,
    required this.allSubscriptions,
  });

  @override
  ConsumerState<_BulkLinkSubscriptionsSheet> createState() =>
      _BulkLinkSubscriptionsSheetState();
}

class _BulkLinkSubscriptionsSheetState
    extends ConsumerState<_BulkLinkSubscriptionsSheet> {
  late Set<String> _selectedIds;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.allSubscriptions
        .where((s) => s.paymentMethodId == widget.paymentMethod.id)
        .map((s) => s.id)
        .toSet();
  }

  void _selectAll(bool select) {
    HapticFeedback.selectionClick();
    setState(() {
      if (select) {
        _selectedIds = widget.allSubscriptions.map((s) => s.id).toSet();
      } else {
        _selectedIds.clear();
      }
    });
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final toLink = _selectedIds.toList();
    final toUnlink = widget.allSubscriptions
        .where(
          (s) =>
              s.paymentMethodId == widget.paymentMethod.id &&
              !_selectedIds.contains(s.id),
        )
        .map((s) => s.id)
        .toList();

    if (toLink.isNotEmpty) {
      await ref
          .read(paymentMethodNotifierProvider.notifier)
          .reassignSubscriptions(
            subscriptionIds: toLink,
            newPaymentMethodId: widget.paymentMethod.id,
          );
    }

    if (toUnlink.isNotEmpty) {
      await ref
          .read(paymentMethodNotifierProvider.notifier)
          .reassignSubscriptions(
            subscriptionIds: toUnlink,
            newPaymentMethodId: null,
          );
    }

    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Updated subscriptions linked to "${widget.paymentMethod.displayLabel}".',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const HeroIcon(
                    HeroIcons.link,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Link Subscriptions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Assign to "${widget.paymentMethod.displayLabel}"',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Select All / Deselect All Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedIds.length} of ${widget.allSubscriptions.length} selected',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () => _selectAll(true),
                      child: const Text(
                        'Select All',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () => _selectAll(false),
                      child: const Text(
                        'Clear',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 1),

            // Subscriptions Checklist
            if (widget.allSubscriptions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No subscriptions found in your account.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.allSubscriptions.length,
                  itemBuilder: (context, index) {
                    final sub = widget.allSubscriptions[index];
                    final isSelected = _selectedIds.contains(sub.id);

                    return CheckboxListTile(
                      value: isSelected,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      activeColor: AppColors.primary,
                      title: Text(
                        sub.serviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${CurrencyHelper.formatAmount(sub.amount, currency: sub.currency)} / ${sub.billingCycle.name}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (val == true) {
                            _selectedIds.add(sub.id);
                          } else {
                            _selectedIds.remove(sub.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            // Save Action Button
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save (${_selectedIds.length} Linked)',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddEditPaymentMethodDialog extends ConsumerStatefulWidget {
  final PaymentMethodEntity? existing;

  const _AddEditPaymentMethodDialog({this.existing});

  @override
  ConsumerState<_AddEditPaymentMethodDialog> createState() =>
      _AddEditPaymentMethodDialogState();
}

class _AddEditPaymentMethodDialogState
    extends ConsumerState<_AddEditPaymentMethodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _last4Controller = TextEditingController();

  PaymentMethodType _selectedType = PaymentMethodType.creditCard;
  int? _expiryMonth;
  int? _expiryYear;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameController.text = widget.existing!.name;
      _last4Controller.text = widget.existing!.last4 ?? '';
      _selectedType = widget.existing!.type;
      _expiryMonth = widget.existing!.expiryMonth;
      _expiryYear = widget.existing!.expiryYear;
      _isDefault = widget.existing!.isDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _last4Controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    final isNew = widget.existing == null;
    final id = widget.existing?.id ?? const Uuid().v4();

    final method = PaymentMethodEntity(
      id: id,
      name: _nameController.text.trim(),
      type: _selectedType,
      last4: _last4Controller.text.trim().isNotEmpty
          ? _last4Controller.text.trim()
          : null,
      expiryMonth: _expiryMonth,
      expiryYear: _expiryYear,
      isDefault: _isDefault,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = isNew
        ? await ref
              .read(paymentMethodNotifierProvider.notifier)
              .addPaymentMethod(method)
        : await ref
              .read(paymentMethodNotifierProvider.notifier)
              .updatePaymentMethod(method);

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Grab Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                widget.existing == null
                    ? 'Add Payment Method'
                    : 'Edit Payment Method',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Type Selector
              DropdownButtonFormField<PaymentMethodType>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Payment Method Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: PaymentMethodType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        HeroIcon(type.heroIcon, size: 18),
                        const SizedBox(width: 8),
                        Text(type.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 14),

              // Name / Cardholder / Label
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Card / Account Label',
                  hintText: 'e.g. Chase Sapphire, Personal PayPal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Label is required'
                    : null,
              ),
              const SizedBox(height: 14),

              // Last 4 digits (if applicable)
              if (_selectedType.supportsExpiry)
                TextFormField(
                  controller: _last4Controller,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: 'Last 4 Digits',
                    hintText: '4242',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val != null && val.isNotEmpty && val.length != 4) {
                      return 'Must be exactly 4 digits';
                    }
                    return null;
                  },
                ),
              if (_selectedType.supportsExpiry) const SizedBox(height: 14),

              // Expiry Month & Year (if applicable)
              if (_selectedType.supportsExpiry)
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _expiryMonth,
                        decoration: InputDecoration(
                          labelText: 'Month',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: List.generate(12, (i) => i + 1).map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text(m.toString().padLeft(2, '0')),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _expiryMonth = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _expiryYear,
                        decoration: InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: List.generate(15, (i) => now.year + i).map((y) {
                          return DropdownMenuItem(
                            value: y,
                            child: Text(y.toString()),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _expiryYear = val),
                      ),
                    ),
                  ],
                ),
              if (_selectedType.supportsExpiry) const SizedBox(height: 14),

              // Is Default Toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Set as Default Payment Method',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Auto-assign this method to newly created subscriptions',
                ),
                value: _isDefault,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  setState(() => _isDefault = val);
                },
              ),
              const SizedBox(height: 18),

              // Save Button
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _handleSave,
                child: Text(
                  widget.existing == null
                      ? 'Add Payment Method'
                      : 'Update Payment Method',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
