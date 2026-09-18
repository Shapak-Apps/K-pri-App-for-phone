import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/profile_repository.dart';
import '../screens/avatar_camera_screen.dart';
import '../screens/preset_avatars_screen.dart';
import '../widgets/profile_tiles.dart';

/// Bottom sheet with avatar sources: gallery, native in-app camera,
/// emoji presets, or removal of the current avatar.
///
/// This is the single implementation used by [ProfileHeader]; the previous
/// duplicate copy that lived in profile_screen.dart was dead code.
Future<void> showAvatarPickerSheet(BuildContext context) async {
  final c = context.c;
  final l10n = context.l10n;
  final p = ProfileRepository.instance;
  final picker = ImagePicker();

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: c.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfilePickerTile(
              c: c,
              icon: Icons.photo_library_rounded,
              label: l10n.t('profile_gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final x = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 85,
                );
                if (x != null && context.mounted) {
                  await p.saveAvatarFromPath(x.path);
                }
              },
            ),
            const SizedBox(height: 8),
            ProfilePickerTile(
              c: c,
              icon: Icons.photo_camera_rounded,
              label: l10n.t('profile_camera'),
              onTap: () async {
                Navigator.pop(ctx);
                // Native in-app camera instead of the system one.
                final path = await Navigator.of(context).push<String>(
                  MaterialPageRoute(builder: (_) => const AvatarCameraScreen()),
                );
                if (path != null && context.mounted) {
                  await p.saveAvatarFromPath(path);
                }
              },
            ),
            const SizedBox(height: 8),
            ProfilePickerTile(
              c: c,
              icon: Icons.emoji_emotions_rounded,
              label: l10n.t('profile_emoji'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PresetAvatarsScreen(),
                  ),
                );
              },
            ),
            if (p.hasAvatar || p.avatarEmoji != null) ...[
              const SizedBox(height: 8),
              ProfilePickerTile(
                c: c,
                icon: Icons.delete_outline_rounded,
                label: l10n.t('profile_remove_photo'),
                warn: true,
                onTap: () async {
                  Navigator.pop(ctx);
                  await p.deleteAvatar();
                },
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
