<div align="center">

<img src="./assets/icon/app_icon.png" alt="Köpri" width="120" />

# Kopri Translator

Kamera (OCR) bilen oflaýn terjimeçi, uly gepleşik kitaby we tekst-tekst terjime

![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84.svg?logo=android)
![PRs](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

[🇬🇧 English](./README.md) · [🇷 По-русски](./README.ru.md)

</div>

---

**Köpri** — Flutter-da ýasalan mugt, oflaýn terjimeçi. Kameraňyzy islendik tekste gönükdiriň, tekst-tekst terjime ediň ýa-da uly gepleşik kitabyny açyň — hemmesi internetsiz işleýär.

## 📱 Ekran şekilleri

<div align="center">
<img src="./assets/screenshots/1.jpg" width="240" />
<img src="./assets/screenshots/2.jpg" width="240" />
<img src="./assets/screenshots/3.jpg" width="240" />
<img src="./assets/screenshots/4.jpg" width="240" />
<img src="./assets/screenshots/5.jpg" width="240" />
<img src="./assets/screenshots/6.jpg" width="240" />
</div>

## ✨ Mümkinçilikler

📸 **Kamera terjimesi (OCR)** — Tesseract OCR arkaly surat, ýazgy we resminamalardan teksti tanaýar
💬 **Tekst-tekst terjime** — 50+ diliň arasynda dessine terjime
📖 **Uly gepleşik kitaby** — onlarça kategoriýada müňlerçe fraza
📴 **Doly oflaýn** — internet gerek däl, maglumatlar enjamda galýar
🕘 **Taryh** — ähli terjimeler lokal ýatda saklanýar
⭐ **Halanlar** — ýygy ulanýan frazalaryňyzy saklaň
🎨 **Häzirki zaman UI** — garaňky režimli arassa dizaýn

### 🌍 Goldanylýan diller

🇬🇧 Iňlis · 🇷🇺 Rus · 🇹🇲 Türkmen · 🇹 Türk · 🇰🇿 Gazak · 🇹🇯 Täjik · 🇺🇿 Özbek · 🇺🇦 Ukrain · 🇨🇳 Hytaý · 🇯🇵 Ýapon · 🇰🇷 Koreý · 🇦🇪 Arap · 🇩🇪 Nemes · 🇫 Fransuz · 🇸 Ispan · 🇮🇹 Italýan · 🇮🇳 Hindi we başgalar

## 🛠 Tehnologiýalar

| Gat | Tehnologiýa |
| --- | --- |
| Freýmwork | [Flutter](https://flutter.dev) 3.x |
| Dil | [Dart](https://dart.dev) 3.x |
| OCR | [Tesseract OCR](https://tesseract-ocr.github.io) (flutter_tesseract_ocr) |
| Kamera | [camera](https://pub.dev/packages/camera) |
| Ammar | SharedPreferences / Hive |
| Arhitektura | Feature-first, arassa arhitektura |

## 🚀 Başlamak

### Zerurlyklar

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.0+
- [Dart SDK](https://dart.dev/get-dart) (Flutter bilen bile gelýär)
- [Android Studio](https://developer.android.com/studio) ýa-da [VS Code](https://code.visualstudio.com)
- [Git](https://git-scm.com)

Barlaň:

```bash
flutter doctor
```

### Gurnama

**1. Repozitoriýany klonlaň**

```bash
git clone https://github.com/aynazar-sylyyew-dev/K-pri-App-for-phone.git
cd K-pri-App-for-phone
```

**2. Baglylyklary gurnaň**

```bash
flutter pub get
```

**3. ⚠️ WAJYP: OCR modellerini `assets/tessdata/` papkasyna goýuň**

Programma teksti Tesseract arkaly tanaýar. Model faýllary (`*.traineddata`) uly bolany üçin **repozitoriýa goşulmaýar** — olary `assets/tessdata/` papkasyna özünüz goýmaly.

Gerek dilleri göçürip alyň:
- Çalt modeller (kiçi): https://github.com/tesseract-ocr/tessdata_fast
- Iň gowy hil (uly): https://github.com/tesseract-ocr/tessdata

```bash
# PowerShell (Windows)
Invoke-WebRequest -Uri "https://github.com/tesseract-ocr/tessdata_fast/raw/main/rus.traineddata" -OutFile "assets/tessdata/rus.traineddata"
Invoke-WebRequest -Uri "https://github.com/tesseract-ocr/tessdata_fast/raw/main/eng.traineddata" -OutFile "assets/tessdata/eng.traineddata"

# curl (Linux / macOS)
curl -L "https://github.com/tesseract-ocr/tessdata_fast/raw/main/rus.traineddata" -o "assets/tessdata/rus.traineddata"
```

Dil kodlary: `eng`, `rus`, `tur`, `kaz`, `tgk`, `tha`, `ukr`, `urd`, `uzb_cyrl`, `vie`, `ara`, `chi_sim`, `chi_tra`, `deu`, `fra`, `spa`, `jpn`, `kor` we başgalar.

`pubspec.yaml` faýlynda bardygyny barlaň:

```yaml
flutter:
  assets:
    - assets/tessdata/
    - assets/icon/
```

## 🏃 Işletmek (Debug)

```bash
flutter run
```

- `flutter devices` — elýeterli enjamlaryň sanawy
- Terminalda `r` — hot reload, `R` — hot restart

## 📦 Ýygnamak (Release)

**APK:**

```bash
flutter build apk --release
```

Taýýar faýl: `build/app/outputs/flutter-apk/app-release.apk`

**Arhitektura boýunça APK (kiçi göwrüm):**

```bash
flutter build apk --release --split-per-abi
```

**Google Play üçin App Bundle:**

```bash
flutter build appbundle --release
```

## 🔧 Meseleler

- **«tessdata not found»** — `.traineddata` faýllarynyň `assets/tessdata/` papkasyndadygyny barlaň, soň `flutter pub get` işlediň.
- **Kamera işlemese** — ilkinji açylyşda Android kameradan peýdalanmaga rugsat sorar, rugsat beriň.
- **Klon soňy ýygnama ýalňyşlary** — `flutter clean && flutter pub get` işlediň.

## 🤝 Goşant

Goşantlar hoş garşylanýar! Issue açyň ýa-da pull request iberiň.

## 📄 Litsenziýa

Bu proýekt [Apache License 2.0](./LICENSE) esasynda paýlanýar.

## 👤 Awtor

**Aýnazar Sylyýew**
🐙 GitHub: [@aynazar-sylyyew-dev](https://github.com/aynazar-sylyyew-dev)

## 🙏 Minnetdarlyk

- [Flutter](https://flutter.dev) — kross-platforma freýmwork
- [Tesseract OCR](https://tesseract-ocr.github.io) — tekst tanamak hereketlendirijisi
- [flutter_tesseract_ocr](https://pub.dev/packages/flutter_tesseract_ocr) — OCR plagini

<div align="center">

❤️ we Flutter bilen ýasaldy

[⭐ GitHub-da ýyldyz goýuň](https://github.com/aynazar-sylyyew-dev/K-pri-App-for-phone)

</div>