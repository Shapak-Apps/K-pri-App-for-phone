// ─────────────────────────────────────────────────────────────────────────────
// KÖPRI UPDATE L10N
//
// Localized copy for the in-app update flow (ru / tk / tr / en).
// Follows the same pattern as AboutStrings: a lightweight class keyed by the
// interface language name, so the update module stays fully self-contained
// (no edits to app_strings.dart are required).
// ─────────────────────────────────────────────────────────────────────────────

class UpdateStrings {
  final String lang;
  const UpdateStrings(this.lang);

  String get checkUpdates => switch (lang) {
    'ru' => 'Проверить обновления',
    'tk' => 'Täzelenmeleri barla',
    'tr' => 'Güncellemeleri denetle',
    _ => 'Check for updates',
  };

  String get checkUpdatesSub => switch (lang) {
    'ru' => 'Поиск новой версии на GitHub',
    'tk' => 'GitHub-da täze wersiýa gözlenýär',
    'tr' => 'GitHub\'da yeni sürüm aranıyor',
    _ => 'Looking for a new version on GitHub',
  };

  String get checking => switch (lang) {
    'ru' => 'Проверка…',
    'tk' => 'Barlanylýar…',
    'tr' => 'Denetleniyor…',
    _ => 'Checking…',
  };

  String get upToDate => switch (lang) {
    'ru' => 'У вас последняя версия',
    'tk' => 'Sizde iň soňky wersiýa',
    'tr' => 'En son sürümdesiniz',
    _ => 'You are up to date',
  };

  String get available => switch (lang) {
    'ru' => 'Доступно обновление',
    'tk' => 'Täzelenme elýeterli',
    'tr' => 'Güncelleme mevcut',
    _ => 'Update available',
  };

  String availableMsg(String v) => switch (lang) {
    'ru' => 'Версия $v доступна. Обновить сейчас?',
    'tk' => '$v wersiýasy elýeterli. Häzir täzeleýärismi?',
    'tr' => '$v sürümü mevcut. Şimdi güncellensin mi?',
    _ => 'Version $v is available. Update now?',
  };

  String get downloadApk => switch (lang) {
    'ru' => 'Скачать APK с GitHub',
    'tk' => 'GitHub-dan APK ýükle',
    'tr' => 'GitHub\'dan APK indir',
    _ => 'Download APK from GitHub',
  };

  String get rustore => switch (lang) {
    'ru' => 'Обновить в RuStore',
    'tk' => 'RuStore-da täzele',
    'tr' => 'RuStore\'da güncelle',
    _ => 'Update in RuStore',
  };

  String get later => switch (lang) {
    'ru' => 'Позже',
    'tk' => 'Soňra',
    'tr' => 'Daha sonra',
    _ => 'Later',
  };

  String get failed => switch (lang) {
    'ru' => 'Не удалось проверить обновления',
    'tk' => 'Täzelenmeleri barlap bolmady',
    'tr' => 'Güncellemeler denetlenemedi',
    _ => 'Failed to check for updates',
  };

  String get failedSub => switch (lang) {
    'ru' => 'Проверьте интернет и попробуйте ещё раз',
    'tk' => 'Interneti barlaň we ýene synanyşyň',
    'tr' => 'İnterneti kontrol edin ve tekrar deneyin',
    _ => 'Check your connection and try again',
  };

  String get changelog => switch (lang) {
    'ru' => 'ЧТО НОВОГО',
    'tk' => 'NÄME TÄZE',
    'tr' => 'YENILIKLER',
    _ => 'WHAT\'S NEW',
  };

  String currentVersion(String v) => switch (lang) {
    'ru' => 'Текущая версия: $v',
    'tk' => 'Häzirki wersiýa: $v',
    'tr' => 'Mevcut sürüm: $v',
    _ => 'Current version: $v',
  };
}
