class AboutStrings {
  final String lang;
  const AboutStrings(this.lang);

  String get appAbout => switch (lang) {
    'ru' => 'О приложении',
    'tk' => 'Programma barada',
    'tr' => 'Uygulama hakkında',
    _ => 'About the app',
  };

  String get versionLabel => switch (lang) {
    'ru' => 'Версия',
    'tk' => 'Wersiýa',
    'tr' => 'Sürüm',
    _ => 'Version',
  };

  String get authorsTitle => switch (lang) {
    'ru' => 'Об авторах',
    'tk' => 'Awtorlar barada',
    'tr' => 'Yazarlar hakkında',
    _ => 'About the Authors',
  };

  String get authorsSub => switch (lang) {
    'ru' => 'Кто создал приложение',
    'tk' => 'Programmany kim döretdi',
    'tr' => 'Uygulamayı kim oluşturdu',
    _ => 'Who created the app',
  };

  String get seriesTitle => switch (lang) {
    'ru' => 'Серия приложений Şapak',
    'tk' => 'Şapak programmalar seriýasy',
    'tr' => 'Şapak uygulama serisi',
    _ => 'Şapak App Series',
  };

  String get seriesSub => switch (lang) {
    'ru' => 'Другие приложения',
    'tk' => 'Beýleki programmalar',
    'tr' => 'Diğer uygulamalar',
    _ => 'Other apps',
  };

  String get copyright => '© 2026 Köpri';

  String get mobileDev => switch (lang) {
    'ru' => 'Мобильная разработка',
    'tk' => 'Mobil programmalaşdyrma',
    'tr' => 'Mobil geliştirme',
    _ => 'Mobile development',
  };

  String get orgText => switch (lang) {
    'ru' =>
      'Приложение Köpri разработано командой разработчиков Şapak из города Мары, Марыйского велаята, Туркменистан.',
    'tk' =>
      'Köpri programmasy Türkmenistanyň Mary welaýatynyň Mary şäherindäki Şapak programmistler topary tarapyndan döredildi.',
    'tr' =>
      "Köpri uygulaması, Türkmenistan'ın Merv ili Mary şehrindeki Şapak geliştirici ekibi tarafından geliştirilmiştir.",
    _ =>
      'The Köpri app is developed by the Şapak development team from Mary city, Mary region, Turkmenistan.',
  };

  String get missionTitle => switch (lang) {
    'ru' => 'Наша миссия',
    'tk' => 'Biziň maksadymyz',
    'tr' => 'Misyonumuz',
    _ => 'Our Mission',
  };

  String get missionText => switch (lang) {
    'ru' =>
      'Мы стремимся помочь жителям Туркменистана — как внутри страны, так и за её пределами, а также иностранным гостям — свободно и комфортно общаться на разных языках, преодолевая языковые барьеры.',
    'tk' =>
      'Biz Türkmenistanyň içinde we daşynda ýaşaýan ýaşaýjylara hem-de daşary ýurtly myhmanlara dil päsgelçiliklerini ýeňip geçmek arkaly dürli dillerde erkin we amatly aragatnaşyk etmäge kömek etmäge çalyşýarys.',
    'tr' =>
      'Hem ülke içinde hem de yurt dışında yaşayan Türkmenistan halkına ve yabancı misafirlere dil engellerini aşarak farklı dillerde özgürce ve konforlu iletişim kurmalarında yardımcı olmayı amaçlıyoruz.',
    _ =>
      'We strive to help the people of Turkmenistan, both at home and abroad, as well as international visitors, communicate freely and comfortably in different languages by overcoming language barriers.',
  };

  String get telegram => switch (lang) {
    'ru' => 'Написать в Telegram',
    'tk' => 'Telegram-da ýazmak',
    'tr' => "Telegram'da yazın",
    _ => 'Message on Telegram',
  };

  String get aboutSeriesTitle => switch (lang) {
    'ru' => 'О серии',
    'tk' => 'Seriýa barada',
    'tr' => 'Seri hakkında',
    _ => 'About the Series',
  };

  String get aboutSeriesText => switch (lang) {
    'ru' =>
      'Серия приложений Şapak представляет собой комплекс программных решений, созданных в первую очередь для помощи жителям Туркменистана в изучении иностранных языков.',
    'tk' =>
      'Şapak programmalar seriýasy ilki bilen Türkmenistanyň ýaşaýjylaryna daşary ýurt dillerini öwrenmäge kömek etmek üçin döredilen programmalar toplumydyr.',
    'tr' =>
      'Şapak uygulama serisi, her şeyden önce Türkmenistan halkına yabancı dilleri öğrenmelerinde yardımcı olmak için oluşturulmuş bir yazılım çözümleri kompleksidir.',
    _ =>
      'The Şapak app series is a suite of software solutions created primarily to help the people of Turkmenistan learn foreign languages.',
  };

  String get forAllTitle => switch (lang) {
    'ru' => 'Для всех',
    'tk' => 'Hemmeler üçin',
    'tr' => 'Herkes için',
    _ => 'For Everyone',
  };

