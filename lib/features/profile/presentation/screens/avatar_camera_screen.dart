import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

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
    _controller?.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (!mounted) return;

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
      await ctrl.dispose();
      if (mounted) rethrow;
      return;
    }

    if (!mounted) {
      await ctrl.dispose();
      return;
    }

    _controller = ctrl;
    setState(() {});
  }

  Future<void> _takePicture() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized || _takingPicture) return;

    setState(() => _takingPicture = true);
    try {
      final image = await ctrl.takePicture();
      if (mounted) Navigator.pop(context, image.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: context.c.warn,
          ),
        );
        setState(() => _takingPicture = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
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
                  Text('Ошибка камеры', style: TextStyle(color: c.text)),
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
              Positioned.fill(child: _AvatarCoverPreview(controller: ctrl)),

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
                    child: const Text(
                      'Поместите лицо в круг',
                      style: TextStyle(color: Colors.white, fontSize: 14),
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

class _AvatarCoverPreview extends StatelessWidget {
  final CameraController controller;
  const _AvatarCoverPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final ps = controller.value.previewSize;
    final upright = (ps != null && ps.longestSide > 0)
        ? ps.shortestSide / ps.longestSide
        : 9 / 16;

    return LayoutBuilder(
      builder: (context, cons) {
        final w = cons.maxWidth;
        final h = cons.maxHeight;
        final screenAspect = w / h;

        double pw, ph;
        if (upright > screenAspect) {
          ph = h;
          pw = h * upright;
        } else {
          pw = w;
          ph = w / upright;
        }

        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            maxWidth: pw,
            maxHeight: ph,
            child: SizedBox(
              width: pw,
              height: ph,
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }
}

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
