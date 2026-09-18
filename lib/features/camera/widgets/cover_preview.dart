import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Renders [CameraPreview] scaled to cover the available box while
/// preserving the sensor aspect ratio (center-crop behaviour).
class CameraCoverPreview extends StatelessWidget {
  final CameraController controller;
  const CameraCoverPreview({required this.controller});

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
