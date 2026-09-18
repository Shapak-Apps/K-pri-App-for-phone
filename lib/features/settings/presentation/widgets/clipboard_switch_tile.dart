import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/native/apk_channel.dart';
import '../../../../core/theme/app_colors.dart';
import 'settings_controls.dart';

/// Toggle for the background clipboard-translation overlay service.
///
/// FIX: uses the shared [kApkChannel] instead of a private duplicate
/// MethodChannel declaration.
class ClipboardSwitchTile extends StatefulWidget {
  final AppColors c;
  final bool isDark;
  const ClipboardSwitchTile({super.key, required this.c, required this.isDark});

  @override
  State<ClipboardSwitchTile> createState() => _ClipboardSwitchTileState();
}

class _ClipboardSwitchTileState extends State<ClipboardSwitchTile> {
  bool _on = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      kApkChannel.invokeMethod<bool>('isClipboardRunning').then((v) {
        if (mounted) setState(() => _on = v == true);
      });
    }
  }

  String get _title => switch (context.settings.lang) {
    AppLang.ru => 'Перевод из буфера',
    AppLang.en => 'Clipboard translate',
    AppLang.tk => 'Buferden terjime',
    AppLang.tr => 'Panodan çeviri',
  };

  String get _desc => switch (context.settings.lang) {
    AppLang.ru =>
      'Копируй текст в любом приложении — Köpri покажет перевод поверх экрана',
    AppLang.en => 'Copy text in any app — Köpri shows the translation on top',
    AppLang.tk =>
      'Islendik programmada tekst göçür — Köpri terjimäni ekranyň üstünde görkezer',
    AppLang.tr =>
      'Herhangi bir uygulamada metni kopyala — Köpri çeviriyi ekranın üstünde gösterir',
  };

  Future<void> _toggle(bool v) async {
    if (_busy || !Platform.isAndroid) return;
    setState(() => _busy = true);
    try {
      if (v) {
        final can =
            await kApkChannel.invokeMethod<bool>('canDrawOverlays') == true;
        if (!can) {
          await kApkChannel.invokeMethod('openOverlaySettings');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(switch (context.settings.lang) {
                  AppLang.ru =>
                    'Разреши «Показ поверх окон», затем включи снова',
                  AppLang.en =>
                    'Allow "Display over other apps", then turn on again',
                  AppLang.tk =>
                    '"Beýleki programmalaryň üstünde" rugsadyny ber, soň ýene aç',
                  AppLang.tr =>
                    '"Diğer uygulamaların üzerinde göster" iznini ver, sonra tekrar aç',
                }),
                backgroundColor: context.c.warn,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
          }
        } else {
          final ok = await kApkChannel.invokeMethod<bool>('startClipboard', {
            'source': context.settings.defaultFrom,
            'target': context.settings.defaultTo,
          });
          if (ok == true && mounted) setState(() => _on = true);
        }
      } else {
        await kApkChannel.invokeMethod('stopClipboard');
        if (mounted) setState(() => _on = false);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) return const SizedBox.shrink();
    return NeoSwitchTile(
      c: widget.c,
      isDark: widget.isDark,
      icon: Icons.content_paste_rounded,
      iconColor: const Color(0xFF06B6D4),
      title: _title,
      subtitle: _desc,
      value: _on,
      onChanged: _toggle,
    );
  }
}
