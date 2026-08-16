import 'dart:io';
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

const _telegramUrl = 'https://t.me/kopri_support_bot';
const _apkChannel = MethodChannel('kopri/apk');

class SettingsScreen extends StatelessWidget {
  final HistoryRepository repo;
  const SettingsScreen({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final s = context.settings, c = context.c, l10n = s.l10n;
    return Scaffold(
      backgroundColor: c.bg,
      body: ListenableBuilder(
        listenable: s,
        builder: (context, _) => CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: c.bg,
              foregroundColor: c.text,
              elevation: 0,
              pinned: true,
              expandedHeight: 116,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
                title: Text(
                  l10n.t('settings'),
                  style: AppTheme.display(size: 18, color: c.text),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [c.accent.withValues(alpha: 0.16), c.bg],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 22, top: 6),
                        child: Icon(
                          Icons.tune_rounded,
                          color: c.accent,
                          size: 78,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _Section(c, l10n.t('translation_section'), [
                    _PickerRow(
                      c,
                      Icons.input_rounded,
                      l10n.t('default_source'),
                      AppLanguages.nameOf(s.defaultFrom),
                      () => _pickLang(
                        context,
                        AppLanguages.sources,
                        s.setDefaultFrom,
                      ),
                    ),
                    _PickerRow(
                      c,
                      Icons.translate_rounded,
                      l10n.t('default_target'),
                      AppLanguages.nameOf(s.defaultTo),
                      () =>
                          _pickLang(context, AppLanguages.all, s.setDefaultTo),
                    ),
                    _SwitchRow(
                      c,
                      Icons.bolt_rounded,
                      l10n.t('auto_translate'),
                      l10n.t('auto_translate_desc'),
                      s.autoTranslate,
                      s.setAutoTranslate,
                    ),
                    if (s.autoTranslate)
                      _SliderRow(
                        c,
                        l10n.t('translate_delay'),
                        '${s.translateDelayMs} ms',
                        s.translateDelayMs.toDouble(),
                        300,
                        2000,
                        17,
                        (v) => s.setTranslateDelayMs(v.round()),
                      ),
                    const ClipboardSwitchRow(),
                  ]),
                  const SizedBox(height: 14),
                  // ── НОВЫЙ БЛОК: оффлайн-модели ──
                  _OfflineModelsSection(key: ValueKey(s.lang.index)),
                  const SizedBox(height: 14),
                  _Section(c, l10n.t('speech_section'), [
                    _SwitchRow(
                      c,
                      Icons.record_voice_over_rounded,
                      l10n.t('auto_speak'),
                      l10n.t('auto_speak_desc'),
                      s.autoSpeak,
                      s.setAutoSpeak,
                    ),
                    _SliderRow(
                      c,
                      l10n.t('speech_rate'),
                      '${(s.speechRate * 100).round()}%',
                      s.speechRate,
                      0.1,
                      1.0,
                      18,
                      s.setSpeechRate,
                    ),
                    _SliderRow(
                      c,
                      l10n.t('volume'),
                      '${(s.ttsVolume * 100).round()}%',
                      s.ttsVolume,
                      0.0,
                      1.0,
                      10,
                      s.setTtsVolume,
                    ),
                    _SliderRow(
                      c,
                      l10n.t('pitch'),
                      '${(s.ttsPitch * 100).round()}%',
                      s.ttsPitch,
                      0.5,
                      1.5,
                      10,
                      s.setTtsPitch,
                    ),
                    _ActionRow(
                      c,
                      Icons.play_circle_outline_rounded,
                      l10n.t('listen_preview'),
                      c.accent,
                      () => TtsService().speak(_example(s.lang), s.lang.name),
                    ),
                    _SliderRow(
                      c,
                      l10n.t('mic_listen_for'),
                      '${s.listenSeconds} s',
                      s.listenSeconds.toDouble(),
                      10,
                      120,
                      22,
                      (v) => s.setListenSeconds(v.round()),
                    ),
                    _SliderRow(
                      c,
                      l10n.t('mic_pause'),
                      '${s.pauseSeconds} s',
                      s.pauseSeconds.toDouble(),
                      1,
                      6,
                      5,
                      (v) => s.setPauseSeconds(v.round()),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _Section(c, l10n.t('phrasebook_section'), [
                    _SwitchRow(
                      c,
                      Icons.text_fields_rounded,
                      l10n.t('show_transcription'),
                      null,
                      s.showTranscription,
                      s.setShowTranscription,
                    ),
                    _SegRow<PhraseSpeakMode>(
                      c,
                      Icons.volume_up_rounded,
                      l10n.t('phrase_speak'),
                      s.phraseSpeak,
                      [
                        (PhraseSpeakMode.iface, l10n.t('phrase_speak_iface')),
                        (
                          PhraseSpeakMode.english,
                          l10n.t('phrase_speak_english'),
                        ),
                        (PhraseSpeakMode.both, l10n.t('phrase_speak_both')),
                      ],
                      s.setPhraseSpeak,
                    ),
                    _SegRow<int>(
                      c,
                      Icons.style_rounded,
                      l10n.t('flashcard_session'),
                      s.flashcardSession,
                      [(10, '10'), (20, '20'), (50, '50')],
                      s.setFlashcardSession,
                    ),
                    _SwitchRow(
                      c,
                      Icons.repeat_rounded,
                      l10n.t('spaced_rep'),
                      null,
                      s.spacedRep,
                      s.setSpacedRep,
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _Section(c, l10n.t('data_section'), [
                    ListenableBuilder(
                      listenable: repo,
                      builder: (context, _) =>
                          _DataCounter(c, repo.count, repo.favoritesCount),
                    ),
                    const SizedBox(height: 10),
                    _SwitchRow(
                      c,
                      Icons.save_rounded,
                      l10n.t('auto_save_history'),
                      l10n.t('auto_save_desc'),
                      s.autoSaveHistory,
                      s.setAutoSaveHistory,
                    ),
                    _SegRow<int>(
                      c,
                      Icons.cleaning_services_rounded,
                      l10n.t('auto_clean'),
                      s.autoCleanDays,
                      [(0, '—'), (30, '30d'), (90, '90d')],
                      s.setAutoCleanDays,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 6),
                      child: Text(
                        l10n.t('auto_clean_desc'),
                        style: AppTheme.caption(color: c.faint, size: 11),
                      ),
                    ),
                    _ActionRow(
                      c,
                      Icons.file_download_rounded,
                      l10n.t('export_history'),
                      c.accent,
                      () => _exportFile(context),
                    ),
                    _ActionRow(
                      c,
                      Icons.file_upload_rounded,
                      l10n.t('import_history'),
                      c.accent,
                      () => _importClipboard(context),
                    ),
                    _DangerRow(
                      c,
                      Icons.history_rounded,
                      l10n.t('clear_history'),
                      () => _clearHistory(context),
                    ),
                    _DangerRow(
                      c,
                      Icons.star_outline_rounded,
                      l10n.t('clear_favorites'),
                      () => _clearFavorites(context),
                    ),
                    _DangerRow(
                      c,
                      Icons.delete_forever_rounded,
                      l10n.t('clear_all'),
                      () => _clearAll(context),
                    ),
                    _DangerRow(
                      c,
                      Icons.photo_library_rounded,
                      l10n.t('clear_photos'),
                      () => _clearPhotos(context),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _Section(c, l10n.t('look_section'), [
                    _RowLabel(c, l10n.t('accent_color')),
                    const SizedBox(height: 10),
                    _AccentPicker(c, s.accentIndex, s.setAccentIndex),
                    const SizedBox(height: 14),
                    _SwitchRow(
                      c,
                      Icons.animation_rounded,
                      l10n.t('animations'),
                      l10n.t('animations_desc'),
                      s.animationsOn,
                      s.setAnimationsOn,
                    ),
                    _SwitchRow(
                      c,
                      Icons.view_agenda_rounded,
                      l10n.t('compact'),
                      l10n.t('compact_desc'),
                      s.compact,
                      s.setCompact,
                    ),
                    _RowLabel(c, l10n.t('theme')),
                    const SizedBox(height: 8),
                    _SegRow<ThemeMode>(
                      c,
                      Icons.palette_rounded,
                      '',
                      s.themeMode,
                      [
                        (ThemeMode.dark, l10n.t('theme_dark')),
                        (ThemeMode.light, l10n.t('theme_light')),
                        (ThemeMode.system, l10n.t('theme_system')),
                      ],
                      s.setTheme,
                    ),
                    const SizedBox(height: 14),
                    _RowLabel(c, l10n.t('interface_language')),
                    const SizedBox(height: 8),
                    _SegRow<AppLang>(
                      c,
                      Icons.language_rounded,
                      '',
                      s.lang,
                      AppLang.values
                          .map((e) => (e, '${e.flag} ${e.title}'))
                          .toList(),
                      s.setLang,
                    ),
                    const SizedBox(height: 14),
                    _SliderRow(
                      c,
                      l10n.t('font_size'),
                      '${(s.fontScale * 100).round()}%',
                      s.fontScale,
                      0.85,
                      1.3,
                      9,
                      s.setFontScale,
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _Section(c, l10n.t('about_section'), [
                    _ActionRow(
                      c,
                      Icons.description_rounded,
                      l10n.t('licenses'),
                      c.sub,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LicensesScreen(),
                        ),
                      ),
                    ),
                    _ActionRow(
                      c,
                      Icons.share_rounded,
                      l10n.t('share_app'),
                      c.sub,
                      () => _shareApp(context),
                    ),
                    _ActionRow(
                      c,
                      Icons.telegram_rounded,
                      l10n.t('feedback'),
                      c.sub,
                      () => _openTelegram(context),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Köpri · ${l10n.t('version')} 1.0.1',
                      style: AppTheme.caption(color: c.faint, size: 11),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _example(AppLang l) => switch (l) {
    AppLang.ru => 'Привет, как дела?',
    AppLang.tk => 'Salam, ýagdaýyňyz nähili?',
    AppLang.en => 'Hello, how are you?',
  };

  void _snack(BuildContext context, String t, {bool warn = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t),
          backgroundColor: warn ? context.c.warn : context.c.accent,
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
      backgroundColor: c.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: opts.entries
              .map(
                (e) => ListTile(
                  title: Text(e.value, style: TextStyle(color: c.text)),
                  onTap: () => Navigator.pop(context, e.key),
                ),
              )
              .toList(),
        ),
      ),
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
            borderRadius: BorderRadius.circular(18),
          ),
          content: Text(
            '$title?',
            style: TextStyle(color: c.text, fontWeight: FontWeight.w700),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.t('cancel'), style: TextStyle(color: c.sub)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l10n.t('confirm'),
                style: TextStyle(color: c.warn, fontWeight: FontWeight.w800),
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
          child: CircularProgressIndicator(color: context.c.accent),
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
    } catch (_) {
    }

    if (!shared) {
      try {
        await Clipboard.setData(ClipboardData(text: json));
        shared = true;
      } catch (_) {
      }
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
          child: CircularProgressIndicator(color: context.c.accent),
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


class _OfflineModelsSection extends StatefulWidget {
  const _OfflineModelsSection({super.key});
  @override
  State<_OfflineModelsSection> createState() => _OfflineModelsSectionState();
}

class _OfflineModelsSectionState extends State<_OfflineModelsSection>
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
        ),
      );

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.settings.l10n;
    final codes = _codes ?? const <String>[];
    final loaded = _codes != null;

    final children = <Widget>[
      Row(
        children: [
          Expanded(
            child: Text(
              l10n.t('offline_models_desc'),
              style: AppTheme.caption(color: c.sub, size: 12),
            ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.refresh_rounded, color: c.accent, size: 22),
              onPressed: _busy ? null : _refresh,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        l10n.t('offline_models_desc2'),
        style: AppTheme.caption(color: c.faint, size: 11),
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: c.warn.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.warn.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: c.warn, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.t('offline_models_note_bg'),
                style: TextStyle(
                  color: c.warn,
                  fontSize: 11,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Text(
        l10n.t('offline_models_format'),
        style: AppTheme.caption(color: c.faint, size: 11),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          _chip(c, 'af  →  en'),
          _chip(c, 'ru  →  tr'),
          _chip(c, 'en  →  de'),
          _chip(c, 'fr  →  es'),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        l10n.t('offline_models_en_note'),
        style: AppTheme.caption(color: c.faint, size: 11),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Icon(Icons.offline_bolt_rounded, color: c.accent, size: 18),
          const SizedBox(width: 8),
          Text(
            '${codes.length}',
            style: AppTheme.display(size: 18, color: c.text),
          ),
          const SizedBox(width: 6),
          Text(
            l10n.t('offline_models_downloaded'),
            style: AppTheme.label(color: c.faint, size: 10),
          ),
          const Spacer(),
          if (_busy)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: c.accent,
              ),
            ),
        ],
      ),
      const SizedBox(height: 10),
    ];

    if (!loaded) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: c.accent,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.t('offline_models_loading'),
                style: AppTheme.caption(color: c.faint),
              ),
            ],
          ),
        ),
      );
    } else if (codes.isEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            l10n.t('offline_models_empty'),
            style: AppTheme.caption(color: c.faint, size: 11),
          ),
        ),
      );
    } else {
      for (final code in codes) {
        children.add(_modelRow(c, code));
      }
      children.add(const SizedBox(height: 6));
      children.add(
        _DangerRow(
          c,
          Icons.delete_sweep_rounded,
          l10n.t('offline_models_delete_all'),
          _deleteAll,
        ),
      );
    }

    return _Section(c, l10n.t('offline_models_title'), children);
  }

  Widget _chip(AppColors c, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: c.bgSoft,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: c.line),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: c.sub,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    ),
  );

  Widget _modelRow(AppColors c, String code) {
    final name = AppLanguages.all[code] ?? code.toUpperCase();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.translate_rounded, color: c.accent, size: 18),
          const SizedBox(width: 10),
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
                  ),
                ),
                Text(
                  code.toUpperCase(),
                  style: AppTheme.label(color: c.faint, size: 9),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: _busy ? 0.4 : 1,
            child: Material(
              color: c.warn.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _busy ? null : () => _deleteOne(code),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
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

class _Section extends StatelessWidget {
  final AppColors c;
  final String title;
  final List<Widget> children;
  const _Section(this.c, this.title, this.children);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
    decoration: BoxDecoration(
      color: c.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.label(color: c.accent, size: 11)),
        const SizedBox(height: 6),
        ...children,
      ],
    ),
  );
}

class _RowLabel extends StatelessWidget {
  final AppColors c;
  final String t;
  const _RowLabel(this.c, this.t);
  @override
  Widget build(BuildContext context) => Text(
    t,
    style: TextStyle(color: c.text, fontWeight: FontWeight.w700),
  );
}

class _SwitchRow extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String title;
  final String? desc;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow(
    this.c,
    this.icon,
    this.title,
    this.desc,
    this.value,
    this.onChanged,
  );
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: c.accent, size: 20),
        const SizedBox(width: 12),
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
                ),
              ),
              if (desc != null) ...[
                const SizedBox(height: 2),
                Text(desc!, style: AppTheme.caption(color: c.faint, size: 11)),
              ],
            ],
          ),
        ),
        Switch.adaptive(value: value, onChanged: onChanged),
      ],
    ),
  );
}

