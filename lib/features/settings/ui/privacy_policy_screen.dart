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
                      icon: Icons.layers_outlined,
                      title: t.sec4Title,
                      body: t.sec4Body,
                      bullets: t.sec4Bullets,
                      index: 3,
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      c: c,
                      icon: Icons.cloud_off_rounded,
                      title: t.sec5Title,
                      body: t.sec5Body,
                      index: 4,
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      c: c,
                      icon: Icons.child_care_rounded,
                      title: t.sec6Title,
                      body: t.sec6Body,
                      index: 5,
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      c: c,
                      icon: Icons.update_rounded,
                      title: t.sec7Title,
                      body: t.sec7Body,
                      index: 6,
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
            Positioned(
              left: -60,
              bottom: 20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      c.accentHi.withValues(alpha: 0.18),
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
          Row(
            children: [
              Icon(
                Icons.telegram_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Köpri support',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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
    'ru' => 'Политика конфиденциальности',
    'tk' => 'Gizlinlik syýasaty',
    'tr' => 'Gizlilik Politikası',
    _ => 'Privacy Policy',
  };

  String get introTitle => switch (lang) {
    'ru' => 'Защита ваших персональных данных',
    'tk' => 'Siziň şahsy maglumatlaryňyzyň goragy',
    'tr' => 'Kişisel verilerinizin korunması',
    _ => 'Protection of your personal data',
  };

  String get introBody => switch (lang) {
    'ru' =>
    'Köpri («Мы», «Правообладатель») обязуется обеспечивать максимальный уровень защиты вашей частной жизни и безопасности ваших данных. Настоящая Политика конфиденциальности (далее «Политика») разъясняет, какие данные обрабатываются, какие не обрабатываются, где хранятся ваши данные и как осуществляется взаимодействие с третьими сторонами. Используя Köpri, вы соглашаетесь с методами обработки данных, описанными в настоящей Политике.',
    'tk' =>
    'Köpri («Biz», «Önümi eýesi») siziň şahsy durmuşyňyzyň elde degirmesizligini we maglumatlaryňyzyň howpsuzlygyny iň ýokary derejede goramaga borçlanýar. Şu Gizlinlik syýasaty (mundan beýläk «Syýasat») haýsy maglumatlaryň işlenýändigini, haýsylarynyň işlenmeýändigini, maglumatlaryňyzyň nirede saklanýandygyny we üçünji taraplar bilen nähili gatnaşykda bolýandygyny düşündirýär. Köpri ulanmak bilen, şu Syýasatda beýan edilen maglumat işläp taýýarlamak usullaryna razylyk berýärsiňiz.',
    'tr' =>
    'Köpri ("Biz", "Sahip") gizliliğinizin ve veri güvenliğinizin en yüksek düzeyde korunmasını taahhüt eder. Bu Gizlilik Politikası (bundan sonra "Politika"), hangi verilerin işlendiğini, hangilerinin işlenmediğini, verilerinizin nerede saklandığını ve üçüncü taraflarla etkileşimin nasıl gerçekleştiğini açıklar. Köpri\'yi kullanarak, bu Politikada açıklanan veri işleme yöntemlerini kabul etmiş olursunuz.',
    _ =>
    'Köpri ("We", "the Owner") is committed to ensuring the highest level of protection for your privacy and data security. This Privacy Policy (hereinafter "the Policy") explains what data is processed, what is not processed, where your data is stored, and how interaction with third parties occurs. By using Köpri, you agree to the data processing methods described in this Policy.',
  };

  String get sec1Title => switch (lang) {
    'ru' => '1. Что мы НЕ собираем',
    'tk' => '1. Biz näme ÝYGNAMEÝARYS',
    'tr' => '1. NE toplamadığımız',
    _ => '1. What we do NOT collect',
  };

  String get sec1Body => switch (lang) {
    'ru' =>
    'Köpri построен по принципу «приватность по умолчанию» (privacy-by-design). Мы никогда и ни в какой форме не собираем следующие данные:',
    'tk' =>
    'Köpri «ilki bilen gizlinlik» (privacy-by-design) ýörelgesi esasynda guruldy. Biz aşakdaky maglumatlary hiç haçan we hiç hili görnüşde ýygnamaýarys:',
    'tr' =>
    'Köpri, "tasarımla gizlilik" (privacy-by-design) ilkesi üzerine kuruludur. Aşağıdaki verileri asla ve hiçbir biçimde toplamayız:',
    _ =>
    'Köpri is built on a "privacy-by-design" principle. We never, in any form, collect the following data:',
  };

  List<String> get sec1Bullets => switch (lang) {
    'ru' => [
      'Персональные идентифицирующие данные (имя, фамилия, отчество, дата рождения)',
      'Контактные данные (email, номер телефона, почтовый адрес)',
      'Платёжные и финансовые данные (банковские карты, счета, транзакции)',
      'Геолокационные данные (GPS-координаты, IP-адреса, сетевые метаданные)',
      'Биометрические данные (отпечатки пальцев, распознавание лиц, голосовые образцы)',
      'Рекламные профили, идентификаторы трекеров и аналитические cookie-файлы',
    ],
    'tk' => [
      'Şahsyýeti anyklaýjy maglumatlar (at, familiýa, ata ady, doglan senesi)',
      'Habarlaşma maglumatlary (e-poçta salgysy, telefon belgisi, poçta salgysy)',
      'Töleg we maliýe maglumatlary (bank kartlary, hasaplar, tranzaksiýalar)',
      'Geolokasiýa maglumatlary (GPS koordinatalary, IP-salgylar, tor metadata)',
      'Biometrik maglumatlar (barmak yzy, ýüz tanama, ses nusgalary)',
      'Mahabat profilleri, treker identifikatorlary we analitik cookie-faýllar',
    ],
    'tr' => [
      'Kişiyi tanımlayan bilgiler (ad, soyad, baba adı, doğum tarihi)',
      'İletişim bilgileri (e-posta, telefon numarası, posta adresi)',
      'Ödeme ve finansal bilgiler (banka kartları, hesaplar, işlemler)',
      'Konum verileri (GPS koordinatları, IP adresleri, ağ meta verileri)',
      'Biyometrik veriler (parmak izi, yüz tanıma, ses örnekleri)',
      'Reklam profilleri, izleyici tanımlayıcıları ve analitik çerezler',
    ],
    _ => [
      'Personal identifying information (name, surname, patronymic, date of birth)',
      'Contact information (email, phone number, postal address)',
      'Payment and financial information (bank cards, accounts, transactions)',
      'Geolocation data (GPS coordinates, IP addresses, network metadata)',
      'Biometric data (fingerprints, facial recognition, voice samples)',
      'Advertising profiles, tracker identifiers, and analytical cookies',
    ],
  };

  String get sec2Title => switch (lang) {
    'ru' => '2. Данные, хранимые ЛОКАЛЬНО на устройстве',
    'tk' => '2. Enjamyňyzda ýerli SAKLANÝAN maglumatlar',
    'tr' => '2. Cihazınızda YEREL olarak saklanan veriler',
    _ => '2. Data stored LOCALLY on your device',
  };

  String get sec2Body => switch (lang) {
    'ru' =>
    'Вся ваша активность остаётся только на вашем личном устройстве и не передаётся в интернет. К локально хранимым данным относятся:',
    'tk' =>
    'Ähli siziň işjeňligiňiz diňe siziň şahsy enjamyňyzda galýar we internete iberilmeýär. Ýerli (lokal) saklanýan maglumatlara şular degişli:',
    'tr' =>
    'Tüm etkinliğiniz yalnızca kişisel cihazınızda kalır ve internete iletilmez. Yerel olarak saklanan veriler şunları içerir:',
    _ =>
    'All your activity remains only on your personal device and is not transmitted to the internet. Locally stored data includes:',
  };

  List<String> get sec2Bullets => switch (lang) {
    'ru' => [
      'История переводов и избранное — в зашифрованном виде в базе данных Hive',
      'Настройки приложения: тема, язык, размер шрифта, параметры голоса',
      'Статистика обучения: серии дней (streak), XP-баллы, уровни, бейджи',
      'Оффлайн-модели перевода Google ML Kit — только для выбранных вами языков',
      'Данные профиля: имя пользователя, эмодзи-аватар, личный статус',
    ],
    'tk' => [
      'Terjime taryhy we halanlaryňyz — Hive maglumatlar bazasynda şifrlenen görnüşde',
      'Programma sazlamalary: tema, dil, şrift ölçegi, ses parametrleri',
      'Öwreniş statistikasy: yzygiderli günler (streak), XP ballary, derejeler, nyşanlar',
      'Google ML Kit offlaýn terjime modelleri — diňe saýlan dilleriňiz üçin',
      'Profil maglumatlary: ulanyjy ady, emoji awatar, şahsy status',
    ],
    'tr' => [
      'Çeviri geçmişi ve favoriler — Hive veritabanında şifrelenmiş olarak',
      'Uygulama ayarları: tema, dil, yazı tipi boyutu, ses parametreleri',
      'Öğrenme istatistikleri: gün serileri, XP puanları, seviyeler, rozetler',
      'Google ML Kit çevrimdışı çeviri modelleri — yalnızca seçtiğiniz diller için',
      'Profil verileri: kullanıcı adı, emoji avatar, kişisel durum',
    ],
    _ => [
      'Translation history and favorites — encrypted in the Hive database',
      'App settings: theme, language, font size, voice parameters',
      'Learning statistics: day streaks, XP points, levels, badges',
      'Google ML Kit offline translation models — only for the languages you selected',
      'Profile data: username, emoji avatar, personal status',
    ],
  };

  String get sec3Title => switch (lang) {
    'ru' => '3. СИСТЕМНЫЕ разрешения Android',
    'tk' => '3. Android ULGAM RUGSATLARY',
    'tr' => '3. Android SİSTEM izinleri',
    _ => '3. Android SYSTEM permissions',
  };

  String get sec3Body => switch (lang) {
    'ru' =>
    'Приложение запрашивает следующие разрешения, каждое из которых предназначено исключительно для конкретной функции и может быть отозвано в любой момент в системных настройках Android:',
    'tk' =>
    'Programma aşakdaky rugsatlary talap edýär, olaryň her biri diňe anyk funksiýa üçin niýetlenen we islendik wagt Android ulgam sazlamalarynda yzyna alynyp bilner:',
    'tr' =>
    'Uygulama, her biri yalnızca belirli bir işlev için tasarlanmış ve Android sistem ayarlarından istenildiği zaman geri alınabilen aşağıdaki izinleri ister:',
    _ =>
    'The App requests the following permissions, each of which is intended solely for a specific function and can be revoked at any time in Android system settings:',
  };

  List<String> get sec3Bullets => switch (lang) {
    'ru' => [
      'КАМЕРА — перевод текста с фото через OCR (оптическое распознавание); данные обрабатываются только на устройстве',
      'МИКРОФОН — голосовой ввод и режим диалога; звук используется только для локального распознавания',
      'ОТОБРАЖЕНИЕ ПОВЕРХ ОКОН — пузырёк перевода из буфера обмена (overlay bubble)',
      'УВЕДОМЛЕНИЯ — работа фоновой службы мониторинга буфера обмена',
      'ИНТЕРНЕТ — исключительно для подключения к онлайн-сервисам перевода',
    ],
    'tk' => [
      'KAMERA — suratlardaky teksti OCR (optiki nyşan tanamak) arkaly terjime etmek; maglumat diňe enjamda işlenýär',
      'MIKROFON — ses bilen girizmek we dialog režimi; ses diňe ýerli tanama üçin ulanylýar',
      'PENJIRELERIŇ ÜSTÜNDE GÖRKEZMEK — buferden terjime köpügi (overlay bubble)',
      'HABARNAMALAR — arka plandaky bufer gözegçilik hyzmatynyň işlemegi',
      'INTERNET — diňe onlaýn terjime hyzmatlaryna baglanmak üçin',
    ],
    'tr' => [
      'KAMERA — OCR (optik karakter tanıma) aracılığıyla fotoğraflardaki metni çevirme; veriler yalnızca cihazda işlenir',
      'MİKROFON — sesli giriş ve diyalog modu; ses yalnızca yerel tanıma için kullanılır',
      'DİĞER UYGULAMALARIN ÜZERİNDE GÖSTERME — pano çeviri balonu (overlay bubble)',
      'BİLDİRİMLER — arka plan pano izleme hizmetinin çalışması',
      'İNTERNET — yalnızca çevrimiçi çeviri hizmetlerine bağlanmak için',
    ],
    _ => [
      'CAMERA — translating text from photos via OCR (optical character recognition); data is processed only on the device',
      'MICROPHONE — voice input and dialogue mode; audio is used only for local recognition',
      'DISPLAY OVER OTHER APPS — clipboard translation bubble (overlay bubble)',
      'NOTIFICATIONS — operation of the background clipboard monitoring service',
      'INTERNET — solely for connecting to online translation services',
    ],
  };

  String get sec4Title => switch (lang) {
    'ru' => '4. СЕТЕВЫЕ ЗАПРОСЫ и сторонние сервисы',
    'tk' => '4. TOR HAÝYŞLARY we üçünji tarap hyzmatlary',
    'tr' => '4. AĞ istekleri ve üçüncü taraf hizmetleri',
    _ => '4. NETWORK requests and third-party services',
  };

  String get sec4Body => switch (lang) {
    'ru' =>
    'Для онлайн-перевода Приложение подключается к интернету, и переводимый вами текст может отправляться в следующие сторонние сервисы. У каждого сервиса есть собственная политика конфиденциальности:',
    'tk' =>
    'Onlaýn terjime üçin Programma internete birigýär we terjime edýän tekstiňiz aşakdaky üçünji tarap hyzmatlaryna iberilip bilner. Her hyzmat öz gizlinlik syýasatyna eýedir:',
    'tr' =>
    'Çevrimiçi çeviri için Uygulama internete bağlanır ve çevirdiğiniz metin aşağıdaki üçüncü taraf hizmetlere gönderilebilir. Her hizmetin kendi gizlilik politikası vardır:',
    _ =>
    'For online translation, the App connects to the internet, and the text you translate may be sent to the following third-party services. Each service has its own privacy policy:',
  };

  List<String> get sec4Bullets => switch (lang) {
    'ru' => [
      'Google Translate API (translate.googleapis.com) — Политика конфиденциальности Google LLC',
      'Lingva Translate — прокси с открытым исходным кодом, данные не хранятся на сервере',
      'MyMemory Translation API (mymemory.translated.net) — политика Translated Srl',
      'Firebase Crashlytics — только анонимные технические отчёты о сбоях приложения (stack trace, модель устройства, версия ОС)',
    ],
    'tk' => [
      'Google Translate API (translate.googleapis.com) — Google LLC-iň Gizlinlik syýasaty',
      'Lingva Translate — açyk çeşme proksi, serwer tarapynda maglumatlar saklanmaýar',
      'MyMemory Translation API (mymemory.translated.net) — Translated Srl-iň syýasaty',
      'Firebase Crashlytics — diňe programma näsazlyklary barada anonim tehniki hasabatlar (stack trace, enjam modeli, OS wersiýasy)',
    ],
    'tr' => [
      'Google Translate API (translate.googleapis.com) — Google LLC Gizlilik Politikası',
      'Lingva Translate — açık kaynak proxy; veriler sunucuda saklanmaz',
      'MyMemory Translation API (mymemory.translated.net) — Translated Srl politikası',
      'Firebase Crashlytics — yalnızca uygulama çökmeleri hakkında anonim teknik raporlar (stack trace, cihaz modeli, OS sürümü)',
    ],
    _ => [
      'Google Translate API (translate.googleapis.com) — Google LLC Privacy Policy',
      'Lingva Translate — open-source proxy; data is not stored on the server',
      'MyMemory Translation API (mymemory.translated.net) — Translated Srl policy',
      'Firebase Crashlytics — only anonymous technical reports about app crashes (stack trace, device model, OS version)',
    ],
  };

  String get sec5Title => switch (lang) {
    'ru' => '5. ОФФЛАЙН-РЕЖИМ и локальная обработка',
    'tk' => '5. OFLAÝN TERTIBI we ýerli işlemek',
    'tr' => '5. ÇEVRİMDIŞI modu ve yerel işleme',
    _ => '5. OFFLINE mode and local processing',
  };

  String get sec5Body => switch (lang) {
    'ru' =>
    'Оффлайн-перевод через Google ML Kit полностью выполняется на вашем устройстве. Загруженные модели нейронных сетей хранятся в локальной файловой системе и не отправляются ни на какой сервер. Встроенный лингвистический словарь туркменско-русского и туркменско-английского также работает полностью оффлайн и не требует подключения к сети. Это обеспечивает полную доступность сервиса перевода даже при отсутствии интернета и гарантирует максимальный уровень конфиденциальности ваших текстов.',
    'tk' =>
    'Offlaýn terjime Google ML Kit arkaly doly siziň enjamyňyzda işleýär. Ýüklenen neýron tor modelleri ýerli faýl ulgamynda saklanýar we hiç hili serwere iberilmeýär. Gurulan türkmen-rus we türkmen-iňlis lingwistik sözlügi hem doly offlaýn işleýär we tora mätäçlik çekmeýär. Bu, internet ýok wagty hem terjime hyzmatynyň doly elýeter bolmagyny üpjün edýär we siziň tekstleriňiziň gizlinligini iň ýokary derejede goraýar.',
    'tr' =>
    'Google ML Kit aracılığıyla çevrimdışı çeviri tamamen cihazınızda gerçekleştirilir. İndirilen sinir ağı modelleri yerel dosya sisteminde saklanır ve hiçbir sunucuya gönderilmez. Yerleşik Türkmen-Rus ve Türkmen-İngiliz dilbilimsel sözlükler de tamamen çevrimdışı çalışır ve ağ bağlantısı gerektirmez. Bu, internet olmasa bile çeviri hizmetinin tam olarak kullanılabilirliğini sağlar ve metinlerinizin azami gizliliğini garanti eder.',
    _ =>
    'Offline translation via Google ML Kit is performed entirely on your device. Downloaded neural network models are stored in the local file system and are not sent to any server. The built-in Turkmen-Russian and Turkmen-English linguistic dictionaries also work completely offline and do not require a network connection. This ensures full availability of the translation service even without internet access and guarantees the maximum level of confidentiality for your texts.',
  };

  String get sec6Title => switch (lang) {
    'ru' => '6. Конфиденциальность ДЕТЕЙ (соответствие COPPA)',
    'tk' => '6. ÇAGALARYŇ gizlinligi (COPPA laýyklykda)',
    'tr' => '6. ÇOCUKLARIN gizliliği (COPPA uyumu)',
    _ => '6. CHILDREN\'s privacy (COPPA compliance)',
  };

  String get sec6Body => switch (lang) {
    'ru' =>
    'Köpri не собирает намеренно персональные данные от детей младше 13 лет (или возраста, установленного в соответствующей юрисдикции — например, 16 лет в ЕС). Мы не требуем заверенного согласия родителей или опекунов на сбор, использование или раскрытие персональных данных детей. Если родитель или опекун считает, что ребёнок предоставил нам персональные данные, ему следует немедленно связаться с нами — мы удалим данные в течение 24 часов как с наших серверов (если они там есть), так и с локальных устройств.',
    'tk' =>
    'Köpri 13 ýaşdan kiçi çagalardan (ýa-da degişli ýurisdiksiýada kesgitlenen san — mysal üçin, ÝB-de 16 ýaş) bilkastlaýyn şahsy maglumat ýygnamaýar. Biz çagalaryň şahsy maglumatlaryny ýygnamak, ulanmak ýa-da açmak üçin ene-ata ýa-da howandaryň tassyklanylýan razylygyny talap etmeýäris. Eger ene-ata ýa-da howandar çagasynyň bize şahsy maglumat berendigine ynanýan bolsa, dessine bize ýüz tutsun — biz maglumatlary 24 sagadyň dowamynda serwerlermizden (bar bolsa) we ýerli enjamlardan hem pozarys.',
    'tr' =>
    'Köpri, 13 yaşın altındaki çocuklardan (veya ilgili yargı bölgesinde belirlenen yaştan — örneğin AB\'de 16) bilerek kişisel veri toplamaz. Çocukların kişisel verilerini toplamak, kullanmak veya ifşa etmek için ebeveyn veya vasisinin doğrulanabilir onayını istemeyiz. Bir ebeveyn veya vasi, çocuğunun bize kişisel veri sağladığına inanıyorsa, derhal bizimle iletişime geçmelidir — verileri 24 saat içinde hem sunucularımızdan (varsa) hem de yerel cihazlardan sileceğiz.',
    _ =>
    'Köpri does not knowingly collect personal data from children under 13 years of age (or the age established in the relevant jurisdiction — for example, 16 in the EU). We do not require verifiable parental or guardian consent to collect, use, or disclose children\'s personal data. If a parent or guardian believes that their child has provided us with personal data, they should contact us immediately — we will delete the data within 24 hours from both our servers (if present) and local devices.',
  };

  String get sec7Title => switch (lang) {
    'ru' => '7. ИЗМЕНЕНИЯ в Политике и уведомления',
    'tk' => '7. Syýasata ÜÝTGEŞMELER we habarnamalar',
    'tr' => '7. Politikadaki DEĞİŞİKLİKLER ve bildirimler',
    _ => '7. CHANGES to the Policy and notifications',
  };

  String get sec7Body => switch (lang) {
    'ru' =>
    'Мы можем время от времени обновлять настоящую Политику. О существенных изменениях (новые виды сбора данных, изменение сторонних сервисов, изменение правовых оснований) мы уведомим вас заранее: через уведомление в Приложении или на стартовом экране. Продолжая использовать обновлённую Политику на регулярной основе, вы принимаете изменения.',
    'tk' =>
    'Biz şu Syýasaty wagtal-wagtal täzeläp bileris. Mazmunly üýtgeşmeler (maglumat ýygnamagyň täze görnüşleri, üçünji tarap hyzmatlarynyň üýtgemegi, hukuk esaslarynyň üýtgemegi) barada öňünden habar bereris: Programma içindäki habarnama ýa-da açylyş ekrany arkaly. Täzelenen Syýasaty yzygiderli ulanmagy dowam etseňiz, üýtgeşmeleri kabul edýärsiňiz.',
    'tr' =>
    'Bu Politikayı zaman zaman güncelleyebiliriz. Önemli değişiklikler (yeni veri toplama türleri, üçüncü taraf hizmetlerindeki değişiklikler, yasal gerekçelerdeki değişiklikler) hakkında önceden bildirimde bulunacağız: uygulama içi bildirim veya başlangıç ekranı aracılığıyla. Güncellenmiş Politikayı düzenli olarak kullanmaya devam ederek değişiklikleri kabul etmiş olursunuz.',
    _ =>
    'We may update this Policy from time to time. Material changes (new types of data collection, changes to third-party services, changes to legal grounds) will be notified in advance: via an in-app notification or a startup screen. By continuing to use the updated Policy on a regular basis, you accept the changes.',
  };

  String get contactTitle => switch (lang) {
    'ru' => 'Связаться с нами и ваши права',
    'tk' => 'Bize ýüz tutmak we hukuklaryňyz',
    'tr' => 'Bize ulaşın ve haklarınız',
    _ => 'Contact us and your rights',
  };

  String get contactBody => switch (lang) {
    'ru' =>
    'Чтобы запросить доступ к вашим данным, их исправление, экспорт или полное удаление, а также по любым вопросам или предложениям касательно настоящей Политики — напишите нам в Telegram:',
    'tk' =>
    'Maglumatlaryňyza girişi, düzedişleri, göçürilmegini ýa-da doly pozulmagyny haýyş etmek üçin, şeýle hem şu Syýasat boýunça islendik sorag ýa-da teklip üçin Telegram arkaly habarlaşyň:',
    'tr' =>
    'Verilerinize erişim, düzeltme, dışa aktarma veya tamamen silme talebinde bulunmak, ayrıca bu Politika ile ilgili herhangi bir soru veya öneri için Telegram üzerinden bize ulaşın:',
    _ =>
    'To request access to your data, correction, export, or complete deletion, as well as for any questions or suggestions regarding this Policy — contact us on Telegram:',
  };

  String get footer => switch (lang) {
    'ru' => 'Köpri · Последнее обновление: август 2026',
    'tk' => 'Köpri · Soňky täzelenme: awgust 2026',
    'tr' => 'Köpri · Son güncelleme: Ağustos 2026',
    _ => 'Köpri · Last updated: August 2026',
  };
}
