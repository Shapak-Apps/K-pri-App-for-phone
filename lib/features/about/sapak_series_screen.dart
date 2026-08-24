import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/controllers/app_settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'about_strings.dart';
import 'widgets/about_widgets.dart';

class SapakSeriesScreen extends StatefulWidget {
  const SapakSeriesScreen({super.key});
  @override
  State<SapakSeriesScreen> createState() => _SapakSeriesScreenState();
}

class _SapakSeriesScreenState extends State<SapakSeriesScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.seriesTitle,
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
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                      color: c.accentHi.withValues(alpha: 0.3),
                      blurRadius: 26,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: Image.asset(
                    'assets/about/sapak_dark.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _stagger(
            0.15,
            _InfoCard(
              c: c,
              icon: Icons.info_outline_rounded,
              tint: c.accent,
              title: t.aboutSeriesTitle,
              text: t.aboutSeriesText,
            ),
          ),
          const SizedBox(height: 14),
          _stagger(
            0.25,
            _InfoCard(
              c: c,
              icon: Icons.public_rounded,
              tint: const Color(0xFF10B981),
              title: t.forAllTitle,
              text: t.forAllText,
            ),
          ),
          const SizedBox(height: 14),
          _stagger(0.35, _KopriCard(c: c, t: t, dark: dark)),
          const SizedBox(height: 14),
          _stagger(
            0.5,
            _InfoCard(
              c: c,
              icon: Icons.schedule_rounded,
              tint: const Color(0xFF8B5CF6),
              title: t.nextTitle,
              text: t.nextText,
            ),
          ),
          const SizedBox(height: 14),
          _stagger(0.6, _ContactCard(c: c, t: t)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final Color tint;
  final String title;
  final String text;

  const _InfoCard({
    required this.c,
    required this.icon,
    required this.tint,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: tint, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: c.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: c.sub, fontSize: 13, height: 1.6)),
        ],
      ),
    );
  }
}

class _KopriCard extends StatelessWidget {
  final AppColors c;
  final AboutStrings t;
  final bool dark;

  const _KopriCard({required this.c, required this.t, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              dark
                  ? 'assets/about/about_dark.png'
                  : 'assets/about/about_light.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  color: c.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Köpri',
                style: TextStyle(
                  color: c.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            t.kopriText,
            style: TextStyle(color: c.sub, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: c.accentHi.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.apps_rounded, color: c.accentHi, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                t.featuresTitle,
                style: TextStyle(
                  color: c.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FeatureRow(
            c: c,
            icon: Icons.menu_book_rounded,
            text: t.featPhrasebook,
            soon: false,
          ),
          const SizedBox(height: 8),
          _FeatureRow(
            c: c,
            icon: Icons.translate_rounded,
            text: t.featText,
            soon: false,
          ),
          const SizedBox(height: 8),
          _FeatureRow(
            c: c,
            icon: Icons.style_rounded,
            text: t.featCardLearning,
            soon: false,
          ),
          const SizedBox(height: 8),
          _FeatureRow(
            c: c,
            icon: Icons.content_paste_rounded,
            text: t.featBuffer,
            soon: false,
          ),
          const SizedBox(height: 8),
          _FeatureRow(
            c: c,
            icon: Icons.mic_rounded,
            text: t.featMicrophone,
            soon: true,
            soonText: t.soon,
          ),
          const SizedBox(height: 8),
          _FeatureRow(
            c: c,
            icon: Icons.camera_alt_rounded,
            text: t.featCamera,
            soon: true,
            soonText: t.soon,
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String text;
  final bool soon;
  final String? soonText;

  const _FeatureRow({
    required this.c,
    required this.icon,
    required this.text,
    required this.soon,
    this.soonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.bgSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: c.accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: c.text,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (soon) SoonBadge(color: c.warn, text: soonText ?? 'Soon'),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final AppColors c;
  final AboutStrings t;

  const _ContactCard({required this.c, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                t.contactTitle,
                style: TextStyle(
                  color: c.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ContactRow(
            c: c,
            icon: Icons.mail_outline_rounded,
            label: 'shapak.apps@gmail.com',
            url: 'mailto:shapak.apps@gmail.com',
          ),
          const SizedBox(height: 8),
          _ContactRow(
            c: c,
            icon: Icons.telegram_rounded,
            label: '@kopri_support_bot',
            url: 'https://t.me/kopri_support_bot',
          ),
          const SizedBox(height: 8),
          _ContactRow(
            c: c,
            icon: Icons.code_rounded,
            label: t.orgGithub,
            url: 'https://github.com/Shapak-Apps',
            useGithubIcon: true,
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String label;
  final String url;
  final bool useGithubIcon;

  const _ContactRow({
    required this.c,
    required this.icon,
    required this.label,
    required this.url,
    this.useGithubIcon = false,
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              if (useGithubIcon)
                GitHubIcon(size: 20, color: c.accent)
              else
                Icon(icon, color: c.accent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: c.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_rounded, size: 16, color: c.accent),
            ],
          ),
        ),
      ),
    );
  }
}
