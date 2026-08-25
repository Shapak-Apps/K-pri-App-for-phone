import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class LicensesScreen extends StatefulWidget {
  const LicensesScreen({super.key});
  @override
  State<LicensesScreen> createState() => _LicensesScreenState();
}

class _LicensesScreenState extends State<LicensesScreen> {
  final List<_PackageInfo> _packages = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadLicenses();
  }

  Future<void> _loadLicenses() async {
    setState(() {
      _loading = true;
      _packages.clear();
    });
    final map = <String, _PackageInfo>{};
    await for (final license in LicenseRegistry.licenses) {
      for (final pkg in license.packages) {
        final info = map.putIfAbsent(pkg, () => _PackageInfo(name: pkg));
        info.entries.add(license);
        if (info.licenseType == null) {
          for (final para in license.paragraphs) {
            final type = _detectLicenseType(para.text);
            if (type != null) {
              info.licenseType = type;
              break;
            }
          }
        }
      }
    }
    final list = map.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (mounted) {
      setState(() {
        _packages.addAll(list);
        _loading = false;
      });
    }
  }

  _LicenseType? _detectLicenseType(String text) {
    final t = text.toLowerCase();
    if (t.contains('mit license') ||
        t.contains('permission is hereby granted')) {
      return _LicenseType.mit;
    }
    if (t.contains('apache license') || t.contains('apache-2.0')) {
      return _LicenseType.apache;
    }
    if (t.contains('bsd') || t.contains('redistribution')) {
      return _LicenseType.bsd;
    }
    if (t.contains('gpl') || t.contains('gnu general public')) {
      return _LicenseType.gpl;
    }
    if (t.contains('mozilla public license') || t.contains('mpl')) {
      return _LicenseType.mpl;
    }
    return null;
  }

  List<_PackageInfo> get _filtered {
    if (_query.trim().isEmpty) return _packages;
    final q = _query.toLowerCase();
    return _packages
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              (p.licenseType?.name.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.settings;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final c = context.c;
        final l10n = s.l10n;
        final filtered = _filtered;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: c.bg,
          body: RefreshIndicator(
            color: c.accent,
            backgroundColor: c.surface,
            onRefresh: _loadLicenses,
            child: CustomScrollView(
              slivers: [
                _buildHeader(c, l10n, isDark),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ThanksCard(c: c, l10n: l10n),
                        const SizedBox(height: 16),
                        _SearchBar(
                          c: c,
                          l10n: l10n,
                          query: _query,
                          onChanged: (v) => setState(() => _query = v),
                        ),
                        const SizedBox(height: 12),
                        _CounterRow(
                          c: c,
                          l10n: l10n,
                          count: filtered.length,
                          total: _packages.length,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                if (_loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  )
                else if (filtered.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [c.surfaceHi, c.surface],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: c.line),
                              boxShadow: [
                                BoxShadow(
                                  color: c.accent.withValues(alpha: 0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.search_off_rounded,
                              color: c.faint,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.t('licenses_not_found'),
                            style: AppTheme.caption(color: c.faint),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, i) {
                        final shouldAnimate = i < 15;
                        final delayMs = shouldAnimate ? i * 50 : 0;
                        final totalMs = 450 + delayMs;
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: totalMs),
                          curve: Interval(
                            delayMs / totalMs,
                            1.0,
                            curve: Curves.easeOutCubic,
                          ),
                          builder: (context, v, child) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 24 * (1 - v)),
                              child: child,
                            ),
                          ),
                          child: _PackageTile(
                            package: filtered[i],
                            onTap: () => _openLicense(context, filtered[i]),
                          ),
                        );
                      }, childCount: filtered.length),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppColors c, dynamic l10n, bool isDark) {
    return SliverAppBar(
      backgroundColor: c.bg,
      foregroundColor: c.text,
      elevation: 0,
      pinned: true,
      expandedHeight: 280,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
        title: Text(
          l10n.t('licenses'),
          style: AppTheme.display(size: 20, color: c.text),
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
                    c.accent.withValues(alpha: isDark ? 0.25 : 0.18),
                    c.accentDeep.withValues(alpha: isDark ? 0.15 : 0.08),
                    c.bgSoft,
                    c.bg,
                  ],
                  stops: const [0.0, 0.35, 0.7, 1.0],
                ),
              ),
            ),
            Positioned(
              right: -60,
              top: -50,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      c.accent.withValues(alpha: 0.55),
                      c.accent.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -80,
              bottom: -20,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      c.accentHi.withValues(alpha: 0.40),
                      c.accentHi.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 80,
              bottom: 60,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      c.accentDeep.withValues(alpha: 0.30),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.82, -0.10),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [c.text, c.accent, c.accentDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.6, 1.0],
                ).createShader(bounds),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Köp',
                        style: AppTheme.logo(size: 64, color: Colors.white),
                      ),
                      TextSpan(
                        text: 'ri',
                        style: AppTheme.logo(size: 64, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.82, 0.32),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: c.accent.withValues(alpha: 0.55),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, color: c.accent, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      'v1.0.2',
                      style: AppTheme.label(
                        color: c.accent,
                        size: 11,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(-0.88, 0.70),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: c.surface.withValues(alpha: isDark ? 0.85 : 0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.line, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flutter_dash, color: c.accent, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'Built with Flutter',
                      style: TextStyle(
                        color: c.sub,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLicense(BuildContext context, _PackageInfo pkg) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _LicenseDetailScreen(packageInfo: pkg)),
    );
  }
}

