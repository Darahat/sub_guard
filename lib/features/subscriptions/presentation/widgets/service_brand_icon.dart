import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final preset = PresetCatalog.getByName(serviceName);
    final color =
        customColor ??
        preset?.brandColor ??
        _generateColorFromName(serviceName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.24),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          serviceName.isNotEmpty ? serviceName.trim()[0].toUpperCase() : 'S',
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

  Color _generateColorFromName(String name) {
    if (name.isEmpty) return const Color(0xFF007AFF);
    final hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
    const colors = [
      Color(0xFF007AFF), // Blue
      Color(0xFF5856D6), // Purple
      Color(0xFFFF2D55), // Pink
      Color(0xFFFF9500), // Orange
      Color(0xFF34C759), // Green
      Color(0xFF00C7BE), // Teal
      Color(0xFFAF52DE), // Violet
      Color(0xFFFF3B30), // Red
    ];
    return colors[hash % colors.length];
  }
}
