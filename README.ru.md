<div align="center">

<img src="./assets/icon/app_icon.png" alt="Köpri" width="120" />

# Kopri Translator

Оффлайн-переводчик с камерой (OCR), огромным разговорником и переводом текста

![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84.svg?logo=android)
![PRs](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

[🇬🇧 English](./README.md) · [🇹🇲 Türkmençe](./README.tk.md)

</div>

---

**Köpri** — бесплатный оффлайн-переводчик на Flutter. Наведи камеру на любой текст, переведи текст в текст или открой огромный разговорник — всё работает без интернета.

## 📱 Скриншоты

<div align="center">
<img src="./assets/screenshots/1.jpg" width="240" />
<img src="./assets/screenshots/2.jpg" width="240" />
<img src="./assets/screenshots/3.jpg" width="240" />
<img src="./assets/screenshots/4.jpg" width="240" />
<img src="./assets/screenshots/5.jpg" width="240" />
<img src="./assets/screenshots/6.jpg" width="240" />
</div>

## ✨ Возможности

📸 **Перевод через камеру (OCR)** — распознавание текста с фото, вывесок и документов через Tesseract OCR
💬 **Перевод текста** — мгновенный перевод между 50+ языками
📖 **Огромный разговорник** — тысячи фраз в десятках категорий и подкатегорий
📴 **Полный оффлайн** — интернет не нужен, данные не покидают устройство
🕘 **История** — все переводы сохраняются локально
⭐ **Избранное** — сохраняй часто используемые фразы
🎨 **Современный UI** — чистый дизайн с тёмной темой

### 🌍 Поддерживаемые языки

🇬🇧 Английский · 🇷🇺 Русский · 🇹🇲 Туркменский · 🇹 Турецкий · 🇿 Казахский · 🇹🇯 Таджикский · 🇺🇿 Узбекский · 🇺🇦 Украинский · 🇨 Китайский · 🇯 Японский · 🇷 Корейский · 🇦🇪 Арабский · 🇩🇪 Немецкий · 🇫🇷 Французский · 🇪 Испанский · 🇹 Итальянский · 🇮🇳 Хинди и другие

## 🛠 Технологии

| Слой | Технология |
| --- | --- |
| Фреймворк | [Flutter](https://flutter.dev) 3.x |
| Язык | [Dart](https://dart.dev) 3.x |
| OCR | [Tesseract OCR](https://tesseract-ocr.github.io) (flutter_tesseract_ocr) |
| Камера | [camera](https://pub.dev/packages/camera) |
| Хранилище | SharedPreferences / Hive |
| Архитектура | Feature-first, чистая архитектура |

## 🚀 Начало работы

### Требования

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.0+
- [Dart SDK](https://dart.dev/get-dart) (идёт в комплекте с Flutter)
- [Android Studio](https://developer.android.com/studio) или [VS Code](https://code.visualstudio.com)
- [Git](https://git-scm.com)

Проверь установку:

```bash
flutter doctor
```

### Установка

**1. Клонируй репозиторий**

```bash
git clone https://github.com/aynazar-sylyyew-dev/K-pri-App-for-phone.git
cd K-pri-App-for-phone
```

**2. Установи зависимости**

```bash
flutter pub get
```

**3. ⚠️ ВАЖНО: добавь OCR-модели в `assets/tessdata/`**

Приложение распознаёт текст с помощью Tesseract. Файлы моделей (`*.traineddata`) **не входят в репозиторий** из-за большого размера — их нужно положить в папку `assets/tessdata/` самостоятельно.

Скачай нужные языки:
- Быстрые модели (меньше размер): https://github.com/tesseract-ocr/tessdata_fast
- Лучшее качество (больше размер): https://github.com/tesseract-ocr/tessdata

```bash
# PowerShell (Windows)
Invoke-WebRequest -Uri "https://github.com/tesseract-ocr/tessdata_fast/raw/main/rus.traineddata" -OutFile "assets/tessdata/rus.traineddata"
Invoke-WebRequest -Uri "https://github.com/tesseract-ocr/tessdata_fast/raw/main/eng.traineddata" -OutFile "assets/tessdata/eng.traineddata"

# curl (Linux / macOS)
curl -L "https://github.com/tesseract-ocr/tessdata_fast/raw/main/rus.traineddata" -o "assets/tessdata/rus.traineddata"
```

Коды языков: `eng`, `rus`, `tur`, `kaz`, `tgk`, `tha`, `ukr`, `urd`, `uzb_cyrl`, `vie`, `ara`, `chi_sim`, `chi_tra`, `deu`, `fra`, `spa`, `jpn`, `kor` и другие.

Убедись, что в `pubspec.yaml` есть:

```yaml
flutter:
  assets:
    - assets/tessdata/
    - assets/icon/
```

## 🏃 Запуск (Debug)

```bash
flutter run
```

- `flutter devices` — список доступных устройств
- `r` в терминале — hot reload, `R` — hot restart

## 📦 Сборка (Release)

**APK:**

```bash
flutter build apk --release
```

Готовый файл: `build/app/outputs/flutter-apk/app-release.apk`

**APK по архитектурам (меньше размер):**

```bash
flutter build apk --release --split-per-abi
```

**App Bundle для Google Play:**

```bash
flutter build appbundle --release
```

## 🔧 Возможные проблемы

- **«tessdata not found»** — проверь, что файлы `.traineddata` лежат в `assets/tessdata/`, затем снова выполни `flutter pub get`.
- **Камера не работает** — разреши доступ к камере, Android сам спросит при первом запуске.
- **Ошибки сборки после клона** — выполни `flutter clean && flutter pub get`.

## 🤝 Вклад

Контрибьют приветствуется! Открой issue или пришли pull request.

## 📄 Лицензия

Проект распространяется под лицензией [Apache License 2.0](./LICENSE).

## 👤 Автор

**Айназар Сылыев**
🐙 GitHub: [@aynazar-sylyyew-dev](https://github.com/aynazar-sylyyew-dev)

## 🙏 Благодарности

- [Flutter](https://flutter.dev) — кроссплатформенный фреймворк
- [Tesseract OCR](https://tesseract-ocr.github.io) — движок распознавания текста
- [flutter_tesseract_ocr](https://pub.dev/packages/flutter_tesseract_ocr) — плагин OCR

<div align="center">

Сделано с ❤️ на Flutter

[⭐ Поставь звезду на GitHub](https://github.com/aynazar-sylyyew-dev/K-pri-App-for-phone)

</div>