import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kopri/core/app/incoming_text.dart';
import 'package:kopri/core/controllers/app_settings_controller.dart';
import 'package:kopri/features/history/data/history_repository.dart';
import 'package:kopri/features/profile/data/profile_repository.dart';
import 'package:kopri/features/translate/data/translator_service.dart';
import 'package:kopri/features/translate/presentation/translate_controller.dart';
import 'package:kopri/features/translate/presentation/translation_state.dart';

/// Answers at once: the text with the target code after it.
class _EchoTranslator implements TranslatorService {
  @override
  Future<TranslationResult> translate(
    String text, {
    required String from,
    required String to,
  }) async => TranslationResult(text: '$text ($to)', detected: 'en');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final history = HistoryRepository();
  final settings = AppSettingsController();
  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('kopri_keyboard_test');
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
    // Boxes in memory: a widget test runs in fake time, and file work that
    // starts there does not end. The repositories get these open boxes.
    for (final name in ['settings', 'history', 'profile']) {
      await Hive.openBox(name, bytes: Uint8List(0));
    }
    await settings.init(); // auto translate is on, as in the app
    await history.init();
    await ProfileRepository.instance.ensureInit();
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  TranslateController make() {
    final c = TranslateController(
      repo: history,
      settings: settings,
      incomingText: ValueNotifier<IncomingText?>(null),
      service: _EchoTranslator(),
    );
    addTearDown(c.dispose);
    return c;
  }

  Widget field(TranslateController c) => MaterialApp(
    home: Scaffold(
      body: TextField(controller: c.ctrl, focusNode: c.focus),
    ),
  );

  testWidgets('Arakesmeden soň klawiatura açyk galýar', (tester) async {
    final c = make();
    await tester.pumpWidget(field(c));
    await tester.enterText(find.byType(TextField), 'hello');
    expect(c.focus.hasFocus, isTrue);

    // The user stops to think. The translation comes after 0.7 s.
    await tester.pump(const Duration(seconds: 3));
    expect(c.state, isA<SuccessState>());
    expect(c.focus.hasFocus, isTrue);
  });

  testWidgets('Meýdançadan daşyna basylanda klawiatura ýapylýar', (
    tester,
  ) async {
    final c = make();
    await tester.pumpWidget(field(c));
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump(const Duration(seconds: 1));
    expect(c.focus.hasFocus, isTrue);

    c.unfocus(); // what a tap outside the field calls
    await tester.pump(const Duration(seconds: 3));
    expect(c.focus.hasFocus, isFalse);
  });
}
