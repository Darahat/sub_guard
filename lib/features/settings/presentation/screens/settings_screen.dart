import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/layout/responsive_layout.dart';
import '../../../../core/security/app_lock_notifier.dart';
import '../../../../core/services/csv_service.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../monetization/presentation/providers/purchase_notifier.dart';
import '../../../monetization/presentation/widgets/paywall_bottom_sheet.dart';
import '../../../subscriptions/presentation/providers/subscription_notifier.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  void _handleExport(BuildContext context) async {
    HapticFeedback.lightImpact();
    final format = await showModalBottomSheet<ExportFormat>(
      context: context,
      backgroundColor: Colors.white,
      constraints: Breakpoints.isTablet(context)
          ? const BoxConstraints(maxWidth: 600)
          : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Export Subscriptions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose your preferred file export format:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.table_chart_outlined,
                    color: Colors.green,
                  ),
                ),
                title: const Text(
                  'Microsoft Excel (.xlsx)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Formatted spreadsheet (Recommended for Excel, Sheets, Numbers)',
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
                onTap: () => Navigator.pop(ctx, ExportFormat.excel),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text(
                  'CSV Document (.csv)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Standard UTF-8 comma-separated text file',
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
                onTap: () => Navigator.pop(ctx, ExportFormat.csv),
              ),
            ],
          ),
        ),
      ),
    );

    if (format != null) {
      setState(() => _isExporting = true);
      try {
        await ref
            .read(subscriptionNotifierProvider.notifier)
            .exportData(format: format);
        HapticFeedback.heavyImpact();
      } finally {
        if (mounted) setState(() => _isExporting = false);
      }
    }
  }

  void _handleImport(BuildContext context, String userId) async {
    HapticFeedback.lightImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Subscriptions'),
        content: const Text(
          'Select an Excel (.xlsx, .xls) or CSV (.csv) backup file from your device. Any valid subscriptions found in the file will be imported and synced.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Choose File'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      HapticFeedback.mediumImpact();
      setState(() => _isImporting = true);
      try {
        final isPro = ref.read(purchaseNotifierProvider).isPro;
        await ref
            .read(subscriptionNotifierProvider.notifier)
            .importData(userId: userId, isPro: isPro);
      } finally {
        if (mounted) setState(() => _isImporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final syncStatusAsync = ref.watch(syncStatusStreamProvider);
    final isGuest = user == null;

    // Listen to messages from SubscriptionNotifier
    ref.listen<SubscriptionState>(subscriptionNotifierProvider, (
      previous,
      next,
    ) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(subscriptionNotifierProvider.notifier).clearError();
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(subscriptionNotifierProvider.notifier).clearSuccess();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Vault')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Breakpoints.isDesktop(context)
                ? 900
                : (Breakpoints.isTablet(context) ? 720 : double.infinity),
          ),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              // 1. Account Section
              _buildSectionHeader('ACCOUNT'),
              _buildAccountCard(context, user),
              const SizedBox(height: 16),
              _buildMembershipCard(context, ref),
              const SizedBox(height: 24),

              // 2. Preferences Section
              _buildSectionHeader('PREFERENCES'),
              _buildGroupedCard(
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final primaryCurrency = ref.watch(
                        primaryCurrencyProvider,
                      );
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const HeroIcon(
                            HeroIcons.currencyDollar,
                            color: Colors.teal,
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Primary Display Currency',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Foreign subscriptions normalize into $primaryCurrency',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.teal.shade200),
                          ),
                          child: Text(
                            primaryCurrency,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade900,
                            ),
                          ),
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showCurrencyPicker(context, ref, primaryCurrency);
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),
                  Consumer(
                    builder: (context, ref, _) {
                      final budgetLimit = ref.watch(monthlyBudgetLimitProvider);
                      final primaryCurrency = ref.watch(
                        primaryCurrencyProvider,
                      );
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const HeroIcon(
                            HeroIcons.chartBar,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Monthly Spending Budget',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          budgetLimit != null
                              ? '${CurrencyHelper.formatAmount(budgetLimit, currency: primaryCurrency)} / month target'
                              : 'Set a monthly limit to prevent overspending',
                        ),
                        trailing: const HeroIcon(
                          HeroIcons.chevronRight,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showBudgetEditor(
                            context,
                            ref,
                            budgetLimit,
                            primaryCurrency,
                          );
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const HeroIcon(
                        HeroIcons.creditCard,
                        color: Colors.blueGrey,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Payment Methods & Shield',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Manage cards, track expiry & spend breakdown',
                    ),
                    trailing: const HeroIcon(
                      HeroIcons.chevronRight,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/payment-methods');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const HeroIcon(
                        HeroIcons.bellAlert,
                        color: Colors.purple,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Notification Alarms',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Renewal reminders & trial alerts'),
                    trailing: const HeroIcon(
                      HeroIcons.chevronRight,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/settings/notifications');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Data & Security Section
              _buildSectionHeader('DATA & SECURITY'),
              _buildGroupedCard(
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final lockState = ref.watch(appLockNotifierProvider);
                      if (!lockState.isDeviceSupported) {
                        return const ListTile(
                          leading: Icon(Icons.fingerprint, color: Colors.grey),
                          title: Text('Biometric App Lock'),
                          subtitle: Text(
                            'Not available or not enrolled on this device',
                          ),
                        );
                      }

                      return SwitchListTile(
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const HeroIcon(
                            HeroIcons.fingerPrint,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          '${lockState.biometricName} Lock',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Require authentication to open SubGuard',
                        ),
                        value: lockState.isEnabled,
                        onChanged: (bool value) async {
                          HapticFeedback.lightImpact();
                          final success = await ref
                              .read(appLockNotifierProvider.notifier)
                              .toggleAppLock(value);
                          if (context.mounted && !success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Biometric authentication cancelled or failed.',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const HeroIcon(
                        HeroIcons.arrowDownTray,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Export Subscriptions',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Export ${subscriptionState.subscriptions.length} subscriptions as Excel (.xlsx) or CSV',
                    ),
                    trailing: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const HeroIcon(
                            HeroIcons.chevronRight,
                            size: 18,
                            color: Colors.grey,
                          ),
                    onTap: _isExporting ? null : () => _handleExport(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const HeroIcon(
                        HeroIcons.arrowUpTray,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Import from Excel / CSV',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Restore subscriptions from Excel (.xlsx) or CSV file',
                    ),
                    trailing: _isImporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const HeroIcon(
                            HeroIcons.chevronRight,
                            size: 18,
                            color: Colors.grey,
                          ),
                    onTap: _isImporting
                        ? null
                        : () =>
                              _handleImport(context, user?.id ?? 'local_user'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const HeroIcon(
                        HeroIcons.cloudArrowUp,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Cloud Sync Now',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: isGuest
                        ? const Text('Sign in to sync with Cloud Firestore')
                        : syncStatusAsync.when(
                            data: (status) {
                              if (status.isSyncing) {
                                return const Text('Syncing in progress...');
                              }
                              if (status.lastSyncedAt != null) {
                                return Text(
                                  'Last synced: ${DateFormat('MMM d, h:mm a').format(status.lastSyncedAt!)}',
                                );
                              }
                              return const Text(
                                'Tap to synchronize with Cloud Firestore',
                              );
                            },
                            loading: () =>
                                const Text('Checking cloud status...'),
                            error: (_, _) => const Text('Cloud sync offline'),
                          ),
                    trailing: const HeroIcon(
                      HeroIcons.arrowPath,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      if (isGuest) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Please sign in to enable Cloud Backup & Sync.',
                            ),
                            action: SnackBarAction(
                              label: 'Sign In',
                              onPressed: () => context.push('/login'),
                            ),
                          ),
                        );
                        return;
                      }

                      await ref.read(syncServiceProvider).syncAll();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cloud sync completed!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. About Section
              _buildSectionHeader('ABOUT'),
              _buildGroupedCard(
                children: [
                  ListTile(
                    leading: const HeroIcon(
                      HeroIcons.informationCircle,
                      color: Colors.grey,
                      size: 20,
                    ),
                    title: const Text(
                      'Version',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(
                      'v${AppConstants.appVersion}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const HeroIcon(
                      HeroIcons.sparkles,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    title: const Text(
                      'Replay Interactive Tour',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Review feature walkthrough & capabilities',
                    ),
                    trailing: const HeroIcon(
                      HeroIcons.chevronRight,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/onboarding/tour');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const HeroIcon(
                      HeroIcons.shieldCheck,
                      color: Colors.grey,
                      size: 20,
                    ),
                    title: const Text(
                      'Privacy Policy',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const HeroIcon(
                      HeroIcons.chevronRight,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showPrivacyPolicyDialog(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const HeroIcon(
                      HeroIcons.documentText,
                      color: Colors.grey,
                      size: 20,
                    ),
                    title: const Text(
                      'Terms of Service',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const HeroIcon(
                      HeroIcons.chevronRight,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/settings/terms');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 6. Sign Out Button (Only displayed when logged in)
              if (user != null) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const HeroIcon(
                    HeroIcons.arrowRightOnRectangle,
                    size: 18,
                  ),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _showSignOutConfirmation(context, ref);
                  },
                ),
                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, dynamic user) {
    final isGuest = user == null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  !isGuest ? (user.initials ?? 'U') : 'G',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      !isGuest
                          ? (user?.displayName ?? user?.email ?? 'User')
                          : 'Guest User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      !isGuest
                          ? (user?.email ?? 'Cloud Synced')
                          : 'Local Storage Mode',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user?.isPremium == true
                      ? 'PRO'
                      : (!isGuest ? 'FREE' : 'GUEST'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (isGuest) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sign in to sync your subscriptions across devices.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/login');
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ] else if (user?.isEmailVerified == false) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amberAccent,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Email unverified',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/verify-email', extra: user.email);
                  },
                  child: const Text(
                    'Verify Now',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembershipCard(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final isPro = purchaseState.isPro;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPro
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPro
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.amber.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPro
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPro ? Icons.workspace_premium : Icons.stars_rounded,
              color: isPro ? AppColors.primary : Colors.amber.shade800,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPro ? 'SubGuard Pro Active' : 'SubGuard Free Plan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isPro ? AppColors.primary : Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPro
                      ? 'Unlimited subscriptions & exact alarms unlocked'
                      : 'Free tier limit: Up to 5 subscriptions',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                constraints: Breakpoints.isTablet(context)
                    ? const BoxConstraints(maxWidth: 600)
                    : null,
                builder: (_) => const PaywallBottomSheet(),
              );
            },
            child: Text(isPro ? 'Manage' : 'Upgrade'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildGroupedCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }

  void _showCurrencyPicker(
    BuildContext context,
    WidgetRef ref,
    String currentCurrency,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: Breakpoints.isTablet(context)
          ? const BoxConstraints(maxWidth: 600)
          : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Primary Display Currency',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'All totals and dashboard charts will normalize into this currency.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView.separated(
                  itemCount: AppConstants.supportedCurrencies.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final curr = AppConstants.supportedCurrencies[index];
                    final isSelected = curr == currentCurrency;
                    return ListTile(
                      title: Text(
                        curr,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(primaryCurrencyProvider.notifier)
                            .setPrimaryCurrency(curr);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetEditor(
    BuildContext context,
    WidgetRef ref,
    double? currentLimit,
    String primaryCurrency,
  ) {
    final controller = TextEditingController(
      text: currentLimit != null && currentLimit > 0
          ? currentLimit.toStringAsFixed(0)
          : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: Breakpoints.isTablet(context)
          ? const BoxConstraints(maxWidth: 600)
          : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Spending Target',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (currentLimit != null)
                  TextButton(
                    onPressed: () {
                      ref
                          .read(monthlyBudgetLimitProvider.notifier)
                          .setBudgetLimit(null);
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Clear Target',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Set a budget to get real-time overspend alerts.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Monthly Target ($primaryCurrency)',
                prefixIcon: const Icon(Icons.track_changes_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [50, 100, 150, 200, 300].map((preset) {
                return ActionChip(
                  label: Text('\$$preset'),
                  onPressed: () => controller.text = preset.toString(),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final val = double.tryParse(controller.text.trim());
                if (val != null && val > 0) {
                  ref
                      .read(monthlyBudgetLimitProvider.notifier)
                      .setBudgetLimit(val);
                } else if (controller.text.trim().isEmpty) {
                  ref
                      .read(monthlyBudgetLimitProvider.notifier)
                      .setBudgetLimit(null);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save Target'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy & Data Retention'),
        content: const SingleChildScrollView(
          child: Text(
            'SubGuard takes your financial privacy seriously.\n\n'
            '• Subscriptions created in Guest mode are stored strictly in local on-device Hive storage.\n'
            '• Subscriptions created after signing in are synced via SSL encrypted Cloud Firestore rules tied to your UID.\n'
            '• We never sell, track, or distribute your subscription spending patterns.\n'
            '• You can export your full data anytime using the Export to CSV feature.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? Your cloud sync will pause until you sign in again.',
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
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