class _SliderRow extends StatelessWidget {
  final AppColors c;
  final String title;
  final String valueLabel;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;
  const _SliderRow(
    this.c,
    this.title,
    this.valueLabel,
    this.value,
    this.min,
    this.max,
    this.divisions,
    this.onChanged,
  );
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
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
                ),
              ),
            ),
            Text(valueLabel, style: AppTheme.label(color: c.accent, size: 10)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: c.accent,
          inactiveColor: c.line,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

class _SegRow<T> extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String title;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> on;
  const _SegRow(
    this.c,
    this.icon,
    this.title,
    this.value,
    this.options,
    this.on,
  );
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Row(
            children: [
              Icon(icon, color: c.accent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: c.bgSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.line),
          ),
          child: Row(
            children: [
              for (final o in options)
                Expanded(
                  child: GestureDetector(
                    onTap: () => on(o.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: value == o.$1
                            ? c.accent.withValues(alpha: 0.16)
                            : Colors.transparent,
                        border: Border.all(
                          color: value == o.$1 ? c.accent : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        o.$2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: value == o.$1 ? c.accent : c.sub,
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

class _PickerRow extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  const _PickerRow(this.c, this.icon, this.title, this.value, this.onTap);
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: c.accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: c.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: c.accent,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: c.sub, size: 22),
          ],
        ),
      ),
    ),
  );
}

class _ActionRow extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String title;
  final Color tint;
  final VoidCallback onTap;
  const _ActionRow(this.c, this.icon, this.title, this.tint, this.onTap);
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: tint, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: c.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: c.sub, size: 22),
          ],
        ),
      ),
    ),
  );
}

