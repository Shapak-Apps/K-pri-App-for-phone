import 'package:flutter/material.dart';
import 'package:kopri/core/widgets/pulsing_mic_button.dart';

class MicButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onTap;
  const MicButton({super.key, required this.isListening, required this.onTap});

  @override
  Widget build(BuildContext context) =>
      PulsingMicButton(isListening: isListening, onTap: onTap);
}