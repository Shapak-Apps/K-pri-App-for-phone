import 'package:flutter/material.dart';

import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../translate/data/languages.dart';
import '../../../translate/data/offline_translator.dart';
import '../settings_actions.dart';
import '../widgets/settings_tiles.dart';

/// Section listing downloaded offline translation models with
/// per-model and bulk deletion.
class OfflineModelsSection extends StatefulWidget {
  const OfflineModelsSection({super.key});
  @override
  State<OfflineModelsSection> createState() => _OfflineModelsSectionState();
}

class _OfflineModelsSectionState extends State<OfflineModelsSection>
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
    showSettingsSnack(
      context,
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
      showSettingsSnack(
        context,
        context.settings.l10n.t('offline_models_none'),
        warn: true,
      );
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
    showSettingsSnack(context, msg, warn: warn);
  }

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

    return GlassSection(
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
