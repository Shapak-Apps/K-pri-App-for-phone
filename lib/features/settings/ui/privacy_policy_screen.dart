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
                      icon: Icons.cloud_off_rounded,
                      title: t.sec4Title,
                      body: t.sec4Body,
                      index: 3,
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      c: c,
                      icon: Icons.child_care_rounded,
                      title: t.sec5Title,
                      body: t.sec5Body,
                      index: 4,
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
      'Мы создали Köpri так, чтобы ваши переводы оставались только у вас. Никакой слежки, никакой рекламы, никакой продажи данных. Вот как это работает:',
    'tk' =>
      'Biz Köpri-ni siziň terjimeleňiziň diňe sizde galar ýaly etdik. Hiç hili göz yzarlamasy, hiç hili mahabat, hiç hili maglumat satuwymy. Ine, nähili işleýär:',
    'tr' =>
      'Köpri\'yi çevirilerinizin yalnızca sizde kalması için tasarladık. Takip yok, reklam yok, veri satışı yok. İşte nasıl çalışıyor:',
    _ =>
      'We built Köpri so your translations stay only with you. No tracking, no ads, no data selling. Here\'s how it works:',
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
      'Интернет — для онлайн-перевода',
      'Уведомления — для фоновой работы',
      'Любое разрешение можно отключить в настройках телефона',
    ],
    'tk' => [
      'Kamera — suratlardaky teksti terjime etmek üçin (ýakyn wagtda)',
      'Mikrofon — ses bilen girizmek üçin (ýakyn wagtda)',
      'Internet — onlaýn terjime üçin',
      'Habarnamalar — arka planda işlemek üçin',
      'Islendik rugsady telefon sazlamalarynda öçürip bolýar',
    ],
    'tr' => [
      'Kamera — fotoğraflardaki metni çevirmek için (yakında)',
      'Mikrofon — sesli giriş için (yakında)',
      'İnternet — çevrimiçi çeviri için',
      'Bildirimler — arka planda çalışmak için',
      'Herhangi bir izin telefon ayarlarından kapatılabilir',
    ],
    _ => [
      'Camera — for translating text from photos (coming soon)',
      'Microphone — for voice input (coming soon)',
      'Internet — for online translation',
      'Notifications — for background work',
      'Any permission can be turned off in phone settings',
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
      'Когда вы скачиваете язык для оффлайн-работы, всё переводится прямо на вашем телефоне. Ни одно слово не уходит в интернет. Это самый безопасный способ перевода — даже без связи ваши тексты остаются только у вас.',
    'tk' =>
      'Offlaýn işlemek üçin dil ýükläniňizde, hemme zat göni telefonyňyzda terjime edilýär. Hiç bir söz internete gitmeýär. Bu terjime etmegiň iň howpsuz usuly — hatda baglanyşyksyz hem tekstleriňiz diňe sizde galýar.',
    'tr' =>
      'Çevrimdışı çalışmak için bir dil indirdiğinizde, her şey doğrudan telefonunuzda çevrilir. Hiçbir kelime internete gitmez. Bu çeviri yapmanın en güvenli yoludur — bağlantı olmadan bile metinleriniz yalnızca sizde kalır.',
    _ =>
      'When you download a language for offline use, everything is translated right on your phone. Not a single word goes to the internet. This is the safest way to translate — even without connection, your texts stay only with you.',
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
    'ru' => 'Köpri · Обновлено: сентябрь 2026',
    'tk' => 'Köpri · Täzelendi: sentýabr 2026',
    'tr' => 'Köpri · Güncellendi: Eylül 2026',
    _ => 'Köpri · Updated: September 2026',
  };
}
