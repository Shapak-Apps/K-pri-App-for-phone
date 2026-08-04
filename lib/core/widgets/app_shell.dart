import 'package:flutter/material.dart';
import '../../features/camera/presentation/camera_screen.dart';
import '../../features/flashcards/presentation/flashcards_screen.dart';
import '../../features/history/data/history_repository.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/phrasebook/presentation/phrasebook_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/translate/presentation/translate_screen.dart';
import '../../main.dart';
import '../controllers/app_settings_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ambient_background.dart';
import 'app_route.dart';
import 'neon_bottom_nav.dart';
import 'package:flutter/foundation.dart';

class AppShell extends StatefulWidget {
  final HistoryRepository repo;
  final ValueListenable<IncomingText?> incomingText;
  const AppShell({super.key, required this.repo, required this.incomingText});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;

    final pages = <Widget>[
      TranslateScreen(repo: widget.repo, incomingText: widget.incomingText),
      const CameraScreen(),
      const PhrasebookScreen(),
      FlashcardsScreen(repo: widget.repo),
      HistoryScreen(repo: widget.repo),
    ];

    final items = <NavItem>[
      NavItem(Icons.translate_rounded, l10n.t('nav_translate')),
      NavItem(Icons.photo_camera_rounded, l10n.t('nav_camera')),
      NavItem(Icons.menu_book_rounded, l10n.t('nav_phrasebook')),
      NavItem(Icons.style_rounded, l10n.t('nav_flashcards')),
      NavItem(Icons.history_rounded, l10n.t('nav_history')),
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
                    child: IndexedStack(index: _i, children: pages),
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
              onTap: (v) => setState(() => _i = v),
              items: items,
            ),
          ),
        ],
      ),
    );
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
