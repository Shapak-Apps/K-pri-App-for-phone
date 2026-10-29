import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kopri/features/camera/data/camera_photo_model.dart';
import 'package:kopri/features/camera/data/camera_repository.dart';
import 'package:kopri/features/flashcards/data/srs_scheduler.dart';
import 'package:kopri/features/history/data/history_repository.dart';
import 'package:kopri/features/profile/data/profile_repository.dart';
import 'package:kopri/features/settings/presentation/settings_actions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final history = HistoryRepository();
  final profile = ProfileRepository.instance;
  final camera = CameraRepository.instance;
  final widgetCalls = <MethodCall>[];
  late Directory dir;
  late File photo;
  late int cleared;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('kopri_clear_all_test');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    // Profile and camera ask path_provider for the documents folder.
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => dir.path,
    );
    messenger.setMockMethodCallHandler(const MethodChannel('home_widget'), (
      call,
    ) async {
      widgetCalls.add(call);
      return true;
    });
    Hive.init(dir.path);
    await history.init();
    await profile.ensureInit();
    await camera.ensureInit();
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  // Fill every store, then press "Clear everything".
  setUp(() async {
    await history.add(source: 'hello', result: 'salam', from: 'en', to: 'tk');
    await profile.setName('Tester');
    await profile.onTranslationDone(resultText: 'salam');
    await SrsScheduler.review('hello', 5);
    photo = File('${camera.photosDir}/1.jpg')..writeAsBytesSync([1, 2, 3]);
    await camera.add(
      CameraPhoto(
        id: '1',
        path: photo.path,
        originalText: 'salam',
        translations: const {},
        timestamp: DateTime.now(),
      ),
    );
    expect(profile.xp, greaterThan(0));
    expect(Hive.box(SrsScheduler.boxName).length, 1);
    widgetCalls.clear();

    cleared = await clearAllData(history);
  });

  test('Taryh arassalanýar', () {
    expect(cleared, 1);
    expect(history.count, 0);
  });

  test('Profil arassalanýar: at, XP, seriýa, gündelik maksat', () {
    expect(profile.name, '');
    expect(profile.xp, 0);
    expect(profile.streak, 0);
    expect(profile.bestStreak, 0);
    expect(profile.todayProgress, 0);
  });

  test('Kartlaryň ösüşi arassalanýar', () {
    expect(Hive.box(SrsScheduler.boxName).length, 0);
  });

  test('Suratlar we olaryň faýllary pozulýar', () {
    expect(camera.count, 0);
    expect(photo.existsSync(), isFalse);
  });

  test('Widjetiň teksti pozulýar we widjet täzelenýär', () {
    final saved = {
      for (final c in widgetCalls.where((c) => c.method == 'saveWidgetData'))
        (c.arguments as Map)['id']: (c.arguments as Map)['data'],
    };
    expect(saved, {
      'last_source': null,
      'last_result': null,
      'last_pair': null,
    });
    expect(widgetCalls.last.method, 'updateWidget');
  });
}
