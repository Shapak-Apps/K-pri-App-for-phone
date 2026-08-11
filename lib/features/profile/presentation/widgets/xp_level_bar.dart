import 'package:flutter/material.dart';
import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/profile_repository.dart';
import '../../data/profile_xp_service.dart';

class XpLevelBar extends StatelessWidget {
  const XpLevelBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;

    return ListenableBuilder(
      listenable: ProfileRepository.instance,
      builder: (context, _) {
        final xp = ProfileRepository.instance.xp;

        final level = ProfileXpService.getLevel(xp);
        final currentXp = ProfileXpService.getXpForCurrentLevel(xp);
        final nextXp = ProfileXpService.getXpForNextLevel(xp);
        final progress = ProfileXpService.getLevelProgress(xp);
        final xpInLevel = xp - currentXp;
        final xpNeeded = nextXp - currentXp;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    ProfileXpService.getLevelEmoji(level),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.t('level')} $level',
                      style: TextStyle(
                        color: c.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '$xp XP',
                    style: TextStyle(
                      color: c.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                ProfileXpService.getLevelTitle(level),
                style: TextStyle(
                  color: c.sub,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 10,
                    backgroundColor: c.surfaceHi,
                    valueColor: AlwaysStoppedAnimation<Color>(c.accent),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$xpInLevel / $xpNeeded ${l10n.t('xp_to_next_level')} ${level + 1}',
                style: TextStyle(color: c.faint, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}