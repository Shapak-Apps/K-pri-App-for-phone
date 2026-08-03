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
  static const _minShow = Duration(milliseconds: 1600);
  static const _totalIn = Duration(milliseconds: 900);
  static const _fadeOutDur = Duration(milliseconds: 260);

  // ── Intro controller (one controller drives everything) ────────────────
  late final AnimationController _inCtrl;

  // Staggered intervals (0→1 timeline)
  late final Animation<double> _iconOpacity; // 0.00 → 0.35
  late final Animation<double> _iconScale; // 0.00 → 0.35
  late final Animation<double> _titleOpacity; // 0.25 → 0.60
  late final Animation<double> _titleSlide; // 0.25 → 0.60
  late final Animation<double> _subOpacity; // 0.45 → 0.80
  late final Animation<double> _subSlide; // 0.45 → 0.80
  late final Animation<double> _lineWidth; // 0.55 → 0.90

  // ── Outro ──────────────────────────────────────────────────────────────
  late final AnimationController _outCtrl;
  late final Animation<double> _fadeOut;

  // ── Gates ──────────────────────────────────────────────────────────────
  bool _taskDone = false;
  bool _waited = false;
  bool _leaving = false;

  // ───────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Single controller → one vsync callback per frame, minimal overhead
    _inCtrl = AnimationController(vsync: this, duration: _totalIn);

    _iconOpacity = _interval(0.00, 0.35, Curves.easeOut);
    _iconScale = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(_interval(0.00, 0.35, Curves.easeOutBack));

    _titleOpacity = _interval(0.25, 0.60, Curves.easeOut);
    _titleSlide = Tween<double>(
      begin: 16,
      end: 0,
    ).animate(_interval(0.25, 0.60, Curves.easeOutCubic));

    _subOpacity = _interval(0.45, 0.80, Curves.easeOut);
    _subSlide = Tween<double>(
      begin: 12,
      end: 0,
    ).animate(_interval(0.45, 0.80, Curves.easeOutCubic));

    _lineWidth = _interval(0.55, 0.90, Curves.easeInOut);

    _inCtrl.forward();

    // Outro
    _outCtrl = AnimationController(
      vsync: this,
      duration: _fadeOutDur,
      value: 1.0,
    );
    _fadeOut = CurvedAnimation(parent: _outCtrl, curve: Curves.easeIn);

    // Min-show timer
    Future<void>.delayed(_minShow, () {
      if (!mounted) return;
      _waited = true;
      _tryNavigate();
    });

    // Init task
    widget.initTask().whenComplete(() {
      if (!mounted) return;
      _taskDone = true;
      _tryNavigate();
    });
  }

  /// Helper: creates a curved interval animation from the single controller.
  Animation<double> _interval(double begin, double end, Curve curve) {
    return CurvedAnimation(
      parent: _inCtrl,
      curve: Interval(begin, end, curve: curve),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  Future<void> _tryNavigate() async {
    if (_leaving || !_taskDone || !_waited) return;
    _leaving = true;

    await _outCtrl.reverse();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (ctx, _, __) => widget.next(ctx),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inCtrl.dispose();
    _outCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Scaffold(
      backgroundColor: c.bg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeOut,
          child: RepaintBoundary(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon ──────────────────────────────────────────────────
                FadeTransition(
                  opacity: _iconOpacity,
                  child: ScaleTransition(
                    scale: _iconScale,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: c.line, width: 1),
                        color: c.surface,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(21),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.translate_rounded,
                            color: c.accent,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ── Title ─────────────────────────────────────────────────
                FadeTransition(
                  opacity: _titleOpacity,
                  child: AnimatedBuilder(
                    animation: _titleSlide,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _titleSlide.value),
                      child: child,
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Köp',
                            style: AppTheme.logo(size: 26, color: c.text),
                          ),
                          TextSpan(
                            text: 'ri',
                            style: AppTheme.logo(size: 26, color: c.accent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Decorative line ───────────────────────────────────────
                AnimatedBuilder(
                  animation: _lineWidth,
                  builder: (_, __) => Container(
                    height: 2,
                    width: 48 * _lineWidth.value,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      color: c.accent.withValues(alpha: 0.5),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Subtitle ──────────────────────────────────────────────
                FadeTransition(
                  opacity: _subOpacity,
                  child: AnimatedBuilder(
                    animation: _subSlide,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _subSlide.value),
                      child: child,
                    ),
                    child: Text(
                      'Ähli dillerde terjimeçi',
                      style: AppTheme.caption(color: c.sub, size: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
