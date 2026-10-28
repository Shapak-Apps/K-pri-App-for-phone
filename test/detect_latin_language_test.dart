import 'package:flutter_test/flutter_test.dart';
import 'package:kopri/features/translate/data/translator_service.dart';

void main() {
  String detect(String text) =>
      OnlineTranslator.detectLatinLanguage(text, 'ru');

  test('Türkmen sözleri ň we ý bilen tapylýar', () {
    expect(detect('Meniň adym Aýnazar'), 'tk');
    expect(detect('Ýok, men bilemok'), 'tk');
  });

  test('Türk sözleri ş, ç we ü bilen tapylýar', () {
    expect(detect('Şu kitap kötü mü'), 'tr');
  });

  test('Iňlis "we" we "men" türkmen hasaplanmaýar', () {
    expect(detect('We need men here'), 'en');
  });

  test('Baş harp Ý hem türkmen harpy hasaplanýar', () {
    expect(detect('Ýene gowy'), 'tk');
  });
}
