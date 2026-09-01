import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../native/clip_filter_native.dart';

class ClipFilterChannel {
  static const _channel = MethodChannel('kopri/clip_filter');

  static void listen() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'classify' && call.arguments is Map) {
        final m = Map<String, dynamic>.from(call.arguments as Map);
        final id = m['id'] as int;
        final text = (m['text'] as String?) ?? '';
        final skip = ClipFilterNative.instance.classify(text);
        final should = skip == ClipSkip.translatable;
        debugPrint(
          '[clip_filter] text="${text.length > 40 ? text.substring(0, 40) : text}" → $skip → should=$should',
        );
        try {
          await _channel.invokeMethod('filterResult', {
            'id': id,
            'should': should,
          });
        } catch (_) {}
      }
      return null;
    });
  }
}
