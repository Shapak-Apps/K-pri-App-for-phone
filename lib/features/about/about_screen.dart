import 'package:flutter/material.dart';

import '../../core/controllers/app_settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'about_authors_screen.dart';
import 'about_strings.dart';
import 'sapak_series_screen.dart';

class AboutEntryCard extends StatelessWidget {
  const AboutEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = AboutStrings(context.settings.lang.name);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                c.accent.withValues(alpha: 0.16),
                c.accentHi.withValues(alpha: 0.10),
                c.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: c.accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c.accent, c.accentDeep]),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.appAbout,
                      style: TextStyle(
                        color: c.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Köpri · v1.0.2',
                      style: AppTheme.caption(color: c.faint, size: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.sub, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Widget _stagger(double start, Widget child) {
    final a = CurvedAnimation(
      parent: _enter,
      curve: Interval(
        start,
        (start + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return AnimatedBuilder(
      animation: a,
      builder: (_, __) => Opacity(
        opacity: a.value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - a.value)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = AboutStrings(context.settings.lang.name);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.appAbout,
          style: AppTheme.display(size: 18, color: c.text),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const SizedBox(height: 12),
          _stagger(
            0.05,
            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _stagger(
            0.15,
            Center(
              child: Text(
                'Köpri',
                style: TextStyle(
                  color: c.text,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _stagger(
            0.22,
            Center(
              child: Text(
                '${t.versionLabel} 1.0.2',
                style: AppTheme.caption(color: c.faint, size: 13),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _stagger(
            0.32,
            _NavCard(
              c: c,
              icon: Icons.groups_rounded,
              tint: c.accent,
              title: t.authorsTitle,
              subtitle: t.authorsSub,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutAuthorsScreen()),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _stagger(
            0.42,
            _NavCard(
              c: c,
              icon: Icons.apps_rounded,
              tint: c.accentHi,
              title: t.seriesTitle,
              subtitle: t.seriesSub,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SapakSeriesScreen()),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _stagger(
            0.52,
            Center(
              child: Text(
                t.copyright,
                style: AppTheme.caption(color: c.faint, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavCard({
    required this.c,
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: tint, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTheme.caption(color: c.faint, size: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.sub, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
