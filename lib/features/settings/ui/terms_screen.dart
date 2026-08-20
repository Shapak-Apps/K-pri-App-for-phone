import 'package:flutter/material.dart';
import 'package:kopri/core/controllers/app_settings_controller.dart';
import 'package:kopri/core/theme/app_colors.dart';
import 'package:kopri/core/theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                      icon: Icons.verified_user_rounded,
                      title: t.sec1Title,
                      body: t.sec1Body,
                      bullets: t.sec1Bullets,
                      index: 0,
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      c: c,
                      icon: Icons.translate_rounded,
                      title: t.sec2Title,
                      body: t.sec2Body,
                      bullets: t.sec2Bullets,
                      index: 1,
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      c: c,
                      icon: Icons.gavel_rounded,
                      title: t.sec3Title,
                      body: t.sec3Body,
                      bullets: t.sec3Bullets,
                      index: 2,
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      c: c,
                      icon: Icons.block_rounded,
                      title: t.sec4Title,
                      body: t.sec4Body,
                      bullets: t.sec4Bullets,
                      index: 3,
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      c: c,
                      icon: Icons.code_rounded,
                      title: t.sec5Title,
                      body: t.sec5Body,
                      bullets: t.sec5Bullets,
                      index: 4,
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      c: c,
                      icon: Icons.balance_rounded,
                      title: t.sec6Title,
                      body: t.sec6Body,
                      index: 5,
                    ),
                    const SizedBox(height: 18),
                    _AcceptanceCard(c: c, t: t),
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
                  colors: [c.accentHi.withValues(alpha: 0.22), c.bgSoft, c.bg],
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
                      c.accentHi.withValues(alpha: 0.30),
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
                      c.accent.withValues(alpha: 0.22),
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
                    colors: [c.accentHi, c.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: c.accentHi.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.description_rounded,
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
          colors: [c.accentHi.withValues(alpha: 0.14), c.surface],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.accentHi.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.accentHi.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.handshake_rounded, color: c.accentHi, size: 22),
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
                        c.accentHi.withValues(alpha: 0.25),
                        c.accent.withValues(alpha: 0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: c.accentHi, size: 18),
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
                          color: c.accentHi,
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

