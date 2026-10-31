import 'dart:async';
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
import 'package:kopri/features/translate/presentation/translation_state.dart';

/// Answers only when the test calls [answer], so the test decides when a
/// translation ends. The result is the text with the target code after it.
class _SlowTranslator implements TranslatorService {
  final calls = <({String text, String from, String to})>[];
  final _pending = <Completer<TranslationResult>>[];

  @override
  Future<TranslationResult> translate(
    String text, {
    required String from,
    required String to,
  }) {
    calls.add((text: text, from: from, to: to));
    final c = Completer<TranslationResult>();
    _pending.add(c);
    return c.future;
  }

  /// Ends the oldest running translation and lets the controller finish.
  Future<void> answer() async {
    final call = calls[calls.length - _pending.length];
    _pending
        .removeAt(0)
        .complete(TranslationResult(text: '${call.text} (${call.to})', detected: 'en'));
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final history = HistoryRepository();
  final settings = AppSettingsController();
  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('kopri_rerun_test');
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

  setUp(() async {
    await history.clear();
  });

  TranslateController make(_SlowTranslator t) => TranslateController(
    repo: history,
    settings: settings,
    incomingText: ValueNotifier<IncomingText?>(null),
    service: t,
  );

  test('Terjime wagtynda ýazylan tekst hem terjime edilýär', () async {
    final t = _SlowTranslator();
    final c = make(t);
    c.ctrl.text = 'hello';
    unawaited(c.translate());
    c.ctrl.text = 'hello friend';
    unawaited(c.translate()); // "hello" is still running

    await t.answer();
    expect(t.calls.map((e) => e.text), ['hello', 'hello friend']);

    await t.answer();
    expect((c.state as SuccessState).text, 'hello friend (ru)');
    c.dispose();
  });

  test('Terjime wagtynda saýlanan dil hem ulanylýar, taryhda öňki dil', () async {
    final t = _SlowTranslator();
    final c = make(t);
    c.ctrl.text = 'good night';
    unawaited(c.translate());
    c.setTo('tr'); // "ru" is still running

    await t.answer();
    expect(history.getAll().single.to, 'ru');
    expect(t.calls.map((e) => e.to), ['ru', 'tr']);

    await t.answer();
    expect((c.state as SuccessState).text, 'good night (tr)');
    c.dispose();
  });

  test('Tekst we dil üýtgemese, gaýtadan terjime edilmeýär', () async {
    final t = _SlowTranslator();
    final c = make(t);
    c.ctrl.text = 'hello';
    unawaited(c.translate());
    unawaited(c.translate()); // the same text, e.g. after a cursor tap

    await t.answer();
    expect(t.calls, hasLength(1));
    expect(history.getAll(), hasLength(1));
    c.dispose();
  });
}
