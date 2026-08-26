import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'licenses_screen.dart';
import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../conversation/data/tts_service.dart';
import '../../history/data/history_repository.dart';
import '../../translate/data/languages.dart';
import '../../translate/data/offline_translator.dart';
import '../../camera/data/camera_repository.dart';
import '../../camera/presentation/camera_screen.dart'
    show kCameraEnabled, showComingSoonAnywhere;
import '../ui/privacy_policy_screen.dart';
import '../ui/terms_screen.dart';

const _telegramUrl = 'https://t.me/kopri_support_bot';
const _apkChannel = MethodChannel('kopri/apk');

String _langFlag(String code) => switch (code) {
  'auto' => '🌐',
  'az' => '🇦🇿',
  'af' => '🇿🇦',
  'sq' => '🇦🇱',
  'am' => '🇪🇹',
  'en' => '🇬🇧',
  'ar' => '🇸🇦',
  'hy' => '🇦🇲',
  'eu' => '🇪🇸',
  'be' => '🇧🇾',
  'bn' => '🇧🇩',
  'my' => '🇲🇲',
  'bg' => '🇧🇬',
  'bs' => '🇧🇦',
  'cy' => '🇬🇧',
  'hu' => '🇭🇺',
  'vi' => '🇻🇳',
  'gl' => '🇪🇸',
  'el' => '🇬🇷',
  'ka' => '🇬🇪',
  'gu' => '🇮🇳',
  'da' => '🇩🇰',
  'zu' => '🇿🇦',
  'he' => '🇮🇱',
  'id' => '🇮🇩',
  'ga' => '🇮🇪',
  'is' => '🇮🇸',
  'es' => '🇪🇸',
  'it' => '🇮🇹',
  'yo' => '🇳🇬',
  'kk' => '🇰🇿',
  'kn' => '🇮🇳',
  'ca' => '🇪🇸',
  'ky' => '🇰🇬',
  'zh' => '🇨🇳',
  'ko' => '🇰🇷',
  'km' => '🇰🇭',
  'lo' => '🇱🇦',
  'la' => '🇻🇦',
  'lv' => '🇱🇻',
  'lt' => '🇱🇹',
  'mk' => '🇲🇰',
  'ms' => '🇲🇾',
  'ml' => '🇮🇳',
  'mt' => '🇲🇹',
  'mr' => '🇮🇳',
  'mn' => '🇲🇳',
  'ne' => '🇳🇵',
  'nl' => '🇳🇱',
  'no' => '🇳🇴',
  'pa' => '🇮🇳',
  'fa' => '🇮🇷',
  'pl' => '🇵🇱',
  'pt' => '🇵🇹',
  'ro' => '🇷🇴',
  'ru' => '🇷🇺',
  'sr' => '🇷🇸',
  'si' => '🇱🇰',
  'sk' => '🇸🇰',
  'sl' => '🇸🇮',
  'sw' => '🇰🇪',
  'tg' => '🇹🇯',
  'th' => '🇹🇭',
  'ta' => '🇮🇳',
  'te' => '🇮🇳',
  'tr' => '🇹🇷',
  'tk' => '🇹🇲',
  'uz' => '🇺🇿',
  'uk' => '🇺🇦',
  'ur' => '🇵🇰',
  'fi' => '🇫🇮',
  'fr' => '🇫🇷',
  'hi' => '🇮🇳',
  'hr' => '🇭🇷',
  'cs' => '🇨🇿',
  'sv' => '🇸🇪',
  'et' => '🇪🇪',
  'ja' => '🇯🇵',
  _ => '🌐',
};

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
              _buildHeader(c, l10n, isDark),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _GlassSection(
                      c: c,
                      isDark: isDark,
                      title: l10n.t('translation_section'),
                      icon: Icons.auto_awesome_rounded,
                      children: [
                        _PickerTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.input_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          title: l10n.t('default_source'),
                          value: AppLanguages.nameOf(s.defaultFrom),
                          flag: _langFlag(s.defaultFrom),
                          onTap: () => _pickLang(
                            context,
                            AppLanguages.sources,
                            s.setDefaultFrom,
                          ),
                        ),
                        _PickerTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.translate_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: l10n.t('default_target'),
                          value: AppLanguages.nameOf(s.defaultTo),
                          flag: _langFlag(s.defaultTo),
                          onTap: () => _pickLang(
                            context,
                            AppLanguages.all,
                            s.setDefaultTo,
                          ),
                        ),
                        _NeoSwitchTile(
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
                          _GlowSliderTile(
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
                        _ClipboardSwitchTile(c: c, isDark: isDark),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _OfflineModelsGlassSection(
                      key: ValueKey('offline_${s.lang.index}'),
                    ),
                    const SizedBox(height: 20),
                    _GlassSection(
                      c: c,
                      isDark: isDark,
                      title: l10n.t('speech_section'),
                      icon: Icons.spatial_audio_off_rounded,
                      children: [
                        _NeoSwitchTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.record_voice_over_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: l10n.t('auto_speak'),
                          subtitle: l10n.t('auto_speak_desc'),
                          value: s.autoSpeak,
                          onChanged: s.setAutoSpeak,
                        ),
                        _GlowSliderTile(
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
                        _GlowSliderTile(
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
                        _GlowSliderTile(
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
                        _ListenPreviewTile(
                          c: c,
                          isDark: isDark,
                          onTap: () =>
                              TtsService().speak(_example(s.lang), s.lang.name),
                        ),
                        _GlowSliderTile(
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
                        _GlowSliderTile(
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
                    _GlassSection(
                      c: c,
                      isDark: isDark,
                      title: l10n.t('phrasebook_section'),
                      icon: Icons.menu_book_rounded,
                      children: [
                        _PillSegment<PhraseSpeakMode>(
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
                        _PillSegment<int>(
                          c: c,
                          isDark: isDark,
                          label: l10n.t('flashcard_session'),
                          icon: Icons.style_rounded,
                          value: s.flashcardSession,
                          options: const [(10, '10'), (20, '20'), (50, '50')],
                          onChanged: s.setFlashcardSession,
                        ),
                        _NeoSwitchTile(
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
                    _GlassSection(
                      c: c,
                      isDark: isDark,
                      title: l10n.t('data_section'),
                      icon: Icons.cloud_sync_rounded,
                      children: [
                        ListenableBuilder(
                          listenable: repo,
                          builder: (context, _) => _StatsPanel(
                            c: c,
                            isDark: isDark,
                            history: repo.count,
                            favorites: repo.favoritesCount,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _NeoSwitchTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.save_rounded,
                          iconColor: const Color(0xFF06B6D4),
                          title: l10n.t('auto_save_history'),
                          subtitle: l10n.t('auto_save_desc'),
                          value: s.autoSaveHistory,
                          onChanged: s.setAutoSaveHistory,
                        ),
                        _PillSegment<int>(
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
                        _GradientActionTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.file_download_rounded,
                          title: l10n.t('export_history'),
                          gradient: const [
                            Color(0xFF3B82F6),
                            Color(0xFF8B5CF6),
                          ],
                          onTap: () => _exportFile(context),
                        ),
                        _GradientActionTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.file_upload_rounded,
                          title: l10n.t('import_history'),
                          gradient: const [
                            Color(0xFF10B981),
                            Color(0xFF06B6D4),
                          ],
                          onTap: () => _importClipboard(context),
                        ),
                        const SizedBox(height: 8),
                        _DangerZone(
                          c: c,
                          isDark: isDark,
                          onClearHistory: () => _clearHistory(context),
                          onClearFavorites: () => _clearFavorites(context),
                          onClearAll: () => _clearAll(context),
                          onClearPhotos: () async {
                            if (!kCameraEnabled) {
                              showComingSoonAnywhere(context);
                            } else {
                              await _clearPhotos(context);
                            }
                          },
                          showPhotosBadge: !kCameraEnabled,
                          lang: s.lang.name,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _GlassSection(
                      c: c,
                      isDark: isDark,
                      title: l10n.t('look_section'),
                      icon: Icons.format_paint_rounded,
                      children: [
                        _AccentLabel(c: c, label: l10n.t('accent_color')),
                        const SizedBox(height: 12),
                        _NewAccentPicker(
                          c: c,
                          index: s.accentIndex,
                          on: s.setAccentIndex,
                        ),
                        const SizedBox(height: 16),
                        _NeoSwitchTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.animation_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: l10n.t('animations'),
                          subtitle: l10n.t('animations_desc'),
                          value: s.animationsOn,
                          onChanged: s.setAnimationsOn,
                        ),
                        _NeoSwitchTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.view_agenda_rounded,
                          iconColor: const Color(0xFFEC4899),
                          title: l10n.t('compact'),
                          subtitle: l10n.t('compact_desc'),
                          value: s.compact,
                          onChanged: s.setCompact,
                        ),
                        _AccentLabel(c: c, label: l10n.t('theme')),
                        const SizedBox(height: 10),
                        _ThemeSwitcher(
                          c: c,
                          isDark: isDark,
                          value: s.themeMode,
                          onChanged: s.setTheme,
                        ),
                        const SizedBox(height: 16),
                        _AccentLabel(c: c, label: l10n.t('interface_language')),
                        const SizedBox(height: 10),
                        _LanguagePicker(
                          c: c,
                          isDark: isDark,
                          value: s.lang,
                          onChanged: s.setLang,
                        ),
                        const SizedBox(height: 16),
                        _GlowSliderTile(
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
                    _GlassSection(
                      c: c,
                      isDark: isDark,
                      title: l10n.t('about_section'),
                      icon: Icons.info_outline_rounded,
                      children: [
                        _AboutTile(
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
                        _AboutTile(
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
                        _AboutTile(
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
                        _AboutTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.share_rounded,
                          gradient: const [
                            Color(0xFF10B981),
                            Color(0xFF3B82F6),
                          ],
                          title: l10n.t('share_app'),
                          onTap: () => _shareApp(context),
                        ),
                        _AboutTile(
                          c: c,
                          isDark: isDark,
                          icon: Icons.feedback_outlined,
                          gradient: const [
                            Color(0xFFEC4899),
                            Color(0xFF8B5CF6),
                          ],
                          title: l10n.t('feedback'),
                          onTap: () => _openFeedback(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _VersionFooter(c: c, l10n: l10n),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppColors c, dynamic l10n, bool isDark) {
    return SliverAppBar(
      backgroundColor: c.bg,
      foregroundColor: c.text,
      elevation: 0,
      pinned: true,
      expandedHeight: 180,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final settings = context
              .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
          final range = settings == null
              ? 1.0
              : (settings.maxExtent - settings.minExtent);
          final double t = settings == null || range <= 0
              ? 1.0
              : ((settings.currentExtent - settings.minExtent) / range).clamp(
                  0.0,
                  1.0,
                );
          final double topPad = MediaQuery.of(context).padding.top;

          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              c.accent.withValues(alpha: 0.18),
                              c.accentDeep.withValues(alpha: 0.08),
                              c.bg,
                            ]
                          : [c.accent.withValues(alpha: 0.14), c.bgSoft, c.bg],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        c.accent.withValues(alpha: 0.45),
                        c.accent.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -40,
                bottom: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        c.accentHi.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: topPad + 8,
                child: Opacity(
                  opacity: 0.35 + 0.65 * t,
                  child: Container(
                    width: 44 + 28 * t,
                    height: 44 + 28 * t,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          c.accent.withValues(alpha: 0.95),
                          c.accentDeep.withValues(alpha: 0.95),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: c.accent.withValues(alpha: 0.45),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 80,
                bottom: 18,
                child: Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - t)),
                    child: Text(
                      l10n.t('settings'),
                      style: AppTheme.display(size: 22, color: c.text).copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 56,
                right: 70,
                top: topPad + (kToolbarHeight - 22) / 2,
                child: Opacity(
                  opacity: 1 - t,
                  child: Text(
                    l10n.t('settings'),
                    style: AppTheme.display(size: 17, color: c.text).copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _example(AppLang l) => switch (l) {
    AppLang.ru => 'Привет, как дела?',
    AppLang.tk => 'Salam, ýagdaýyňyz nähili?',
    AppLang.en => 'Hello, how are you?',
    AppLang.tr => 'Merhaba, nasılsınız?',
  };

  void _snack(BuildContext context, String t, {bool warn = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t),
          backgroundColor: warn ? context.c.warn : context.c.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

  Future<void> _shareApp(BuildContext context) async {
    final l10n = context.settings.l10n;
    if (!Platform.isAndroid) {
      if (context.mounted) _snack(context, l10n.t('share_unavailable'));
      return;
    }
    try {
      final apk = await _apkChannel.invokeMethod<String>('getApkPath');
      final cache = await _apkChannel.invokeMethod<String>('getCacheDir');
      if (apk == null || cache == null || apk.isEmpty) {
        if (context.mounted) _snack(context, l10n.t('apk_not_found'));
        return;
      }
      final dest = File('$cache/Kopri.apk');
      await File(apk).copy(dest.path);
      await Share.shareXFiles(
        [XFile(dest.path)],
        subject: 'Köpri',
        text: 'Köpri — ähli dillerde terjimeçi 🌉',
      );
    } catch (e) {
      if (context.mounted) _snack(context, '${l10n.t('share_failed')}: $e');
    }
  }

  void _openFeedback(BuildContext context) {
    final c = context.c;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _FeedbackSheet(c: c),
    );
  }

  Future<void> _openEmail(BuildContext context) async {
    final l10n = context.settings.l10n;
    try {
      await launchUrl(Uri.parse('mailto:shapak.apps@gmail.com'));
    } catch (_) {
      if (context.mounted) _snack(context, l10n.t('telegram_failed'));
    }
  }

  Future<void> _openTelegram(BuildContext context) async {
    final l10n = context.settings.l10n;
    try {
      await launchUrl(
        Uri.parse(_telegramUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      if (context.mounted) _snack(context, l10n.t('telegram_failed'));
    }
  }

  Future<void> _pickLang(
    BuildContext context,
    Map<String, String> opts,
    ValueChanged<String> on,
  ) async {
    final c = context.c;
    final code = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LanguageBottomSheet(c: c, opts: opts),
    );
    if (code != null) on(code);
  }

  Future<bool> _askConfirm(BuildContext context, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = ctx.c;
        final l10n = ctx.settings.l10n;
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: c.text,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                l10n.t('cancel'),
                style: TextStyle(color: c.sub, fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: c.warn,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l10n.t('confirm'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
    return ok == true;
  }

  Future<void> _clearHistory(BuildContext context) async {
    final l10n = context.settings.l10n;
    if (!await _askConfirm(context, l10n.t('clear_history'))) return;
    final n = await repo.clear();
    if (context.mounted) _snack(context, '${l10n.t('cleared')} · $n');
  }

  Future<void> _clearFavorites(BuildContext context) async {
    final l10n = context.settings.l10n;
    if (!await _askConfirm(context, l10n.t('clear_favorites'))) return;
    final n = await repo.clearFavorites();
    if (context.mounted) _snack(context, '${l10n.t('removed_stars')} · $n');
  }

  Future<void> _clearAll(BuildContext context) async {
    final l10n = context.settings.l10n;
    if (!await _askConfirm(context, l10n.t('clear_all'))) return;
    final n = await repo.clear();
    if (context.mounted) _snack(context, '${l10n.t('cleared')} · $n');
  }

  Future<void> _clearPhotos(BuildContext context) async {
    final l10n = context.settings.l10n;
    if (!await _askConfirm(context, l10n.t('clear_photos'))) return;
    final n = await CameraRepository.instance.clearAll();
    if (context.mounted) _snack(context, '${l10n.t('photos_cleared')} · $n');
  }

  Future<void> _exportFile(BuildContext context) async {
    final l10n = context.settings.l10n;
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.c.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: context.c.accent),
                const SizedBox(height: 16),
                Text(
                  l10n.t('export_history'),
                  style: TextStyle(
                    color: context.c.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    String json = '';
    try {
      json = await repo.exportJson();
    } catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted) _snack(context, l10n.t('export_failed'), warn: true);
      return;
    }
    bool shared = false;
    try {
      if (Platform.isAndroid) {
        final cache = await _apkChannel.invokeMethod<String>('getCacheDir');
        if (cache != null && cache.isNotEmpty) {
          final file = File('$cache/kopri_history.json');
          await file.writeAsString(json);
          await Share.shareXFiles(
            [XFile(file.path)],
            subject: 'Köpri',
            text: 'Köpri — history',
          );
          shared = true;
        }
      }
    } catch (_) {}
    if (!shared) {
      try {
        await Clipboard.setData(ClipboardData(text: json));
        shared = true;
      } catch (_) {}
    }
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    if (context.mounted) {
      _snack(
        context,
        shared ? l10n.t('history_exported') : l10n.t('export_failed'),
        warn: !shared,
      );
    }
  }

  Future<void> _importClipboard(BuildContext context) async {
    final l10n = context.settings.l10n;
    final raw = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    if (raw == null || raw.trim().isEmpty) {
      if (context.mounted) _snack(context, l10n.t('no_data_clipboard'));
      return;
    }
    if (!await _askConfirm(context, l10n.t('import_history'))) return;
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.c.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: context.c.accent),
                const SizedBox(height: 16),
                Text(
                  l10n.t('import_history'),
                  style: TextStyle(
                    color: context.c.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    try {
      final n = await repo.importJson(raw);
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted)
        _snack(context, '${l10n.t('history_imported')} · $n');
    } on PlatformException catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      final msg = e.message ?? l10n.t('invalid_json');
      if (context.mounted)
        _snack(context, '${l10n.t('import_failed')}: $msg', warn: true);
    } catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted)
        _snack(context, '${l10n.t('import_failed')}: $e', warn: true);
    }
  }
}

class _GlassSection extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _GlassSection({
    required this.c,
    required this.isDark,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.06),
                  Colors.white.withValues(alpha: 0.02),
                ]
              : [
                  Colors.white.withValues(alpha: 0.90),
                  Colors.white.withValues(alpha: 0.70),
                ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      c.accent.withValues(alpha: 0.95),
                      c.accentDeep.withValues(alpha: 0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.display(
                  size: 15,
                  color: c.text,
                ).copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String flag;
  final VoidCallback onTap;
  const _PickerTile({
    required this.c,
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.flag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          margin: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      iconColor.withValues(alpha: 0.25),
                      iconColor.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.30),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: c.accent.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          color: c.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: c.faint, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeoSwitchTile extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _NeoSwitchTile({
    required this.c,
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  iconColor.withValues(alpha: 0.25),
                  iconColor.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.30),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTheme.caption(color: c.faint, size: 11),
                  ),
                ],
              ],
            ),
          ),
          _NeoSwitch(value: value, onChanged: onChanged, accentColor: c.accent),
        ],
      ),
    );
  }
}

class _NeoSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accentColor;
  const _NeoSwitch({
    required this.value,
    required this.onChanged,
    required this.accentColor,
  });

  @override
  State<_NeoSwitch> createState() => _NeoSwitchState();
}

class _NeoSwitchState extends State<_NeoSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.value ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant _NeoSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          const width = 52.0;
          const height = 30.0;
          const thumbSize = 24.0;
          const padding = 3.0;
          final thumbX = padding + (width - thumbSize - padding * 2) * t;

          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              gradient: LinearGradient(
                colors: t > 0.5
                    ? [
                        widget.accentColor.withValues(alpha: 0.95),
                        widget.accentColor.withValues(alpha: 0.75),
                      ]
                    : [
                        Colors.grey.withValues(alpha: 0.25),
                        Colors.grey.withValues(alpha: 0.15),
                      ],
              ),
              boxShadow: t > 0.5
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.45),
                        blurRadius: 12 * t,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: thumbX,
                  top: padding,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: t > 0.7 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 150),
                        child: Icon(
                          Icons.check_rounded,
                          color: widget.accentColor,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GlowSliderTile extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final String title;
  final String valueLabel;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;
  const _GlowSliderTile({
    required this.c,
    required this.isDark,
    required this.title,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: c.accent.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  valueLabel,
                  style: TextStyle(
                    color: c.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _GlowSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            accentColor: c.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _GlowSlider extends StatefulWidget {
  final double value, min, max;
  final int divisions;
  final Color accentColor;
  final ValueChanged<double> onChanged;
  const _GlowSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  State<_GlowSlider> createState() => _GlowSliderState();
}

class _GlowSliderState extends State<_GlowSlider> {
  final GlobalKey _trackKey = GlobalKey();
  bool _dragging = false;

  double _calcValue(double localX, double trackWidth) {
    final pct = (localX / trackWidth).clamp(0.0, 1.0);
    final raw = widget.min + (widget.max - widget.min) * pct;
    final step = (widget.max - widget.min) / widget.divisions;
    return ((raw / step).round() * step).clamp(widget.min, widget.max);
  }

  void _onDragStart(DragStartDetails details) {
    _dragging = true;
    final box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      widget.onChanged(_calcValue(details.localPosition.dx, box.size.width));
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_dragging) return;
    final box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      widget.onChanged(_calcValue(details.localPosition.dx, box.size.width));
    }
  }

  void _onDragEnd(DragEndDetails details) {
    _dragging = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = (widget.value - widget.min) / (widget.max - widget.min);

    return SizedBox(
      height: 36,
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onTapDown: (details) {
          final box =
              _trackKey.currentContext?.findRenderObject() as RenderBox?;
          if (box != null) {
            widget.onChanged(
              _calcValue(details.localPosition.dx, box.size.width),
            );
          }
        },
        child: LayoutBuilder(
          key: _trackKey,
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final thumbX = pct * width;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 14,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 14,
                  child: Container(
                    width: thumbX,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.accentColor.withValues(alpha: 0.95),
                          widget.accentColor.withValues(alpha: 0.70),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: thumbX - 14,
                  top: 4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: widget.accentColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PillSegment<T> extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final String label;
  final IconData icon;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;
  const _PillSegment({
    required this.c,
    required this.isDark,
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: c.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: c.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                for (final o in options)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(o.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: value == o.$1
                              ? LinearGradient(
                                  colors: [
                                    c.accent.withValues(alpha: 0.95),
                                    c.accentDeep.withValues(alpha: 0.95),
                                  ],
                                )
                              : null,
                          color: value == o.$1 ? null : Colors.transparent,
                          boxShadow: value == o.$1
                              ? [
                                  BoxShadow(
                                    color: c.accent.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          o.$2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: value == o.$1 ? Colors.white : c.sub,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListenPreviewTile extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final VoidCallback onTap;
  const _ListenPreviewTile({
    required this.c,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                c.accent.withValues(alpha: 0.20),
                c.accentDeep.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: c.accent.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      c.accent.withValues(alpha: 0.95),
                      c.accentDeep.withValues(alpha: 0.95),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withValues(alpha: 0.40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  context.settings.l10n.t('listen_preview'),
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Icon(Icons.volume_up_rounded, color: c.accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final int history;
  final int favorites;
  const _StatsPanel({
    required this.c,
    required this.isDark,
    required this.history,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.settings.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.accent.withValues(alpha: 0.18),
            c.accentDeep.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.accent.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              c: c,
              icon: Icons.history_rounded,
              gradient: const [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              count: history,
              label: l10n.t('history'),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: c.line.withValues(alpha: 0.5),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: _StatCell(
              c: c,
              icon: Icons.star_rounded,
              gradient: const [Color(0xFFF59E0B), Color(0xFFEC4899)],
              count: favorites,
              label: l10n.t('favorites'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final List<Color> gradient;
  final int count;
  final String label;
  const _StatCell({
    required this.c,
    required this.icon,
    required this.gradient,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: AppTheme.display(
            size: 20,
            color: c.text,
          ).copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.caption(color: c.faint, size: 11)),
      ],
    );
  }
}

class _GradientActionTile extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final IconData icon;
  final String title;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _GradientActionTile({
    required this.c,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.faint, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final VoidCallback onClearHistory;
  final VoidCallback onClearFavorites;
  final VoidCallback onClearAll;
  final VoidCallback onClearPhotos;
  final bool showPhotosBadge;
  final String lang;
  const _DangerZone({
    required this.c,
    required this.isDark,
    required this.onClearHistory,
    required this.onClearFavorites,
    required this.onClearAll,
    required this.onClearPhotos,
    required this.showPhotosBadge,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.warn.withValues(alpha: 0.12),
            c.warn.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.warn.withValues(alpha: 0.35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      c.warn.withValues(alpha: 0.95),
                      c.warn.withValues(alpha: 0.75),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: c.warn.withValues(alpha: 0.40),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                context.settings.l10n.t('danger_zone'),
                style: TextStyle(
                  color: c.warn,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DangerRow(
            c: c,
            icon: Icons.history_rounded,
            title: context.settings.l10n.t('clear_history'),
            onTap: onClearHistory,
          ),
          const SizedBox(height: 6),
          _DangerRow(
            c: c,
            icon: Icons.star_outline_rounded,
            title: context.settings.l10n.t('clear_favorites'),
            onTap: onClearFavorites,
          ),
          const SizedBox(height: 6),
          _DangerRow(
            c: c,
            icon: Icons.delete_forever_rounded,
            title: context.settings.l10n.t('clear_all'),
            onTap: onClearAll,
          ),
          const SizedBox(height: 6),
          _DangerRow(
            c: c,
            icon: Icons.photo_library_rounded,
            title: context.settings.l10n.t('clear_photos'),
            onTap: onClearPhotos,
            badge: showPhotosBadge ? _SoonLabel(lang: lang) : null,
          ),
        ],
      ),
    );
  }
}

class _DangerRow extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? badge;
  const _DangerRow({
    required this.c,
    required this.icon,
    required this.title,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: c.warn.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.warn.withValues(alpha: 0.20), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: c.warn, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: c.warn,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: -0.1,
                      ),
                    ),
                    if (badge != null) ...[const SizedBox(width: 8), badge!],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.warn, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoonLabel extends StatelessWidget {
  final String lang;
  const _SoonLabel({required this.lang});

  String get _text => switch (lang) {
    'ru' => 'Скоро',
    'en' => 'Soon',
    'tk' => 'Ýakyn',
    'tr' => 'Yakında',
    _ => 'Soon',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.40),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _AccentLabel extends StatelessWidget {
  final AppColors c;
  final String label;
  const _AccentLabel({required this.c, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: c.text,
        fontWeight: FontWeight.w800,
        fontSize: 14,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _NewAccentPicker extends StatelessWidget {
  final AppColors c;
  final int index;
  final ValueChanged<int> on;
  const _NewAccentPicker({
    required this.c,
    required this.index,
    required this.on,
  });

  @override
  Widget build(BuildContext context) {
    const perRow = 5;
    final rows = <Widget>[];
    for (var start = 0; start < accents.length; start += perRow) {
      final end = (start + perRow) > accents.length
          ? accents.length
          : start + perRow;
      final dots = <Widget>[
        for (var i = start; i < end; i++) Expanded(child: _accentDot(i)),
      ];
      for (var i = end; i < start + perRow; i++) {
        dots.add(const Expanded(child: SizedBox.shrink()));
      }
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 14));
      rows.add(Row(children: dots));
    }
    return Column(children: rows);
  }

  Widget _accentDot(int i) => GestureDetector(
    onTap: () => on(i),
    child: Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accents[i].dAccent,
              accents[i].dAccent.withValues(alpha: 0.75),
            ],
          ),
          border: Border.all(
            color: index == i ? c.text : Colors.transparent,
            width: 3,
          ),
          boxShadow: index == i
              ? [
                  BoxShadow(
                    color: accents[i].dAccent.withValues(alpha: 0.65),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [
                  BoxShadow(
                    color: accents[i].dAccent.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: index == i
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : null,
      ),
    ),
  );
}

class _ThemeSwitcher extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;
  const _ThemeSwitcher({
    required this.c,
    required this.isDark,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = <(ThemeMode, IconData, String)>[
      (ThemeMode.light, Icons.light_mode_rounded, 'Light'),
      (ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
      (ThemeMode.system, Icons.brightness_auto_rounded, 'Auto'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(o.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: value == o.$1
                        ? LinearGradient(
                            colors: [
                              c.accent.withValues(alpha: 0.95),
                              c.accentDeep.withValues(alpha: 0.95),
                            ],
                          )
                        : null,
                    boxShadow: value == o.$1
                        ? [
                            BoxShadow(
                              color: c.accent.withValues(alpha: 0.40),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        o.$2,
                        color: value == o.$1 ? Colors.white : c.sub,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        o.$3,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: value == o.$1 ? Colors.white : c.sub,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final AppLang value;
  final ValueChanged<AppLang> onChanged;
  const _LanguagePicker({
    required this.c,
    required this.isDark,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          for (final lang in AppLang.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(lang),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: value == lang
                        ? LinearGradient(
                            colors: [
                              c.accent.withValues(alpha: 0.95),
                              c.accentDeep.withValues(alpha: 0.95),
                            ],
                          )
                        : null,
                    boxShadow: value == lang
                        ? [
                            BoxShadow(
                              color: c.accent.withValues(alpha: 0.40),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(lang.flag, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        lang.title,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: value == lang ? Colors.white : c.sub,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final VoidCallback onTap;
  const _AboutTile({
    required this.c,
    required this.isDark,
    required this.icon,
    required this.gradient,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Icon(Icons.arrow_outward_rounded, color: c.faint, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionFooter extends StatelessWidget {
  final AppColors c;
  final dynamic l10n;
  const _VersionFooter({required this.c, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.accent.withValues(alpha: 0.08),
            c.accent.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.accent.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                LinearGradient(colors: [c.text, c.accent]).createShader(bounds),
            child: Text(
              'Köpri',
              style: AppTheme.logo(size: 28, color: Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${l10n.t('version')} 1.0.2',
            style: AppTheme.caption(color: c.faint, size: 11),
          ),
        ],
      ),
    );
  }
}

class _OfflineModelsGlassSection extends StatefulWidget {
  const _OfflineModelsGlassSection({super.key});
  @override
  State<_OfflineModelsGlassSection> createState() =>
      _OfflineModelsGlassSectionState();
}

class _OfflineModelsGlassSectionState extends State<_OfflineModelsGlassSection>
    with WidgetsBindingObserver {
  List<String>? _codes;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    OfflineTranslator.instance.addListener(_onModelsChanged);
    _load();
  }

  @override
  void dispose() {
    OfflineTranslator.instance.removeListener(_onModelsChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onModelsChanged() {
    if (mounted) _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    final list = await OfflineTranslator.instance.downloadedModels();
    if (!mounted) return;
    setState(() => _codes = list);
  }

  Future<void> _refresh() async {
    if (_busy || !mounted) return;
    setState(() => _busy = true);
    await _load();
    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<void> _deleteOne(String code) async {
    if (_busy || !mounted) return;
    setState(() => _busy = true);
    final ok = await OfflineTranslator.instance.deleteModel(code);
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    setState(() => _busy = false);
    final l10n = context.settings.l10n;
    _snack(
      ok
          ? l10n.t('offline_models_deleted_one')
          : l10n.t('offline_models_could_not_delete'),
      warn: !ok,
    );
  }

  Future<void> _deleteAll() async {
    if (_busy || !mounted) return;
    final was = (_codes ?? const <String>[]).length;
    if (was == 0) {
      _snack(context.settings.l10n.t('offline_models_none'), warn: true);
      return;
    }
    setState(() => _busy = true);
    final n = await OfflineTranslator.instance.deleteAllDownloaded();
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    setState(() => _busy = false);
    final l10n = context.settings.l10n;
    final String msg;
    final bool warn;
    if (n >= was) {
      msg = l10n.t('offline_models_deleted_all');
      warn = false;
    } else if (n > 0) {
      msg = l10n.t('offline_models_deleted_some');
      warn = false;
    } else {
      msg = l10n.t('offline_models_could_not_delete');
      warn = true;
    }
    _snack(msg, warn: warn);
  }

  void _snack(String t, {bool warn = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t),
          backgroundColor: warn ? context.c.warn : context.c.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.settings.l10n;
    final codes = _codes ?? const <String>[];
    final loaded = _codes != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final children = <Widget>[
      Row(
        children: [
          Expanded(
            child: Text(
              l10n.t('offline_models_desc'),
              style: AppTheme.caption(color: c.sub, size: 12),
            ),
          ),
          const SizedBox(width: 8),
          _RefreshButton(c: c, busy: _busy, onTap: _refresh),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        l10n.t('offline_models_desc2'),
        style: AppTheme.caption(color: c.faint, size: 11),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              c.warn.withValues(alpha: 0.12),
              c.warn.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.warn.withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: c.warn, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.t('offline_models_note_bg'),
                style: TextStyle(
                  color: c.warn,
                  fontSize: 11,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Text(
        l10n.t('offline_models_format'),
        style: AppTheme.caption(color: c.faint, size: 11),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _LangChip(c: c, label: 'af → en', isDark: isDark),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _LangChip(c: c, label: 'ru → tr', isDark: isDark),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _LangChip(c: c, label: 'en → de', isDark: isDark),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _LangChip(c: c, label: 'fr → es', isDark: isDark),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        l10n.t('offline_models_en_note'),
        style: AppTheme.caption(color: c.faint, size: 11),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              c.accent.withValues(alpha: 0.18),
              c.accentDeep.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.accent.withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    c.accent.withValues(alpha: 0.95),
                    c.accentDeep.withValues(alpha: 0.95),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: c.accent.withValues(alpha: 0.40),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.offline_bolt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${codes.length}',
              style: AppTheme.display(
                size: 22,
                color: c.text,
              ).copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
            const SizedBox(width: 6),
            Text(
              l10n.t('offline_models_downloaded'),
              style: AppTheme.caption(color: c.faint, size: 11),
            ),
            const Spacer(),
            if (_busy)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: c.accent,
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 12),
    ];

    if (!loaded) {
      children.add(
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: c.accent,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.t('offline_models_loading'),
                style: AppTheme.caption(color: c.faint, size: 12),
              ),
            ],
          ),
        ),
      );
    } else if (codes.isEmpty) {
      children.add(
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      c.accent.withValues(alpha: 0.20),
                      c.accentDeep.withValues(alpha: 0.10),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_off_rounded, color: c.accent, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.t('offline_models_empty'),
                style: AppTheme.caption(color: c.faint, size: 12),
              ),
            ],
          ),
        ),
      );
    } else {
      for (final code in codes) {
        children.add(
          _OfflineModelRow(
            c: c,
            code: code,
            busy: _busy,
            onDelete: () => _deleteOne(code),
            isDark: isDark,
          ),
        );
      }
      children.add(const SizedBox(height: 8));
      children.add(
        _DeleteAllButton(
          c: c,
          onTap: _deleteAll,
          busy: _busy,
          title: l10n.t('offline_models_delete_all'),
        ),
      );
    }

    return _GlassSection(
      c: c,
      isDark: isDark,
      title: l10n.t('offline_models_title'),
      icon: Icons.cloud_download_rounded,
      children: children,
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final AppColors c;
  final bool busy;
  final VoidCallback onTap;
  const _RefreshButton({
    required this.c,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: busy ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                c.accent.withValues(alpha: 0.20),
                c.accentDeep.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: c.accent.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
          child: Icon(Icons.refresh_rounded, color: c.accent, size: 20),
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final AppColors c;
  final String label;
  final bool isDark;
  const _LangChip({required this.c, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.accent.withValues(alpha: 0.14),
            c.accentDeep.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.accent.withValues(alpha: 0.22), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: c.accent,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _OfflineModelRow extends StatelessWidget {
  final AppColors c;
  final String code;
  final bool busy;
  final VoidCallback onDelete;
  final bool isDark;
  const _OfflineModelRow({
    required this.c,
    required this.code,
    required this.busy,
    required this.onDelete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final name = AppLanguages.all[code] ?? code.toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  c.accent.withValues(alpha: 0.95),
                  c.accentDeep.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: c.accent.withValues(alpha: 0.30),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.translate_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: -0.1,
                  ),
                ),
                Text(
                  code.toUpperCase(),
                  style: AppTheme.caption(color: c.faint, size: 10),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: busy ? 0.4 : 1,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: busy ? null : onDelete,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        c.warn.withValues(alpha: 0.20),
                        c.warn.withValues(alpha: 0.10),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: c.warn.withValues(alpha: 0.30),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: c.warn,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteAllButton extends StatelessWidget {
  final AppColors c;
  final VoidCallback onTap;
  final bool busy;
  final String title;
  const _DeleteAllButton({
    required this.c,
    required this.onTap,
    required this.busy,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: busy ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                c.warn.withValues(alpha: 0.90),
                c.warn.withValues(alpha: 0.70),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: c.warn.withValues(alpha: 0.40),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClipboardSwitchTile extends StatefulWidget {
  final AppColors c;
  final bool isDark;
  const _ClipboardSwitchTile({required this.c, required this.isDark});

  @override
  State<_ClipboardSwitchTile> createState() => _ClipboardSwitchTileState();
}

class _ClipboardSwitchTileState extends State<_ClipboardSwitchTile> {
  static const _ch = MethodChannel('kopri/apk');
  bool _on = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _ch.invokeMethod<bool>('isClipboardRunning').then((v) {
        if (mounted) setState(() => _on = v == true);
      });
    }
  }

  String get _title => switch (context.settings.lang) {
    AppLang.ru => 'Перевод из буфера',
    AppLang.en => 'Clipboard translate',
    AppLang.tk => 'Buferden terjime',
    AppLang.tr => 'Panodan çeviri',
  };

  String get _desc => switch (context.settings.lang) {
    AppLang.ru =>
      'Копируй текст в любом приложении — Köpri покажет перевод поверх экрана',
    AppLang.en => 'Copy text in any app — Köpri shows the translation on top',
    AppLang.tk =>
      'Islendik programmada tekst göçür — Köpri terjimäni ekranyň üstünde görkezer',
    AppLang.tr =>
      'Herhangi bir uygulamada metni kopyala — Köpri çeviriyi ekranın üstünde gösterir',
  };

  Future<void> _toggle(bool v) async {
    if (_busy || !Platform.isAndroid) return;
    setState(() => _busy = true);
    try {
      if (v) {
        final can = await _ch.invokeMethod<bool>('canDrawOverlays') == true;
        if (!can) {
          await _ch.invokeMethod('openOverlaySettings');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(switch (context.settings.lang) {
                  AppLang.ru =>
                    'Разреши «Показ поверх окон», затем включи снова',
                  AppLang.en =>
                    'Allow "Display over other apps", then turn on again',
                  AppLang.tk =>
                    '"Beýleki programmalaryň üstünde" rugsadyny ber, soň ýene aç',
                  AppLang.tr =>
                    '"Diğer uygulamaların üzerinde göster" iznini ver, sonra tekrar aç',
                }),
                backgroundColor: context.c.warn,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
          }
        } else {
          final ok = await _ch.invokeMethod<bool>('startClipboard', {
            'source': context.settings.defaultFrom,
            'target': context.settings.defaultTo,
          });
          if (ok == true && mounted) setState(() => _on = true);
        }
      } else {
        await _ch.invokeMethod('stopClipboard');
        if (mounted) setState(() => _on = false);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) return const SizedBox.shrink();
    return _NeoSwitchTile(
      c: widget.c,
      isDark: widget.isDark,
      icon: Icons.content_paste_rounded,
      iconColor: const Color(0xFF06B6D4),
      title: _title,
      subtitle: _desc,
      value: _on,
      onChanged: _toggle,
    );
  }
}

class _FeedbackSheet extends StatelessWidget {
  final AppColors c;
  const _FeedbackSheet({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0F1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      c.accent.withValues(alpha: 0.95),
                      c.accentDeep.withValues(alpha: 0.95),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withValues(alpha: 0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.feedback_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Get in Touch',
                style: AppTheme.display(
                  size: 22,
                  color: c.text,
                ).copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
              const SizedBox(height: 6),
              Text(
                'We\'d love to hear from you',
                style: AppTheme.caption(color: c.faint, size: 13),
              ),
              const SizedBox(height: 28),
              _FeedbackOption(
                c: c,
                gradient: const [Color(0xFF0088CC), Color(0xFF3B82F6)],
                icon: Icons.telegram_rounded,
                title: 'Telegram',
                subtitle: '@kopri_support_bot',
                onTap: () {
                  Navigator.pop(context);
                  _openTelegramExt(context);
                },
              ),
              const SizedBox(height: 12),
              _FeedbackOption(
                c: c,
                gradient: [c.accent, c.accentDeep],
                icon: Icons.mail_rounded,
                title: 'Email',
                subtitle: 'shapak.apps@gmail.com',
                onTap: () {
                  Navigator.pop(context);
                  _openEmailExt(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openTelegramExt(BuildContext context) async {
    try {
      await launchUrl(
        Uri.parse(_telegramUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  Future<void> _openEmailExt(BuildContext context) async {
    try {
      await launchUrl(Uri.parse('mailto:shapak.apps@gmail.com'));
    } catch (_) {}
  }
}

class _FeedbackOption extends StatelessWidget {
  final AppColors c;
  final List<Color> gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _FeedbackOption({
    required this.c,
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: c.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.caption(color: c.faint, size: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_outward_rounded, color: c.faint, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageBottomSheet extends StatelessWidget {
  final AppColors c;
  final Map<String, String> opts;
  const _LanguageBottomSheet({required this.c, required this.opts});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = opts.entries.toList();
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0F1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Language',
              style: AppTheme.display(
                size: 18,
                color: c.text,
              ).copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: entries.length,
                itemBuilder: (context, i) {
                  final e = entries[i];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pop(context, e.key),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _langFlag(e.key),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  color: c.text,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
