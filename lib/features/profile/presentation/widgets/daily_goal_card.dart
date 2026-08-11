import 'package:flutter/material.dart';
import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/profile_repository.dart';

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;

    return ListenableBuilder(
      listenable: ProfileRepository.instance,
      builder: (context, _) {
        final p = ProfileRepository.instance;
        final progress =
        p.dailyGoal > 0 ? (p.todayProgress / p.dailyGoal).clamp(0.0, 1.0) : 0.0;
        final isCompleted = p.todayProgress >= p.dailyGoal;

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
                  Icon(
                    isCompleted ? Icons.check_circle_rounded : Icons.flag_rounded,
                    color: isCompleted ? Colors.green : c.accent,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.t('daily_goal'),
                      style: TextStyle(
                        color: c.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: p.todayProgress.toDouble()),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => Text(
                      '${v.round()}/${p.dailyGoal}',
                      style: TextStyle(
                        color: c.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 10,
                    backgroundColor: c.surfaceHi,
                    valueColor: AlwaysStoppedAnimation(
                      isCompleted ? Colors.green : c.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isCompleted
                    ? '🎉 ${l10n.t('goal_completed')}'
                    : '${l10n.t('phrases_remaining')} ${p.dailyGoal - p.todayProgress} ${l10n.t('phrases_more')}',
                style: TextStyle(color: c.sub, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}