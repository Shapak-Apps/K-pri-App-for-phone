import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import '../../phrasebook/data/phrasebook_data.dart';
import 'mt_wordlist_data.dart';
import 'native/mt_native.dart';

class MtHit {
  final String text;
  final int quality;
  const MtHit(this.text, this.quality);
}

class MtService {
  static final MtService instance = MtService._();
  MtService._();

  final _n = MtNative.instance;
  bool _loaded = false;
  bool _failed = false;

  void _ensureLoaded() {
    if (_loaded || _failed || !_n.available) return;

    final ru = <String>[];
    final en = <String>[];
    final tk = <String>[];
    final tr = <String>[];

    for (final cat in phrasebook) {
      for (final sub in cat.s) {
        for (final p in sub.p) {
          if (p.tk.trim().isEmpty) continue;
          ru.add(p.ru);
          en.add(p.en);
          tk.add(p.tk);
          tr.add('');
        }
      }
    }

    for (final w in mtWordlist) {
      if (w.tk.trim().isEmpty) continue;
      ru.add(w.ru);
      en.add(w.en);
      tk.add(w.tk);
      tr.add(w.tr);
    }

    final n = ru.length;
    if (n == 0) {
      _failed = true;
      return;
    }

    final pRu = calloc<Pointer<Utf8>>(n);
    final pEn = calloc<Pointer<Utf8>>(n);
    final pTk = calloc<Pointer<Utf8>>(n);
    final pTr = calloc<Pointer<Utf8>>(n);
    final keep = <Pointer<Utf8>>[];
    try {
      for (int i = 0; i < n; i++) {
        pRu[i] = ru[i].toNativeUtf8();
        pEn[i] = en[i].toNativeUtf8();
        pTk[i] = tk[i].toNativeUtf8();
        pTr[i] = tr[i].toNativeUtf8();
        keep.add(pRu[i]);
        keep.add(pEn[i]);
        keep.add(pTk[i]);
        keep.add(pTr[i]);
      }
      final r = _n.load(n, pRu, pEn, pTk, pTr);
      _loaded = (r == 0);
      debugPrint('[mt] loaded $n phrases+words → ${_loaded ? "OK" : "FAIL"}');
    } catch (e) {
      debugPrint('[mt] load error: $e');
      _loaded = false;
    } finally {
      for (final p in keep) {
        calloc.free(p);
      }
      calloc.free(pRu);
      calloc.free(pEn);
      calloc.free(pTk);
      calloc.free(pTr);
    }
    if (!_loaded) _failed = true;
  }

  MtHit? translate(String text, String srcLang) {
    _ensureLoaded();
    if (!_loaded) return null;

    final pText = text.toNativeUtf8();
    final pFrom = srcLang.toNativeUtf8();
    final out = calloc<Uint8>(8192);
    final q = calloc<Int32>(1);
    try {
      final len = _n.translate(pText, pFrom, out, 8192, q);
      if (len < 0) return null;
      return MtHit(out.cast<Utf8>().toDartString(), q.value);
    } catch (e) {
      debugPrint('[mt] translate error: $e');
      return null;
    } finally {
      calloc.free(pText);
      calloc.free(pFrom);
      calloc.free(out);
      calloc.free(q);
    }
  }
}
