import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kopri/core/controllers/app_settings_controller.dart';
import 'package:kopri/core/native/apk_channel.dart';
import 'package:kopri/features/translate/data/offline_translator.dart';

/// ML Kit with only the English model on the phone. A download ends at once,
/// and the model is on the phone after it.
class _FakeMlKit {
  final downloads = <String>[];
  final onPhone = <String>{'en'};

  Future<Object?> handle(MethodCall call) async {
    final args = Map<String, dynamic>.from(call.arguments as Map);
    switch (call.method) {
      case 'nlp#manageLanguageModelModels':
        final model = args['model'] as String;
        if (args['task'] == 'check') return onPhone.contains(model);
        downloads.add(model);
        onPhone.add(model);
        return 'success';
      case 'nlp#startLanguageTranslator':
        return 'offline: ${args['text']}';
    }
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final offline = OfflineTranslator.instance;
  late _FakeMlKit mlKit;

  setUp(() {
    mlKit = _FakeMlKit();
    messenger.setMockMethodCallHandler(
      const MethodChannel('google_mlkit_on_device_translator'),
      mlKit.handle,
    );
    addTearDown(() => offline.downloadMode = () => ModelDownload.wifiOnly);
  });

  /// The answer of MainActivity: is the phone on a metered network (mobile
  /// data) now?
  void network({required bool metered}) {
    messenger.setMockMethodCallHandler(
      kApkChannel,
      (call) async => call.method == 'isNetworkMetered' ? metered : null,
    );
  }

  test('Diňe Wi-Fi: mobil internetde model ýüklenmeýär', () async {
    offline.downloadMode = () => ModelDownload.wifiOnly;
    network(metered: true);
    final res = await offline.translate('good morning', from: 'en', to: 'de');
    expect(mlKit.downloads, isEmpty);
    expect(res, isNull); // the app translates online
  });

  test('Diňe Wi-Fi: Wi-Fi-da model ýüklenýär', () async {
    offline.downloadMode = () => ModelDownload.wifiOnly;
    network(metered: false);
    final res = await offline.translate('good morning', from: 'en', to: 'fr');
    expect(mlKit.downloads, ['fr']);
    expect(res?.text, 'offline: good morning');
  });

  test('Wi-Fi we mobil: mobil internetde-de model ýüklenýär', () async {
    offline.downloadMode = () => ModelDownload.wifiAndMobile;
    network(metered: true);
    await offline.translate('good morning', from: 'en', to: 'it');
    expect(mlKit.downloads, ['it']);
  });

  test('Hiç haçan: Wi-Fi-da-da model ýüklenmeýär', () async {
    offline.downloadMode = () => ModelDownload.never;
    network(metered: false);
    final res = await offline.translate('good morning', from: 'en', to: 'es');
    expect(mlKit.downloads, isEmpty);
    expect(res, isNull);
  });

  test('Hiç haçan: telefondaky modeller ulanylýar', () async {
    offline.downloadMode = () => ModelDownload.never;
    mlKit.onPhone.add('pt');
    final res = await offline.translate('good morning', from: 'en', to: 'pt');
    expect(res?.text, 'offline: good morning');
  });

  test('Ulgam barlanyp bilinmese, Diňe Wi-Fi-da ýüklenmeýär', () async {
    offline.downloadMode = () => ModelDownload.wifiOnly;
    messenger.setMockMethodCallHandler(
      kApkChannel,
      (_) async => throw PlatformException(code: 'error'),
    );
    await offline.translate('good morning', from: 'en', to: 'nl');
    expect(mlKit.downloads, isEmpty);
  });

  group('Sazlama', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('kopri_model_download');
      Hive.init(dir.path);
    });

    tearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    test('Başda "Diňe Wi-Fi", saýlanan ýatda saklanýar', () async {
      final settings = AppSettingsController();
      await settings.init();
      expect(settings.modelDownload, ModelDownload.wifiOnly);

      await settings.setModelDownload(ModelDownload.never);
      await Hive.close();
      final again = AppSettingsController();
      await again.init();
      expect(again.modelDownload, ModelDownload.never);
    });
  });
}
