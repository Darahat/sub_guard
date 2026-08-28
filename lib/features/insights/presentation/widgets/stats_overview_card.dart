import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/insight_entity.dart';

class StatsOverviewCard extends StatelessWidget {
  final SubscriptionStats stats;

  const StatsOverviewCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OVERVIEW', style: AppTypography.sectionOverhead),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Total',
                  stats.totalSubscriptions.toString(),
                  HeroIcons.rectangleStack,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Active',
                  stats.activeSubscriptions.toString(),
                  HeroIcons.checkCircle,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Paused',
                  stats.pausedSubscriptions.toString(),
                  HeroIcons.pauseCircle,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Cancelled',
                  stats.cancelledSubscriptions.toString(),
                  HeroIcons.xCircle,
                  AppColors.error,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(
            context,
            'Average Cost',
            '\$${stats.averageSubscriptionCost.toStringAsFixed(2)}/mo',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            'Highest',
            '\$${stats.highestSubscription.toStringAsFixed(2)}/mo',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            'Lowest',
            '\$${stats.lowestSubscription.toStringAsFixed(2)}/mo',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    HeroIcons icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          HeroIcon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTypography.sectionOverhead.copyWith(fontSize: 10),
              ),
              Text(
                value,
                style: AppTypography.cardFinancial.copyWith(
                  fontSize: 18,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMetadata),
        Text(
          value,
          style: AppTypography.compactFinancial.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
