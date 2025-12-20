import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Promo carousel widget with automatic scrolling.
///
/// Displays promotional banners or important goals in a carousel format.
class PromoCarousel extends StatefulWidget {
  final List<PromoItem> items;
  final double height;
  final Duration autoPlayInterval;

  const PromoCarousel({
    super.key,
    required this.items,
    this.height = 180,
    this.autoPlayInterval = const Duration(seconds: 4),
  });

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, index, realIndex) {
            final item = widget.items[index];
            return _buildCarouselItem(item);
          },
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            autoPlay: widget.items.length > 1,
            autoPlayInterval: widget.autoPlayInterval,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOutCubic,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
            scrollDirection: Axis.horizontal,
          ),
        ),
        if (widget.items.length > 1) _buildPageIndicator(),
      ],
    );
  }

  Widget _buildCarouselItem(PromoItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        gradient: item.gradient ??
            const LinearGradient(
              colors: [
                AppTheme.primarySkyBlue,
                AppTheme.accentBlue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primarySkyBlue.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Stack(
          children: [
            // Background pattern (optional)
            if (item.icon != null)
              Positioned(
                right: -20,
                top: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    item.icon,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      size: 28,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                  ],
                  Flexible(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacing12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.items.length,
          (index) => Container(
            width: _currentIndex == index ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _currentIndex == index
                  ? AppTheme.primarySkyBlue
                  : AppTheme.primarySkyBlue.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}

/// Model for promo carousel items.
class PromoItem {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final LinearGradient? gradient;
  final VoidCallback? onTap;

  const PromoItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.gradient,
    this.onTap,
  });
}

