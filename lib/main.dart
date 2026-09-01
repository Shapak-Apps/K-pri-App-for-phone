import 'package:flutter/material.dart';

import 'core/app/kopri_app.dart';
import 'core/app/app_bootstrap.dart';
import 'core/app/incoming_text.dart';
import 'core/app/intent_channel.dart';
import 'core/controllers/app_settings_controller.dart';
import 'features/history/data/history_repository.dart';

export 'core/app/incoming_text.dart';

Future<void> main() async {
  await AppBootstrap.initialize();

  final pendingScreen = await IntentChannel.getPendingScreen();
  final pendingText = await IntentChannel.getPendingText();

  if (pendingText != null && pendingText.trim().isNotEmpty) {
    incomingText.value = IncomingText(
      pendingText.trim(),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  final repo = HistoryRepository();
  final settings = AppSettingsController();
  await Future.wait([repo.init(), settings.init()]);
  await repo.purgeOlderThan(settings.autoCleanDays);

  runApp(
    AppProviders(
      controller: settings,
      child: KopriApp(
        repo: repo,
        settings: settings,
        initialScreen: pendingScreen ?? 0,
      ),
    ),
  );
} //lowerslowdown
