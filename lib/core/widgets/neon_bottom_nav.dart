import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

class NeonBottomNav extends StatefulWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<NavItem> items;
  const NeonBottomNav({
    super.key,
    required this.index,
    required this.onTap,
    required this.items,
  });

  @override
  State<NeonBottomNav> createState() => _NeonBottomNavState();
}

class _NeonBottomNavState extends State<NeonBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _pulse;
  late AnimationController _slide;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _slide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void didUpdateWidget(covariant NeonBottomNav old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) _slide.forward(from: 0);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    const dockH = 70.0;
    const inset = 6.0;
    const pillH = 40.0;
    const pillTop = 8.0;
    final n = widget.items.length;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        child: SizedBox(
          height: dockH,
          child: LayoutBuilder(
            builder: (ctx, cons) {
              final cellW = cons.maxWidth / n;
              final pillLeft = widget.index * cellW + inset;
              final pillW = cellW - inset * 2;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                    left: widget.index * cellW,
                    width: cellW,
                    top: -6,
                    bottom: -12,
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, __) {
                            final a = 0.20 + 0.14 * _pulse.value;
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    c.accent.withValues(alpha: a),
                                    c.accent.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // ── скользящая пилюля со squash-stretch + бликом ──
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                    left: pillLeft,
                    width: pillW,
                    top: pillTop,
                    height: pillH,
                    child: AnimatedBuilder(
                      animation: _slide,
                      builder: (_, __) {
                        // тянется в середине пути, сжимается к краям
                        final sx =
                            1.0 +
                            0.07 *
                                Curves.easeOut.transform(
                                  _slide.value < 0.5
                                      ? _slide.value * 2
                                      : (1 - _slide.value) * 2,
                                );
                        return Transform.scale(
                          scaleX: sx,
                          child: Container(
                            decoration: BoxDecoration(
                              color: c.accent,
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.20),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.55],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: c.accent.withValues(alpha: 0.5),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ── табы поверх (глифы + подписи, без подложки) ──
                  Positioned.fill(
                    child: Row(
                      children: [
                        for (var i = 0; i < n; i++)
                          Expanded(
                            child: _NavItem(
                              index: i,
                              selected: i == widget.index,
                              icon: widget.items[i].icon,
                              label: widget.items[i].label,
                              c: c,
                              onTap: widget.onTap,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Одна вкладка: пружинящий глиф + раскрывающаяся подпись у активной.
class _NavItem extends StatefulWidget {
  final int index;
  final bool selected;
  final IconData icon;
  final String label;
  final AppColors c;
  final ValueChanged<int> onTap;
  const _NavItem({
    required this.index,
    required this.selected,
    required this.icon,
    required this.label,
    required this.c,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  void _tap() {
    widget.onTap(widget.index);
    _bounce.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final sel = widget.selected;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _tap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _bounce,
              builder: (_, __) {
                final v = _bounce.value;
                final s =
                    1.0 +
                    0.24 *
                        Curves.easeOutBack.transform(
                          v < 0.5 ? v * 2 : (1 - v) * 2,
                        );
                return Transform.scale(
                  scale: s,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      widget.icon,
                      key: ValueKey<bool>(sel),
                      color: sel ? Colors.white : c.sub,
                      size: sel ? 23 : 22,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 3),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: sel
                  ? Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        height: 1.1,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
