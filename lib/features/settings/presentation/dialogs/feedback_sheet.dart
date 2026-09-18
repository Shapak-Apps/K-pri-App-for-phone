import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../settings_constants.dart';

/// "Get in touch" bottom sheet with Telegram / email actions.
Future<void> showSettingsFeedbackSheet(BuildContext context) async {
  final c = context.c;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _FeedbackSheetBody(c: c),
  );
}

Future<void> _openTelegram(BuildContext context) async {
  try {
    await launchUrl(
      Uri.parse(kTelegramUrl),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {}
}

Future<void> _openEmail(BuildContext context) async {
  try {
    await launchUrl(Uri.parse('mailto:shapak.apps@gmail.com'));
  } catch (_) {}
}

class _FeedbackSheetBody extends StatelessWidget {
  final AppColors c;
  const _FeedbackSheetBody({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0F1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      c.accent.withValues(alpha: 0.95),
                      c.accentDeep.withValues(alpha: 0.95),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withValues(alpha: 0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.feedback_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Get in Touch',
                style: AppTheme.display(
                  size: 22,
                  color: c.text,
                ).copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
              const SizedBox(height: 6),
              Text(
                'We\'d love to hear from you',
                style: AppTheme.caption(color: c.faint, size: 13),
              ),
              const SizedBox(height: 28),
              _FeedbackOption(
                c: c,
                gradient: const [Color(0xFF0088CC), Color(0xFF3B82F6)],
                icon: Icons.telegram_rounded,
                title: 'Telegram',
                subtitle: '@kopri_support_bot',
                onTap: () {
                  Navigator.pop(context);
                  _openTelegram(context);
                },
              ),
              const SizedBox(height: 12),
              _FeedbackOption(
                c: c,
                gradient: [c.accent, c.accentDeep],
                icon: Icons.mail_rounded,
                title: 'Email',
                subtitle: 'shapak.apps@gmail.com',
                onTap: () {
                  Navigator.pop(context);
                  _openEmail(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackOption extends StatelessWidget {
  final AppColors c;
  final List<Color> gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _FeedbackOption({
    required this.c,
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.40),
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
                      title,
                      style: TextStyle(
                        color: c.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.caption(color: c.faint, size: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_outward_rounded, color: c.faint, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
