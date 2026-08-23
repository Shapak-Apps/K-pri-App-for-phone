import 'package:flutter/material.dart';

class GitHubIcon extends StatelessWidget {
  final double size;
  final Color color;
  const GitHubIcon({required this.size, required this.color});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _GitHubPainter(color, size));
}

class _GitHubPainter extends CustomPainter {
  final Color color;
  final double size;
  _GitHubPainter(this.color, this.size);

  static final Path _path = _parseSvg(
    'M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.012 8.012 0 0 0 16 8c0-4.42-3.58-8-8-8z',
  );

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.scale(size / 16.0);
    canvas.drawPath(
      _path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GitHubPainter old) => old.color != color;
}

Path _parseSvg(String d) {
  final tokens = RegExp(
    r'[MmCcAaZzLl]|[-+]?(?:\d+\.\d+|\.\d+|\d+)',
  ).allMatches(d).map((m) => m.group(0)!).toList();
  final path = Path();
  var i = 0;
  double cx = 0, cy = 0, sx = 0, sy = 0;
  var cmd = '';
  double n() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    final t = tokens[i];
    if (RegExp(r'[A-Za-z]').hasMatch(t)) {
      cmd = t;
      i++;
      if (cmd == 'Z' || cmd == 'z') {
        path.close();
        cx = sx;
        cy = sy;
        cmd = '';
      }
      continue;
    }
    switch (cmd) {
      case 'M':
        cx = n();
        cy = n();
        path.moveTo(cx, cy);
        sx = cx;
        sy = cy;
        cmd = 'L';
      case 'L':
        cx = n();
        cy = n();
        path.lineTo(cx, cy);
      case 'C':
        final x1 = n(), y1 = n(), x2 = n(), y2 = n();
        cx = n();
        cy = n();
        path.cubicTo(x1, y1, x2, y2, cx, cy);
      case 'c':
        final x1 = n(), y1 = n(), x2 = n(), y2 = n(), dx = n(), dy = n();
        path.cubicTo(cx + x1, cy + y1, cx + x2, cy + y2, cx + dx, cy + dy);
        cx += dx;
        cy += dy;
      case 'A':
        final rx = n(), ry = n(), rot = n(), la = n(), sf = n();
        final x = n(), y = n();
        path.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rot,
          largeArc: la == 1,
          clockwise: sf == 1,
        );
        cx = x;
        cy = y;
      default:
        i++;
    }
  }
  return path;
}

class BeatingHeart extends StatelessWidget {
  final Color color;
  final Animation<double> animation;
  const BeatingHeart({required this.color, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final t = animation.value;
        double beat;
        if (t < 0.18) {
          beat = Curves.easeOut.transform(t / 0.18);
        } else if (t < 0.36) {
          beat = 1 - Curves.easeIn.transform((t - 0.18) / 0.18);
        } else if (t < 0.54) {
          beat = 0.65 * Curves.easeOut.transform((t - 0.36) / 0.18);
        } else if (t < 0.72) {
          beat = 0.65 * (1 - Curves.easeIn.transform((t - 0.54) / 0.18));
        } else {
          beat = 0.0;
        }
        return Transform.scale(
          scale: 1.0 + 0.30 * beat,
          child: Icon(
            Icons.favorite_rounded,
            color: color,
            size: 18,
            shadows: [
              Shadow(
                color: color.withValues(alpha: 0.2 + 0.6 * beat),
                blurRadius: 8,
              ),
            ],
          ),
        );
      },
    );
  }
}

class SoonBadge extends StatelessWidget {
  final Color color;
  final String text;
  const SoonBadge({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
