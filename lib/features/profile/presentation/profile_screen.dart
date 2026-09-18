import 'package:flutter/material.dart';

import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../about/about_screen.dart';
import '../../camera/data/camera_repository.dart';
import '../../history/data/history_repository.dart';
import '../data/profile_repository.dart';
import 'dialogs/bio_dialog.dart';
import 'dialogs/clear_profile_dialog.dart';
import 'dialogs/feedback_sheet.dart';
import 'profile_share.dart';
import 'profile_stats.dart';
import 'screens/export_screen.dart';
import 'widgets/achievements_list.dart';
import 'widgets/daily_goal_card.dart';
import 'widgets/phrase_of_day.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_tiles.dart';
import 'widgets/quick_settings.dart';
import 'widgets/stats_overview.dart';
import 'widgets/streak_card.dart';
import 'widgets/weekly_chart.dart';
import 'widgets/xp_level_bar.dart';

/// Entry widget of the profile tab: composes header, gamification blocks,
/// activity stats and quick actions. All heavy logic lives in dedicated
/// files (dialogs/, profile_stats, profile_share, widgets/).
class ProfileScreen extends StatefulWidget {
  final HistoryRepository repo;
  const ProfileScreen({super.key, required this.repo});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    ProfileRepository.instance.ensureInit();
    CameraRepository.instance.ensureInit();
    CameraRepository.instance.addListener(_onData);
    widget.repo.addListener(_onData);
  }

  @override
  void dispose() {
    CameraRepository.instance.removeListener(_onData);
    widget.repo.removeListener(_onData);
    super.dispose();
  }

  void _onData() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;
    final s = computeProfileStats(widget.repo);

    return ListenableBuilder(
      listenable: ProfileRepository.instance,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.person_rounded, color: c.accent, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    l10n.t('profile_title'),
                    style: AppTheme.display(size: 19, color: c.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            ProfileHeader(onEditBio: () => showBioDialog(context)),
            const SizedBox(height: 16),

            const XpLevelBar(),
            const SizedBox(height: 12),
            const StreakCard(),
            const SizedBox(height: 12),
            const DailyGoalCard(),
            const SizedBox(height: 12),
            WeeklyChart(repo: widget.repo),
            const SizedBox(height: 12),

            ProfileSectionLabel(text: l10n.t('profile_activity'), c: c),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ProfileStatCard(
                    c: c,
                    label: l10n.t('profile_translations'),
                    value: s.tr,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ProfileStatCard(
                    c: c,
                    label: l10n.t('profile_favorites'),
                    value: s.fav,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ProfileStatCard(
                    c: c,
                    label: l10n.t('profile_cards'),
                    value: s.cards,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ProfileStatCard(
                    c: c,
                    label: l10n.t('profile_photos'),
                    value: s.cam,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            StatsOverview(repo: widget.repo),
            const SizedBox(height: 18),

            const PhraseOfDay(),
            const SizedBox(height: 18),

            ProfileSectionLabel(text: l10n.t('profile_achievements'), c: c),
            const SizedBox(height: 10),
            AchievementsList(stats: s),
            const SizedBox(height: 18),

            const QuickSettings(),
            const SizedBox(height: 18),

            ProfileSectionLabel(text: l10n.t('profile_quick'), c: c),
            const SizedBox(height: 10),
            ProfileActionTile(
              c: c,
              icon: Icons.import_export_rounded,
              label: l10n.t('profile_export'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ExportScreen(repo: widget.repo),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ProfileActionTile(
              c: c,
              icon: Icons.share_rounded,
              label: l10n.t('profile_share'),
              onTap: () => shareProfileStats(context, s),
            ),
            const SizedBox(height: 8),
            ProfileActionTile(
              c: c,
              icon: Icons.mail_outline_rounded,
              label: l10n.t('profile_feedback'),
              onTap: () => showFeedbackSheet(context),
            ),
            const SizedBox(height: 8),
            ProfileActionTile(
              c: c,
              icon: Icons.delete_sweep_rounded,
              label: l10n.t('profile_clear'),
              warn: true,
              onTap: () => showClearProfileDialog(context),
            ),
            const SizedBox(height: 18),
            const AboutEntryCard(),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Köpri · v1.0.2',
                style: AppTheme.caption(color: c.faint, size: 11),
              ),
            ),
          ],
        );
      },
    );
  }
}
