import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../translation_state.dart';

class ResultCard extends StatelessWidget {
  final TranslationState state;
  final VoidCallback? onSpeak;
  const ResultCard({super.key, required this.state, this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isErr = state is ErrorState;
    final text = switch (state) {
      SuccessState(:final text) => text,
      ErrorState(:final message) => message,
      _ => '',
    };
    final has = text.isNotEmpty;
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
          Row(
            children: [
              Icon(
                isErr ? Icons.error_outline_rounded : Icons.translate_rounded,
                size: 18,
                color: isErr ? c.warn : c.accent,
              ),
              const SizedBox(width: 8),
              Text(
                isErr ? 'ERROR' : 'TERJIME',
                style: AppTheme.label(color: isErr ? c.warn : c.accent),
              ),
              const Spacer(),
              if (has) ...[
                if (onSpeak != null && !isErr)
                  _btn(c, Icons.volume_up_rounded, onSpeak!),
                if (onSpeak != null && !isErr) const SizedBox(width: 6),
                _btn(
                  c,
                  Icons.copy_rounded,
                  () => Clipboard.setData(ClipboardData(text: text)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (!has)
            Text(
              'Terjime netijesi şu ýerde görner.',
              style: AppTheme.caption(color: c.faint),
            )
          else
            Text(
              text,
              style: TextStyle(
                color: isErr ? c.warn : c.text,
                fontSize: 17,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _btn(AppColors c, IconData i, VoidCallback t) => Material(
    color: c.surfaceHi,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: t,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(i, size: 18, color: c.sub),
      ),
    ),
  );
}
