import 'package:flutter_test/flutter_test.dart';
import 'package:kopri/core/data/language_linkage_data.dart';
import 'package:kopri/features/translate/data/language_flags.dart';
import 'package:kopri/features/translate/data/languages.dart';

/// Regional indicator letters (🇦…🇿) in [s]. A flag is two of them.
int _flagLetters(String s) =>
    s.runes.where((r) => r >= 0x1F1E6 && r <= 0x1F1FF).length;

void main() {
  test('Sazlamalarda her diliň baýdagy iki harpdan ybarat', () {
    final broken = [
      for (final code in AppLanguages.all.keys)
        if (_flagLetters(langFlagFor(code)) != 2) code,
    ];
    expect(broken, isEmpty);
  });

  test('Katalan dili üçin Ispaniýanyň baýdagy, KS däl', () {
    expect(langFlagFor('ca'), '🇪🇸');
  });

  test('Dil saýlaýjyda her setiriň baýdagy iki harpdan ybarat', () {
    final broken = [
      for (final e in kLangTextByCode.entries)
        if (e.key != 'auto' && _flagLetters(e.value) != 2) e.key,
    ];
    expect(broken, isEmpty);
  });
}
