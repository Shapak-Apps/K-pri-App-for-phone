import 'package:flutter/material.dart';

import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../conversation/data/tts_service.dart';
import '../settings_constants.dart';

/// Animated neon switch (custom replacement for [Switch]).
class NeoSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accentColor;
  const NeoSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.accentColor,
  });

  @override
  State<NeoSwitch> createState() => _NeoSwitchState();
}

class _NeoSwitchState extends State<NeoSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.value ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant NeoSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          const width = 52.0;
          const height = 30.0;
          const thumbSize = 24.0;
          const padding = 3.0;
          final thumbX = padding + (width - thumbSize - padding * 2) * t;

          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              gradient: LinearGradient(
                colors: t > 0.5
                    ? [
                        widget.accentColor.withValues(alpha: 0.95),
                        widget.accentColor.withValues(alpha: 0.75),
                      ]
                    : [
                        Colors.grey.withValues(alpha: 0.25),
                        Colors.grey.withValues(alpha: 0.15),
                      ],
              ),
              boxShadow: t > 0.5
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.45),
                        blurRadius: 12 * t,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: thumbX,
                  top: padding,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: t > 0.7 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 150),
                        child: Icon(
                          Icons.check_rounded,
                          color: widget.accentColor,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Icon + title + subtitle row ending with a [NeoSwitch].
class NeoSwitchTile extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const NeoSwitchTile({
    super.key,
    required this.c,
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  iconColor.withValues(alpha: 0.25),
                  iconColor.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.30),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTheme.caption(color: c.faint, size: 11),
                  ),
                ],
              ],
            ),
          ),
          NeoSwitch(value: value, onChanged: onChanged, accentColor: c.accent),
        ],
      ),
    );
  }
}

/// Custom glow slider with snap-to-step dragging.
class GlowSlider extends StatefulWidget {
  final double value, min, max;
  final int divisions;
  final Color accentColor;
  final ValueChanged<double> onChanged;
  const GlowSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  State<GlowSlider> createState() => _GlowSliderState();
}

class _GlowSliderState extends State<GlowSlider> {
  final GlobalKey _trackKey = GlobalKey();
  bool _dragging = false;

  double _calcValue(double localX, double trackWidth) {
    final pct = (localX / trackWidth).clamp(0.0, 1.0);
    final raw = widget.min + (widget.max - widget.min) * pct;
    final step = (widget.max - widget.min) / widget.divisions;
    return ((raw / step).round() * step).clamp(widget.min, widget.max);
  }

  void _onDragStart(DragStartDetails details) {
    _dragging = true;
    final box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      widget.onChanged(_calcValue(details.localPosition.dx, box.size.width));
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_dragging) return;
    final box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      widget.onChanged(_calcValue(details.localPosition.dx, box.size.width));
    }
  }

  void _onDragEnd(DragEndDetails details) {
    _dragging = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = (widget.value - widget.min) / (widget.max - widget.min);

    return SizedBox(
      height: 36,
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onTapDown: (details) {
          final box =
              _trackKey.currentContext?.findRenderObject() as RenderBox?;
          if (box != null) {
            widget.onChanged(
              _calcValue(details.localPosition.dx, box.size.width),
            );
          }
        },
        child: LayoutBuilder(
          key: _trackKey,
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final thumbX = pct * width;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 14,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 14,
                  child: Container(
                    width: thumbX,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.accentColor.withValues(alpha: 0.95),
                          widget.accentColor.withValues(alpha: 0.70),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: thumbX - 14,
                  top: 4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: widget.accentColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Label + value badge + [GlowSlider] column.
class GlowSliderTile extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final String title;
  final String valueLabel;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;
  const GlowSliderTile({
    super.key,
    required this.c,
    required this.isDark,
    required this.title,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: c.accent.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  valueLabel,
                  style: TextStyle(
                    color: c.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GlowSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            accentColor: c.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Segmented pill selector for enum/int settings.
class PillSegment<T> extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final String label;
  final IconData icon;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;
  const PillSegment({
    super.key,
    required this.c,
    required this.isDark,
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: c.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: c.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                for (final o in options)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(o.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: value == o.$1
                              ? LinearGradient(
                                  colors: [
                                    c.accent.withValues(alpha: 0.95),
                                    c.accentDeep.withValues(alpha: 0.95),
                                  ],
                                )
                              : null,
                          color: value == o.$1 ? null : Colors.transparent,
                          boxShadow: value == o.$1
                              ? [
                                  BoxShadow(
                                    color: c.accent.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          o.$2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: value == o.$1 ? Colors.white : c.sub,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// TTS preview tile.
///
/// FIX: a single shared [TtsService] instance is used; creating a new one
/// per tap leaked a native TTS engine on every press.
class ListenPreviewTile extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  const ListenPreviewTile({super.key, required this.c, required this.isDark});

  static final TtsService _tts = TtsService();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final lang = context.settings.lang;
          _tts.speak(ttsExampleFor(lang), lang.name);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                c.accent.withValues(alpha: 0.20),
                c.accentDeep.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: c.accent.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      c.accent.withValues(alpha: 0.95),
                      c.accentDeep.withValues(alpha: 0.95),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withValues(alpha: 0.40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  context.settings.l10n.t('listen_preview'),
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Icon(Icons.volume_up_rounded, color: c.accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
