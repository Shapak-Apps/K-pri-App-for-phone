import 'package:flutter/services.dart';
import 'incoming_text.dart';

class IntentChannel {
  static const _channel = MethodChannel('kopri/intent');

  static void listen() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onText' && call.arguments is Map) {
        final m = Map<String, dynamic>.from(call.arguments as Map);
        final text = (m['text'] as String?)?.trim() ?? '';
        final id = (m['id'] as int?) ?? DateTime.now().millisecondsSinceEpoch;
        if (text.isNotEmpty) {
          incomingText.value = IncomingText(text, id);
        }
      }
      if (call.method == 'openScreen' && call.arguments is int) {
        openScreen.value = call.arguments as int;
      }
      return null;
    });
  }

  static Future<int?> getPendingScreen() async {
    try {
      return await _channel.invokeMethod<int>('getPendingScreen');
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getPendingText() async {
    try {
      return await _channel.invokeMethod<String>('getPendingText');
    } catch (_) {
      return null;
    }
  }
}
