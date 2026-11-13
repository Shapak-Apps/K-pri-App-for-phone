import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kopri/features/translate/data/tm_service.dart';
import 'package:kopri/features/translate/data/translator_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // No offline models on the phone, and a download fails at once.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('google_mlkit_on_device_translator'),
          (call) async {
            final args = Map<String, dynamic>.from(call.arguments as Map);
            if (args['task'] == 'check') return false;
            throw PlatformException(code: 'no-network');
          },
        );
  });

  var requests = 0;
  final asked = <String>[]; // "from>to: text" of every memory lookup
  setUp(() {
    requests = 0;
    asked.clear();
  });

  /// No internet: every online service fails at once.
  final noInternet = MockClient((_) async {
    requests++;
    return http.Response('', 503);
  });

  /// Google answers, the other services do not.
  final withInternet = MockClient((req) async {
    requests++;
    if (req.url.host == 'translate.googleapis.com') {
      return http.Response(
        '[[["online result","good evenin"]],null,"en"]',
        200,
      );
    }
    return http.Response('', 503);
  });

  /// The translation memory: "good evening" was translated to Korean before.
  TmHit? memory(String src, {required String from, required String to}) {
    asked.add('$from>$to: $src');
    if (from != 'en' || to != 'ko') return null;
    return switch (src) {
      'good evening' => const TmHit('좋은 저녁이에요', 1000),
      'good evenin' => const TmHit('좋은 저녁이에요', 916),
      _ => null,
    };
  }

  OnlineTranslator translator(http.Client client) =>
      OnlineTranslator(client: client, tmLookup: memory);

  test('Öň terjime edilen tekst internetsiz terjime edilýär', () async {
    final res = await translator(
      noInternet,
    ).translate('good evening', from: 'en', to: 'ko');
    expect(res.text, '좋은 저녁이에요');
    expect(res.approx, isFalse);
    expect(requests, 0);
  });

  test('Awtomat: tanalan dil bilen gözlenýär', () async {
    final res = await translator(
      noInternet,
    ).translate('good evening', from: 'auto', to: 'ko');
    expect(asked, ['en>ko: good evening']);
    expect(res.text, '좋은 저녁이에요');
    expect(res.detected, 'en');
  });

  test('Internet bar bolsa, meňzeş tekst üçin onlaýn terjime gelýär', () async {
    final res = await translator(
      withInternet,
    ).translate('good evenin', from: 'en', to: 'ko');
    expect(res.text, 'online result');
    expect(res.approx, isFalse);
  });

  test('Internet ýok bolsa, meňzeş tekstiň terjimesi ≈ bilen gelýär', () async {
    final res = await translator(
      noInternet,
    ).translate('good evenin', from: 'en', to: 'ko');
    expect(res.text, '좋은 저녁이에요');
    expect(res.approx, isTrue);
  });

  test('Ýatda hem ýok, internet hem ýok bolsa, ýalňyşlyk', () async {
    await expectLater(
      translator(noInternet).translate('thank you', from: 'en', to: 'ko'),
      throwsA(isA<TranslationFailedException>()),
    );
  });
}