class _AcceptanceCard extends StatelessWidget {
  final AppColors c;
  final _Strings t;
  const _AcceptanceCard({required this.c, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.accent.withValues(alpha: 0.90),
            c.accentHi.withValues(alpha: 0.80),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: c.accentHi.withValues(alpha: 0.25),
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
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                t.acceptanceTitle,
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
            t.acceptanceBody,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 12.5,
              height: 1.5,
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
    'ru' => 'Условия использования',
    'tk' => 'Ulanyş şertleri',
    'tr' => 'Kullanım Koşulları',
    _ => 'Terms of Service',
  };

  String get introTitle => switch (lang) {
    'ru' => 'Юридическое соглашение между вами и нами',
    'tk' => 'Biziň aramyzdaky hukuk şertnamasy',
    'tr' => 'Sizinle aramızdaki yasal anlaşma',
    _ => 'Legal agreement between you and us',
  };

  String get introBody => switch (lang) {
    'ru' =>
    'Загружая, устанавливая или используя мобильное приложение Köpri («Приложение»), вы («Пользователь») полностью и безоговорочно принимаете настоящие условия. Если вы не согласны с каким-либо пунктом настоящих условий, мы просим вас немедленно прекратить использование Приложения и удалить его с вашего устройства. Настоящий документ регулирует правовые отношения между вами и разработчиком Köpri («Мы», «Правообладатель»).',
    'tk' =>
    'Köpri mobil programmasyny («Programma») ýükläp, gurnap ýa-da ulanyp, siz («Ulanyjy») şu şertleri doly we çäklendirilmedik kabul edýärsiňiz. Eger şu şertleriň haýsydyr bir bölegi bilen razy bolmasaňyz, Programmany derrew ulanmagy bes etmegiňizi we enjamyňyzdan aýyrmagyňyzy haýyş edýäris. Şu resminama siziň bilen Köpri döredijisiniň («Biz», «Önümi eýesi») arasyndaky baglanyşykly hukuk gatnaşyklaryny düzgünleşdirýär.',
    'tr' =>
    'Köpri mobil uygulamasını ("Uygulama") indirerek, kurarak veya kullanarak, siz ("Kullanıcı") bu koşulları tam ve şartsız olarak kabul etmiş olursunuz. Bu koşulların herhangi bir bölümüne katılmıyorsanız, Uygulamayı kullanmayı derhal bırakmanızı ve cihazınızdan kaldırmanızı rica ederiz. Bu belge, siz ve Köpri geliştiricisi ("Biz", "Sahip") arasındaki yasal ilişkiyi düzenler.',
    _ =>
    'By downloading, installing, or using the Köpri mobile application (the "App"), you (the "User") fully and unconditionally accept these terms. If you do not agree with any part of these terms, we request that you immediately cease using the App and uninstall it from your device. This document governs the legal relationship between you and the Köpri developer ("We", "the Owner").',
  };

  String get sec1Title => switch (lang) {
    'ru' => '1. Лицензия и интеллектуальная собственность',
    'tk' => '1. Lisenziýa we intellektual eýeçilik',
    'tr' => '1. Lisans ve fikri mülkiyet',
    _ => '1. License and intellectual property',
  };

  String get sec1Body => switch (lang) {
    'ru' =>
    'Мы предоставляем вам личную, неисключительную, непередаваемую, безвозмездную и ограниченную лицензию на использование Приложения исключительно на вашем личном устройстве. Все права интеллектуальной собственности, включая авторское право, товарные знаки, исходный код, дизайн, логотипы и алгоритмы перевода, остаются нашей собственностью. Без нашего прямого письменного разрешения категорически запрещается:',
    'tk' =>
    'Biz size şahsy, aýratyn däl, gaýtadan berlip bilinmeýän, mugt we çäkli lisenziýa berýäris — diňe Programmany öz şahsy enjamyňyzda ulanmak üçin. Ähli intellektual eýeçilik hukuklary, şol sanda awtorlyk hukugy, söwda belligi, Programma kody, dizaýn, nyşanlar we terjime algoritmleri — biziň eýeçiligimizde galýar. Biziň açyk ýazmaça rugsadymyzsyz şu hereketler düýbünden gadagan:',
    'tr' =>
    'Size, Uygulamayı yalnızca kişisel cihazınızda kullanmak üzere kişisel, münhasır olmayan, devredilemez, ücretsiz ve sınırlı bir lisans veriyoruz. Telif hakkı, ticari markalar, kaynak kodu, tasarım, logolar ve çeviri algoritmaları dahil tüm fikri mülkiyet hakları bizim mülkiyetimizde kalır. Açık yazılı iznimiz olmadan aşağıdaki işlemler kesinlikle yasaktır:',
    _ =>
    'We grant you a personal, non-exclusive, non-transferable, free and limited license to use the App solely on your personal device. All intellectual property rights, including copyright, trademarks, source code, design, logos, and translation algorithms, remain our property. Without our express written permission, the following actions are strictly prohibited:',
  };

  List<String> get sec1Bullets => switch (lang) {
    'ru' => [
      'Осуществлять обратную разработку, декомпиляцию или дизассемблирование бинарного кода Приложения',
      'Предпринимать попытки извлечения исходного кода, структуры или алгоритмов Приложения',
      'Создавать или распространять модифицированные или производные версии Приложения',
      'Сдавать Приложение в аренду, продавать или сублицензировать в коммерческих целях',
    ],
    'tk' => [
      'Programmanyň binar koduny gaýtadan inženerçilik etmek, dekompilýasiýa ýa-da disassemblirlemek',
      'Programmanyň çeşme koduny, gurluşyny ýa-da algoritmlerini çykarmaga synanyşmak',
      'Programmanyň üýtgedilen ýa-da gelip çykan nusgalaryny döretmek ýa-da ýaýratmak',
      'Programmany täjirçilik maksatly kärendesine bermek, satmak ýa-da gaýtadan lisenziýalamak',
    ],
    'tr' => [
      'Uygulamanın ikili kodunu tersine mühendislik yapmak, derlemesini çözmek veya parçalarına ayırmak',
      'Uygulamanın kaynak kodunu, yapısını veya algoritmalarını çıkarmaya çalışmak',
      'Uygulamanın değiştirilmiş veya türetilmiş sürümlerini oluşturmak veya dağıtmak',
      'Uygulamayı ticari amaçlarla kiralamak, satmak veya alt lisanslamak',
    ],
    _ => [
      'Reverse engineering, decompiling, or disassembling the App\'s binary code',
      'Attempting to extract the App\'s source code, structure, or algorithms',
      'Creating or distributing modified or derivative versions of the App',
      'Renting, selling, or sublicensing the App for commercial purposes',
    ],
  };

  String get sec2Title => switch (lang) {
    'ru' => '2. Качество перевода и отсутствие гарантий',
    'tk' => '2. Terjime hili we takyklyk kepilligi ýok',
    'tr' => '2. Çeviri kalitesi ve garanti verilmez',
    _ => '2. Translation quality and no warranties',
  };

  String get sec2Body => switch (lang) {
    'ru' =>
    'Переводы генерируются автоматически с помощью моделей машинного обучения (Google ML Kit, Google Translate API, MyMemory Translation Memory), нейронных сетей и встроенного лингвистического словаря. Машинный перевод по своей природе не может гарантировать абсолютную точность — он может содержать семантические, грамматические, прагматические и культурные ошибки. Мы предупреждаем:',
    'tk' =>
    'Terjimeler awtomatiki maşyn öwreniş modelleri (Google ML Kit, Google Translate API, MyMemory Translation Memory), neýron torlary we gurulan lingwistik sözlük arkaly döredilýär. Maşyn terjimesi tebigaty boýunça doly takyklygy kepillendirip bilmeýär — ol semantik, grammatik, pragmatik we medeniýet ýalňyşlyklary öz içine alyp biler. Biz aşakdakylary duýdurýarys:',
    'tr' =>
    'Çeviriler, makine öğrenimi modelleri (Google ML Kit, Google Translate API, MyMemory Translation Memory), sinir ağları ve yerleşik dilbilimsel sözlük kullanılarak otomatik olarak oluşturulur. Makine çevirisi doğası gereği mutlak doğruluğu garanti edemez — anlamsal, dilbilgisel, pragmatik ve kültürel hatalar içerebilir. Uyarıyoruz:',
    _ =>
    'Translations are automatically generated using machine learning models (Google ML Kit, Google Translate API, MyMemory Translation Memory), neural networks, and a built-in linguistic dictionary. Machine translation by its nature cannot guarantee absolute accuracy — it may contain semantic, grammatical, pragmatic, and cultural errors. We warn:',
  };

  List<String> get sec2Bullets => switch (lang) {
    'ru' => [
      'Не полагайтесь на переводы Köpri для медицинских диагнозов, дозировок лекарств или клинических рекомендаций',
      'Не используйте для юридических договоров, судебных документов или нормативных требований',
      'Не используйте для финансовых отчётов, банковских операций или налоговых деклараций',
      'Для критически важных переводов всегда проводите проверку квалифицированным переводчиком',
    ],
    'tk' => [
      'Lukmançylyk diagnozlary, derman dozalary ýa-da kliniki maslahatlar üçin Köpri terjimelerine daýanmaň',
      'Hukuk şertnamalary, kazyýet resminamalary ýa-da kadalaşdyryjy talaplar üçin ulanmaň',
      'Maliýe hasabatlary, bank amallary ýa-da salgyt beýannamalary üçin ulanmaň',
      'Möhüm terjimeler üçin hemişe ygtyýarly hünärmen terjimeçi tarapyndan barladyň',
    ],
    'tr' => [
      'Köpri çevirilerine tıbbi teşhisler, ilaç dozajları veya klinik tavsiyeler için güvenmeyin',
      'Yasal sözleşmeler, mahkeme belgeleri veya düzenleyici gereklilikler için kullanmayın',
      'Mali tablolar, bankacılık işlemleri veya vergi beyannameleri için kullanmayın',
      'Kritik çeviriler için her zaman nitelikli bir insan çevirmen tarafından doğrulatın',
    ],
    _ => [
      'Do not rely on Köpri translations for medical diagnoses, drug dosages, or clinical advice',
      'Do not use for legal contracts, court documents, or regulatory requirements',
      'Do not use for financial reports, banking operations, or tax declarations',
      'For critical translations, always have them verified by a qualified human translator',
    ],
  };

  String get sec3Title => switch (lang) {
    'ru' => '3. Ограничение ответственности',
    'tk' => '3. Jogapkärçiligiň çäklendirilmegi',
    'tr' => '3. Sorumluluk sınırlaması',
    _ => '3. Limitation of liability',
  };

  String get sec3Body => switch (lang) {
    'ru' =>
    'Приложение предоставляется на принципах «КАК ЕСТЬ» (AS IS) и «ПО МЕРЕ ДОСТУПНОСТИ» (AS AVAILABLE) без каких-либо прямых или косвенных гарантий. В максимальной степени, допускаемой законом, Мы не несём ответственности за:',
    'tk' =>
    'Programma «BAR BOLŞY ÝALY» (AS IS) we «ELÝETER BOLŞY ÝALY» (AS AVAILABLE) ýörelgeleri esasynda, hiç hili göni ýa-da gytaklaýyn kepilliksiz berilýär. Kanunyň iň ýokary rugsat berýän çäginde Biz aşakdakylar üçin jogapkärçilik çekmeýäris:',
    'tr' =>
    'Uygulama "OLDUĞU GİBİ" (AS IS) ve "MEVCUT OLDUĞU GİBİ" (AS AVAILABLE) esasına göre, herhangi bir açık veya zımni garanti olmaksızın sunulur. Yasaların izin verdiği azami ölçüde, aşağıdakilerden sorumlu değiliz:',
    _ =>
    'The App is provided on an "AS IS" and "AS AVAILABLE" basis without any express or implied warranties. To the maximum extent permitted by law, We are not liable for:',
  };

  List<String> get sec3Bullets => switch (lang) {
    'ru' => [
      'Прямой, косвенный, случайный, особый или последующий ущерб (включая потерю данных)',
      'Упущенную выгоду, приостановку деятельности или коммерческий ущерб',
      'Сбои устройства, быстрый разряд батареи или чрезмерное использование системных ресурсов',
      'Недоступность или ошибки сторонних сервисов (Google, MyMemory)',
    ],
    'tk' => [
      'Göni, gytaklaýyn, tötänleýin, aýratyn ýa-da netijeli zyýan (şol sanda maglumat ýitgisi)',
      'Elden giderilen girdeji, iş togtamasy ýa-da täjirçilik zyýany',
      'Enjamyň näsazlygy, batareýanyň çalt gutarmasy ýa-da ulgam resurslarynyň aşa ulanylmagy',
      'Üçünji tarap hyzmatlarynyň (Google, MyMemory) elýeterliliginiň kesilmegi ýa-da ýalňyşlygy',
    ],
    'tr' => [
      'Doğrudan, dolaylı, arızi, özel veya sonuçsal zararlar (veri kaybı dahil)',
      'Kazanç kaybı, iş kesintisi veya ticari zarar',
      'Cihaz arızaları, hızlı pil bitmesi veya aşırı sistem kaynağı kullanımı',
      'Üçüncü taraf hizmetlerinin (Google, MyMemory) kullanılamazlığı veya hataları',
    ],
    _ => [
      'Direct, indirect, incidental, special, or consequential damages (including data loss)',
      'Lost profits, business interruption, or commercial damage',
      'Device malfunctions, rapid battery drain, or excessive system resource usage',
      'Unavailability or errors of third-party services (Google, MyMemory)',
    ],
  };

  String get sec4Title => switch (lang) {
    'ru' => '4. Запрещённое использование и обязанности Пользователя',
    'tk' => '4. Gadagan ulanma we Ulanyjynyň borçlary',
    'tr' => '4. Yasaklı kullanım ve Kullanıcı yükümlülükleri',
    _ => '4. Prohibited use and User obligations',
  };

  String get sec4Body => switch (lang) {
    'ru' =>
    'Используя Приложение, вы обязуетесь воздерживаться от следующих действий:',
    'tk' =>
    'Programmany ulanyp, siz aşakdaky hereketlerden saklanmaga borçlanýarsyňyz:',
    'tr' =>
    'Uygulamayı kullanarak aşağıdaki faaliyetlerden kaçınmayı taahhüt edersiniz:',
    _ =>
    'By using the App, you undertake to refrain from the following activities:',
  };

  List<String> get sec4Bullets => switch (lang) {
    'ru' => [
      'Перевод преступного, оскорбительного, клеветнического, порнографического или насильственного контента',
      'Перевод и распространение материалов, защищённых авторским правом, без разрешения',
      'Использование для спама, фишинга, вредоносного ПО или активности ботнета',
      'Действия против государственной безопасности, военной тайны или неприкосновенности частной жизни',
      'Чрезмерная нагрузка на Приложение через автоматизированные скрипты, боты или веб-скрейпинг',
    ],
    'tk' => [
      'Jenaýatçylykly, kemsidiji, adamyň abraýyna degýän, jynsçylykly ýa-da zorlukly mazmuny terjime etmek',
      'Awtorlyk hukugy bilen goralýan materiallary rugsatsyz terjime edip, ýaýratmak',
      'Spam, phishing, zyýanly programma ýa-da botnet işjeňligi üçin ulanmak',
      'Döwlet howpsuzlygyna, harby syrlara ýa-da şahsy durmuşyň elde degirmesizligine garşy hereketler',
      'Awtomatlaşdyrylan skriptler, botlar ýa-da web-skreýping arkaly Programmany aşa ýüklemek',
    ],
    'tr' => [
      'Suç içeren, saldırgan, iftira niteliğinde, pornografik veya şiddet içeren içeriklerin çevirisi',
      'İzin olmaksızın telif hakkıyla korunan materyallerin çevrilmesi ve dağıtılması',
      'Spam, kimlik avı, kötü amaçlı yazılım veya botnet faaliyeti için kullanma',
      'Ulusal güvenliğe, askeri sırlara veya mahremiyete karşı faaliyetler',
      'Otomatik komut dosyaları, botlar veya web kazıma yoluyla Uygulamayı aşırı yükleme',
    ],
    _ => [
      'Translating criminal, offensive, defamatory, pornographic, or violent content',
      'Translating and distributing copyrighted materials without permission',
      'Using the App for spam, phishing, malware, or botnet activity',
      'Activities against national security, military secrets, or privacy',
      'Overloading the App through automated scripts, bots, or web scraping',
    ],
  };

  String get sec5Title => switch (lang) {
    'ru' => '5. Сторонние компоненты и открытый исходный код',
    'tk' => '5. Üçünji tarap komponentleri we açyk çeşme',
    'tr' => '5. Üçüncü taraf bileşenler ve açık kaynak',
    _ => '5. Third-party components and open source',
  };

  String get sec5Body => switch (lang) {
    'ru' =>
    'Köpri использует следующие сторонние библиотеки и компоненты с открытым исходным кодом, каждый из которых предоставляется на условиях собственной лицензии:',
    'tk' =>
    'Köpri aşakdaky üçünji tarap kitapханalary we açyk çeşme komponentleri ulanýar, olaryň her biri öz lisenziýa şertleri bilen berilýär:',
    'tr' =>
    'Köpri, her biri kendi lisans koşulları altında sağlanan aşağıdaki üçüncü taraf kütüphaneleri ve açık kaynak bileşenleri kullanır:',
    _ =>
    'Köpri uses the following third-party libraries and open-source components, each provided under its own license terms:',
  };

  List<String> get sec5Bullets => switch (lang) {
    'ru' => [
      'Фреймворк Flutter — лицензия BSD 3-Clause (Google LLC)',
      'Google ML Kit — в соответствии с условиями обслуживания Google LLC',
      'Hive, flutter_tts, shared_preferences и другие — соответствующие лицензии MIT, Apache 2.0 или BSD',
      'Полный список и тексты лицензий доступны в разделе «Лицензии» в настройках Приложения',
    ],
    'tk' => [
      'Flutter framework — BSD 3-Clause Lisenziýasy (Google LLC)',
      'Google ML Kit — Google LLC-iň hyzmat şertlerine laýyklykda',
      'Hive, flutter_tts, shared_preferences we beýlekiler — degişli MIT, Apache 2.0 ýa-da BSD lisenziýalary',
      'Doly sanaw we lisenziýa tekstleri Programma sazlamalaryndaky «Rugsatnamalar» bölüminde elýeter',
    ],
    'tr' => [
      'Flutter framework — BSD 3-Clause Lisansı (Google LLC)',
      'Google ML Kit — Google LLC\'nin hizmet koşullarına uygun olarak',
      'Hive, flutter_tts, shared_preferences ve diğerleri — ilgili MIT, Apache 2.0 veya BSD lisansları',
      'Tam liste ve lisans metinleri, Uygulama ayarlarının Lisanslar bölümünde mevcuttur',
    ],
    _ => [
      'Flutter framework — BSD 3-Clause License (Google LLC)',
      'Google ML Kit — in accordance with Google LLC\'s terms of service',
      'Hive, flutter_tts, shared_preferences, and others — respective MIT, Apache 2.0, or BSD licenses',
      'The full list and license texts are available in the Licenses section of the App settings',
    ],
  };

  String get sec6Title => switch (lang) {
    'ru' => '6. Применимое право и разрешение споров',
    'tk' => '6. Ulanylýan hukuk we dawalary çözmek',
    'tr' => '6. Geçerli hukuk ve uyuşmazlık çözümü',
    _ => '6. Governing law and dispute resolution',
  };

  String get sec6Body => switch (lang) {
    'ru' =>
    'Настоящие Условия толкуются и регулируются в соответствии с законодательством страны вашего проживания. Любой спор или разногласие сначала предпринимаются попытки решить путём переговоров в разумные сроки. Если переговоры не приносят результата, спор рассматривается в компетентном суде соответствующей юрисдикции. Если какое-либо положение настоящих Условий будет признано противоречащим закону, остальные положения сохраняют полную силу.',
    'tk' =>
    'Şu Şertler siziň ýaşaýan ýurduňyzyň kanunlaryna laýyklykda düşündirilýär we düzgünleşdirilýär. Islendik dawa ýa-da düşünişmezlik ilki bilen gepleşikler arkaly, ýazmaça habarlaşma arkaly, makul möhletlerde çözülmäge synanyşylýar. Eger gepleşikler netije bermese, dawa degişli ýurisdiksiýanyň ygtyýarly kazyýetinde serediler. Şu Şertleriň haýsydyr bir maddasy kanuna garşy gelýän diýlip ykrar edilse, beýleki maddalar doly güýjünde galýar.',
    'tr' =>
    'Bu Koşullar, ikamet ettiğiniz ülkenin yasalarına göre yorumlanır ve yönetilir. Herhangi bir anlaşmazlık veya uyuşmazlık ilk olarak makul bir süre içinde müzakereler yoluyla çözülmeye çalışılır. Müzakereler başarısız olursa, uyuşmazlık yetkili mahkemede görülür. Bu Koşulların herhangi bir hükmü yasaya aykırı bulunursa, kalan hükümler tam yürürlükte kalır.',
    _ =>
    'These Terms are interpreted and governed in accordance with the laws of your country of residence. Any dispute or disagreement shall first be attempted to be resolved through negotiation within a reasonable timeframe. If negotiations fail, the dispute shall be heard in a court of competent jurisdiction. If any provision of these Terms is found to be contrary to law, the remaining provisions shall remain in full force and effect.',
  };

  String get acceptanceTitle => switch (lang) {
    'ru' => 'Ваше согласие',
    'tk' => 'Siziň razylygyňyz',
    'tr' => 'Onayınız',
    _ => 'Your acceptance',
  };

  String get acceptanceBody => switch (lang) {
    'ru' =>
    'Используя Köpri, вы подтверждаете, что полностью прочитали, поняли и согласны соблюдать настоящие Условия использования и Политику конфиденциальности.',
    'tk' =>
    'Köpri ulanyp, siz şu Ulanyş şertlerini we Gizlinlik syýasatyny doly okandygyňyzy, düşünýändigiňizi we olary ýerine ýetirmäge razydygyňyzy tassyklaýarsyňyz.',
    'tr' =>
    'Köpri\'yi kullanarak, bu Kullanım Koşullarını ve Gizlilik Politikasını tamamen okuduğunuzu, anladığınızı ve bunlara uymayı kabul ettiğinizi onaylarsınız.',
    _ =>
    'By using Köpri, you confirm that you have fully read, understood, and agreed to comply with these Terms of Service and the Privacy Policy.',
  };

  String get footer => switch (lang) {
    'ru' => 'Köpri · Дата вступления в силу: август 2026',
    'tk' => 'Köpri · Güýje giren senesi: awgust 2026',
    'tr' => 'Köpri · Yürürlük tarihi: Ağustos 2026',
    _ => 'Köpri · Effective date: August 2026',
  };
}