class _DangerRow extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _DangerRow(this.c, this.icon, this.title, this.onTap);
  @override
  Widget build(BuildContext context) => Material(
    color: c.warn.withValues(alpha: 0.06),
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Icon(icon, color: c.warn, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: c.warn,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AccentPicker extends StatelessWidget {
  final AppColors c;
  final int index;
  final ValueChanged<int> on;
  const _AccentPicker(this.c, this.index, this.on);

  @override
  Widget build(BuildContext context) {
    const perRow = 5;
    final rows = <Widget>[];
    for (var start = 0; start < accents.length; start += perRow) {
      final end = (start + perRow) > accents.length
          ? accents.length
          : start + perRow;
      final dots = <Widget>[
        for (var i = start; i < end; i++) Expanded(child: _dot(i)),
      ];
      for (var i = end; i < start + perRow; i++) {
        dots.add(const Expanded(child: SizedBox.shrink()));
      }
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 12));
      rows.add(Row(children: dots));
    }
    return Column(children: rows);
  }

  Widget _dot(int i) => GestureDetector(
    onTap: () => on(i),
    child: Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accents[i].dAccent,
          border: Border.all(
            color: index == i ? c.text : Colors.transparent,
            width: 2,
          ),
          boxShadow: index == i
              ? [
                  BoxShadow(
                    color: accents[i].dAccent.withValues(alpha: 0.5),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: index == i
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : null,
      ),
    ),
  );
}

