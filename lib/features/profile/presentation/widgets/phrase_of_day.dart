import 'package:flutter/material.dart';
import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../conversation/data/tts_service.dart';
import '../../../phrasebook/data/phrasebook_data.dart';

class PhraseOfDay extends StatefulWidget {
  const PhraseOfDay({super.key});
  @override
  State<PhraseOfDay> createState() => _PhraseOfDayState();
}

class _PhraseOfDayState extends State<PhraseOfDay> {
  final _tts = TtsService();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;
    final src = context.settings.lang.name;

    final all = <PPh>[];
    for (final cat in phrasebook) {
      for (final sub in cat.s) {
        all.addAll(sub.p);
      }
    }
    if (all.isEmpty) return const SizedBox.shrink();

    final day = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
    final p = all[day % all.length];

    final text = switch (src) {
      'ru' => p.ru,
      'en' => p.en,
      'tr' => p.tr,
      _ => p.tk,
    };

    final ttsCode = src == 'tr' ? 'en' : src;
    final ttsText = src == 'tr' ? p.en : text;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.accent.withValues(alpha: 0.16),
            c.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('profile_phrase_day'),
                  style: TextStyle(
                    color: c.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _tts.speak(ttsText, ttsCode),
            icon: Icon(Icons.volume_up_rounded, color: c.accent),
          ),
        ],
      ),
    );
  }
}
