import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// FIX: `Permission.camera.request()` is used both in pickProfilePhoto()
// and in _openCamera(); the import was missing after the file split.
import 'package:permission_handler/permission_handler.dart';

import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/camera_photo_model.dart';
import '../data/camera_repository.dart';
import 'camera_constants.dart';
import 'camera_routes.dart';
import 'real_camera_page.dart';
import '../widgets/bottom_stack.dart';
import '../widgets/coming_soon_badge.dart';
import '../widgets/coming_soon_page.dart';
import '../widgets/gallery_card.dart';
import '../widgets/profile_gallery_picker.dart';

// Backward-compatible re-exports: external modules (settings, shell, profile)
// import these symbols from `camera_screen.dart`, keep them resolvable here.
export 'camera_constants.dart' show kCameraEnabled, kCameraComingSoonVersion;
export 'camera_routes.dart' show showComingSoonAnywhere;

/// Entry widget of the camera tab: hero shutter button, "coming soon"
/// badge and the fanned stack of saved photos.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();

  /// Opens the translate-camera flow (or the coming-soon placeholder).
  static Future<void> openTranslateCamera(BuildContext context) =>
      pushCameraOrSoon(context);

  /// Bottom-sheet flow used by the profile module to obtain an avatar:
  /// either a fresh capture or a pick from the saved-photo gallery.
  /// Returns the selected image path, or `null` when cancelled.
  static Future<String?> pickProfilePhoto(BuildContext context) async {
    await CameraRepository.instance.ensureInit();
    final c = context.c;

    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (kCameraEnabled)
                ListTile(
                  leading: Icon(Icons.camera_alt_rounded, color: c.accent),
                  title: Text(
                    'Сделать снимок',
                    style: TextStyle(
                      color: c.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => Navigator.pop(ctx, 'camera'),
                ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: c.accent),
                title: Text(
                  'Выбрать из галереи',
                  style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !context.mounted) return null;

    if (source == 'camera' && kCameraEnabled) {
      final status = await Permission.camera.request();
      if (!status.isGranted) return null;
      if (!context.mounted) return null;
      return await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(
          fullscreenDialog: true,
          builder: (_) => const RealCameraPage(isProfileMode: true),
        ),
      );
    } else if (source == 'gallery') {
      if (!context.mounted) return null;
      return await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(builder: (_) => const ProfileGalleryPicker()),
      );
    }
    return null;
  }
}

