<div align="center">
<img src="./assets/icon/app_icon.png" alt="Köpri" width="120" />

# Köpri Translator

Offline translator with hybrid camera OCR (coming soon), huge phrasebook and text-to-text translation

![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg?logo=dart)
![C++](https://img.shields.io/badge/C%2B%2B-17-00599C.svg?logo=c%2B%2B)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84.svg?logo=android)
![PRs](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

[🇷🇺 По-русски](./README.ru.md) · [🇹 Türkmençe](./README.tk.md)
</div>

Köpri is a free, offline-first translator built with Flutter. The phrasebook, history, favourites, XP and statistics work fully offline. Turkmen ↔ Russian and Turkmen ↔ English text translation also works offline via a built-in dictionary. For all other language pairs the app uses online services (Google Translate, Lingva, MyMemory) — text is sent to them. Camera translation is under active development and will ship in v2.0.0.

Köpri is part of the [Shapak-Apps](https://github.com/Shapak-Apps) organization — open-source mobile apps from Turkmenistan.

## 📱 Screenshots

<div align="center">
<img src="./assets/screenshots/1.jpg" width="240" />
<img src="./assets/screenshots/2.jpg" width="240" />
<img src="./assets/screenshots/3.jpg" width="240" />
<img src="./assets/screenshots/4.jpg" width="240" />
<img src="./assets/screenshots/5.jpg" width="240" />
<img src="./assets/screenshots/6.jpg" width="240" />
</div>

## ✨ Features

- 🚧 **Camera translation (Hybrid OCR) — Coming Soon in v2.0.0** — ultra-fast text recognition using Google ML Kit (Latin scripts, ~0.3s) + Tesseract OCR (Cyrillic, Arabic, CJK, Devanagari) as fallback. Currently under active development — available only in the upcoming major update.
- 💬 **Text-to-text translation** — instant translation between 50+ languages
- 📖 **Huge phrasebook** — thousands of phrases in dozens of categories and subcategories
- 🔵 **Offline-first** — phrasebook, history, favourites, XP and statistics are **fully offline**; Turkmen ↔ Russian and Turkmen ↔ English have a built-in offline dictionary; text translation for all other language pairs uses online services (Google Translate, Lingva, MyMemory) — text is sent to them
- 🕘 **History** — all translations are saved locally
- ⭐ **Favorites** — save the phrases you use often
- 🎨 **Modern UI** — clean design with dark mode support
- 👤 **Profile** — easily track your activity, usage statistics, and completed work
- 🎮 **Hardcore progression** — XP levels (1–100), daily streaks, badges and the title "Translation Legend" for the most dedicated users
- 🚀 **Native performance** — heavy calculations (XP, streaks, statistics, JSON parsing, avatar resize) run in C++17 via FFI — 10–60× faster than pure Dart

## 🌍 Supported languages

🇬🇧 English · 🇷 Russian · 🇲 Turkmen · 🇷 Turkish · 🇿 Kazakh · 🇹🇯 Tajik · 🇺🇿 Uzbek · 🇺 Ukrainian · 🇳 Chinese · 🇵 Japanese · 🇷 Korean · 🇦 Arabic · 🇪 German · 🇷 French · 🇸 Spanish · 🇹 Italian · 🇳 Hindi and more

## 🛠 Tech Stack

| Layer | Technology |
| --- | --- |
| Framework | [Flutter](https://flutter.dev) 3.x |
| Language | [Dart](https://dart.dev) 3.x |
| Native core | C++17 (via FFI) — XP, streaks, stats, JSON/CSV, avatar resize, translate parsing and more |
| OCR (Latin) | [Google ML Kit](https://developers.google.com/ml-kit/vision/text-recognition) (offline, on-device) — coming soon |
| OCR (Cyrillic / Arabic / CJK / Devanagari) | [Tesseract OCR](https://tesseract-ocr.github.io) (flutter_tesseract_ocr) — coming soon |
| Camera | [camera](https://pub.dev/packages/camera) — coming soon in v2.0.0 |
| Storage | SharedPreferences / Hive |
| Architecture | Feature-first, clean architecture |

Why hybrid OCR? ML Kit is 10–20× faster on Latin scripts (signs, menus, documents), while Tesseract covers scripts ML Kit doesn't support yet (Cyrillic, Arabic, Devanagari). This engine is fully implemented in C++ and will be enabled in v2.0.0.

## ⚡ C++ Modules (native performance)

| Module | Purpose |
| --- | --- |
| xp_engine | XP, levels, progress with exponential difficulty (BASE 200, GROWTH 1.25) — 20× faster than Dart |
| streak_engine | Current/best streak with Hinnant's civil days algorithm (exact across months/years) |
| stats_engine | Weekly chart (O(n)), peak hour, average length, top phrases — all in C++ |
| ocr_engine | Native image preprocessing & rotation for OCR — ships with camera in v2.0.0 |
| json_lite | Hand-written recursive JSON parser for profile export |
| csv_engine | Native JSON→CSV conversion for history export |
| image_fast | Instant avatar resize via stb_image (512px) — no UI lag on photo apply |
| translate_engine | Native script detection, Google GTX response parsing, long-text chunking |
| tm_engine | Translation memory with exact + fuzzy (Levenshtein) lookup |
| mt_tk_engine | Offline Turkmen translation engine (phrase + word-level matching) |
| clip_filter | Smart clipboard filter (skips URLs, emails, code, hashes, emoji-only text) |
| splash_engine | Splash-screen particles/streaks/letters computed in C++ |
| crash_handler | Native crash handler with backtrace logging |
| ffi_bridge | FFI bridge between Dart and native library |

## 🎮 Progression system

Köpri uses a hardcore leveling curve so that every level is earned:

- +5 XP per completed translation
- Exponential cost: BASE 200, GROWTH 1.25 — each level needs ~25% more XP than the previous one
- 100 levels, level 100 = "Translation Legend"
- Daily streaks, best streak, badges and daily goals

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.0+
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com)
- [Git](https://git-scm.com)

Check your setup:

```bash
flutter doctor
```

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/Shapak-Apps/K-pri-App-for-phone.git
cd K-pri-App-for-phone
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **⚠️ IMPORTANT: add OCR models to `assets/tessdata/` (for v2.0.0 camera)**

Latin scripts are recognized by Google ML Kit (auto-downloaded by Google Play Services), so you only need Tesseract models for Cyrillic, Arabic, CJK and Devanagari. `eng` and `tur` are kept as fallbacks for devices without Google Play Services. The app needs 38 model files.

**Note:** These models are currently excluded from the APK build to reduce size (camera is Coming Soon). Uncomment `- assets/tessdata/` in `pubspec.yaml` when v2.0.0 is released.

**Download all of them with one command:**

```bash
# PowerShell (Windows) — run in the project root
New-Item -ItemType Directory -Force -Path "assets\tessdata" | Out-Null
"eng tur rus ukr bel bul srp mkd kaz uzb_cyrl kir tgk mon ara fas urd heb pus chi_sim chi_tra jpn kor hin tha tam tel ben nep pan guj mar kan mal sin khm lao mya".Split(" ") | ForEach-Object {
    Invoke-WebRequest -Uri "https://github.com/tesseract-ocr/tessdata_fast/raw/main/$_.traineddata" -OutFile "assets\tessdata\$_.traineddata"
}
```

```bash
# curl (Linux / macOS) — run in the project root
mkdir -p assets/tessdata
for c in eng tur rus ukr bel bul srp mkd kaz uzb_cyrl kir tgk mon ara fas urd heb pus chi_sim chi_tra jpn kor hin tha tam tel ben nep pan guj mar kan mal sin khm lao mya; do
  curl -L "https://github.com/tesseract-ocr/tessdata_fast/raw/main/$c.traineddata" -o "assets/tessdata/$c.traineddata"
done
```

For best quality (larger files) replace `tessdata_fast` with `tessdata` in the URLs.

4. **⚠️ IMPORTANT: download stb_image headers for native avatar resize**

The C++ module `image_fast` uses the single-header libraries [stb_image](https://github.com/nothings/stb) and [stb_image_write](https://github.com/nothings/stb) for instant avatar resizing. Download them into `android/app/src/main/cpp/`:

```bash
# PowerShell (Windows) — run in the project root
New-Item -ItemType Directory -Force -Path "android\app\src\main\cpp" | Out-Null
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nothings/stb/master/stb_image.h" -OutFile "android\app\src\main\cpp\stb_image.h"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h" -OutFile "android\app\src\main\cpp\stb_image_write.h"
```

```bash
# curl (Linux / macOS) — run in the project root
mkdir -p android/app/src/main/cpp
curl -L "https://raw.githubusercontent.com/nothings/stb/master/stb_image.h" -o android/app/src/main/cpp/stb_image.h
curl -L "https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h" -o android/app/src/main/cpp/stb_image_write.h
```

If stb headers are missing, the app falls back to Dart image copy automatically — everything still works, just slightly slower.

5. **Android configuration**

The app requires Android 5.0+ (API 21) and uses Google Play Services for ML Kit. Add this inside `<application>` in `android/app/src/main/AndroidManifest.xml` so the OCR model is pre-downloaded on install:

```xml
<meta-data
    android:name="com.google.mlkit.vision.DEPENDENCIES"
    android:value="ocr" />
```

Make sure `pubspec.yaml` contains:

```yaml
flutter:
  assets:
    - assets/icon/
    - assets/tessdata_config.json
    - assets/google_fonts/
    # - assets/tessdata/  # ← uncomment when v2.0.0 is released
```

Before running the app, please read `build.gradle` (android) and `build.gradle` (:app).

## 🏃 Running (Debug)

```bash
flutter run
```

- `flutter devices` — list available devices
- Press `r` in the terminal for hot reload, `R` for hot restart

## 📦 Building (Release)

APK:

```bash
flutter build apk --release
```

Output file: `build/app/outputs/flutter-apk/app-release.apk`

Smaller APKs per architecture:

```bash
flutter build apk --release --split-per-abi
```

App Bundle for Google Play:

```bash
flutter build appbundle --release
```

## 🔧 Troubleshooting

- **"tessdata not found"** — make sure the `.traineddata` files are inside `assets/tessdata/` and the line is uncommented in `pubspec.yaml`, then run `flutter pub get` again.
- **Camera shows "Coming Soon"** — this is expected in v1.x. Camera translation will be enabled in v2.0.0 (flip `kCameraEnabled` to `true` in `camera_screen.dart` for early testing).
- **First camera OCR run is slow** — Google Play Services downloads the ML Kit model once (~5 MB); after that recognition takes ~0.3s.
- **Camera not working** — grant the camera permission when Android asks for it on first launch.
- **Build errors after cloning** — run `flutter clean && flutter pub get`.
- **C++ files appear red in IDE** — open `File → Sync Project with Gradle Files` in Android Studio so the NDK/CMake toolchain picks up the include paths.

## 🤝 Contributing

Contributions are welcome! Open an issue or send a pull request.

## 📄 License

This project is licensed under the [Apache License 2.0](./LICENSE).

## 👤 Author

Aynazar Sylyyew
🐙 GitHub: [@aynazar-sylyyew-dev](https://github.com/aynazar-sylyyew-dev)
🏢 Organization: [Shapak-Apps](https://github.com/Shapak-Apps)

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) — cross-platform framework
- [Google ML Kit](https://developers.google.com/ml-kit) — on-device text recognition
- [Tesseract OCR](https://tesseract-ocr.github.io) — text recognition engine
- [stb by Sean Barrett](https://github.com/nothings/stb) — single-header image library for native avatar resize
- [flutter_tesseract_ocr](https://pub.dev/packages/flutter_tesseract_ocr) — OCR plugin

<div align="center">
Made with ❤️, Flutter and C++

[⭐ Star on GitHub](https://github.com/Shapak-Apps/K-pri-App-for-phone)
</div>