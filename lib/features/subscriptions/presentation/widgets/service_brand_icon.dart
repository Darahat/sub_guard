import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/preset_catalog.dart';

class ServiceBrandIcon extends StatelessWidget {
  final String serviceName;
  final Color? customColor;
  final double size;
  final double borderRadius;

  const ServiceBrandIcon({
    super.key,
    required this.serviceName,
    this.customColor,
    this.size = 44,
    this.borderRadius = 12,
  });

  /// Map normalized service name or aliases to local SVG asset paths
  String? _getAssetLogoPath(String name) {
    final clean = name.trim().toLowerCase();
    if (clean.isEmpty) return null;

    final Map<String, String> localLogos = {
      'netflix': 'assets/icons/logos/netflix.svg',
      'spotify': 'assets/icons/logos/spotify.svg',
      'apple': 'assets/icons/logos/apple.svg',
      'apple music': 'assets/icons/logos/apple.svg',
      'apple tv': 'assets/icons/logos/apple.svg',
      'apple tv+': 'assets/icons/logos/apple.svg',
      'apple one': 'assets/icons/logos/apple.svg',
      'icloud': 'assets/icons/logos/apple.svg',
      'icloud+': 'assets/icons/logos/apple.svg',
      'google': 'assets/icons/logos/google.svg',
      'google one': 'assets/icons/logos/google.svg',
      'google workspace': 'assets/icons/logos/google.svg',
      'youtube': 'assets/icons/logos/youtube.svg',
      'youtube premium': 'assets/icons/logos/youtube.svg',
      'youtube music': 'assets/icons/logos/youtube.svg',
      'chatgpt': 'assets/icons/logos/chatgpt.svg',
      'chatgpt plus': 'assets/icons/logos/chatgpt.svg',
      'openai': 'assets/icons/logos/openai.svg',
      'amazon': 'assets/icons/logos/amazon.svg',
      'amazon prime': 'assets/icons/logos/amazon.svg',
      'prime video': 'assets/icons/logos/amazon.svg',
      'audible': 'assets/icons/logos/amazon.svg',
      'github': 'assets/icons/logos/github.svg',
      'github copilot': 'assets/icons/logos/github.svg',
      'discord': 'assets/icons/logos/discord.svg',
      'discord nitro': 'assets/icons/logos/discord.svg',
      'adobe': 'assets/icons/logos/adobe.svg',
      'adobe creative cloud': 'assets/icons/logos/adobe.svg',
      'photoshop': 'assets/icons/logos/adobe.svg',
      'notion': 'assets/icons/logos/notion.svg',
      'figma': 'assets/icons/logos/figma.svg',
      'dropbox': 'assets/icons/logos/dropbox.svg',
      'duolingo': 'assets/icons/logos/duolingo.svg',
      'duolingo plus': 'assets/icons/logos/duolingo.svg',
      'duolingo max': 'assets/icons/logos/duolingo.svg',
      'nordvpn': 'assets/icons/logos/nordvpn.svg',
      'playstation': 'assets/icons/logos/playstation.svg',
      'playstation plus': 'assets/icons/logos/playstation.svg',
      'ps plus': 'assets/icons/logos/playstation.svg',
      'psn': 'assets/icons/logos/playstation.svg',
      'xbox': 'assets/icons/logos/xbox.svg',
      'xbox game pass': 'assets/icons/logos/xbox.svg',
      'canva': 'assets/icons/logos/canva.svg',
      'canva pro': 'assets/icons/logos/canva.svg',
      'microsoft': 'assets/icons/logos/microsoft.svg',
      'microsoft 365': 'assets/icons/logos/microsoft.svg',
      'office 365': 'assets/icons/logos/microsoft.svg',
      '1password': 'assets/icons/logos/1password.svg',
      'bitwarden': 'assets/icons/logos/bitwarden.svg',
      'hulu': 'assets/icons/logos/hulu.svg',
      'max': 'assets/icons/logos/max.svg',
      'hbo': 'assets/icons/logos/max.svg',
      'hbo max': 'assets/icons/logos/max.svg',
      'anthropic': 'assets/icons/logos/anthropic.svg',
      'claude': 'assets/icons/logos/anthropic.svg',
      'claude pro': 'assets/icons/logos/anthropic.svg',
      'claude ai': 'assets/icons/logos/anthropic.svg',
    };

    // 1. Direct match
    if (localLogos.containsKey(clean)) {
      return localLogos[clean];
    }

    // 2. Substring match
    for (final entry in localLogos.entries) {
      if (clean.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _getAssetLogoPath(serviceName);

    if (assetPath != null) {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SvgPicture.asset(assetPath, fit: BoxFit.contain),
      );
    }

    // Fallback: Dual-tone gradient monogram
    return _buildGradientMonogram();
  }

  Widget _buildGradientMonogram() {
    final preset = PresetCatalog.getByName(serviceName);
    final baseColor =
        customColor ??
        preset?.brandColor ??
        _generateBaseColorFromName(serviceName);

    final colors = [
      baseColor,
      Color.lerp(baseColor, Colors.black, 0.22) ?? baseColor,
    ];

    final initial = serviceName.trim().isNotEmpty
        ? serviceName.trim()[0].toUpperCase()
        : 'S';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.44,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Color _generateBaseColorFromName(String name) {
    if (name.isEmpty) return const Color(0xFF4F46E5);
    final hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
    const colors = [
      Color(0xFF4F46E5), // Indigo
      Color(0xFF2563EB), // Blue
      Color(0xFF7C3AED), // Violet
      Color(0xFFDB2777), // Pink
      Color(0xFFE11D48), // Rose
      Color(0xFFD97706), // Amber
      Color(0xFF059669), // Emerald
      Color(0xFF0891B2), // Cyan
      Color(0xFF475569), // Slate
    ];
    return colors[hash % colors.length];
  }
}
