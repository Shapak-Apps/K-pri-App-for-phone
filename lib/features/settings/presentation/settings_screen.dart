import 'package:flutter/material.dart';

import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../camera/presentation/camera_screen.dart'
    show kCameraEnabled, showComingSoonAnywhere;
import '../../history/data/history_repository.dart';
import '../../translate/data/languages.dart';
import '../ui/privacy_policy_screen.dart';
import '../ui/terms_screen.dart';
import 'dialogs/feedback_sheet.dart';
import 'licenses_screen.dart';
import 'sections/offline_models_section.dart';
import 'settings_actions.dart';
import 'settings_constants.dart';
import 'settings_header.dart';
import 'widgets/appearance_pickers.dart';
import 'widgets/clipboard_switch_tile.dart';
import 'widgets/danger_zone.dart';
import 'widgets/settings_controls.dart';
import 'widgets/settings_tiles.dart';

/// Entry widget of the settings screen: composes header, sections and
/// footer. All actions live in `settings_actions.dart`, all visual
/// primitives in `widgets/`, the models section in `sections/`.
class SettingsScreen extends StatelessWidget {
  final HistoryRepository repo;
  const SettingsScreen({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final s = context.settings;
    return Scaffold(
      backgroundColor: context.c.bg,
      body: ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          final c = context.c;
          final l10n = s.l10n;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return CustomScrollView(
            slivers: [
              SettingsHeader(c: c, isDark: isDark, title: l10n.t('settings')),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    GlassSection(
                      c: c,
                      isDark: isDark,
                      title: l10n.t('translation_section'),
                      icon: Icons.auto_awesome_rounded,
                      children: [
                        PickerTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.input_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          title: l10n.t('default_source'),
                          value: AppLanguages.nameOf(s.defaultFrom),
                          flag: langFlagFor(s.defaultFrom),
                          onTap: () => pickSettingsLanguage(
                            context,
                            true,
                            s.defaultFrom,
                            s.setDefaultFrom,
                          ),
                        ),
                        PickerTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.translate_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: l10n.t('default_target'),
                          value: AppLanguages.nameOf(s.defaultTo),
                          flag: langFlagFor(s.defaultTo),
                          onTap: () => pickSettingsLanguage(
                            context,
                            false,
                            s.defaultTo,
                            s.setDefaultTo,
                          ),
                        ),
                        NeoSwitchTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.bolt_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: l10n.t('auto_translate'),
                          subtitle: l10n.t('auto_translate_desc'),
                          value: s.autoTranslate,
                          onChanged: s.setAutoTranslate,
                        ),
                        if (s.autoTranslate)
                          GlowSliderTile(
                            c: c,
                            isDark: isDark,
                            title: l10n.t('translate_delay'),
                            valueLabel: '${s.translateDelayMs} ms',
                            value: s.translateDelayMs.toDouble(),
                            min: 300,
                            max: 2000,
                            divisions: 17,
                            onChanged: (v) => s.setTranslateDelayMs(v.round()),
                          ),
                        ClipboardSwitchTile(c: c, isDark: isDark),
                      ],
                    ),
                    const SizedBox(height: 20),
                    OfflineModelsSection(
                      key: ValueKey('offline_${s.lang.index}'),
                    ),
                    const SizedBox(height: 20),
                    GlassSection(
                      c: c,
                      isDark: isDark,
                      title: l10n.t('speech_section'),
                      icon: Icons.spatial_audio_off_rounded,
                      children: [
                        NeoSwitchTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.record_voice_over_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: l10n.t('auto_speak'),
                          subtitle: l10n.t('auto_speak_desc'),
                          value: s.autoSpeak,
                          onChanged: s.setAutoSpeak,
                        ),
                        GlowSliderTile(
                          c: c,
                          isDark: isDark,
                          title: l10n.t('speech_rate'),
                          valueLabel: '${(s.speechRate * 100).round()}%',
                          value: s.speechRate,
                          min: 0.1,
                          max: 1.0,
                          divisions: 18,
                          onChanged: s.setSpeechRate,
                        ),
                        GlowSliderTile(
                          c: c,
                          isDark: isDark,
                          title: l10n.t('volume'),
                          valueLabel: '${(s.ttsVolume * 100).round()}%',
                          value: s.ttsVolume,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          onChanged: s.setTtsVolume,
                        ),
                        GlowSliderTile(
                          c: c,
                          isDark: isDark,
                          title: l10n.t('pitch'),
                          valueLabel: '${(s.ttsPitch * 100).round()}%',
                          value: s.ttsPitch,
                          min: 0.5,
                          max: 1.5,
                          divisions: 10,
                          onChanged: s.setTtsPitch,
                        ),
                        ListenPreviewTile(c: c, isDark: isDark),
                        GlowSliderTile(
                          c: c,
                          isDark: isDark,
                          title: l10n.t('mic_listen_for'),
                          valueLabel: '${s.listenSeconds} s',
                          value: s.listenSeconds.toDouble(),
                          min: 10,
                          max: 120,
                          divisions: 22,
                          onChanged: (v) => s.setListenSeconds(v.round()),
                        ),
                        GlowSliderTile(
                          c: c,
                          isDark: isDark,
                          title: l10n.t('mic_pause'),
                          valueLabel: '${s.pauseSeconds} s',
                          value: s.pauseSeconds.toDouble(),
                          min: 1,
                          max: 6,
                          divisions: 5,
                          onChanged: (v) => s.setPauseSeconds(v.round()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GlassSection(
                      c: c,
                      isDark: isDark,
                      title: l10n.t('phrasebook_section'),
                      icon: Icons.menu_book_rounded,
                      children: [
                        PillSegment<PhraseSpeakMode>(
                          c: c,
                          isDark: isDark,
                          label: l10n.t('phrase_speak'),
                          icon: Icons.volume_up_rounded,
                          value: s.phraseSpeak,
                          options: [
                            (
                              PhraseSpeakMode.iface,
                              l10n.t('phrase_speak_iface'),
                            ),
                            (
                              PhraseSpeakMode.english,
                              l10n.t('phrase_speak_english'),
                            ),
                            (PhraseSpeakMode.both, l10n.t('phrase_speak_both')),
                          ],
                          onChanged: s.setPhraseSpeak,
                        ),
                        PillSegment<int>(
                          c: c,
                          isDark: isDark,
                          label: l10n.t('flashcard_session'),
                          icon: Icons.style_rounded,
                          value: s.flashcardSession,
                          options: const [(10, '10'), (20, '20'), (50, '50')],
                          onChanged: s.setFlashcardSession,
                        ),
                        NeoSwitchTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.repeat_rounded,
                          iconColor: const Color(0xFFEC4899),
                          title: l10n.t('spaced_rep'),
                          subtitle: null,
                          value: s.spacedRep,
                          onChanged: s.setSpacedRep,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GlassSection(
                      c: c,
                      isDark: isDark,
                      title: l10n.t('data_section'),
                      icon: Icons.cloud_sync_rounded,
                      children: [
                        ListenableBuilder(
                          listenable: repo,
                          builder: (context, _) => StatsPanel(
                            c: c,
                            isDark: isDark,
                            history: repo.count,
                            favorites: repo.favoritesCount,
                          ),
                        ),
                        const SizedBox(height: 14),
                        NeoSwitchTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.save_rounded,
                          iconColor: const Color(0xFF06B6D4),
                          title: l10n.t('auto_save_history'),
                          subtitle: l10n.t('auto_save_desc'),
                          value: s.autoSaveHistory,
                          onChanged: s.setAutoSaveHistory,
                        ),
                        PillSegment<int>(
                          c: c,
                          isDark: isDark,
                          label: l10n.t('auto_clean'),
                          icon: Icons.cleaning_services_rounded,
                          value: s.autoCleanDays,
                          options: const [(0, '—'), (30, '30d'), (90, '90d')],
                          onChanged: s.setAutoCleanDays,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            l10n.t('auto_clean_desc'),
                            style: AppTheme.caption(color: c.faint, size: 11),
                          ),
                        ),
                        const SizedBox(height: 6),
                        GradientActionTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.file_download_rounded,
                          title: l10n.t('export_history'),
                          gradient: const [
                            Color(0xFF3B82F6),
                            Color(0xFF8B5CF6),
                          ],
                          onTap: () => exportHistoryFile(context, repo),
                        ),
                        GradientActionTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.file_upload_rounded,
                          title: l10n.t('import_history'),
                          gradient: const [
                            Color(0xFF10B981),
                            Color(0xFF06B6D4),
                          ],
                          onTap: () => importHistoryClipboard(context, repo),
                        ),
                        const SizedBox(height: 8),
                        DangerZone(
                          c: c,
                          onClearHistory: () =>
                              clearHistoryAction(context, repo),
                          onClearFavorites: () =>
                              clearFavoritesAction(context, repo),
                          onClearAll: () => clearAllAction(context, repo),
                          onClearPhotos: () async {
                            if (!kCameraEnabled) {
                              showComingSoonAnywhere(context);
                            } else {
                              await clearPhotosAction(context);
                            }
                          },
                          showPhotosBadge: !kCameraEnabled,
                          lang: s.lang.name,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GlassSection(
                      c: c,
                      isDark: isDark,
                      title: l10n.t('look_section'),
                      icon: Icons.format_paint_rounded,
                      children: [
                        AccentLabel(c: c, label: l10n.t('accent_color')),
                        const SizedBox(height: 12),
                        AccentPicker(
                          c: c,
                          index: s.accentIndex,
                          on: s.setAccentIndex,
                        ),
                        const SizedBox(height: 16),
                        NeoSwitchTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.animation_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: l10n.t('animations'),
                          subtitle: l10n.t('animations_desc'),
                          value: s.animationsOn,
                          onChanged: s.setAnimationsOn,
                        ),
                        NeoSwitchTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.view_agenda_rounded,
                          iconColor: const Color(0xFFEC4899),
                          title: l10n.t('compact'),
                          subtitle: l10n.t('compact_desc'),
                          value: s.compact,
                          onChanged: s.setCompact,
                        ),
                        _CameraTabSwitchTile(c: c, isDark: isDark),
                        AccentLabel(c: c, label: l10n.t('theme')),
                        const SizedBox(height: 10),
                        ThemeSwitcher(
                          c: c,
                          isDark: isDark,
                          value: s.themeMode,
                          onChanged: s.setTheme,
                        ),
                        const SizedBox(height: 16),
                        AccentLabel(c: c, label: l10n.t('interface_language')),
                        const SizedBox(height: 10),
                        LanguagePicker(
                          c: c,
                          isDark: isDark,
                          value: s.lang,
                          onChanged: s.setLang,
                        ),
                        const SizedBox(height: 16),
                        GlowSliderTile(
                          c: c,
                          isDark: isDark,
                          title: l10n.t('font_size'),
                          valueLabel: '${(s.fontScale * 100).round()}%',
                          value: s.fontScale,
                          min: 0.85,
                          max: 1.3,
                          divisions: 9,
                          onChanged: s.setFontScale,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GlassSection(
                      c: c,
                      isDark: isDark,
                      title: l10n.t('about_section'),
                      icon: Icons.info_outline_rounded,
                      children: [
                        AboutTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.privacy_tip_rounded,
                          gradient: const [
                            Color(0xFF3B82F6),
                            Color(0xFF06B6D4),
                          ],
                          title: l10n.t('privacy_policy'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyScreen(),
                            ),
                          ),
                        ),
                        AboutTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.gavel_rounded,
                          gradient: const [
                            Color(0xFFF59E0B),
                            Color(0xFFEC4899),
                          ],
                          title: l10n.t('terms_of_service'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TermsScreen(),
                            ),
                          ),
                        ),
                        AboutTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.description_rounded,
                          gradient: const [
                            Color(0xFF8B5CF6),
                            Color(0xFFEC4899),
                          ],
                          title: l10n.t('licenses'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LicensesScreen(),
                            ),
                          ),
                        ),
                        AboutTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.share_rounded,
                          gradient: const [
                            Color(0xFF10B981),
                            Color(0xFF3B82F6),
                          ],
                          title: l10n.t('share_app'),
                          onTap: () => shareAppApk(context),
                        ),
                        AboutTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.feedback_outlined,
                          gradient: const [
                            Color(0xFFEC4899),
                            Color(0xFF8B5CF6),
                          ],
                          title: l10n.t('feedback'),
                          onTap: () => showSettingsFeedbackSheet(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    VersionFooter(c: c, versionLabel: l10n.t('version')),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Toggle for showing the camera tab in the bottom navigation.
class _CameraTabSwitchTile extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  const _CameraTabSwitchTile({required this.c, required this.isDark});

  String _title(AppLang l) => switch (l) {
    AppLang.ru => 'Камера в нижнем меню',
    AppLang.en => 'Camera tab in bottom nav',
    AppLang.tk => 'Kamera aşaky menýuda',
    AppLang.tr => 'Alt menüde kamera sekmesi',
  };

  String _desc(AppLang l) => switch (l) {
    AppLang.ru => 'Показывать вкладку камеры в нижней панели',
    AppLang.en => 'Show the camera tab in the bottom bar',
    AppLang.tk => 'Kamera sekmesini aşaky panelde görkez',
    AppLang.tr => 'Kamera sekmesini alt çubukta göster',
  };

  @override
  Widget build(BuildContext context) {
    final s = context.settings;
    return NeoSwitchTile(
      c: c,
      isDark: isDark,
      icon: Icons.photo_camera_rounded,
      iconColor: const Color(0xFF0EA5E9),
      title: _title(s.lang),
      subtitle: _desc(s.lang),
      value: s.showCameraTab,
      onChanged: s.setShowCameraTab,
    );
  }
}
