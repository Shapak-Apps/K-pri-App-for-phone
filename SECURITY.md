# Security Policy

**Last updated:** September 15, 2026  
**Project:** [Köpri Translator](https://github.com/Shapak-Apps/K-pri-App-for-phone)  
**Maintainer:** Aynazar Sylyyew ([@aynazar-sylyyew-dev](https://github.com/aynazar-sylyyew-dev))  
**Organization:** [Shapak-Apps](https://github.com/Shapak-Apps) — Open-source mobile apps from Turkmenistan

---

## 1. Reporting a Vulnerability

We take the security of Köpri Translator very seriously. The app handles sensitive user data including translated text (which may contain personal, medical, legal, or financial information), camera frames, local translation history, and device identifiers.

### 🔐 How to report

**Please DO NOT open a public GitHub issue for security vulnerabilities.**

Instead, report vulnerabilities privately using one of the following methods:

| Method | Contact                                                                                                                        |
|---|--------------------------------------------------------------------------------------------------------------------------------|
| **GitHub Private Vulnerability Reporting** | Use the **"Report a vulnerability"** button on the [Security tab](https://github.com/Shapak-Apps/K-pri-App-for-phone/security) |
| **Email** | `sylyyewsylyyew5@gmail.com`                                                                                                    |
| **Keybase / Matrix** | Available on request via GitHub profile                                                                                        |

### 📋 What to include

When reporting, please provide:

- **Type of vulnerability** (e.g., buffer overread, FFI memory leak, XSS in phrasebook, insecure storage)
- **Affected component** (Dart layer, C++ FFI module, Tesseract integration, ML Kit, `mt_tk_engine`, `ocr_engine`, etc.)
- **Full path of the affected file(s)**
- **Step-by-step reproduction instructions** (with sample input text or image if applicable)
- **Proof-of-concept code** if available
- **Potential impact** (data leak, remote code execution, privilege escalation, etc.)
- **Suggested fix** if you have one

### ⏱️ Response timeline

| Stage | Timeframe |
|---|---|
| Acknowledgment | Within **48 hours** |
| Initial triage | Within **7 days** |
| Status update | Every **14 days** until resolution |
| Patch release | Within **30 days** for critical issues |
| Public disclosure | After patch is released, typically **90 days** after report |

### 🎁 Recognition

Reporters of confirmed vulnerabilities will be:

- Credited in the **Security Advisories** section of the repository
- Added to the `ACKNOWLEDGMENTS.md` file (with permission)
- Offered a **"Security Contributor"** badge on GitHub

We support responsible disclosure and will work with you to coordinate publication.

---

## 2. Supported Versions

Only the latest stable release and the current `main` branch receive security updates.

| Version | Branch | Supported |
|---|---|---|
| `2.x.x` (upcoming camera release) | `main` | ✅ Active development |
| `1.x.x` (text + phrasebook) | `main` | ✅ Security patches only |
| `< 1.0.0` | archived | ❌ End of life |

Security patches are backported to the latest stable minor version for **6 months** after a new minor release.

---

## 3. Threat Model

Köpri is a **privacy-first offline translator**, but it has several attack surfaces worth understanding.

### 3.1 Data flow classification

| Data type | Storage | Privacy level |
|---|---|---|
| Translation history | Local (Hive / SharedPreferences) | 🟡 Medium — user content |
| Favorites / phrasebook | Local | 🟢 Low |
| XP, streaks, statistics | Local (C++ `xp_engine` / `streak_engine`) | 🟢 Low |
| Avatar image | Local (native `image_fast` resize) | 🟡 Medium |
| Camera frames (v2.0.0+) | In-memory only, never persisted | 🔴 High |
| Online translation requests | Sent to Google Translate / Lingva / MyMemory | 🔴 High |
| ML Kit OCR model | Downloaded once by Google Play Services | 🟡 Medium |
| Tesseract `.traineddata` | Bundled in APK / downloaded on demand | 🟢 Low |

### 3.2 Attack surfaces

#### 🔴 High-risk surfaces

1. **Online translation providers** (Google Translate, Lingva, MyMemory)
    - User input is transmitted over HTTPS to third-party servers
    - Sensitive text (medical, legal, passwords) **must never be translated online**
    - Users are warned in the UI when a non-Turkmen/non-Russian pair is selected

2. **Camera OCR pipeline** (v2.0.0+)
    - Captures live frames containing potentially sensitive content
    - Frames are processed in-memory by ML Kit (Google Play Services) and Tesseract
    - **Frames are never written to disk** — enforced in `ocr_engine.cpp`

3. **C++ FFI boundary** (`ffi_bridge`)
    - 14 native modules expose functions to Dart via FFI
    - Memory safety issues (buffer overreads, use-after-free) can crash the app or leak memory
    - Recent fix: NEON ASM buffer overread in `ocr_engine` (commit Aug 20, 2026)

#### 🟡 Medium-risk surfaces

4. **Local storage (Hive / SharedPreferences)**
    - Translation history stored unencrypted on device
    - Mitigation: app respects Android's file encryption (FBE) and iOS Data Protection

5. **Tesseract model files**
    - 38 `.traineddata` files (~200 MB total) shipped or downloaded
    - Integrity verified via SHA-256 checksums in `tessdata_config.json`

6. **Phrasebook and TM (Translation Memory)**
    - User-added phrases are stored locally
    - Fuzzy Levenshtein matching in `tm_engine` — bounded to prevent ReDoS

#### 🟢 Low-risk surfaces

7. **XP / streak / stats engines** — pure numerical computation, no I/O
8. **Splash screen particles** — rendered locally, no network
9. **Avatar resize** (`image_fast` via stb_image) — sandboxed, single-header library

### 3.3 Out of scope

The following are **not** considered security vulnerabilities for this project:

- Lack of end-to-end encryption for online translation (this is a feature of the upstream providers)
- Google Play Services telemetry from ML Kit (out of our control)
- Vulnerabilities in third-party pub.dev packages unless we have pinned a vulnerable version
- DoS via extremely long input text (we chunk at 5000 chars in `translate_engine`)

---

## 4. Security Best Practices for Contributors

When contributing to Köpri, please follow these rules:

### 4.1 C++ / FFI code (`android/app/src/main/cpp/`)

- ✅ **Always bounds-check** before pointer arithmetic in ASM and NEON intrinsics
- ✅ Use `std::string_view` / `gsl::span` instead of raw pointers where possible
- ✅ Validate all FFI inputs at the Dart↔C++ boundary (`ffi_bridge.cpp`)
- ✅ Run `AddressSanitizer` and `UndefinedBehaviorSanitizer` before PR
- ❌ Never use `strcpy`, `sprintf`, `gets` — use `strncpy`, `snprintf`, `fgets`
- ❌ Never persist camera frames or user text to disk from C++

### 4.2 Dart code (`lib/`)

- ✅ Use `flutter_secure_storage` for any future sensitive preferences
- ✅ Validate all user input before passing to FFI
- ✅ Use `const` constructors to avoid accidental state mutation
- ❌ Never log translated text in release builds (check `kDebugMode`)
- ❌ Never commit API keys, even if unused

### 4.3 Dependencies

- ✅ Pin versions in `pubspec.yaml` (we already do)
- ✅ Run `flutter pub outdated --mode=dependency` monthly
- ✅ Audit new packages with [`dartdev score`](https://pub.dev/) and `snyk`
- ❌ Never add packages with known CVEs in `pubspec.lock`

### 4.4 CI / CD

- Our GitHub Actions workflow runs:
    - `flutter analyze`
    - `dart format --set-exit-if-changed`
    - `flutter test`
    - C++ static analysis via `clang-tidy`
    - Dependency vulnerability scan via `osv-scanner`

---

## 5. Known Security Considerations

### 5.1 Online translation privacy

When translating between languages other than **Russian ↔ Turkmen** or **English ↔ Turkmen**, the text is sent to one of:

- `translate.googleapis.com` (Google Translate)
- `lingva.ml` / `lingva.lunar.icu` (Lingva)
- `api.mymemory.translated.net` (MyMemory)

Users in high-risk environments (journalists, activists, lawyers) **should only use offline pairs** (RU/EN → TK).

### 5.2 Camera permission (v2.0.0+)

The `android.permission.CAMERA` permission is declared in `AndroidManifest.xml`. It is:

- Requested at runtime only when the user opens the camera screen
- Used **exclusively** for OCR — frames are never saved or uploaded
- Can be revoked at any time in Android Settings

### 5.3 ML Kit telemetry

Google ML Kit (used for Latin-script OCR) may send anonymous usage statistics to Google. This cannot be disabled without removing ML Kit entirely. For fully private OCR, users can rely on **Tesseract-only mode** (toggle in Settings).

### 5.4 Tesseract model integrity

All 38 `.traineddata` files are checksummed. If a file is corrupted or tampered with, the app falls back to the next available model or displays a clear error — it never executes arbitrary bytes.

---

## 6. Incident Response

In case of a confirmed security incident:

1. **Contain** — disable the affected feature via remote config (if available) or push a hotfix
2. **Notify** — publish a GitHub Security Advisory within 72 hours
3. **Patch** — release a new version on GitHub and (if applicable) Google Play
4. **Communicate** — post on the project's Telegram channel and README
5. **Post-mortem** — publish a transparent write-up within 30 days

---

## 7. Cryptography

Köpri currently does **not** implement its own cryptography. We rely on:

- **HTTPS** (TLS 1.3) for all network requests
- **Android Keystore** / **iOS Keychain** for any future secure storage
- **Google Play Services** for ML Kit model integrity

If you believe the project should encrypt local translation history, please open a feature request.

---

## 8. Contact

| Role | Contact |
|---|---|
| Security lead | Aynazar Sylyyew — `@aynazar-sylyyew-dev` on GitHub |
| Organization | [Shapak-Apps](https://github.com/Shapak-Apps) |
---

Thank you for helping keep Köpri Translator safe for users in Turkmenistan and around the world. 🌉