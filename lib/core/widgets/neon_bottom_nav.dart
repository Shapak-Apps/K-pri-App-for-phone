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
  late AnimationController _slide;

  @override
  void initState() {
    super.initState();
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
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final n = widget.items.length;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: SizedBox(
          height: 66,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(33),
              border: Border.all(color: c.line),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.55 : 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(33),
              child: LayoutBuilder(
                builder: (ctx, cons) {
                  final cellW = cons.maxWidth / n;
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutCubic,
                        left: widget.index * cellW + 5,
                        width: cellW - 10,
                        top: 7,
                        bottom: 7,
                        child: AnimatedBuilder(
                          animation: _slide,
                          builder: (_, __) {
                            final sx =
                                1.0 +
                                0.06 *
                                    Curves.easeOut.transform(
                                      _slide.value < 0.5
                                          ? _slide.value * 2
                                          : (1 - _slide.value) * 2,
                                    );
                            return Transform.scale(
                              scaleX: sx,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                decoration: BoxDecoration(
                                  color: c.accent.withValues(
                                    alpha: dark ? 0.22 : 0.16,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

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
        ),
      ),
    );
  }
}

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
    final col = sel ? c.accent : c.text;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
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
                    0.18 *
                        Curves.easeOutBack.transform(
                          v < 0.5 ? v * 2 : (1 - v) * 2,
                        );
                return Transform.scale(
                  scale: s,
                  child: Icon(widget.icon, color: col, size: 24),
                );
              },
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: col,
                fontSize: 11,
                fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}