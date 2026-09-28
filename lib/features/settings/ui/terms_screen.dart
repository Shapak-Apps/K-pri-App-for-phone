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
                      icon: Icons.rocket_launch_rounded,
                      title: t.sec5Title,
                      body: t.sec5Body,
                      bullets: t.sec5Bullets,
                      index: 4,
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
    _ => 'Terms of Use',
  };

  String get introTitle => switch (lang) {
    'ru' => 'Простое соглашение',
    'tk' => 'Ýönekeý ylalaşyk',
    'tr' => 'Basit anlaşma',
    _ => 'Simple agreement',
  };

  String get introBody => switch (lang) {
    'ru' =>
      'Используя Köpri, вы соглашаетесь с несколькими простыми правилами. Если что-то не нравится — просто удалите приложение. Вот что важно знать:',
    'tk' =>
      'Köpri ulanyp, siz birnäçe ýönekeý düzgünlere razylyk berýärsiňiz. Eger bir zat halamasaňyz — programmany aýyryň. Ine, nämäni bilmeli:',
    'tr' =>
      'Köpri\'yi kullanarak birkaç basit kuralı kabul etmiş olursunuz. Bir şey hoşunuza gitmezse — uygulamayı silin. İşte bilmeniz gerekenler:',
    _ =>
      'By using Köpri, you agree to a few simple rules. If you don\'t like something — just uninstall the app. Here\'s what you need to know:',
  };

  String get sec1Title => switch (lang) {
    'ru' => '1. Приложение ваше, код наш',
    'tk' => '1. Programma siziňki, kod biziňki',
    'tr' => '1. Uygulama sizin, kod bizim',
    _ => '1. App is yours, code is ours',
  };

  String get sec1Body => switch (lang) {
    'ru' =>
      'Вы можете пользоваться Köpri бесплатно на своём телефоне. Но нельзя:',
    'tk' => 'Köpri-ni telefonyňyzda mugt ulanyp bilersiňiz. Ýöne bolmaýar:',
    'tr' => 'Köpri\'yi telefonunuzda ücretsiz kullanabilirsiniz. Ama yapılmaz:',
    _ => 'You can use Köpri for free on your phone. But you can\'t:',
  };

  List<String> get sec1Bullets => switch (lang) {
    'ru' => [
      'Копировать или перепродавать приложение',
      'Взламывать код или вытаскивать алгоритмы',
      'Делать модифицированные версии и распространять их',
      'Использовать для коммерции без разрешения',
    ],
    'tk' => [
      'Programmany göçürip almak ýa-da satmak',
      'Kody döwmek ýa-da algoritmleri çykarmak',
      'Üýtgedilen wersiýalary ýasamak we ýaýratmak',
      'Rugsatsyz täjirçilik üçin ulanmak',
    ],
    'tr' => [
      'Uygulamayı kopyalamak veya satmak',
      'Kodu kırmak veya algoritmaları çıkarmak',
      'Değiştirilmiş sürümler yapmak ve dağıtmak',
      'İzinsiz ticaret için kullanmak',
    ],
    _ => [
      'Copy or resell the app',
      'Hack the code or extract algorithms',
      'Make modified versions and distribute them',
      'Use for commerce without permission',
    ],
  };

  String get sec2Title => switch (lang) {
    'ru' => '2. Перевод может ошибаться',
    'tk' => '2. Terjime ýalňyşyp biler',
    'tr' => '2. Çeviri hata yapabilir',
    _ => '2. Translation can make mistakes',
  };

  String get sec2Body => switch (lang) {
    'ru' =>
      'Köpri использует искусственный интеллект, который иногда ошибается. Поэтому:',
    'tk' => 'Köpri emeli aňy ulanýar, ol käwagt ýalňyşýar. Şonuň üçin:',
    'tr' => 'Köpri yapay zeka kullanır, bazen hata yapar. Bu yüzden:',
    _ =>
      'Köpri uses artificial intelligence, which sometimes makes mistakes. So:',
  };

  List<String> get sec2Bullets => switch (lang) {
    'ru' => [
      'Не используйте для медицинских решений',
      'Не используйте для юридических документов',
      'Не используйте для финансовых операций',
      'Для важных вещей — проверьте у живого переводчика',
    ],
    'tk' => [
      'Lukmançylyk kararlar üçin ulanmaň',
      'Hukuk resminamalary üçin ulanmaň',
      'Maliýe amallary üçin ulanmaň',
      'Möhüm zatlar üçin — hakyky terjimeçiden barladyň',
    ],
    'tr' => [
      'Tıbbi kararlar için kullanmayın',
      'Yasal belgeler için kullanmayın',
      'Finansal işlemler için kullanmayın',
      'Önemli şeyler için — gerçek çevirmene kontrol ettirin',
    ],
    _ => [
      'Don\'t use for medical decisions',
      'Don\'t use for legal documents',
      'Don\'t use for financial transactions',
      'For important things — check with a human translator',
    ],
  };

  String get sec3Title => switch (lang) {
    'ru' => '3. Мы не виноваты',
    'tk' => '3. Biz günäkär däl',
    'tr' => '3. Biz sorumlu değiliz',
    _ => '3. We\'re not liable',
  };

  String get sec3Body => switch (lang) {
    'ru' =>
      'Приложение даётся «как есть». Если что-то пойдёт не так, мы не отвечаем за:',
    'tk' =>
      'Programma «bar bolşy ýaly» berilýär. Eger bir zat ters gitse, biz şular üçin jogap bermeýäris:',
    'tr' =>
      'Uygulama "olduğu gibi" verilir. Bir şey ters giderse, şunlardan sorumlu değiliz:',
    _ =>
      'The app is provided "as is". If something goes wrong, we\'re not responsible for:',
  };

  List<String> get sec3Bullets => switch (lang) {
    'ru' => [
      'Потерю данных или убытки',
      'Проблемы с телефоном или батареей',
      'Ошибки сторонних сервисов (Google, MyMemory)',
      'Любой ущерб от использования приложения',
    ],
    'tk' => [
      'Maglumat ýitgisini ýa-da zyýanlary',
      'Telefon ýa-da batareýa meselelerini',
      'Üçünji tarap hyzmatlarynyň ýalňyşlyklaryny (Google, MyMemory)',
      'Programmany ulanmakdan gelýän islendik zyýan',
    ],
    'tr' => [
      'Veri kaybı veya zararlar',
      'Telefon veya pil sorunları',
      'Üçüncü taraf hizmetlerinin hataları (Google, MyMemory)',
      'Uygulamayı kullanmaktan kaynaklanan herhangi bir zarar',
    ],
    _ => [
      'Data loss or damages',
      'Phone or battery issues',
      'Errors from third-party services (Google, MyMemory)',
      'Any harm from using the app',
    ],
  };

  String get sec4Title => switch (lang) {
    'ru' => '4. Не делайте так',
    'tk' => '4. Beýle etmäň',
    'tr' => '4. Böyle yapmayın',
    _ => '4. Don\'t do this',
  };

  String get sec4Body => switch (lang) {
    'ru' => 'Пожалуйста, не используйте Köpri для:',
    'tk' => 'Haýyş, Köpri-ni şular üçin ulanmaň:',
    'tr' => 'Lütfen Köpri\'yi şunlar için kullanmayın:',
    _ => 'Please don\'t use Köpri for:',
  };

  List<String> get sec4Bullets => switch (lang) {
    'ru' => [
      'Перевода оскорбительного или незаконного контента',
      'Спама, фишинга или вредоносных программ',
      'Нарушения чужих авторских прав',
      'Автоматической массовой загрузки (боты, скрипты)',
    ],
    'tk' => [
      'Kemsidiji ýa-da bikanun mazmuny terjime etmek',
      'Spam, phishing ýa-da zyýanly programmalar',
      'Başgalaryň awtorlyk hukuklaryny bozmak',
      'Awtomatiki köpçülikleýin ýükleme (botlar, skriptler)',
    ],
    'tr' => [
      'Saldırgan veya yasadışı içerik çevirmek',
      'Spam, kimlik avı veya kötü amaçlı yazılımlar',
      'Başkalarının telif haklarını ihlal etmek',
      'Otomatik toplu indirme (botlar, komut dosyaları)',
    ],
    _ => [
      'Translating offensive or illegal content',
      'Spam, phishing, or malware',
      'Violating others\' copyrights',
      'Automated mass downloading (bots, scripts)',
    ],
  };

  String get sec5Title => switch (lang) {
    'ru' => '5. Что впереди',
    'tk' => '5. Öňde näme bar',
    'tr' => '5. Sırada ne var',
    _ => '5. What\'s coming',
  };

  String get sec5Body => switch (lang) {
    'ru' => 'Köpri постоянно улучшается. Скоро появятся:',
    'tk' => 'Köpri yzygiderli gowulaşýar. Ýakyn wagtda peýda bolar:',
    'tr' => 'Köpri sürekli gelişiyor. Yakında gelecek:',
    _ => 'Köpri is constantly improving. Coming soon:',
  };

  List<String> get sec5Bullets => switch (lang) {
    'ru' => [
      'Голосовой ввод (v2.0.0) — перевод через микрофон',
      'Камера (v2.0.0) — перевод текста с фото',
      'Все новые функции будут такими же безопасными',
      'Мы расскажем о них через уведомления',
    ],
    'tk' => [
      'Ses bilen girizmek (v2.0.0) — mikrofon arkaly terjime',
      'Kamera (v2.0.0) — suratlardaky teksti terjime',
      'Ähli täze aýratynlyklar şeýle howpsuz bolar',
      'Habarnamalar arkaly habar bereris',
    ],
    'tr' => [
      'Sesli giriş (v2.0.0) — mikrofonla çeviri',
      'Kamera (v2.0.0) — fotoğraflardaki metni çeviri',
      'Tüm yeni özellikler aynı derecede güvenli olacak',
      'Bildirimlerle haber vereceğiz',
    ],
    _ => [
      'Voice input (v2.0.0) — translate via microphone',
      'Camera (v2.0.0) — translate text from photos',
      'All new features will be just as safe',
      'We\'ll let you know through notifications',
    ],
  };

  String get acceptanceTitle => switch (lang) {
    'ru' => 'Всё понятно?',
    'tk' => 'Hemme zat düşnüklimi?',
    'tr' => 'Her şey anlaşıldı mı?',
    _ => 'All clear?',
  };

  String get acceptanceBody => switch (lang) {
    'ru' =>
      'Продолжая пользоваться Köpri, вы соглашаетесь с этими простыми правилами и Политикой конфиденциальности. Если есть вопросы — напишите нам на shapak.apps@gmail.com',
    'tk' =>
      'Köpri ulanmagy dowam etseňiz, şu ýönekeý düzgünlere we Gizlinlik syýasatyna razylyk berýärsiňiz. Soraglar bar bolsa — shapak.apps@gmail.com ýazyň',
    'tr' =>
      'Köpri\'yi kullanmaya devam ederek bu basit kuralları ve Gizlilik Politikasını kabul etmiş olursunuz. Sorularınız varsa — shapak.apps@gmail.com adresine yazın',
    _ =>
      'By continuing to use Köpri, you agree to these simple rules and the Privacy Policy. If you have questions — write to us at shapak.apps@gmail.com',
  };

  String get footer => switch (lang) {
    'ru' => 'Köpri · Обновлено: сентябрь 2026',
    'tk' => 'Köpri · Täzelendi: sentýabr 2026',
    'tr' => 'Köpri · Güncellendi: Eylül 2026',
    _ => 'Köpri · Updated: September 2026',
  };
}
