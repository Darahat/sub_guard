import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_settings_notifier.dart';

/// Screen for managing notification settings
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(notificationSettingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: settingsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Enable/Disable Notifications
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text(
                    'Receive reminders for upcoming renewals',
                  ),
                  value: settingsState.settings.enabled,
                  onChanged: (value) {
                    ref
                        .read(notificationSettingsNotifierProvider.notifier)
                        .toggleNotifications(value);
                  },
                ),

                const Divider(),

                // Reminder Times Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminder Times',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get notified X days before renewal',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                // Reminder Day Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8.0,
                    children: [
                      for (final days in [1, 3, 7, 14, 30])
                        FilterChip(
                          label: Text('$days ${days == 1 ? 'day' : 'days'}'),
                          selected: settingsState.settings.defaultReminderDays
                              .contains(days),
                          onSelected: (selected) {
                            ref
                                .read(
                                  notificationSettingsNotifierProvider.notifier,
                                )
                                .toggleReminderDay(days);
                          },
                        ),
                    ],
                  ),
                ),

                const Divider(),

                // Sound Settings
                SwitchListTile(
                  title: const Text('Sound'),
                  subtitle: const Text('Play sound for notifications'),
                  value: settingsState.settings.soundEnabled,
                  onChanged: settingsState.settings.enabled
                      ? (value) {
                          ref
                              .read(
                                notificationSettingsNotifierProvider.notifier,
                              )
                              .toggleSound(value);
                        }
                      : null,
                ),

                // Vibration Settings
                SwitchListTile(
                  title: const Text('Vibration'),
                  subtitle: const Text('Vibrate for notifications'),
                  value: settingsState.settings.vibrationEnabled,
                  onChanged: settingsState.settings.enabled
                      ? (value) {
                          ref
                              .read(
                                notificationSettingsNotifierProvider.notifier,
                              )
                              .toggleVibration(value);
                        }
                      : null,
                ),

                // Badge Settings
                SwitchListTile(
                  title: const Text('Badge'),
                  subtitle: const Text('Show badge on app icon'),
                  value: settingsState.settings.badgeEnabled,
                  onChanged: settingsState.settings.enabled
                      ? (value) {
                          ref
                              .read(
                                notificationSettingsNotifierProvider.notifier,
                              )
                              .toggleBadge(value);
                        }
                      : null,
                ),

                const Divider(),

                // Test Notification Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OutlinedButton.icon(
                    onPressed: settingsState.settings.enabled
                        ? () {
                            ref
                                .read(
                                  notificationSettingsNotifierProvider.notifier,
                                )
                                .sendTestNotification();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Test notification sent! Check your device.',
                                ),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Send Test Notification'),
                  ),
                ),

                // Info Card
                Card(
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'About Notifications',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Notifications help you stay on top of your subscriptions by reminding you before renewals. You can customize when to receive reminders and manage notification preferences here.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
