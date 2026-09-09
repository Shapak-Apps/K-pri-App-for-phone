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
  late final PageController _pageController;
  late int _i;
  static const _pageCount = 6;
  static const _animDuration = Duration(milliseconds: 260);
  static const _animCurve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();
    _i = widget.initialScreen.clamp(0, _pageCount - 1);
    _pageController = PageController(initialPage: _i);
    openScreen.addListener(_onOpenScreen);

    if (widget.initialScreen == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) CameraScreen.openTranslateCamera(context);
      });
    }
  }

  @override
  void dispose() {
    openScreen.removeListener(_onOpenScreen);
    _pageController.dispose();
    super.dispose();
  }

  void _onOpenScreen() {
    final t = openScreen.value;
    if (t == null) return;
    openScreen.value = null;
    if (!mounted) return;
    if (t >= 0 && t < _pageCount) {
      _navigateTo(t, animate: true);
    }
  }

  void _navigateTo(int index, {required bool animate}) {
    if (index == _i) return;
    setState(() => _i = index);
    if (animate) {
      _pageController.animateToPage(
        index,
        duration: _animDuration,
        curve: _animCurve,
      );
    } else {
      _pageController.jumpToPage(index);
    }
    if (index == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) CameraScreen.openTranslateCamera(context);
      });
    }
  }

  void _onPageChanged(int index) {
    if (index == _i) return;
    setState(() => _i = index);
    if (index == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) CameraScreen.openTranslateCamera(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;

    final items = <NavItem>[
      NavItem(Icons.translate_rounded, l10n.t('nav_translate')),
      NavItem(Icons.photo_camera_rounded, l10n.t('nav_camera')),
      NavItem(Icons.menu_book_rounded, l10n.t('nav_phrasebook')),
      NavItem(Icons.style_rounded, l10n.t('nav_flashcards')),
      NavItem(Icons.history_rounded, l10n.t('nav_history')),
      NavItem(Icons.person_outline_rounded, l10n.t('nav_profile')),
    ];

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 86),
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
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      physics: const PageScrollPhysics(),
                      children: [
                        _KeepAlivePage(
                          child: TranslateScreen(
                            repo: widget.repo,
                            incomingText: widget.incomingText,
                          ),
                        ),
                        const _KeepAlivePage(child: CameraScreen()),
                        const _KeepAlivePage(child: PhrasebookScreen()),
                        _KeepAlivePage(child: FlashcardsScreen(repo: widget.repo)),
                        _KeepAlivePage(child: HistoryScreen(repo: widget.repo)),
                        _KeepAlivePage(child: ProfileScreen(repo: widget.repo)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NeonBottomNav(
              index: _i,
              onTap: (v) => _navigateTo(v, animate: true),
              items: items,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

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