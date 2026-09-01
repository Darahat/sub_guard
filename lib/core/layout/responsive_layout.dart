import 'package:flutter/material.dart';

/// Shared breakpoint constants and helpers for adaptive layouts.
///
/// Usage:
/// `dart
/// if (Breakpoints.isTablet(context)) { ... }
/// `
class Breakpoints {
  const Breakpoints._();

  /// Mobile: < 600dp
  static const double mobile = 0;

  /// Tablet: >= 600dp
  static const double tablet = 600;

  /// Desktop: >= 900dp
  static const double desktop = 900;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;
}

/// Holds different values for different breakpoints and resolves the
/// correct one based on the current screen width.
///
/// Example:
/// `dart
/// final columns = AdaptiveValue(mobile: 1, tablet: 2).resolve(context);
/// `
class AdaptiveValue<T> {
  final T mobile;
  final T tablet;
  final T? desktop;

  const AdaptiveValue({
    required this.mobile,
    required this.tablet,
    this.desktop,
  });

  T resolve(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (desktop != null && w >= Breakpoints.desktop) return desktop as T;
    if (w >= Breakpoints.tablet) return tablet;
    return mobile;
  }
}

/// Shows a modal bottom sheet that is horizontally constrained to [maxWidth]
/// on tablet and desktop, and full-width on mobile.
Future<T?> showAdaptiveBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  double maxWidth = 600,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    constraints: Breakpoints.isTablet(context)
        ? BoxConstraints(maxWidth: maxWidth)
        : null,
    builder: builder,
  );
}
