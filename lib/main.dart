import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/controllers/app_settings_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';
import 'core/widgets/splash_screen.dart';
import 'features/conversation/data/tts_service.dart';
import 'features/history/data/history_repository.dart';

class IncomingText {
  final String text;
  final int id;
  const IncomingText(this.text, this.id);
}

final incomingText = ValueNotifier<IncomingText?>(null);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  const intentChannel = MethodChannel('kopri/intent');
  intentChannel.setMethodCallHandler((call) async {
    if (call.method == 'onText' && call.arguments is Map) {
      final m = Map<String, dynamic>.from(call.arguments as Map);
      final text = (m['text'] as String?)?.trim() ?? '';
      final id = (m['id'] as int?) ?? DateTime.now().millisecondsSinceEpoch;
      if (text.isNotEmpty) incomingText.value = IncomingText(text, id);
    }
  });

  intentChannel
      .invokeMethod<String>('getPendingText')
      .then((t) {
        final text = t?.trim() ?? '';
        if (text.isNotEmpty) {
          incomingText.value = IncomingText(
            text,
            DateTime.now().millisecondsSinceEpoch,
          );
        }
      })
      .catchError((_) {});

  final repo = HistoryRepository();
  final settings = AppSettingsController();
  await Future.wait([repo.init(), settings.init()]);
  await repo.purgeOlderThan(settings.autoCleanDays);

  runApp(
    AppProviders(
      controller: settings,
      child: KopriApp(repo: repo, settings: settings),
    ),
  );
}

class KopriApp extends StatelessWidget {
  final HistoryRepository repo;
  final AppSettingsController settings;
  const KopriApp({super.key, required this.repo, required this.settings});

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
            next: (_) => AppShell(repo: repo, incomingText: incomingText),
          ),
        );
      },
    );
  }
}
