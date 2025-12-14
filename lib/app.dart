import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/splash/presentation/pages/splash_page.dart';

/// Root application widget.
class DonationApp extends ConsumerWidget {
  const DonationApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeState = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Donation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeModeState.themeMode,
      home: const SplashPage(),
    );
  }
}

