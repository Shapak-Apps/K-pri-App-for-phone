import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:kopri/core/controllers/app_settings_controller.dart';
import 'package:kopri/core/l10n/app_strings.dart';
import 'package:kopri/core/theme/app_theme.dart';
import 'package:kopri/core/widgets/linkage_language_picker.dart';
import 'package:kopri/features/profile/data/profile_repository.dart';
import 'package:kopri/features/profile/data/profile_streak_service.dart';
import 'package:kopri/features/profile/presentation/widgets/streak_card.dart';
import 'package:kopri/features/translate/presentation/translation_state.dart';
import 'package:kopri/features/translate/presentation/widgets/bridge_loader.dart';
import 'package:kopri/features/translate/presentation/widgets/input_card.dart';
import 'package:kopri/features/translate/presentation/widgets/language_selector.dart';
import 'package:kopri/features/translate/presentation/widgets/result_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettingsController();
  late Directory dir;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false; // as in AppBootstrap
    dir = await Directory.systemTemp.createTemp('kopri_texts_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => dir.path,
        );
    Hive.init(dir.path);
    await settings.init();
    await ProfileRepository.instance.ensureInit();
    await ProfileRepository.instance.clearAll(); // streak 0, best 0
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  Future<void> show(WidgetTester tester, AppLang lang, Widget child) async {
    await tester.runAsync(() => settings.setLang(lang));
    await tester.pumpWidget(
      AppProviders(
        controller: settings,
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  testWidgets('Terjime ekrany iňlis dilinde', (tester) async {
    await show(
      tester,
      AppLang.en,
      // Not a ListView: it builds only the children that are on the screen.
      SingleChildScrollView(
        child: Column(
          children: [
            LanguageSelector(
              from: 'auto',
              to: 'ru',
              onFromChanged: (_) {},
              onToChanged: (_) {},
              onSwap: () {},
              canSwap: false,
            ),
            InputCard(
              controller: TextEditingController(),
              onClear: () {},
              onMicTap: () {},
              autoDetected: 'en',
            ),
            InputCard(
              controller: TextEditingController(),
              onClear: () {},
              onMicTap: () {},
              isListening: true,
            ),
            const ResultCard(state: IdleState()),
            const BridgeLoader(),
          ],
        ),
      ),
    );

    expect(find.text('SOURCE'), findsNWidgets(3)); // the pill and 2 cards
    expect(find.text('TRANSLATION'), findsNWidgets(2)); // the pill, result
    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('AUTO · ENGLISH'), findsOneWidget);
    expect(find.text('Type text to translate…'), findsOneWidget);
    expect(find.text('Listening…'), findsOneWidget);
    expect(find.text('The translation will show here.'), findsOneWidget);
    expect(find.text('TRANSLATING'), findsOneWidget);

    await tester.pumpWidget(const SizedBox()); // stop the loader animation
  });

  testWidgets('Ýalňyşlyk ýazgysy rus dilinde', (tester) async {
    await show(tester, AppLang.ru, const ResultCard(state: ErrorState('x')));
    expect(find.text('ОШИБКА'), findsOneWidget);
  });

  testWidgets('Dil saýlaýjynyň toparlary iňlis dilinde', (tester) async {
    await show(
      tester,
      AppLang.en,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => LinkageLanguagePicker.show(
            context,
            currentCode: 'auto',
            includeAuto: true,
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('🤖 Auto'), findsOneWidget);
    expect(find.text('🌍 Popular'), findsOneWidget);
    expect(find.text('🌐 Auto'), findsOneWidget); // the language row
  });

  testWidgets('Seriýa kartoçkasy iňlis dilinde', (tester) async {
    await show(tester, AppLang.en, const StreakCard());
    expect(find.text('0 days'), findsOneWidget);
    expect(find.text('Start your streak today!'), findsOneWidget);
    expect(find.text('Best: 0 days'), findsOneWidget);
  });

  test('Täze açarlar 4 dilde hem bar', () {
    const keys = [
      'lang_auto',
      'lang_auto_short',
      'result_placeholder',
      'translating_label',
      'error_label',
      'approx_badge',
      'region_popular',
      'region_europe',
      'region_asia',
      'region_middle_east',
      'region_africa',
      'region_other',
      'streak_record',
      'streak_days_few',
      'streak_msg_0',
      'streak_msg_1',
      'streak_msg_3',
      'streak_msg_7',
      'streak_msg_14',
      'streak_msg_30',
      'streak_msg_60',
      'streak_msg_100',
      'streak_msg_180',
      'streak_msg_365',
    ];
    for (final lang in AppLang.values) {
      final missing = keys.where((k) => !appStrings[lang]!.containsKey(k));
      expect(missing, isEmpty, reason: '$lang');
    }
  });

  test('"Gün" sözi: rus dilinde 3 görnüş, iňlis dilinde 2', () {
    String word(AppLang lang, int n) =>
        appStrings[lang]![ProfileStreakService.daysKey(n, lang)]!;
    expect([1, 2, 5, 11, 21, 22].map((n) => word(AppLang.ru, n)), [
      'день',
      'дня',
      'дней',
      'дней',
      'день',
      'дня',
    ]);
    expect([0, 1, 2, 21].map((n) => word(AppLang.en, n)), [
      'days',
      'day',
      'days',
      'days',
    ]);
  });
}
