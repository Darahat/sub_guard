import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

class SkeletonShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const SkeletonShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Geometry matched shimmer
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurface : Colors.grey[300]!,
      highlightColor: isDark
          ? AppColors.darkSurfaceElevated
          : Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(borderRadius)
              : null,
        ),
      ),
    );
  }
}

class DashboardSkeletonLoader extends StatelessWidget {
  const DashboardSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Stats Row Skeleton
            Row(
              children: [
                Expanded(
                  child: SkeletonShimmer(
                    width: double.infinity,
                    height: 100,
                    borderRadius: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SkeletonShimmer(
                    width: double.infinity,
                    height: 100,
                    borderRadius: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Action Hub / Budget Progress Skeleton
            const SkeletonShimmer(
              width: double.infinity,
              height: 120,
              borderRadius: 20,
            ),
            const SizedBox(height: 24),
            // Subscriptions List Header
            const SkeletonShimmer(width: 150, height: 24, borderRadius: 6),
            const SizedBox(height: 16),
            // Subscriptions List Items
            ...List.generate(
              4,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: SkeletonShimmer(
                  width: double.infinity,
                  height: 72,
                  borderRadius: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InsightsSkeletonLoader extends StatelessWidget {
  const InsightsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart placeholder
            const SkeletonShimmer(
              width: double.infinity,
              height: 200,
              borderRadius: 20,
            ),
            const SizedBox(height: 24),
            // Legend/Stats placeholders
            Row(
              children: [
                Expanded(
                  child: SkeletonShimmer(
                    width: double.infinity,
                    height: 60,
                    borderRadius: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SkeletonShimmer(
                    width: double.infinity,
                    height: 60,
                    borderRadius: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // List Items
            ...List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: SkeletonShimmer(
                  width: double.infinity,
                  height: 80,
                  borderRadius: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListSkeletonLoader extends StatelessWidget {
  const ListSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          6,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: SkeletonShimmer(
              width: double.infinity,
              height: 64,
              borderRadius: 12,
            ),
          ),
        ),
      ),
    );
  }
}