class _CameraScreenState extends State<CameraScreen> {
  void _snack(String t, {bool warn = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t),
        backgroundColor: warn ? context.c.warn : context.c.accent,
      ),
    );
  }

  /// Opens the real camera, or the coming-soon page when the feature
  /// flag is off. Shows a snackbar when the permission is denied.
  Future<void> _openCamera() async {
    if (!kCameraEnabled) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => const CameraComingSoonPage(),
        ),
      );
      return;
    }
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _snack(context.l10n.t('camera_permission'), warn: true);
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const RealCameraPage(),
      ),
    );
  }

  /// Modal gallery dialog with the saved-photo grid.
  Future<void> _openGallery() async {
    final c = context.c;
    final l10n = context.l10n;
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      barrierLabel: 'gallery',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, __) {
        return ListenableBuilder(
          listenable: CameraRepository.instance,
          builder: (context, _) {
            final all = CameraRepository.instance.getAll();
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: FractionallySizedBox(
                    heightFactor: 0.86,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: c.line),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  10,
                                  10,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.photo_library_rounded,
                                      color: c.accent,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        l10n.t('camera_gallery'),
                                        style: TextStyle(
                                          color: c.text,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      icon: Icon(
                                        Icons.close_rounded,
                                        color: c.sub,
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: all.isEmpty
                                    ? Center(
                                        child: Text(
                                          l10n.t('camera_empty'),
                                          style: AppTheme.caption(
                                            color: c.faint,
                                          ),
                                        ),
                                      )
                                    : GridView.builder(
                                        padding: const EdgeInsets.all(12),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 12,
                                              crossAxisSpacing: 12,
                                              childAspectRatio: 0.78,
                                            ),
                                        itemCount: all.length,
                                        itemBuilder: (_, i) =>
                                            CameraGalleryCard(
                                              photo: all[i],
                                              onTap: () => _viewPhoto(all[i]),
                                            ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Full-screen dialog with the photo, its OCR text and translations.
  Future<void> _viewPhoto(CameraPhoto p) async {
    final c = context.c;
    final l10n = context.l10n;

    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 36,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.86,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 180,
                      child: Image.file(
                        File(p.path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => SizedBox(
                          height: 180,
                          child: Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: c.faint,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (p.originalText.isNotEmpty)
                              _textSection(
                                c: c,
                                label: l10n.t('camera_original'),
                                text: p.originalText,
                              ),
                            for (final e in p.translations.entries) ...[
                              const SizedBox(height: 14),
                              _textSection(
                                c: c,
                                label:
                                    '${l10n.t('camera_translation')} · ${e.key.toUpperCase()}',
                                text: e.value,
                              ),
                            ],
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: c.line)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await CameraRepository.instance.delete(p.id);
                              _snack(l10n.t('camera_deleted'));
                            },
                            child: Text(
                              l10n.t('clear'),
                              style: TextStyle(
                                color: c.warn,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              l10n.t('cancel'),
                              style: TextStyle(
                                color: c.sub,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Label + copy-to-clipboard block used inside the photo dialog.
  Widget _textSection({
    required AppColors c,
    required String label,
    required String text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTheme.label(color: c.accent, size: 10),
              ),
            ),
            GestureDetector(
              onTap: () => Clipboard.setData(ClipboardData(text: text)),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.copy_rounded, color: c.faint, size: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(text, style: TextStyle(color: c.text, height: 1.45)),
      ],
    );
  }

  String _soonBadgeText(String lang) => switch (lang) {
    'ru' => 'Скоро',
    'en' => 'Soon',
    'tk' => 'Ýakynda',
    'tr' => 'Yakında',
    _ => 'Soon',
  };

  String _soonVersionText(String lang) => switch (lang) {
    'ru' => 'v$kCameraComingSoonVersion',
    'en' => 'v$kCameraComingSoonVersion',
    'tk' => 'v$kCameraComingSoonVersion',
    'tr' => 'v$kCameraComingSoonVersion',
    _ => 'v$kCameraComingSoonVersion',
  };

  String _soonSubtitle(String lang) => switch (lang) {
    'ru' => 'в разработке',
    'en' => 'in development',
    'tk' => 'işlenip düzülýär',
    'tr' => 'geliştiriliyor',
    _ => 'in development',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;
    final lang = context.settings.lang.name;

    return ListenableBuilder(
      listenable: CameraRepository.instance,
      builder: (context, _) {
        final all = CameraRepository.instance.getAll();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: c.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.document_scanner_rounded,
                          color: c.accent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.t('camera_title'),
                              style: AppTheme.display(size: 19, color: c.text),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              l10n.t('camera_subtitle'),
                              style: AppTheme.caption(color: c.faint, size: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: _openCamera,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 116,
                            height: 116,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: c.accent.withValues(alpha: 0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: c.accent,
                              size: 52,
                            ),
                          ),
                        ),
                        if (!kCameraEnabled)
                          Positioned(
                            top: -8,
                            right: -12,
                            child: ComingSoonBadge(
                              mainText: _soonBadgeText(lang),
                              versionText: _soonVersionText(lang),
                              subtitleText: _soonSubtitle(lang),
                              c: c,
                              onTap: _openCamera,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      l10n.t('camera_open'),
                      style: TextStyle(
                        color: c.sub,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CameraBottomStack(
              c: c,
              all: all,
              emptyLabel: l10n.t('camera_empty'),
              galleryLabel: l10n.t('camera_gallery'),
              onTap: all.isEmpty ? null : _openGallery,
            ),
          ],
        );
      },
    );
  }
}
