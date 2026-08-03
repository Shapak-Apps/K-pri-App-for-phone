import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/languages.dart';
import 'mic_button.dart';

class InputCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final String? autoDetected;
  final VoidCallback onClear;
  final bool isListening;
  final VoidCallback onMicTap;
  const InputCard({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onMicTap,
    this.focusNode,
    this.onSubmitted,
    this.autoDetected,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 14, 0),
            child: Row(
              children: [
                Icon(Icons.edit_note_rounded, color: c.accent, size: 18),
                const SizedBox(width: 8),
                Text('GÖZBAŞY', style: AppTheme.label(color: c.accent)),
                const Spacer(),
                if (autoDetected != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: c.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'AWT · ${AppLanguages.nameOf(autoDetected!).toUpperCase()}',
                      style: AppTheme.label(color: c.accent, size: 9),
                    ),
                  ),
              ],
            ),
          ),
          TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: false,
            textInputAction: TextInputAction.done,
            onSubmitted: onSubmitted,
            maxLines: 7,
            minLines: 4,
            cursorColor: c.accent,
            style: TextStyle(fontSize: 17, height: 1.45, color: c.text),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              hintText: isListening
                  ? 'Diňleýäris…'
                  : 'Terjime etmeli tekstiňizi ýazyň…',
              hintStyle: TextStyle(color: c.faint),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, __) => Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 12, 12),
              child: Row(
                children: [
                  Text(
                    '${v.text.length}'.padLeft(3, '0'),
                    style: AppTheme.label(color: c.faint, size: 10),
                  ),
                  const Spacer(),
                  MicButton(isListening: isListening, onTap: onMicTap),
                  const SizedBox(width: 8),
                  _mini(c, Icons.content_paste_rounded, () async {
                    final d = await Clipboard.getData(Clipboard.kTextPlain);
                    if (d?.text != null) controller.text = d!.text!;
                  }),
                  const SizedBox(width: 6),
                  _mini(
                    c,
                    Icons.close_rounded,
                    onClear,
                    enabled: v.text.isNotEmpty,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mini(
    AppColors c,
    IconData i,
    VoidCallback t, {
    bool enabled = true,
  }) => Opacity(
    opacity: enabled ? 1 : .35,
    child: Material(
      color: c.surfaceHi,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled ? t : null,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(i, size: 18, color: c.sub),
        ),
      ),
    ),
  );
}