enum _LicenseType {
  mit('MIT', Color(0xFF34D399), Color(0xFF10B981)),
  apache('Apache', Color(0xFFFB923C), Color(0xFFF97316)),
  bsd('BSD', Color(0xFF60A5FA), Color(0xFF3B82F6)),
  gpl('GPL', Color(0xFFF472B6), Color(0xFFEC4899)),
  mpl('MPL', Color(0xFFA78BFA), Color(0xFF8B5CF6));

  final String name;
  final Color color;
  final Color deepColor;
  const _LicenseType(this.name, this.color, this.deepColor);
}

class _PackageInfo {
  final String name;
  final List<LicenseEntry> entries = [];
  _LicenseType? licenseType;
  _PackageInfo({required this.name});

  String get letter => name.isNotEmpty ? name[0].toUpperCase() : '?';
}

class _ThanksCard extends StatefulWidget {
  final AppColors c;
  final dynamic l10n;
  const _ThanksCard({required this.c, required this.l10n});

  @override
  State<_ThanksCard> createState() => _ThanksCardState();
}

class _ThanksCardState extends State<_ThanksCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final l10n = widget.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.06),
                  Colors.white.withValues(alpha: 0.02),
                ]
              : [
                  Colors.white.withValues(alpha: 0.85),
                  Colors.white.withValues(alpha: 0.65),
                ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseAnimation.value * 0.08),
                child: child,
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    c.accent.withValues(alpha: 0.95),
                    c.accentDeep.withValues(alpha: 0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: c.accent.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('licenses_thanks_title'),
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.t('licenses_thanks_desc'),
                  style: TextStyle(
                    color: c.sub,
                    fontSize: 13,
                    height: 1.45,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final AppColors c;
  final dynamic l10n;
  final String query;
  final ValueChanged<String> onChanged;
  const _SearchBar({
    required this.c,
    required this.l10n,
    required this.query,
    required this.onChanged,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _focused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final l10n = widget.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasQuery = widget.query.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: _focused
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  c.accent.withValues(alpha: 0.9),
                  c.accentDeep.withValues(alpha: 0.9),
                ],
              )
            : null,
        color: _focused
            ? null
            : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.85)),
        border: Border.all(
          color: _focused
              ? Colors.transparent
              : (isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.06)),
          width: 1.2,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: c.accent.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      padding: EdgeInsets.all(_focused ? 1.5 : 0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(_focused ? 16.5 : 18),
        ),
        child: TextField(
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          style: TextStyle(color: c.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: l10n.t('licenses_search'),
            hintStyle: TextStyle(color: c.faint),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _focused ? c.accent : c.sub,
              size: 21,
            ),
            suffixIcon: hasQuery
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: c.sub, size: 20),
                    onPressed: () => widget.onChanged(''),
                  )
                : null,
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  final AppColors c;
  final dynamic l10n;
  final int count;
  final int total;
  const _CounterRow({
    required this.c,
    required this.l10n,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                c.accent.withValues(alpha: 0.18),
                c.accentDeep.withValues(alpha: 0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: c.accent.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_rounded, color: c.accent, size: 15),
              const SizedBox(width: 6),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: count),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Text(
                  '$v',
                  style: AppTheme.display(
                    size: 15,
                    color: c.accent,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          l10n.t('licenses_packages'),
          style: AppTheme.label(color: c.sub, size: 11),
        ),
        const Spacer(),
        if (count < total)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.line, width: 1),
            ),
            child: Text(
              '/ $total',
              style: AppTheme.label(color: c.sub, size: 10),
            ),
          ),
      ],
    );
  }
}

