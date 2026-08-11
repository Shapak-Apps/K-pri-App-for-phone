import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/analyzing_wave.dart';
import '../../translate/data/languages.dart';
import '../../translate/data/translator_service.dart';
import '../../translate/presentation/widgets/language_selector.dart';
import '../data/camera_photo_model.dart';
import '../data/camera_repository.dart';
import '../data/ocr_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();

  static Future<void> openTranslateCamera(BuildContext context) async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const _CameraPage(),
      ),
    );
  }

  static Future<String?> pickProfilePhoto(BuildContext context) async {
    await CameraRepository.instance.ensureInit();
    final c = context.c;

    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: c.accent),
                title: Text('Сделать снимок',
                    style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: c.accent),
                title: Text('Выбрать из галереи',
                    style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !context.mounted) return null;

    if (source == 'camera') {
      final status = await Permission.camera.request();
      if (!status.isGranted) return null;
      if (!context.mounted) return null;
      return await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(
          fullscreenDialog: true,
          builder: (_) => const _CameraPage(isProfileMode: true),
        ),
      );
    } else if (source == 'gallery') {
      if (!context.mounted) return null;
      return await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(
          builder: (_) => const _ProfileGalleryPicker(),
        ),
      );
    }
    return null;
  }
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _snack(String t, {bool warn = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t),
        backgroundColor: warn ? context.c.warn : context.c.accent,
      ),
    );
  }

  Future<void> _openCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _snack(context.l10n.t('camera_permission'), warn: true);
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const _CameraPage(),
      ),
    );
  }

  Future<void> _openGallery() async {
    final c = context.c;
    final l10n = context.l10n;
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      barrierLabel: 'gallery',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, __) {
        return ListenableBuilder(
          listenable: CameraRepository.instance,
          builder: (context, _) {
            final all = CameraRepository.instance.getAll();
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: FractionallySizedBox(
                    heightFactor: 0.86,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: c.line),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 10, 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.photo_library_rounded, color: c.accent, size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        l10n.t('camera_gallery'),
                                        style: TextStyle(
                                          color: c.text,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      icon: Icon(Icons.close_rounded, color: c.sub, size: 22),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: all.isEmpty
                                    ? Center(
                                  child: Text(
                                    l10n.t('camera_empty'),
                                    style: AppTheme.caption(color: c.faint),
                                  ),
                                )
                                    : GridView.builder(
                                  padding: const EdgeInsets.all(12),
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 0.78,
                                  ),
                                  itemCount: all.length,
                                  itemBuilder: (_, i) => _GalleryCard(
                                    photo: all[i],
                                    onTap: () => _viewPhoto(all[i]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _viewPhoto(CameraPhoto p) async {
    final c = context.c;
    final l10n = context.l10n;

    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 36),
          child: ConstrainedBox(
            // Явный потолок высоты — диалог знает свой размер, Flexible работает
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.86,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── фото с фиксированной высотой ─────────────────────
                    SizedBox(
                      height: 180,
                      child: Image.file(
                        File(p.path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => SizedBox(
                          height: 180,
                          child: Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: c.faint,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // ── прокручиваемый текст ──────────────────────────────
                    // Flexible забирает оставшееся место, ScrollView не обрезает
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (p.originalText.isNotEmpty)
                              _textSection(
                                c: c,
                                label: l10n.t('camera_original'),
                                text: p.originalText,
                              ),
                            for (final e in p.translations.entries) ...[
                              const SizedBox(height: 14),
                              _textSection(
                                c: c,
                                label:
                                '${l10n.t('camera_translation')} · ${e.key.toUpperCase()}',
                                text: e.value,
                              ),
                            ],
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),
                    // ── кнопки действий ───────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: c.line)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await CameraRepository.instance.delete(p.id);
                              _snack(l10n.t('camera_deleted'));
                            },
                            child: Text(
                              l10n.t('clear'),
                              style: TextStyle(
                                color: c.warn,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              l10n.t('cancel'),
                              style: TextStyle(
                                color: c.sub,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _textSection({
    required AppColors c,
    required String label,
    required String text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTheme.label(color: c.accent, size: 10),
              ),
            ),
            // Кнопка копирования — важно для переводчика
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: text));
                // snack здесь недоступен напрямую, но текст скопируется
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.copy_rounded, color: c.faint, size: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(text, style: TextStyle(color: c.text, height: 1.45)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;

    return ListenableBuilder(
      listenable: CameraRepository.instance,
      builder: (context, _) {
        final all = CameraRepository.instance.getAll();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: c.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.document_scanner_rounded, color: c.accent, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.t('camera_title'),
                                style: AppTheme.display(size: 19, color: c.text)),
                            const SizedBox(height: 3),
                            Text(l10n.t('camera_subtitle'),
                                style: AppTheme.caption(color: c.faint, size: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: GestureDetector(
                      onTap: _openCamera,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 116,
                        height: 116,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: c.accent.withValues(alpha: 0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(Icons.camera_alt_rounded, color: c.accent, size: 52),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(l10n.t('camera_open'),
                        style: TextStyle(color: c.sub, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ],
              ),
            ),
            _BottomStack(
              c: c,
              all: all,
              emptyLabel: l10n.t('camera_empty'),
              galleryLabel: l10n.t('camera_gallery'),
              onTap: all.isEmpty ? null : _openGallery,
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _CameraPage — с плавным зумом и preprocessing
// ═══════════════════════════════════════════════════════════════════════════
class _CameraPage extends StatefulWidget {
  final bool isProfileMode;
  const _CameraPage({this.isProfileMode = false});
  @override
  State<_CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<_CameraPage> with TickerProviderStateMixin {
  final _tr = OnlineTranslator();
  final _ocr = OcrService();

  CameraController? _controller;
  String? _shotPath;
  bool _processing = false;
  bool _initError = false;

  // ── ЗУМ ──────────────────────────────────────────────────────────────
  final ValueNotifier<double> _zoomNotifier = ValueNotifier<double>(1.0);
  double _zoomLevel = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;

  // Для плавного жеста
  double _baseZoom = 1.0;
  DateTime _lastZoomCall = DateTime.fromMillisecondsSinceEpoch(0);

  // ⚠️ ПОЛЕ переименовано, чтобы не конфликтовать с методом
  bool _zoomIndicatorVisible = false;
  Timer? _zoomHideTimer;

  // Для snap-анимации
  AnimationController? _snapAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _init();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _snapAnim?.dispose();
    _zoomHideTimer?.cancel();
    _zoomNotifier.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) throw Exception('no cameras');
      final back = cams.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      final ctrl = CameraController(back, ResolutionPreset.veryHigh, enableAudio: false);
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      try {
        _minZoom = await ctrl.getMinZoomLevel();
        _maxZoom = await ctrl.getMaxZoomLevel();
        _zoomLevel = _minZoom;
        _zoomNotifier.value = _minZoom;
      } catch (e) {
        debugPrint('[cam] zoom query error: $e');
        _minZoom = 1.0;
        _maxZoom = 5.0;
      }
      setState(() => _controller = ctrl);
    } catch (e) {
      debugPrint('[cam] init error: $e');
      if (mounted) setState(() => _initError = true);
    }
  }

  void _snack(String t, {bool warn = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t),
        backgroundColor: warn ? context.c.warn : context.c.accent,
      ),
    );
  }

  /// Переводит ЛЮБОЙ объём текста: режет на куски по предложениям,
  /// переводит каждый и склеивает обратно. Обход лимитов переводчика.
  Future<String> _translateFull(String text, String to) async {
    final chunks = _splitChunks(text, 450);
    if (chunks.length <= 1) {
      final res = await _tr.translate(text, from: 'auto', to: to);
      return res.text;
    }

    final sb = StringBuffer();
    for (var i = 0; i < chunks.length; i++) {
      try {
        final res = await _tr.translate(chunks[i], from: 'auto', to: to);
        if (i > 0) sb.writeln();
        sb.write(res.text.trim());
      } catch (e) {
        debugPrint('[cam] translate chunk $i error: $e');
      }
    }
    return sb.toString();
  }

  /// Режет текст на куски ≤ [max] символов по границам предложений/строк
  List<String> _splitChunks(String text, int max) {
    final pieces = <String>[];
    for (final line in text.split('\n')) {
      final t = line.trim();
      if (t.isEmpty) continue;
      if (t.length <= max) {
        pieces.add(t);
      } else {
        var rest = t;
        while (rest.length > max) {
          var cut = -1;
          for (final sep in const ['. ', '! ', '? ', ' ']) {
            final i = rest.lastIndexOf(sep, max);
            if (i > cut) cut = i + 1;
          }
          if (cut <= 1) cut = max;
          pieces.add(rest.substring(0, cut).trim());
          rest = rest.substring(cut).trim();
        }
        if (rest.isNotEmpty) pieces.add(rest);
      }
    }

    final chunks = <String>[];
    final buf = StringBuffer();
    for (final p in pieces) {
      if (buf.isNotEmpty && buf.length + p.length + 1 > max) {
        chunks.add(buf.toString());
        buf.clear();
      }
      if (buf.isNotEmpty) buf.write(' ');
      buf.write(p);
    }
    if (buf.isNotEmpty) chunks.add(buf.toString());
    return chunks;
  }

  // ✅ Теперь метод — без конфликта с полем
  void _showZoomIndicator() {
    _zoomHideTimer?.cancel();
    if (!_zoomIndicatorVisible) {
      setState(() => _zoomIndicatorVisible = true);
    }
    _zoomHideTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _zoomIndicatorVisible = false);
    });
  }

  Future<void> _applyZoom(double level) async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    final now = DateTime.now();
    if (now.difference(_lastZoomCall).inMilliseconds < 16) return;
    _lastZoomCall = now;

    final clamped = level.clamp(_minZoom, _maxZoom);
    try {
      await ctrl.setZoomLevel(clamped);
      _zoomLevel = clamped;
      _zoomNotifier.value = clamped;
      _showZoomIndicator();
    } catch (e) {
      debugPrint('[cam] setZoom error: $e');
    }
  }

  void _animateZoomTo(double target) {
    _snapAnim?.dispose();
    _snapAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    final startZoom = _zoomLevel;
    final curve = CurvedAnimation(parent: _snapAnim!, curve: Curves.easeOutCubic);
    curve.addListener(() {
      final v = curve.value;
      final current = startZoom + (target - startZoom) * v;
      _zoomLevel = current;
      _zoomNotifier.value = current;
      _controller?.setZoomLevel(current);
      _showZoomIndicator();
    });
    _snapAnim!.forward();
  }

  void _onScaleStart(ScaleStartDetails d) {
    _snapAnim?.stop();
    _baseZoom = _zoomLevel;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (d.scale != 1.0) {
      final newZoom = (_baseZoom * d.scale).clamp(_minZoom, _maxZoom);
      _applyZoom(newZoom);
    }
  }

  void _onScaleEnd(ScaleEndDetails d) {
    final rounded = _zoomLevel.roundToDouble();
    final diff = (_zoomLevel - rounded).abs();
    if (diff > 0.08 && diff < 0.4 && rounded >= _minZoom && rounded <= _maxZoom) {
      HapticFeedback.lightImpact();
      _animateZoomTo(rounded);
    }
  }

  void _onDoubleTap() {
    HapticFeedback.mediumImpact();
    _animateZoomTo(_minZoom);
  }

  Future<void> _capture() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized || _processing) return;
    try {
      final shot = await ctrl.takePicture();
      final repo = CameraRepository.instance;
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final dest = '${repo.photosDir}/$id.jpg';
      await File(shot.path).copy(dest);

      if (!mounted) return;

      setState(() {
        _controller = null;
        _shotPath = dest;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try { await ctrl.dispose(); } catch (_) {}
      });

      if (widget.isProfileMode) {
        if (mounted) Navigator.of(context).pop(dest);
        return;
      }

      await _process(dest, id);
    } catch (e) {
      debugPrint('[cam] capture error: $e');
      if (mounted) _snack(e.toString(), warn: true);
    }
  }

  Future<void> _process(String path, String id) async {
    try {
      final to = await showLanguagePicker(
        context,
        opts: AppLanguages.all,
        current: context.settings.defaultTo,
      );
      if (!mounted) return;
      if (to == null) {
        try {
          final f = File(path);
          if (await f.exists()) await f.delete();
        } catch (_) {}
        Navigator.of(context).pop();
        return;
      }

      setState(() => _processing = true);

      final original = await _ocr.recognize(path);
      if (!mounted) return;

      String translated = '';
      if (original.isNotEmpty) {
        try {
          translated = await _translateFull(original, to);
        } catch (e) {
          debugPrint('[cam] translate error: $e');
        }
      }
      if (!mounted) return;

      await CameraRepository.instance.add(
        CameraPhoto(
          id: id,
          path: path,
          originalText: original,
          translations: translated.isNotEmpty ? {to: translated} : const {},
          timestamp: DateTime.now(),
        ),
      );
      if (!mounted) return;

      if (original.isEmpty) _snack(context.l10n.t('camera_no_text'), warn: true);
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('[cam] process error: $e');
      if (mounted) {
        setState(() => _processing = false);
        _snack(e.toString(), warn: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final ctrl = _controller;
    final ready = ctrl != null && ctrl.value.isInitialized;
    final shot = _shotPath;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (ready)
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                onDoubleTap: _onDoubleTap,
                child: _CoverPreview(controller: ctrl),
              ),
            )
          else if (shot != null)
            Positioned.fill(
              child: Center(
                child: Image.file(
                  File(shot),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.broken_image_rounded, color: Colors.white54, size: 48),
                ),
              ),
            )
          else
            const ColoredBox(color: Colors.black),

          if (!ready && shot == null && !_initError)
            Center(child: CircularProgressIndicator(color: c.accent)),
          if (_initError && shot == null)
            Center(
              child: Icon(Icons.no_photography_rounded, color: Colors.white54, size: 48),
            ),

          // ✅ Используем новое имя поля
          if (ready && _zoomIndicatorVisible)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: ValueListenableBuilder<double>(
                  valueListenable: _zoomNotifier,
                  builder: (context, zoom, _) {
                    return AnimatedOpacity(
                      opacity: _zoomIndicatorVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${zoom.toStringAsFixed(1)}x',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          if (ready)
            Positioned(
              right: 20,
              top: MediaQuery.of(context).padding.top + 120,
              bottom: MediaQuery.of(context).padding.bottom + 160,
              child: ValueListenableBuilder<double>(
                valueListenable: _zoomNotifier,
                builder: (context, zoom, _) {
                  return _ZoomSlider(
                    c: c,
                    min: _minZoom,
                    max: _maxZoom,
                    value: zoom,
                    onChanged: _applyZoom,
                  );
                },
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 120,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 160,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _roundBtn(c, Icons.arrow_back_rounded, () => Navigator.of(context).pop()),
          ),

          if (ready)
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 34,
              child: Center(
                child: GestureDetector(
                  onTap: _capture,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: c.accent, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(Icons.camera_alt_rounded, color: c.accent, size: 34),
                  ),
                ),
              ),
            ),

          if (_processing)
            Positioned(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom + 40,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: c.line),
                ),
                child: AnalyzingWave(label: context.l10n.t('camera_translating')),
              ),
            ),
        ],
      ),
    );
  }

  Widget _roundBtn(AppColors c, IconData i, VoidCallback t) => Material(
    color: Colors.black.withValues(alpha: 0.35),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: t,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(i, color: Colors.white, size: 24),
      ),
    ),
  );
}

