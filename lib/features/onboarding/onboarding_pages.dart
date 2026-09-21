import 'widgets/teacher_avatar.dart';

/// One onboarding / "how it works" slide.
///
/// NAMING: Köpri = the bridge (the app). The character speaking here is a
/// SEPARATE persona — "Köpri Teacher / Mollum / Ogretman" — the guide who
/// lives on the bridge. Not "the bridge is a teacher", not "just a bridge".
///
/// Texts are deliberately simple — no programming words, for regular people.
class OnboardingPageData {
  const OnboardingPageData({
    required this.pose,
    required this.title,
    required this.body,
  });

  final TeacherPose pose;
  final Map<String, String> title;
  final Map<String, String> body;

  String titleFor(String lang) => title[lang] ?? title['en']!;
  String bodyFor(String lang) => body[lang] ?? body['en']!;
}

const List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    pose: TeacherPose.wave,
    title: {
      'ru': 'Привет! Я Учитель!',
      'tk': 'Salam! Men Mollum!',
      'tr': 'Merhaba! Ben Ogretman!',
      'en': 'Hi! I\'m Teacher!',
    },
    body: {
      'ru':
          'Köpri — это мост между языками. А я — твой наставник на этом мосту. За минуту покажу, как тут всё устроено — это просто!',
      'tk':
          'Köpri — dilleriň arasyndaky köpri. Men bolsa şol köpride seniň mugallymyň. Bir minutda hemme zadyň nähili işleýändigini görkezerin — aňsat!',
      'tr':
          'Köpri — diller arasındaki köprü. Ben ise o köprüde senin rehberinim. Bir dakikada her şeyin nasıl çalıştığını göstereceğim — çok kolay!',
      'en':
          'Köpri is a bridge between languages. And I\'m your guide on that bridge. In a minute I\'ll show you how everything works — it\'s simple!',
    },
  ),
  OnboardingPageData(
    pose: TeacherPose.point,
    title: {
      'ru': 'Перевод за секунду',
      'tk': 'Bir sekuntda terjime',
      'tr': 'Bir saniyede çeviri',
      'en': 'Translate in a second',
    },
    body: {
      'ru':
          'Напиши или скажи фразу — мост мгновенно переведёт. А когда выучу язык, смогу работать даже без интернета.',
      'tk':
          'Ýaz ýa-da aýt — köpri şol bada terjime eder. Dili öwrenenimden soň internet bolmasa-da işläp bilerin.',
      'tr':
          'Yaz veya söyle — köprü anında çevirir. Dili öğrendikten sonra internet olmadan da çalışabilirim.',
      'en':
          'Type or say a phrase — the bridge translates instantly. Once I learn a language, I work even without internet.',
    },
  ),
  OnboardingPageData(
    pose: TeacherPose.explain,
    title: {
      'ru': 'Баллы за каждую букву',
      'tk': 'Her harp üçin bal',
      'tr': 'Her harf için puan',
      'en': 'Points for every letter',
    },
    body: {
      'ru':
          'За каждый перевод ты получаешь баллы: чем длиннее фраза, тем больше. Баллы растут в уровни — как в игре, только по-настоящему.',
      'tk':
          'Her terjime üçin bal alýarsyň: sözlem näçe uzyn bolsa, şonça köp bal. Ballar derejelere öwrülýär — oýundaky ýaly, diňe hakyky.',
      'tr':
          'Her çeviri için puan alırsın: cümle ne kadar uzunsa, o kadar puan. Puanlar seviyelere dönüşür — oyun gibi, ama gerçek.',
      'en':
          'Every translation earns points: the longer the phrase, the more points. Points grow into levels — like a game, but real.',
    },
  ),
  OnboardingPageData(
    pose: TeacherPose.explain,
    title: {
      'ru': 'Задание на каждый день',
      'tk': 'Her gün üçin tabşyryk',
      'tr': 'Her güne bir görev',
      'en': 'A task for every day',
    },
    body: {
      'ru':
          'Каждый день я даю небольшое задание: например, 10 переводов. Выполнить — завтра задание чуть вырастет и получишь бонус. Не выполнить — задание уменьшится, а огонёк погаснет.',
      'tk':
          'Her gün men kiçi tabşyryk berýärin: meselem, 10 terjime. Ýerine ýetirseň — ertirki tabşyryk biraz öser we bonus alarsyň. Ýetirmeseň — tabşyryk kiçeler, otjik öçer.',
      'tr':
          'Sana her gün küçük bir görev veririm: mesela 10 çeviri. Bitirirsen — yarınki görev biraz büyür ve bonus alırsın. Bitiremezsen — görev küçülür, ateş söner.',
      'en':
          'Every day I give a small task: like 10 translations. Complete it — tomorrow\'s task grows a bit and you get a bonus. Miss it — the task shrinks and the fire goes out.',
    },
  ),
  OnboardingPageData(
    pose: TeacherPose.fire,
    title: {
      'ru': 'Огонёк серии',
      'tk': 'Seriýa otjigy',
      'tr': 'Seri ateşi',
      'en': 'The streak fire',
    },
    body: {
      'ru':
          'Переводи хотя бы раз в день — и твой огонёк горит. Пропустишь день или не выполнишь задание — огонёк гаснет. Длинные серии — это уважение!',
      'tk':
          'Günde azyndan bir gezek terjime et — otjigyň ýanar. Bir gününi goýbersеň ýa-da tabşyrygy ýetirmeseň — otjik öçýär. Uzyn seriýalar — hormat!',
      'tr':
          'Günde en az bir kez çeviri yap — ateşin yanar. Bir günü kaçırır veya görevi bitiremezsen — ateş söner. Uzun seriler saygı demektir!',
      'en':
          'Translate at least once a day — and your fire keeps burning. Miss a day or fail the task — the fire goes out. Long streaks earn respect!',
    },
  ),
  OnboardingPageData(
    pose: TeacherPose.celebrate,
    title: {
      'ru': 'Ты готов!',
      'tk': 'Sen taýýar!',
      'tr': 'Hazırsın!',
      'en': 'You\'re ready!',
    },
    body: {
      'ru':
          'Вот и вся мудрость. Иди переводи — я буду рядом на мосту и помогу. Забудешь что-то — нажми «?» в профиле, я напомню.',
      'tk':
          'Ine, hemme paýhas şu. Indi terjime et — men köpride ýanyňda bolaryn we kömek ederin. Unutsaň — profildäki «?» bas, ýatladaryn.',
      'tr':
          'İşte tüm bilgelik bu. Şimdi çeviri yap — köprüde yanında olacağım ve yardım edeceğim. Unutursan — profildeki «?» işaretine bas, hatırlatırım.',
      'en':
          'That\'s all the wisdom. Go translate — I\'ll be right there on the bridge to help. Forget something — tap "?" in your profile and I\'ll remind you.',
    },
  ),
];
