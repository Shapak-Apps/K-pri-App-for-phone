import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef _I32_I32_N = Int32 Function(Int32);
typedef _I32_I32_D = int Function(int);
typedef _F64_I32_N = Double Function(Int32);
typedef _F64_I32_D = double Function(int);

typedef _StreakN = Int32 Function(Pointer<Int32>, Int32, Int32);
typedef _StreakD = int Function(Pointer<Int32>, int, int);
typedef _BestN = Int32 Function(Pointer<Int32>, Int32);
typedef _BestD = int Function(Pointer<Int32>, int);

typedef _PeakN = Int32 Function(Pointer<Int32>, Int32);
typedef _PeakD = int Function(Pointer<Int32>, int);
typedef _WeeklyN = Void Function(Pointer<Int32>, Int32, Int32, Pointer<Int32>);
typedef _WeeklyD = void Function(Pointer<Int32>, int, int, Pointer<Int32>);
typedef _AvgN = Double Function(Pointer<Int32>, Int32);
typedef _AvgD = double Function(Pointer<Int32>, int);

typedef _TopLangN = Int32 Function(Pointer<Pointer<Utf8>>, Int32, Pointer<Utf8>, Int32);
typedef _TopLangD = int Function(Pointer<Pointer<Utf8>>, int, Pointer<Utf8>, int);
typedef _TopPhrN = Int32 Function(Pointer<Pointer<Utf8>>, Int32, Int32, Pointer<Utf8>, Int32);
typedef _TopPhrD = int Function(Pointer<Pointer<Utf8>>, int, int, Pointer<Utf8>, int);

typedef _CsvN = Int32 Function(Pointer<Utf8>, Pointer<Uint8>, Int32);
typedef _CsvD = int Function(Pointer<Utf8>, Pointer<Uint8>, int);
typedef _CountN = Int32 Function(Pointer<Utf8>);
typedef _CountD = int Function(Pointer<Utf8>);

typedef _ResizeN = Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Int32, Int32);
typedef _ResizeD = int Function(Pointer<Utf8>, Pointer<Utf8>, int, int);

class ProfileNativeBindings {
  late final DynamicLibrary _lib;

  late final _I32_I32_D level, xpNext, xpCurrent;
  late final _F64_I32_D levelProgress;
  late final _StreakD streakCurrent;
  late final _BestD streakBest;
  late final _PeakD peakHour;
  late final _WeeklyD weeklyCounts;
  late final _AvgD avgLength;
  late final _TopLangD topLanguage;
  late final _TopPhrD topPhrases;
  late final _CsvD jsonToCsv;
  late final _CountD jsonCount;
  late final _ResizeD imageResize;

  ProfileNativeBindings() {
    _lib = Platform.isAndroid
        ? DynamicLibrary.open('libprofile_native.so')
        : DynamicLibrary.process();

    level         = _lib.lookupFunction<_I32_I32_N, _I32_I32_D>('pn_level');
    xpNext        = _lib.lookupFunction<_I32_I32_N, _I32_I32_D>('pn_xp_next');
    xpCurrent     = _lib.lookupFunction<_I32_I32_N, _I32_I32_D>('pn_xp_current');
    levelProgress = _lib.lookupFunction<_F64_I32_N, _F64_I32_D>('pn_level_progress');
    streakCurrent = _lib.lookupFunction<_StreakN, _StreakD>('pn_streak_current');
    streakBest    = _lib.lookupFunction<_BestN, _BestD>('pn_streak_best');
    peakHour      = _lib.lookupFunction<_PeakN, _PeakD>('pn_peak_hour');
    weeklyCounts  = _lib.lookupFunction<_WeeklyN, _WeeklyD>('pn_weekly_counts');
    avgLength     = _lib.lookupFunction<_AvgN, _AvgD>('pn_avg_length');
    topLanguage   = _lib.lookupFunction<_TopLangN, _TopLangD>('pn_top_language');
    topPhrases    = _lib.lookupFunction<_TopPhrN, _TopPhrD>('pn_top_phrases');
    jsonToCsv     = _lib.lookupFunction<_CsvN, _CsvD>('pn_json_to_csv');
    jsonCount     = _lib.lookupFunction<_CountN, _CountD>('pn_json_count');
    imageResize   = _lib.lookupFunction<_ResizeN, _ResizeD>('pn_image_resize');
  }
}