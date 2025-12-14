import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'skeleton_card.dart';
import 'shimmer.dart';

/// Skeleton list widget for loading states.
///
/// Displays a list of skeleton cards with shimmer effect.
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsets? padding;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// Pre-built skeleton list for goals.
class SkeletonGoalsList extends StatelessWidget {
  final int itemCount;

  const SkeletonGoalsList({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const SkeletonGoalCard();
      },
    );
  }
}

/// Pre-built skeleton list for donations.
class SkeletonDonationsList extends StatelessWidget {
  final int itemCount;

  const SkeletonDonationsList({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const SkeletonDonationCard();
      },
    );
  }
}

/// Pre-built skeleton list for community stats.
class SkeletonCommunityStats extends StatelessWidget {
  const SkeletonCommunityStats({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final baseColor = isDark 
        ? const Color(0xFF2C2C2C) 
        : const Color(0xFFE0E0E0);
    final highlightColor = isDark
        ? const Color(0xFF3C3C3C)
        : const Color(0xFFF5F5F5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < 2 ? AppTheme.spacing12 : 0,
              ),
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Column(
                children: [
                  Shimmer(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Shimmer(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      height: 20,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Shimmer(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      height: 12,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

