import 'package:flutter/material.dart';
import 'package:aqua_life/features/splash/presentation/pages/splash_page.dart';
import 'package:aqua_life/app/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaLife',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
