<div align="center">

<img src="./assets/icon/app_icon.png" alt="Köpri" width="120" />

# Kopri Translator

Offline translator with camera OCR, huge phrasebook and text-to-text translation

![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84.svg?logo=android)
![PRs](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

[🇷🇺 По-русски](./README.ru.md) · [🇹🇲 Türkmençe](./README.tk.md)

</div>

---

**Köpri** is a free, offline-first translator built with Flutter. Point your camera at any text, translate text-to-text, or open the huge phrasebook — everything works without internet.

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

 **Camera translation (OCR)** — recognize text from photos, signs and documents via Tesseract OCR
💬 **Text-to-text translation** — instant translation between 50+ languages
📖 **Huge phrasebook** — thousands of phrases in dozens of categories and subcategories
📴 **Fully offline** — no internet required, your data never leaves the device
🕘 **History** — all translations are saved locally
⭐ **Favorites** — save the phrases you use often
🎨 **Modern UI** — clean design with dark mode support

### 🌍 Supported languages

🇬🇧 English · 🇷🇺 Russian · 🇹 Turkmen · 🇹🇷 Turkish · 🇿 Kazakh · 🇹🇯 Tajik · 🇺🇿 Uzbek · 🇺🇦 Ukrainian · 🇨🇳 Chinese · 🇯🇵 Japanese · 🇰 Korean · 🇪 Arabic · 🇪 German · 🇷 French · 🇸 Spanish · 🇹 Italian · 🇮🇳 Hindi and more

## 🛠 Tech Stack

| Layer | Technology |
| --- | --- |
| Framework | [Flutter](https://flutter.dev) 3.x |
| Language | [Dart](https://dart.dev) 3.x |
| OCR | [Tesseract OCR](https://tesseract-ocr.github.io) (flutter_tesseract_ocr) |
| Camera | [camera](https://pub.dev/packages/camera) |
| Storage | SharedPreferences / Hive |
| Architecture | Feature-first, clean architecture |

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

**1. Clone the repository**

```bash
git clone https://github.com/aynazar-sylyyew-dev/K-pri-App-for-phone.git
cd K-pri-App-for-phone
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. ⚠️ IMPORTANT: add OCR models to `assets/tessdata/`**

The app recognizes text with Tesseract. The model files (`*.traineddata`) are **not included in this repository** because of their large size — you must place them into the `assets/tessdata/` folder yourself.

Download the languages you need:
- Fast models (smaller): https://github.com/tesseract-ocr/tessdata_fast
- Best quality (larger): https://github.com/tesseract-ocr/tessdata

```bash
# PowerShell (Windows)
Invoke-WebRequest -Uri "https://github.com/tesseract-ocr/tessdata_fast/raw/main/rus.traineddata" -OutFile "assets/tessdata/rus.traineddata"
Invoke-WebRequest -Uri "https://github.com/tesseract-ocr/tessdata_fast/raw/main/eng.traineddata" -OutFile "assets/tessdata/eng.traineddata"

# curl (Linux / macOS)
curl -L "https://github.com/tesseract-ocr/tessdata_fast/raw/main/rus.traineddata" -o "assets/tessdata/rus.traineddata"
```

Language codes: `eng`, `rus`, `tur`, `kaz`, `tgk`, `tha`, `ukr`, `urd`, `uzb_cyrl`, `vie`, `ara`, `chi_sim`, `chi_tra`, `deu`, `fra`, `spa`, `jpn`, `kor` and more.

Make sure `pubspec.yaml` contains:

```yaml
flutter:
  assets:
    - assets/tessdata/
    - assets/icon/
```

## 🏃 Running (Debug)

```bash
flutter run
```

- `flutter devices` — list available devices
- Press `r` in the terminal for hot reload, `R` for hot restart

## 📦 Building (Release)

**APK:**

```bash
flutter build apk --release
```

Output file: `build/app/outputs/flutter-apk/app-release.apk`

**Smaller APKs per architecture:**

```bash
flutter build apk --release --split-per-abi
```

**App Bundle for Google Play:**

```bash
flutter build appbundle --release
```

## 🔧 Troubleshooting

- **"tessdata not found"** — make sure the `.traineddata` files are inside `assets/tessdata/`, then run `flutter pub get` again.
- **Camera not working** — grant the camera permission when Android asks for it on first launch.
- **Build errors after cloning** — run `flutter clean && flutter pub get`.

## 🤝 Contributing

Contributions are welcome! Open an issue or send a pull request.

## 📄 License

This project is licensed under the [Apache License 2.0](./LICENSE).

## 👤 Author

**Aynazar Sylyyew**
🐙 GitHub: [@aynazar-sylyyew-dev](https://github.com/aynazar-sylyyew-dev)

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) — cross-platform framework
- [Tesseract OCR](https://tesseract-ocr.github.io) — text recognition engine
- [flutter_tesseract_ocr](https://pub.dev/packages/flutter_tesseract_ocr) — OCR plugin

<div align="center">

Made with ❤️ and Flutter

[⭐ Star on GitHub](https://github.com/aynazar-sylyyew-dev/K-pri-App-for-phone)

</div>