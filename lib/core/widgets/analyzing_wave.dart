import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kopri/core/theme/app_colors.dart';

/// Полоса «Анализ»: тонкие аудио-бары + подпись.
/// Цвет = c.text по умолчанию (на dark — белая волна).
/// Размер через LayoutBuilder (реальная ширина родителя) → никаких
/// «огромных пятен». 60/120fps: AnimationController + CustomPainter,
/// перерисовывается только канвас (RepaintBoundary).
class AnalyzingWave extends StatefulWidget {
  final String label;
  final double height;
  final Color? color;
  const AnalyzingWave({
    super.key,
    required this.label,
    this.height = 40,
    this.color,
  });

  @override
  State<AnalyzingWave> createState() => _AnalyzingWaveState();
}

class _AnalyzingWaveState extends State<AnalyzingWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = widget.color ?? c.text;
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (ctx, cons) {
              final double w = cons.maxWidth.isFinite ? cons.maxWidth : 240;
              return SizedBox(
                width: w,
                height: widget.height,
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (_, __) => CustomPaint(
                    size: Size(w, widget.height),
                    painter: _WavePainter(t: _c.value, color: color),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double t;
  final Color color;
  _WavePainter({required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const bars = 24;
    const gap = 3.0;
    final bw = (size.width - gap * (bars - 1)) / bars;
    final mid = size.height / 2;
    final paint = Paint();
    for (var i = 0; i < bars; i++) {
      final phase = i * 0.55 + t * 2 * math.pi;
      final a1 = math.sin(phase) * 0.5 + 0.5;
      final a2 = math.sin(phase * 0.5 + 1.3) * 0.5 + 0.5;
      final h = 3 + (a1 * 0.7 + a2 * 0.3) * (size.height - 6);
      final x = i * (bw + gap);
      paint.color = color.withValues(alpha: 0.30 + 0.70 * a1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, mid - h / 2, bw, h),
          Radius.circular(bw / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.t != t;
}
