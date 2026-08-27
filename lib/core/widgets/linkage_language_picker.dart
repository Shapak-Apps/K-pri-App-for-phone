import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/app_settings_controller.dart';
import '../data/language_linkage_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class LinkageLanguagePicker {
  static Future<String?> show(
    BuildContext context, {
    required String currentCode,
    bool includeAuto = false,
  }) async {
    final c = context.c;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final data = buildLanguageLinkageData(includeAuto: includeAuto);
    final regions = data.map((m) => m.keys.first).toList();
    final indices = languageIndicesFor(currentCode, includeAuto: includeAuto);

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => _PickerSheet(
        c: c,
        l10n: l10n,
        isDark: isDark,
        data: data,
        regions: regions,
        initialRegion: indices[0],
        initialLang: indices[1],
      ),
    );
  }
}

class _PickerSheet extends StatefulWidget {
  final AppColors c;
  final dynamic l10n;
  final bool isDark;
  final List<Map<String, List<String>>> data;
  final List<String> regions;
  final int initialRegion;
  final int initialLang;

  const _PickerSheet({
    required this.c,
    required this.l10n,
    required this.isDark,
    required this.data,
    required this.regions,
    required this.initialRegion,
    required this.initialLang,
  });

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  late int _region = widget.initialRegion;
  late int _lang = widget.initialLang;

  List<String> get _langs => widget.data[_region].values.first;

  void _confirm() {
    final code = extractLangCodeFromText(_langs[_lang]);
    if (code != null) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context, code);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final l10n = widget.l10n;
    final isDark = widget.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0F1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 10),
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.t('language'),
                        style: AppTheme.display(size: 18, color: c.text)
                            .copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.t('cancel'),
                        style: TextStyle(
                          color: c.sub,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _confirm,
                      child: Text(
                        l10n.t('confirm'),
                        style: TextStyle(
                          color: c.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              SizedBox(
                height: 220,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: _region.clamp(
                            0,
                            widget.regions.length - 1,
                          ),
                        ),
                        itemExtent: 42,
                        onSelectedItemChanged: (i) {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _region = i;
                            _lang = 0;
                          });
                        },
                        selectionOverlay:
                            CupertinoPickerDefaultSelectionOverlay(
                              background: c.accent.withValues(alpha: 0.12),
                            ),
                        children: [
                          for (final r in widget.regions)
                            Center(
                              child: Text(
                                r,
                                style: TextStyle(
                                  color: c.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 180,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                    ),

                    Expanded(
                      flex: 1,
                      child: CupertinoPicker(
                        key: ValueKey(_region),
                        scrollController: FixedExtentScrollController(
                          initialItem: _lang.clamp(0, _langs.length - 1),
                        ),
                        itemExtent: 42,
                        onSelectedItemChanged: (i) {
                          HapticFeedback.lightImpact();
                          setState(() => _lang = i);
                        },
                        selectionOverlay:
                            CupertinoPickerDefaultSelectionOverlay(
                              background: c.accent.withValues(alpha: 0.12),
                            ),
                        children: [
                          for (final lang in _langs)
                            Center(
                              child: Text(
                                lang,
                                style: TextStyle(
                                  color: c.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
