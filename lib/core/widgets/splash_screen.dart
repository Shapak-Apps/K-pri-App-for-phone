import 'dart:math' as math;
import 'package:flutter/material.dart';
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
  // ── Timings ────────────────────────────────────────────────────────────
  static const _minShow = Duration(milliseconds: 2200);
  static const _totalIn = Duration(milliseconds: 1800);
  static const _warpDur = Duration(milliseconds: 1700);

  // ── Controllers ────────────────────────────────────────────────────────
  late final AnimationController _mainCtrl;
  late final AnimationController _orbitCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _warpCtrl;

  // ── Intro animations ───────────────────────────────────────────────────
  late final Animation<double> _iconRotation;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _spiralProgress;
  late final Animation<double> _wavePhase;
  final List<Animation<double>> _letterScales = [];
  final List<Animation<double>> _letterOffsets = [];
  final List<Animation<double>> _letterRotations = [];

  // ── Warp (black-hole) animations ───────────────────────────────────────
  late final Animation<double> _suck;
  late final Animation<double> _holeGrow;
  late final Animation<double> _zoom;
  late final Animation<double> _clipGrow;
  late final Animation<double> _ringFade;
  late final Animation<double> _streakBell;
  late final Animation<double> _shock;

  // ── Gates ──────────────────────────────────────────────────────────────
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

    // ── Intro ───────────────────────────────────────────────────────────
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

    const letters = ['K', 'ö', 'p', 'r', 'i'];
    for (int i = 0; i < letters.length; i++) {
      final s = 0.25 + i * 0.08;
      final e = s + 0.25;
      _letterScales.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _mainCtrl,
            curve: Interval(s, e, curve: Curves.easeOutBack),
          ),
        ),
      );
      _letterOffsets.add(
        Tween<double>(begin: 50.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _mainCtrl,
            curve: Interval(s, e, curve: Curves.easeOutCubic),
          ),
        ),
      );
      _letterRotations.add(
        Tween<double>(begin: -math.pi / 6, end: 0.0).animate(
          CurvedAnimation(
            parent: _mainCtrl,
            curve: Interval(s, e, curve: Curves.easeOut),
          ),
        ),
      );
    }

    // ── Warp timeline ────────────────────────────────────────────────────
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

  // ───────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainCtrl,
          _orbitCtrl,
          _particleCtrl,
          _warpCtrl,
        ]),
        builder: (context, _) {
          final size = MediaQuery.of(context).size;
          final minDim = math.min(size.width, size.height);
          final maxR = math.sqrt(
            size.width * size.width + size.height * size.height,
          );

          final suck = _warping ? _suck.value : 0.0;
          final holeR = (_warping ? _holeGrow.value : 0.0) * minDim * 0.18;
          final zoom = _warping ? _zoom.value : 0.0;
          final clipR =
              holeR +
              (maxR * 0.62 - holeR) * (_warping ? _clipGrow.value : 0.0);
          final ringOpacity = _warping ? (1.0 - _ringFade.value) : 0.0;
          final streakI = _warping
              ? math.sin(math.pi * _streakBell.value)
              : 0.0;
          final warpT = _warpCtrl.value * (_warpDur.inMilliseconds / 1000.0);
          final bgMix = _warping ? math.min(1.0, 0.35 + suck) : 0.0;

          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Color.lerp(c.bg, Colors.black, bgMix) ?? Colors.black,
              ),

              // ── 1. Warp-стрики (гиперпрыжок) ───────────────────────────
              if (streakI > 0.01)
                RepaintBoundary(
                  child: CustomPaint(
                    size: size,
                    painter: _WarpStreaksPainter(
                      intensity: streakI,
                      time: warpT,
                      color: c.accent,
                    ),
                  ),
                ),

              // ── 2. Портал: первый экран приближается из глубины ───────
              if (_warping && _preview != null && zoom > 0.0 && clipR > 1.0)
                ClipPath(
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
                ),

              // ── 3. Контент сплэша — всасывается в дыру ────────────────
              if (!_warping || suck < 0.999)
                Opacity(
                  opacity: 1.0 - suck,
                  child: Transform.rotate(
                    angle: suck * 2.5 * math.pi,
                    child: Transform.scale(
                      scale: math.max(0.001, 1.0 - suck),
                      child: SizedBox.expand(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ..._buildGeometricPatterns(c),
                            ..._buildOrbitalParticles(c, size),
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
                  ),
                ),

              if (_warping && holeR > 0.5 && ringOpacity > 0.01)
                RepaintBoundary(
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
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildGeometricPatterns(AppColors c) {
    final t = _mainCtrl.value;
    final orbitT = _orbitCtrl.value;
    return List.generate(3, (index) {
      final rotation = orbitT * 2 * math.pi + index * math.pi / 3;
      final scale = 0.3 + t * 0.7;
      final opacity = (0.05 + t * 0.1) * (1 - index * 0.3);
      return Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: CustomPaint(
              size: const Size(400, 400),
              painter: _HexagonPainter(
                color: c.accent.withValues(alpha: 0.3),
                sides: 6,
              ),
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildOrbitalParticles(AppColors c, Size size) {
    final particles = <Widget>[];
    final t = _particleCtrl.value;
    const numParticles = 12;
    for (int i = 0; i < numParticles; i++) {
      final a = 2 + i * 0.5;
      final b = 3 + i * 0.3;
      final delta = i * math.pi / 6;
      final x = 120 * math.sin(a * t * 2 * math.pi + delta);
      final y = 100 * math.sin(b * t * 2 * math.pi);
      final particleOpacity = (math.sin(t * 2 * math.pi + i) + 1) / 2;
      final pSize = 2.0 + 2.0 * math.sin(t * 4 * math.pi + i);
      particles.add(
        Positioned(
          left: size.width / 2 + x,
          top: size.height / 2 + y,
          child: Opacity(
            opacity: particleOpacity * 0.6,
            child: Container(
              width: pSize,
              height: pSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accent,
                boxShadow: [
                  BoxShadow(
                    color: c.accent.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return particles;
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

  Widget _buildAnimatedTitle(AppColors c) {
    const letters = ['K', 'ö', 'p', 'r', 'i'];
    final colors = [c.text, c.accent, c.text, c.text, c.accent];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(letters.length, (index) {
        return AnimatedBuilder(
          animation: _wavePhase,
          builder: (context, child) {
            final waveOffset = math.sin(_wavePhase.value + index * 0.5) * 2;
            return Transform.translate(
              offset: Offset(0, _letterOffsets[index].value + waveOffset),
              child: Transform.rotate(
                angle: _letterRotations[index].value,
                child: Transform.scale(
                  scale: _letterScales[index].value,
                  child: child,
                ),
              ),
            );
          },
          child: Text(
            letters[index],
            style: AppTheme.logo(size: 32, color: colors[index]),
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedWaveLine(AppColors c) {
    return CustomPaint(
      size: Size(80 * _mainCtrl.value, 8),
      painter: _WavePainter(
        color: c.accent.withValues(alpha: 0.6),
        phase: _wavePhase.value,
        progress: _mainCtrl.value,
      ),
    );
  }

  Widget _buildAnimatedSubtitle(AppColors c) {
    final p = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic),
    ).value;
    return Transform.translate(
      offset: Offset(0, 20 * (1 - p)),
      child: Opacity(
        opacity: p,
        child: Text(
          'Ähli dillerde terjimeçi',
          style: AppTheme.caption(color: c.sub, size: 13),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// ── PAINTERS ─────────────────────────────────────────────────────────────

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
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round
          ..color = accent.withValues(alpha: 0.30 * intensity),
      );
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
      canvas.drawLine(
        c + dir * r,
        c + dir * (r + len),
        Paint()
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round
          ..color = (Color.lerp(Colors.white, color, _h(i + 3000)) ?? color)
              .withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WarpStreaksPainter old) =>
      old.time != time || old.intensity != intensity;
}

class _HexagonPainter extends CustomPainter {
  final Color color;
  final int sides;
  _HexagonPainter({required this.color, required this.sides});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final path = Path();
    for (int i = 0; i <= sides; i++) {
      final angle = 2 * math.pi * i / sides;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      final y =
          size.height / 2 +
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