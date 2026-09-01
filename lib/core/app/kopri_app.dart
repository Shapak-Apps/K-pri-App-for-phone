import 'package:flutter/material.dart';

import 'incoming_text.dart';
import '../controllers/app_settings_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/splash_screen.dart';
import '../../../features/conversation/data/tts_service.dart';
import '../../../features/history/data/history_repository.dart';

class KopriApp extends StatelessWidget {
  final HistoryRepository repo;
  final AppSettingsController settings;
  final int initialScreen;

  const KopriApp({
    super.key,
    required this.repo,
    required this.settings,
    this.initialScreen = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        TtsService.applySettings(settings);
        final density = settings.compact
            ? VisualDensity.compact
            : VisualDensity.standard;
        final light = AppTheme.light(
          fontScale: settings.fontScale,
          accent: settings.accentIndex,
        ).copyWith(visualDensity: density);
        final dark = AppTheme.dark(
          fontScale: settings.fontScale,
          accent: settings.accentIndex,
        ).copyWith(visualDensity: density);

        return MaterialApp(
          title: 'Kopri',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: light,
          darkTheme: dark,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(
              ctx,
            ).copyWith(textScaler: TextScaler.linear(settings.fontScale)),
            child: child!,
          ),
          home: SplashScreen(
            initTask: () async {},
            next: (_) => AppShell(
              repo: repo,
              incomingText: incomingText,
              initialScreen: initialScreen,
            ),
          ),
        );
      },
    );
  }
}
