import 'dart:io';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/camera_photo_model.dart';

/// Bottom bar of the camera tab: a fanned stack of the last saved photos
/// (tap → gallery) plus a counter label.
class CameraBottomStack extends StatelessWidget {
  final AppColors c;
  final List<CameraPhoto> all;
  final String emptyLabel;
  final String galleryLabel;
  final VoidCallback? onTap;
  const CameraBottomStack({
    required this.c,
    required this.all,
    required this.emptyLabel,
    required this.galleryLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const cardW = 72.0;
    const cardH = 98.0;
    const stackW = 190.0;
    const stackH = 132.0;
    final vis = all.length > 3 ? all.sublist(all.length - 3) : all.toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: SizedBox(
              width: stackW,
              height: stackH,
              child: vis.isEmpty
                  ? Center(
                      child: Icon(
                        Icons.photo_library_outlined,
                        color: c.faint,
                        size: 34,
                      ),
                    )
                  : Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (var i = 0; i < vis.length; i++)
                          _fanFor(
                            vis[i],
                            i,
                            vis.length,
                            cardW,
                            cardH,
                            stackW,
                            stackH,
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  galleryLabel,
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  all.isEmpty ? emptyLabel : '${all.length}',
                  style: AppTheme.caption(color: c.faint, size: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.sub, size: 26),
        ],
      ),
    );
  }

  /// Positions a single card inside the fan with rotation and offset.
  Widget _fanFor(
    CameraPhoto p,
    int i,
    int n,
    double cardW,
    double cardH,
    double stackW,
    double stackH,
  ) {
    final t = n == 1 ? 0.5 : i / (n - 1);
    final angle = -14.0 + 28.0 * t;
    final dx = -28.0 + 56.0 * t;
    final dy = 12.0 * ((t - 0.5).abs() * 2);
    final left = stackW / 2 - cardW / 2 + dx;
    final top = stackH / 2 - cardH / 2 + dy;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      left: left,
      top: top,
      width: cardW,
      height: cardH,
      child: _FanCard(photo: p, angleDeg: angle),
    );
  }
}

/// A single rotated photo card with a spring-like enter animation.
class _FanCard extends StatefulWidget {
  final CameraPhoto photo;
  final double angleDeg;
  const _FanCard({required this.photo, required this.angleDeg});
  @override
  State<_FanCard> createState() => _FanCardState();
}

class _FanCardState extends State<_FanCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnimatedRotation(
      turns: widget.angleDeg / 360,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      child: AnimatedBuilder(
        animation: _enter,
        builder: (_, __) {
          final e = Curves.easeOutBack.transform(_enter.value);
          return Transform.scale(
            scale: 0.6 + 0.4 * e,
            child: Opacity(
              opacity: _enter.value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: c.surfaceHi,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(widget.photo.path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.image_rounded,
                        color: c.faint,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