class _ZoomSlider extends StatelessWidget {
  final AppColors c;
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;

  const _ZoomSlider({
    required this.c,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final range = max - min;
    final normalized = range <= 0 ? 0.0 : ((value - min) / range).clamp(0.0, 1.0);

    return SizedBox(
      width: 56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _zoomBtn(Icons.add_rounded, () {
            onChanged((value + 0.5).clamp(min, max));
          }),
          const SizedBox(height: 8),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  activeTrackColor: c.accent,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                  overlayColor: c.accent.withValues(alpha: 0.2),
                ),
                child: Slider(
                  min: 0.0,
                  max: 1.0,
                  value: normalized,
                  onChanged: (v) => onChanged(min + v * range),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _zoomBtn(Icons.remove_rounded, () {
            onChanged((value - 0.5).clamp(min, max));
          }),
          const SizedBox(height: 12),
          if (value != min)
            GestureDetector(
              onTap: () => onChanged(min),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.55),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    '${min.toStringAsFixed(0)}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.45),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    ),
  );
}

class _CoverPreview extends StatelessWidget {
  final CameraController controller;
  const _CoverPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final ps = controller.value.previewSize;
    final upright = (ps != null && ps.longestSide > 0)
        ? ps.shortestSide / ps.longestSide
        : 9 / 16;

    return LayoutBuilder(
      builder: (context, cons) {
        final w = cons.maxWidth;
        final h = cons.maxHeight;
        final screenAspect = w / h;

        double pw, ph;
        if (upright > screenAspect) {
          ph = h;
          pw = h * upright;
        } else {
          pw = w;
          ph = w / upright;
        }

        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            maxWidth: pw,
            maxHeight: ph,
            child: SizedBox(
              width: pw,
              height: ph,
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final CameraPhoto photo;
  final VoidCallback onTap;
  const _GalleryCard({required this.photo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.surfaceHi,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(photo.path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(Icons.broken_image_rounded, color: c.faint, size: 32),
                ),
              ),
            ),
            if (photo.translations.isNotEmpty)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    photo.translations.keys.first.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomStack extends StatelessWidget {
  final AppColors c;
  final List<CameraPhoto> all;
  final String emptyLabel;
  final String galleryLabel;
  final VoidCallback? onTap;
  const _BottomStack({
    required this.c,
    required this.all,
    required this.emptyLabel,
    required this.galleryLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const cardW = 72.0;
    const cardH = 98.0;
    const stackW = 190.0;
    const stackH = 132.0;

    final vis = all.length > 3 ? all.sublist(all.length - 3) : all.toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: SizedBox(
              width: stackW,
              height: stackH,
              child: vis.isEmpty
                  ? Center(child: Icon(Icons.photo_library_outlined, color: c.faint, size: 34))
                  : Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var i = 0; i < vis.length; i++)
                    _fanFor(vis[i], i, vis.length, cardW, cardH, stackW, stackH),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(galleryLabel,
                    style: TextStyle(color: c.text, fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 3),
                Text(all.isEmpty ? emptyLabel : '${all.length}',
                    style: AppTheme.caption(color: c.faint, size: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.sub, size: 26),
        ],
      ),
    );
  }

  Widget _fanFor(
      CameraPhoto p,
      int i,
      int n,
      double cardW,
      double cardH,
      double stackW,
      double stackH,
      ) {
    final t = n == 1 ? 0.5 : i / (n - 1);
    final angle = -14.0 + 28.0 * t;
    final dx = -28.0 + 56.0 * t;
    final dy = 12.0 * ((t - 0.5).abs() * 2);
    final left = stackW / 2 - cardW / 2 + dx;
    final top = stackH / 2 - cardH / 2 + dy;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      left: left,
      top: top,
      width: cardW,
      height: cardH,
      child: _FanCard(photo: p, angleDeg: angle),
    );
  }
}

class _FanCard extends StatefulWidget {
  final CameraPhoto photo;
  final double angleDeg;
  const _FanCard({required this.photo, required this.angleDeg});

  @override
  State<_FanCard> createState() => _FanCardState();
}

class _FanCardState extends State<_FanCard> with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnimatedRotation(
      turns: widget.angleDeg / 360,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      child: AnimatedBuilder(
        animation: _enter,
        builder: (_, __) {
          final e = Curves.easeOutBack.transform(_enter.value);
          return Transform.scale(
            scale: 0.6 + 0.4 * e,
            child: Opacity(
              opacity: _enter.value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: c.surfaceHi,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(widget.photo.path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(Icons.image_rounded, color: c.faint, size: 26),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileGalleryPicker extends StatelessWidget {
  const _ProfileGalleryPicker();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        title: Text('Галерея',
            style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
        iconTheme: IconThemeData(color: c.text),
      ),
      body: ListenableBuilder(
        listenable: CameraRepository.instance,
        builder: (context, _) {
          final all = CameraRepository.instance.getAll();
          if (all.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library_outlined, color: c.faint, size: 64),
                  const SizedBox(height: 12),
                  Text('Нет сохраненных фото', style: TextStyle(color: c.sub)),
                  const SizedBox(height: 8),
                  Text('Сначала сделайте снимок в камере',
                      style: TextStyle(color: c.faint, fontSize: 12)),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: all.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => Navigator.pop(context, all[i].path),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(all[i].path), fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }
}