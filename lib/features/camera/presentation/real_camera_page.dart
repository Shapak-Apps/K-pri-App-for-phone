import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/analyzing_wave.dart';
import '../../../core/widgets/linkage_language_picker.dart';
import '../../translate/data/translator_service.dart';
import '../data/camera_photo_model.dart';
import '../data/camera_repository.dart';
import '../data/ocr_service.dart';
import '../widgets/cover_preview.dart';
import '../widgets/zoom_slider.dart';

/// Full-screen camera page: live preview with pinch/double-tap zoom,
/// capture, OCR and chunked translation of the recognized text.
///
/// In profile mode ([isProfileMode]) the page skips OCR and simply
/// returns the captured image path to the caller.
class RealCameraPage extends StatefulWidget {
  final bool isProfileMode;
  const RealCameraPage({this.isProfileMode = false});
  @override
  State<RealCameraPage> createState() => _RealCameraPageState();
}

class _RealCameraPageState extends State<RealCameraPage>
    with TickerProviderStateMixin {
  /// Owned by this page; its HTTP client MUST be closed in [dispose].
  final _tr = OnlineTranslator();
  final _ocr = OcrService();

  CameraController? _controller;
  String? _shotPath;
  bool _processing = false;
  bool _initError = false;

  final ValueNotifier<double> _zoomNotifier = ValueNotifier<double>(1.0);
  double _zoomLevel = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _baseZoom = 1.0;
  DateTime _lastZoomCall = DateTime.fromMillisecondsSinceEpoch(0);
  bool _zoomIndicatorVisible = false;
  Timer? _zoomHideTimer;
  AnimationController? _snapAnim;
  CurvedAnimation? _zoomCurve;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _init();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    // FIX: release the socket pool held by this page's translator instance.
    _tr.close();
    _controller?.dispose();
    // FIX: dispose the curved animation before its parent controller.
    _zoomCurve?.dispose();
    _snapAnim?.dispose();
    _zoomHideTimer?.cancel();
    _zoomNotifier.dispose();
    super.dispose();
  }

  /// Enumerates cameras, initializes the back camera and queries zoom range.
  Future<void> _init() async {
    CameraController? ctrl;
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) throw Exception('no cameras');
      if (!mounted) return;

      final back = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );

      ctrl = CameraController(
        back,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      await ctrl.initialize();

      if (!mounted) return;

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
      ctrl = null;
    } catch (e) {
      debugPrint('[cam] init error: $e');
      if (mounted) setState(() => _initError = true);
    } finally {
      // Guard against leaking a half-initialized controller on failure.
      if (ctrl != null) {
        try {
          await ctrl.dispose();
        } catch (_) {}
      }
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

  /// Translates [text] in chunks that fit into provider limits.
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

  /// Splits OCR output into translation-sized chunks on line/sentence bounds.
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

  // ───────────────────────────────────────────────────────────────────────────
  // Zoom handling
  // ───────────────────────────────────────────────────────────────────────────

  void _showZoomIndicator() {
    _zoomHideTimer?.cancel();
    if (!_zoomIndicatorVisible) setState(() => _zoomIndicatorVisible = true);
    _zoomHideTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _zoomIndicatorVisible = false);
    });
  }

  /// Applies [level] zoom with a 16 ms throttle to avoid flooding the plugin.
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

  /// Smoothly snaps the zoom level to [target] (used after pinch-end).
  void _animateZoomTo(double target) {
    _snapAnim?.dispose();
    _zoomCurve?.dispose();
    _snapAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    final startZoom = _zoomLevel;
    _zoomCurve = CurvedAnimation(
      parent: _snapAnim!,
      curve: Curves.easeOutCubic,
    );
    _zoomCurve!.addListener(() {
      final current = startZoom + (target - startZoom) * _zoomCurve!.value;
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
      _applyZoom((_baseZoom * d.scale).clamp(_minZoom, _maxZoom));
    }
  }

  void _onScaleEnd(ScaleEndDetails d) {
    final rounded = _zoomLevel.roundToDouble();
    final diff = (_zoomLevel - rounded).abs();
    if (diff > 0.08 &&
        diff < 0.4 &&
        rounded >= _minZoom &&
        rounded <= _maxZoom) {
      HapticFeedback.lightImpact();
      _animateZoomTo(rounded);
    }
  }

  void _onDoubleTap() {
    HapticFeedback.mediumImpact();
    _animateZoomTo(_minZoom);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Capture & processing pipeline
  // ───────────────────────────────────────────────────────────────────────────

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
      // Dispose the controller after the frame so the preview texture
      // is not destroyed while still being composited.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await ctrl.dispose();
        } catch (_) {}
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

  /// Asks for the target language, runs OCR, translates and persists result.
  Future<void> _process(String path, String id) async {
    try {
      final to = await LinkageLanguagePicker.show(
        context,
        currentCode: context.settings.defaultTo,
        includeAuto: false,
      );
      if (!mounted) return;
      if (to == null) {
        // User cancelled: drop the temporary capture and leave the page.
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
      if (original.isEmpty) {
        _snack(context.l10n.t('camera_no_text'), warn: true);
      }
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('[cam] process error: $e');
      if (mounted) {
        setState(() => _processing = false);
        _snack(e.toString(), warn: true);
      }
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // UI
  // ───────────────────────────────────────────────────────────────────────────

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
                child: CameraCoverPreview(controller: ctrl),
              ),
            )
          else if (shot != null)
            Positioned.fill(
              child: Center(
                child: Image.file(
                  File(shot),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            )
          else
            const ColoredBox(color: Colors.black),
          if (!ready && shot == null && !_initError)
            Center(child: CircularProgressIndicator(color: context.c.accent)),
          if (_initError && shot == null)
            const Center(
              child: Icon(
                Icons.no_photography_rounded,
                color: Colors.white54,
                size: 48,
              ),
            ),
          if (ready && _zoomIndicatorVisible)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: ValueListenableBuilder<double>(
                  valueListenable: _zoomNotifier,
                  builder: (context, zoom, _) => AnimatedOpacity(
                    opacity: _zoomIndicatorVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                  ),
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
                builder: (context, zoom, _) => CameraZoomSlider(
                  c: c,
                  min: _minZoom,
                  max: _maxZoom,
                  value: zoom,
                  onChanged: _applyZoom,
                ),
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
            child: _roundBtn(
              c,
              Icons.arrow_back_rounded,
              () => Navigator.of(context).pop(),
            ),
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
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: c.accent,
                      size: 34,
                    ),
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
                child: AnalyzingWave(
                  label: context.l10n.t('camera_translating'),
                ),
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
