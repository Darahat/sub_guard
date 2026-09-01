import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/layout/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../subscriptions/presentation/providers/subscription_notifier.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final isGuest = user == null;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Breakpoints.isTablet(context) ? 600 : double.infinity,
          ),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: Breakpoints.isTablet(context) ? 32 : 16,
              vertical: 20,
            ),
            children: [
              // Sleek User Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              !isGuest ? user.initials : 'G',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (!isGuest && user.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      !isGuest
                          ? (user.displayName ?? 'My Account')
                          : 'Guest Account',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      !isGuest ? user.email : 'Local device storage only',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isGuest && !user.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'FREE TIER',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Subscription Stats Summary
              _buildGroupedCard(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          'Active Subs',
                          '${subscriptionState.activeSubscriptionCount}',
                          AppColors.primary,
                        ),
                        _buildStatItem(
                          context,
                          'Monthly Cost',
                          '\$${subscriptionState.totalMonthlySpending.toStringAsFixed(2)}',
                          AppColors.accent,
                        ),
                        _buildStatItem(
                          context,
                          'Yearly Cost',
                          '\$${subscriptionState.totalYearlySpending.toStringAsFixed(2)}',
                          AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Account Options
              if (isGuest) ...[
                _buildGroupedCard(
                  children: [
                    ListTile(
                      leading: _buildIconContainer(
                        HeroIcons.arrowRightOnRectangle,
                        AppColors.primary,
                      ),
                      title: const Text(
                        'Sign In or Register',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Enable multi-device cloud backup',
                        style: TextStyle(fontSize: 13),
                      ),
                      trailing: const HeroIcon(
                        HeroIcons.chevronRight,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () => context.push('/login'),
                    ),
                  ],
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'ACCOUNT SETTINGS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                _buildGroupedCard(
                  children: [
                    if (!user.isEmailVerified) ...[
                      ListTile(
                        leading: _buildIconContainer(
                          HeroIcons.envelopeOpen,
                          Colors.amber,
                        ),
                        title: const Text(
                          'Verify Email Address',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Tap to send verification code',
                          style: TextStyle(fontSize: 13),
                        ),
                        trailing: const HeroIcon(
                          HeroIcons.chevronRight,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () =>
                            context.push('/verify-email', extra: user.email),
                      ),
                      const Divider(height: 1),
                    ],
                    ListTile(
                      leading: _buildIconContainer(
                        HeroIcons.key,
                        AppColors.primary,
                      ),
                      title: const Text(
                        'Change Password',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: const HeroIcon(
                        HeroIcons.chevronRight,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () => context.push('/profile/change-password'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: _buildIconContainer(
                        HeroIcons.sparkles,
                        Colors.purple,
                      ),
                      title: const Text(
                        'Product Tour',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: const HeroIcon(
                        HeroIcons.chevronRight,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () => context.push('/onboarding/tour'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'DANGER ZONE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade400,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                _buildGroupedCard(
                  children: [
                    ListTile(
                      leading: _buildIconContainer(
                        HeroIcons.arrowRightOnRectangle,
                        AppColors.error,
                      ),
                      title: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                      onTap: () async {
                        await ref.read(authNotifierProvider.notifier).signOut();
                        if (context.mounted) context.go('/dashboard');
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(HeroIcons icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: HeroIcon(icon, color: color, size: 20),
    );
  }

  Widget _buildGroupedCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
