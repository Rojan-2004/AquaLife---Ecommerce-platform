import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/core/theme/theme_mode.dart';

class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Appearance', style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SegmentedButton<AppThemeMode>(
            segments: const [
              ButtonSegment(
                value: AppThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: AppThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
              ButtonSegment(
                value: AppThemeMode.auto,
                label: Text('Auto'),
                icon: Icon(Icons.brightness_auto_outlined),
              ),
            ],
            selected: {currentMode},
            onSelectionChanged: (Set<AppThemeMode> selected) {
              if (selected.isNotEmpty) {
                ref.read(themeModeProvider.notifier).setThemeMode(selected.first);
              }
            },
          ),
        ],
      ),
    );
  }
}
