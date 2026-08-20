import 'package:flutter/material.dart';
import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../conversation/data/tts_service.dart';
import '../../history/data/history_models.dart';
import '../../history/data/history_repository.dart';

class FlashcardsScreen extends StatefulWidget {
  final HistoryRepository repo;
  const FlashcardsScreen({super.key, required this.repo});
  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  List<HistoryEntry> _cards = [];
  int _i = 0;
  bool _back = false;

  bool _loaded = false;
  bool _subscribed = false;
  AppSettingsController? _settings;
  int? _lastSession;
  bool? _lastSpaced;

  final Set<String> _repeated = {};

  @override
  void initState() {
    super.initState();
    widget.repo.addListener(_load);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settings ??= context.settings;
    if (!_loaded) {
      _loaded = true;
      _load();
    }
    if (!_subscribed) {
      _subscribed = true;
      _settings!.addListener(_onSettings);
    }
  }

  void _onSettings() {
    final s = _settings!;
    if (s.flashcardSession != _lastSession || s.spacedRep != _lastSpaced) {
      _load();
    }
  }

  @override
  void dispose() {
    widget.repo.removeListener(_load);
    _settings?.removeListener(_onSettings);
    super.dispose();
  }

  void _load() {
    if (!mounted) return;
    final s = context.settings;
    _lastSession = s.flashcardSession;
    _lastSpaced = s.spacedRep;
    final fav = widget.repo.getFavorites()..shuffle();
    final session = fav.take(s.flashcardSession).toList();
    setState(() {
      _cards = session;
      _i = 0;
      _back = false;
      _repeated.clear();
    });
  }

  void _next({required bool remembered}) {
    if (_cards.isEmpty) return;
    final current = _cards[_i % _cards.length];
    setState(() {
      if (!remembered && context.settings.spacedRep) {
        _repeated.add(current.id);
        _cards = [..._cards, current];
      }
      _i = (_i + 1) % _cards.length;
      _back = false;
    });
  }

  void _speakCurrent(HistoryEntry e) {
    final text = _back ? e.result : e.source;
    final lang = _back ? e.to : e.from;
    TtsService().speak(text, lang);
  }

  String _flagFor(String code) => switch (code) {
    'ru' => '🇷🇺',
    'tk' => '🇹🇲',
    'en' => '🇬🇧',
    'tr' => '🇹🇷',
    _ => '🏳️',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.c, l10n = context.l10n;

    if (_cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.style_outlined, size: 56, color: c.faint),
            const SizedBox(height: 12),
            Text(
              l10n.t('flashcards_empty'),
              style: AppTheme.caption(color: c.faint),
            ),
          ],
        ),
      );
    }

    final e = _cards[_i % _cards.length];
    final isRepeated = _repeated.contains(e.id);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            l10n.t('flashcards_title'),
            style: AppTheme.display(size: 22, color: c.text),
          ),
          const SizedBox(height: 6),
          Text(
            '${_i + 1} / ${_cards.length}',
            style: AppTheme.label(color: c.sub, size: 11),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _back = !_back),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (ch, a) => ScaleTransition(
                  scale: a,
                  child: FadeTransition(opacity: a, child: ch),
                ),
                child: Container(
                  key: ValueKey('$_i$_back'),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isRepeated
                          ? c.warn.withValues(alpha: 0.5)
                          : (_back ? c.accent : c.line),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _back ? l10n.t('to') : l10n.t('from'),
                            style: AppTheme.label(color: c.accent, size: 11),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_flagFor(e.from)} ${e.from.toUpperCase()} → ${_flagFor(e.to)} ${e.to.toUpperCase()}',
                            style: AppTheme.label(color: c.faint, size: 10),
                          ),
                          if (isRepeated) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.replay_rounded, color: c.warn, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              l10n.t('repeat'),
                              style: AppTheme.label(color: c.warn, size: 9),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _back ? e.result : e.source,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: c.text,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => _speakCurrent(e),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: c.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: c.accent.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.volume_up_rounded,
                                  color: c.accent,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.t('speak'),
                                  style: TextStyle(
                                    color: c.accent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _act(
                  c,
                  l10n.t('forgot'),
                  Icons.close_rounded,
                  c.warn,
                      () => _next(remembered: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _act(
                  c,
                  l10n.t('remember'),
                  Icons.check_rounded,
                  c.accent,
                      () => _next(remembered: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _act(AppColors c, String l, IconData i, Color col, VoidCallback t) =>
      Material(
        color: col.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: t,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: col.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(i, color: col, size: 20),
                const SizedBox(width: 8),
                Text(
                  l,
                  style: TextStyle(color: col, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      );
}