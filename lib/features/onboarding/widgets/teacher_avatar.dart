import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Poses the teacher can take. The painter switches limbs/props per pose,
/// and idle animation (bob, blink, wave) runs continuously.
enum TeacherPose { wave, point, explain, fire, celebrate }

/// A friendly teacher character drawn 100% with Flutter CustomPainter.
/// No images, no assets — pure vector code.
class TeacherAvatar extends StatefulWidget {
  const TeacherAvatar({
    super.key,
    required this.pose,
    required this.accent,
    this.size = 200,
  });

  final TeacherPose pose;
  final Color accent;
  final double size;

  @override
  State<TeacherAvatar> createState() => _TeacherAvatarState();
}

class _TeacherAvatarState extends State<TeacherAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _TeacherPainter(
            t: _c.value,
            pose: widget.pose,
            accent: widget.accent,
          ),
        ),
      ),
    );
  }
}

class _TeacherPainter extends CustomPainter {
  _TeacherPainter({required this.t, required this.pose, required this.accent});

  final double t; // 0..1 loop
  final TeacherPose pose;
  final Color accent;

  static const _skin = Color(0xFFFFD9B8);
  static const _hair = Color(0xFF4A2F23);
  static const _dark = Color(0xFF2B2B33);
  static const _confetti = [
    Color(0xFFFB923C),
    Color(0xFF9B7BFF),
    Color(0xFF10B981),
    Color(0xFF38BDF8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 220;
    final cx = size.width / 2;
    final groundY = size.height * 0.94;
    final bob = math.sin(t * 2 * math.pi) * 3 * s;

    // ── shadow ────────────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, groundY),
        width: 120 * s,
        height: 16 * s,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    // ── legs + shoes ──────────────────────────────────────────────────────
    final legPaint = Paint()..color = _dark;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 18 * s, groundY - 30 * s, 13 * s, 30 * s),
        Radius.circular(6 * s),
      ),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 5 * s, groundY - 30 * s, 13 * s, 30 * s),
        Radius.circular(6 * s),
      ),
      legPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 14 * s, groundY - 2 * s),
        width: 26 * s,
        height: 10 * s,
      ),
      Paint()..color = _dark,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 14 * s, groundY - 2 * s),
        width: 26 * s,
        height: 10 * s,
      ),
      Paint()..color = _dark,
    );

    // ── body ─────────────────────────────────────────────────────────────
    final bodyTop = groundY - 96 * s + bob;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 34 * s, bodyTop, 68 * s, 70 * s),
        Radius.circular(20 * s),
      ),
      Paint()..color = accent,
    );
    // collar
    final collar = Path()
      ..moveTo(cx - 10 * s, bodyTop + 2 * s)
      ..lineTo(cx, bodyTop + 14 * s)
      ..lineTo(cx + 10 * s, bodyTop + 2 * s)
      ..close();
    canvas.drawPath(collar, Paint()..color = Colors.white);
    // buttons
    canvas.drawCircle(
      Offset(cx, bodyTop + 26 * s),
      2.5 * s,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
    canvas.drawCircle(
      Offset(cx, bodyTop + 40 * s),
      2.5 * s,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );

    // ── arms (pose-driven) ────────────────────────────────────────────────
    final shoulderL = Offset(cx - 30 * s, bodyTop + 12 * s);
    final shoulderR = Offset(cx + 30 * s, bodyTop + 12 * s);

    void arm(Offset shoulder, double angle, double len) {
      final hand =
          shoulder +
          Offset(math.cos(angle) * len * s, math.sin(angle) * len * s);
      canvas.drawLine(
        shoulder,
        hand,
        Paint()
          ..color = accent
          ..strokeWidth = 11 * s
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(hand, 7 * s, Paint()..color = _skin);
      // ignore: avoid_returning_null
      if (pose == TeacherPose.point && shoulder == shoulderR) {
        // pointer stick in the right hand
        final tip =
            hand + Offset(math.cos(angle) * 34 * s, math.sin(angle) * 34 * s);
        canvas.drawLine(
          hand,
          tip,
          Paint()
            ..color = _hair
            ..strokeWidth = 4 * s
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    switch (pose) {
      case TeacherPose.wave:
        arm(shoulderL, 2.5, 34);
        arm(shoulderR, -1.35 + math.sin(t * 4 * math.pi) * 0.22, 40);
      case TeacherPose.point:
        arm(shoulderL, 2.5, 34);
        arm(shoulderR, -0.25, 44);
      case TeacherPose.explain:
        arm(shoulderL, 2.5, 34);
        arm(shoulderR, -0.75, 40);
      case TeacherPose.fire:
        arm(shoulderL, -1.15, 34);
        arm(shoulderR, -1.95, 34);
      case TeacherPose.celebrate:
        arm(shoulderL, -2.45, 40);
        arm(shoulderR, -0.7, 40);
    }

    // ── head ──────────────────────────────────────────────────────────────
    final headC = Offset(cx, bodyTop - 30 * s);
    canvas.drawCircle(headC, 26 * s, Paint()..color = _skin);
    // hair (top half + side tufts)
    canvas.drawArc(
      Rect.fromCircle(center: headC, radius: 27 * s),
      math.pi,
      math.pi,
      true,
      Paint()..color = _hair,
    );
    canvas.drawCircle(
      headC + Offset(-25 * s, 2 * s),
      7 * s,
      Paint()..color = _hair,
    );
    canvas.drawCircle(
      headC + Offset(25 * s, 2 * s),
      7 * s,
      Paint()..color = _hair,
    );

    // glasses
    final glassPaint = Paint()
      ..color = _dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * s;
    canvas.drawCircle(headC + Offset(-10 * s, 4 * s), 8 * s, glassPaint);
    canvas.drawCircle(headC + Offset(10 * s, 4 * s), 8 * s, glassPaint);
    canvas.drawLine(
      headC + Offset(-2 * s, 4 * s),
      headC + Offset(2 * s, 4 * s),
      glassPaint,
    );

    // eyes with blink
    final phase = (t * 3) % 1.0;
    final blink = phase < 0.08 ? 0.15 : 1.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: headC + Offset(-10 * s, 4 * s),
        width: 6 * s,
        height: 6 * s * blink,
      ),
      Paint()..color = _dark,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: headC + Offset(10 * s, 4 * s),
        width: 6 * s,
        height: 6 * s * blink,
      ),
      Paint()..color = _dark,
    );

    // smile
    canvas.drawArc(
      Rect.fromLTWH(cx - 8 * s, headC.dy + 8 * s, 16 * s, 12 * s),
      0.15 * math.pi,
      0.7 * math.pi,
      false,
      Paint()
        ..color = _dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * s
        ..strokeCap = StrokeCap.round,
    );

    // cheeks
    canvas.drawCircle(
      headC + Offset(-17 * s, 10 * s),
      4 * s,
      Paint()..color = const Color(0xFFFF8FA3).withValues(alpha: 0.5),
    );
    canvas.drawCircle(
      headC + Offset(17 * s, 10 * s),
      4 * s,
      Paint()..color = const Color(0xFFFF8FA3).withValues(alpha: 0.5),
    );

    // ── props ─────────────────────────────────────────────────────────────
    if (pose == TeacherPose.explain) {
      // whiteboard on the right
      final board = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 52 * s, bodyTop - 30 * s, 60 * s, 46 * s),
        Radius.circular(8 * s),
      );
      canvas.drawRRect(board, Paint()..color = Colors.white);
      canvas.drawRRect(
        board,
        Paint()
          ..color = _dark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 * s,
      );
      for (var i = 0; i < 3; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              cx + 60 * s,
              bodyTop - 20 * s + i * 12 * s,
              (44 - i * 10) * s,
              4 * s,
            ),
            Radius.circular(2 * s),
          ),
          Paint()..color = accent.withValues(alpha: 0.8),
        );
      }
    }

    if (pose == TeacherPose.fire) {
      // flame between the hands
      final flick = math.sin(t * 6 * math.pi) * 2 * s;
      final fx = cx;
      final fy = bodyTop - 4 * s;
      final outer = Path()
        ..moveTo(fx, fy - 26 * s - flick)
        ..quadraticBezierTo(fx + 14 * s, fy - 10 * s, fx + 10 * s, fy + 4 * s)
        ..quadraticBezierTo(fx, fy + 12 * s, fx - 10 * s, fy + 4 * s)
        ..quadraticBezierTo(fx - 14 * s, fy - 10 * s, fx, fy - 26 * s - flick)
        ..close();
      canvas.drawPath(outer, Paint()..color = const Color(0xFFFB923C));
      final inner = Path()
        ..moveTo(fx, fy - 14 * s - flick * 0.6)
        ..quadraticBezierTo(fx + 7 * s, fy - 4 * s, fx + 5 * s, fy + 3 * s)
        ..quadraticBezierTo(fx, fy + 8 * s, fx - 5 * s, fy + 3 * s)
        ..quadraticBezierTo(
          fx - 7 * s,
          fy - 4 * s,
          fx,
          fy - 14 * s - flick * 0.6,
        )
        ..close();
      canvas.drawPath(inner, Paint()..color = const Color(0xFFFDE047));
    }

    if (pose == TeacherPose.celebrate) {
      // falling confetti
      for (var i = 0; i < 14; i++) {
        final dx = ((i * 53) % 180) - 90;
        final dy = (t * 140 + i * 29) % 150;
        final rot = (i + t * 4) * 1.3;
        canvas.save();
        canvas.translate(cx + dx * s, size.height * 0.06 + dy * s);
        canvas.rotate(rot);
        canvas.drawRect(
          Rect.fromLTWH(-4 * s, -2 * s, 8 * s, 4 * s),
          Paint()..color = _confetti[i % _confetti.length],
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TeacherPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.pose != pose;
}
