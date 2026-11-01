import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:kopri/core/app/kopri_app.dart';
import 'package:kopri/core/controllers/app_settings_controller.dart';
import 'package:kopri/core/widgets/splash_screen.dart';
import 'package:kopri/features/history/data/history_repository.dart';

/// Like Android 14+ nonlinear font scaling: big text grows less.
class _NonlinearScaler extends TextScaler {
  const _NonlinearScaler();

  @override
  double scale(double fontSize) =>
      fontSize <= 20 ? fontSize * 1.5 : 30 + (fontSize - 20) * 1.2;

  @override
  double get textScaleFactor => 1.5;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final history = HistoryRepository();
  late Directory dir;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false; // as in AppBootstrap
    dir = await Directory.systemTemp.createTemp('kopri_text_scale_test');
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
    await history.init();
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test(
    'Täze ulanyjy üçin harp ölçegi 100%, saýlanan ölçeg saklanýar',
    () async {
      await Hive.deleteBoxFromDisk('settings');
      final s = AppSettingsController();
      await s.init();
      expect(s.fontScale, 1.0);

      await s.setFontScale(0.85); // the user moved the slider
      final again = AppSettingsController();
      await again.init();
      expect(again.fontScale, 0.85);
    },
  );

  /// Starts the app with [system] as the phone's text size and returns the
  /// text scaler that the app's screens get.
  Future<TextScaler> appScaler(
    WidgetTester tester,
    TextScaler system,
    double fontScale,
  ) async {
    final settings = AppSettingsController();
    await tester.runAsync(() async {
      await settings.init();
      await settings.setFontScale(fontScale);
    });
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: system),
        child: AppProviders(
          controller: settings,
          child: KopriApp(repo: history, settings: settings),
        ),
      ),
    );
    final scaler = MediaQuery.textScalerOf(
      tester.element(find.byType(SplashScreen)),
    );
    // Let the splash screen finish, then close the app.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox());
    return scaler;
  }

  testWidgets('Telefonyň harp ölçegi hem ulanylýar', (tester) async {
    final scaler = await appScaler(tester, const TextScaler.linear(1.3), 1.0);
    expect(scaler.scale(10), closeTo(13, 0.001));
  });

  testWidgets('Programmanyň ölçegi telefonyňka köpeldilýär', (tester) async {
    final scaler = await appScaler(tester, const _NonlinearScaler(), 1.2);
    expect(scaler.scale(10), closeTo(15 * 1.2, 0.001));
    expect(scaler.scale(40), closeTo(54 * 1.2, 0.001)); // not 40 * 1.5 * 1.2
  });
}
