import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
// FIX: reuse the shared aspect-correct preview instead of a local copy.
import '../../../camera/widgets/cover_preview.dart';

/// Full-screen front-camera capture used by the profile avatar picker.
/// Returns the captured image path via `Navigator.pop(context, path)`,
/// or `null` when the user backs out.
class AvatarCameraScreen extends StatefulWidget {
  const AvatarCameraScreen({super.key});
  @override
  State<AvatarCameraScreen> createState() => _AvatarCameraScreenState();
}

class _AvatarCameraScreenState extends State<AvatarCameraScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;
  bool _takingPicture = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initFuture = _initCamera();
  }

  @override
  void dispose() {
    // Release the native camera session before tearing down the UI.
    _controller?.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  /// Enumerates cameras and initializes the front one (fallback: first).
  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (!mounted) return;

    // FIX: guard against devices/emulators with no camera at all.
    // Previously `orElse: () => cameras.first` threw a raw StateError
    // ("No element") on an empty list.
    if (cameras.isEmpty) throw Exception('no cameras available');

    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    final ctrl = CameraController(
      front,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await ctrl.initialize();
    } catch (e) {
      // Initialization failed: free the half-created session and surface
      // the error to the FutureBuilder error UI.
      await ctrl.dispose();
      if (mounted) rethrow;
      return;
    }

    // The page was closed while the camera was starting: free the session.
    if (!mounted) {
      await ctrl.dispose();
      return;
    }

    _controller = ctrl;
    setState(() {});
  }

  /// Captures a frame and pops with the temporary image path.
  Future<void> _takePicture() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized || _takingPicture) return;

    setState(() => _takingPicture = true);
    try {
      final image = await ctrl.takePicture();
      if (mounted) Navigator.pop(context, image.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_errorLabel(context.settings.lang.name)}: $e'),
          backgroundColor: context.c.warn,
        ),
      );
      setState(() => _takingPicture = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Localized copy (inline switches follow the codebase style used in
  // the camera module; no new l10n keys required).
  // ─────────────────────────────────────────────────────────────────

  String _hintLabel(String lang) => switch (lang) {
    'ru' => 'Поместите лицо в круг',
    'en' => 'Fit your face in the circle',
    'tk' => 'Ýüzüňizi tegelegiň içine ýerleşdiriň',
    'tr' => 'Yüzünüzü çemberin içine yerleştirin',
    _ => 'Fit your face in the circle',
  };

  String _errorTitle(String lang) => switch (lang) {
    'ru' => 'Ошибка камеры',
    'en' => 'Camera error',
    'tk' => 'Kamera ýalňyşlygy',
    'tr' => 'Kamera hatası',
    _ => 'Camera error',
  };

  String _errorLabel(String lang) => switch (lang) {
    'ru' => 'Ошибка',
    'en' => 'Error',
    'tk' => 'Ýalňyşlyk',
    'tr' => 'Hata',
    _ => 'Error',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final lang = context.settings.lang.name;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: c.warn, size: 64),
                  const SizedBox(height: 16),
                  Text(_errorTitle(lang), style: TextStyle(color: c.text)),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: c.sub, fontSize: 12),
                  ),
                ],
              ),
            );
          }
          final ctrl = _controller;
          if (ctrl == null || !ctrl.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // Shared aspect-ratio-correct preview (single source of truth).
              Positioned.fill(child: CameraCoverPreview(controller: ctrl)),

              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _CircleGuidePainter(c.accent)),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 120,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 160,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 12,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _hintLabel(lang),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 30,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _takingPicture ? null : _takePicture,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: c.accent, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: c.accent,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),

              if (_takingPicture)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Dimmed overlay with a transparent circular window plus a neon ring:
/// guides the user to place their face inside the crop zone.
class _CircleGuidePainter extends CustomPainter {
  final Color ringColor;
  const _CircleGuidePainter(this.ringColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.38;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = ringColor
        ..strokeWidth = 3,
    );

    canvas.drawCircle(
      center,
      radius + 4,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = ringColor.withValues(alpha: 0.25)
        ..strokeWidth = 6,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleGuidePainter old) =>
      old.ringColor != ringColor;
}
