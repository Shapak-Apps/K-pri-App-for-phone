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

class _NeonBottomNavState extends State<NeonBottomNav> {
  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.bg,
        border: Border(
          top: BorderSide(color: c.line.withValues(alpha: 0.6), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Row(
            children: [
              for (var i = 0; i < widget.items.length; i++)
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _tap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              width: 46,
              height: 30,
              decoration: BoxDecoration(
                gradient: sel
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [c.accent, c.accentDeep],
                      )
                    : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: c.accent.withValues(alpha: 0.55),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: AnimatedBuilder(
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
                    child: Icon(
                      widget.icon,
                      color: sel ? Colors.white : c.faint,
                      size: 19,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                color: sel ? c.accentHi : c.faint,
                fontSize: 10,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.2,
                height: 1.1,
              ),
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
