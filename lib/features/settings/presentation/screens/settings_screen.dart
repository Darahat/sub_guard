import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/security/app_lock_notifier.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../subscriptions/presentation/providers/subscription_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final syncStatusAsync = ref.watch(syncStatusStreamProvider);

    // Listen to messages from SubscriptionNotifier
    ref.listen<SubscriptionState>(subscriptionNotifierProvider, (previous, next) {
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
      appBar: AppBar(
        title: const Text('Settings & Data'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Account Profile Card
          _buildAccountCard(context, user),
          const SizedBox(height: 20),

          // 2. Data Backup & Migration Section
          _buildSectionHeader('Data Backup & Migration'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.file_download_outlined, color: AppColors.primary),
                  ),
                  title: const Text('Export to CSV', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Export ${subscriptionState.subscriptions.length} subscriptions to CSV file'),
                  trailing: subscriptionState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: subscriptionState.isLoading
                      ? null
                      : () => _handleExportCsv(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.file_upload_outlined, color: Colors.green),
                  ),
                  title: const Text('Import from CSV', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Restore subscriptions from standard CSV backup'),
                  trailing: subscriptionState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: subscriptionState.isLoading
                      ? null
                      : () => _handleImportCsv(context, ref, user?.id ?? 'local_user'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.cloud_sync_outlined, color: Colors.blue),
                  ),
                  title: const Text('Cloud Sync Now', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: syncStatusAsync.when(
                    data: (status) {
                      if (status.isSyncing) return const Text('Syncing in progress...');
                      if (status.lastSyncedAt != null) {
                        return Text('Last synced: ${DateFormat('MMM d, h:mm a').format(status.lastSyncedAt!)}');
                      }
                      return const Text('Tap to synchronize with Cloud Firestore');
                    },
                    loading: () => const Text('Checking cloud status...'),
                    error: (_, __) => const Text('Cloud sync offline'),
                  ),
                  trailing: const Icon(Icons.refresh, size: 20),
                  onTap: () async {
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
          ),
          const SizedBox(height: 20),

          // 3. Security & Biometrics Section
          _buildSectionHeader('Security & Privacy'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final lockState = ref.watch(appLockNotifierProvider);
                    if (!lockState.isDeviceSupported) {
                      return const ListTile(
                        leading: Icon(Icons.fingerprint, color: Colors.grey),
                        title: Text('Biometric App Lock'),
                        subtitle: Text('Not available or not enrolled on this device'),
                      );
                    }

                    return SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          lockState.hasFaceId ? Icons.face_outlined : Icons.fingerprint,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        '${lockState.biometricName} Lock',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('Require authentication to open SubGuard'),
                      value: lockState.isEnabled,
                      onChanged: (bool value) async {
                        final success = await ref
                            .read(appLockNotifierProvider.notifier)
                            .toggleAppLock(value);
                        if (context.mounted && !success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Biometric authentication cancelled or failed.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Notification & Preferences Section
          _buildSectionHeader('Preferences'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.notifications_active_outlined, color: Colors.purple),
                  ),
                  title: const Text('Notification Alarms', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Renewal reminders & trial alerts'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/settings/notifications'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. About & Version
          _buildSectionHeader('About SubGuard'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.grey),
                  title: Text('Version', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text('1.0.0 (MVP Build)', style: TextStyle(color: Colors.grey)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.explore_outlined, color: AppColors.primary),
                  title: const Text('Replay Interactive Tour', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Review feature walkthrough & capabilities'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/onboarding/tour'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: Colors.grey),
                  title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showPrivacyPolicyDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 5. Sign Out Button
          if (user != null)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () => _showSignOutConfirmation(context, ref),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              user != null ? (user.initials ?? 'U') : 'G',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? (user?.email ?? 'Guest User'),
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
                  user != null ? (user.email ?? 'Offline Local Account') : 'Local Mode',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user?.isPremium == true ? 'PRO' : 'FREE',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _handleExportCsv(BuildContext context, WidgetRef ref) async {
    await ref.read(subscriptionNotifierProvider.notifier).exportCsv();
  }

  void _handleImportCsv(BuildContext context, WidgetRef ref, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Subscriptions CSV'),
        content: const Text(
          'Select a CSV backup file from your device. Any valid subscriptions found in the file will be added to your account and synced.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Choose CSV File'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(subscriptionNotifierProvider.notifier).importCsv(userId: userId);
    }
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('SubGuard Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'SubGuard stores your data locally on your device using Isar Database with optional Firebase Cloud Backup. '
            'We do not sell your data or share it with third parties. Your financial tracking data is strictly private to your authenticated account.',
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
        content: const Text('Are you sure you want to sign out of SubGuard? Your local data will remain saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
