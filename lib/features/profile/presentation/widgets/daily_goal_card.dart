import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/profile_goals_service.dart';
import '../../data/profile_repository.dart';
import 'goal_celebration_dialog.dart';
import 'how_it_works_dialog.dart';

/// Daily goal card:
/// - live 24h countdown (deadline-based → ticks even with the app closed)
/// - progress FROZEN once the goal is completed ("counter killed")
/// - one-time celebration dialog on completion
/// - "?" button opens the teacher's "how it works" dialog
class DailyGoalCard extends StatefulWidget {
  const DailyGoalCard({super.key});

  @override
  State<DailyGoalCard> createState() => _DailyGoalCardState();
}

class _DailyGoalCardState extends State<DailyGoalCard> {
  Timer? _ticker;
  bool _rolling = false;
  bool _celebrationOpen = false;
  int _celebratedForDeadline = 0;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final p = ProfileRepository.instance;

      // Window expired while we're watching → roll to the next goal.
      if (p.goalWindowExpired && !_rolling) {
        _rolling = true;
        p.evaluateAndRollWindow().whenComplete(() => _rolling = false);
      }

      // One-time celebration per window.
      if (p.goalCelebrationPending &&
          !_celebrationOpen &&
          _celebratedForDeadline != p.goalDeadlineMs) {
        _celebrationOpen = true;
        _celebratedForDeadline = p.goalDeadlineMs;
        showGoalCelebrationDialog(context).whenComplete(() {
          _celebrationOpen = false;
        });
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;
    final lang = context.settings.lang.name;

    return ListenableBuilder(
      listenable: ProfileRepository.instance,
      builder: (context, _) {
        final p = ProfileRepository.instance;
        final completed = p.goalCompletedInWindow;
        final progress = ProfileGoalsService.progress(
          p.todayProgress,
          p.dailyGoal,
        );
        final remaining = p.goalRemainingMs;

        final countdownLabel = switch (lang) {
          'ru' => completed ? 'Новая цель через:' : 'До конца цели:',
          'tk' => completed ? 'Täze maksat çenli:' : 'Maksada çenli:',
          'tr' => completed ? 'Yeni göreve kalan:' : 'Hedefe kalan:',
          _ => completed ? 'New task in:' : 'Time left:',
        };
        final ladderHint = switch (lang) {
          'ru' =>
            'Выполнишь → завтра ${p.nextGoal} · Не выполнишь → завтра ${p.fallbackGoal} и огонёк погаснет',
          'tk' =>
            'Ýerine ýetirseň → ertir ${p.nextGoal} · Ýetirmeseň → ertir ${p.fallbackGoal} we otjik öçer',
          'tr' =>
            'Bitirirsen → yarın ${p.nextGoal} · Bitiremezsen → yarın ${p.fallbackGoal} ve ateş söner',
          _ =>
            'Complete → tomorrow ${p.nextGoal} · Fail → tomorrow ${p.fallbackGoal} and the fire goes out',
        };

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: completed
                ? LinearGradient(
                    colors: [Colors.green.withValues(alpha: 0.16), c.surface],
                  )
                : null,
            color: completed ? null : c.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: completed ? Colors.green.withValues(alpha: 0.5) : c.line,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    completed ? Icons.emoji_events_rounded : Icons.flag_rounded,
                    color: completed ? Colors.green : c.accent,
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
                  // frozen counter: shows the final result once completed
                  Text(
                    ProfileGoalsService.format(p.todayProgress, p.dailyGoal),
                    style: TextStyle(
                      color: completed ? Colors.green : c.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // "?" — teacher explains everything
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => showHowItWorksDialog(context),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: c.surfaceHi,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.line),
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        color: c.sub,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: completed ? 1.0 : progress),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 10,
                    backgroundColor: c.surfaceHi,
                    valueColor: AlwaysStoppedAnimation(
                      completed ? Colors.green : c.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                completed
                    ? switch (lang) {
                        'ru' =>
                          '🎉 Задание выполнено! Счётчик отдыхает до нового дня.',
                        'tk' =>
                          '🎉 Tabşyryk ýerine ýetirildi! Sanawçy täze güne çenli dynç alýar.',
                        'tr' =>
                          '🎉 Görev tamamlandı! Sayaç yeni güne kadar dinleniyor.',
                        _ =>
                          '🎉 Task completed! The counter rests until the new day.',
                      }
                    : '${l10n.t('phrases_remaining')} ${p.dailyGoal - p.todayProgress} ${l10n.t('phrases_more')}',
                style: TextStyle(
                  color: completed ? Colors.green : c.sub,
                  fontSize: 12,
                  fontWeight: completed ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: remaining < 3600000
                      ? c.warn.withValues(alpha: 0.12)
                      : c.surfaceHi,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: remaining < 3600000
                        ? c.warn.withValues(alpha: 0.4)
                        : c.line,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: remaining < 3600000 ? c.warn : c.sub,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        countdownLabel,
                        style: TextStyle(color: c.sub, fontSize: 12),
                      ),
                    ),
                    Text(
                      ProfileGoalsService.countdown(remaining),
                      style: TextStyle(
                        color: remaining < 3600000 ? c.warn : c.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ladderHint,
                style: TextStyle(color: c.faint, fontSize: 10, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }
}
