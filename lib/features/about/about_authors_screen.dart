import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/controllers/app_settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'about_strings.dart';
import 'widgets/about_widgets.dart';

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
  static const _telegram = 'https://t.me/kopri_support_bot';

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
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
          t.authorsTitle,
          style: AppTheme.display(size: 18, color: c.text),
        ),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: c.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _stagger(
            0.05,
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
          _stagger(0.2, _OrgCard(c: c, t: t)),
          const SizedBox(height: 16),
          _stagger(0.35, _MissionCard(c: c, t: t, heart: _heart)),
          const SizedBox(height: 16),
          _stagger(0.5, _TelegramCard(c: c, t: t)),
          const SizedBox(height: 16),
          _stagger(0.65, _GmailCard(c: c, t: t)),
        ],
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

  const _AuthorCard({
    required this.c,
    required this.icon,
    required this.role,
    required this.name,
    required this.handle,
    required this.url,
    required this.tint,
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
                    Text(
                      name,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _GithubChip(c: c, handle: handle, url: url, tint: tint),
        ],
      ),
    );
  }
}

class _OrgCard extends StatelessWidget {
  final AppColors c;
  final AboutStrings t;
  const _OrgCard({required this.c, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.location_city_rounded, color: c.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              t.orgText,
              style: TextStyle(
                color: c.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final AppColors c;
  final AboutStrings t;
  final Animation<double> heart;
  const _MissionCard({required this.c, required this.t, required this.heart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.accentHi.withValues(alpha: 0.14), c.surface],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.accentHi.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BeatingHeart(color: c.accentHi, animation: heart),
              const SizedBox(width: 10),
              Text(
                t.missionTitle,
                style: TextStyle(
                  color: c.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            t.missionText,
            style: TextStyle(color: c.sub, fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _TelegramCard extends StatelessWidget {
  final AppColors c;
  final AboutStrings t;
  const _TelegramCard({required this.c, required this.t});

  static const _telegram = 'https://t.me/kopri_support_bot';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          try {
            await launchUrl(
              Uri.parse(_telegram),
              mode: LaunchMode.externalApplication,
            );
          } catch (_) {}
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                c.accentDeep.withValues(alpha: 0.95),
                c.accent.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: c.accent.withValues(alpha: 0.3),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.telegram_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.telegram,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GmailCard extends StatelessWidget {
  final AppColors c;
  final AboutStrings t;
  const _GmailCard({required this.c, required this.t});

  static const _email = 'shapak.apps@gmail.com';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          try {
            await launchUrl(Uri.parse('mailto:$_email'));
          } catch (_) {}
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.line),
            boxShadow: [
              BoxShadow(
                color: c.accent.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      c.accent.withValues(alpha: 0.90),
                      c.accentDeep.withValues(alpha: 0.80),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.mail_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.supportTitle,
                      style: TextStyle(
                        color: c.faint,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _email,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new_rounded, size: 14, color: c.sub),
            ],
          ),
        ),
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
