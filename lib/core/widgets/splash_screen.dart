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

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const _minShow = Duration(milliseconds: 2200);
  static const _totalIn = Duration(milliseconds: 1800);
  static const _warpDur = Duration(milliseconds: 1700);

  late final AnimationController _mainCtrl;
  late final AnimationController _orbitCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _warpCtrl;

  late final Animation<double> _iconRotation;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _spiralProgress;
  late final Animation<double> _wavePhase;
  late final Animation<double> _subtitle;

  late final Animation<double> _suck;
  late final Animation<double> _holeGrow;
  late final Animation<double> _zoom;
  late final Animation<double> _clipGrow;
  late final Animation<double> _ringFade;
  late final Animation<double> _streakBell;
  late final Animation<double> _shock;

  bool _taskDone = false;
  bool _waited = false;
  bool _leaving = false;
  bool _warping = false;
  Widget? _preview;

  late final _GeometricPainter _geoPainter;
  late final _OrbitalParticlesPainter _orbitalPainter;
  late final _TitlePainter _titlePainter;
  late final _WavePainter _wavePainter;
  late final _WarpStreaksPainter _warpPainter;
  late final _BlackHolePainter _blackHolePainter;

  bool _paintersInitialized = false;

  @override
  void initState() {
    super.initState();
    _mainCtrl = AnimationController(vsync: this, duration: _totalIn);
    _orbitCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
    _warpCtrl = AnimationController(vsync: this, duration: _warpDur)
      ..addStatusListener((s) { if (s == AnimationStatus.completed) _finish(); });

    _iconRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)));
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack)));
    _iconOpacity = CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.3, curve: Curves.easeOut));
    _spiralProgress = CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeInOut));
    _wavePhase = Tween<double>(begin: 0.0, end: 4 * math.pi).animate(CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.3, 1.0, curve: Curves.linear)));
    _subtitle = CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic));

    _suck = CurvedAnimation(parent: _warpCtrl, curve: const Interval(0.00, 0.45, curve: Curves.easeInCubic));
    _holeGrow = CurvedAnimation(parent: _warpCtrl, curve: const Interval(0.02, 0.42, curve: Curves.easeOutCubic));
    _zoom = CurvedAnimation(parent: _warpCtrl, curve: const Interval(0.30, 0.94, curve: Curves.easeInOutCubic));
    _clipGrow = CurvedAnimation(parent: _warpCtrl, curve: const Interval(0.45, 0.97, curve: Curves.easeInCubic));
    _ringFade = CurvedAnimation(parent: _warpCtrl, curve: const Interval(0.82, 1.0, curve: Curves.easeOut));
    _streakBell = CurvedAnimation(parent: _warpCtrl, curve: const Interval(0.10, 0.90, curve: Curves.easeInOut));
    _shock = CurvedAnimation(parent: _warpCtrl, curve: const Interval(0.00, 0.55, curve: Curves.easeOutCubic));

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_paintersInitialized) {
      final c = context.c;
      final colors = [c.text, c.accent, c.text, c.text, c.accent];

      _geoPainter = _GeometricPainter(repaint: Listenable.merge([_mainCtrl, _orbitCtrl]), mainCtrl: _mainCtrl, orbitCtrl: _orbitCtrl, color: c.accent);
      _orbitalPainter = _OrbitalParticlesPainter(repaint: _particleCtrl, timeCtrl: _particleCtrl, color: c.accent, count: 12);
      _titlePainter = _TitlePainter(repaint: Listenable.merge([_mainCtrl, _wavePhase]), mainCtrl: _mainCtrl, wavePhase: _wavePhase, colors: colors, style: AppTheme.logo(size: 32, color: c.text));
      _wavePainter = _WavePainter(repaint: Listenable.merge([_mainCtrl, _wavePhase]), mainCtrl: _mainCtrl, wavePhase: _wavePhase, color: c.accent.withValues(alpha: 0.6));
      _warpPainter = _WarpStreaksPainter(repaint: Listenable.merge([_warpCtrl, _streakBell]), warpCtrl: _warpCtrl, streakBell: _streakBell, color: c.accent);
      _blackHolePainter = _BlackHolePainter(repaint: Listenable.merge([_warpCtrl, _holeGrow, _ringFade, _shock]), warpCtrl: _warpCtrl, holeGrow: _holeGrow, ringFade: _ringFade, shock: _shock, accent: c.accent);

      _paintersInitialized = true;
    }
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
    Navigator.of(context).pushReplacement(PageRouteBuilder<void>(transitionDuration: Duration.zero, pageBuilder: (ctx, _, __) => widget.next(ctx)));
  }

  @override
  void dispose() {
    _mainCtrl.dispose(); _orbitCtrl.dispose(); _particleCtrl.dispose(); _warpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(animation: _warpCtrl, builder: (context, _) {
            final suck = _warping ? _suck.value : 0.0;
            return Container(color: Color.lerp(c.bg, Colors.black, _warping ? math.min(1.0, 0.35 + suck) : 0.0) ?? Colors.black);
          }),
          CustomPaint(size: MediaQuery.of(context).size, painter: _warping ? _warpPainter : null),
          if (_warping && _preview != null) AnimatedBuilder(animation: _warpCtrl, builder: (context, _) {
            final zoom = _zoom.value; final size = MediaQuery.of(context).size;
            final minDim = math.min(size.width, size.height); final maxR = math.sqrt(size.width * size.width + size.height * size.height);
            final holeR = _holeGrow.value * minDim * 0.18; final clipR = holeR + (maxR * 0.62 - holeR) * _clipGrow.value;
            if (zoom <= 0.0 || clipR <= 1.0) return const SizedBox.shrink();
            return ClipPath(clipper: _CircleClipper(clipR), child: Transform.rotate(angle: (1.0 - zoom) * -0.22, child: Transform.scale(scale: 0.08 + 0.92 * zoom, child: Opacity(opacity: math.min(1.0, 0.15 + zoom * 1.6), child: IgnorePointer(ignoring: true, child: SizedBox.expand(child: _preview!))))));
          }),
          AnimatedBuilder(animation: _warpCtrl, builder: (context, child) {
            final suck = _warping ? _suck.value : 0.0;
            if (_warping && suck >= 0.999) return const SizedBox.shrink();
            return Opacity(opacity: 1.0 - suck, child: Transform.rotate(angle: suck * 2.5 * math.pi, child: Transform.scale(scale: math.max(0.001, 1.0 - suck), child: child)));
          }, child: SizedBox.expand(child: Stack(alignment: Alignment.center, children: [
            CustomPaint(size: const Size(400, 400), painter: _geoPainter),
            CustomPaint(size: MediaQuery.of(context).size, painter: _orbitalPainter),
            Column(mainAxisSize: MainAxisSize.min, children: [
              _buildAnimatedIcon(c), const SizedBox(height: 28), _buildAnimatedTitle(), const SizedBox(height: 12), _buildAnimatedWaveLine(), const SizedBox(height: 14), _buildAnimatedSubtitle(c),
            ]),
          ]))),
          CustomPaint(size: MediaQuery.of(context).size, painter: _warping ? _blackHolePainter : null),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(AppColors c) {
    return FadeTransition(opacity: _iconOpacity, child: AnimatedBuilder(animation: Listenable.merge([_iconRotation, _iconScale, _spiralProgress]), builder: (context, child) {
      final spiralT = _spiralProgress.value; final spiralRadius = 50 * (1 - spiralT); final spiralAngle = 4 * math.pi * spiralT;
      return Transform.translate(offset: Offset(spiralRadius * math.cos(spiralAngle), spiralRadius * math.sin(spiralAngle)), child: Transform.rotate(angle: _iconRotation.value, child: Transform.scale(scale: _iconScale.value, child: child)));
    }, child: Container(width: 100, height: 100, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: c.accent.withValues(alpha: 0.3), width: 2), color: c.surface, boxShadow: [BoxShadow(color: c.accent.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 2)]), child: ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.asset('assets/icon/app_icon.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.translate_rounded, color: c.accent, size: 48))))));
  }

  Widget _buildAnimatedTitle() => CustomPaint(size: const Size(300, 60), painter: _titlePainter);
  Widget _buildAnimatedWaveLine() => CustomPaint(size: const Size(300, 8), painter: _wavePainter);

  Widget _buildAnimatedSubtitle(AppColors c) {
    return AnimatedBuilder(animation: _subtitle, builder: (context, child) => Transform.translate(offset: Offset(0, 20 * (1 - _subtitle.value)), child: Opacity(opacity: _subtitle.value, child: child)), child: Text('Ähli dillerde terjimeçi', style: AppTheme.caption(color: c.sub, size: 13)));
  }
}

class _CircleClipper extends CustomClipper<Path> {
  final double radius;
  _CircleClipper(this.radius);
  @override Path getClip(Size size) => Path()..addOval(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius));
  @override bool shouldReclip(covariant _CircleClipper old) => old.radius != radius;
}

class _GeometricPainter extends CustomPainter {
  final Animation<double> mainCtrl, orbitCtrl; final Color color;
  _GeometricPainter({required Listenable repaint, required this.mainCtrl, required this.orbitCtrl, required this.color}) : super(repaint: repaint);
  @override void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2); final scale = 0.3 + mainCtrl.value * 0.7;
    for (int index = 0; index < 3; index++) {
      final opacity = ((0.05 + mainCtrl.value * 0.1) * (1 - index * 0.3)).clamp(0.0, 1.0);
      if (opacity <= 0.001) continue;
      canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(orbitCtrl.value * 2 * math.pi + index * math.pi / 3); canvas.scale(scale);
      final path = Path(); for (int i = 0; i <= 6; i++) { final angle = 2 * math.pi * i / 6; if (i == 0) path.moveTo(200.0 * math.cos(angle), 200.0 * math.sin(angle)); else path.lineTo(200.0 * math.cos(angle), 200.0 * math.sin(angle)); }
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.3 * opacity)..style = PaintingStyle.stroke..strokeWidth = 1.5); canvas.restore();
    }
  }
  @override bool shouldRepaint(covariant _GeometricPainter old) => false;
}

