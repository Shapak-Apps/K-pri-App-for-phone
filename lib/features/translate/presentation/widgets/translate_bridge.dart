import 'package:flutter/material.dart';
import '../translation_state.dart';
import 'bridge_indicator.dart';
import 'bridge_loader.dart';

/// Центральный блок между вводом и результатом.
/// Ожидание/заряд — живой канал связи ([BridgeIndicator]);
/// перевод — анимация моста ([BridgeLoader]).
class TranslateBridge extends StatelessWidget {
  final TranslationState state;
  final bool canTranslate;
  final VoidCallback onTap;
  const TranslateBridge({
    super.key,
    required this.state,
    required this.canTranslate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = state is LoadingState;
    return SizedBox(
      height: 128,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: isLoading
              ? const KeyedSubtree(key: ValueKey('load'), child: BridgeLoader())
              : KeyedSubtree(
                  key: const ValueKey('cable'),
                  child: BridgeIndicator(
                    active: canTranslate,
                    enabled: canTranslate,
                    onTap: onTap,
                  ),
                ),
        ),
      ),
    );
  }
}
