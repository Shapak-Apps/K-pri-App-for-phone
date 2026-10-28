import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kopri/features/profile/data/profile_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = ProfileRepository.instance;
  late Directory dir;

  String daysAgo(int n) => DateTime.now()
      .subtract(Duration(days: n))
      .toIso8601String()
      .substring(0, 10);

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('kopri_streak_test');
    // ensureInit() asks path_provider for the documents folder.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => dir.path,
        );
    Hive.init(dir.path);
    await repo.ensureInit();
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('Ilkinji terjime: seriýa 1, rekord 1', () async {
    await repo.onTranslationDone(resultText: 'salam');
    expect(repo.streak, 1);
    expect(repo.bestStreak, 1);
  });

  test('Arakesmeden soň rekord 0 bolsa: seriýa 1, rekord 1', () async {
    final box = Hive.box('profile');
    await box.put('lastActiveDate', daysAgo(5));
    await box.put('streak', 0);
    await box.put('bestStreak', 0);

    await repo.onTranslationDone(resultText: 'salam');
    expect(repo.streak, 1);
    expect(repo.bestStreak, 1);
  });

  test('Arakesmeden soň uly rekord peselmeýär', () async {
    final box = Hive.box('profile');
    await box.put('lastActiveDate', daysAgo(5));
    await box.put('streak', 0);
    await box.put('bestStreak', 3);

    await repo.onTranslationDone(resultText: 'salam');
    expect(repo.streak, 1);
    expect(repo.bestStreak, 3);
  });
}
