import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
    with SingleTickerProviderStateMixin {
  static const _minShow = Duration(milliseconds: 1500);
  static const _iconAsset = 'assets/icon/app_icon.png';
  static const _iconSize = 112.0;

  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _subtitleSlide;

  bool _taskDone = false;
  bool _waited = false;
  bool _leaving = false;
  bool _precacheStarted = false;

  @override
  void initState() {
    super.initState();

    SplashNative.instance.particles(0.0, 0);
    SplashNative.instance.letters(0.0, 0.0, 0);

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _subtitleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _subtitleSlide = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _ctrl.forward();

    Future<void>.delayed(_minShow, () {
      if (!mounted) return;
      _waited = true;
      _tryFinish();
    });
    widget.initTask().whenComplete(() {
      if (!mounted) return;
      _taskDone = true;
      _tryFinish();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_precacheStarted) return;
    _precacheStarted = true;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(
        const AssetImage(_iconAsset),
        context,
        size: const Size(_iconSize * 3, _iconSize * 3),
      ).then((_) {}).catchError((_) {});
    });
  }

  void _tryFinish() {
    if (_leaving || !_taskDone || !_waited) return;
    _leaving = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (ctx, _, __) => widget.next(ctx),
        transitionsBuilder: (ctx, anim, secondary, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final splashBg = isDark ? const Color(0xFF0A0F1E) : Colors.white;
    final iconSurface = isDark
        ? const Color(0xFF1A1F2E)
        : const Color(0xFFF8FAFC);
    final iconBorder = isDark
        ? c.accent.withValues(alpha: 0.45)
        : c.accent.withValues(alpha: 0.25);
    final iconShadow = isDark
        ? c.accent.withValues(alpha: 0.35)
        : c.accent.withValues(alpha: 0.15);
    final logoColors = isDark
        ? [Colors.white, c.accent]
        : [const Color(0xFF1A1F2E), c.accent];

    return Scaffold(
      backgroundColor: splashBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  width: _iconSize,
                  height: _iconSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: iconBorder, width: 1.5),
                    color: iconSurface,
                    boxShadow: [
                      BoxShadow(
                        color: iconShadow,
                        blurRadius: 28,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Center(
                          child: Icon(
                            Icons.translate_rounded,
                            color: c.accent,
                            size: 54,
                          ),
                        ),
                        Image.asset(
                          _iconAsset,
                          fit: BoxFit.cover,
                          cacheWidth: (_iconSize * 3).round(),
                          cacheHeight: (_iconSize * 3).round(),
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.medium,
                          isAntiAlias: true,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fade,
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    LinearGradient(colors: logoColors).createShader(bounds),
                child: Text(
                  'Köpri',
                  style: AppTheme.logo(size: 36, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: Listenable.merge([_subtitleFade, _subtitleSlide]),
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _subtitleSlide.value),
                child: Opacity(opacity: _subtitleFade.value, child: child),
              ),
              child: Text(
                'Ähli dillerde terjimeçi',
                style: AppTheme.caption(color: c.sub, size: 13),
              ),
            ),
            const SizedBox(height: 40),
            FadeTransition(
              opacity: _subtitleFade,
              child: SizedBox(
                width: 140,
                height: 2.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    backgroundColor: c.line,
                    valueColor: AlwaysStoppedAnimation(c.accent),
                    minHeight: 2.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
