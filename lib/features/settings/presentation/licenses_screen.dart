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
        // Определяем тип лицензии из первого параграфа
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

  /// Определяем тип лицензии по ключевым словам
  _LicenseType? _detectLicenseType(String text) {
    final t = text.toLowerCase();
    if (t.contains('mit license') || t.contains('permission is hereby granted')) {
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
        .where((p) =>
    p.name.toLowerCase().contains(q) ||
        (p.licenseType?.name.toLowerCase().contains(q) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // ← ВАЖНО: реагирует на смену темы из Settings/Profile
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
                // ── ШАПКА ──
                _buildHeader(c, l10n, isDark),

                // ── БЛАГОДАРНОСТЬ + ПОИСК ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ThanksCard(c: c, l10n: l10n),
                        const SizedBox(height: 14),
                        _SearchBar(
                          c: c,
                          l10n: l10n,
                          query: _query,
                          onChanged: (v) => setState(() => _query = v),
                        ),
                        const SizedBox(height: 10),
                        _CounterRow(
                          c: c,
                          l10n: l10n,
                          count: filtered.length,
                          total: _packages.length,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // ── СОДЕРЖИМОЕ ──
                if (_loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
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
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: c.surfaceHi,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.search_off_rounded,
                                color: c.faint, size: 32),
                          ),
                          const SizedBox(height: 12),
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
                      delegate: SliverChildBuilderDelegate(
                            (context, i) => TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + i * 40),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, child) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - v)),
                              child: child,
                            ),
                          ),
                          child: _PackageTile(
                            package: filtered[i],
                            onTap: () =>
                                _openLicense(context, filtered[i]),
                          ),
                        ),
                        childCount: filtered.length,
                      ),
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
      expandedHeight: 220,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
        title: Text(
          l10n.t('licenses'),
          style: AppTheme.display(size: 18, color: c.text),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Фоновый градиент
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    c.accent.withValues(alpha: isDark ? 0.22 : 0.14),
                    c.bgSoft,
                    c.bg,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),

            // Декоративные круги
            Positioned(
              right: -50,
              top: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      c.accent.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -70,
              bottom: 30,
              child: Container(
                width: 160,
                height: 160,
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

            // Логотип Köpri с градиентом
            Align(
              alignment: const Alignment(0.78, -0.15),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [c.text, c.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Köp',
                        style: AppTheme.logo(
                            size: 52, color: Colors.white),
                      ),
                      TextSpan(
                        text: 'ri',
                        style: AppTheme.logo(
                            size: 52, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Бейдж версии
            Align(
              alignment: const Alignment(0.78, 0.26),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: c.accent.withValues(alpha: 0.45)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: c.accent, size: 12),
                    const SizedBox(width: 5),
                    Text(
                      'v1.0.1',
                      style: AppTheme.label(color: c.accent, size: 10),
                    ),
                  ],
                ),
              ),
            ),

            // Flutter badge слева снизу
            Align(
              alignment: const Alignment(-0.9, 0.65),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: c.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flutter_dash, color: c.accent, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'Built with Flutter',
                      style: TextStyle(
                          color: c.sub,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
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
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _LicenseDetailScreen(packageInfo: pkg),
    ));
  }
}

// ─── Данные пакета ───────────────────────────────────────────
enum _LicenseType {
  mit('MIT', Color(0xFF34D399)),
  apache('Apache', Color(0xFFFB923C)),
  bsd('BSD', Color(0xFF60A5FA)),
  gpl('GPL', Color(0xFFF472B6)),
  mpl('MPL', Color(0xFFA78BFA));

  final String name;
  final Color color;
  const _LicenseType(this.name, this.color);
}

class _PackageInfo {
  final String name;
  final List<LicenseEntry> entries = [];
  _LicenseType? licenseType;
  _PackageInfo({required this.name});

  String get letter =>
      name.isNotEmpty ? name[0].toUpperCase() : '?';
}