  String get forAllText => switch (lang) {
    'ru' =>
      'Хотя наши приложения ориентированы на туркменистанцев, они могут быть с лёгкостью использованы людьми по всему миру для изучения новых языков.',
    'tk' =>
      'Biziň programmalar türkmenistanlylara gönükdirilen hem bolsa, olary täze dilleri öwrenmek üçin bütin dünýädäki adamlar aňsatlyk bilen ulanyp bilerler.',
    'tr' =>
      'Uygulamalarımız Türkmenistanlılara yönelik olsa da, yeni diller öğrenmek için dünyanın her yerindeki insanlar tarafından kolaylıkla kullanılabilir.',
    _ =>
      'Although our apps are aimed at the people of Turkmenistan, they can easily be used by people all over the world to learn new languages.',
  };

  String get kopriText => switch (lang) {
    'ru' =>
      'Köpri — четвертое приложение в серии. Это оффлайн-переводчик с обширным разговорником и текстовым переводом. Визуальный переводчик через камеру появится в ближайшем будущем.',
    'tk' =>
      'Köpri — seriýanyň dördünji programmasy. Bu giň gepleşik kitaby we tekst terjimesi bilen oflaýn terjimeçi. Kamera arkaly wizual terjimeçi ýakyn wagtda çykar.',
    'tr' =>
      'Köpri, serinin dördüncü uygulamasıdır. Kapsamlı bir konuşma kılavuzu ve metin çevirisi içeren çevrimdışı bir çevirmendir. Kamera aracılığıyla görsel çevirmen yakında gelecek.',
    _ =>
      'Köpri is the fourth app in the series. It\'s an offline translator with a comprehensive phrasebook and text translation. The visual translator via camera is coming soon.',
  };

  String get featuresTitle => switch (lang) {
    'ru' => 'Функции',
    'tk' => 'Aýratynlyklar',
    'tr' => 'Özellikler',
    _ => 'Features',
  };

  String get featPhrasebook => switch (lang) {
    'ru' =>
      'Озвученный разговорник с готовыми фразами для реальных жизненных ситуаций — озвучка на всех языках и полный офлайн-режим',
    'tk' =>
      'Hakyky durmuş ýagdaýlary üçin taýýar sözlemler bilen sesli gepleşik kitaby — ähli dillerde seslendirme we doly oflaýn režim',
    'tr' =>
      'Gerçek hayat durumları için hazır ifadelerle seslendirilmiş konuşma kılavuzu — tüm dillerde seslendirme ve tam çevrimdışı mod',
    _ =>
      'Voiced phrasebook with ready phrases for real-life situations — voice output in all languages and full offline mode',
  };

  String get featText => switch (lang) {
    'ru' => 'Текстовый переводчик',
    'tk' => 'Tekst terjimeçisi',
    'tr' => 'Metin çevirmeni',
    _ => 'Text translator',
  };

  String get featCardLearning => switch (lang) {
    'ru' => 'Обучение с карточками',
    'tk' => 'Kartlar bilen öwrenmek',
    'tr' => 'Kartlarla öğrenme',
    _ => 'Card learning',
  };

  String get featBuffer => switch (lang) {
    'ru' => 'Перевод из буфера обмена',
    'tk' => 'Buferden terjime',
    'tr' => 'Pano çevirisi',
    _ => 'Clipboard translation',
  };

  String get featMicrophone => switch (lang) {
    'ru' => 'Голосовой переводчик',
    'tk' => 'Ses terjimeçisi',
    'tr' => 'Sesli çevirmen',
    _ => 'Voice translator',
  };

  String get featCamera => switch (lang) {
    'ru' => 'Визуальный переводчик (камера)',
    'tk' => 'Wizual terjimeçi (kamera)',
    'tr' => 'Görsel çevirmen (kamera)',
    _ => 'Visual translator (camera)',
  };

  String get soon => switch (lang) {
    'ru' => 'Скоро',
    'tk' => 'Tiz wagtda',
    'tr' => 'Yakında',
    _ => 'Soon',
  };

  String get nextTitle => switch (lang) {
    'ru' => 'Что впереди',
    'tk' => 'Öňde nämeler bar',
    'tr' => 'Sırada ne var',
    _ => "What's Ahead",
  };

  String get nextText => switch (lang) {
    'ru' =>
      'Остальные приложения серии активно разрабатываются — оставайтесь с нами и следите за обновлениями, чтобы не пропустить релизы!',
    'tk' =>
      'Seriýanyň galan programmalary işjeň işlenilýär — biziň bilen galyň we täzelenmeleri synlaň, relizleri sypdyrmaň!',
    'tr' =>
      'Serinin diğer uygulamaları aktif olarak geliştiriliyor — bizimle kalın ve güncellemeleri takip edin, lansmanları kaçırmayın!',
    _ =>
      'The remaining apps in the series are under active development — stay with us and follow updates so you don\'t miss the releases!',
  };

  String get contactTitle => switch (lang) {
    'ru' => 'Связаться с нами',
    'tk' => 'Bize ýüz tutmak',
    'tr' => 'Bize ulaşın',
    _ => 'Contact Us',
  };

  String get orgGithub => switch (lang) {
    'ru' => 'GitHub организации',
    'tk' => 'Guramanyň GitHub-y',
    'tr' => "Organizasyonun GitHub'ı",
    _ => 'Organization GitHub',
  };
}
