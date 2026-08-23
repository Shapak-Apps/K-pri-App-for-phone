<div align="center">
<img src="./assets/icon/app_icon.png" alt="Köpri" width="120" />

# Köpri Translator

Kamera (gibrid OCR) bilen oflaýn terjimeçi (ýakyn wagtda), uly gepleşik kitaby we tekst-tekst terjime

![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg?logo=dart)
![C++](https://img.shields.io/badge/C%2B%2B-17-00599C.svg?logo=c%2B%2B)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84.svg?logo=android)
![PRs](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

[🇬🇧 English](./README.md) · [🇷🇺 По-русски](./README.ru.md)
</div>

Köpri — Flutter-da ýasalan mugt, oflaýn terjimeçi. Tekst-tekst terjime ediň ýa-da uly gepleşik kitabyny açyň — hemmesi internetsiz işleýär. Kamera terjimesi işjeň işlenip düzülýär we v2.0.0 wersiýasynda çykar.

Köpri [Shapak-Apps](https://github.com/Shapak-Apps) guramasynyň bir bölegi — Türkmenistandan açyk kodly mobil programmalar.

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

- 🚧 **Kamera terjimesi (gibrid OCR) — v2.0.0-da ýakyn wagtda** — Google ML Kit arkaly örän çalt tekst tanamak (latyn elipbiýi, ~0.3 s) + Tesseract OCR (kiril, arap, CJK, dewanagari) ätiýaçlyk hökmünde. Işjeň işlenip düzülýär — diňe indiki uly täzelenişde elýeterli bolar.
- 💬 **Tekst-tekst terjime** — 50+ diliň arasynda dessine terjime
- 📖 **Uly gepleşik kitaby** — onlarça kategoriýada müňlerçe fraza
- 📴 **Doly oflaýn** — internet gerek däl, maglumatlar enjamda galýar
- 🕘 **Taryh** — ähli terjimeler lokal ýatda saklanýar
- ⭐ **Halanlar** — ýygy ulanýan frazalaryňyzy saklaň
- 🎨 **Häzirki zaman UI** — garaňky režimli arassa dizaýn
- 👤 **Profil** — öz statistikaňyza, geçirilen işleriňize we ulanyş maglumatlaryňyza aňsatlyk bilen gözegçilik ediň
- 🎮 **Kyn progressiýa** — XP derejeler (1–100), günlük strikler, rozetler we iň işjeň ulanyjylar üçin «Terjime efsanesi» ady
- 🚀 **Natiw tizlik** — agyr hasaplamalar (XP, strikler, statistika, JSON parsing, awatar resize) C++17 FFI arkaly işleýär — arassa Dart-dan 10–60 esse çalt

## 🌍 Goldanylýan diller

🇬🇧 Iňlis · 🇷🇺 Rus · 🇹 Türkmen · 🇹🇷 Türk · 🇿 Gazak · 🇹🇯 Täjik · 🇺 Özbek · 🇦 Ukrain · 🇳 Hytaý · 🇯 Ýapon · 🇷 Koreý · 🇦 Arap · 🇩🇪 Nemes · 🇫🇷 Fransuz · 🇪🇸 Ispan · 🇮🇹 Italýan · 🇮🇳 Hindi we başgalar

## 🛠 Tehnologiýalar

| Gat | Tehnologiýa |
| --- | --- |
| Freýmwork | [Flutter](https://flutter.dev) 3.x |
| Dil | [Dart](https://dart.dev) 3.x |
| Natiw ýadro | C++17 (FFI arkaly) — XP, strikler, statistika, JSON/CSV, awatar resize, terjime parsing we beýleki ýadrolar |
| OCR (latyn) | [Google ML Kit](https://developers.google.com/ml-kit/vision/text-recognition) (oflaýn, enjamda) — ýakyn wagtda |
| OCR (kiril / arap / CJK / dewanagari) | [Tesseract OCR](https://tesseract-ocr.github.io) (flutter_tesseract_ocr) — ýakyn wagtda |
| Kamera | [camera](https://pub.dev/packages/camera) — v2.0.0-de ýakyn wagtda |
| Ammar | SharedPreferences / Hive |
| Arhitektura | Feature-first, arassa arhitektura |

Näme üçin gibrid? ML Kit latyn elipbiýinde Tesseract-den 10–20 esse çalt (ýazgylar, menýu, resminamalar), Tesseract bolsa ML Kit-iň heniz goldamaýan elipbiýlerini (kiril, arap, dewanagari) tanaýar. Bu hereketlendiriji C++-da doly amala aşyryldy we v2.0.0-de işlediler.

## ⚡ C++ modullary (natiw tizlik)

| Modul | Maksady |
| --- | --- |
| xp_engine | XP, derejeler, öňegidişlik eksponensial kynçylyk bilen (BASE 200, GROWTH 1.25) — Dart-dan 20 esse çalt |
| streak_engine | Häzirki/iň gowy strik — Hinnant-yň raýat günleri algoritmi bilen (aý/ýyl boýunça takyk) |
| stats_engine | Hepdelik grafik (O(n)), pik sagady, ortaça uzynlyk, iň köp frazalar — hemmesi C++-da |
| ocr_engine | OCR üçin natiw surat taýýarlamasy we aýlawy — kamera bilen v2.0.0-de çykar |
| json_lite | Profil eksporty üçin öz ýazylan rekurssiý JSON parseri |
| csv_engine | Taryhy eksporty üçin natiw JSON→CSV konwersiýa |
| image_fast | stb_image arkaly dessine awatar resize (512px) — foto goýlanda UI doňmaýar |
| translate_engine | Natiw elipbiý kesgitleme, Google GTX jogaby parsing, uzyn tekstleri bölmek |
| tm_engine | Takyk we bulaşyk (Levenshtein) gözlegli terjime ýady |
| mt_tk_engine | Oflaýn türkmen terjime hereketlendirijisi (fraza + söz derejesinde) |
| clip_filter | Akylly bufer süzgüji (URL, email, kod, heşler, diňe emoji) |
| splash_engine | Splash-ekran bölejikleri/zolaklar/harplar C++-da hasaplanýar |
| crash_handler | Backtrace loglaýjy natiw çökme tutujy |
| ffi_bridge | Dart we natiw kitaphananyň arasynda FFI köprüsi |

## 🎮 Progressiýa ulgamy

Köpri kyn derejeleşme egrisini ulanýar — her dereje gazanylmaly:

- Her tamamlanan terjime üçin +5 XP
- Eksponensial baha: BASE 200, GROWTH 1.25 — her indiki dereje öňküsinden ~25% köp XP talap edýär
- 100 dereje, 100-nji dereje = «Terjime efsanesi»
- Günlik strikler, iň gowy strik, rozetler we günlük maksatlar

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

1. **Repozitoriýany klonlaň**

```bash
git clone https://github.com/Shapak-Apps/K-pri-App-for-phone.git
cd K-pri-App-for-phone
```

2. **Baglylyklary gurnaň**

```bash
flutter pub get
```

3. **⚠️ WAJYP: OCR modellerini `assets/tessdata/` papkasyna goýuň (v2.0.0 kamera üçin)**

Latyn elipbiýini Google ML Kit tanaýar (model Google Play Services arkaly awtomatik göçürilýär), şonuň üçin Tesseract diňe kiril, arap, CJK we dewanagari modelleri gerek. `eng.traineddata` we `tur.traineddata` Google Play Services bolmadyk enjamlar üçin ätiýaçlyk hökmünde galdyrylan. Jemi 38 model faýly gerek.

**Bellik:** Häzirki APK ýygnamasynda modeller göwrümi kiçeltmek üçin aýryldy (kamera Coming Soon). v2.0.0 çykanda `pubspec.yaml`-da `- assets/tessdata/` setirini açyň.

**Ähli modelleri bir buýruk bilen göçürip alyň:**

```bash
# PowerShell (Windows) — proýekt kökünde işlediň
New-Item -ItemType Directory -Force -Path "assets\tessdata" | Out-Null
"eng tur rus ukr bel bul srp mkd kaz uzb_cyrl kir tgk mon ara fas urd heb pus chi_sim chi_tra jpn kor hin tha tam tel ben nep pan guj mar kan mal sin khm lao mya".Split(" ") | ForEach-Object {
    Invoke-WebRequest -Uri "https://github.com/tesseract-ocr/tessdata_fast/raw/main/$_.traineddata" -OutFile "assets\tessdata\$_.traineddata"
}
```

```bash
# curl (Linux / macOS) — proýekt kökünde işlediň
mkdir -p assets/tessdata
for c in eng tur rus ukr bel bul srp mkd kaz uzb_cyrl kir tgk mon ara fas urd heb pus chi_sim chi_tra jpn kor hin tha tam tel ben nep pan guj mar kan mal sin khm lao mya; do
  curl -L "https://github.com/tesseract-ocr/tessdata_fast/raw/main/$c.traineddata" -o "assets/tessdata/$c.traineddata"
done
```

Iň gowy hil üçin (uly faýllar) salgylarda `tessdata_fast` ýerine `tessdata` ulanyň.

4. **⚠️ WAJYP: natiw awatar resize üçin stb_image headerlerini göçürip alyň**

`image_fast` C++ moduly dessine awatar resize etmek üçin [stb_image](https://github.com/nothings/stb) we [stb_image_write](https://github.com/nothings/stb) single-header kitaphanalaryny ulanýar. Olary `android/app/src/main/cpp/` papkasyna göçürip alyň:

```bash
# PowerShell (Windows) — proýekt kökünde işlediň
New-Item -ItemType Directory -Force -Path "android\app\src\main\cpp" | Out-Null
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nothings/stb/master/stb_image.h" -OutFile "android\app\src\main\cpp\stb_image.h"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h" -OutFile "android\app\src\main\cpp\stb_image_write.h"
```

```bash
# curl (Linux / macOS) — proýekt kökünde işlediň
mkdir -p android/app/src/main/cpp
curl -L "https://raw.githubusercontent.com/nothings/stb/master/stb_image.h" -o android/app/src/main/cpp/stb_image.h
curl -L "https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h" -o android/app/src/main/cpp/stb_image_write.h
```

Eger stb headerleri ýok bolsa, programma awtomatik Dart nusgasyndan peýdalanar — hemme zat işlär, diňe biraz haýalrak.

5. **Android sazlamasy**

Programma Android 5.0+ (API 21) talap edýär. ML Kit modeliniň gurnalanda öňünden göçürilmegi üçin `android/app/src/main/AndroidManifest.xml` faýlynda `<application>` içine goşuň:

```xml
<meta-data
    android:name="com.google.mlkit.vision.DEPENDENCIES"
    android:value="ocr" />
```

`pubspec.yaml` faýlynda bardygyny barlaň:

```yaml
flutter:
  assets:
    - assets/icon/
    - assets/tessdata_config.json
    - assets/google_fonts/
    # - assets/tessdata/  # ← v2.0.0 çykanda açyň
```

Programmany işletmekden öň `build.gradle` (android) we `build.gradle` (:app) okaň.

## 🏃 Işletmek (Debug)

```bash
flutter run
```

- `flutter devices` — elýeterli enjamlaryň sanawy
- Terminalda `r` — hot reload, `R` — hot restart

## 📦 Ýygnamak (Release)

APK:

```bash
flutter build apk --release
```

Taýýar faýl: `build/app/outputs/flutter-apk/app-release.apk`

Arhitektura boýunça APK (kiçi göwrüm):

```bash
flutter build apk --release --split-per-abi
```

Google Play üçin App Bundle:

```bash
flutter build appbundle --release
```

## 🔧 Meseleler

- **«tessdata not found»** — `.traineddata` faýllarynyň `assets/tessdata/` papkasyndadygyny we `pubspec.yaml`-da setiriň açykdygyny barlaň, soň `flutter pub get` işlediň.
- **Kamera «Ýakyn wagtda» görkezýär** — bu v1.x üçin garaşylýan. Kamera terjimesi v2.0.0-de işlediler (irki synag üçin `camera_screen.dart`-da `kCameraEnabled`-y `true`-a üýtgediň).
- **Ilkinji OCR işledilişi haýal** — Google Play Services ML Kit modelini bir gezek göçürýär (~5 MB), soňra tanamak ~0.3 s alýar.
- **Kamera işlemese** — ilkinji açylyşda Android kameradan peýdalanmaga rugsat sorar, rugsat beriň.
- **Klon soňy ýygnama ýalňyşlary** — `flutter clean && flutter pub get` işlediň.
- **C++ faýllar IDE-de gyzyl** — Android Studio-da `File → Sync Project with Gradle Files` açyň, NDK/CMake toolchain include ýollary çeksin.

## 🤝 Goşant

Goşantlar hoş garşylanýar! Issue açyň ýa-da pull request iberiň.

## 📄 Litsenziýa

Bu proýekt [Apache License 2.0](./LICENSE) esasynda paýlanýar.

## 👤 Awtor

Aýnazar Sylyýew
🐙 GitHub: [@aynazar-sylyyew-dev](https://github.com/aynazar-sylyyew-dev)
🏢 Gurama: [Shapak-Apps](https://github.com/Shapak-Apps)

## 🙏 Minnetdarlyk

- [Flutter](https://flutter.dev) — kross-platforma freýmwork
- [Google ML Kit](https://developers.google.com/ml-kit) — enjamda tekst tanamak
- [Tesseract OCR](https://tesseract-ocr.github.io) — tekst tanamak hereketlendirijisi
- [Sean Barrett-iň stb kitaphanasy](https://github.com/nothings/stb) — natiw awatar resize üçin single-header kitaphana
- [flutter_tesseract_ocr](https://pub.dev/packages/flutter_tesseract_ocr) — OCR plagini

<div align="center">
❤️, Flutter we C++ bilen ýasaldy

[⭐ GitHub-da ýyldyz goýuň](https://github.com/Shapak-Apps/K-pri-App-for-phone)
</div>