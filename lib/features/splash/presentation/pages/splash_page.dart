import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../auth/presentation/pages/auth_choice_page.dart';

/// Splash screen with animated logo and loader.
///
/// Flow:
/// 1. Show animated logo (pulsating + rotating)
/// 2. Check stored token
/// 3. If valid token → navigate to Main Page
/// 4. If no token → navigate to Registration
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSplashFlow();
  }

  void _setupAnimations() {
    // Animation controller (2 second loop)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Pulsating scale animation (0.9 → 1.1 → 0.9)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.9)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_animationController);

    // Subtle rotation animation (0 → 0.05 radians)
    _rotationAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Fade in animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));

    _animationController.repeat();
  }

  Future<void> _startSplashFlow() async {
    try {
      // Show splash for minimum 2 seconds (for visual effect)
      final minDuration = Future.delayed(const Duration(seconds: 2));

      // Check authentication
      final tokenService = TokenStorageService();
      final isAuth = await tokenService.isAuthenticated();
      final userData = await tokenService.getUserData();

      // Wait for minimum duration
      await minDuration;

      if (!mounted) return;

      // Navigate based on auth status
      if (isAuth && userData != null) {
        // User is authenticated → go to Home (with Main tab as default)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(
              userName: userData['userName']!,
              userGroup: userData['userGroup']!,
              initialIndex: 1, // Main tab
            ),
          ),
        );
      } else {
        // Not authenticated → go to Auth Choice (Login/Registration)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const AuthChoicePage(),
          ),
        );
      }
    } catch (e) {
      print('Splash error: $e');
      // On error, go to auth choice
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AuthChoicePage(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated Logo
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primarySkyBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primarySkyBlue.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volunteer_activism,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // App Name
              FadeTransition(
                opacity: _opacityAnimation,
                child: Text(
                  'Donation',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppTheme.primarySkyBlue,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              FadeTransition(
                opacity: _opacityAnimation,
                child: Text(
                  'Помогаем вместе',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                ),
              ),

              const Spacer(flex: 2),

              // Loading indicator
              Column(
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primarySkyBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Загрузка...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

