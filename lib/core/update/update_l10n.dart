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

  // ── Strings for the "can't reach GitHub" dialog ─────────────────────
  String get networkErrorTitle => switch (lang) {
    'ru' => 'Не удалось подключиться к GitHub',
    'tk' => 'GitHub-a birigip bolmady',
    'tr' => 'GitHub\'a bağlanılamadı',
    _ => 'Could not reach GitHub',
  };

  String get networkErrorBody => switch (lang) {
    'ru' =>
      'Не удалось проверить обновления. Проверьте подключение к интернету, попробуйте включить VPN или обновите приложение через RuStore.',
    'tk' =>
      'Täzelenmeleri barlap bolmady. Interneti barlaň, VPN açyp görüň ýa-da programmany RuStore arkaly täzeläň.',
    'tr' =>
      'Güncellemeler denetlenemedi. İnternet bağlantınızı kontrol edin, VPN açmayı deneyin veya uygulamayı RuStore üzerinden güncelleyin.',
    _ =>
      'Could not check for updates. Check your internet connection, try turning on a VPN, or update the app through RuStore.',
  };

  String get openRustore => switch (lang) {
    'ru' => 'Открыть RuStore',
    'tk' => 'RuStore-y aç',
    'tr' => 'RuStore\'u aç',
    _ => 'Open RuStore',
  };

  String get tryAgain => switch (lang) {
    'ru' => 'Попробовать снова',
    'tk' => 'Ýene synanyş',
    'tr' => 'Tekrar dene',
    _ => 'Try again',
  };

  // ── Strings for the in-app download + install flow ──────────────────
  String get downloading => switch (lang) {
    'ru' => 'Загрузка обновления…',
    'tk' => 'Täzelenme ýüklenýär…',
    'tr' => 'Güncelleme indiriliyor…',
    _ => 'Downloading update…',
  };

  String get installing => switch (lang) {
    'ru' => 'Установка…',
    'tk' => 'Gurnalýar…',
    'tr' => 'Kuruluyor…',
    _ => 'Installing…',
  };

  String get cancel => switch (lang) {
    'ru' => 'Отмена',
    'tk' => 'Ýatyr',
    'tr' => 'İptal',
    _ => 'Cancel',
  };

  String get downloadFailed => switch (lang) {
    'ru' => 'Не удалось загрузить обновление',
    'tk' => 'Täzelenmäni ýükläp bolmady',
    'tr' => 'Güncelleme indirilemedi',
    _ => 'Failed to download update',
  };

  // ── Strings for the "enable unknown sources" flow ──────────────────
  String get enableInstallHint => switch (lang) {
    'ru' =>
      'Разрешите установку в настройках — обновление запустится автоматически',
    'tk' => 'Gurmaga rugsat beriň — täzelenme awtomatiki başlar',
    'tr' =>
      'Ayarlardan kuruluma izin verin — güncelleme otomatik başlayacaktır',
    _ => 'Allow installs in settings — the update will start automatically',
  };

  String get tapFileToInstall => switch (lang) {
    'ru' => 'Нажмите на файл APK, чтобы установить обновление',
    'tk' => 'Täzelenmäni gurmak üçin APK faýla basyň',
    'tr' => 'Güncellemeyi kurmak için APK dosyasına dokunun',
    _ => 'Tap the APK file to install the update',
  };

  // ── Strings for the install-permission dialog ────────────────────────
  String get permissionTitle => switch (lang) {
    'ru' => 'Нужно разрешение',
    'tk' => 'Rugsat gerek',
    'tr' => 'İzin gerekiyor',
    _ => 'Permission needed',
  };

  String get permissionOnce => switch (lang) {
    'ru' => 'Только один раз',
    'tk' => 'Diňe bir gezek',
    'tr' => 'Yalnızca bir kez',
    _ => 'One-time setup',
  };

  String get permissionBody => switch (lang) {
    'ru' =>
      'Чтобы устанавливать обновления напрямую, разрешите Köpri устанавливать приложения из неизвестных источников. Нажмите «Настройки», включите переключатель и вернитесь — установка начнётся автоматически.',
    'tk' =>
      'Täzelenmeleri göni gurmak üçin Köpri-ä nätanyş çeşmelerden programma gurmaga rugsat beriň. «Sazlamalar» basyň, açary açyň we yzyňyza gaýdyň — gurnama awtomatik başlanar.',
    'tr' =>
      'Güncellemeleri doğrudan yüklemek için Köpri\'nin bilinmeyen kaynaklardan uygulama yüklemesine izin verin. «Ayarlar»a dokunun, anahtarı açın ve geri dönün — kurulum otomatik başlayacak.',
    _ =>
      'To install updates directly, allow Köpri to install from unknown sources. Tap Settings, enable the toggle, and come back — the install starts automatically.',
  };

  String get openSettings => switch (lang) {
    'ru' => 'Открыть настройки',
    'tk' => 'Sazlamalary aç',
    'tr' => 'Ayarları aç',
    _ => 'Open settings',
  };
}
