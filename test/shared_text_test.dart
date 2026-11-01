import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:kopri/core/app/incoming_text.dart';
import 'package:kopri/core/controllers/app_settings_controller.dart';
import 'package:kopri/core/theme/app_theme.dart';
import 'package:kopri/core/widgets/app_shell.dart';
import 'package:kopri/features/history/data/history_repository.dart';
import 'package:kopri/features/history/presentation/history_screen.dart';
import 'package:kopri/features/translate/presentation/translate_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final history = HistoryRepository();
  final settings = AppSettingsController();
  late Directory dir;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false; // as in AppBootstrap
    dir = await Directory.systemTemp.createTemp('kopri_shared_text_test');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => dir.path,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('home_widget'),
      (_) async => true,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
    );
    Hive.init(dir.path);
    await settings.init();
    await history.init();
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  Widget app(Widget home) => AppProviders(
    controller: settings,
    child: MaterialApp(theme: AppTheme.dark(), home: home),
  );

  testWidgets('Taryh açyk wagty täze ýazgy şol bada görünýär', (tester) async {
    await tester.pumpWidget(app(Scaffold(body: HistoryScreen(repo: history))));
    expect(find.text('thank you'), findsNothing);

    await tester.runAsync(
      () => history.add(
        source: 'thank you',
        result: 'e dupe',
        from: 'en',
        to: 'yo',
      ),
    );
    await tester.pump();
    expect(find.text('thank you'), findsOneWidget);
  });

  testWidgets('Tekst paýlaşylanda Terjime bölümi açylýar', (tester) async {
    final incoming = ValueNotifier<IncomingText?>(null);
    await tester.pumpWidget(
      app(AppShell(repo: history, incomingText: incoming, initialScreen: 4)),
    );
    await tester.pump();
    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.byType(TranslateScreen), findsNothing);

    incoming.value = const IncomingText('thank you', 1);
    await tester.pump();
    await tester.pump();
    expect(find.byType(TranslateScreen), findsOneWidget);
    expect(find.byType(HistoryScreen), findsNothing);

    // The Translate tab starts a real translation of the text (here it fails,
    // there is no network). Let its timers end before the test ends.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpWidget(const SizedBox()); // dispose the screens
  });
}
