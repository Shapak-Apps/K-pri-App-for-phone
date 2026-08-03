import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onHistoryTap;
  final int historyCount;
  const AppHeader({super.key, this.onHistoryTap, this.historyCount = 0});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}