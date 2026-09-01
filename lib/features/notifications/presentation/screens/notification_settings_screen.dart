import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/layout/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../monetization/presentation/providers/purchase_notifier.dart';
import '../../../monetization/presentation/widgets/paywall_bottom_sheet.dart';
import '../providers/notification_settings_notifier.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _isTimePickerExpanded = false;

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(notificationSettingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Alarms')),
      body: SafeArea(
        bottom: true,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          child: settingsState.isLoading
              ? const ListSkeletonLoader()
              : Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Breakpoints.isTablet(context)
                          ? 680
                          : double.infinity,
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      children: [
                        // 1. Master Enable Section
                        _buildSectionHeader('MASTER SWITCH'),
                        _buildGroupedCard(
                          children: [
                            SwitchListTile(
                              secondary: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const HeroIcon(
                                  HeroIcons.bellAlert,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              title: const Text(
                                'Enable Reminders',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                'Receive alarms before renewal charges',
                              ),
                              value: settingsState.settings.enabled,
                              onChanged: (value) {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(
                                      notificationSettingsNotifierProvider
                                          .notifier,
                                    )
                                    .toggleNotifications(value);
                                if (!value && _isTimePickerExpanded) {
                                  setState(() => _isTimePickerExpanded = false);
                                }
                              },
                            ),
                            if (settingsState.settings.enabled) ...[
                              const Divider(height: 1),
                              ListTile(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _isTimePickerExpanded =
                                        !_isTimePickerExpanded;
                                  });
                                },
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const HeroIcon(
                                    HeroIcons.clock,
                                    color: Colors.purple,
                                    size: 20,
                                  ),
                                ),
                                title: const Text(
                                  'Reminder Time',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _isTimePickerExpanded
                                            ? AppColors.primary.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.grey.withValues(
                                                alpha: 0.1,
                                              ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        settingsState.settings.reminderTime,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _isTimePickerExpanded
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                height: _isTimePickerExpanded ? 200 : 0,
                                child: ClipRect(
                                  child: CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.time,
                                    initialDateTime: DateTime(
                                      2026,
                                      1,
                                      1,
                                      int.parse(
                                        settingsState.settings.reminderTime
                                            .split(':')[0],
                                      ),
                                      int.parse(
                                        settingsState.settings.reminderTime
                                            .split(':')[1],
                                      ),
                                    ),
                                    onDateTimeChanged: (DateTime newTime) {
                                      HapticFeedback.selectionClick();
                                      final formattedTime =
                                          '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
                                      ref
                                          .read(
                                            notificationSettingsNotifierProvider
                                                .notifier,
                                          )
                                          .updateReminderTime(formattedTime);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 2. Reminder Timeline Days
                        _buildSectionHeader('ADVANCE WARNING DAYS'),
                        _buildGroupedCard(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Select when you want to receive alerts before renewal:',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: [
                                      for (final days in [1, 3, 7, 14, 30])
                                        Builder(
                                          builder: (context) {
                                            final isPro = ref
                                                .watch(purchaseNotifierProvider)
                                                .isPro;
                                            final isSelected = settingsState
                                                .settings
                                                .defaultReminderDays
                                                .contains(days);
                                            final isLocked =
                                                days >= 14 && !isPro;

                                            return FilterChip(
                                              avatar: isLocked
                                                  ? const HeroIcon(
                                                      HeroIcons.lockClosed,
                                                      size: 13,
                                                      color: AppColors.primary,
                                                    )
                                                  : (isSelected
                                                        ? const HeroIcon(
                                                            HeroIcons.check,
                                                            size: 13,
                                                            color: Colors.white,
                                                          )
                                                        : null),
                                              label: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '$days ${days == 1 ? 'day' : 'days'} before',
                                                  ),
                                                  if (isLocked) ...[
                                                    const SizedBox(width: 4),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 4,
                                                            vertical: 1,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary
                                                            .withValues(
                                                              alpha: 0.15,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: const Text(
                                                        'PRO',
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              selected: isSelected,
                                              selectedColor: AppColors.primary,
                                              labelStyle: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : AppColors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              onSelected:
                                                  settingsState.settings.enabled
                                                  ? (selected) {
                                                      if (isLocked) {
                                                        HapticFeedback.mediumImpact();
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          constraints:
                                                              Breakpoints.isTablet(
                                                                context,
                                                              )
                                                              ? const BoxConstraints(
                                                                  maxWidth: 600,
                                                                )
                                                              : null,
                                                          builder: (_) =>
                                                              const PaywallBottomSheet(),
                                                        );
                                                        return;
                                                      }
                                                      HapticFeedback.lightImpact();
                                                      ref
                                                          .read(
                                                            notificationSettingsNotifierProvider
                                                                .notifier,
                                                          )
                                                          .toggleReminderDay(
                                                            days,
                                                          );
                                                    }
                                                  : null,
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 3. Sensory Preferences
                        _buildSectionHeader('ALERT PREFERENCES'),
                        _buildGroupedCard(
                          children: [
                            SwitchListTile(
                              secondary: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const HeroIcon(
                                  HeroIcons.speakerWave,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              title: const Text(
                                'Sound',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text('Play chime with reminder'),
                              value: settingsState.settings.soundEnabled,
                              onChanged: settingsState.settings.enabled
                                  ? (value) {
                                      HapticFeedback.lightImpact();
                                      ref
                                          .read(
                                            notificationSettingsNotifierProvider
                                                .notifier,
                                          )
                                          .toggleSound(value);
                                    }
                                  : null,
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              secondary: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const HeroIcon(
                                  HeroIcons.devicePhoneMobile,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              ),
                              title: const Text(
                                'Vibration',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text(
                                'Tactile vibration on alarm',
                              ),
                              value: settingsState.settings.vibrationEnabled,
                              onChanged: settingsState.settings.enabled
                                  ? (value) {
                                      HapticFeedback.lightImpact();
                                      ref
                                          .read(
                                            notificationSettingsNotifierProvider
                                                .notifier,
                                          )
                                          .toggleVibration(value);
                                    }
                                  : null,
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              secondary: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const HeroIcon(
                                  HeroIcons.envelopeOpen,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              title: const Text(
                                'App Icon Badge',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text('Display badge on app icon'),
                              value: settingsState.settings.badgeEnabled,
                              onChanged: settingsState.settings.enabled
                                  ? (value) {
                                      HapticFeedback.lightImpact();
                                      ref
                                          .read(
                                            notificationSettingsNotifierProvider
                                                .notifier,
                                          )
                                          .toggleBadge(value);
                                    }
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 4. Test Notification Button
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: settingsState.settings.enabled
                              ? () {
                                  HapticFeedback.mediumImpact();
                                  ref
                                      .read(
                                        notificationSettingsNotifierProvider
                                            .notifier,
                                      )
                                      .sendTestNotification();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Test notification sent! Check your notification tray.',
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              : null,
                          icon: const HeroIcon(HeroIcons.bellAlert, size: 20),
                          label: const Text(
                            'Dispatch Test Alarm',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
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
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}
