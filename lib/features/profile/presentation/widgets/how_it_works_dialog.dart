import 'package:flutter/material.dart';

import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/onboarding_pages.dart';
import '../../../onboarding/widgets/teacher_avatar.dart';

/// "How everything works" refresher: the same teacher slides as onboarding,
/// in a scrollable dialog. Opened from the "?" button on the goal card.
Future<void> showHowItWorksDialog(BuildContext context) async {
  final c = context.c;
  final lang = context.settings.lang.name;

  final title = switch (lang) {
    'ru' => 'Как всё устроено',
    'tk' => 'Hemme zat nähili işleýär',
    'tr' => 'Her şey nasıl çalışıyor',
    _ => 'How everything works',
  };
  final close = switch (lang) {
    'ru' => 'Понятно!',
    'tk' => 'Düşnükli!',
    'tr' => 'Anladım!',
    _ => 'Got it!',
  };

  await showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.accent.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: Icon(Icons.close_rounded, color: c.faint, size: 20),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                children: [
                  for (final p in onboardingPages)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TeacherAvatar(
                            pose: p.pose,
                            accent: c.accent,
                            size: 84,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.titleFor(lang),
                                  style: TextStyle(
                                    color: c.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  p.bodyFor(lang),
                                  style: TextStyle(
                                    color: c.sub,
                                    fontSize: 12,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    close,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
