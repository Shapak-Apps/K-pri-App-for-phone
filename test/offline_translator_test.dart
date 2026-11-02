import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kopri/features/translate/data/offline_translator.dart';
import 'package:kopri/features/translate/data/translator_service.dart';

/// The ML Kit channel, like on a phone right after the app starts: the first
/// translation of a new translator takes 1.5 s, because ML Kit loads the model.
class _FakeMlKit {
  final started = <String>[]; // translator id of every translation
  final closed = <String>[];
  final _loaded = <String>{};
  bool modelsOnPhone = true;

  Future<Object?> handle(MethodCall call) async {
    final args = Map<String, dynamic>.from(call.arguments as Map);
    switch (call.method) {
      case 'nlp#manageLanguageModelModels':
        if (args['task'] == 'check') return modelsOnPhone;
        await Completer<void>().future; // a download with no end
        return 'success';
      case 'nlp#startLanguageTranslator':
        final id = args['id'] as String;
        started.add(id);
        if (_loaded.add(id)) {
          await Future<void>.delayed(const Duration(milliseconds: 1500));
        }
        return 'offline: ${args['text']}';
      case 'nlp#closeLanguageTranslator':
        closed.add(args['id'] as String);
        return null;
    }
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final mlKit = _FakeMlKit();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('google_mlkit_on_device_translator'),
          mlKit.handle,
        );
  });

  /// No internet: every online service fails at once.
  OnlineTranslator noInternet() =>
      OnlineTranslator(client: MockClient((_) async => http.Response('', 503)));

  test('Bir dil jübüti üçin bir terjimeçi gaýtadan ulanylýar', () async {
    final offline = OfflineTranslator.instance;
    await offline.translate('good morning', from: 'en', to: 'de');
    await offline.translate('good night', from: 'en', to: 'de');

    expect(mlKit.started, hasLength(2));
    expect(mlKit.started.toSet(), hasLength(1)); // the same translator
    expect(mlKit.closed, isEmpty);
  });

  test(
    'Modeller bar bolsa, 800 ms-den uzaga çeken offline terjimä garaşylýar',
    () async {
      // A new pair, so its first translation takes 1.5 s.
      final res = await noInternet().translate(
        'good morning',
        from: 'en',
        to: 'fr',
      );
      expect(res.text, 'offline: good morning');
    },
  );

  test('Model ýüklenmeli bolsa, ýüklenmegine garaşylmaýar', () async {
    mlKit.modelsOnPhone = false;
    addTearDown(() => mlKit.modelsOnPhone = true);
    final watch = Stopwatch()..start();
    await expectLater(
      noInternet().translate('good morning', from: 'en', to: 'it'),
      throwsA(isA<TranslationFailedException>()),
    );
    expect(watch.elapsed, lessThan(const Duration(seconds: 3)));
  });

  test('Iň köp 3 terjimeçi saklanýar, has köneleri ýapylýar', () async {
    final offline = OfflineTranslator.instance;
    for (final to in ['es', 'pt', 'nl', 'sv']) {
      await offline.translate('hello', from: 'en', to: to);
    }
    final kept = mlKit.started.sublist(mlKit.started.length - 3).toSet();
    expect(mlKit.closed.toSet(), mlKit.started.toSet().difference(kept));
  });
}
