import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/splash/presentation/pages/splash_page.dart';
import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/core/theme/theme_mode.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final effectiveThemeMode = ref.read(themeModeProvider.notifier).toMaterialThemeMode();

    if (themeMode == AppThemeMode.auto) {
      ref.read(themeModeProvider.notifier).listenToLightSensor(ref);
    }

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
