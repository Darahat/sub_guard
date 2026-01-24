import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Calm, Trust-focused Palette
  static const Color primary = Color(0xFF2D3748); // Dark Blue-Gray
  static const Color primaryLight = Color(0xFF4A5568);
  static const Color primaryDark = Color(0xFF1A202C);

  // Accent Colors
  static const Color accent = Color(0xFF48BB78); // Success Green
  static const Color accentLight = Color(0xFF68D391);
  static const Color accentDark = Color(0xFF38A169);

  // Semantic Colors
  static const Color success = Color(0xFF48BB78); // Green - savings
  static const Color warning = Color(0xFFF6AD55); // Orange - trial ending
  static const Color error = Color(0xFFFC8181); // Red - urgent renewal
  static const Color info = Color(0xFF4299E1); // Blue - information

  // Background Colors
  static const Color background = Color(0xFFF7FAFC);
  static const Color backgroundSecondary = Color(0xFFEDF2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textHint = Color(0xFFA0AEC0);
  static const Color textDisabled = Color(0xFFCBD5E0);

  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF7FAFC);
  static const Color borderDark = Color(0xFFCBD5E0);

  // Chart Colors
  static const Color chartColor1 = Color(0xFF667EEA);
  static const Color chartColor2 = Color(0xFF48BB78);
  static const Color chartColor3 = Color(0xFFF6AD55);
  static const Color chartColor4 = Color(0xFFFC8181);
  static const Color chartColor5 = Color(0xFF4299E1);
  static const Color chartColor6 = Color(0xFF9F7AEA);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF7FAFC);

  // Overlay Colors
  static const Color overlay = Color(0x80000000); // 50% black
  static const Color overlayLight = Color(0x40000000); // 25% black

  // Status Colors (subscription types)
  static const Color activeSubscription = Color(0xFF48BB78);
  static const Color trialSubscription = Color(0xFF4299E1);
  static const Color cancelledSubscription = Color(0xFF718096);
  static const Color expiredSubscription = Color(0xFFFC8181);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, accentLight],
  );
}
