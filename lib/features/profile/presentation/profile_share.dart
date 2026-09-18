import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/native/apk_channel.dart';
import '../../../core/theme/app_colors.dart';
import '../data/profile_repository.dart';
import 'profile_stats.dart';

/// Copies a plain-text profile summary to the system clipboard.
///
/// The native side is asked to ignore the next clipboard change so the
/// clipboard-translation bubble does not react to our own copy.
Future<void> shareProfileStats(BuildContext context, ProfileStats stats) async {
  final l10n = context.settings.l10n;
  final p = ProfileRepository.instance;

  try {
    await kApkChannel.invokeMethod('setIgnoreNextClipboard');
  } catch (_) {}

  final text =
      'Köpri — ${p.name.isEmpty ? l10n.t('profile_user_default') : p.name}\n'
      '${l10n.t('profile_translations')}: ${stats.tr}\n'
      '${l10n.t('profile_favorites')}: ${stats.fav}\n'
      '${l10n.t('profile_cards')}: ${stats.cards}\n'
      '${l10n.t('profile_photos')}: ${stats.cam}';

  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.t('copied')),
      backgroundColor: context.c.accent,
    ),
  );
}
