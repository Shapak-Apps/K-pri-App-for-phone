import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/profile_repository.dart';
import '../../data/profile_xp_service.dart';

class XpLevelBar extends StatelessWidget {
  const XpLevelBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = ProfileRepository.instance;
    final level = ProfileXpService.getLevel(p.xp);
    final progress = ProfileXpService.getLevelProgress(p.xp);
    final currentXp = ProfileXpService.getXpForCurrentLevel(p.xp);
    final nextXp = ProfileXpService.getXpForNextLevel(p.xp);
    final xpInLevel = p.xp - currentXp;
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
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Уровень $level',
                      style: TextStyle(
                        color: c.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      ProfileXpService.getLevelTitle(level),
                      style: TextStyle(
                        color: c.sub,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${p.xp} XP',
                style: TextStyle(
                  color: c.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: c.surfaceHi,
              valueColor: AlwaysStoppedAnimation(c.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$xpInLevel / $xpNeeded XP до уровня ${level + 1}',
            style: TextStyle(color: c.faint, fontSize: 12),
          ),
        ],
      ),
    );
  }
}