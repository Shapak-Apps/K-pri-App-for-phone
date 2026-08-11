import 'package:flutter/material.dart';
import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/profile_repository.dart';

class PresetAvatarsScreen extends StatelessWidget {
  const PresetAvatarsScreen({super.key});

  // ← ИСПРАВЛЕНО: все эмодзи заполнены (без пустых строк)
  static const List<String> _emojis = [
    // Животные
    '🦊', '🐼', '🐯', '🦁', '🐺', '🦄', '🐨', '🐵',
    '🐰', '🦝', '🐻', '🐸', '🐳', '🦈', '🐙', '🦋',
    // Персонажи
    '🧑', '👩', '👨', '🧒', '👧', '👦', '🧙', '🧝',
    '🧛', '🧚', '🦸', '🦹', '🥷', '👨‍🚀', '👨‍💻', '👩‍🎨',
    // Лица и эмоции
    '😎', '🤩', '😇', '🤠', '🥸', '🤓', '🧐', '😺',
    '🤖', '👽', '👻', '💀', '🎃', '👹', '🤡', '🥳',
    // Символы и предметы
    '🚀', '🌟', '⚡', '🔥', '💎', '🎯', '🎧', '⚽',
    '🏀', '🎮', '🎨', '🎸', '📚', '🧠', '💡', '🏆',
    // Природа
    '🌸', '🌻', '🌹', '🌺', '🍀', '🌈', '⭐', '🌙',
    '☀️', '🌊', '🏔️', '🌲', '🍁', '🌴', '🌵', '🍃',
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;
    final current = ProfileRepository.instance.avatarEmoji;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        foregroundColor: c.text,
        title: Text(
          l10n.t('profile_emoji'),
          style: AppTheme.display(size: 18, color: c.text),
        ),
        actions: [
          if (current != null)
            IconButton(
              icon: Icon(Icons.clear_rounded, color: c.warn),
              tooltip: l10n.t('profile_remove_photo'),
              onPressed: () {
                ProfileRepository.instance.setAvatarEmoji(null);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Подсказка сверху ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.accent.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.touch_app_rounded, color: c.accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.t('profile_emoji_hint'),
                    style: TextStyle(color: c.sub, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          // ── Счётчик эмодзи ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.emoji_emotions_rounded, color: c.accent, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_emojis.length}',
                  style: AppTheme.display(size: 16, color: c.text),
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.t('profile_emoji_count'),
                  style: AppTheme.label(color: c.faint, size: 10),
                ),
              ],
            ),
          ),

          // ── Сетка эмодзи ──
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemCount: _emojis.length,
              itemBuilder: (context, i) {
                final e = _emojis[i];
                final selected = current == e;
                return GestureDetector(
                  onTap: () {
                    ProfileRepository.instance.setAvatarEmoji(e);
                    Navigator.pop(context);
                  },
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + i * 15),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, child) => Opacity(
                      opacity: v,
                      child: Transform.scale(
                        scale: 0.6 + 0.4 * v,
                        child: child,
                      ),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: selected
                            ? c.accent.withValues(alpha: 0.15)
                            : c.surfaceHi,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? c.accent : c.line,
                          width: selected ? 2 : 1,
                        ),
                        boxShadow: selected
                            ? [
                          BoxShadow(
                            color: c.accent.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            e,
                            style: TextStyle(
                              fontSize: selected ? 40 : 34,
                            ),
                          ),
                          if (selected)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: c.accent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 12,
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
    );
  }
}