class _OrbitalParticlesPainter extends CustomPainter {
  final Animation<double> timeCtrl; final Color color; final int count;
  _OrbitalParticlesPainter({required Listenable repaint, required this.timeCtrl, required this.color, required this.count}) : super(repaint: repaint);
  @override void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2; final native = SplashNative.instance;
    final glowPaint = Paint()..style = PaintingStyle.fill; final corePaint = Paint()..style = PaintingStyle.fill;
    if (native.available) {
      final n = native.particles(timeCtrl.value, count); final buf = native.particleList;
      for (int i = 0; i < n; i++) {
        final o = i * 5; final a = buf[o + 3]; if (a <= 0.001) continue;
        glowPaint.color = color.withValues(alpha: a * 0.25); corePaint.color = color.withValues(alpha: a);
        canvas.drawCircle(Offset(cx + buf[o], cy + buf[o + 1]), buf[o + 4], glowPaint); canvas.drawCircle(Offset(cx + buf[o], cy + buf[o + 1]), buf[o + 2], corePaint);
      }
    } else {
      final t = timeCtrl.value; for (int i = 0; i < count; i++) {
        final a = 2.0 + i * 0.5, b = 3.0 + i * 0.3, delta = i * math.pi / 6;
        final x = cx + 120 * math.sin(a * t * 2 * math.pi + delta), y = cy + 100 * math.sin(b * t * 2 * math.pi);
        final alpha = (math.sin(t * 2 * math.pi + i) + 1) / 2 * 0.6; final s = 2.0 + 2.0 * math.sin(t * 4 * math.pi + i);
        glowPaint.color = color.withValues(alpha: alpha * 0.25); corePaint.color = color.withValues(alpha: alpha);
        canvas.drawCircle(Offset(x, y), s * 3.5, glowPaint); canvas.drawCircle(Offset(x, y), s, corePaint);
      }
    }
  }
  @override bool shouldRepaint(covariant _OrbitalParticlesPainter old) => false;
}

