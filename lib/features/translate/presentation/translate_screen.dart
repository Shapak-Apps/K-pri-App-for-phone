import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/app/incoming_text.dart';
import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/analyzing_wave.dart';
import '../../history/data/history_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../data/languages.dart';
import '../data/offline_translator.dart';
import 'translate_controller.dart';
import 'widgets/input_card.dart';
import 'widgets/language_selector.dart';
import 'widgets/result_card.dart';
import 'widgets/translate_bridge.dart';

export 'translate_controller.dart' show kMicEnabled, kMicComingSoonVersion;

class TranslateScreen extends StatefulWidget {
  final HistoryRepository repo;
  final ValueListenable<IncomingText?> incomingText;
  const TranslateScreen({
    super.key,
    required this.repo,
    required this.incomingText,
  });
  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

/// in [TranslateController]. without business logic
class _TranslateScreenState extends State<TranslateScreen> {
  late final TranslateController _c;
  bool _created = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_created) {
      _created = true;
      _c = TranslateController(
        repo: widget.repo,
        settings: context.settings,
        incomingText: widget.incomingText,
      )..addListener(_tick);
    }
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (_created) {
      _c.removeListener(_tick);
      _c.dispose();
    }
    super.dispose();
  }

  /// Runs the translation, then shows the smart-XP feedback toast:
  /// "+N XP · M букв" on success, or a daily-cap notice when farming is blocked.
  Future<void> _onTranslateTap() async {
    await _c.translate();
    if (!mounted) return;

    final p = ProfileRepository.instance;
    final xp = p.lastXpAwarded;
    final chars = p.lastXpChars;
    final lang = context.settings.lang.name;

    if (xp > 0) {
      final charLabel = switch (lang) {
        'ru' => 'букв',
        'tk' => 'harp',
        'tr' => 'karakter',
        _ => 'chars',
      };
      final msg = '+$xp XP · $chars $charLabel';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: context.c.accent,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (p.dailyXpCapReached) {
      final msg = switch (lang) {
        'ru' => 'Дневной лимит XP достигнут — вернись завтра',
        'tk' => 'Gündelik XP çägi doldy — ertir gel',
        'tr' => 'Günlük XP sınırına ulaşıldı — yarın geri gel',
        _ => 'Daily XP cap reached — come back tomorrow',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: context.c.warn,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onMicTap() async {
    final outcome = await _c.toggleMic();
    if (!mounted) return;
    if (outcome == MicToggleOutcome.comingSoon) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => const _MicComingSoonPage(),
        ),
      );
    } else if (outcome == MicToggleOutcome.unavailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mikrofon / ses tanamak elýeterli däl'),
          backgroundColor: context.c.warn,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final auto = _c.autoDetected;
    final can = _c.canTranslate;
    final shownState = _c.shownState;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _c.unfocus,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LanguageSelector(
            from: _c.from,
            to: _c.to,
            onFromChanged: _c.setFrom,
            onToChanged: _c.setTo,
            onSwap: _c.swap,
          ),
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                const _ModelDownloadBanner(),
                InputCard(
                  controller: _c.ctrl,
                  focusNode: _c.focus,
                  onSubmitted: (_) => _c.unfocus(),
                  autoDetected: auto,
                  onClear: _c.clearInput,
                  isListening: _c.listening,
                  onMicTap: _onMicTap,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: _c.voiceAnalyzing
                      ? Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: AnalyzingWave(
                            label: context.l10n.t('analyzing'),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 14),
                TranslateBridge(
                  state: shownState,
                  canTranslate: can,
                  onTap: _onTranslateTap,
                ),
                const SizedBox(height: 14),
                if (_c.approx)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: c.warn.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.warn.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: c.warn,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            switch (context.settings.lang.name) {
                              'ru' => '≈ Приблизительный перевод',
                              'tk' => '≈ Takmyny terjime',
                              _ => '≈ Approximate translation',
                            },
                            style: TextStyle(
                              color: c.warn,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ResultCard(state: shownState, onSpeak: _c.speak),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MicComingSoonPage extends StatefulWidget {
  const _MicComingSoonPage();
  @override
  State<_MicComingSoonPage> createState() => _MicComingSoonPageState();
}

class _MicComingSoonPageState extends State<_MicComingSoonPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String _title(String lang) => switch (lang) {
    'ru' => 'Скоро в v$kMicComingSoonVersion',
    'tk' => 'v$kMicComingSoonVersion-de ýakyn wagtda',
    'tr' => 'v$kMicComingSoonVersion\'de Yakında',
    _ => 'Coming Soon in v$kMicComingSoonVersion',
  };

  String _subtitle(String lang) => switch (lang) {
    'ru' => 'Голосовой ввод',
    'tk' => 'Ses bilen girizmek',
    'tr' => 'Sesli giriş',
    _ => 'Voice input',
  };

  String _msg(String lang) => switch (lang) {
    'ru' =>
      'Голосовой перевод находится в активной разработке и появится в следующем крупном обновлении.',
    'tk' =>
      'Ses terjimesi işjeň işlenip düzülýär we indiki uly täzelenişde peýda bolar.',
    'tr' =>
      'Sesli çeviri aktif olarak geliştirilmektedir ve bir sonraki büyük güncellemede kullanılabilir olacak.',
    _ =>
      'Voice translation is under active development and will be available in the next major update.',
  };

  String _hint(String lang) => switch (lang) {
    'ru' => 'Следите за обновлениями!',
    'tk' => 'Täzelenmelere garaşyň!',
    'tr' => 'Güncellemeleri takip edin!',
    _ => 'Stay tuned for updates!',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final lang = context.settings.lang.name;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c.accent.withValues(alpha: 0.18), c.surface],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: c.accent.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: c.accent.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) {
                      final scale =
                          1.0 + 0.08 * Curves.easeInOut.transform(_pulse.value);
                      final glow =
                          0.25 +
                          0.35 * Curves.easeInOut.transform(_pulse.value);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [c.accent, c.accentDeep],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: c.accent.withValues(alpha: glow),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mic_rounded,
                            color: Colors.white,
                            size: 46,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: c.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: c.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.record_voice_over_rounded,
                          color: c.accent,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _subtitle(lang),
                          style: TextStyle(
                            color: c.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _title(lang),
                    style: TextStyle(
                      color: c.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _msg(lang),
                    style: TextStyle(color: c.sub, height: 1.5, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.surfaceHi,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.line),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: c.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _hint(lang),
                            style: TextStyle(
                              color: c.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
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
    );
  }
}

class _ModelDownloadBanner extends StatelessWidget {
  const _ModelDownloadBanner();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final lang = context.settings.lang;
    final tr = OfflineTranslator.instance;

    return ListenableBuilder(
      listenable: tr,
      builder: (context, _) {
        if (tr.downloadingCode != null) {
          final name =
              AppLanguages.all[tr.downloadingCode] ??
              tr.downloadingCode!.toUpperCase();
          final label = switch (lang) {
            AppLang.ru => 'Скачивание модели: $name…',
            AppLang.tk => 'Model ýüklenýär: $name…',
            AppLang.en => 'Downloading model: $name…',
            AppLang.tr => 'Model indiriliyor: $name…',
          };
          return _BannerBox(
            color: c.accent,
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: c.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (tr.failedCode != null) {
          final name =
              AppLanguages.all[tr.failedCode] ?? tr.failedCode!.toUpperCase();
          final label = switch (lang) {
            AppLang.ru => 'Не удалось скачать $name. Проверьте интернет.',
            AppLang.tk => '$name ýüklemek başa barmady. Interneti barlaň.',
            AppLang.tr =>
              '$name indirilemedi. İnternet bağlantınızı kontrol edin.',
            AppLang.en =>
              'Failed to download $name. Check your internet connection.',
          };
          return _BannerBox(
            color: c.warn,
            child: Row(
              children: [
                Icon(Icons.wifi_off_rounded, color: c.warn, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: c.warn,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _BannerBox extends StatelessWidget {
  final Color color;
  final Widget child;
  const _BannerBox({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: child,
      ),
    );
  }
}
