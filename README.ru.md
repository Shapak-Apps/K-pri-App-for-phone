<div align="center">
<img src="./assets/icon/app_icon.png" alt="Köpri" width="120" />

# Köpri Translator

Оффлайн-переводчик с гибридным OCR через камеру (скоро), огромным разговорником и переводом текста

![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg?logo=dart)
![C++](https://img.shields.io/badge/C%2B%2B-17-00599C.svg?logo=c%2B%2B)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84.svg?logo=android)
![PRs](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

[🇬 English](./README.md) · [🇹🇲 Türkmençe](./README.tk.md)
</div>

Köpri — бесплатный оффлайн-приоритетный переводчик на Flutter. Разговорник, история, избранное, XP и статистика работают полностью без интернета. Перевод текста с русского → туркменский и с английского → туркменский работает оффлайн через встроенный словарь. Для всех остальных пар языков приложение использует онлайн-сервисы (Google Translate, Lingva, MyMemory) — текст передаётся на их серверы. Перевод через камеру находится в активной разработке и выйдет в версии 2.0.0.

Köpri — часть организации [Shapak-Apps](https://github.com/Shapak-Apps) — открытый исходный код из Туркменистана.

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

- 🚧 **Перевод через камеру (гибридный OCR) — Скоро в v2.0.0** — сверхбыстрое распознавание через Google ML Kit (латиница, ~0.3 с) + Tesseract OCR (кириллица, арабский, CJK, деванагари) как запасной вариант. Находится в активной разработке — будет доступно только в следующем крупном обновлении.
- 💬 **Перевод текста** — мгновенный перевод между 50+ языками
- 📖 **Огромный разговорник** — тысячи фраз в десятках категорий и подкатегорий
- 🔵 **Оффлайн-приоритет** — разговорник, история, избранное, XP и статистика работают **полностью без интернета**; перевод текста с русского → туркменский и с английского → туркменский работает оффлайн через встроенный словарь; перевод текста для остальных пар языков использует онлайн-сервисы (Google Translate, Lingva, MyMemory) — текст передаётся на их серверы
- 🕘 **История** — все переводы сохраняются локально
- ⭐ **Избранное** — сохраняй часто используемые фразы
- 🎨 **Современный UI** — чистый дизайн с тёмной темой
- 👤 **Профиль** — удобное отслеживание активности, статистики и всех выполненных переводов
- 🎮 **Хардкорная прогрессия** — XP уровни (1–100), дневные стрики, бейджи и титул «Легенда перевода» для самых активных пользователей
- 🚀 **Нативная производительность** — тяжёлые вычисления (XP, стрики, статистика, парсинг JSON, ресайз аватара) работают на C++17 через FFI — в 10–60 раз быстрее, чем на чистом Dart

## 🌍 Поддерживаемые языки

🇬🇧 Английский · 🇷🇺 Русский · 🇹🇲 Туркменский · 🇹 Турецкий · 🇿 Казахский · 🇹🇯 Таджикский · 🇺🇿 Узбекский · 🇺🇦 Украинский · 🇨🇳 Китайский · 🇯🇵 Японский · 🇰🇷 Корейский · 🇸🇦 Арабский · 🇩🇪 Немецкий · 🇫🇷 Французский · 🇪 Испанский · 🇹 Итальянский · 🇮🇳 Хинди и другие

## 🛠 Технологии

| Слой | Технология |
| --- | --- |
| Фреймворк | [Flutter](https://flutter.dev) 3.x |
| Язык | [Dart](https://dart.dev) 3.x |
| Нативное ядро | C++17 (через FFI) — XP, стрики, статистика, JSON/CSV, ресайз аватара, парсинг перевода и много других ядер |
| OCR (латиница) | [Google ML Kit](https://developers.google.com/ml-kit/vision/text-recognition) (оффлайн, на устройстве) — скоро |
| OCR (кириллица / арабский / CJK / деванагари) | [Tesseract OCR](https://tesseract-ocr.github.io) (flutter_tesseract_ocr) — скоро |
| Камера | [camera](https://pub.dev/packages/camera) — скоро в v2.0.0 |
| Хранилище | SharedPreferences / Hive |
| Архитектура | Feature-first, чистая архитектура |

Почему гибрид? ML Kit в 10–20 раз быстрее Tesseract на латинице (вывески, меню, документы), а Tesseract покрывает письменности, которые ML Kit пока не поддерживает (кириллица, арабский, деванагари). Движок полностью реализован на C++ и будет включён в v2.0.0.

## ⚡ Модули C++ (нативная производительность)

| Модуль | Назначение |
| --- | --- |
| xp_engine | XP, уровни, прогресс с экспоненциальной сложностью (BASE 200, GROWTH 1.25) — в 20 раз быстрее Dart |
| streak_engine | Текущий/лучший стрик через алгоритм гражданских дней Хиннанта (точно через месяцы/годы) |
| stats_engine | Недельный график (O(n)), пиковый час, средняя длина, топ-фразы — всё в C++ |
| ocr_engine | Нативная предобработка и поворот изображений для OCR — выйдет вместе с камерой в v2.0.0 |
| json_lite | Ручной рекурсивный парсер JSON для экспорта профиля |
| csv_engine | Нативная конвертация JSON→CSV для экспорта истории |
| image_fast | Мгновенный ресайз аватара через stb_image (512px) — без лагов UI при применении фото |
| translate_engine | Нативное определение письменности, парсинг ответа Google GTX, чанкинг длинных текстов |
| tm_engine | Память переводов с точным и нечётким поиском (Levenshtein) |
| mt_tk_engine | Оффлайн туркменский движок перевода (фразы + слова) |
| clip_filter | Умный фильтр буфера обмена (URL, email, код, хеши, эмодзи) |
| splash_engine | Частицы/полосы/буквы splash-экрана на C++ |
| crash_handler | Нативный обработчик падений с логированием backtrace |
| ffi_bridge | FFI-мост между Dart и нативной библиотекой |

## 🎮 Система прогрессии

В Köpri используется хардкорная кривая прокачки — каждый уровень надо заслужить:

- +5 XP за каждый завершённый перевод
- Экспоненциальная стоимость: BASE 200, GROWTH 1.25 — каждый следующий уровень требует ~25% больше XP
- 100 уровней, уровень 100 = «Легенда перевода»
- Дневные стрики, лучший стрик, бейджи и ежедневные цели

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

1. **Клонируй репозиторий**

```bash
git clone https://github.com/Shapak-Apps/K-pri-App-for-phone.git
cd K-pri-App-for-phone
```

2. **Установи зависимости**

```bash
flutter pub get
```

3. **⚠️ ВАЖНО: добавь OCR-модели в `assets/tessdata/` (для камеры в v2.0.0)**

Латиницу распознаёт Google ML Kit (модель скачивается автоматически через Google Play Services), поэтому для Tesseract нужны только модели кириллицы, арабского, CJK и деванагари. Файлы `eng.traineddata` и `tur.traineddata` оставлены как запасные для устройств без Google Play Services. Всего нужно 38 файлов моделей.

**Примечание:** В текущей сборке APK модели исключены для уменьшения размера (камера Coming Soon). Раскомментируй `- assets/tessdata/` в `pubspec.yaml` при выпуске v2.0.0.

**Скачай все одной командой:**

```bash
# PowerShell (Windows) — запусти в корне проекта
New-Item -ItemType Directory -Force -Path "assets\tessdata" | Out-Null
"eng tur rus ukr bel bul srp mkd kaz uzb_cyrl kir tgk mon ara fas urd heb pus chi_sim chi_tra jpn kor hin tha tam tel ben nep pan guj mar kan mal sin khm lao mya".Split(" ") | ForEach-Object {
    Invoke-WebRequest -Uri "https://github.com/tesseract-ocr/tessdata_fast/raw/main/$_.traineddata" -OutFile "assets\tessdata\$_.traineddata"
}
```

```bash
# curl (Linux / macOS) — запусти в корне проекта
mkdir -p assets/tessdata
for c in eng tur rus ukr bel bul srp mkd kaz uzb_cyrl kir tgk mon ara fas urd heb pus chi_sim chi_tra jpn kor hin tha tam tel ben nep pan guj mar kan mal sin khm lao mya; do
  curl -L "https://github.com/tesseract-ocr/tessdata_fast/raw/main/$c.traineddata" -o "assets/tessdata/$c.traineddata"
done
```

Для лучшего качества (файлы больше) замени `tessdata_fast` на `tessdata` в ссылках.

4. **⚠️ ВАЖНО: скачай stb_image-хедеры для нативного ресайза аватара**

C++-модуль `image_fast` использует single-header библиотеки [stb_image](https://github.com/nothings/stb) и [stb_image_write](https://github.com/nothings/stb) для мгновенного ресайза аватара. Скачай их в `android/app/src/main/cpp/`:

```bash
# PowerShell (Windows) — запусти в корне проекта
New-Item -ItemType Directory -Force -Path "android\app\src\main\cpp" | Out-Null
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nothings/stb/master/stb_image.h" -OutFile "android\app\src\main\cpp\stb_image.h"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h" -OutFile "android\app\src\main\cpp\stb_image_write.h"
```

```bash
# curl (Linux / macOS) — запусти в корне проекта
mkdir -p android/app/src/main/cpp
curl -L "https://raw.githubusercontent.com/nothings/stb/master/stb_image.h" -o android/app/src/main/cpp/stb_image.h
curl -L "https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h" -o android/app/src/main/cpp/stb_image_write.h
```

Если stb-хедеры отсутствуют, приложение автоматически переключится на копирование через Dart — всё продолжит работать, просто чуть медленнее.

5. **Настройка Android**

Приложению нужен Android 5.0+ (API 21). Добавь внутрь `<application>` в `android/app/src/main/AndroidManifest.xml`, чтобы модель ML Kit скачивалась заранее при установке:

```xml
<meta-data
    android:name="com.google.mlkit.vision.DEPENDENCIES"
    android:value="ocr" />
```

Убедись, что в `pubspec.yaml` есть:

```yaml
flutter:
  assets:
    - assets/icon/
    - assets/tessdata_config.json
    - assets/google_fonts/
    # - assets/tessdata/  # ← раскомментируй при выпуске v2.0.0
```

Перед запуском программы прочитай `build.gradle` (android) и `build.gradle` (:app).

## 🏃 Запуск (Debug)

```bash
flutter run
```

- `flutter devices` — список доступных устройств
- `r` в терминале — hot reload, `R` — hot restart

## 📦 Сборка (Release)

APK:

```bash
flutter build apk --release
```

Готовый файл: `build/app/outputs/flutter-apk/app-release.apk`

APK по архитектурам (меньше размер):

```bash
flutter build apk --release --split-per-abi
```

App Bundle для Google Play:

```bash
flutter build appbundle --release
```

## 🔧 Возможные проблемы

- **«tessdata not found»** — проверь, что файлы `.traineddata` лежат в `assets/tessdata/` и строка раскомментирована в `pubspec.yaml`, затем снова выполни `flutter pub get`.
- **Камера показывает «Скоро»** — это ожидаемое поведение в v1.x. Перевод через камеру будет включён в v2.0.0 (для раннего тестирования переключи `kCameraEnabled` на `true` в `camera_screen.dart`).
- **Первый запуск OCR медленный** — Google Play Services один раз скачивает модель ML Kit (~5 МБ), дальше распознавание занимает ~0.3 с.
- **Камера не работает** — разреши доступ к камере, Android сам спросит при первом запуске.
- **Ошибки сборки после клона** — выполни `flutter clean && flutter pub get`.
- **C++-файлы красные в IDE** — открой `File → Sync Project with Gradle Files` в Android Studio, чтобы NDK/CMake-тулчейн подтянул include-пути.

## 🤝 Вклад

Контрибьют приветствуется! Открой issue или пришли pull request.

## 📄 Лицензия

Проект распространяется под лицензией [Apache License 2.0](./LICENSE).

## 👤 Автор

Айназар Сылыев
🐙 GitHub: [@aynazar-sylyyew-dev](https://github.com/aynazar-sylyyew-dev)
🏢 Организация: [Shapak-Apps](https://github.com/Shapak-Apps)

## 🙏 Благодарности

- [Flutter](https://flutter.dev) — кроссплатформенный фреймворк
- [Google ML Kit](https://developers.google.com/ml-kit) — распознавание текста на устройстве
- [Tesseract OCR](https://tesseract-ocr.github.io) — движок распознавания текста
- [stb от Sean Barrett](https://github.com/nothings/stb) — single-header библиотека для нативного ресайза аватара
- [flutter_tesseract_ocr](https://pub.dev/packages/flutter_tesseract_ocr) — плагин OCR

<div align="center">
Сделано с ❤️, Flutter и C++

[⭐ Поставь звезду на GitHub](https://github.com/Shapak-Apps/K-pri-App-for-phone)
</div>