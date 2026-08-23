import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class AboutAuthorsCard extends StatelessWidget {
  const AboutAuthorsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = _Strings(context.settings.lang.name);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AboutAuthorsScreen())),
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [c.accent, c.accentDeep],
                      ),
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
                  Positioned(
                    right: -8,
                    bottom: -4,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [c.accentHi, c.accent],
                        ),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: c.surface, width: 2),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: TextStyle(
                        color: c.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      t.teamSub,
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

class AboutAuthorsScreen extends StatefulWidget {
  const AboutAuthorsScreen({super.key});
  @override
  State<AboutAuthorsScreen> createState() => _AboutAuthorsScreenState();
}

class _AboutAuthorsScreenState extends State<AboutAuthorsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _heart;

  static const _mobileGithub = 'https://github.com/aynazar-sylyyew-dev/';
  static const _webGithub = 'https://github.com/annayev-dev/';
  static const _telegram = 'https://t.me/kopri_support_bot';

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _heart = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _enter.dispose();
    _heart.dispose();
    super.dispose();
  }

  Widget _stagger(double start, Widget child) {
    final a = CurvedAnimation(
      parent: _enter,
      curve: Interval(
        start,
        (start + 0.45).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return AnimatedBuilder(
      animation: a,
      builder: (_, __) => Opacity(
        opacity: a.value,
        child: Transform.translate(
          offset: Offset(0, 26 * (1 - a.value)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final lang = context.settings.lang.name;
    final t = _Strings(lang);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: c.bg,
            foregroundColor: c.text,
            elevation: 0,
            pinned: true,
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
              title: Text(
                t.title,
                style: AppTheme.display(size: 18, color: c.text),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          c.accent.withValues(alpha: 0.20),
                          c.accentHi.withValues(alpha: 0.10),
                          c.bg,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -50,
                    top: -40,
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            c.accent.withValues(alpha: 0.28),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -60,
                    bottom: 10,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            c.accentHi.withValues(alpha: 0.20),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0.85, -0.2),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [c.accent, c.accentHi],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: c.accent.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _stagger(
                  0.03,
                  _HeroImage(
                    asset: dark
                        ? 'assets/about/about_dark.png'
                        : 'assets/about/about_light.png',
                    c: c,
                  ),
                ),
                const SizedBox(height: 20),
                _stagger(0.12, _AboutProject(c: c, t: t)),
                const SizedBox(height: 20),
                _stagger(0.20, _StatsSection(c: c, t: t)),
                const SizedBox(height: 20),
                _stagger(0.28, _TechStack(c: c, t: t)),
                const SizedBox(height: 20),
                _stagger(
                  0.36,
                  _AuthorCard(
                    c: c,
                    icon: Icons.phone_android_rounded,
                    role: t.mobileDev.toUpperCase(),
                    name: 'Aýnazar Sylyýew',
                    handle: '@aynazar-sylyyew-dev',
                    url: _mobileGithub,
                    tint: c.accent,
                  ),
                ),
                const SizedBox(height: 16),
                _stagger(
                  0.44,
                  _AuthorCard(
                    c: c,
                    icon: Icons.language_rounded,
                    role: t.webDev.toUpperCase(),
                    name: 'Annaýew Döwlet',
                    handle: '@annayev-dev',
                    url: _webGithub,
                    tint: c.accentHi,
                    thanks: t.thanksWeb,
                    heart: _heart,
                  ),
                ),
                const SizedBox(height: 20),
                _stagger(0.52, _Timeline(c: c, t: t)),
                const SizedBox(height: 20),
                _stagger(0.60, _ContactCard(c: c, t: t)),
                const SizedBox(height: 20),
                _stagger(0.68, _FunFacts(c: c, t: t)),
                const SizedBox(height: 24),
                _stagger(0.76, _Footer(c: c, t: t, heart: _heart)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutProject extends StatelessWidget {
  final AppColors c;
  final _Strings t;
  const _AboutProject({required this.c, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.accent.withValues(alpha: 0.14), c.surface],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c.accent, c.accentDeep]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                t.aboutProject,
                style: TextStyle(
                  color: c.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            t.projectDesc,
            style: TextStyle(color: c.sub, fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final AppColors c;
  final _Strings t;
  const _StatsSection({required this.c, required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            t.stats,
            style: TextStyle(
              color: c.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                c: c,
                icon: Icons.translate_rounded,
                number: '50+',
                label: t.languages,
                color: c.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                c: c,
                icon: Icons.code_rounded,
                number: '15K',
                label: t.linesOfCode,
                color: c.accentHi,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                c: c,
                icon: Icons.speed_rounded,
                number: '0.3s',
                label: t.ocrSpeed,
                color: c.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                c: c,
                icon: Icons.offline_bolt_rounded,
                number: '95%',
                label: t.offline,
                color: c.accentHi,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String number;
  final String label;
  final Color color;
  const _StatCard({
    required this.c,
    required this.icon,
    required this.number,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            number,
            style: TextStyle(
              color: c.text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.caption(color: c.faint, size: 11)),
        ],
      ),
    );
  }
}

class _TechStack extends StatelessWidget {
  final AppColors c;
  final _Strings t;
  const _TechStack({required this.c, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.build_rounded, color: c.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                t.techStack,
                style: TextStyle(
                  color: c.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TechChip(c: c, name: 'Flutter', color: const Color(0xFF02569B)),
              _TechChip(c: c, name: 'Dart', color: const Color(0xFF0175C2)),
              _TechChip(c: c, name: 'C++', color: const Color(0xFF00599C)),
              _TechChip(c: c, name: 'ML Kit', color: c.accent),
              _TechChip(c: c, name: 'Tesseract', color: c.accentHi),
              _TechChip(c: c, name: 'Hive', color: const Color(0xFFFF8F00)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final AppColors c;
  final String name;
  final Color color;
  const _TechChip({required this.c, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final AppColors c;
  final _Strings t;
  const _Timeline({required this.c, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.accentHi.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  color: c.accentHi,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                t.journey,
                style: TextStyle(
                  color: c.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _TimelineItem(
            c: c,
            year: '2025',
            title: t.timeline2025,
            icon: Icons.rocket_launch_rounded,
            active: true,
          ),
          _TimelineItem(
            c: c,
            year: '2026',
            title: t.timeline2026,
            icon: Icons.update_rounded,
          ),
          _TimelineItem(
            c: c,
            year: t.future,
            title: t.timelineFuture,
            icon: Icons.auto_awesome_rounded,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final AppColors c;
  final String year;
  final String title;
  final IconData icon;
  final bool active;
  final bool isLast;
  const _TimelineItem({
    required this.c,
    required this.year,
    required this.title,
    required this.icon,
    this.active = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? c.accent : c.faint;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 24,
                  color: color.withValues(alpha: 0.3),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    year,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      color: c.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final AppColors c;
  final _Strings t;
  static const String _telegram = 'https://t.me/kopri_support_bot';
  const _ContactCard({required this.c, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.accentDeep.withValues(alpha: 0.95),
            c.accent.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.contact,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            t.contactDesc,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                try {
                  await launchUrl(
                    Uri.parse(_telegram),
                    mode: LaunchMode.externalApplication,
                  );
                } catch (_) {}
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.telegram_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      t.telegram,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FunFacts extends StatelessWidget {
  final AppColors c;
  final _Strings t;
  const _FunFacts({required this.c, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: c.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                t.funFacts,
                style: TextStyle(
                  color: c.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FactItem(c: c, text: t.fact1),
          const SizedBox(height: 12),
          _FactItem(c: c, text: t.fact2),
        ],
      ),
    );
  }
}

class _FactItem extends StatelessWidget {
  final AppColors c;
  final String text;
  const _FactItem({required this.c, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: c.sub, fontSize: 12.5, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatefulWidget {
  final String asset;
  final AppColors c;
  const _HeroImage({required this.asset, required this.c});
  @override
  State<_HeroImage> createState() => _HeroImageState();
}

class _HeroImageState extends State<_HeroImage> {
  double _ratio = 16 / 9;

  @override
  void initState() {
    super.initState();
    AssetImage(widget.asset)
        .resolve(ImageConfiguration.empty)
        .addListener(
          ImageStreamListener((image, _) {
            if (mounted)
              setState(() => _ratio = image.image.width / image.image.height);
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: c.accent.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: 0.25),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: _ratio,
          child: Image.asset(widget.asset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _AuthorCard extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String role;
  final String name;
  final String handle;
  final String url;
  final Color tint;
  final String? thanks;
  final Animation<double>? heart;

  const _AuthorCard({
    required this.c,
    required this.icon,
    required this.role,
    required this.name,
    required this.handle,
    required this.url,
    required this.tint,
    this.thanks,
    this.heart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint.withValues(alpha: 0.16), c.surface],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tint.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [tint, tint.withValues(alpha: 0.55)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: tint.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role,
                      style: TextStyle(
                        color: tint,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              color: c.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (heart != null)
                          _BeatingHeart(color: tint, animation: heart!),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (thanks != null) ...[
            const SizedBox(height: 12),
            Text(
              thanks!,
              style: TextStyle(
                color: c.sub,
                fontSize: 12.5,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 14),
          _GithubChip(c: c, handle: handle, url: url, tint: tint),
        ],
      ),
    );
  }
}

class _GithubChip extends StatelessWidget {
  final AppColors c;
  final String handle;
  final String url;
  final Color tint;
  const _GithubChip({
    required this.c,
    required this.handle,
    required this.url,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          try {
            await launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            );
          } catch (_) {}
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tint.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GitHubIcon(size: 18, color: tint),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  handle,
                  style: TextStyle(
                    color: tint,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.open_in_new_rounded,
                size: 14,
                color: tint.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BeatingHeart extends StatelessWidget {
  final Color color;
  final Animation<double> animation;
  const _BeatingHeart({required this.color, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final t = animation.value;
        double beat;
        if (t < 0.18) {
          beat = Curves.easeOut.transform(t / 0.18);
        } else if (t < 0.36) {
          beat = 1 - Curves.easeIn.transform((t - 0.18) / 0.18);
        } else if (t < 0.54) {
          beat = 0.65 * Curves.easeOut.transform((t - 0.36) / 0.18);
        } else if (t < 0.72) {
          beat = 0.65 * (1 - Curves.easeIn.transform((t - 0.54) / 0.18));
        } else {
          beat = 0.0;
        }
        final s = 1.0 + 0.30 * beat;
        return Transform.scale(
          scale: s,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12 + 0.15 * beat),
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: color,
              size: 18,
              shadows: [
                Shadow(
                  color: color.withValues(alpha: 0.2 + 0.6 * beat),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  final AppColors c;
  final _Strings t;
  final Animation<double> heart;
  const _Footer({required this.c, required this.t, required this.heart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                c.accent.withValues(alpha: 0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _BeatingHeart(color: c.accentHi, animation: heart),
            const SizedBox(width: 10),
            Text(
              t.motto,
              style: TextStyle(
                color: c.sub,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Köpri · 2026', style: AppTheme.caption(color: c.faint, size: 11)),
      ],
    );
  }
}

class GitHubIcon extends StatelessWidget {
  final double size;
  final Color color;
  const GitHubIcon({required this.size, required this.color});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _GitHubPainter(color, size));
}

class _GitHubPainter extends CustomPainter {
  final Color color;
  final double size;
  _GitHubPainter(this.color, this.size);

  static final Path _path = _parseSvg(
    'M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.012 8.012 0 0 0 16 8c0-4.42-3.58-8-8-8z',
  );

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.scale(size / 16.0);
    canvas.drawPath(
      _path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GitHubPainter old) => old.color != color;
}

Path _parseSvg(String d) {
  final tokens = RegExp(
    r'[MmCcAaZzLl]|[-+]?(?:\d+\.\d+|\.\d+|\d+)',
  ).allMatches(d).map((m) => m.group(0)!).toList();
  final path = Path();
  var i = 0;
  double cx = 0, cy = 0, sx = 0, sy = 0;
  var cmd = '';
  double n() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    final t = tokens[i];
    if (RegExp(r'[A-Za-z]').hasMatch(t)) {
      cmd = t;
      i++;
      if (cmd == 'Z' || cmd == 'z') {
        path.close();
        cx = sx;
        cy = sy;
        cmd = '';
      }
      continue;
    }
    switch (cmd) {
      case 'M':
        cx = n();
        cy = n();
        path.moveTo(cx, cy);
        sx = cx;
        sy = cy;
        cmd = 'L';
      case 'L':
        cx = n();
        cy = n();
        path.lineTo(cx, cy);
      case 'C':
        final x1 = n(), y1 = n(), x2 = n(), y2 = n();
        cx = n();
        cy = n();
        path.cubicTo(x1, y1, x2, y2, cx, cy);
      case 'c':
        final x1 = n(), y1 = n(), x2 = n(), y2 = n(), dx = n(), dy = n();
        path.cubicTo(cx + x1, cy + y1, cx + x2, cy + y2, cx + dx, cy + dy);
        cx += dx;
        cy += dy;
      case 'A':
        final rx = n(), ry = n(), rot = n(), la = n(), sf = n();
        final x = n(), y = n();
        path.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rot,
          largeArc: la == 1,
          clockwise: sf == 1,
        );
        cx = x;
        cy = y;
      default:
        i++;
    }
  }
  return path;
}

class _Strings {
  final String lang;
  const _Strings(this.lang);

  String get title => switch (lang) {
    'ru' => 'Об авторах',
    'tk' => 'Awtorlar barada',
    'tr' => 'Yazarlar hakkında',
    _ => 'About the Authors',
  };

  String get teamSub => switch (lang) {
    'ru' => 'Команда, создавшая Köpri',
    'tk' => 'Köpri döreden topar',
    'tr' => "Köpri'yi oluşturan ekip",
    _ => 'The team behind Köpri',
  };

  String get aboutProject => switch (lang) {
    'ru' => 'О проекте Köpri',
    'tk' => 'Köpri taslamasy barada',
    'tr' => "Köpri projesi hakkında",
    _ => 'About Köpri Project',
  };

  String get projectDesc => switch (lang) {
    'ru' =>
      'Köpri — это бесплатный оффлайн-переводчик с гибридным OCR через камеру, огромным разговорником и поддержкой 50+ языков. Создан командой из двух разработчиков с целью разрушить языковые барьеры и сделать общение доступным для всех.',
    'tk' =>
      'Köpri — bu kamera arkaly gibrid OCR, uly gepleşik kitaby we 50+ dili goldaýan mugt oflaýn terjimeçi. Dil päsgelçiliklerini ýok etmek we aragatnaşygy hemmeler üçin elýeterli etmek maksady bilen iki programmistden ybarat topar tarapyndan döredildi.',
    'tr' =>
      "Köpri, kamera üzerinden hibrit OCR, kapsamlı bir konuşma kılavuzu ve 50'den fazla dil desteği sunan ücretsiz çevrimdışı bir çevirmendir. Dil engellerini ortadan kaldırmak ve iletişimi herkes için erişilebilir kılmak amacıyla iki geliştiriciden oluşan bir ekip tarafından oluşturuldu.",
    _ =>
      "Köpri is a free offline translator with hybrid camera OCR, a comprehensive phrasebook, and support for 50+ languages. Created by a team of two developers with the goal of breaking language barriers and making communication accessible to everyone.",
  };

  String get stats => switch (lang) {
    'ru' => 'Köpri в цифрах',
    'tk' => 'Köpri sanlarda',
    'tr' => "Köpri rakamlarla",
    _ => 'Köpri in Numbers',
  };

  String get languages => switch (lang) {
    'ru' => 'Языков',
    'tk' => 'Diller',
    'tr' => 'Diller',
    _ => 'Languages',
  };

  String get linesOfCode => switch (lang) {
    'ru' => 'Строк кода',
    'tk' => 'Kod setirleri',
    'tr' => 'Kod satırları',
    _ => 'Lines of Code',
  };

  String get ocrSpeed => switch (lang) {
    'ru' => 'Скорость OCR',
    'tk' => 'OCR tizligi',
    'tr' => 'OCR hızı',
    _ => 'OCR Speed',
  };

  String get offline => switch (lang) {
    'ru' => 'Оффлайн',
    'tk' => 'Oflaýn',
    'tr' => 'Çevrimdışı',
    _ => 'Offline',
  };

  String get techStack => switch (lang) {
    'ru' => 'Технологии',
    'tk' => 'Tehnologiýalar',
    'tr' => 'Teknolojiler',
    _ => 'Technologies',
  };

  String get journey => switch (lang) {
    'ru' => 'Наш путь',
    'tk' => 'Biziň ýolumyz',
    'tr' => 'Yolculuğumuz',
    _ => 'Our Journey',
  };

  String get timeline2025 => switch (lang) {
    'ru' => 'Запуск проекта и первая версия',
    'tk' => 'Taslamanyň başlangyjy we birinji wersiýa',
    'tr' => 'Projenin başlangıcı ve ilk sürüm',
    _ => 'Project launch and first version',
  };

  String get timeline2026 => switch (lang) {
    'ru' => 'Добавление OCR и улучшение производительности',
    'tk' => 'OCR goşuldy we öndürijilik gowulandyryldy',
    'tr' => 'OCR eklendi ve performans iyileştirildi',
    _ => 'OCR added and performance improved',
  };

  String get future => switch (lang) {
    'ru' => 'БУДУЩЕЕ',
    'tk' => 'GELEJEK',
    'tr' => 'GELECEK',
    _ => 'FUTURE',
  };

  String get timelineFuture => switch (lang) {
    'ru' => 'Мобильное приложение для iOS и веб-версия',
    'tk' => 'iOS üçin mobil programma we web wersiýasy',
    'tr' => 'iOS için mobil uygulama ve web sürümü',
    _ => 'iOS mobile app and web version',
  };

  String get contact => switch (lang) {
    'ru' => 'Связаться с нами',
    'tk' => 'Bize ýüz tutmak',
    'tr' => 'Bize ulaşın',
    _ => 'Contact Us',
  };

  String get contactDesc => switch (lang) {
    'ru' =>
      'Есть вопросы, предложения или нашли ошибку? Мы всегда рады обратной связи и готовы помочь!',
    'tk' =>
      'Soraglaryňyz, teklipleriňiz bar ýa-da ýalňyşlyk tapdyňyzmy? Biz hemişe geri bildirimden hoşal we kömäge taýýar!',
    'tr' =>
      'Sorularınız, önerileriniz var mı veya bir hata mı buldunuz? Geri bildirimden her zaman mutluyuz ve yardım etmeye hazırız!',
    _ =>
      'Have questions, suggestions, or found a bug? We always welcome feedback and are ready to help!',
  };

  String get telegram => switch (lang) {
    'ru' => 'Написать в Telegram',
    'tk' => 'Telegram-da ýazmak',
    'tr' => "Telegram'da yazın",
    _ => 'Message on Telegram',
  };

  String get funFacts => switch (lang) {
    'ru' => 'Интересные факты',
    'tk' => 'Gyzykly maglumatlar',
    'tr' => 'İlginç bilgiler',
    _ => 'Fun Facts',
  };

  String get fact1 => switch (lang) {
    'ru' =>
      'Название "Köpri" означает "мост" на туркменском — символ соединения людей через языки',
    'tk' =>
      '"Köpri" ady türkmençe "köpri" diýmekdir — adamlary diller arkaly birleşdirmegiň nyşany',
    'tr' =>
      '"Köpri" adı Türkmen dilinde "köprü" anlamına gelir — insanları diller aracılığıyla birleştirmenin sembolü',
    _ =>
      'The name "Köpri" means "bridge" in Turkmen — a symbol of connecting people through languages',
  };

  String get fact2 => switch (lang) {
    'ru' =>
      'Приложение полностью работает оффлайн — ваши данные никогда не покидают устройство',
    'tk' =>
      'Programma doly oflaýn işleýär — maglumatlaryňyz hiç haçan enjamdan çykmaýar',
    'tr' =>
      'Uygulama tamamen çevrimdışı çalışır — verileriniz asla cihazdan ayrılmaz',
    _ => 'The app works completely offline — your data never leaves the device',
  };

  String get mobileDev => switch (lang) {
    'ru' => 'Мобильная разработка',
    'tk' => 'Mobil programmalaşdyrma',
    'tr' => 'Mobil geliştirme',
    _ => 'Mobile development',
  };

  String get webDev => switch (lang) {
    'ru' => 'Веб-разработка',
    'tk' => 'Web programmalaşdyrma',
    'tr' => 'Web geliştirme',
    _ => 'Web development',
  };

  String get thanksWeb => switch (lang) {
    'ru' => 'С особой благодарностью за вклад в веб-разработку Köpri',
    'tk' => 'Köpri web ösüşine goşandy üçin aýratyn minnetdarlyk bilen',
    'tr' => "Köpri web gelişimine katkısı için özel minnetle",
    _ => 'With special gratitude for the contribution to Köpri web development',
  };

  String get motto => 'Connect • Build • Inspire';
}
