import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../camera/data/camera_repository.dart';
import '../../history/data/history_repository.dart';
import '../data/profile_repository.dart';
import 'screens/export_screen.dart';
import 'screens/preset_avatars_screen.dart';
import 'widgets/achievements_list.dart';
import 'widgets/daily_goal_card.dart';
import 'widgets/phrase_of_day.dart';
import 'widgets/profile_header.dart';
import 'widgets/quick_settings.dart';
import 'widgets/stats_overview.dart';
import 'widgets/streak_card.dart';
import 'widgets/weekly_chart.dart';
import 'widgets/xp_level_bar.dart';
import 'screens/about_authors_screen.dart';

const _apkChannel = MethodChannel('kopri/apk');

class ProfileScreen extends StatefulWidget {
  final HistoryRepository repo;
  const ProfileScreen({super.key, required this.repo});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    ProfileRepository.instance.ensureInit();
    CameraRepository.instance.ensureInit();
    CameraRepository.instance.addListener(_onData);
    try {
      widget.repo.addListener(_onData);
    } catch (_) {}
  }

  @override
  void dispose() {
    CameraRepository.instance.removeListener(_onData);
    try {
      widget.repo.removeListener(_onData);
    } catch (_) {}
    super.dispose();
  }

  void _onData() {
    if (mounted) setState(() {});
  }

  ({int tr, int fav, int cards, int cam}) _stats() {
    var tr = 0, fav = 0, cards = 0;
    try {
      final dynamic d = widget.repo;
      tr = (d.count as int?) ?? 0;
      fav = (d.favoritesCount as int?) ?? 0;
    } catch (_) {}
    try {
      if (Hive.isBoxOpen('flashcards')) cards = Hive.box('flashcards').length;
    } catch (_) {}
    final cam = CameraRepository.instance.isReady
        ? CameraRepository.instance.count
        : 0;
    return (tr: tr, fav: fav, cards: cards, cam: cam);
  }

  void _snack(String t, {bool warn = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t),
        backgroundColor: warn ? context.c.warn : context.c.accent,
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final c = context.c, l10n = context.l10n, p = ProfileRepository.instance;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tile(
                c,
                Icons.photo_library_rounded,
                l10n.t('profile_gallery'),
                () async {
                  Navigator.pop(ctx);
                  final x = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 85,
                  );
                  if (x != null && mounted) await p.saveAvatarFromPath(x.path);
                },
              ),
              const SizedBox(height: 8),
              _tile(
                c,
                Icons.photo_camera_rounded,
                l10n.t('profile_camera'),
                () async {
                  Navigator.pop(ctx);
                  final x = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 85,
                  );
                  if (x != null && mounted) await p.saveAvatarFromPath(x.path);
                },
              ),
              const SizedBox(height: 8),
              _tile(
                c,
                Icons.emoji_emotions_rounded,
                l10n.t('profile_emoji'),
                () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PresetAvatarsScreen(),
                    ),
                  );
                },
              ),
              if (p.hasAvatar || p.avatarEmoji != null) ...[
                const SizedBox(height: 8),
                _tile(
                  c,
                  Icons.delete_outline_rounded,
                  l10n.t('profile_remove_photo'),
                  () async {
                    Navigator.pop(ctx);
                    await p.deleteAvatar();
                  },
                  warn: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(
    AppColors c,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool warn = false,
  }) {
    return Material(
      color: c.surfaceHi,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: warn ? c.warn : c.accent, size: 24),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: warn ? c.warn : c.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editBio() {
    final c = context.c, l10n = context.l10n;
    final ctrl = TextEditingController(text: ProfileRepository.instance.bio);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.t('profile_bio_hint'),
          style: TextStyle(color: c.text, fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: ctrl,
          style: TextStyle(color: c.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: c.surfaceHi,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ProfileRepository.instance.setBio(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: Text(
              l10n.t('confirm'),
              style: TextStyle(color: c.accent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String t, AppColors c) =>
      Text(t, style: AppTheme.label(color: c.accent, size: 11));

  Widget _statCard(AppColors c, String label, int value) {
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
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text(
              v.round().toString(),
              style: AppTheme.display(size: 26, color: c.accent),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.label(color: c.sub, size: 10)),
        ],
      ),
    );
  }

  Widget _actionTile(
    AppColors c,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool warn = false,
  }) {
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.line),
          ),
          child: Row(
            children: [
              Icon(icon, color: warn ? c.warn : c.accent, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: warn ? c.warn : c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.sub, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _share() async {
    final l10n = context.l10n;
    final p = ProfileRepository.instance;
    final s = _stats();

    try {
      await _apkChannel.invokeMethod('setIgnoreNextClipboard');
    } catch (_) {}

    final text =
        'Köpri — ${p.name.isEmpty ? l10n.t('profile_user_default') : p.name}\n'
        '${l10n.t('profile_translations')}: ${s.tr}\n'
        '${l10n.t('profile_favorites')}: ${s.fav}\n'
        '${l10n.t('profile_cards')}: ${s.cards}\n'
        '${l10n.t('profile_photos')}: ${s.cam}';

    await Clipboard.setData(ClipboardData(text: text));
    _snack(l10n.t('copied'));
  }

  void _feedback() async {
    final c = context.c;
    final l10n = context.l10n;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: c.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0088CC),
                        const Color(0xFF0066AA),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0088CC).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.telegram,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  l10n.t('profile_feedback_title'),
                  style: AppTheme.display(size: 22, color: c.text),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  l10n.t('profile_feedback_desc'),
                  style: TextStyle(color: c.sub, fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0088CC),
                        const Color(0xFF0066AA),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0088CC).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final uri = Uri.parse('https://t.me/kopri_support_bot');
                        try {
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            if (mounted) {
                              _snack(
                                l10n.t('profile_feedback_error'),
                                warn: true,
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            _snack(
                              '${l10n.t('profile_feedback_error')}: $e',
                              warn: true,
                            );
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.telegram,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.t('profile_feedback_open'),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: c.surfaceHi,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.line),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.pop(ctx),
                      child: Center(
                        child: Text(
                          l10n.t('cancel'),
                          style: TextStyle(
                            color: c.sub,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmClear() {
    final c = context.c, l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.t('profile_clear'),
          style: TextStyle(color: c.text, fontWeight: FontWeight.w800),
        ),
        content: Text(
          l10n.t('profile_clear_msg'),
          style: TextStyle(color: c.sub),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ProfileRepository.instance.clearAll();
              _snack(l10n.t('profile_cleared'));
            },
            child: Text(
              l10n.t('confirm'),
              style: TextStyle(color: c.warn, fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.t('cancel'), style: TextStyle(color: c.sub)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;
    final s = _stats();

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

            ProfileHeader(onEditBio: _editBio),
            const SizedBox(height: 16),

            const XpLevelBar(),
            const SizedBox(height: 12),
            const StreakCard(),
            const SizedBox(height: 12),
            const DailyGoalCard(),
            const SizedBox(height: 12),
            WeeklyChart(repo: widget.repo),
            const SizedBox(height: 12),

            _section(l10n.t('profile_activity'), c),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _statCard(c, l10n.t('profile_translations'), s.tr),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(c, l10n.t('profile_favorites'), s.fav),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _statCard(c, l10n.t('profile_cards'), s.cards)),
                const SizedBox(width: 10),
                Expanded(child: _statCard(c, l10n.t('profile_photos'), s.cam)),
              ],
            ),
            const SizedBox(height: 18),

            StatsOverview(repo: widget.repo),
            const SizedBox(height: 18),

            const PhraseOfDay(),
            const SizedBox(height: 18),

            _section(l10n.t('profile_achievements'), c),
            const SizedBox(height: 10),
            AchievementsList(stats: s),
            const SizedBox(height: 18),

            const QuickSettings(),
            const SizedBox(height: 18),

            _section(l10n.t('profile_quick'), c),
            const SizedBox(height: 10),
            _actionTile(
              c,
              Icons.import_export_rounded,
              l10n.t('profile_export'),
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExportScreen(repo: widget.repo),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _actionTile(
              c,
              Icons.share_rounded,
              l10n.t('profile_share'),
              _share,
            ),
            const SizedBox(height: 8),
            _actionTile(
              c,
              Icons.mail_outline_rounded,
              l10n.t('profile_feedback'),
              _feedback,
            ),
            const SizedBox(height: 8),
            _actionTile(
              c,
              Icons.delete_sweep_rounded,
              l10n.t('profile_clear'),
              _confirmClear,
              warn: true,
            ),
            const SizedBox(height: 18),
            const AboutAuthorsCard(),
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
