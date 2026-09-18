import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import 'camera_constants.dart';
import 'real_camera_page.dart';
import '../widgets/coming_soon_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Localized copy for the "coming soon" bottom sheet.
// ─────────────────────────────────────────────────────────────────────────────

String _sheetTitle(String lang) => switch (lang) {
  'ru' => 'Скоро в v$kCameraComingSoonVersion',
  'en' => 'Coming Soon in v$kCameraComingSoonVersion',
  'tk' => 'v$kCameraComingSoonVersion-de ýakyn wagtda',
  'tr' => 'v$kCameraComingSoonVersion\'de Yakında',
  _ => 'Coming Soon in v$kCameraComingSoonVersion',
};

String _sheetMessage(String lang) => switch (lang) {
  'ru' =>
    'Функция перевода через камеру находится в активной разработке и будет доступна в следующем крупном обновлении.',
  'en' =>
    'Camera translation is under active development and will be available in the next major update.',
  'tk' =>
    'Kamera terjime funksiýasy işjeň işlenip düzülýär we indiki uly täzelenişde elýeterli bolar.',
  'tr' =>
    'Kamera çeviri özelliği aktif olarak geliştirilmektedir ve bir sonraki büyük güncellemede kullanılabilir olacak.',
  _ =>
    'Camera translation is under active development and will be available in the next major update.',
};

String _sheetHint(String lang) => switch (lang) {
  'ru' => 'Следите за обновлениями!',
  'en' => 'Stay tuned for updates!',
  'tk' => 'Täzelenmelere garaşyň!',
  'tr' => 'Güncellemeleri takip edin!',
  _ => 'Stay tuned for updates!',
};

/// Shows the "feature is under development" modal bottom sheet.
///
/// Safe to call from any context (including async gaps): the function
/// bails out early when the context is no longer mounted.
void showComingSoonAnywhere(BuildContext context) {
  if (!context.mounted) return;
  final c = context.c;
  final lang = context.settings.lang.name;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.accent.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    c.accent.withValues(alpha: 0.2),
                    c.accent.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Icon(
                Icons.rocket_launch_rounded,
                color: c.accent,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _sheetTitle(lang),
              style: TextStyle(
                color: c.text,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _sheetMessage(lang),
              style: TextStyle(color: c.sub, height: 1.5, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: c.accent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _sheetHint(lang),
                      style: TextStyle(
                        color: c.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Requests the camera permission and pushes either the real camera page
/// or the "coming soon" placeholder, depending on [kCameraEnabled].
///
/// When [isProfileMode] is `true`, the camera page returns the captured
/// image path instead of running the OCR pipeline.
Future<void> pushCameraOrSoon(
  BuildContext context, {
  bool isProfileMode = false,
}) async {
  if (!kCameraEnabled) {
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const CameraComingSoonPage(),
      ),
    );
    return;
  }
  final status = await Permission.camera.request();
  if (!status.isGranted) return;
  if (!context.mounted) return;
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => RealCameraPage(isProfileMode: isProfileMode),
    ),
  );
}
