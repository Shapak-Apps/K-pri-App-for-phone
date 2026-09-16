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

        return Scaffold(
          backgroundColor: c.bg,
          body: RefreshIndicator(
            color: c.accent,
            backgroundColor: c.surface,
            onRefresh: _loadLicenses,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: c.bg,
                  foregroundColor: c.text,
                  elevation: 0,
                  pinned: true,
                  centerTitle: false,
                  title: Text(
                    l10n.t('licenses'),
                    style: AppTheme.display(size: 20, color: c.text),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: _ThanksCard(c: c, l10n: l10n),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: _SearchBar(
                      c: c,
                      l10n: l10n,
                      query: _query,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: _CounterRow(
                      c: c,
                      l10n: l10n,
                      count: filtered.length,
                      total: _packages.length,
                    ),
                  ),
                ),
                if (_loading)
                  SliverFillRemaining(
                    child: Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: c.accent,
                          strokeWidth: 2.5,
                        ),
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
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: c.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.line),
                            ),
                            child: Icon(
                              Icons.search_off_rounded,
                              color: c.faint,
                              size: 32,
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

  void _openLicense(BuildContext context, _PackageInfo pkg) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _LicenseDetailScreen(packageInfo: pkg)),
    );
  }
}

enum _LicenseType {
  mit('MIT'),
  apache('Apache-2.0'),
  bsd('BSD'),
  gpl('GPL'),
  mpl('MPL');

  final String name;
  const _LicenseType(this.name);
}

class _PackageInfo {
  final String name;
  final List<LicenseEntry> entries = [];
  _LicenseType? licenseType;
  _PackageInfo({required this.name});

  String get letter => name.isNotEmpty ? name[0].toUpperCase() : '?';
}

class _ThanksCard extends StatelessWidget {
  final AppColors c;
  final dynamic l10n;
  const _ThanksCard({required this.c, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.accent, c.accentDeep],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('licenses_thanks_title'),
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.t('licenses_thanks_desc'),
                  style: TextStyle(
                    color: c.sub,
                    fontSize: 12.5,
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
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
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
    final hasQuery = widget.query.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focused ? c.accent : c.line,
          width: _focused ? 1.4 : 1,
        ),
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
            color: _focused ? c.accent : c.faint,
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
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 14,
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
            color: c.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.accent.withValues(alpha: 0.3)),
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
        Expanded(
          child: Text(
            l10n.t('licenses_packages'),
            style: AppTheme.label(color: c.sub, size: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (count < total)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.line),
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
    final lt = package.licenseType;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.line),
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'license_avatar_${package.name}',
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c.surfaceHi,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.line),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      package.letter,
                      style: TextStyle(
                        color: c.accent,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
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
                        package.name,
                        style: TextStyle(
                          color: c.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lt?.name ?? '—'} · ${package.entries.length}',
                        style: AppTheme.caption(color: c.faint, size: 11.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: c.faint, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
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
    final lt = widget.packageInfo.licenseType;

    return Scaffold(
      backgroundColor: c.bg,
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
                color: c.surfaceHi,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.line),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.packageInfo.letter,
                style: TextStyle(
                  color: c.accent,
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
                        color: c.sub,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: widget.packageInfo.entries.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return _InfoCard(c: c, package: widget.packageInfo);
          }
          final entry = widget.packageInfo.entries[i - 1];
          final paragraphs = entry.paragraphs.toList();
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: c.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: c.line)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: c.surfaceHi,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: c.line),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '§',
                            style: TextStyle(
                              color: c.accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$i',
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
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _copyAll(context),
          backgroundColor: c.accent,
          foregroundColor: Colors.white,
          elevation: 6,
          icon: const Icon(Icons.copy_rounded, size: 20),
          label: const Text(
            'Copy All',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final AppColors c;
  final _PackageInfo package;
  const _InfoCard({required this.c, required this.package});

  @override
  Widget build(BuildContext context) {
    final lt = package.licenseType;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'license_avatar_${package.name}',
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: c.surfaceHi,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.line),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    package.letter,
                    style: TextStyle(
                      color: c.accent,
                      fontSize: 24,
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
                  children: [
                    Text(
                      package.name,
                      style: TextStyle(
                        color: c.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (lt != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: c.surfaceHi,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: c.line),
                        ),
                        child: Text(
                          lt.name,
                          style: AppTheme.caption(color: c.sub, size: 10.5),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: c.line),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatTile(
                c: c,
                icon: Icons.description_outlined,
                value: '${package.entries.length}',
                label: 'entries',
              ),
              const SizedBox(width: 10),
              _StatTile(
                c: c,
                icon: Icons.text_snippet_outlined,
                value:
                    '${package.entries.fold<int>(0, (sum, e) => sum + e.paragraphs.length)}',
                label: 'paragraphs',
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
  const _StatTile({
    required this.c,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: c.surfaceHi,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.line),
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