class _PackageTile extends StatelessWidget {
  final _PackageInfo package;
  final VoidCallback onTap;
  const _PackageTile({required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lt = package.licenseType;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.02),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.90),
                        Colors.white.withValues(alpha: 0.70),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      gradient: lt != null
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [lt.color, lt.deepColor],
                            )
                          : null,
                      color: lt == null ? c.faint : null,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'license_avatar_${package.name}',
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: lt != null
                                      ? [lt.color, lt.deepColor]
                                      : [
                                          c.accent.withValues(alpha: 0.95),
                                          c.accentDeep.withValues(alpha: 0.95),
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (lt?.color ?? c.accent).withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                package.letter,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  package.name,
                                  style: TextStyle(
                                    color: c.text,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    letterSpacing: 0.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      color: c.faint,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${package.entries.length} ${_pluralEntries(package.entries.length)}',
                                      style: AppTheme.caption(
                                        color: c.faint,
                                        size: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (lt != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    lt.color.withValues(alpha: 0.20),
                                    lt.deepColor.withValues(alpha: 0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: lt.color.withValues(alpha: 0.45),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                lt.name,
                                style: TextStyle(
                                  color: lt.color,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.9,
                                ),
                              ),
                            ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: c.sub,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _pluralEntries(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'запись';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) {
      return 'записи';
    }
    return 'записей';
  }
}

class _LicenseDetailScreen extends StatefulWidget {
  final _PackageInfo packageInfo;
  const _LicenseDetailScreen({super.key, required this.packageInfo});

  @override
  State<_LicenseDetailScreen> createState() => _LicenseDetailScreenState();
}

class _LicenseDetailScreenState extends State<_LicenseDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fabController.forward();
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _copyAll(BuildContext context) {
    final text = widget.packageInfo.entries
        .expand((e) => e.paragraphs.map((p) => p.text))
        .join('\n\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.t('copied')),
        backgroundColor: context.c.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _copyParagraph(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.t('copied')),
        backgroundColor: context.c.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lt = widget.packageInfo.licenseType;

    return Scaffold(
      backgroundColor: c.bg,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: c.bg,
        foregroundColor: c.text,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: lt != null
                      ? [lt.color, lt.deepColor]
                      : [
                          c.accent.withValues(alpha: 0.95),
                          c.accentDeep.withValues(alpha: 0.95),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (lt?.color ?? c.accent).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                widget.packageInfo.letter,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.packageInfo.name,
                    style: AppTheme.display(
                      size: 15,
                      color: c.text,
                    ).copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (lt != null)
                    Text(
                      lt.name,
                      style: TextStyle(
                        color: lt.color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (lt?.color ?? c.accent).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: widget.packageInfo.entries.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) {
                return _InfoCard(
                  c: c,
                  package: widget.packageInfo,
                  isDark: isDark,
                );
              }
              final entry = widget.packageInfo.entries[i - 1];
              final paragraphs = entry.paragraphs.toList();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: lt != null
                                      ? [lt.color, lt.deepColor]
                                      : [
                                          c.accent.withValues(alpha: 0.9),
                                          c.accentDeep.withValues(alpha: 0.9),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: (lt?.color ?? c.accent).withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '§',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${i}',
                              style: AppTheme.label(
                                color: c.text,
                                size: 12,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            IconButton(
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              icon: Icon(
                                Icons.copy_rounded,
                                color: c.sub,
                                size: 17,
                              ),
                              onPressed: () {
                                _copyParagraph(
                                  context,
                                  paragraphs.map((p) => p.text).join('\n\n'),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int p = 0; p < paragraphs.length; p++) ...[
                              if (p > 0) const SizedBox(height: 12),
                              SelectableText(
                                paragraphs[p].text.isEmpty
                                    ? '—'
                                    : paragraphs[p].text,
                                style: TextStyle(
                                  color: c.text,
                                  fontSize: 13.5,
                                  height: 1.55,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _fabController,
                curve: Curves.elasticOut,
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _copyAll(context),
                backgroundColor: c.accent,
                foregroundColor: Colors.white,
                elevation: 8,
                icon: const Icon(Icons.copy_rounded, size: 20),
                label: Text(
                  'Copy All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
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

class _InfoCard extends StatelessWidget {
  final AppColors c;
  final _PackageInfo package;
  final bool isDark;
  const _InfoCard({
    required this.c,
    required this.package,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final lt = package.licenseType;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.03),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.75),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'license_avatar_${package.name}',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: lt != null
                          ? [lt.color, lt.deepColor]
                          : [
                              c.accent.withValues(alpha: 0.95),
                              c.accentDeep.withValues(alpha: 0.95),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (lt?.color ?? c.accent).withValues(alpha: 0.40),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    package.letter,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name,
                      style: TextStyle(
                        color: c.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (lt != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              lt.color.withValues(alpha: 0.20),
                              lt.deepColor.withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: lt.color.withValues(alpha: 0.45),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          lt.name,
                          style: TextStyle(
                            color: lt.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.9,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _StatTile(
                c: c,
                icon: Icons.description_outlined,
                value: '${package.entries.length}',
                label: 'entries',
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _StatTile(
                c: c,
                icon: Icons.text_snippet_outlined,
                value:
                    '${package.entries.fold<int>(0, (sum, e) => sum + e.paragraphs.length)}',
                label: 'paragraphs',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;
  const _StatTile({
    required this.c,
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: c.accent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: c.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: c.faint,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
