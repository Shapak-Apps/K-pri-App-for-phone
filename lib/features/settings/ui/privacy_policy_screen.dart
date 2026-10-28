import 'package:flutter/material.dart';
import 'package:kopri/core/controllers/app_settings_controller.dart';
import 'package:kopri/core/theme/app_colors.dart';
import 'package:kopri/core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.settings;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final c = context.c;
        final lang = s.lang.name;
        final t = _Strings(lang);

        return Scaffold(
          backgroundColor: c.bg,
          body: CustomScrollView(
            slivers: [
              _buildHeader(c, t),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _IntroCard(c: c, t: t),
                    const SizedBox(height: 14),
                    _Section(
                      c: c,
                      icon: Icons.shield_outlined,
                      title: t.sec1Title,
                      body: t.sec1Body,
                      bullets: t.sec1Bullets,
                      index: 0,
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      c: c,
                      icon: Icons.storage_rounded,
                      title: t.sec2Title,
                      body: t.sec2Body,
                      bullets: t.sec2Bullets,
                      index: 1,
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      c: c,
                      icon: Icons.sensors_rounded,
                      title: t.sec3Title,
                      body: t.sec3Body,
                      bullets: t.sec3Bullets,
                      index: 2,
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      c: c,
                      icon: Icons.public_rounded,
                      title: t.secNetTitle,
                      body: t.secNetBody,
                      bullets: t.secNetBullets,
                      index: 3,
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      c: c,
                      icon: Icons.cloud_off_rounded,
                      title: t.sec4Title,
                      body: t.sec4Body,
                      index: 4,
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      c: c,
                      icon: Icons.child_care_rounded,
                      title: t.sec5Title,
                      body: t.sec5Body,
                      index: 5,
                    ),
                    const SizedBox(height: 18),
                    _ContactCard(c: c, t: t),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        t.footer,
                        style: AppTheme.caption(color: c.faint, size: 11),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppColors c, _Strings t) {
    return SliverAppBar(
      backgroundColor: c.bg,
      foregroundColor: c.text,
      elevation: 0,
      pinned: true,
      expandedHeight: 180,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
        title: Text(
          t.headerTitle,
          style: AppTheme.display(size: 17, color: c.text),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c.accent.withValues(alpha: 0.22), c.bgSoft, c.bg],
                ),
              ),
            ),
            Positioned(
              right: -40,
              top: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      c.accent.withValues(alpha: 0.30),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.82, -0.15),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [c.accent, c.accentDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.privacy_tip_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final AppColors c;
  final _Strings t;
  const _IntroCard({required this.c, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.accent.withValues(alpha: 0.14), c.surface],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.favorite_rounded, color: c.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.introTitle,
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.introBody,
                  style: TextStyle(color: c.sub, fontSize: 12.5, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String title;
  final String body;
  final List<String>? bullets;
  final int index;

  const _Section({
    required this.c,
    required this.icon,
    required this.title,
    required this.body,
    required this.index,
    this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 320 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - v)),
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        c.accent.withValues(alpha: 0.25),
                        c.accentDeep.withValues(alpha: 0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: c.accent, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: c.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: TextStyle(color: c.sub, fontSize: 13, height: 1.55),
            ),
            if (bullets != null && bullets!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...bullets!.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: c.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          b,
                          style: TextStyle(
                            color: c.sub,
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final AppColors c;
  final _Strings t;
  const _ContactCard({required this.c, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.accentDeep.withValues(alpha: 0.90),
            c.accent.withValues(alpha: 0.80),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                t.contactTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            t.contactBody,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'shapak.apps@gmail.com',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Strings {
  final String lang;
  _Strings(this.lang);

  String get headerTitle => switch (lang) {
    'ru' => 'Конфиденциальность',
    'tk' => 'Gizlinlik',
    'tr' => 'Gizlilik',
    _ => 'Privacy',
  };

  String get introTitle => switch (lang) {
    'ru' => 'Ваши данные — ваши',
    'tk' => 'Siziň maglumatlaryňyz — siziňki',
    'tr' => 'Verileriniz — sizin',
    _ => 'Your data is yours',
  };

  String get introBody => switch (lang) {
    'ru' =>
      'История, избранное и прогресс хранятся на вашем телефоне. Никакой рекламы, никакой продажи данных. Вот как это работает:',
    'tk' =>
      'Taryhyňyz, halanlaryňyz we öňegidişligiňiz telefonyňyzda saklanýar. Mahabat ýok, maglumat satuwy ýok. Ine, nähili işleýär:',
    'tr' =>
      'Geçmişiniz, favorileriniz ve ilerlemeniz telefonunuzda kalır. Reklam yok, veri satışı yok. İşte nasıl çalışıyor:',
    _ =>
      'Your history, favorites and progress stay on your phone. No ads, no data selling. Here\'s how it works:',
  };

  String get sec1Title => switch (lang) {
    'ru' => 'Что мы НЕ собираем',
    'tk' => 'Näme ÝYGNAMEÝARYS',
    'tr' => 'NE toplamıyoruz',
    _ => 'What we do NOT collect',
  };

  String get sec1Body => switch (lang) {
    'ru' => 'Мы принципиально не собираем:',
    'tk' => 'Biz asla ýygnamaýarys:',
    'tr' => 'Asla toplamayız:',
    _ => 'We never collect:',
  };

  List<String> get sec1Bullets => switch (lang) {
    'ru' => [
      'Ваше имя, email, телефон или адрес',
      'Ваши банковские данные или платежи',
      'Ваше местоположение (GPS, IP)',
      'Отпечатки пальцев или лицо',
      'Рекламные профили и трекеры',
    ],
    'tk' => [
      'Adyňyz, e-poçtaňyz, telefon ýa-da salgyňyz',
      'Bank maglumatlaryňyz ýa-da tölegleriňiz',
      'Ýerleşýän ýeriňiz (GPS, IP)',
      'Barmak yzyňyz ýa-da ýüzüňiz',
      'Mahabat profilleri we trekerler',
    ],
    'tr' => [
      'Adınız, e-postanız, telefon veya adresiniz',
      'Banka bilgileriniz veya ödemeleriniz',
      'Konumunuz (GPS, IP)',
      'Parmak iziniz veya yüzünüz',
      'Reklam profilleri ve izleyiciler',
    ],
    _ => [
      'Your name, email, phone, or address',
      'Your bank details or payments',
      'Your location (GPS, IP)',
      'Fingerprints or face',
      'Ad profiles and trackers',
    ],
  };

  String get sec2Title => switch (lang) {
    'ru' => 'Что остаётся на вашем телефоне',
    'tk' => 'Telefonyňyzda galýan zatlar',
    'tr' => 'Telefonunuzda kalanlar',
    _ => 'What stays on your phone',
  };

  String get sec2Body => switch (lang) {
    'ru' => 'Всё это хранится только у вас, никуда не отправляется:',
    'tk' => 'Bularyň hemmesi diňe sizde saklanýar, hiç ýere iberilmeýär:',
    'tr' => 'Bunların hepsi yalnızca sizde saklanır, hiçbir yere gönderilmez:',
    _ => 'All of this stays only on your device, never sent anywhere:',
  };

  List<String> get sec2Bullets => switch (lang) {
    'ru' => [
      'История переводов и избранное',
      'Настройки: тема, язык, размер текста',
      'Ваш прогресс: уровни, серии дней, достижения',
      'Имя профиля и аватарка',
      'Оффлайн-модели языков (только те, что вы скачали)',
    ],
    'tk' => [
      'Terjime taryhy we halanlar',
      'Sazlamalar: tema, dil, tekst ölçegi',
      'Öňegidişligiňiz: derejeler, gün seriýalary, üstünlikler',
      'Profil ady we awatar',
      'Offlaýn dil modelleri (diňe ýükläp alanlaryňyz)',
    ],
    'tr' => [
      'Çeviri geçmişi ve favoriler',
      'Ayarlar: tema, dil, metin boyutu',
      'İlerlemeniz: seviyeler, gün serileri, başarılar',
      'Profil adı ve avatar',
      'Çevrimdışı dil modelleri (yalnızca indirdikleriniz)',
    ],
    _ => [
      'Translation history and favorites',
      'Settings: theme, language, text size',
      'Your progress: levels, day streaks, achievements',
      'Profile name and avatar',
      'Offline language models (only what you downloaded)',
    ],
  };

  String get sec3Title => switch (lang) {
    'ru' => 'Разрешения телефона',
    'tk' => 'Telefon rugsatlary',
    'tr' => 'Telefon izinleri',
    _ => 'Phone permissions',
  };

  String get sec3Body => switch (lang) {
    'ru' => 'Приложение может попросить доступ к:',
    'tk' => 'Programma şulara giriş sorap biler:',
    'tr' => 'Uygulama şunlara erişim isteyebilir:',
    _ => 'The app may ask for access to:',
  };

  List<String> get sec3Bullets => switch (lang) {
    'ru' => [
      'Камера — для перевода текста с фото (скоро)',
      'Микрофон — для голосового ввода (скоро)',
      'Интернет — для онлайн-перевода и отчётов о сбоях',
      'Уведомления — для фоновой работы',
      'Любое разрешение можно отключить в настройках телефона',
    ],
    'tk' => [
      'Kamera — suratlardaky teksti terjime etmek üçin (ýakyn wagtda)',
      'Mikrofon — ses bilen girizmek üçin (ýakyn wagtda)',
      'Internet — onlaýn terjime we näsazlyk hasabatlary üçin',
      'Habarnamalar — arka planda işlemek üçin',
      'Islendik rugsady telefon sazlamalarynda öçürip bolýar',
    ],
    'tr' => [
      'Kamera — fotoğraflardaki metni çevirmek için (yakında)',
      'Mikrofon — sesli giriş için (yakında)',
      'İnternet — çevrimiçi çeviri ve çökme raporları için',
      'Bildirimler — arka planda çalışmak için',
      'Herhangi bir izin telefon ayarlarından kapatılabilir',
    ],
    _ => [
      'Camera — for translating text from photos (coming soon)',
      'Microphone — for voice input (coming soon)',
      'Internet — for online translation and crash reports',
      'Notifications — for background work',
      'Any permission can be turned off in phone settings',
    ],
  };

  String get secNetTitle => switch (lang) {
    'ru' => 'Что уходит в интернет',
    'tk' => 'Internete näme gidýär',
    'tr' => 'İnternete ne gider',
    _ => 'What goes to the internet',
  };

  String get secNetBody => switch (lang) {
    'ru' => 'Часть данных покидает ваш телефон:',
    'tk' => 'Käbir maglumatlar telefonyňyzdan çykýar:',
    'tr' => 'Bazı veriler telefonunuzdan çıkar:',
    _ => 'Some data leaves your phone:',
  };

  List<String> get secNetBullets => switch (lang) {
    'ru' => [
      'Текст, который вы переводите онлайн, уходит в Google Translate, Lingva (три сервера, их держат другие люди) и MyMemory. Приложение отправляет его всем сразу и берёт первый ответ.',
      'Скопированный текст уходит в те же сервисы, когда его переводит пузырёк буфера обмена.',
      'Отчёты о сбоях уходят в Firebase Crashlytics (Google): что сломалось, модель телефона, версия Android и версия приложения.',
    ],
    'tk' => [
      'Onlaýn terjime edýän tekstiňiz Google Translate, Lingva (beýleki adamlaryň dolandyrýan üç serweri) we MyMemory hyzmatlaryna gidýär. Programma ony hemmesine birden iberýär we ilkinji jogaby alýar.',
      'Göçüren tekstiňizi bufer terjime köpügi terjime edende, ol hem şol hyzmatlara gidýär.',
      'Näsazlyk hasabatlary Firebase Crashlytics-e (Google) gidýär: näme ýalňyş boldy, telefonyňyzyň modeli, Android wersiýasy we programmanyň wersiýasy.',
    ],
    'tr' => [
      'Çevrimiçi çevirdiğiniz metin Google Translate, Lingva (başka kişilerin yönettiği üç sunucu) ve MyMemory\'ye gider. Uygulama metni hepsine aynı anda gönderir ve ilk cevabı kullanır.',
      'Kopyaladığınız metin, pano çeviri balonu onu çevirdiğinde aynı hizmetlere gider.',
      'Çökme raporları Firebase Crashlytics\'e (Google) gider: ne yanlış gitti, cihaz modeliniz, Android sürümü ve uygulama sürümü.',
    ],
    _ => [
      'Text you translate online goes to Google Translate, Lingva (three servers run by other people) and MyMemory. The app sends it to all of them at once and uses the first answer.',
      'Text you copy goes to the same services when the clipboard bubble translates it.',
      'Crash reports go to Firebase Crashlytics (Google): what went wrong, your device model, Android version and app version.',
    ],
  };

  String get sec4Title => switch (lang) {
    'ru' => 'Оффлайн-режим',
    'tk' => 'Oflaýn režim',
    'tr' => 'Çevrimdışı mod',
    _ => 'Offline mode',
  };

  String get sec4Body => switch (lang) {
    'ru' =>
      'Когда оффлайн-модель языка скачана, приложение сначала переводит прямо на телефоне. Если оффлайн-перевод не ответил быстро или ничего не дал, текст уходит в онлайн-сервисы выше. Пузырёк буфера обмена не использует оффлайн-модели: ему всегда нужен интернет.',
    'tk' =>
      'Diliň oflaýn modeli ýüklenen bolsa, programma ilki göni telefonyňyzda terjime edýär. Eger oflaýn terjime çalt jogap bermese ýa-da hiç zat bermese, tekst ýokardaky onlaýn hyzmatlara gidýär. Bufer terjime köpügi oflaýn modelleri ulanmaýar: oňa elmydama internet gerek.',
    'tr' =>
      'Bir dilin çevrimdışı modeli hazır olduğunda, uygulama önce doğrudan telefonunuzda çevirir. Çevrimdışı çeviri hızlı cevap vermezse veya bir şey vermezse, metin yukarıdaki çevrimiçi hizmetlere gider. Pano çeviri balonu çevrimdışı modelleri kullanmaz: her zaman internete ihtiyaç duyar.',
    _ =>
      'When the offline model for a language is ready, the app translates right on your phone first. If the offline translation does not answer quickly or gives nothing, the text goes to the online services above. The clipboard bubble does not use offline models: it always needs the internet.',
  };

  String get sec5Title => switch (lang) {
    'ru' => 'Дети',
    'tk' => 'Çagalar',
    'tr' => 'Çocuklar',
    _ => 'Children',
  };

  String get sec5Body => switch (lang) {
    'ru' =>
    'Приложением могут пользоваться дети. Но следят за детьми их родители — мы не проверяем возраст и не отвечаем за то, что дети делают в приложении. Если вы родитель и хотите, чтобы ребёнок не пользовался Köpri — просто удалите приложение с его телефона.',
    'tk' =>
    'Programmany çagalar hem ulanyp biler. Emma çagalara ene-atalary gözegçilik edýär — biz ýaşyny barlamaýarys we çagalaryň programmada näme edýändigi üçin jogap bermeýäris. Eger ene-ata bolsaňyz we çagaňyzyň Köpri ulanmagyny islemeýän bolsaňyz — diňe onuň telefonyndan programmany aýyryň.',
    'tr' =>
    'Uygulamayı çocuklar da kullanabilir. Ama çocukları ebeveynleri denetler — biz yaşı kontrol etmiyoruz ve çocukların uygulamada ne yaptığından sorumlu değiliz. Ebeveyseniz ve çocuğunuzun Köpri kullanmasını istemiyorsanız — telefonundan uygulamayı silin.',
    _ =>
    'Children can use the app. But parents supervise children — we do not check ages and are not responsible for what children do in the app. If you are a parent and don\'t want your child to use Köpri — just remove the app from their phone.',
  };

  String get contactTitle => switch (lang) {
    'ru' => 'Есть вопросы?',
    'tk' => 'Soraglaryňyz barmy?',
    'tr' => 'Sorularınız mı var?',
    _ => 'Have questions?',
  };

  String get contactBody => switch (lang) {
    'ru' =>
      'Напишите нам, если хотите удалить данные, что-то спросить или просто пообщаться:',
    'tk' =>
      'Maglumatlary pozmak, bir zat soramak ýa-da diňe gürrüňdeş bolmak isleseňiz bize ýazyň:',
    'tr' =>
      'Verileri silmek, bir şey sormak veya sadece sohbet etmek isterseniz bize yazın:',
    _ => 'Write to us if you want to delete data, ask something, or just chat:',
  };

  String get footer => switch (lang) {
    'ru' => 'Köpri · Обновлено: октябрь 2026',
    'tk' => 'Köpri · Täzelendi: oktýabr 2026',
    'tr' => 'Köpri · Güncellendi: Ekim 2026',
    _ => 'Köpri · Updated: October 2026',
  };
}
