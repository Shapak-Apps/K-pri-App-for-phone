import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'presentation/onboarding_screen.dart';

/// Shows [OnboardingScreen] on the VERY FIRST launch only.
/// The "seen" flag lives in the Hive box 'onboarding' — no new dependencies.
///
/// While onboarding is visible, this widget provides its OWN MaterialApp
/// (KopriApp is not built yet), so nothing inside KopriApp had to change.
class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key, required this.child});

  final Widget child;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool? _done; // null = still reading the flag

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final box = await Hive.openBox('onboarding');
      if (!mounted) return;
      setState(
        () => _done = (box.get('done', defaultValue: false) as bool?) ?? false,
      );
    } catch (_) {
      // Hive not ready for some reason — never block the app:
      if (!mounted) return;
      setState(() => _done = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done == null) {
      // Tiny splash while reading the flag (one frame usually).
      return const SizedBox.shrink();
    }
    if (_done == false) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0B0E14),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF38BDF8),
            surface: Color(0xFF151A23),
          ),
        ),
        home: OnboardingScreen(onDone: () => setState(() => _done = true)),
      );
    }
    return widget.child;
  }
}
