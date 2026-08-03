import 'package:flutter_test/flutter_test.dart';
import 'package:kopri/features/history/data/history_models.dart';
import 'package:kopri/features/translate/data/languages.dart';
import 'package:kopri/features/translate/data/translator_service.dart';
import 'package:kopri/features/translate/presentation/translation_state.dart';

void main() {
  test('Diller sanawy boş däl, Türkmençe we Awtomat bar', () {
    expect(AppLanguages.all.containsKey('tk'), isTrue);
    expect(AppLanguages.sources.containsKey('auto'), isTrue);
    expect(AppLanguages.nameOf('auto'), 'Awtomat');
    expect(AppLanguages.nameOf('tk'), 'Türkmençe');
  });

  test('HistoryEntry toMap/fromMap aýlanýar', () {
    final e = HistoryEntry(
      id: '1',
      source: 'salam',
      result: 'привет',
      from: 'tk',
      to: 'ru',
      timestamp: DateTime.fromMillisecondsSinceEpoch(1000),
    );
    final back = HistoryEntry.fromMap(e.toMap());
    expect(back.source, 'salam');
    expect(back.to, 'ru');
  });

  test('OnlineTranslator TranslatorService dur', () {
    expect(OnlineTranslator(), isA<TranslatorService>());
  });

  test('TranslationState sealed — ähli şahalar bar', () {
    const states = <TranslationState>[
      IdleState(),
      LoadingState(),
      SuccessState('hi', 'en'),
      ErrorState('oops'),
    ];
    expect(states.length, 4);
  });
}
