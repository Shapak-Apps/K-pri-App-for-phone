<div align="center">

# Contributing to Kopri Translator

Offline translator with camera OCR, phrasebook and text-to-text translation

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/aynazar-sylyyew-dev/K-pri-App-for-phone/pulls)

</div>

First off, thank you for considering contributing to **Kopri Translator**! 🎉
Every contribution — code, documentation, translations, bug reports or feature ideas — makes the app better for everyone.

This document is a set of **guidelines**, not strict rules. Use your best judgment, and feel free to propose changes to this document itself in a pull request.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [I Just Have a Question](#i-just-have-a-question)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Development Workflow](#development-workflow)
- [Style Guides](#style-guides)
- [Testing](#testing)
- [Adding a New Language](#adding-a-new-language)
- [Pull Request Process](#pull-request-process)
- [Project Orientation](#project-orientation)
- [Recognition](#recognition)
- [License](#license)

---

## Code of Conduct

We are committed to providing a welcoming and inclusive experience for everyone. By participating in this project you agree to:

- Use welcoming and inclusive language.
- Be respectful of differing viewpoints and experiences.
- Gracefully accept constructive criticism.
- Focus on what is best for the community.
- Show empathy towards other community members.

Unacceptable behavior includes harassment, personal attacks, trolling, and publishing others' private information. Violations may result in removal from the community.

## I Just Have a Question

If you have a question, please don't open an issue for it. Instead:

1. Check the [README](./README.md) — it covers setup, OCR models and building.
2. Search [existing issues](https://github.com/aynazar-sylyyew-dev/K-pri-App-for-phone/issues).
3. If nothing fits, [open a new issue](https://github.com/aynazar-sylyyew-dev/K-pri-App-for-phone/issues/new) with the `question` label.

## How Can I Contribute?

### Reporting Bugs

Bugs are tracked as [GitHub issues](https://github.com/aynazar-sylyyew-dev/K-pri-App-for-phone/issues). Before creating a bug report, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **A clear title and description** of the problem.
- **Steps to reproduce** — as precise as possible.
- **Expected vs. actual behavior.**
- **Device info:** model, Android version, app version.
- **Screenshots or screen recordings** if applicable.
- **Logs** — run `flutter logs` or `adb logcat` and paste relevant output.

### Suggesting Enhancements

Enhancement suggestions are also tracked as issues. When suggesting a feature:

- Explain **what problem it solves** or what value it adds.
- Describe **how it should work**, ideally with a rough UX sketch.
- Keep the scope narrow — one feature per issue.

### Improving Documentation

Documentation improvements are always welcome: fixing typos, clarifying setup steps, translating the README into new languages, or improving inline code comments.

### Translations

The app UI and the READMEs are multilingual. You can:

- Add or correct translations in `lib/core/l10n/`.
- Translate `README.md` into a new language (create `README.<lang>.md` and add a language switcher link to all existing READMEs).

### Your First Code Contribution

Unsure where to begin? Look for issues labeled `good first issue` — they are small, well-scoped tasks perfect for getting familiar with the codebase.

## Development Setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.0+
- [Dart SDK](https://dart.dev/get-dart) (bundled with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com)
- [Git](https://git-scm.com)

Verify your environment with `flutter doctor`.

### Setting Up the Project

```bash
# Fork the repository on GitHub first, then clone your fork
git clone https://github.com/<your-username>/K-pri-App-for-phone.git
cd K-pri-App-for-phone

# Keep your fork in sync with the original repository
git remote add upstream https://github.com/aynazar-sylyyew-dev/K-pri-App-for-phone.git

# Install dependencies
flutter pub get
```

### OCR Models (Required)

Tesseract language models (`*.traineddata`) are **not stored in the repository** due to their size. To run the app locally you must download the models you need into `assets/tessdata/`:

```bash
mkdir -p assets/tessdata

# Example: English + Russian (PowerShell)
Invoke-WebRequest -Uri "https://github.com/tesseract-ocr/tessdata_fast/raw/main/eng.traineddata" -OutFile "assets/tessdata/eng.traineddata"
Invoke-WebRequest -Uri "https://github.com/tesseract-ocr/tessdata_fast/raw/main/rus.traineddata" -OutFile "assets/tessdata/rus.traineddata"
```

Available models: <https://github.com/tesseract-ocr/tessdata_fast>

### Running the App

```bash
flutter run          # debug mode with hot reload
flutter analyze      # static analysis — must pass with no issues
dart format .        # code formatting
flutter test         # run the test suite
```

## Development Workflow

1. **Create a branch** from `main`:

   ```bash
   git checkout main
   git pull upstream main
   git checkout -b <branch-name>
   ```

2. **Make your changes** in small, focused commits.
3. **Push and open a pull request** against `main`.

### Branch Naming

| Prefix | Purpose | Example |
| --- | --- | --- |
| `feature/` | New feature | `feature/camera-zoom` |
| `fix/` | Bug fix | `fix/history-crash` |
| `docs/` | Documentation | `docs/contributing-guide` |
| `refactor/` | Code refactoring | `refactor/ocr-service` |
| `test/` | Adding tests | `test/translator-service` |
| `chore/` | Maintenance | `chore/upgrade-deps` |

### Commit Messages

We follow the [Conventional Commits](https://www.conventionalcommits.org) specification:

```
<type>(<scope>): <short summary>
```

| Type | Description |
| --- | --- |
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no logic change |
| `refactor` | Neither fixes a bug nor adds a feature |
| `perf` | Performance improvement |
| `test` | Adding or fixing tests |
| `chore` | Build process, tooling, dependencies |

Examples:

```
feat(camera): add zoom control to the OCR screen
fix(l10n): correct Turkmen strings on the settings screen
docs(readme): add tessdata download instructions
```

## Style Guides

### Dart Code Style

- Follow the [Effective Dart guidelines](https://dart.dev/effective-dart) and the project's `analysis_options.yaml`.
- Run `dart format .` before committing.
- Run `flutter analyze` — PRs with analyzer warnings will not be merged.
- Prefer small, single-responsibility widgets and services; keep the existing **feature-first** organization.
- No hardcoded user-facing strings — everything goes through `lib/core/l10n/`.

### Documentation Style

- Use clear, present-tense language.
- Include code blocks with language tags for every command.
- Keep README translations in sync with the English version.

## Testing

- Write or update tests for any business logic you change (`test/` and `plugins/*/test/`).
- Run the full suite before opening a PR:

  ```bash
  flutter test
  ```

- For UI changes, manually verify on at least one real device or emulator, including:
  - camera OCR flow,
  - text-to-text translation,
  - phrasebook navigation,
  - history and favorites.

## Adding a New Language

1. **UI strings** — add the locale in `lib/core/l10n/app_strings.dart` and `app_localizations.dart`.
2. **Language list** — register the language (code, name, flag) in `lib/features/translate/data/languages.dart`.
3. **OCR support** — verify Tesseract supports the language, document its `<code>.traineddata` download, and test recognition on a real photo.
4. **Phrasebook (optional)** — add phrase categories in `lib/features/phrasebook/data/phrasebook_data.dart`.
5. **README** — add the language flag to the supported-languages list if applicable.

## Pull Request Process

1. Ensure your branch is up to date with `main`.
2. Make sure all checks pass locally (`analyze`, `format`, `test`).
3. Open a PR with a **clear title** (conventional-commit style) and a description explaining **what** changed and **why**.
4. Link any related issues (`Fixes #123`).
5. Add screenshots or recordings for UI changes.

### PR Checklist

- [ ] `flutter analyze` passes with no issues
- [ ] `dart format .` applied
- [ ] `flutter test` passes
- [ ] Documentation updated where needed
- [ ] Tested on at least one device/emulator
- [ ] Commits follow the conventional format
- [ ] No unrelated changes included

### Review Process

- Maintainers will review your PR and may request changes.
- Address feedback and push updates to the same branch — the PR updates automatically.
- Once approved, a maintainer will merge your PR. 🎉

## Project Orientation

```
lib/
├── core/        # theme, localization, shared widgets, controllers
└── features/    # camera, translate, phrasebook, history, flashcards, settings
plugins/         # locally bundled flutter_tesseract_ocr plugin
assets/tessdata/ # OCR models — NOT in git, download separately
```

The codebase follows a **feature-first, clean-architecture** approach: each feature keeps its `data/` (services, models) and `presentation/` (screens, widgets) layers separated.

## Recognition

Contributors are recognized in release notes, and significant contributions may be highlighted in the README. Thank you for making Kopri Translator better! ❤️

## License

By contributing to this project, you agree that your contributions will be licensed under the [Apache License 2.0](./LICENSE), the same license that covers the project.

---

<div align="center">

Made with ❤️ and Flutter — thank you for contributing!

</div>