class _DataCounter extends StatelessWidget {
  final AppColors c;
  final int history;
  final int fav;
  const _DataCounter(this.c, this.history, this.fav);

  @override
  Widget build(BuildContext context) {
    final l10n = context.settings.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.accent.withValues(alpha: 0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.accent.withValues(alpha: 0.14), c.bgSoft],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _stat(Icons.history_rounded, '$history', l10n.t('history')),
          ),
          Container(width: 1, height: 32, color: c.line),
          Expanded(
            child: _stat(Icons.star_rounded, '$fav', l10n.t('favorites')),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData ic, String num, String label) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ic, color: c.accent, size: 18),
          const SizedBox(width: 6),
          Text(num, style: AppTheme.display(size: 20, color: c.text)),
        ],
      ),
      const SizedBox(height: 2),
      Text(label, style: AppTheme.label(color: c.faint, size: 9)),
    ],
  );
}

class ClipboardSwitchRow extends StatefulWidget {
  const ClipboardSwitchRow({super.key});
  @override
  State<ClipboardSwitchRow> createState() => _ClipboardSwitchRowState();
}

class _ClipboardSwitchRowState extends State<ClipboardSwitchRow> {
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
  };

  String get _desc => switch (context.settings.lang) {
    AppLang.ru =>
      'Копируй текст в любом приложении — Köpri покажет перевод поверх экрана',
    AppLang.en => 'Copy text in any app — Köpri shows the translation on top',
    AppLang.tk =>
      'Islendik programmada tekst göçür — Köpri terjimäni ekranyň üstünde görkezer',
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
                }),
                backgroundColor: context.c.warn,
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
    return _SwitchRow(
      context.c,
      Icons.content_paste_rounded,
      _title,
      _desc,
      _on,
      _toggle,
    );
  }
}
