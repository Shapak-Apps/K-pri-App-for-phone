import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../native/splash_native.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> Function() initTask;
  final WidgetBuilder next;

  const SplashScreen({super.key, required this.initTask, required this.next});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Timings ────────────────────────────────────────────────
  static const _minShow = Duration(milliseconds: 2200);
  static const _totalIn = Duration(milliseconds: 1800);
  static const _warpDur = Duration(milliseconds: 1700);

  // ── Controllers ────────────────────────────────────────────
  late final AnimationController _mainCtrl;
  late final AnimationController _orbitCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _warpCtrl;

  // ── Intro animations ───────────────────────────────────────
  late final Animation<double> _iconRotation;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _spiralProgress;
  late final Animation<double> _wavePhase;
  late final Animation<double> _subtitle;

  // ── Warp (black-hole) animations ───────────────────────────
  late final Animation<double> _suck;
  late final Animation<double> _holeGrow;
  late final Animation<double> _zoom;
  late final Animation<double> _clipGrow;
  late final Animation<double> _ringFade;
  late final Animation<double> _streakBell;
  late final Animation<double> _shock;

  // ── Gates ──────────────────────────────────────────────────
  bool _taskDone = false;
  bool _waited = false;
  bool _leaving = false;
  bool _warping = false;
  Widget? _preview;

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(vsync: this, duration: _totalIn);
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _warpCtrl = AnimationController(vsync: this, duration: _warpDur)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _finish();
      });

    // ── Intro ───────────────────────────────────────────────
    _iconRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack),
      ),
    );
    _iconOpacity = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _spiralProgress = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    );
    _wavePhase = Tween<double>(begin: 0.0, end: 4 * math.pi).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.linear),
      ),
    );
    _subtitle = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic),
    );

    // ── Warp timeline ───────────────────────────────────────
    _suck = CurvedAnimation(
      parent: _warpCtrl,
      curve: const Interval(0.00, 0.45, curve: Curves.easeInCubic),
    );
    _holeGrow = CurvedAnimation(
      parent: _warpCtrl,
      curve: const Interval(0.02, 0.42, curve: Curves.easeOutCubic),
    );
    _zoom = CurvedAnimation(
      parent: _warpCtrl,
      curve: const Interval(0.30, 0.94, curve: Curves.easeInOutCubic),
    );
    _clipGrow = CurvedAnimation(
      parent: _warpCtrl,
      curve: const Interval(0.45, 0.97, curve: Curves.easeInCubic),
    );
    _ringFade = CurvedAnimation(
      parent: _warpCtrl,
      curve: const Interval(0.82, 1.0, curve: Curves.easeOut),
    );
    _streakBell = CurvedAnimation(
      parent: _warpCtrl,
      curve: const Interval(0.10, 0.90, curve: Curves.easeInOut),
    );
    _shock = CurvedAnimation(
      parent: _warpCtrl,
      curve: const Interval(0.00, 0.55, curve: Curves.easeOutCubic),
    );

    _mainCtrl.forward();

    Future<void>.delayed(_minShow, () {
      if (!mounted) return;
      _waited = true;
      _tryStartWarp();
    });
    widget.initTask().whenComplete(() {
      if (!mounted) return;
      _taskDone = true;
      _tryStartWarp();
    });
  }

  void _tryStartWarp() {
    if (_leaving || !_taskDone || !_waited) return;
    _leaving = true;
    setState(() {
      _warping = true;
      _preview = widget.next(context);
    });
    _warpCtrl.forward();
  }

  void _finish() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: Duration.zero,
        pageBuilder: (ctx, _, __) => widget.next(ctx),
      ),
    );
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _orbitCtrl.dispose();
    _particleCtrl.dispose();
    _warpCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ── 1. Background Color ────────────────────────────
          AnimatedBuilder(
            animation: _warpCtrl,
            builder: (context, _) {
              final suck = _warping ? _suck.value : 0.0;
              final bgMix = _warping ? math.min(1.0, 0.35 + suck) : 0.0;
              return Container(
                color: Color.lerp(c.bg, Colors.black, bgMix) ?? Colors.black,
              );
            },
          ),

          // ── 2. Warp-стрики (гиперпрыжок) — C++ ─────────────
          if (_warping)
            AnimatedBuilder(
              animation: _warpCtrl,
              builder: (context, _) {
                final streakI = math.sin(math.pi * _streakBell.value);
                if (streakI <= 0.01) return const SizedBox.shrink();
                final warpT =
                    _warpCtrl.value * (_warpDur.inMilliseconds / 1000.0);
                return RepaintBoundary(
                  child: CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _WarpStreaksPainter(
                      intensity: streakI,
                      time: warpT,
                      color: c.accent,
                    ),
                  ),
                );
              },
            ),

          // ── 3. Портал: первый экран приближается ───────────
          if (_warping && _preview != null)
            AnimatedBuilder(
              animation: _warpCtrl,
              builder: (context, _) {
                final zoom = _zoom.value;
                final size = MediaQuery.of(context).size;
                final minDim = math.min(size.width, size.height);
                final maxR = math.sqrt(
                    size.width * size.width + size.height * size.height);
                final holeR = _holeGrow.value * minDim * 0.18;
                final clipR =
                    holeR + (maxR * 0.62 - holeR) * _clipGrow.value;

                if (zoom <= 0.0 || clipR <= 1.0) {
                  return const SizedBox.shrink();
                }

                return ClipPath(
                  clipper: _CircleClipper(clipR),
                  child: Transform.rotate(
                    angle: (1.0 - zoom) * -0.22,
                    child: Transform.scale(
                      scale: 0.08 + 0.92 * zoom,
                      child: Opacity(
                        opacity: math.min(1.0, 0.15 + zoom * 1.6),
                        child: IgnorePointer(
                          ignoring: true,
                          child: SizedBox.expand(child: _preview!),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

          // ── 4. Контент сплэша (всасывается в дыру) ─────────
          AnimatedBuilder(
            animation: _warpCtrl,
            builder: (context, child) {
              final suck = _warping ? _suck.value : 0.0;
              if (_warping && suck >= 0.999) return const SizedBox.shrink();

              return Opacity(
                opacity: 1.0 - suck,
                child: Transform.rotate(
                  angle: suck * 2.5 * math.pi,
                  child: Transform.scale(
                    scale: math.max(0.001, 1.0 - suck),
                    child: child,
                  ),
                ),
              );
            },
            child: SizedBox.expand(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Геометрические паттерны — ОДИН CustomPaint
                  AnimatedBuilder(
                    animation: Listenable.merge([_mainCtrl, _orbitCtrl]),
                    builder: (context, _) => CustomPaint(
                      size: const Size(400, 400),
                      painter: _GeometricPainter(
                        mainT: _mainCtrl.value,
                        orbitT: _orbitCtrl.value,
                        color: c.accent,
                      ),
                    ),
                  ),

                  // Орбитальные частицы — ОДИН CustomPaint (C++)
                  AnimatedBuilder(
                    animation: _particleCtrl,
                    builder: (context, _) => CustomPaint(
                      size: MediaQuery.of(context).size,
                      painter: _OrbitalParticlesPainter(
                        time: _particleCtrl.value,
                        color: c.accent,
                        count: 12,
                      ),
                    ),
                  ),

                  // Основная колонка
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAnimatedIcon(c),
                      const SizedBox(height: 28),
                      _buildAnimatedTitle(c),
                      const SizedBox(height: 12),
                      _buildAnimatedWaveLine(c),
                      const SizedBox(height: 14),
                      _buildAnimatedSubtitle(c),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── 5. Черная дыра ─────────────────────────────────
          if (_warping)
            AnimatedBuilder(
              animation: _warpCtrl,
              builder: (context, _) {
                final size = MediaQuery.of(context).size;
                final minDim = math.min(size.width, size.height);
                final maxR =
                math.sqrt(size.width * size.width + size.height * size.height);
                final holeR = _holeGrow.value * minDim * 0.18;
                final ringOpacity = 1.0 - _ringFade.value;
                final warpT =
                    _warpCtrl.value * (_warpDur.inMilliseconds / 1000.0);

                if (holeR <= 0.5 || ringOpacity <= 0.01) {
                  return const SizedBox.shrink();
                }

                return RepaintBoundary(
                  child: CustomPaint(
                    size: size,
                    painter: _BlackHolePainter(
                      radius: holeR,
                      time: warpT,
                      intensity: ringOpacity,
                      shock: _shock.value,
                      maxR: maxR * 0.5,
                      accent: c.accent,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(AppColors c) {
    return FadeTransition(
      opacity: _iconOpacity,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _iconRotation,
          _iconScale,
          _spiralProgress,
        ]),
        builder: (context, child) {
          final spiralT = _spiralProgress.value;
          final spiralRadius = 50 * (1 - spiralT);
          final spiralAngle = 4 * math.pi * spiralT;
          return Transform.translate(
            offset: Offset(
              spiralRadius * math.cos(spiralAngle),
              spiralRadius * math.sin(spiralAngle),
            ),
            child: Transform.rotate(
              angle: _iconRotation.value,
              child: Transform.scale(scale: _iconScale.value, child: child),
            ),
          );
        },
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: c.accent.withValues(alpha: 0.3),
              width: 2,
            ),
            color: c.surface,
            boxShadow: [
              BoxShadow(
                color: c.accent.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/icon/app_icon.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.translate_rounded, color: c.accent, size: 48),
            ),
          ),
        ),
      ),
    );
  }

  // ── Заголовок: ОДИН CustomPaint, буквы считает C++ ─────────
  Widget _buildAnimatedTitle(AppColors c) {
    final colors = [c.text, c.accent, c.text, c.text, c.accent];
    return AnimatedBuilder(
      animation: Listenable.merge([_mainCtrl, _wavePhase]),
      builder: (context, _) {
        return CustomPaint(
          size: const Size(300, 60),
          painter: _TitlePainter(
            mainT: _mainCtrl.value,
            wavePhase: _wavePhase.value,
            colors: colors,
            style: AppTheme.logo(size: 32, color: c.text),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedWaveLine(AppColors c) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainCtrl, _wavePhase]),
      builder: (context, _) {
        return CustomPaint(
          size: Size(80 * _mainCtrl.value, 8),
          painter: _WavePainter(
            color: c.accent.withValues(alpha: 0.6),
            phase: _wavePhase.value,
            progress: _mainCtrl.value,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSubtitle(AppColors c) {
    return AnimatedBuilder(
      animation: _subtitle,
      builder: (context, child) {
        final p = _subtitle.value;
        return Transform.translate(
          offset: Offset(0, 20 * (1 - p)),
          child: Opacity(
            opacity: p,
            child: child,
          ),
        );
      },
      child: Text(
        'Ähli dillerde terjimeçi',
        style: AppTheme.caption(color: c.sub, size: 13),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ── PAINTERS ─────────────────────────────────────────────────

class _CircleClipper extends CustomClipper<Path> {
  final double radius;
  _CircleClipper(this.radius);

  @override
  Path getClip(Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    return Path()..addOval(Rect.fromCircle(center: c, radius: radius));
  }

  @override
  bool shouldReclip(covariant _CircleClipper old) => old.radius != radius;
}

class _GeometricPainter extends CustomPainter {
  final double mainT;
  final double orbitT;
  final Color color;

  _GeometricPainter({
    required this.mainT,
    required this.orbitT,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = 0.3 + mainT * 0.7;

    for (int index = 0; index < 3; index++) {
      final rotation = orbitT * 2 * math.pi + index * math.pi / 3;
      final opacity =
      ((0.05 + mainT * 0.1) * (1 - index * 0.3)).clamp(0.0, 1.0);
      if (opacity <= 0.001) continue;

      final paint = Paint()
        ..color = color.withValues(alpha: 0.3 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.scale(scale);

      final path = Path();
      for (int i = 0; i <= 6; i++) {
        final angle = 2 * math.pi * i / 6;
        final x = 200.0 * math.cos(angle);
        final y = 200.0 * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GeometricPainter old) =>
      old.mainT != mainT || old.orbitT != orbitT;
}

class _OrbitalParticlesPainter extends CustomPainter {
  final double time;
  final Color color;
  final int count;

  _OrbitalParticlesPainter({
    required this.time,
    required this.color,
    required this.count,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final native = SplashNative.instance;

    final glowPaint = Paint()..style = PaintingStyle.fill;
    final corePaint = Paint()..style = PaintingStyle.fill;

    if (native.available) {
      final n = native.particles(time, count);
      final buf = native.particleList;
      for (int i = 0; i < n; i++) {
        final o = i * 5;
        final x = cx + buf[o];
        final y = cy + buf[o + 1];
        final s = buf[o + 2];
        final a = buf[o + 3];
        final g = buf[o + 4];
        if (a <= 0.001) continue;

        glowPaint.color = color.withValues(alpha: a * 0.25);
        corePaint.color = color.withValues(alpha: a);

        canvas.drawCircle(Offset(x, y), g, glowPaint);
        canvas.drawCircle(Offset(x, y), s, corePaint);
      }
    } else {
      for (int i = 0; i < count; i++) {
        final a = 2.0 + i * 0.5;
        final b = 3.0 + i * 0.3;
        final delta = i * math.pi / 6;
        final x = cx + 120 * math.sin(a * time * 2 * math.pi + delta);
        final y = cy + 100 * math.sin(b * time * 2 * math.pi);
        final op = (math.sin(time * 2 * math.pi + i) + 1) / 2;
        final alpha = op * 0.6;
        final s = 2.0 + 2.0 * math.sin(time * 4 * math.pi + i);

        glowPaint.color = color.withValues(alpha: alpha * 0.25);
        corePaint.color = color.withValues(alpha: alpha);

        canvas.drawCircle(Offset(x, y), s * 3.5, glowPaint);
        canvas.drawCircle(Offset(x, y), s, corePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitalParticlesPainter old) =>
      old.time != time;
}

class _TitlePainter extends CustomPainter {
  final double mainT;
  final double wavePhase;
  final List<Color> colors;
  final TextStyle style;

  static const _letters = ['K', 'ö', 'p', 'r', 'i'];

  _TitlePainter({
    required this.mainT,
    required this.wavePhase,
    required this.colors,
    required this.style,
  });

  static double _easeOutCubic(double t) {
    final u = 1 - t;
    return 1 - u * u * u;
  }

  static double _easeOut(double t) {
    final u = 1 - t;
    return 1 - u * u;
  }

  static double _easeOutBack(double t) {
    const c1 = 1.70158, c3 = c1 + 1;
    final u = t - 1;
    return 1 + c3 * u * u * u + c1 * u * u;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final native = SplashNative.instance;
    double yOff, scale, rot, wave;

    if (native.available) {
      native.letters(mainT, wavePhase, _letters.length);
    }

    final painters = <TextPainter>[];
    double total = 0;
    for (int i = 0; i < _letters.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: _letters[i],
          style: style.copyWith(color: colors[i]),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painters.add(tp);
      total += tp.width;
    }

    double x = (size.width - total) / 2;
    final buf = native.letterList;
    for (int i = 0; i < _letters.length; i++) {
      final tp = painters[i];

      if (native.available) {
        final o = i * 4;
        yOff = buf[o];
        scale = buf[o + 1];
        rot = buf[o + 2];
        wave = buf[o + 3];
      } else {
        final s = 0.25 + i * 0.08;
        final e = s + 0.25;
        final t = ((mainT - s) / (e - s)).clamp(0.0, 1.0);
        scale = _easeOutBack(t);
        yOff = 50.0 * (1.0 - _easeOutCubic(t));
        rot = (-math.pi / 6) * (1.0 - _easeOut(t));
        wave = math.sin(wavePhase + i * 0.5) * 2;
      }

      if (scale > 0.001) {
        canvas.save();
        canvas.translate(
          x + tp.width / 2,
          size.height / 2 + yOff + wave,
        );
        canvas.rotate(rot);
        canvas.scale(scale);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      }

      x += tp.width;
    }
  }

  @override
  bool shouldRepaint(covariant _TitlePainter old) =>
      old.mainT != mainT || old.wavePhase != wavePhase;
}

class _BlackHolePainter extends CustomPainter {
  final double radius;
  final double time;
  final double intensity;
  final double shock;
  final double maxR;
  final Color accent;

  _BlackHolePainter({
    required this.radius,
    required this.time,
    required this.intensity,
    required this.shock,
    required this.maxR,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0 || intensity <= 0) return;
    final c = size.center(Offset.zero);

    if (shock > 0.01 && shock < 0.99) {
      canvas.drawCircle(
        c,
        radius + shock * maxR * 0.9,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = accent.withValues(alpha: 0.35 * (1 - shock) * intensity),
      );
    }

    final glowR = radius * 3.0;
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: 0.0),
          accent.withValues(alpha: 0.28 * intensity),
          Colors.white.withValues(alpha: 0.10 * intensity),
          accent.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.28, 0.34, 0.75],
      ).createShader(Rect.fromCircle(center: c, radius: glowR));
    canvas.drawCircle(c, glowR, glow);

    const arms = 3;
    final pathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    for (var a = 0; a < arms; a++) {
      final path = Path();
      final rot = time * 2.4 + a * 2 * math.pi / arms;
      var first = true;
      for (var phi = 0.0; phi <= 2.4 * math.pi; phi += 0.10) {
        final r = radius * (1.02 + 1.35 * math.exp(-0.42 * phi));
        final th = phi + rot;
        final p = Offset(c.dx + r * math.cos(th), c.dy + r * math.sin(th));
        if (first) {
          path.moveTo(p.dx, p.dy);
          first = false;
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      pathPaint.color = accent.withValues(alpha: 0.30 * intensity);
      canvas.drawPath(path, pathPaint);
    }

    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = Colors.white.withValues(alpha: 0.85 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    canvas.drawCircle(
      c,
      radius * 0.96,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = accent.withValues(alpha: 0.9 * intensity),
    );
  }

  @override
  bool shouldRepaint(covariant _BlackHolePainter old) =>
      old.radius != radius ||
          old.time != time ||
          old.intensity != intensity ||
          old.shock != shock;
}

class _WarpStreaksPainter extends CustomPainter {
  final double intensity;
  final double time;
  final Color color;

  _WarpStreaksPainter({
    required this.intensity,
    required this.time,
    required this.color,
  });

  double _h(int i) {
    final v = math.sin(i * 127.1 + 311.7) * 43758.5453;
    return v - v.floor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = math.sqrt(c.dx * c.dx + c.dy * c.dy);
    const n = 80;

    final paint = Paint()
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final native = SplashNative.instance;

    if (native.available) {
      final buf = native.streakList;
      final count = native.streaks(time, intensity, n);
      for (int i = 0; i < count; i++) {
        final o = i * 5;
        final ang = buf[o];
        final r = maxR * buf[o + 1];
        final len = buf[o + 2];
        final alpha = buf[o + 3];
        final wm = buf[o + 4];

        final dir = Offset(math.cos(ang), math.sin(ang));
        paint.color =
            (Color.lerp(Colors.white, color, wm) ?? color).withValues(alpha: alpha);

        canvas.drawLine(
          c + dir * r,
          c + dir * (r + len),
          paint,
        );
      }
    } else {
      for (var i = 0; i < n; i++) {
        final ang = _h(i) * 2 * math.pi;
        final speed = 0.5 + _h(i + 1000) * 1.1;
        final seed = _h(i + 2000);
        final prog = (time * speed + seed) % 1.0;
        final r = maxR * (0.12 + 0.95 * math.pow(prog, 2.4).toDouble());
        final len = (4 + 30 * prog) * intensity;
        final alpha = math.sin(math.pi * prog) * 0.65 * intensity;
        if (alpha <= 0.01) continue;

        final dir = Offset(math.cos(ang), math.sin(ang));
        paint.color = (Color.lerp(Colors.white, color, _h(i + 3000)) ?? color)
            .withValues(alpha: alpha);

        canvas.drawLine(
          c + dir * r,
          c + dir * (r + len),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WarpStreaksPainter old) =>
      old.time != time || old.intensity != intensity;
}

class _WavePainter extends CustomPainter {
  final Color color;
  final double phase;
  final double progress;

  _WavePainter({
    required this.color,
    required this.phase,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 1) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(0, size.height / 2);
    for (double x = 0; x <= size.width; x += 1) {
      final nx = x / size.width;
      final y = size.height / 2 +
          3 *
              math.sin(2 * math.pi * nx * 2 + phase) *
              math.sin(math.pi * nx) *
              progress;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) =>
      old.phase != phase || old.progress != progress;
}