class _TitlePainter extends CustomPainter {
  static const _letters = ['K', 'ö', 'p', 'r', 'i'];
  final Animation<double> mainCtrl, wavePhase;
  final List<Color> colors;
  final TextStyle style;

  List<TextPainter> _painters = [];
  double _totalWidth = 0;
  bool _init = false;

  _TitlePainter({
    required Listenable repaint,
    required this.mainCtrl,
    required this.wavePhase,
    required this.colors,
    required this.style,
  }) : super(repaint: repaint);

  void _initPainters() {
    _painters = [];
    _totalWidth = 0;
    for (int i = 0; i < _letters.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: _letters[i],
          style: style.copyWith(color: colors[i]),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      _painters.add(tp);
      _totalWidth += tp.width;
    }
    _init = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!_init) _initPainters();

    final mt = mainCtrl.value;
    final wp = wavePhase.value;
    final native = SplashNative.instance;

    if (native.available) native.letters(mt, wp, _letters.length);

    double x = (size.width - _totalWidth) / 2;
    final buf = native.letterList;

    for (int i = 0; i < _letters.length; i++) {
      final tp = _painters[i];
      double yOff, scale, rot, wave;

      if (native.available) {
        final o = i * 4;
        yOff = buf[o];
        scale = buf[o + 1];
        rot = buf[o + 2];
        wave = buf[o + 3];
      } else {
        final s = 0.25 + i * 0.08;
        final t = ((mt - s) / 0.25).clamp(0.0, 1.0);
        scale = 1 + 2.70158 * (t - 1) * (t - 1) * (t - 1) + 1.70158 * (t - 1) * (t - 1);
        yOff = 50.0 * (1.0 - (1 - (1 - t) * (1 - t) * (1 - t)));
        rot = (-math.pi / 6) * (1.0 - (1 - (1 - t) * (1 - t)));
        wave = math.sin(wp + i * 0.5) * 2;
      }

      if (scale > 0.001) {
        canvas.save();
        canvas.translate(x + tp.width / 2, size.height / 2 + yOff + wave);
        canvas.rotate(rot);
        canvas.scale(scale);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      }
      x += tp.width;
    }
  }

  @override
  bool shouldRepaint(covariant _TitlePainter old) => false;
}