// ─── Карточка благодарности ──────────────────────────────────
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  c.accent.withValues(alpha: 0.9),
                  c.accentDeep.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: c.accent.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.favorite_rounded,
                color: Colors.white, size: 24),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.t('licenses_thanks_desc'),
                  style: TextStyle(
                    color: c.sub,
                    fontSize: 12,
                    height: 1.4,
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

// ─── Поиск ───────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: query.isNotEmpty
              ? c.accent.withValues(alpha: 0.5)
              : c.line,
        ),
        boxShadow: query.isNotEmpty
            ? [
          BoxShadow(
            color: c.accent.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(color: c.text),
        decoration: InputDecoration(
          hintText: l10n.t('licenses_search'),
          hintStyle: TextStyle(color: c.faint),
          prefixIcon: Icon(Icons.search_rounded, color: c.sub, size: 20),
          suffixIcon: query.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.close_rounded, color: c.sub, size: 20),
            onPressed: () => onChanged(''),
          )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
        ),
      ),
    );
  }
}

// ─── Счётчик ─────────────────────────────────────────────────
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: c.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.inventory_2_rounded, color: c.accent, size: 14),
        ),
        const SizedBox(width: 8),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: count),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => Text(
            '$v',
            style: AppTheme.display(size: 16, color: c.text),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          l10n.t('licenses_packages'),
          style: AppTheme.label(color: c.faint, size: 10),
        ),
        const Spacer(),
        if (count < total)
          Text(
            '/ $total',
            style: AppTheme.label(color: c.sub, size: 10),
          ),
      ],
    );
  }
}

// ─── Карточка пакета ─────────────────────────────────────────
class _PackageTile extends StatelessWidget {
  final _PackageInfo package;
  final VoidCallback onTap;
  const _PackageTile({required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.line),
            ),
            child: Row(
              children: [
                // «аватар» пакета с первой буквой
                Hero(
                  tag: 'license_avatar_${package.name}',
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          c.accent.withValues(alpha: 0.95),
                          c.accentDeep.withValues(alpha: 0.95),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: c.accent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      package.letter,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              package.name,
                              style: TextStyle(
                                color: c.text,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (package.licenseType != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: package.licenseType!.color
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: package.licenseType!.color
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                package.licenseType!.name,
                                style: TextStyle(
                                  color: package.licenseType!.color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.description_outlined,
                              color: c.faint, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${package.entries.length} ${_pluralEntries(package.entries.length)}',
                            style:
                            AppTheme.caption(color: c.faint, size: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: c.sub, size: 22),
              ],
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

// ─── Экран деталей лицензии ──────────────────────────────────
class _LicenseDetailScreen extends StatelessWidget {
  final _PackageInfo packageInfo;
  const _LicenseDetailScreen({super.key, required this.packageInfo});

  void _copyAll(BuildContext context) {
    final text = packageInfo.entries
        .expand((e) => e.paragraphs.map((p) => p.text))
        .join('\n\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(context.l10n.t('copied')),
      backgroundColor: context.c.accent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        foregroundColor: c.text,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              packageInfo.name,
              style: AppTheme.display(size: 15, color: c.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (packageInfo.licenseType != null)
              Text(
                packageInfo.licenseType!.name,
                style: TextStyle(
                  color: packageInfo.licenseType!.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.copy_rounded, color: c.accent),
            tooltip: 'Copy',
            onPressed: () => _copyAll(context),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: packageInfo.entries.length,
        separatorBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(height: 1, color: c.line),
        ),
        itemBuilder: (context, i) {
          final entry = packageInfo.entries[i];
          final paragraphs = entry.paragraphs.toList();
          return Hero(
            tag: 'license_avatar_${packageInfo.name}',
            flightShuttleBuilder: (_, __, ___, ____, _____) => Container(),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: c.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '§',
                          style: TextStyle(
                            color: c.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${i + 1}',
                        style: AppTheme.label(color: c.accent, size: 10),
                      ),
                      const Spacer(),
                      IconButton(
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                        constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: Icon(Icons.copy_rounded,
                            color: c.sub, size: 16),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: paragraphs.join('\n\n')));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(context.l10n.t('copied')),
                            backgroundColor: c.accent,
                          ));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...paragraphs.map((para) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SelectableText(
                      para.text.isEmpty ? '—' : para.text,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}