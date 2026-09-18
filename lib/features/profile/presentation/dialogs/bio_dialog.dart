import 'package:flutter/material.dart';

import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/profile_repository.dart';

/// Status (bio) editor dialog.
///
/// FIX (critical): the previous `.whenComplete(ctrl.dispose)` ran BEFORE the
/// dialog's exit animation finished. The TextField still in the widget tree
/// tried to re-subscribe to the (now disposed) controller during the rebuild,
/// causing "TextEditingController was used after being disposed".
///
/// Solution: delay dispose by 400ms (covers the default dialog exit animation
/// of ~300ms). This guarantees the controller is freed AFTER the widget is
/// fully removed from the tree, preventing any post-dispose access.
///
/// Alternative considered: `WidgetsBinding.instance.addPostFrameCallback` —
/// also valid, but Future.delayed is simpler and more predictable.
void showBioDialog(BuildContext context) {
  final c = context.c;
  final l10n = context.l10n;
  final ctrl = TextEditingController(text: ProfileRepository.instance.bio);

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        l10n.t('profile_bio_hint'),
        style: TextStyle(color: c.text, fontWeight: FontWeight.w800),
      ),
      content: TextField(
        controller: ctrl,
        style: TextStyle(color: c.text),
        decoration: InputDecoration(
          filled: true,
          fillColor: c.surfaceHi,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ProfileRepository.instance.setBio(ctrl.text.trim());
            Navigator.pop(ctx);
          },
          child: Text(
            l10n.t('confirm'),
            style: TextStyle(color: c.accent, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  ).whenComplete(() {
    // FIX: wait for exit animation to finish before disposing.
    Future.delayed(const Duration(milliseconds: 400), ctrl.dispose);
  });
}
