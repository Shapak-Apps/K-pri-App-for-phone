import 'package:flutter/material.dart';
import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/native/translate_ffi.dart';
import '../../data/languages.dart';

const _langToCountry = <String, String>{
  'az': 'AZ',
  'af': 'ZA',
  'sq': 'AL',
  'am': 'ET',
  'en': 'GB',
  'ar': 'SA',
  'hy': 'AM',
  'eu': 'ES',
  'be': 'BY',
  'bn': 'BD',
  'my': 'MM',
  'bg': 'BG',
  'bs': 'BA',
  'cy': 'GB',
  'hu': 'HU',
  'vi': 'VN',
  'gl': 'ES',
  'el': 'GR',
  'ka': 'GE',
  'gu': 'IN',
  'da': 'DK',
  'zu': 'ZA',
  'he': 'IL',
  'id': 'ID',
  'ga': 'IE',
  'is': 'IS',
  'es': 'ES',
  'it': 'IT',
  'yo': 'NG',
  'kk': 'KZ',
  'kn': 'IN',
  'ca': 'ES',
  'ky': 'KG',
  'zh': 'CN',
  'ko': 'KR',
  'km': 'KH',
  'lo': 'LA',
  'la': 'VA',
  'lv': 'LV',
  'lt': 'LT',
  'mk': 'MK',
  'ms': 'MY',
  'ml': 'IN',
  'mt': 'MT',
  'mr': 'IN',
  'mn': 'MN',
  'ne': 'NP',
  'nl': 'NL',
  'no': 'NO',
  'pa': 'IN',
  'fa': 'IR',
  'pl': 'PL',
  'pt': 'PT',
  'ro': 'RO',
  'ru': 'RU',
  'sr': 'RS',
  'si': 'LK',
  'sk': 'SK',
  'sl': 'SI',
  'sw': 'TZ',
  'tg': 'TJ',
  'th': 'TH',
  'ta': 'IN',
  'te': 'IN',
  'tr': 'TR',
  'tk': 'TM',
  'uz': 'UZ',
  'uk': 'UA',
  'ur': 'PK',
  'fi': 'FI',
  'fr': 'FR',
  'hi': 'IN',
  'hr': 'HR',
  'cs': 'CZ',
  'sv': 'SE',
  'et': 'EE',
  'ja': 'JP',
};

String _flagOf(String code) {
  if (code == 'auto') return '🌐';
  final cc = _langToCountry[code];
  if (cc == null || cc.length != 2) return '🏳️';

  try {
    final native = TranslateFFI().flag(cc);
    if (native != null && native.isNotEmpty) return native;
  } catch (_) {
  }

  const base = 0x1F1E6 - 0x41;
  return String.fromCharCode(base + cc.codeUnitAt(0)) +
      String.fromCharCode(base + cc.codeUnitAt(1));
}

