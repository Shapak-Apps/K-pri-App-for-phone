import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/language_flags.dart';
import '../../data/languages.dart';
import '../../../../core/widgets/linkage_language_picker.dart';

class LanguageSelector extends StatefulWidget {
  final String from, to;
  final ValueChanged<String> onFromChanged, onToChanged;
  final VoidCallback onSwap;
  final bool canSwap;
  const LanguageSelector({
    super.key,
    required this.from,
    required this.to,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onSwap,
    this.canSwap = true,
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
    final picked = await LinkageLanguagePicker.show(
      context,
      currentCode: current,
      includeAuto: opts.containsKey('auto'),
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
            _Swap(c: c, turns: _turns, onTap: widget.canSwap ? _swap : null),
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
              Text(langFlagFor(code), style: const TextStyle(fontSize: 22)),
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

class _Swap extends StatelessWidget {
  final AppColors c;
  final double turns;
  final VoidCallback? onTap;
  const _Swap({required this.c, required this.turns, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
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
      ),
    );
  }
}