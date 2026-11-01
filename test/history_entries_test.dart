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

/// Answers at once: the text with the target code after it.
class _EchoTranslator implements TranslatorService {
  int calls = 0;

  @override
  Future<TranslationResult> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    calls++;
    return TranslationResult(text: '$text ($to)', detected: 'en');
  }
}

/// Lets a translation that the test did not await finish.
Future<void> settle() =>
    Future<void>.delayed(const Duration(milliseconds: 200));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final history = HistoryRepository();
  final settings = AppSettingsController();
  final profile = ProfileRepository.instance;
  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('kopri_history_test');
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
    // Most tests call translate() themselves, without the typing timer.
    await settings.setAutoTranslate(false);
    await history.init();
    await profile.ensureInit();
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  setUp(() async {
    await history.clear();
    await profile.clearAll();
  });

  TranslateController make([_EchoTranslator? t]) {
    final c = TranslateController(
      repo: history,
      settings: settings,
      incomingText: ValueNotifier<IncomingText?>(null),
      service: t ?? _EchoTranslator(),
    );
    addTearDown(c.dispose);
    return c;
  }

  test('Diňe kursor süýşse, täze terjime başlanmaýar', () async {
    await settings.setAutoTranslate(true);
    await settings.setTranslateDelayMs(50);
    addTearDown(() async {
      await settings.setAutoTranslate(false);
      await settings.setTranslateDelayMs(700);
    });
    final t = _EchoTranslator();
    final c = make(t);

    c.ctrl.text = 'good';
    await settle();
    expect(t.calls, 1);

    c.ctrl.selection = const TextSelection.collapsed(offset: 2); // a tap
    await settle();
    expect(t.calls, 1);
    expect(history.getAll(), hasLength(1));
  });

  test(
    'Şol bir tekst täzeden terjime edilse, ýazgy goşulmaýar we XP berilmeýär',
    () async {
      final c = make();
      c.ctrl.text = 'good';
      await c.translate();
      final xp = profile.xp;
      final progress = profile.todayProgress;

      await c.translate(); // e.g. the Translate button
      expect(history.getAll(), hasLength(1));
      expect(profile.xp, xp);
      expect(profile.todayProgress, progress);
      expect(profile.lastXpAwarded, 0); // no "+N XP" toast again
    },
  );

  test(
    'Dowam etdirilen tekst soňky ýazgyny täzeleýär, maksat bir gezek sanalýar',
    () async {
      final c = make();
      c.ctrl.text = 'good';
      await c.translate();
      c.ctrl.text = 'good morning';
      await c.translate();

      final all = history.getAll();
      expect(all.map((e) => e.source), ['good morning']);
      expect(all.single.result, 'good morning (ru)');
      expect(profile.todayProgress, 1);
      expect(profile.translationsToday, 1);
    },
  );

  test(
    'Dowam etdirilen tekst üçin diňe goşulan harplara XP berilýär',
    () async {
      final c = make();
      c.ctrl.text = 'good';
      await c.translate(); // "good (ru)": 6 letters
      final xp = profile.xp;

      c.ctrl.text = 'good morning';
      await c.translate(); // "good morning (ru)": 13 letters, 7 more
      expect(profile.xp - xp, 7);
      expect(profile.lastXpAwarded, 7);
      expect(profile.lastXpChars, 7);
    },
  );

  test('Gysgaldylan tekst ýa-da başga dil täze ýazgy goşýar', () async {
    final c = make();
    c.ctrl.text = 'good morning';
    await c.translate();
    c.ctrl.text = 'good';
    await c.translate(); // shorter: not a continuation
    c.setTo('tr');
    await settle();

    expect(
      history.getAll().map((e) => '${e.source} → ${e.to}'),
      unorderedEquals(['good morning → ru', 'good → ru', 'good → tr']),
    );
    expect(profile.todayProgress, 3);
  });
}