class LanguageSelector extends StatefulWidget {
  final String from, to;
  final ValueChanged<String> onFromChanged, onToChanged;
  final VoidCallback onSwap;
  const LanguageSelector({
    super.key,
    required this.from,
    required this.to,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onSwap,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  double _turns = 0;

  void _swap() {
    setState(() => _turns += 0.5);
    widget.onSwap();
  }

  Future<void> _openPicker(
    BuildContext context,
    String current,
    Map<String, String> opts,
    ValueChanged<String> onPick,
  ) async {
    final picked = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      barrierLabel: 'lang-picker',
      transitionDuration: const Duration(milliseconds: 340),
      transitionBuilder: (ctx, anim, secondary, child) {
        final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeIn,
          ),
        );
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
      pageBuilder: (ctx, _, __) => _LangPicker(opts: opts, current: current),
    );
    if (picked != null && picked != current) onPick(picked);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.line),
        ),
        child: Row(
          children: [
            Expanded(
              child: _Pill(
                c: c,
                code: widget.from,
                hint: 'GÖZBAŞY',
                onTap: () => _openPicker(
                  context,
                  widget.from,
                  AppLanguages.sources,
                  widget.onFromChanged,
                ),
              ),
            ),
            _Swap(c: c, turns: _turns, onTap: _swap),
            Expanded(
              child: _Pill(
                c: c,
                code: widget.to,
                hint: 'TERJIME',
                onTap: () => _openPicker(
                  context,
                  widget.to,
                  AppLanguages.all,
                  widget.onToChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Пилюля-триггер: флаг + подпись + название языка.
class _Pill extends StatelessWidget {
  final AppColors c;
  final String code, hint;
  final VoidCallback onTap;
  const _Pill({
    required this.c,
    required this.code,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: c.surfaceHi,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.line),
          ),
          child: Row(
            children: [
              Text(_flagOf(code), style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(hint, style: AppTheme.label(color: c.faint, size: 9)),
                    const SizedBox(height: 2),
                    Text(
                      AppLanguages.nameOf(code),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: c.text,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.unfold_more_rounded, color: c.sub, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Кнопка смены направлений с поворотом.
class _Swap extends StatelessWidget {
  final AppColors c;
  final double turns;
  final VoidCallback onTap;
  const _Swap({required this.c, required this.turns, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: c.accent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: AnimatedRotation(
              turns: turns,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: Icon(Icons.swap_horiz_rounded, color: c.bg, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

/// Оверлей-пикер: поиск + список языков с флагами, «волновое» появление строк.
class _LangPicker extends StatefulWidget {
  final Map<String, String> opts;
  final String current;
  const _LangPicker({required this.opts, required this.current});

  @override
  State<_LangPicker> createState() => _LangPickerState();
}

class _LangPickerState extends State<_LangPicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;
    final q = _q.toLowerCase();
    final list = widget.opts.entries
        .where(
          (e) =>
              e.value.toLowerCase().contains(q) ||
              e.key.toLowerCase().contains(q),
        )
        .toList();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: FractionallySizedBox(
            heightFactor: 0.84,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: c.line),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 40,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    children: [
                      // ── заголовок + закрыть ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 18, 12, 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.language_rounded,
                              color: c.accent,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.t('language'),
                                style: TextStyle(
                                  color: c.text,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close_rounded,
                                color: c.sub,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── поиск ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
                        child: TextField(
                          style: TextStyle(color: c.text),
                          onChanged: (v) => setState(() => _q = v),
                          decoration: InputDecoration(
                            hintText: l10n.t('search'),
                            hintStyle: TextStyle(color: c.sub),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: c.sub,
                            ),
                            filled: true,
                            fillColor: c.bgSoft,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      // ── список ──
                      Expanded(
                        child: list.isEmpty
                            ? Center(
                                child: Text(
                                  '—',
                                  style: AppTheme.caption(color: c.faint),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                itemCount: list.length,
                                itemBuilder: (_, i) {
                                  final e = list[i];
                                  final selected = e.key == widget.current;
                                  return AnimatedBuilder(
                                    animation: _anim,
                                    builder: (_, __) {
                                      final start = (i * 0.018).clamp(
                                        0.0,
                                        0.55,
                                      );
                                      final local =
                                          ((_anim.value - start) / (1 - start))
                                              .clamp(0.0, 1.0);
                                      final eased = Curves.easeOutCubic
                                          .transform(local);
                                      return Opacity(
                                        opacity: eased,
                                        child: Transform.translate(
                                          offset: Offset(0, (1 - eased) * 14),
                                          child: _LangRow(
                                            c: c,
                                            code: e.key,
                                            name: e.value,
                                            selected: selected,
                                            onTap: () =>
                                                Navigator.pop(context, e.key),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Строка языка: флаг + название + код; выбранная подсвечена галочкой.
class _LangRow extends StatelessWidget {
  final AppColors c;
  final String code;
  final String name;
  final bool selected;
  final VoidCallback onTap;
  const _LangRow({
    required this.c,
    required this.code,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: selected ? c.accent.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? c.accent.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Text(_flagOf(code), style: const TextStyle(fontSize: 27)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: c.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        code.toUpperCase(),
                        style: AppTheme.label(color: c.faint, size: 9),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: c.accent, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<String?> showLanguagePicker(
  BuildContext context, {
  required Map<String, String> opts,
  required String current,
}) {
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    barrierLabel: 'lang-picker',
    transitionDuration: const Duration(milliseconds: 340),
    transitionBuilder: (ctx, anim, secondary, child) {
      final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        ),
      );
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
    pageBuilder: (ctx, _, __) => _LangPicker(opts: opts, current: current),
  );
}