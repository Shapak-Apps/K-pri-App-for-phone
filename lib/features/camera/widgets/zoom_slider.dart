import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Vertical zoom control with +/- steppers, a rotated slider track and
/// a "reset to 1x" chip that appears once zoomed in.
class CameraZoomSlider extends StatelessWidget {
  final AppColors c;
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;

  const CameraZoomSlider({
    required this.c,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final range = max - min;
    final normalized = range <= 0
        ? 0.0
        : ((value - min) / range).clamp(0.0, 1.0);
    return SizedBox(
      width: 56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _zoomBtn(
            Icons.add_rounded,
            () => onChanged((value + 0.5).clamp(min, max)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  activeTrackColor: c.accent,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 9,
                  ),
                  overlayColor: c.accent.withValues(alpha: 0.2),
                ),
                child: Slider(
                  min: 0.0,
                  max: 1.0,
                  value: normalized,
                  onChanged: (v) => onChanged(min + v * range),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _zoomBtn(
            Icons.remove_rounded,
            () => onChanged((value - 0.5).clamp(min, max)),
          ),
          const SizedBox(height: 12),
          if (value != min)
            GestureDetector(
              onTap: () => onChanged(min),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.55),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${min.toStringAsFixed(0)}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.45),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    ),
  );
}
