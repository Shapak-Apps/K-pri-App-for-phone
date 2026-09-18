import 'package:flutter/material.dart';

import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/profile_repository.dart';

/// Destructive-action confirmation: wipes name, avatar and status.
void showClearProfileDialog(BuildContext context) {
  final c = context.c;
  final l10n = context.l10n;
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        l10n.t('profile_clear'),
        style: TextStyle(color: c.text, fontWeight: FontWeight.w800),
      ),
      content: Text(
        l10n.t('profile_clear_msg'),
        style: TextStyle(color: c.sub),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await ProfileRepository.instance.clearAll();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.t('profile_cleared')),
                backgroundColor: c.warn,
              ),
            );
          },
          child: Text(
            l10n.t('confirm'),
            style: TextStyle(color: c.warn, fontWeight: FontWeight.w700),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.t('cancel'), style: TextStyle(color: c.sub)),
        ),
      ],
    ),
  );
}
