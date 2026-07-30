import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/splash/presentation/pages/splash_page.dart';
import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/core/theme/theme_mode.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveThemeMode = ref.watch(effectiveThemeModeProvider);

    return MaterialApp(
      title: 'AquaLife',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: effectiveThemeMode,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}