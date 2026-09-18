import 'package:flutter/material.dart';

import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';

/// Destructive-actions block: clear history / favorites / all / photos.
class DangerZone extends StatelessWidget {
  final AppColors c;
  final VoidCallback onClearHistory;
  final VoidCallback onClearFavorites;
  final VoidCallback onClearAll;
  final VoidCallback onClearPhotos;
  final bool showPhotosBadge;
  final String lang;
  const DangerZone({
    super.key,
    required this.c,
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

/// Small gradient "Soon" badge for features gated behind kCameraEnabled.
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