class _BlackHolePainter extends CustomPainter {
  final Animation<double> warpCtrl, holeGrow, ringFade, shock; final Color accent;
  _BlackHolePainter({required Listenable repaint, required this.warpCtrl, required this.holeGrow, required this.ringFade, required this.shock, required this.accent}) : super(repaint: repaint);
  @override void paint(Canvas canvas, Size size) {
    final radius = holeGrow.value * math.min(size.width, size.height) * 0.18; final intensity = 1.0 - ringFade.value; final shockV = shock.value; final time = warpCtrl.value * 1.7;
    if (radius <= 0.5 || intensity <= 0.01) return;
    final c = size.center(Offset.zero);
    if (shockV > 0.01 && shockV < 0.99) canvas.drawCircle(c, radius + shockV * math.sqrt(size.width * size.width + size.height * size.height) * 0.45, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0..color = accent.withValues(alpha: 0.35 * (1 - shockV) * intensity));
    canvas.drawCircle(c, radius * 3.0, Paint()..shader = RadialGradient(colors: [accent.withValues(alpha: 0.0), accent.withValues(alpha: 0.28 * intensity), Colors.white.withValues(alpha: 0.10 * intensity), accent.withValues(alpha: 0.0)], stops: const [0.0, 0.28, 0.34, 0.75]).createShader(Rect.fromCircle(center: c, radius: radius * 3.0)));
    final pathPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..strokeCap = StrokeCap.round;
    for (var a = 0; a < 3; a++) { final path = Path(); final rot = time * 2.4 + a * 2 * math.pi / 3; var first = true; for (var phi = 0.0; phi <= 2.4 * math.pi; phi += 0.15) { final r = radius * (1.02 + 1.35 * math.exp(-0.42 * phi)); final p = Offset(c.dx + r * math.cos(phi + rot), c.dy + r * math.sin(phi + rot)); if (first) { path.moveTo(p.dx, p.dy); first = false; } else path.lineTo(p.dx, p.dy); } pathPaint.color = accent.withValues(alpha: 0.30 * intensity); canvas.drawPath(path, pathPaint); }
    canvas.drawCircle(c, radius, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2..color = Colors.white.withValues(alpha: 0.85 * intensity)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5));
    canvas.drawCircle(c, radius * 0.96, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = accent.withValues(alpha: 0.9 * intensity));
  }
  @override bool shouldRepaint(covariant _BlackHolePainter old) => false;
}

