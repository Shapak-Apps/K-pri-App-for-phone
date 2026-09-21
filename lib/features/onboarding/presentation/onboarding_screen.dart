import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../onboarding_pages.dart';
import '../widgets/teacher_avatar.dart';

/// First-launch tutorial. The teacher changes pose per slide,
/// everything is animated, and there is always a Skip button.
/// Completion flag is stored in Hive box 'onboarding' (no extra deps).
///
/// NO dependency on AppProviders — uses hardcoded colors and auto-detects
/// language from system locale.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _i = 0;
  bool _finishing = false;

  // ── HARDCODED COLORS (no AppProviders dependency) ─────────────────────────
  static const _bg = Color(0xFF0B0E14);
  static const _surface = Color(0xFF151A23);
  static const _text = Color(0xFFE2E8F0);
  static const _sub = Color(0xFF94A3B8);
  static const _faint = Color(0xFF64748B);
  static const _accent = Color(0xFF38BDF8);
  static const _line = Color(0xFF2D3748);

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    try {
      final box = await Hive.openBox('onboarding');
      await box.put('done', true);
    } catch (_) {
      // Never trap the user: even if Hive fails, let them in.
    }
    if (mounted) widget.onDone();
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  /// Auto-detect language from system locale.
  String _detectLang() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final code = locale.languageCode.toLowerCase();
    if (code == 'ru') return 'ru';
    if (code == 'tk') return 'tk';
    if (code == 'tr') return 'tr';
    return 'en';
  }

  @override
  Widget build(BuildContext context) {
    final lang = _detectLang();
    final pages = onboardingPages;
    final last = _i == pages.length - 1;

    final skipLabel = switch (lang) {
      'ru' => 'Пропустить',
      'tk' => 'Geçmek',
      'tr' => 'Atla',
      _ => 'Skip',
    };
    final nextLabel = switch (lang) {
      'ru' => 'Дальше',
      'tk' => 'Öňe',
      'tr' => 'İleri',
      _ => 'Next',
    };
    final startLabel = switch (lang) {
      'ru' => 'Поехали!',
      'tk' => 'Başlaýarys!',
      'tr' => 'Başlayalım!',
      _ => 'Let\'s go!',
    };

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip — always visible, top right
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  skipLabel,
                  style: const TextStyle(color: _faint, fontSize: 13),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                onPageChanged: (v) => setState(() => _i = v),
                children: [
                  for (var idx = 0; idx < pages.length; idx++)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: TeacherAvatar(
                              key: ValueKey(pages[idx].pose),
                              pose: pages[idx].pose,
                              accent: _accent,
                              size: 210,
                            ),
                          ),
                          const SizedBox(height: 18),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              pages[idx].titleFor(lang),
                              key: ValueKey('t$idx'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _text,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              pages[idx].bodyFor(lang),
                              key: ValueKey('b$idx'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _sub,
                                fontSize: 14,
                                height: 1.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _i ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _i ? _accent : _line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (last) {
                      _finish();
                    } else {
                      _page.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    last ? startLabel : nextLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
