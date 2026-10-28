import 'package:flutter_test/flutter_test.dart';
import 'package:kopri/features/profile/data/profile_xp_service.dart';

void main() {
  test('Latyn we kiril harplary öňküsi ýaly sanalýar', () {
    expect(ProfileXpService.countChars('Доброе утро!'), 10);
    expect(ProfileXpService.countChars('Ertiriňiz haýyrly bolsun!'), 22);
    expect(ProfileXpService.countChars('Guten Morgen!'), 11);
  });

  test('à we і harplary hem sanalýar', () {
    expect(ProfileXpService.countChars('Bonjour à tous'), 12);
    expect(ProfileXpService.countChars('Доброго ранку, і вам'), 16);
  });

  test('Latyn däl ýazuwlar 0 däl', () {
    expect(ProfileXpService.countChars('शुभ प्रभात'), 6);
    expect(ProfileXpService.countChars('おはようございます'), 9);
    expect(ProfileXpService.countChars('早上好'), 3);
    expect(ProfileXpService.countChars('صباح الخير'), 9);
    expect(ProfileXpService.countChars('좋은 아침'), 4);
    expect(ProfileXpService.countChars('დილა მშვიდობისა'), 14);
  });
}
