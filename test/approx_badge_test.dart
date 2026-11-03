import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kopri/core/app/incoming_text.dart';
import 'package:kopri/core/controllers/app_settings_controller.dart';
import 'package:kopri/features/history/data/history_repository.dart';
import 'package:kopri/features/profile/data/profile_repository.dart';
import 'package:kopri/features/translate/data/translator_service.dart';
import 'package:kopri/features/translate/presentation/translate_controller.dart';

/// Every translation is approximate, like a word-by-word one from the
/// built-in dictionary.
class _ApproxTranslator implements TranslatorService {
  @override
  Future<TranslationResult> translate(
    String text, {
    required String from,
    required String to,
  }) async => TranslationResult(text: '$text ($to)', approx: true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final history = HistoryRepository();
  final settings = AppSettingsController();
  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('kopri_approx_test');
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
    // The tests call translate() themselves, without the typing timer.
    await settings.setAutoTranslate(false);
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
      service: _ApproxTranslator(),
    );
    addTearDown(c.dispose);
    return c;
  }

  test('✕ bilen arassalananda ≈ belgisi ýitýär', () async {
    final c = make();
    c.ctrl.text = 'hello';
    await c.translate();
    expect(c.approx, isTrue);

    c.clearInput(); // the ✕ button
    expect(c.approx, isFalse);
  });

  test('Tekst pozulanda ≈ belgisi ýitýär', () async {
    final c = make();
    c.ctrl.text = 'hello';
    await c.translate();
    expect(c.approx, isTrue);

    c.ctrl.text = ''; // Backspace until the field is empty
    expect(c.approx, isFalse);
  });

  test('Täze takmyny terjime ≈ belgisini ýene görkezýär', () async {
    final c = make();
    c.ctrl.text = 'hello';
    await c.translate();
    c.clearInput();

    c.ctrl.text = 'good night';
    await c.translate();
    expect(c.approx, isTrue);
  });
}
