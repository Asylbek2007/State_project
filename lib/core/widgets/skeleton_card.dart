import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'shimmer.dart';

/// Skeleton card widget for loading states.
///
/// Displays a card-shaped skeleton with shimmer effect.
class SkeletonCard extends StatelessWidget {
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const SkeletonCard({
    super.key,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius,
  });

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

    return Container(
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      padding: padding ?? const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Shimmer(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Skeleton card with multiple lines (for text content).
class SkeletonCardWithLines extends StatelessWidget {
  final int lineCount;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const SkeletonCardWithLines({
    super.key,
    this.lineCount = 3,
    this.height,
    this.margin,
    this.padding,
  });

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

    return Container(
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      padding: padding ?? const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lineCount, (index) {
          final isLast = index == lineCount - 1;
          return Padding(
            padding: EdgeInsets.only(
              bottom: isLast ? 0 : AppTheme.spacing8,
            ),
            child: Shimmer(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                height: 16,
                width: isLast ? double.infinity * 0.6 : double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Skeleton for goal card (specific layout).
class SkeletonGoalCard extends StatelessWidget {
  const SkeletonGoalCard({super.key});

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

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Shimmer(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 20,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          
          // Description
          Shimmer(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Shimmer(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 16,
              width: double.infinity * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          
          // Progress bar
          Shimmer(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          
          // Stats row
          Row(
            children: [
              Expanded(
                child: Shimmer(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Shimmer(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton for donation card.
class SkeletonDonationCard extends StatelessWidget {
  const SkeletonDonationCard({super.key});

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

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Shimmer(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Shimmer(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Shimmer(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: 14,
                    width: double.infinity * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Amount
          Shimmer(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 80,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for total amount card.
class SkeletonTotalAmountCard extends StatelessWidget {
  const SkeletonTotalAmountCard({super.key});

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

    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing16),
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            baseColor,
            baseColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Shimmer(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Shimmer(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        height: 32,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

