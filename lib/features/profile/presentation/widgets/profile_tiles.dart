import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Small uppercase section caption (e.g. "ACTIVITY", "ACHIEVEMENTS").
class ProfileSectionLabel extends StatelessWidget {
  final String text;
  final AppColors c;
  const ProfileSectionLabel({super.key, required this.text, required this.c});

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTheme.label(color: c.accent, size: 11));
}

/// Animated counter card used in the 2×2 activity grid.
class ProfileStatCard extends StatelessWidget {
  final AppColors c;
  final String label;
  final int value;
  const ProfileStatCard({
    super.key,
    required this.c,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text(
              v.round().toString(),
              style: AppTheme.display(size: 26, color: c.accent),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.label(color: c.sub, size: 10)),
        ],
      ),
    );
  }
}

/// Chevron row for quick actions (export / share / feedback / clear).
class ProfileActionTile extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool warn;
  const ProfileActionTile({
    super.key,
    required this.c,
    required this.icon,
    required this.label,
    required this.onTap,
    this.warn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.line),
          ),
          child: Row(
            children: [
              Icon(icon, color: warn ? c.warn : c.accent, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: warn ? c.warn : c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.sub, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Flat row tile used inside modal sheets (avatar picker).
class ProfilePickerTile extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool warn;
  const ProfilePickerTile({
    super.key,
    required this.c,
    required this.icon,
    required this.label,
    required this.onTap,
    this.warn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: c.surfaceHi,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: warn ? c.warn : c.accent, size: 24),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: warn ? c.warn : c.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
