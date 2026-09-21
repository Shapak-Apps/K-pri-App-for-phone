import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../features/camera/presentation/camera_screen.dart';
import '../../features/flashcards/presentation/flashcards_screen.dart';
import '../../features/history/data/history_repository.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/phrasebook/presentation/phrasebook_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/translate/presentation/translate_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../app/incoming_text.dart';
import '../controllers/app_settings_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ambient_background.dart';
import 'app_route.dart';
import 'neon_bottom_nav.dart';

class AppShell extends StatefulWidget {
  final HistoryRepository repo;
  final ValueListenable<IncomingText?> incomingText;
  final int initialScreen;

  const AppShell({
    super.key,
    required this.repo,
    required this.incomingText,
    this.initialScreen = 0,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // CRASH-FIX #2: nullable instead of `late final`.
  // - Will never throw LateInitializationError ("already initialized")
  // - Will never be read before initialization (null-check instead of crash)
  PageController? _pageController;
  AppSettingsController? _settings;

  int _i = 0;
  bool _cameraOn = true;
  bool _didInitDeps = false;

  static const _animDuration = Duration(milliseconds: 260);
  static const _animCurve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();
    // CRASH-FIX #1: NEVER call context.settings / context.l10n /
    // any InheritedWidget lookups inside initState().
    // Only regular listeners here.
    openScreen.addListener(_onOpenScreen);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // InheritedWidget lookup is safe ONLY here (and in build()).
    // Guard ensures single initialization:
    // didChangeDependencies() is called by Flutter multiple times
    // (theme change, locale change, etc.) — without guard PageController
    // would be created repeatedly.
    if (!_didInitDeps) {
      _didInitDeps = true;

      final s = context.settings;
      _settings = s;
      _cameraOn = s.showCameraTab;
      _i = _navIndex(widget.initialScreen.clamp(0, 5));
      _pageController = PageController(initialPage: _i);
      s.addListener(_onSettingsChanged);
    }
  }

  @override
  void dispose() {
    openScreen.removeListener(_onOpenScreen);
    if (_didInitDeps) {
      _settings?.removeListener(_onSettingsChanged);
      _pageController?.dispose();
      _pageController = null;
    }
    super.dispose();
  }

  int _navIndex(int logical) =>
      (!_cameraOn && logical >= 1) ? logical - 1 : logical;

  void _onSettingsChanged() {
    if (!mounted || !_didInitDeps) return;
    final s = _settings;
    if (s == null) return;

    final on = s.showCameraTab;
    if (on == _cameraOn) {
      setState(() {});
      return;
    }

    final old = _i;
    final int neu;
    if (_cameraOn && !on) {
      neu = old == 1 ? 0 : (old > 1 ? old - 1 : old);
    } else {
      neu = old >= 1 ? old + 1 : old;
    }

    setState(() {
      _cameraOn = on;
      _i = neu;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pc = _pageController;
      if (mounted && pc != null && pc.hasClients) {
        pc.jumpToPage(neu);
      }
    });
  }

  void _onOpenScreen() {
    final t = openScreen.value;
    if (t == null) return;
    openScreen.value = null;
    if (!mounted || !_didInitDeps) return;
    if (t == 1 && !_cameraOn) return;
    _navigateTo(_navIndex(t.clamp(0, 5)), animate: true);
  }

  void _navigateTo(int index, {required bool animate}) {
    if (!mounted || !_didInitDeps) return;
    if (index == _i) return;
    setState(() => _i = index);

    final pc = _pageController;
    if (pc == null || !pc.hasClients) return;
    if (animate) {
      pc.animateToPage(index, duration: _animDuration, curve: _animCurve);
    } else {
      pc.jumpToPage(index);
    }
  }

  void _onPageChanged(int index) {
    if (index == _i) return;
    setState(() => _i = index);
  }

  @override
  Widget build(BuildContext context) {
    // Render empty until didChangeDependencies() completes.
    final pc = _pageController;
    if (!_didInitDeps || pc == null) {
      return const SizedBox.shrink();
    }

    final c = context.c;
    final l10n = context.l10n;

    final items = <NavItem>[
      NavItem(Icons.translate_rounded, l10n.t('nav_translate')),
      if (_cameraOn) NavItem(Icons.photo_camera_rounded, l10n.t('nav_camera')),
      NavItem(Icons.menu_book_rounded, l10n.t('nav_phrasebook')),
      NavItem(Icons.style_rounded, l10n.t('nav_flashcards')),
      NavItem(Icons.history_rounded, l10n.t('nav_history')),
      NavItem(Icons.person_outline_rounded, l10n.t('nav_profile')),
    ];

    final current = _i.clamp(0, items.length - 1);

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(
                  c: c,
                  onSettings: () => Navigator.of(context).push(
                    appRoute(
                      SettingsScreen(repo: widget.repo),
                      animate: context.settings.animationsOn,
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: pc,
                    onPageChanged: _onPageChanged,
                    physics: const PageScrollPhysics(),
                    // CRASH-FIX #5: STABLE KEYS.
                    // When camera tab is toggled, children list changes.
                    // WITHOUT keys Flutter reuses State BY POSITION:
                    // State of one screen gets disposed (along with its
                    // TextEditingController) while TextField animation
                    // still listens to it → "used after being disposed".
                    // WITH keys State travels along with the page.
                    children: [
                      _KeepAlivePage(
                        key: const ValueKey('page_translate'),
                        child: TranslateScreen(
                          repo: widget.repo,
                          incomingText: widget.incomingText,
                        ),
                      ),
                      if (_cameraOn)
                        const _KeepAlivePage(
                          key: ValueKey('page_camera'),
                          child: CameraScreen(),
                        ),
                      const _KeepAlivePage(
                        key: ValueKey('page_phrasebook'),
                        child: PhrasebookScreen(),
                      ),
                      _KeepAlivePage(
                        key: const ValueKey('page_flashcards'),
                        child: FlashcardsScreen(repo: widget.repo),
                      ),
                      _KeepAlivePage(
                        key: const ValueKey('page_history'),
                        child: HistoryScreen(repo: widget.repo),
                      ),
                      _KeepAlivePage(
                        key: const ValueKey('page_profile'),
                        child: ProfileScreen(repo: widget.repo),
                      ),
                    ],
                  ),
                ),
                NeonBottomNav(
                  index: current,
                  onTap: (v) => _navigateTo(v, animate: true),
                  items: items,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({super.key, required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _TopBar extends StatelessWidget {
  final AppColors c;
  final VoidCallback onSettings;
  const _TopBar({required this.c, required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 12, 0),
        child: Row(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Köp',
                    style: AppTheme.logo(size: 24, color: c.text),
                  ),
                  TextSpan(
                    text: 'ri',
                    style: AppTheme.logo(size: 24, color: c.accent),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Material(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onSettings,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.line),
                  ),
                  child: Icon(Icons.settings_rounded, color: c.sub, size: 21),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
