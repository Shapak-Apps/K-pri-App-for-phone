// ─────────────────────────────────────────────────────────────────────────────
// GITHUB LOGO (vector, drawn with CustomPaint)
//
// Reusable GitHub octocat-mark glyph rendered as a filled Path so it can be
// tinted with any color and scaled to any size without an image asset.
// Extracted from about_screen.dart so the update dialog can reuse the same
// artwork on its "Download APK from GitHub" button.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class GithubLogo extends StatelessWidget {
  final double size;
  final Color color;

  const GithubLogo({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GithubPainter(color: color),
    );
  }
}

class _GithubPainter extends CustomPainter {
  final Color color;
  _GithubPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    final s = size.width / 24.0;
    path.moveTo(12 * s, 0 * s);
    path.cubicTo(5.37 * s, 0 * s, 0 * s, 5.37 * s, 0 * s, 12 * s);
    path.cubicTo(
      0 * s,
      17.31 * s,
      3.435 * s,
      21.795 * s,
      8.205 * s,
      23.385 * s,
    );
    path.cubicTo(
      8.805 * s,
      23.49 * s,
      9.03 * s,
      23.13 * s,
      9.03 * s,
      22.815 * s,
    );
    path.cubicTo(
      9.03 * s,
      22.53 * s,
      9.015 * s,
      21.585 * s,
      9.015 * s,
      20.58 * s,
    );
    path.cubicTo(6 * s, 21.135 * s, 5.22 * s, 19.845 * s, 4.98 * s, 19.17 * s);
    path.cubicTo(
      4.845 * s,
      18.82 * s,
      4.26 * s,
      17.76 * s,
      3.75 * s,
      17.475 * s,
    );
    path.cubicTo(
      3.33 * s,
      17.25 * s,
      2.73 * s,
      16.695 * s,
      3.735 * s,
      16.68 * s,
    );
    path.cubicTo(
      4.68 * s,
      16.665 * s,
      5.355 * s,
      17.55 * s,
      5.58 * s,
      17.91 * s,
    );
    path.cubicTo(
      6.66 * s,
      19.725 * s,
      8.385 * s,
      19.215 * s,
      9.075 * s,
      18.9 * s,
    );
    path.cubicTo(
      9.18 * s,
      18.12 * s,
      9.495 * s,
      17.595 * s,
      9.84 * s,
      17.295 * s,
    );
    path.cubicTo(
      7.17 * s,
      16.995 * s,
      4.38 * s,
      15.96 * s,
      4.38 * s,
      11.37 * s,
    );
    path.cubicTo(
      4.38 * s,
      10.065 * s,
      4.845 * s,
      8.985 * s,
      5.61 * s,
      8.145 * s,
    );
    path.cubicTo(5.49 * s, 7.845 * s, 5.07 * s, 6.615 * s, 5.73 * s, 4.965 * s);
    path.cubicTo(5.73 * s, 4.965 * s, 6.735 * s, 4.65 * s, 9.03 * s, 6.18 * s);
    path.cubicTo(
      9.99 * s,
      5.91 * s,
      11.01 * s,
      5.775 * s,
      12.03 * s,
      5.775 * s,
    );
    path.cubicTo(
      13.05 * s,
      5.775 * s,
      14.07 * s,
      5.91 * s,
      15.03 * s,
      6.18 * s,
    );
    path.cubicTo(
      17.325 * s,
      4.62 * s,
      18.33 * s,
      4.965 * s,
      18.33 * s,
      4.965 * s,
    );
    path.cubicTo(
      18.99 * s,
      6.615 * s,
      18.57 * s,
      7.845 * s,
      18.45 * s,
      8.145 * s,
    );
    path.cubicTo(
      19.215 * s,
      8.985 * s,
      19.68 * s,
      10.05 * s,
      19.68 * s,
      11.37 * s,
    );
    path.cubicTo(
      19.68 * s,
      15.975 * s,
      16.875 * s,
      16.995 * s,
      14.205 * s,
      17.295 * s,
    );
    path.cubicTo(
      14.64 * s,
      17.67 * s,
      15.015 * s,
      18.39 * s,
      15.015 * s,
      19.515 * s,
    );
    path.cubicTo(15.015 * s, 21.12 * s, 15 * s, 22.41 * s, 15 * s, 22.815 * s);
    path.cubicTo(
      15 * s,
      23.13 * s,
      15.225 * s,
      23.505 * s,
      15.825 * s,
      23.385 * s,
    );
    path.cubicTo(20.565 * s, 21.795 * s, 24 * s, 17.31 * s, 24 * s, 12 * s);
    path.cubicTo(24 * s, 5.37 * s, 18.63 * s, 0 * s, 12 * s, 0 * s);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
