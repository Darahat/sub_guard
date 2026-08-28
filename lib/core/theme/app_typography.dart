import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  /// Hero financial numbers (32sp-40sp) with tabular figures for jitter-free numbers
  static const TextStyle heroFinancial = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Medium financial figures in cards & list items (18sp-24sp)
  static const TextStyle cardFinancial = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Compact tabular figures for rows, tables, and dense metrics (13sp-15sp)
  static const TextStyle compactFinancial = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Apple-style uppercase section overheads
  static const TextStyle sectionOverhead = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textSecondary,
  );

  /// High contrast body / metadata
  static const TextStyle bodyMetadata = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );
}
