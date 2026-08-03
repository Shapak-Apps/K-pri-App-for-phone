import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_route.dart';
import '../../conversation/data/tts_service.dart';
import '../data/phrasebook_data.dart';

// режим озвучки фраз
bool _showIface(PhraseSpeakMode m) =>
    m == PhraseSpeakMode.iface || m == PhraseSpeakMode.both;
bool _showEn(PhraseSpeakMode m, String src) {
  if (m == PhraseSpeakMode.english) return true;
  if (m == PhraseSpeakMode.both) return src != 'en';
  return false;
}

class PhrasebookScreen extends StatefulWidget {
  const PhrasebookScreen({super.key});
  @override
  State<PhrasebookScreen> createState() => _PhrasebookScreenState();
}

class _PhrasebookScreenState extends State<PhrasebookScreen> {
  final _tts = TtsService();
  String _q = '';
  Timer? _deb;

  @override
  void initState() {
    super.initState();
    _tts.init();
  }

  @override
  void dispose() {
    _deb?.cancel();
    super.dispose();
  }

  String get _src => context.settings.lang.name;

  int get _total => phrasebook.fold<int>(0, (a, x) => a + catCount(x));

  List<({PCat c, PSub s, PPh p})> _search() {
    final q = _q.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final out = <({PCat c, PSub s, PPh p})>[];
    for (final c in phrasebook) {
      for (final s in c.s) {
        for (final p in s.p) {
          if (p.ru.toLowerCase().contains(q) ||
              p.en.toLowerCase().contains(q) ||
              p.tk.toLowerCase().contains(q)) {
            out.add((c: c, s: s, p: p));
          }
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;
    final searching = _q.trim().isNotEmpty;
    final results = searching ? _search() : const <({PCat c, PSub s, PPh p})>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  l10n.t('phrasebook_title'),
                  style: AppTheme.display(size: 26, color: c.text),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '$_total',
                  style: AppTheme.label(color: c.accent, size: 13),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (v) {
              _deb?.cancel();
              _deb = Timer(const Duration(milliseconds: 160), () {
                if (mounted) setState(() => _q = v);
              });
            },
            style: TextStyle(color: c.text),
            decoration: InputDecoration(
              hintText: l10n.t('search'),
              hintStyle: TextStyle(color: c.faint),
              prefixIcon: Icon(Icons.search_rounded, color: c.sub),
              suffixIcon: _q.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded, color: c.sub),
                      onPressed: () => setState(() => _q = ''),
                    )
                  : null,
              filled: true,
              fillColor: c.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: searching
              ? _Results(
                  c: c,
                  src: _src,
                  items: results,
                  onSpeak: (t, code) =>
                      _tts.speak(t, code, rate: context.settings.speechRate),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: phrasebook.length,
                  itemBuilder: (_, i) => _CategoryCard(
                    c: c,
                    src: _src,
                    index: i,
                    cat: phrasebook[i],
                    onTap: () => Navigator.of(context).push(
                      appRoute(
                        _CategoryScreen(index: i, cat: phrasebook[i]),
                        animate: context.settings.animationsOn,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final AppColors c;
  final String src;
  final int index;
  final PCat cat;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.c,
    required this.src,
    required this.index,
    required this.cat,
    required this.onTap,
  });

  Widget _iconBox() => Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: c.accent.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Icon(cat.icon, color: c.accent, size: 27),
  );

  @override
  Widget build(BuildContext context) {
    final n = catCount(cat);
    final compact = context.settings.compact;
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 6 : 10),
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(compact ? 10 : 14),
            child: Row(
              children: [
                context.settings.animationsOn
                    ? Hero(tag: 'pb-cat-$index', child: _iconBox())
                    : _iconBox(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        catText(cat, src),
                        style: TextStyle(
                          color: c.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 15.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${cat.s.length}  ·  $n',
                        style: AppTheme.label(color: c.faint, size: 10),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.sub, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  final AppColors c;
  final String src;
  final List<({PCat c, PSub s, PPh p})> items;
  final void Function(String, String) onSpeak;
  const _Results({
    required this.c,
    required this.src,
    required this.items,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final mode = context.settings.phraseSpeak;
    if (items.isEmpty) {
      return Center(
        child: Text('—  no results', style: AppTheme.caption(color: c.faint)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final it = items[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phText(it.p, src),
                      style: TextStyle(
                        color: c.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${catText(it.c, src)}  ·  ${subText(it.s, src)}',
                      style: AppTheme.label(color: c.faint, size: 9),
                    ),
                  ],
                ),
              ),
              if (_showIface(mode)) ...[
                _spk(Icons.record_voice_over_rounded, phText(it.p, src), src),
                const SizedBox(width: 6),
              ],
              if (_showEn(mode, src))
                _spk(Icons.language_rounded, it.p.en, 'en'),
            ],
          ),
        );
      },
    );
  }

  Widget _spk(IconData ic, String text, String code) => Material(
    color: c.surfaceHi,
    borderRadius: BorderRadius.circular(9),
    child: InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: () => onSpeak(text, code),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(ic, size: 18, color: c.accent),
      ),
    ),
  );
}

class _CategoryScreen extends StatelessWidget {
  final int index;
  final PCat cat;
  const _CategoryScreen({required this.index, required this.cat});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final src = context.settings.lang.name;
    final anim = context.settings.animationsOn;
    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: c.bg,
            foregroundColor: c.text,
            elevation: 0,
            pinned: true,
            expandedHeight: 132,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
              title: Text(
                catText(cat, src),
                style: AppTheme.display(size: 17, color: c.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [c.accent.withValues(alpha: 0.16), c.bg],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24, top: 8),
                      child: anim
                          ? Hero(
                              tag: 'pb-cat-$index',
                              child: Icon(cat.icon, color: c.accent, size: 84),
                            )
                          : Icon(cat.icon, color: c.accent, size: 84),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                final sub = cat.s[i];
                return _SubCard(
                  c: c,
                  src: src,
                  sub: sub,
                  onTap: () => Navigator.of(context).push(
                    appRoute(
                      _SubScreen(sub: sub),
                      animate: context.settings.animationsOn,
                    ),
                  ),
                );
              }, childCount: cat.s.length),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubCard extends StatelessWidget {
  final AppColors c;
  final String src;
  final PSub sub;
  final VoidCallback onTap;
  const _SubCard({
    required this.c,
    required this.src,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final compact = context.settings.compact;
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 6 : 10),
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(compact ? 10 : 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: c.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(sub.icon, color: c.accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subText(sub, src),
                        style: TextStyle(
                          color: c.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${subCount(sub)}',
                        style: AppTheme.label(color: c.faint, size: 10),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.sub, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubScreen extends StatefulWidget {
  final PSub sub;
  const _SubScreen({required this.sub});
  @override
  State<_SubScreen> createState() => _SubScreenState();
}

class _SubScreenState extends State<_SubScreen> {
  final _tts = TtsService();
  @override
  void initState() {
    super.initState();
    _tts.init();
  }

  void _speak(String text, String code) =>
      _tts.speak(text, code, rate: context.settings.speechRate);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final src = context.settings.lang.name;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        foregroundColor: c.text,
        title: Text(
          subText(widget.sub, src),
          style: AppTheme.display(size: 18, color: c.text),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: widget.sub.p.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) =>
            _PhraseTile(c: c, src: src, ph: widget.sub.p[i], onSpeak: _speak),
      ),
    );
  }
}

class _PhraseTile extends StatefulWidget {
  final AppColors c;
  final String src;
  final PPh ph;
  final void Function(String, String) onSpeak;
  const _PhraseTile({
    required this.c,
    required this.src,
    required this.ph,
    required this.onSpeak,
  });
  @override
  State<_PhraseTile> createState() => _PhraseTileState();
}

class _PhraseTileState extends State<_PhraseTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final src = widget.src;
    final ph = widget.ph;
    final mode = context.settings.phraseSpeak;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _open = !_open),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _open ? c.accent.withValues(alpha: 0.45) : c.line,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      phText(ph, src),
                      style: TextStyle(
                        color: c.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_showIface(mode)) ...[
                    _spk(
                      c,
                      Icons.record_voice_over_rounded,
                      phText(ph, src),
                      src,
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (_showEn(mode, src)) ...[
                    _spk(c, Icons.language_rounded, ph.en, 'en'),
                    const SizedBox(width: 6),
                  ],
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: c.sub,
                      size: 22,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _open
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            if (src != 'en') _row(c, 'EN', ph.en, c.accent),
                            if (src != 'ru') _row(c, 'RU', ph.ru, c.sub),
                            if (src != 'tk') _row(c, 'TK', ph.tk, c.sub),
                            if (context.settings.showTranscription) ...[
                              const SizedBox(height: 4),
                              Text(
                                '[${ph.tr}]',
                                style: AppTheme.caption(
                                  color: c.faint,
                                  size: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(AppColors c, String tag, String text, Color col) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Text(tag, style: AppTheme.label(color: col, size: 9)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: c.text,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _spk(AppColors c, IconData ic, String text, String code) => Material(
    color: c.surfaceHi,
    borderRadius: BorderRadius.circular(9),
    child: InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: () => widget.onSpeak(text, code),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(ic, size: 18, color: c.accent),
      ),
    ),
  );
}
