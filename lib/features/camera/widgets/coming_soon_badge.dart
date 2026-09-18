import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Pulsing "Soon · v2.0.0" badge rendered on top of the shutter button
/// while the camera feature is disabled.
class ComingSoonBadge extends StatefulWidget {
  final String mainText;
  final String versionText;
  final String subtitleText;
  final AppColors c;
  final VoidCallback onTap;

  const ComingSoonBadge({
    required this.mainText,
    required this.versionText,
    required this.subtitleText,
    required this.c,
    required this.onTap,
  });

  @override
  State<ComingSoonBadge> createState() => _ComingSoonBadgeState();
}

class _ComingSoonBadgeState extends State<ComingSoonBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  /// FIX: the curved animation is now a named field so it can be disposed.
  /// Previously it was created anonymously inside `Tween.animate(...)`,
  /// which left it subscribed to [_pulse] with no way to release it.
  late final CurvedAnimation _pulseCurve;

  /// Tween-driven wrappers over [_pulseCurve]. Plain [Animation] objects
  /// hold no native resources and have no `dispose()` — they are released
  /// together with their parent curve.
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;

  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseCurve = CurvedAnimation(parent: _pulse, curve: Curves.easeInOut);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.06).animate(_pulseCurve);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.7).animate(_pulseCurve);
  }

  @override
  void dispose() {
    // FIX: dispose the curve first (it unsubscribes from the controller),
    // then the controller itself. No dangling listeners survive.
    _pulseCurve.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final mainText = widget.mainText;
    final versionText = widget.versionText;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: _expanded ? 14 : 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: c.accent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: c.accent.withValues(alpha: 0.45 * _glowAnim.value),
                    blurRadius: 14,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    mainText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      versionText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
