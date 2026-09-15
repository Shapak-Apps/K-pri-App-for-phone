import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  static const String _githubUrl =
      'https://github.com/Shapak-Apps/K-pri-App-for-phone';

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

  Future<void> _openGithub() async {
    final uri = Uri.parse(_githubUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open GitHub'),
            backgroundColor: context.c.accent,
          ),
        );
      }
    }
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
          const SizedBox(height: 14),
          _stagger(
            0.52,
            _OpenSourceCard(
              c: c,
              title: t.openSourceTitle,
              subtitle: t.openSourceSub,
              buttonLabel: t.openSourceButton,
              onTap: _openGithub,
            ),
          ),
          const SizedBox(height: 32),
          _stagger(
            0.62,
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

class _GitBranchIcon extends StatefulWidget {
  final double size;
  final Color color;

  const _GitBranchIcon({required this.size, required this.color});

  @override
  State<_GitBranchIcon> createState() => _GitBranchIconState();
}

class _GitBranchIconState extends State<_GitBranchIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _GitBranchPainter(
            color: widget.color,
            pulseValue: _pulse.value,
          ),
        );
      },
    );
  }
}

class _GitBranchPainter extends CustomPainter {
  final Color color;
  final double pulseValue;

  _GitBranchPainter({required this.color, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;

    final glow = Paint()
      ..color = color.withValues(alpha: 0.22 * (1 - pulseValue))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.drawCircle(
      Offset(12 * s, 12 * s),
      size.width * 0.62 * (0.75 + pulseValue * 0.45),
      glow,
    );

    final trunk = Path();
    trunk.moveTo(7.0 * s, 6.4 * s);
    trunk.lineTo(7.0 * s, 21.0 * s);
    canvas.drawPath(trunk, stroke);

    final branch = Path();
    branch.moveTo(16.0 * s, 8.0 * s);
    branch.lineTo(16.0 * s, 11.0 * s);
    branch.cubicTo(16.0 * s, 14.2 * s, 14.2 * s, 15.6 * s, 11.2 * s, 15.6 * s);
    branch.lineTo(7.0 * s, 15.6 * s);
    canvas.drawPath(branch, stroke);

    canvas.drawCircle(Offset(7.0 * s, 4.5 * s), 2.1 * s, stroke);
    canvas.drawCircle(Offset(16.0 * s, 6.0 * s), 2.1 * s, stroke);
  }

  @override
  bool shouldRepaint(covariant _GitBranchPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}

class _GithubLogo extends StatelessWidget {
  final double size;
  final Color color;

  const _GithubLogo({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GithubPainter(color: color),
    );
  }
}

class _GithubPainter extends CustomPainter {
  final Color color;
  _GithubPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    final s = size.width / 24.0;
    path.moveTo(12 * s, 0 * s);
    path.cubicTo(5.37 * s, 0 * s, 0 * s, 5.37 * s, 0 * s, 12 * s);
    path.cubicTo(
      0 * s,
      17.31 * s,
      3.435 * s,
      21.795 * s,
      8.205 * s,
      23.385 * s,
    );
    path.cubicTo(
      8.805 * s,
      23.49 * s,
      9.03 * s,
      23.13 * s,
      9.03 * s,
      22.815 * s,
    );
    path.cubicTo(
      9.03 * s,
      22.53 * s,
      9.015 * s,
      21.585 * s,
      9.015 * s,
      20.58 * s,
    );
    path.cubicTo(6 * s, 21.135 * s, 5.22 * s, 19.845 * s, 4.98 * s, 19.17 * s);
    path.cubicTo(
      4.845 * s,
      18.825 * s,
      4.26 * s,
      17.76 * s,
      3.75 * s,
      17.475 * s,
    );
    path.cubicTo(
      3.33 * s,
      17.25 * s,
      2.73 * s,
      16.695 * s,
      3.735 * s,
      16.68 * s,
    );
    path.cubicTo(
      4.68 * s,
      16.665 * s,
      5.355 * s,
      17.55 * s,
      5.58 * s,
      17.91 * s,
    );
    path.cubicTo(
      6.66 * s,
      19.725 * s,
      8.385 * s,
      19.215 * s,
      9.075 * s,
      18.9 * s,
    );
    path.cubicTo(
      9.18 * s,
      18.12 * s,
      9.495 * s,
      17.595 * s,
      9.84 * s,
      17.295 * s,
    );
    path.cubicTo(
      7.17 * s,
      16.995 * s,
      4.38 * s,
      15.96 * s,
      4.38 * s,
      11.37 * s,
    );
    path.cubicTo(
      4.38 * s,
      10.065 * s,
      4.845 * s,
      8.985 * s,
      5.61 * s,
      8.145 * s,
    );
    path.cubicTo(5.49 * s, 7.845 * s, 5.07 * s, 6.615 * s, 5.73 * s, 4.965 * s);
    path.cubicTo(5.73 * s, 4.965 * s, 6.735 * s, 4.65 * s, 9.03 * s, 6.18 * s);
    path.cubicTo(
      9.99 * s,
      5.91 * s,
      11.01 * s,
      5.775 * s,
      12.03 * s,
      5.775 * s,
    );
    path.cubicTo(
      13.05 * s,
      5.775 * s,
      14.07 * s,
      5.91 * s,
      15.03 * s,
      6.18 * s,
    );
    path.cubicTo(
      17.325 * s,
      4.62 * s,
      18.33 * s,
      4.965 * s,
      18.33 * s,
      4.965 * s,
    );
    path.cubicTo(
      18.99 * s,
      6.615 * s,
      18.57 * s,
      7.845 * s,
      18.45 * s,
      8.145 * s,
    );
    path.cubicTo(
      19.215 * s,
      8.985 * s,
      19.68 * s,
      10.05 * s,
      19.68 * s,
      11.37 * s,
    );
    path.cubicTo(
      19.68 * s,
      15.975 * s,
      16.875 * s,
      16.995 * s,
      14.205 * s,
      17.295 * s,
    );
    path.cubicTo(
      14.64 * s,
      17.67 * s,
      15.015 * s,
      18.39 * s,
      15.015 * s,
      19.515 * s,
    );
    path.cubicTo(15.015 * s, 21.12 * s, 15 * s, 22.41 * s, 15 * s, 22.815 * s);
    path.cubicTo(
      15 * s,
      23.13 * s,
      15.225 * s,
      23.505 * s,
      15.825 * s,
      23.385 * s,
    );
    path.cubicTo(20.565 * s, 21.795 * s, 24 * s, 17.31 * s, 24 * s, 12 * s);
    path.cubicTo(24 * s, 5.37 * s, 18.63 * s, 0 * s, 12 * s, 0 * s);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OpenSourceCard extends StatelessWidget {
  final AppColors c;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  const _OpenSourceCard({
    required this.c,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.surfaceHi, c.surface],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.accent.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c.accent, c.accentDeep]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _GitBranchIcon(size: 24, color: Colors.white),
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
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTheme.caption(color: c.sub, size: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [c.accent, c.accentDeep]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: c.accent.withValues(alpha: 0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _GithubLogo(size: 20, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          buttonLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
