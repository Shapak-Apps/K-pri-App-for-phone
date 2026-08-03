import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BridgeIndicator extends StatelessWidget {
  final bool active, enabled;
  final VoidCallback onTap;
  const BridgeIndicator({
    super.key,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      children: [
        Expanded(child: Container(height: 2, color: c.line)),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: enabled ? c.accent : c.surfaceHi,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.arrow_downward_rounded,
              color: enabled ? c.bg : c.faint,
              size: 22,
            ),
          ),
        ),
        Expanded(child: Container(height: 2, color: c.line)),
      ],
    );
  }
}
