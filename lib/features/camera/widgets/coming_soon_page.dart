import 'package:flutter/material.dart';

import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../presentation/camera_constants.dart';

/// Full-screen animated placeholder shown while the camera feature
/// is under development.
class CameraComingSoonPage extends StatefulWidget {
  const CameraComingSoonPage();
  @override
  State<CameraComingSoonPage> createState() => _CameraComingSoonPageState();
}

class _CameraComingSoonPageState extends State<CameraComingSoonPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _float.dispose();
    super.dispose();
  }

  String _titleText(String lang) => switch (lang) {
    'ru' => 'Скоро в v$kCameraComingSoonVersion',
    'en' => 'Coming Soon in v$kCameraComingSoonVersion',
    'tk' => 'v$kCameraComingSoonVersion-de ýakyn wagtda',
    'tr' => 'v$kCameraComingSoonVersion\'de Yakında',
    _ => 'Coming Soon in v$kCameraComingSoonVersion',
  };

  String _subtitleText(String lang) => switch (lang) {
    'ru' => 'Перевод через камеру',
    'en' => 'Camera Translation',
    'tk' => 'Kamera terjimesi',
    'tr' => 'Kamera Çevirisi',
    _ => 'Camera Translation',
  };

  String _msgText(String lang) => switch (lang) {
    'ru' =>
      'Эта функция находится в активной разработке и будет доступна в следующем крупном обновлении приложения.',
    'en' =>
      'This feature is under active development and will be available in the next major app update.',
    'tk' =>
      'Bu funksiýa işjeň işlenip düzülýär we indiki uly täzelenişde elýeterli bolar.',
    'tr' =>
      'Bu özellik aktif olarak geliştirilmektedir ve bir sonraki büyük güncellemede kullanılabilir olacak.',
    _ =>
      'This feature is under active development and will be available in the next major app update.',
  };

  String _hintText(String lang) => switch (lang) {
    'ru' => 'Следите за обновлениями!',
    'en' => 'Stay tuned for updates!',
    'tk' => 'Täzelenmelere garaşyň!',
    'tr' => 'Güncellemeleri takip edin!',
    _ => 'Stay tuned for updates!',
  };

  String _versionLabel(String lang) => switch (lang) {
    'ru' => 'Версия',
    'en' => 'Version',
    'tk' => 'Wersiýa',
    'tr' => 'Sürüm',
    _ => 'Version',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final lang = context.settings.lang.name;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _float,
            builder: (_, __) {
              final dy = 20.0 * Curves.easeInOut.transform(_float.value);
              return Positioned(
                top: -100 + dy,
                right: -80,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        c.accent.withValues(alpha: dark ? 0.25 : 0.18),
                        c.accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _float,
            builder: (_, __) {
              final dy = 15.0 * Curves.easeInOut.transform(1 - _float.value);
              return Positioned(
                bottom: -60 + dy,
                left: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        c.accent.withValues(alpha: dark ? 0.2 : 0.12),
                        c.accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.surface,
                    border: Border.all(color: c.line),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: c.text,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  AnimatedBuilder(
                    animation: _float,
                    builder: (_, __) {
                      final offset =
                          12.0 * Curves.easeInOut.transform(_float.value);
                      return Transform.translate(
                        offset: Offset(0, -offset),
                        child: AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, __) {
                            final scale =
                                1.0 +
                                0.08 * Curves.easeInOut.transform(_pulse.value);
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      c.accent.withValues(alpha: 0.28),
                                      c.accent.withValues(alpha: 0.08),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: c.accent.withValues(alpha: 0.4),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: c.accent.withValues(alpha: 0.3),
                                      blurRadius: 40,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.rocket_launch_rounded,
                                  color: c.accent,
                                  size: 72,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: c.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: c.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          color: c.accent,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _subtitleText(lang),
                          style: TextStyle(
                            color: c.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _titleText(lang),
                    style: TextStyle(
                      color: c.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _msgText(lang),
                    style: TextStyle(color: c.sub, height: 1.5, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 2),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: c.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: c.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: c.accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _hintText(lang),
                            style: TextStyle(
                              color: c.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_versionLabel(lang)} $kCameraComingSoonVersion',
                        style: TextStyle(
                          color: c.faint,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
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
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
