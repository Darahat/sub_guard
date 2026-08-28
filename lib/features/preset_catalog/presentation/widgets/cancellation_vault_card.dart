import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/billing_platform.dart';
import '../../models/preset_service.dart';

class CancellationVaultCard extends StatefulWidget {
  final PresetService preset;
  final String? customWebsiteUrl;
  final VoidCallback onMarkCancelled;

  const CancellationVaultCard({
    super.key,
    required this.preset,
    this.customWebsiteUrl,
    required this.onMarkCancelled,
  });

  @override
  State<CancellationVaultCard> createState() => _CancellationVaultCardState();
}

class _CancellationVaultCardState extends State<CancellationVaultCard> {
  late BillingPlatform _selectedPlatform;

  @override
  void initState() {
    super.initState();
    _selectedPlatform =
        widget.preset.supportedPlatforms.contains(BillingPlatform.web)
        ? BillingPlatform.web
        : (widget.preset.supportedPlatforms.firstOrNull ?? BillingPlatform.web);
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $urlString'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open link: $urlString'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final guide = widget.preset.cancellationGuide;
    final method = guide.getMethod(_selectedPlatform);
    final formattedVerificationDate = DateFormat(
      'MMM d, yyyy',
    ).format(guide.lastVerified);

    final targetUrl =
        (_selectedPlatform == BillingPlatform.web &&
            widget.customWebsiteUrl != null &&
            widget.customWebsiteUrl!.isNotEmpty &&
            method?.actionUrl == null)
        ? widget.customWebsiteUrl
        : method?.actionUrl;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header with verified trust badge below title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
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
                        'CANCELLATION VAULT',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verified guide: $formattedVerificationDate',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 2. Where did you subscribe? Platform Selector
            const Text(
              'Where did you subscribe?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.preset.supportedPlatforms.map((platform) {
                final isSelected = _selectedPlatform == platform;
                return ChoiceChip(
                  avatar: Icon(
                    platform.icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  label: Text(platform.label),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.grey.withValues(alpha: 0.06),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedPlatform = platform);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // 3. Direct Action URL Button
            if (targetUrl != null && targetUrl.isNotEmpty) ...[
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _launchUrl(targetUrl);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: widget.preset.brandColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.preset.brandColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.public,
                        color: widget.preset.brandColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedPlatform == BillingPlatform.web
                              ? 'Go to ${widget.preset.name} Official Portal'
                              : 'Open ${_selectedPlatform.label} Subscriptions',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        color: widget.preset.brandColor,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 4. Step-by-Step Guided Instructions
            if (method != null && method.steps.isNotEmpty) ...[
              Text(
                'How to cancel on ${_selectedPlatform.label}:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              ...method.steps.asMap().entries.map((entry) {
                final stepIndex = entry.key + 1;
                final stepText = entry.value;
                final isLast = entry.key == method.steps.length - 1;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$stepIndex',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0, top: 2),
                          child: Text(
                            stepText,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // 5. Mark as Cancelled Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
              ),
              label: const Text(
                'Mark as Successfully Cancelled',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: widget.onMarkCancelled,
            ),
          ],
        ),
      ),
    );
  }
}
