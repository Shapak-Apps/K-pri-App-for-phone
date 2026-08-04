import 'package:flutter/material.dart';
import 'package:kopri/core/theme/app_colors.dart';

class PulsingMicButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onTap;
  final double size;
  const PulsingMicButton({
    super.key,
    required this.isListening,
    required this.onTap,
    this.size = 50,
  });

  @override
  State<PulsingMicButton> createState() => _PulsingMicButtonState();
}

class _PulsingMicButtonState extends State<PulsingMicButton>
    with SingleTickerProviderStateMixin {
  static const _rec = Color(0xFFEF4444);
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.isListening) _pulse.repeat();
  }

  @override
  void didUpdateWidget(covariant PulsingMicButton old) {
    super.didUpdateWidget(old);
    if (widget.isListening && !_pulse.isAnimating) {
      _pulse.forward(from: 0);
      _pulse.repeat();
    }
    if (!widget.isListening && _pulse.isAnimating) _pulse.stop();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final on = widget.isListening;
    final s = widget.size;
    return RepaintBoundary(
      child: SizedBox(
        width: s + 28,
        height: s + 28,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (on) ..._rings(s),
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              width: s,
              height: s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? _rec : c.surfaceHi,
                border: Border.all(color: on ? _rec : c.line, width: 1.5),
                boxShadow: on
                    ? [
                        BoxShadow(
                          color: _rec.withValues(alpha: 0.45),
                          blurRadius: 18,
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.onTap,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Icon(
                      on ? Icons.stop_rounded : Icons.mic_none_rounded,
                      key: ValueKey<bool>(on),
                      color: on ? Colors.white : c.sub,
                      size: s * 0.46,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Круглые расходящиеся кольца (две волны с разными фазами).
  List<Widget> _rings(double s) => List.generate(2, (i) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final t = (_pulse.value + i / 2) % 1.0;
        final scale = 1.0 + t * 0.75;
        final opacity = (1 - t) * 0.4;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _rec.withValues(alpha: opacity),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  });
}