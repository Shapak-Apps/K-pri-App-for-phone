import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/profile_repository.dart';

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = ProfileRepository.instance;
    final progress = p.todayProgress / p.dailyGoal;
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
                Icons.flag_rounded,
                color: isCompleted ? Colors.green : c.accent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ежедневная цель',
                  style: TextStyle(
                    color: c.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${p.todayProgress}/${p.dailyGoal}',
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
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: c.surfaceHi,
              valueColor: AlwaysStoppedAnimation(
                isCompleted ? Colors.green : c.accent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCompleted
                ? '🎉 Цель выполнена! Отличная работа!'
                : 'Переведи ещё ${p.dailyGoal - p.todayProgress} фраз',
            style: TextStyle(color: c.sub, fontSize: 12),
          ),
        ],
      ),
    );
  }
}