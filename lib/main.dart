import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/controllers/app_settings_controller.dart';
import 'core/native/clip_filter_native.dart';
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

final openScreen = ValueNotifier<int?>(null);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoogleFonts.config.allowRuntimeFetching = false;

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
    if (call.method == 'openScreen' && call.arguments is int) {
      openScreen.value = call.arguments as int;
    }
    return null;
  });

  const clipChannel = MethodChannel('kopri/clip_filter');
  clipChannel.setMethodCallHandler((call) async {
    if (call.method == 'classify' && call.arguments is Map) {
      final m = Map<String, dynamic>.from(call.arguments as Map);
      final id = m['id'] as int;
      final text = (m['text'] as String?) ?? '';
      final skip = ClipFilterNative.instance.classify(text);
      final should = skip == ClipSkip.translatable;
      debugPrint(
          '[clip_filter] text="${text.length > 40 ? text.substring(0, 40) : text}" → $skip → should=$should');
      try {
        await clipChannel.invokeMethod('filterResult', {
          'id': id,
          'should': should,
        });
      } catch (_) {}
    }
    return null;
  });

  int? pendingScreen;
  try {
    pendingScreen = await intentChannel.invokeMethod<int>('getPendingScreen');
  } catch (_) {}

  String? pendingText;
  try {
    pendingText = await intentChannel.invokeMethod<String>('getPendingText');
  } catch (_) {}
  if (pendingText != null && pendingText.trim().isNotEmpty) {
    incomingText.value = IncomingText(
      pendingText.trim(),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  final repo = HistoryRepository();
  final settings = AppSettingsController();
  await Future.wait([repo.init(), settings.init()]);
  await repo.purgeOlderThan(settings.autoCleanDays);

  runApp(
    AppProviders(
      controller: settings,
      child: KopriApp(
        repo: repo,
        settings: settings,
        initialScreen: pendingScreen ?? 0,
      ),
    ),
  );
}

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