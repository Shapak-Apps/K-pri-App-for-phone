import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/controllers/app_settings_controller.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../onboarding/widgets/teacher_avatar.dart';
import '../../data/profile_repository.dart';

/// Shown ONCE per window when the daily goal is completed.
/// Confetti + celebrating teacher + simple explanation of what happens next.
Future<void> showGoalCelebrationDialog(BuildContext context) async {
  final c = context.c;
  final lang = context.settings.lang.name;
  final p = ProfileRepository.instance;

  final title = switch (lang) {
    'ru' => 'Ты справился!',
    'tk' => 'Sen başardyň!',
    'tr' => 'Başardın!',
    _ => 'You did it!',
  };
  final body = switch (lang) {
    'ru' =>
      'Задание выполнено! Таймер ещё идёт — когда он дойдёт до нуля, придёт новое задание, чуть сложнее. А пока переводи спокойно: баллы капают, задание отдыхает.',
    'tk' =>
      'Tabşyryk ýerine ýetirildi! Taýmer heniz işleýär — nola ýetende täze tabşyryk geler, biraz kynrak. Häzirlikçe asuda terjime et: ballar damýar, tabşyryk dynç alýar.',
    'tr' =>
      'Görev tamamlandı! Sayaç hâlâ işliyor — sıfıra ulaşınca yeni görev gelecek, biraz daha zor. Şimdilik rahatça çeviri yap: puanlar birikiyor, görev dinleniyor.',
    _ =>
      'Task completed! The timer is still running — when it hits zero, a new task arrives, a bit harder. For now translate freely: points keep flowing, the task rests.',
  };
  final button = switch (lang) {
    'ru' => 'Отлично!',
    'tk' => 'Gaty gowy!',
    'tr' => 'Harika!',
    _ => 'Awesome!',
  };

  await showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: c.accent.withValues(alpha: 0.4)),
        ),
        child: CustomPaint(
          painter: _ConfettiPainter(accent: c.accent),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TeacherAvatar(
                  pose: TeacherPose.celebrate,
                  accent: c.accent,
                  size: 150,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.sub, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      button,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  // Mark celebration as shown for this window.
  await p.consumeGoalCelebration();
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.accent});
  final Color accent;

  static const _colors = [
    Color(0xFFFB923C),
    Color(0xFF9B7BFF),
    Color(0xFF10B981),
    Color(0xFF38BDF8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    for (var i = 0; i < 24; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * 0.5;
      final rot = rnd.nextDouble() * math.pi;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      canvas.drawRect(
        Rect.fromLTWH(-4, -2, 8, 4),
        Paint()
          ..color = (i % 5 == 0)
              ? accent
              : _colors[i % _colors.length].withValues(alpha: 0.8),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