class _WarpStreaksPainter extends CustomPainter {
  final Animation<double> warpCtrl, streakBell; final Color color;
  _WarpStreaksPainter({required Listenable repaint, required this.warpCtrl, required this.streakBell, required this.color}) : super(repaint: repaint);
  @override void paint(Canvas canvas, Size size) {
    final intensity = math.sin(math.pi * streakBell.value); if (intensity <= 0.01) return;
    final c = size.center(Offset.zero); final maxR = math.sqrt(c.dx * c.dx + c.dy * c.dy); final time = warpCtrl.value * 1.7;
    final paint = Paint()..strokeWidth = 1.3..strokeCap = StrokeCap.round; final native = SplashNative.instance;
    if (native.available) {
      final buf = native.streakList; final count = native.streaks(time, intensity, 80);
      for (int i = 0; i < count; i++) { final o = i * 5; final dir = Offset(math.cos(buf[o]), math.sin(buf[o])); paint.color = (Color.lerp(Colors.white, color, buf[o + 4]) ?? color).withValues(alpha: buf[o + 3]); canvas.drawLine(c + dir * maxR * buf[o + 1], c + dir * (maxR * buf[o + 1] + buf[o + 2]), paint); }
    } else {
      double h(int i) { final v = math.sin(i * 127.1 + 311.7) * 43758.5453; return v - v.floor(); }
      for (var i = 0; i < 80; i++) { final prog = (time * (0.5 + h(i + 1000) * 1.1) + h(i + 2000)) % 1.0; final alpha = math.sin(math.pi * prog) * 0.65 * intensity; if (alpha <= 0.01) continue; final dir = Offset(math.cos(h(i) * 2 * math.pi), math.sin(h(i) * 2 * math.pi)); final r = maxR * (0.12 + 0.95 * math.pow(prog, 2.4)); paint.color = (Color.lerp(Colors.white, color, h(i + 3000)) ?? color).withValues(alpha: alpha); canvas.drawLine(c + dir * r, c + dir * (r + (4 + 30 * prog) * intensity), paint); }
    }
  }
  @override bool shouldRepaint(covariant _WarpStreaksPainter old) => false;
}

class _WavePainter extends CustomPainter {
  final Animation<double> mainCtrl, wavePhase; final Color color;
  _WavePainter({required Listenable repaint, required this.mainCtrl, required this.wavePhase, required this.color}) : super(repaint: repaint);
  @override void paint(Canvas canvas, Size size) {
    final progress = mainCtrl.value; if (progress <= 0.01) return;
    final phase = wavePhase.value; final w = 80 * progress; if (w <= 1) return;
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(0, size.height / 2);
    // 🚀 Шаг 3 вместо 1 для снижения нагрузки на CPU
    for (double x = 1; x <= w; x += 3) { final nx = x / w; path.lineTo(x, size.height / 2 + 3 * math.sin(2 * math.pi * nx * 2 + phase) * math.sin(math.pi * nx) * progress); }
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant _WavePainter old) => false;
}