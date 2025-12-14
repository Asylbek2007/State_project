import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Shimmer effect widget for skeleton loaders.
///
/// Creates an animated gradient that moves across the widget
/// to create a shimmer/loading effect.
class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final baseColor = isDark 
        ? const Color(0xFF2C2C2C) 
        : widget.baseColor;
    final highlightColor = isDark
        ? const Color(0xFF3C3C3C)
        : widget.highlightColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0.0),
              end: Alignment(1.0 - _controller.value * 2, 0.0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Shimmer effect with custom gradient stops for more control.
class ShimmerGradient extends StatelessWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final double progress;

  const ShimmerGradient({
    super.key,
    required this.child,
    required this.progress,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final base = isDark ? const Color(0xFF2C2C2C) : baseColor;
    final highlight = isDark ? const Color(0xFF3C3C3C) : highlightColor;

    return ShaderMask(
      shaderCallback: (bounds) {
        final width = bounds.width;
        final shimmerWidth = width * 0.3;
        final startX = (width + shimmerWidth) * progress - shimmerWidth;

        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            base,
            base,
            highlight,
            highlight,
            base,
            base,
          ],
          stops: [
            0.0,
            math.max(0.0, (startX - shimmerWidth) / width),
            math.max(0.0, startX / width),
            math.min(1.0, (startX + shimmerWidth) / width),
            math.min(1.0, (startX + shimmerWidth * 2) / width),
            1.0,
          ],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

