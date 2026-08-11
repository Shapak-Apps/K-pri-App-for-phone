import 'package:flutter/material.dart';
import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';

class QuickSettings extends StatelessWidget {
  const QuickSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final settings = context.settings;

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
          Text(
            'Быстрые настройки',
            style: TextStyle(
              color: c.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Тема
          Row(
            children: [
              Icon(Icons.palette_rounded, color: c.accent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Тема',
                  style: TextStyle(color: c.text, fontSize: 14),
                ),
              ),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 16)),
                  ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 16)),
                  ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_brightness, size: 16)),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (value) => settings.setTheme(value.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Автоперевод
          Row(
            children: [
              Icon(Icons.translate_rounded, color: c.accent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Автоперевод',
                      style: TextStyle(color: c.text, fontSize: 14),
                    ),
                    Text(
                      'Переводить при вводе',
                      style: TextStyle(color: c.faint, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.autoTranslate,
                onChanged: settings.setAutoTranslate,
                activeColor: c.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}