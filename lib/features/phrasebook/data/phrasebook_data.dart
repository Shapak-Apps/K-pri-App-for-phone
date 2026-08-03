import 'package:flutter/material.dart';

class PPh {
  final String ru, en, tk, tr;
  const PPh(this.ru, this.en, this.tk, this.tr);
}

class PSub {
  final IconData icon;
  final String ru, en, tk;
  final List<PPh> p;
  const PSub(this.icon, this.ru, this.en, this.tk, this.p);
}

class PCat {
  final IconData icon;
  final String ru, en, tk;
  final List<PSub> s;
  const PCat(this.icon, this.ru, this.en, this.tk, this.s);
}

String phText(PPh p, String s) => switch (s) {
  'ru' => p.ru,
  'tk' => p.tk,
  'en' => p.en,
  _ => p.en,
};
String subText(PSub p, String s) => switch (s) {
  'ru' => p.ru,
  'tk' => p.tk,
  'en' => p.en,
  _ => p.en,
};
String catText(PCat p, String s) => switch (s) {
  'ru' => p.ru,
  'tk' => p.tk,
  'en' => p.en,
  _ => p.en,
};

int subCount(PSub s) => s.p.length;
int catCount(PCat c) => c.s.fold<int>(0, (a, s) => a + s.p.length);

const phrasebook = <PCat>[
  // 1
  PCat(
    Icons.waving_hand_rounded,
    'Приветствия и знакомство',
    'Greetings & Meeting',
    'Salamlaşma we tanyşlyk',
    [
      PSub(Icons.waving_hand_rounded, 'Приветствия', 'Hello', 'Salamlaşma', [
        PPh('Здравствуйте', 'Hello', 'Salam', 'hel-oh'),
        PPh('Доброе утро', 'Good morning', 'Ertiriňiz haýyrly', 'gud mor-ning'),
        PPh(
          'Добрый день',
          'Good afternoon',
          'Gündiziňiz haýyrly',
          'gud af-ter-noon',
        ),
        PPh('Добрый вечер', 'Good evening', 'Agşamyňyz haýyrly', 'gud ee-ving'),
      ]),
      PSub(Icons.person_add_rounded, 'Знакомство', 'Meeting', 'Tanyşlyk', [
        PPh(
          'Как вас зовут?',
          'What is your name?',
          'Adyňyz näme?',
          'wot iz yor neym',
        ),
        PPh('Меня зовут …', 'My name is …', 'Meniň adym …', 'may neym iz'),
        PPh(
          'Очень приятно',
          'Nice to meet you',
          'Tanyşanyma şat',
          'nays tu meet yu',
        ),
        PPh('Откуда вы?', 'Where are you from?', 'Nireden?', 'wer ar yu from'),
      ]),
    ],
  ),
  // 2
  PCat(
    Icons.handshake_rounded,
    'Вежливость и извинения',
    'Politeness & Sorry',
    'Edep we ötünç',
    [
      PSub(Icons.favorite_rounded, 'Благодарность', 'Thanks', 'Sagbolsun', [
        PPh('Спасибо', 'Thank you', 'Sag boluň', 'thenk yu'),
        PPh(
          'Большое спасибо',
          'Thank you very much',
          'Öň sag boluň',
          'thenk yu ve-ri mach',
        ),
        PPh('Не за что', 'You are welcome', 'Bir zat däl', 'yu ar wel-kom'),
        PPh('Пожалуйста', 'Please', 'Haýyş', 'pleez'),
      ]),
      PSub(Icons.mood_rounded, 'Извинения', 'Sorry', 'Ötünç', [
        PPh('Извините', 'Excuse me', 'Bagyşlaň', 'iks-kyuz mee'),
        PPh('Простите', 'I am sorry', 'Ökünýärin', 'ay em so-ri'),
        PPh('Ничего страшного', 'No problem', 'Hiç zat däl', 'no pro-blem'),
        PPh(
          'Я не понял',
          'I did not understand',
          'Men düşünmedim',
          'ay did not an-der-stand',
        ),
      ]),
    ],
  ),
  // 3
  PCat(
    Icons.family_restroom_rounded,
    'Семья и родственники',
    'Family',
    'Maşgala',
    [
      PSub(Icons.home_rounded, 'Ближайшие', 'Close family', 'Ýakynlar', [
        PPh('Мать / отец', 'Mother / father', 'Ene / ata', 'ma-ther / fa-ther'),
        PPh('Сын / дочь', 'Son / daughter', 'Ogul / gyz', 'san / do-ter'),
        PPh('Муж / жена', 'Husband / wife', 'Är / aýal', 'haz-band / wayf'),
        PPh(
          'Брат / сестра',
          'Brother / sister',
          'Dogan / uýa',
          'bra-ther / sis-ter',
        ),
      ]),
      PSub(Icons.people_rounded, 'Родня', 'Relatives', 'Gohumlar', [
        PPh(
          'Бабушка / дедушка',
          'Grandmother / grandfather',
          'Mama / ata',
          'gran-ma-ther / gran-fa-ther',
        ),
        PPh('Дядя / тётя', 'Uncle / aunt', 'Daýy / daýza', 'ang-kel / ant'),
        PPh('Друг / подруга', 'Friend', 'Dost', 'frend'),
        PPh('Сосед', 'Neighbour', 'Goňşy', 'ney-ber'),
      ]),
    ],
  ),
  // 4
  PCat(
    Icons.restaurant_rounded,
    'Еда в ресторане',
    'At the restaurant',
    'Restoranda',
    [
      PSub(Icons.table_restaurant_rounded, 'Заказ', 'Ordering', 'Sargyt', [
        PPh(
          'Столик на двоих',
          'A table for two',
          'Iki adamlyk stol',
          'a tey-bol for tu',
        ),
        PPh(
          'Меню, пожалуйста',
          'The menu, please',
          'Menýu haýyş',
          'de men-yu pleez',
        ),
        PPh(
          'Мы готовы заказать',
          'We are ready to order',
          'Biz taýýar',
          'wi ar re-di tu or-der',
        ),
        PPh(
          'Что рекомендуете?',
          'What do you recommend?',
          'Näme maslahat berýärsiňiz?',
          'wot du yu re-ko-mend',
        ),
      ]),
      PSub(Icons.receipt_long_rounded, 'Счёт', 'The bill', 'Hasap', [
        PPh(
          'Счёт, пожалуйста',
          'The bill, please',
          'Hasap haýyş',
          'de bil pleez',
        ),
        PPh(
          'Очень вкусно',
          'It is delicious',
          'Örän tagamly',
          'it iz di-li-shes',
        ),
        PPh(
          'Принесите ещё',
          'Bring more, please',
          'Ýene getiriň',
          'bring mor pleez',
        ),
        PPh(
          'Всё было отлично',
          'Everything was great',
          'Hemmesi gowy boldy',
          'ev-ri-ting woz greyt',
        ),
      ]),
      PSub(
        Icons.emoji_food_beverage_rounded,
        'Кухни мира',
        'World cuisines',
        'Dünýä aşhanalary',
        [
          PPh(
            'Национальное блюдо',
            'National dish',
            'Milli tagam',
            'na-sho-nal dish',
          ),
          PPh('Местная кухня', 'Local food', 'Ýerli nahar', 'lo-kal fud'),
          PPh('Острое', 'Spicy', 'Ajy', 'spay-si'),
          PPh('Не острое', 'Not spicy', 'Ajy däl', 'not spay-si'),
          PPh(
            'Фирменное блюдо',
            'Speciality',
            'Firmenny tagam',
            'spe-sha-li-ti',
          ),
        ],
      ),
    ],
  ),
  // 5
  PCat(Icons.local_drink_rounded, 'Напитки', 'Drinks', 'Içgiler', [
    PSub(Icons.coffee_rounded, 'Горячие', 'Hot', 'Yssy', [
      PPh('Чай, пожалуйста', 'Tea, please', 'Çay haýyş', 'tee pleez'),
      PPh(
        'Кофе с молоком',
        'Coffee with milk',
        'Sütli kofe',
        'ko-fi with milk',
      ),
      PPh('Чёрный кофе', 'Black coffee', 'Gara kofe', 'blak ko-fi'),
      PPh('Горячий шоколад', 'Hot chocolate', 'Yssy şokolad', 'hot cho-ko-let'),
    ]),
    PSub(Icons.water_drop_rounded, 'Холодные', 'Cold', 'Sowuk', [
      PPh(
        'Стакан воды',
        'A glass of water',
        'Bir stakan suw',
        'a glas ov wo-ter',
      ),
      PPh('Сок, пожалуйста', 'Juice, please', 'Şire haýyş', 'jus pleez'),
      PPh(
        'Что-то холодное',
        'Something cold',
        'Sowuk bir zat',
        'sam-ting kold',
      ),
      PPh('Без льда', 'No ice, please', 'Buzsuz', 'no ays pleez'),
    ]),
    PSub(Icons.sports_bar_rounded, 'Алкоголь', 'Alcohol', 'Alkogol', [
      PPh('Пиво', 'Beer', 'Piwo', 'beer'),
      PPh('Вино', 'Wine', 'Çakyr', 'wayn'),
      PPh('Красное вино', 'Red wine', 'Gyzyl çakyr', 'red wayn'),
      PPh('Белое вино', 'White wine', 'Ak çakyr', 'wayt wayn'),
      PPh('Без алкоголя', 'Non-alcoholic', 'Alkogolsyz', 'non-al-ko-ho-lik'),
    ]),
  ]),
  // 6
  PCat(
    Icons.no_food_rounded,
    'Аллергии и диета',
    'Allergy & Diet',
    'Allergiýa we dieta',
    [
      PSub(Icons.warning_amber_rounded, 'Аллергии', 'Allergies', 'Allergiýa', [
        PPh(
          'У меня аллергия на …',
          'I am allergic to …',
          'Meniň … allergiýam bar',
          'ay em a-ler-jik tu',
        ),
        PPh(
          'Это содержит орехи?',
          'Does it contain nuts?',
          'Munda hoz barmy?',
          'daz it kon-teyn nats',
        ),
        PPh('Без молока', 'Without milk', 'Sütsiz', 'wi-thaut milk'),
        PPh('Без глютена', 'Gluten free', 'Glýutensiz', 'glu-ten free'),
      ]),
      PSub(Icons.eco_rounded, 'Диета', 'Diet', 'Dieta', [
        PPh(
          'Я вегетарианец',
          'I am vegetarian',
          'Men wegetarian',
          'ay em ve-ji-tey-ri-en',
        ),
        PPh(
          'Я не ем мясо',
          'I do not eat meat',
          'Men et iýemok',
          'ay du not eet meet',
        ),
        PPh('Без сахара', 'No sugar', 'Şekersiz', 'no shu-ger'),
        PPh('Мало соли', 'Less salt, please', 'Az duz', 'les solt pleez'),
      ]),
    ],
  ),
  // 7
  PCat(
    Icons.apple_rounded,
    'Фрукты и овощи',
    'Fruits & Vegetables',
    'Miweler we gök önümler',
    [
      PSub(Icons.apple_rounded, 'Фрукты', 'Fruits', 'Miweler', [
        PPh('Яблоко', 'Apple', 'Alma', 'a-pel'),
        PPh('Банан', 'Banana', 'Banan', 'ba-na-na'),
        PPh('Апельсин', 'Orange', 'Apelsin', 'o-rinj'),
        PPh('Виноград', 'Grapes', 'Üzüm', 'greyps'),
      ]),
      PSub(Icons.eco_rounded, 'Овощи', 'Vegetables', 'Gök önümler', [
        PPh('Помидор', 'Tomato', 'Pomidor', 'to-ma-to'),
        PPh('Огурец', 'Cucumber', 'Hýyar', 'kyu-kam-ber'),
        PPh('Картофель', 'Potato', 'Kartoşka', 'po-tey-to'),
        PPh('Лук', 'Onion', 'Sogan', 'an-yen'),
      ]),
      PSub(
        Icons.grass_rounded,
        'Ягоды и бахчевые',
        'Berries & Melons',
        'Ýertudana we gawun',
        [
          PPh('Клубника', 'Strawberry', 'Ýertudana', 'stro-ber-i'),
          PPh('Вишня', 'Cherry', 'Alça', 'che-ri'),
          PPh('Арбуз', 'Watermelon', 'Garpyz', 'wo-ter-me-lon'),
          PPh('Дыня', 'Melon', 'Gawun', 'me-lon'),
          PPh('Зелень', 'Herbs', 'Gök ot', 'herbs'),
        ],
      ),
    ],
  ),
  // 8
  PCat(Icons.set_meal_rounded, 'Мясо и рыба', 'Meat & Fish', 'Et we balyk', [
    PSub(Icons.dinner_dining_rounded, 'Мясо', 'Meat', 'Et', [
      PPh('Говядина', 'Beef', 'Sygyr eti', 'beef'),
      PPh('Курица', 'Chicken', 'Towuk eti', 'chi-ken'),
      PPh('Баранина', 'Lamb', 'Goýun eti', 'lam'),
      PPh('Мясо на гриле', 'Grilled meat', 'Gril eti', 'grild meet'),
    ]),
    PSub(Icons.set_meal_rounded, 'Рыба', 'Fish', 'Balyk', [
      PPh('Рыба', 'Fish', 'Balyk', 'fish'),
      PPh('Жареная рыба', 'Fried fish', 'Gyzardylan balyk', 'fryd fish'),
      PPh('Креветки', 'Shrimps', 'Krewetka', 'shrimps'),
      PPh('Свежая рыба', 'Fresh fish', 'Täze balyk', 'fresh fish'),
    ]),
    PSub(Icons.set_meal_rounded, 'Морепродукты', 'Seafood', 'Deňiz önümleri', [
      PPh('Кальмар', 'Squid', 'Kalmar', 'skwid'),
      PPh('Мидии', 'Mussels', 'Midiýa', 'ma-sels'),
      PPh('Устрицы', 'Oysters', 'Ustritsa', 'oy-sters'),
      PPh('Лосось', 'Salmon', 'Losos', 'sa-mon'),
      PPh('Икра', 'Caviar', 'Işbil', 'ka-vi-ar'),
    ]),
  ]),
  // 9
  PCat(
    Icons.cake_rounded,
    'Сладости и выпечка',
    'Sweets & Bakery',
    'Süýjülik we çörek',
    [
      PSub(Icons.cake_rounded, 'Десерты', 'Desserts', 'Desertler', [
        PPh('Мороженое', 'Ice cream', 'Dondurma', 'ays kreem'),
        PPh('Торт', 'Cake', 'Tort', 'keyk'),
        PPh('Шоколад', 'Chocolate', 'Şokolad', 'cho-ko-let'),
        PPh('Мёд', 'Honey', 'Bal', 'ha-ni'),
      ]),
      PSub(Icons.bakery_dining_rounded, 'Выпечка', 'Bakery', 'Çörek', [
        PPh('Хлеб', 'Bread', 'Çörek', 'bred'),
        PPh('Свежий хлеб', 'Fresh bread', 'Täze çörek', 'fresh bred'),
        PPh('Булочка', 'Bun', 'Bulka', 'ban'),
        PPh('Печенье', 'Cookie', 'Köke', 'ku-ki'),
      ]),
    ],
  ),
  // 10
  PCat(Icons.free_breakfast_rounded, 'Завтрак', 'Breakfast', 'Ertirlik', [
    PSub(Icons.egg_rounded, 'Блюда', 'Dishes', 'Naharlar', [
      PPh('Яичница', 'Fried eggs', 'Gyzardylan ýumurtga', 'fryd egz'),
      PPh('Омлет', 'Omelette', 'Omlet', 'om-let'),
      PPh('Каша', 'Porridge', 'Süýtli unaş', 'po-rij'),
      PPh('Блины', 'Pancakes', 'Blintsek', 'pan-keyks'),
    ]),
    PSub(
      Icons.bakery_dining_rounded,
      'К завтраку',
      'With breakfast',
      'Ertirlik bilen',
      [
        PPh(
          'Масло и сыр',
          'Butter and cheese',
          'Mesge we peýnir',
          'ba-ter end cheez',
        ),
        PPh('Джем', 'Jam', 'Murabbo', 'jam'),
        PPh('Йогурт', 'Yoghurt', 'Ýogurt', 'yo-gert'),
        PPh(
          'Завтрак включён?',
          'Is breakfast included?',
          'Ertirlik goşulýarmy?',
          'iz brek-fest in-klu-ded',
        ),
      ],
    ),
  ]),
  // 11
  PCat(
    Icons.flight_takeoff_rounded,
    'Аэропорт и рейсы',
    'Airport & Flights',
    'Howa menzili',
    [
      PSub(
        Icons.airline_stops_rounded,
        'Регистрация',
        'Check-in',
        'Hasaba alyş',
        [
          PPh(
            'Где регистрация?',
            'Where is check-in?',
            'Hasaba alyş nirede?',
            'wer iz çek-in',
          ),
          PPh(
            'Паспорт, пожалуйста',
            'Your passport, please',
            'Pasportyňyzy haýyş',
            'yor pas-port pleez',
          ),
          PPh(
            'Одно место у окна',
            'One window seat',
            'Bir penjire ýany',
            'wan win-do seet',
          ),
          PPh(
            'Багаж сдать',
            'Check the baggage',
            'Ýüki tabşyrmaly',
            'çek de ba-gij',
          ),
        ],
      ),
      PSub(Icons.flight_rounded, 'Рейс', 'Flight', 'Uçuş', [
        PPh(
          'Во сколько вылет?',
          'What time is the flight?',
          'Uçuş sagat näçede?',
          'wot taym iz de flayt',
        ),
        PPh(
          'Где мой выход?',
          'Where is my gate?',
          'Meniň gapym nirede?',
          'wer iz may geyt',
        ),
        PPh(
          'Рейс задержан',
          'The flight is delayed',
          'Uçuş gijikdirildi',
          'de flayt iz di-leyd',
        ),
        PPh(
          'Где багаж?',
          'Where is the baggage?',
          'Ýükler nirede?',
          'wer iz de ba-gij',
        ),
      ]),
      PSub(
        Icons.security_rounded,
        'Досмотр и пересадка',
        'Security & Transfer',
        'Barlag we aktarma',
        [
          PPh(
            'Где досмотр?',
            'Where is security?',
            'Barlag nirede?',
            'wer iz se-kyu-ri-ti',
          ),
          PPh(
            'У меня пересадка',
            'I have a transfer',
            'Meniň aktarmam bar',
            'ay hev a trans-fer',
          ),
          PPh(
            'Достаньте ноутбук',
            'Take out your laptop',
            'Noutbugyňyzy çykaryň',
            'teyk aut yor lap-top',
          ),
          PPh(
            'Жидкости есть?',
            'Any liquids?',
            'Suwuklyk barmy?',
            'e-ni li-kwids',
          ),
          PPh(
            'Какой терминал?',
            'Which terminal?',
            'Haýsy terminal?',
            'wich ter-mi-nal',
          ),
        ],
      ),
    ],
  ),
  // 12
  PCat(Icons.local_taxi_rounded, 'Такси', 'Taxi', 'Taksi', [
    PSub(Icons.local_taxi_rounded, 'Вызов', 'Calling', 'Çagyrmak', [
      PPh(
        'Вызовите такси',
        'Call a taxi, please',
        'Taksi çagyryň',
        'kol a tak-see',
      ),
      PPh(
        'Отвезите меня сюда',
        'Take me here',
        'Meni şu ýere äkidiň',
        'tayk mee heer',
      ),
      PPh('В аэропорт', 'To the airport', 'Howa menziline', 'tu de er-port'),
      PPh(
        'Сколько стоит?',
        'How much is it?',
        'Näçe durýar?',
        'hau mach iz it',
      ),
    ]),
    PSub(Icons.pin_drop_rounded, 'В пути', 'On the way', 'Ýolda', [
      PPh(
        'Остановите здесь',
        'Stop here, please',
        'Şu ýerde saklaň',
        'stop heer pleez',
      ),
      PPh('Подождите меня', 'Wait for me', 'Maňa garaşyň', 'weyt for mee'),
      PPh(
        'Можно багаж?',
        'Can you take luggage?',
        'Ýük alyp bilersiňizmi?',
        'ken yu teyk la-gij',
      ),
      PPh('Чек, пожалуйста', 'Receipt, please', 'Çek haýyş', 'ri-seet pleez'),
    ]),
  ]),
  // 13
  PCat(
    Icons.directions_bus_rounded,
    'Автобус и метро',
    'Bus & Metro',
    'Awtobus we metro',
    [
      PSub(Icons.directions_bus_rounded, 'Автобус', 'Bus', 'Awtobus', [
        PPh(
          'Где остановка?',
          'Where is the bus stop?',
          'Duralga nirede?',
          'wer iz de bas stop',
        ),
        PPh(
          'Идёт в центр?',
          'Does it go to the center?',
          'Merkeze gidýärmi?',
          'daz it go tu de sen-ter',
        ),
        PPh('Один билет', 'One ticket', 'Bir bilet', 'wan ti-kit'),
        PPh(
          'Где мне выйти?',
          'Where do I get off?',
          'Nirede düşmeli?',
          'wer du ay get of',
        ),
      ]),
      PSub(Icons.subway_rounded, 'Метро', 'Metro', 'Metro', [
        PPh(
          'Где метро?',
          'Where is the metro?',
          'Metro nirede?',
          'wer iz de me-tro',
        ),
        PPh('Какая линия?', 'Which line?', 'Haýsy çyzyk?', 'wich layn'),
        PPh(
          'Жетон, пожалуйста',
          'A token, please',
          'Bir žeton haýyş',
          'a to-ken pleez',
        ),
        PPh(
          'Следующая станция?',
          'Next station?',
          'Indiki duralga?',
          'nekst stey-shen',
        ),
      ]),
      PSub(Icons.confirmation_number_rounded, 'Билеты', 'Tickets', 'Biletler', [
        PPh(
          'В одну сторону',
          'One-way ticket',
          'Bir tarapa bilet',
          'wan-way ti-kit',
        ),
        PPh('Туда и обратно', 'Return ticket', 'Yzyna bilet', 'ri-tern ti-kit'),
        PPh('Проездной', 'Travel pass', 'Ýol kartasy', 'tra-vel pas'),
        PPh('Детский билет', 'Child ticket', 'Çaga bileti', 'chayld ti-kit'),
        PPh(
          'Компостировать',
          'Validate the ticket',
          'Bileti belläň',
          'va-li-deyt de ti-kit',
        ),
      ]),
    ],
  ),
  // 14
  PCat(Icons.train_rounded, 'Поезд', 'Train', 'Otly', [
    PSub(Icons.train_rounded, 'Посадка', 'Boarding', 'Münmek', [
      PPh(
        'С какой платформы?',
        'Which platform?',
        'Haýsy platforma?',
        'wich plat-form',
      ),
      PPh(
        'Во сколько отправление?',
        'What time does it leave?',
        'Sagat näçede gidýär?',
        'wot taym daz it leev',
      ),
      PPh(
        'Это моё место',
        'This is my seat',
        'Bu meniň ýerim',
        'dis iz may seet',
      ),
      PPh(
        'Вагон-ресторан?',
        'Is there a dining car?',
        'Restoran wagony barmy?',
        'iz der a day-ning kar',
      ),
    ]),
    PSub(Icons.luggage_rounded, 'Багаж', 'Luggage', 'Ýük', [
      PPh(
        'Где положить багаж?',
        'Where to put luggage?',
        'Ýüki nire goýmaly?',
        'wer tu put la-gij',
      ),
      PPh(
        'Помогите с сумкой',
        'Help with my bag',
        'Sumkama kömek ediň',
        'help with may bag',
      ),
      PPh(
        'Я сошёл не там',
        'I got off at the wrong stop',
        'Men nädogry düşdüm',
        'ay got of et de rong stop',
      ),
      PPh(
        'Когда прибываем?',
        'When do we arrive?',
        'Haçan barýarys?',
        'wen du wi a-rayv',
      ),
    ]),
  ]),
  // 15
  PCat(
    Icons.car_rental_rounded,
    'Аренда авто',
    'Car rental',
    'Awtoulag kärendesi',
    [
      PSub(Icons.car_rental_rounded, 'Прокат', 'Rental', 'Kärende', [
        PPh(
          'Хочу арендовать авто',
          'I want to rent a car',
          'Maşyn kärendesine almaly',
          'ay wont tu rent a kar',
        ),
        PPh(
          'На сколько дней?',
          'For how many days?',
          'Näçe günligine?',
          'for hau me-ni deys',
        ),
        PPh('С автоматом', 'Automatic gearbox', 'Awtomat', 'o-to-ma-tik'),
        PPh(
          'Страховка включена?',
          'Is insurance included?',
          'Ätiýaçlandyryş barmy?',
          'iz in-shu-rans in-klu-ded',
        ),
      ]),
      PSub(Icons.local_gas_station_rounded, 'Заправка', 'Fuel', 'Ýangyç', [
        PPh(
          'Где заправка?',
          'Where is the gas station?',
          'Ýangyç duralgasy nirede?',
          'wer iz de gas stey-shen',
        ),
        PPh('Полный бак', 'Full tank, please', 'Doly bak', 'ful tank pleez'),
        PPh(
          'Дизель или бензин?',
          'Diesel or petrol?',
          'Dizel ýa benzin?',
          'dee-zel or pe-trel',
        ),
        PPh(
          'Проверьте масло',
          'Check the oil, please',
          'Ýagy barlaň',
          'çek de oyl pleez',
        ),
      ]),
    ],
  ),
  // 16
  PCat(
    Icons.directions_walk_rounded,
    'Пешком и велосипед',
    'Walking & Bike',
    'Pyýada we welosiped',
    [
      PSub(Icons.directions_walk_rounded, 'Пешком', 'Walking', 'Pyýada', [
        PPh(
          'Это далеко пешком?',
          'Is it far on foot?',
          'Pyýada uzakmy?',
          'iz it far on fut',
        ),
        PPh(
          'Сколько идти?',
          'How long to walk?',
          'Näçe wagt ýöremeli?',
          'hau long tu wok',
        ),
        PPh(
          'Есть тротуар?',
          'Is there a sidewalk?',
          'Ýoda barmy?',
          'iz der a sayd-wok',
        ),
        PPh('Я заблудился', 'I am lost', 'Men ýitdim', 'ay em lost'),
      ]),
      PSub(Icons.pedal_bike_rounded, 'Велосипед', 'Bike', 'Welosiped', [
        PPh(
          'Где взять велосипед?',
          'Where to rent a bike?',
          'Welosiped nireden almaly?',
          'wer tu rent a bayk',
        ),
        PPh('На час', 'For one hour', 'Bir sagatlyk', 'for wan au-er'),
        PPh(
          'Где велодорожка?',
          'Where is the bike lane?',
          'Welosiped ýoly nirede?',
          'wer iz de bayk leyn',
        ),
        PPh(
          'Шлем есть?',
          'Do you have a helmet?',
          'Togalga barmy?',
          'du yu hev a hel-met',
        ),
      ]),
    ],
  ),
  // 17
  PCat(
    Icons.hotel_rounded,
    'Отель: заселение',
    'Hotel check-in',
    'Myhmanhana',
    [
      PSub(Icons.hotel_rounded, 'Стойка', 'Reception', 'Resepşn', [
        PPh(
          'У меня бронь',
          'I have a reservation',
          'Meniň bronum bar',
          'ay hev a re-zer-vey-shen',
        ),
        PPh(
          'Номер на одну ночь',
          'A room for one night',
          'Bir gijelik otag',
          'a room for wan nayt',
        ),
        PPh(
          'Сколько стоит ночь?',
          'How much per night?',
          'Gijesi näçe?',
          'hau mach per nayt',
        ),
        PPh(
          'Завтрак включён?',
          'Is breakfast included?',
          'Ertirlik goşulýarmy?',
          'iz brek-fest in-klu-ded',
        ),
      ]),
      PSub(Icons.key_rounded, 'Ключ и этаж', 'Key & Floor', 'Açgy we gat', [
        PPh('Какой этаж?', 'Which floor?', 'Haýsy gat?', 'wich flor'),
        PPh(
          'Где лифт?',
          'Where is the elevator?',
          'Lift nirede?',
          'wer iz de e-li-vey-ter',
        ),
        PPh(
          'Дайте второй ключ',
          'A second key, please',
          'Ikinji açgy haýyş',
          'a se-kend key pleez',
        ),
        PPh(
          'Во сколько выезд?',
          'What is check-out time?',
          'Çykyş sagady näçe?',
          'wot iz çek-aut taym',
        ),
      ]),
      PSub(
        Icons.meeting_room_rounded,
        'Типы номеров',
        'Room types',
        'Otag görnüşleri',
        [
          PPh(
            'Одноместный номер',
            'Single room',
            'Bir ýerlik otag',
            'sing-gel room',
          ),
          PPh(
            'Двухместный номер',
            'Double room',
            'Iki ýerlik otag',
            'da-bel room',
          ),
          PPh('Люкс', 'Suite', 'Lýuks', 'sweet'),
          PPh('С видом на море', 'Sea view', 'Deňiz görnüşli', 'see vyoo'),
          PPh('С балконом', 'With balcony', 'Balkonly', 'with bal-ko-ni'),
        ],
      ),
    ],
  ),
  // 18
  PCat(Icons.king_bed_rounded, 'Отель: в номере', 'In the room', 'Otagda', [
    PSub(Icons.wifi_rounded, 'Удобства', 'Amenities', 'Amatlylyklar', [
      PPh(
        'Пароль от Wi-Fi?',
        'What is the Wi-Fi password?',
        'Wi-Fi paroly näme?',
        'wot iz de way-fay pas-werd',
      ),
      PPh(
        'Можно ещё полотенце?',
        'Another towel, please',
        'Ýene süpürgiç haýyş',
        'a-na-ter tau-el pleez',
      ),
      PPh('Дайте воду', 'Some water, please', 'Suw haýyş', 'sam wo-ter pleez'),
      PPh('Где сейф?', 'Where is the safe?', 'Seýf nirede?', 'wer iz de seyf'),
    ]),
    PSub(Icons.room_service_rounded, 'Обслуживание', 'Service', 'Hyzmat', [
      PPh(
        'Разбудите в 7',
        'Wake me at seven',
        'Meni 7-de oýaryň',
        'weyk mee et se-ven',
      ),
      PPh(
        'Уборка номера',
        'Clean the room, please',
        'Otagy arassalaň',
        'kleen de room pleez',
      ),
      PPh(
        'Завтрак в номер',
        'Breakfast in room',
        'Otaga ertirlik',
        'brek-fest in room',
      ),
      PPh(
        'Можно позже выезд?',
        'Late check-out?',
        'Gijik çykmak bolarmy?',
        'leyt çek-aut',
      ),
    ]),
  ]),
  // 19
  PCat(Icons.build_rounded, 'Отель: проблемы', 'Hotel problems', 'Meseleler', [
    PSub(Icons.ac_unit_rounded, 'Поломки', 'Broken', 'Döwük', [
      PPh(
        'Не работает кондиционер',
        'The AC does not work',
        'Kondisioner işlemeýär',
        'de ey-si daz not werk',
      ),
      PPh('Нет горячей воды', 'No hot water', 'Yssy suw ýok', 'no hot wo-ter'),
      PPh(
        'Не горит свет',
        'The light is off',
        'Çyra ýanmaýar',
        'de layt iz of',
      ),
      PPh(
        'Сломан замок',
        'The lock is broken',
        'Gulpy döwük',
        'de lok iz bro-ken',
      ),
    ]),
    PSub(Icons.volume_up_rounded, 'Шум', 'Noise', 'Ses', [
      PPh(
        'Слишком шумно',
        'It is too noisy',
        'Örän galmagally',
        'it iz tu noy-zi',
      ),
      PPh(
        'Можно тише?',
        'Can you be quieter?',
        'Azaýrak ses bolmazmy?',
        'ken yu bi kwaý-er',
      ),
      PPh(
        'Другой номер',
        'Another room, please',
        'Başga otag haýyş',
        'a-na-ter room pleez',
      ),
      PPh(
        'Позовите менеджера',
        'Call the manager',
        'Dolandyryjyny çagyryň',
        'kol de ma-ni-jer',
      ),
    ]),
  ]),
  // 20
  PCat(
    Icons.forest_rounded,
    'Хостел и кемпинг',
    'Hostel & Camping',
    'Hostel we düşelge',
    [
      PSub(Icons.hotel_rounded, 'Хостел', 'Hostel', 'Hostel', [
        PPh(
          'Койка в общей комнате',
          'A bed in a dorm',
          'Umumy otagda düşek',
          'a bed in a dorm',
        ),
        PPh(
          'Есть шкафчик?',
          'Is there a locker?',
          'Şkaf barmy?',
          'iz der a lo-ker',
        ),
        PPh(
          'Где кухня?',
          'Where is the kitchen?',
          'Aşhana nirede?',
          'wer iz de ki-chen',
        ),
        PPh('Общий душ?', 'Shared shower?', 'Umumy hammam?', 'sherd shau-er'),
      ]),
      PSub(Icons.forest_rounded, 'Кемпинг', 'Camping', 'Düşelge', [
        PPh(
          'Место для палатки',
          'A tent spot',
          'Çadyr üçin ýer',
          'a tent spot',
        ),
        PPh('Где вода?', 'Where is water?', 'Suw nirede?', 'wer iz wo-ter'),
        PPh(
          'Можно костёр?',
          'Can we make a fire?',
          'Ot ýakmak bolarmy?',
          'ken wi meyk a fayr',
        ),
        PPh(
          'Туалет рядом?',
          'Is the toilet nearby?',
          'Hajathana ýakynmy?',
          'iz de toy-let nier-bay',
        ),
      ]),
    ],
  ),
  // 21
  PCat(
    Icons.shopping_cart_rounded,
    'Покупки: цены и торг',
    'Shopping & Bargain',
    'Söwda we baha',
    [
      PSub(Icons.sell_rounded, 'Цена', 'Price', 'Baha', [
        PPh(
          'Сколько это стоит?',
          'How much is this?',
          'Munuň bahasy näçe?',
          'hau mach iz dis',
        ),
        PPh('Слишком дорого', 'Too expensive', 'Örän gymmat', 'tu iks-pen-siv'),
        PPh('Скиньте цену', 'Give a discount', 'Arzanladyň', 'giv a dis-kaunt'),
        PPh(
          'Я только смотрю',
          'I am just looking',
          'Men diňe seredýärin',
          'ay em jast lu-king',
        ),
      ]),
      PSub(Icons.payments_rounded, 'Оплата', 'Payment', 'Töleg', [
        PPh(
          'Принимаете карты?',
          'Do you take cards?',
          'Kart kabul edýärsiňizmi?',
          'du yu teyk kards',
        ),
        PPh('Только наличные', 'Cash only', 'Diňe nagt', 'kesh on-li'),
        PPh('Чек, пожалуйста', 'Receipt, please', 'Çek haýyş', 'ri-seet pleez'),
        PPh(
          'Упакуйте в подарок',
          'Gift wrap, please',
          'Sowgap gaplaň',
          'gift wrap pleez',
        ),
      ]),
      PSub(
        Icons.assignment_return_rounded,
        'Возврат товара',
        'Returns',
        'Yzyna gaýtarmak',
        [
          PPh(
            'Хочу вернуть',
            'I want to return',
            'Yzyna gaýtarmak isleýärin',
            'ay wont tu ri-tern',
          ),
          PPh('Не подходит', 'It does not fit', 'Bolmaýar', 'it daz not fit'),
          PPh(
            'Есть чек',
            'I have the receipt',
            'Çegim bar',
            'ay hev de ri-seet',
          ),
          PPh(
            'Верните деньги',
            'Refund, please',
            'Pulumy yzyna beriň',
            'ri-fand pleez',
          ),
          PPh(
            'Обмен возможен?',
            'Can I exchange?',
            'Çalşyp bolarmy?',
            'ken ay iks-cheynj',
          ),
        ],
      ),
    ],
  ),
  // 22
  PCat(
    Icons.checkroom_rounded,
    'Одежда и размер',
    'Clothes & Size',
    'Eşik we ölçeg',
    [
      PSub(Icons.checkroom_rounded, 'Размер', 'Size', 'Ölçeg', [
        PPh(
          'Есть другой размер?',
          'Another size?',
          'Başga ölçegi barmy?',
          'a-na-ter sayz',
        ),
        PPh(
          'Мне нужен больше',
          'I need a bigger one',
          'Maňa ulyrak gerek',
          'ay need a bi-ger wan',
        ),
        PPh(
          'Можно примерить?',
          'Can I try it on?',
          'Synap görüp bilerinmi?',
          'ken ay tray it on',
        ),
        PPh(
          'Где примерочная?',
          'Where is the fitting room?',
          'Synag otagy nirede?',
          'wer iz de fi-ting room',
        ),
      ]),
      PSub(Icons.palette_rounded, 'Цвет', 'Color', 'Reňk', [
        PPh(
          'Покажите другой цвет',
          'Show another color',
          'Başga reňkini görkeziň',
          'sho a-na-ter ka-ler',
        ),
        PPh(
          'Тёмный / светлый',
          'Dark / light',
          'Garaňky / ýagty',
          'dark / layt',
        ),
        PPh(
          'Мне нравится этот',
          'I like this one',
          'Maňa bu ýaraýar',
          'ay layk dis wan',
        ),
        PPh('Возьму это', 'I will take this', 'Muny alaryn', 'ay wil teyk dis'),
      ]),
    ],
  ),
  // 23
  PCat(
    Icons.dry_cleaning_rounded,
    'Обувь и аксессуары',
    'Shoes & Accessories',
    'Aýakgap we aksessuar',
    [
      PSub(Icons.dry_cleaning_rounded, 'Обувь', 'Shoes', 'Aýakgap', [
        PPh(
          'Мой размер 42',
          'My size is 42',
          'Meniň ölçegim 42',
          'may sayz iz for-ti-tu',
        ),
        PPh('Эти жмут', 'These are tight', 'Bular dar', 'diz ar tayt'),
        PPh(
          'Покажите кроссовки',
          'Show sneakers',
          'Krossowka görkeziň',
          'sho snee-kers',
        ),
        PPh(
          'Нужны удобные',
          'I need comfortable',
          'Maňa amatly gerek',
          'ay need komf-te-bl',
        ),
      ]),
      PSub(Icons.watch_rounded, 'Аксессуары', 'Accessories', 'Aksessuar', [
        PPh('Ремень', 'A belt', 'Guşak', 'a belt'),
        PPh('Сумка', 'A bag', 'Sumka', 'a bag'),
        PPh('Очки', 'Glasses', 'Äýnek', 'gla-ses'),
        PPh('Шарф', 'A scarf', 'Şarf', 'a skarf'),
      ]),
    ],
  ),
  // 24
  PCat(Icons.devices_rounded, 'Электроника', 'Electronics', 'Elektronika', [
    PSub(Icons.phone_android_rounded, 'Гаджеты', 'Gadgets', 'Enjamlar', [
      PPh(
        'Зарядка для телефона',
        'Phone charger',
        'Telefon zarýadlaýjy',
        'fon char-jer',
      ),
      PPh('Наушники', 'Headphones', 'Gulakçyn', 'hed-fons'),
      PPh('Флешка', 'USB drive', 'Fleşka', 'yu-es-bee drayv'),
      PPh('Переходник', 'Adapter', 'Adaptör', 'a-dap-ter'),
    ]),
    PSub(Icons.power_rounded, 'Питание', 'Power', 'Iýmitlendirme', [
      PPh(
        'Какая розетка?',
        'What plug type?',
        'Haýsy rozetka?',
        'wot plag tayp',
      ),
      PPh(
        'Где купить батарейки?',
        'Where to buy batteries?',
        'Batareýka nireden almaly?',
        'wer tu bay ba-te-ris',
      ),
      PPh(
        'Не включается',
        'It does not turn on',
        'Işlemeýär',
        'it daz not tern on',
      ),
      PPh(
        'Гарантия есть?',
        'Is there warranty?',
        'Kepillik barmy?',
        'iz der wo-ren-ti',
      ),
    ]),
  ]),
  // 25
  PCat(
    Icons.shopping_basket_rounded,
    'Супермаркет',
    'Supermarket',
    'Supermarket',
    [
      PSub(Icons.shopping_basket_rounded, 'В зале', 'In the store', 'Dükanda', [
        PPh(
          'Где молоко?',
          'Where is the milk?',
          'Süt nirede?',
          'wer iz de milk',
        ),
        PPh(
          'Где хлеб?',
          'Where is the bread?',
          'Çörek nirede?',
          'wer iz de bred',
        ),
        PPh(
          'Корзина где?',
          'Where are the baskets?',
          'Sebet nirede?',
          'wer ar de bas-kits',
        ),
        PPh('Свежее это?', 'Is this fresh?', 'Bu täzemi?', 'iz dis fresh'),
      ]),
      PSub(Icons.point_of_sale_rounded, 'Касса', 'Checkout', 'Kassa', [
        PPh(
          'Где касса?',
          'Where is the checkout?',
          'Kassa nirede?',
          'wer iz de çek-aut',
        ),
        PPh('Пакет нужен', 'I need a bag', 'Maňa paket gerek', 'ay need a bag'),
        PPh(
          'Картой можно?',
          'Can I pay by card?',
          'Kart bilen bolarmy?',
          'ken ay pay bay kard',
        ),
        PPh(
          'Это не моё',
          'This is not mine',
          'Bu meniňki däl',
          'dis iz not mayn',
        ),
      ]),
    ],
  ),
  // 26
  PCat(Icons.local_pharmacy_rounded, 'Аптека', 'Pharmacy', 'Dermanhana', [
    PSub(Icons.local_pharmacy_rounded, 'Покупка', 'Buying', 'Satyn almak', [
      PPh(
        'Мне нужно лекарство',
        'I need medicine',
        'Maňa derman gerek',
        'ay need me-di-sin',
      ),
      PPh('Обезболивающее', 'Painkiller', 'Agyry basýan derman', 'peyn-ki-ler'),
      PPh('Пластырь', 'Bandage', 'Plastyr', 'ban-dij'),
      PPh(
        'Солнцезащитный крем',
        'Sunscreen',
        'Günden goraýan krem',
        'san-skreen',
      ),
    ]),
    PSub(Icons.medication_rounded, 'Рецепт', 'Prescription', 'Resept', [
      PPh(
        'По рецепту',
        'With prescription',
        'Resept bilen',
        'with pres-krip-shen',
      ),
      PPh(
        'Как принимать?',
        'How to take it?',
        'Nädip ulanmaly?',
        'hau tu teyk it',
      ),
      PPh(
        'Сколько раз в день?',
        'How many times a day?',
        'Günde näçe gezek?',
        'hau me-ni tayms a dey',
      ),
      PPh(
        'Есть аналог?',
        'Is there a generic?',
        'Meňzeşi barmy?',
        'iz der a je-ne-rik',
      ),
    ]),
    PSub(Icons.vaccines_rounded, 'Лекарства', 'Medicines', 'Dermanlar', [
      PPh('Таблетка', 'Tablet', 'Hep', 'tab-let'),
      PPh('Сироп', 'Syrup', 'Şerbet', 'si-rap'),
      PPh('Мазь', 'Ointment', 'Melhem', 'oynt-ment'),
      PPh('Антибиотик', 'Antibiotic', 'Antibiotik', 'an-ti-bay-o-tik'),
      PPh('Витамины', 'Vitamins', 'Witaminler', 'vay-ta-mins'),
    ]),
  ]),
  // 27
  PCat(
    Icons.local_hospital_rounded,
    'Больница и врач',
    'Hospital & Doctor',
    'Hassahana we lukman',
    [
      PSub(Icons.local_hospital_rounded, 'Приём', 'Visit', 'Kabul', [
        PPh(
          'Мне нужен врач',
          'I need a doctor',
          'Maňa lukman gerek',
          'ay need a dok-ter',
        ),
        PPh(
          'Где больница?',
          'Where is the hospital?',
          'Hassahana nirede?',
          'wer iz de hos-pi-tel',
        ),
        PPh(
          'Запишите меня',
          'Make an appointment',
          'Meni ýazyň',
          'meyk en a-poynt-ment',
        ),
        PPh('Это срочно', 'It is urgent', 'Bu gyssagly', 'it iz er-jent'),
      ]),
      PSub(
        Icons.health_and_safety_rounded,
        'Страховка',
        'Insurance',
        'Ätiýaçlandyryş',
        [
          PPh(
            'У меня страховка',
            'I have insurance',
            'Meniň ätiýaçlandyryşym bar',
            'ay hev in-shu-rans',
          ),
          PPh(
            'Сколько стоит приём?',
            'How much is the visit?',
            'Kabul näçe durýar?',
            'hau mach iz de vi-zit',
          ),
          PPh(
            'Дайте справку',
            'Give a certificate',
            'Güwanama beriň',
            'giv a ser-ti-fi-ket',
          ),
          PPh(
            'Где оплатить?',
            'Where to pay?',
            'Nirede tölemeli?',
            'wer tu pay',
          ),
        ],
      ),
    ],
  ),
  // 28
  PCat(
    Icons.sick_rounded,
    'Симптомы и боль',
    'Symptoms & Pain',
    'Alamatlar we agyry',
    [
      PSub(Icons.sick_rounded, 'Симптомы', 'Symptoms', 'Alamatlar', [
        PPh('Мне плохо', 'I feel sick', 'Ýagdaýym erbet', 'ay feel sik'),
        PPh(
          'Болит голова',
          'I have a headache',
          'Kelläm agyrýar',
          'ay hev a hed-eyk',
        ),
        PPh(
          'У меня температура',
          'I have a fever',
          'Gyzgynam bar',
          'ay hev a fee-ver',
        ),
        PPh(
          'Болит живот',
          'My stomach hurts',
          'Garnym agyrýar',
          'may sta-mak hurts',
        ),
      ]),
      PSub(Icons.medical_services_rounded, 'Описание', 'Describing', 'Beýan', [
        PPh('Я простудился', 'I have a cold', 'Sowukladym', 'ay hev a kold'),
        PPh(
          'Болит горло',
          'My throat hurts',
          'Bokurdagym agyrýar',
          'may throt hurts',
        ),
        PPh(
          'Меня тошнит',
          'I feel nauseous',
          'Ýürek bulanýar',
          'ay feel no-shes',
        ),
        PPh('Я порезался', 'I cut myself', 'Men kesildim', 'ay kat may-self'),
      ]),
      PSub(Icons.personal_injury_rounded, 'Травмы', 'Injuries', 'Şikesler', [
        PPh('Я поранился', 'I am injured', 'Men şikeslendim', 'ay em in-jerd'),
        PPh('Кровь идёт', 'It is bleeding', 'Gan akýar', 'it iz blee-ding'),
        PPh('Сломал руку', 'I broke my arm', 'Elimi döwdüm', 'ay brok may arm'),
        PPh('Ожог', 'A burn', 'Ýanma', 'a bern'),
        PPh(
          'Нужна повязка',
          'I need a bandage',
          'Maňa sargy gerek',
          'ay need a ban-dij',
        ),
      ]),
    ],
  ),
  // 29
  PCat(
    Icons.emergency_rounded,
    'Экстренная помощь',
    'Emergency help',
    'Gyssagly kömek',
    [
      PSub(
        Icons.emergency_rounded,
        'Зов о помощи',
        'Calling help',
        'Kömek çagyrmak',
        [
          PPh('Помогите!', 'Help!', 'Kömek ediň!', 'help'),
          PPh(
            'Вызовите скорую',
            'Call an ambulance',
            'Tiz kömek çagyryň',
            'kol en am-byu-lens',
          ),
          PPh(
            'Вызовите врача',
            'Call a doctor',
            'Lukman çagyryň',
            'kol a dok-ter',
          ),
          PPh(
            'Он без сознания',
            'He is unconscious',
            'Ol huşsuz',
            'hi iz an-kon-shes',
          ),
        ],
      ),
      PSub(Icons.local_fire_department_rounded, 'Опасность', 'Danger', 'Howp', [
        PPh('Пожар!', 'Fire!', 'Ýangyn!', 'fayr'),
        PPh('Осторожно!', 'Careful!', 'Ägä boluň!', 'ker-ful'),
        PPh('Не трогайте', 'Do not touch', 'Degmäň', 'du not tach'),
        PPh(
          'Уйдите оттуда',
          'Get out of there',
          'O ýerden çykyň',
          'get aut ov der',
        ),
      ]),
    ],
  ),
  // 30
  PCat(
    Icons.gavel_rounded,
    'Полиция и документы',
    'Police & Documents',
    'Polisiýa we resminama',
    [
      PSub(Icons.gavel_rounded, 'Полиция', 'Police', 'Polisiýa', [
        PPh(
          'Где полиция?',
          'Where is the police?',
          'Polisiýa nirede?',
          'wer iz de po-lees',
        ),
        PPh('Меня обокрали', 'I was robbed', 'Meni ogurladylar', 'ay woz robd'),
        PPh(
          'Я потерял паспорт',
          'I lost my passport',
          'Pasportymy ýitirdim',
          'ay lost may pas-port',
        ),
        PPh(
          'Мне нужна помощь',
          'I need help',
          'Maňa kömek gerek',
          'ay need help',
        ),
      ]),
      PSub(
        Icons.description_rounded,
        'Документы',
        'Documents',
        'Resminamalar',
        [
          PPh(
            'Покажите документы',
            'Show your documents',
            'Resminamalaryňyzy görkeziň',
            'sho yor do-kyu-ments',
          ),
          PPh(
            'Вот мой паспорт',
            'Here is my passport',
            'Ine meniň pasportym',
            'heer iz may pas-port',
          ),
          PPh('Я турист', 'I am a tourist', 'Men turist', 'ay em a tu-rist'),
          PPh(
            'Где посольство?',
            'Where is the embassy?',
            'Ilçihana nirede?',
            'wer iz de em-ba-si',
          ),
        ],
      ),
    ],
  ),
  // 31
  PCat(
    Icons.thunderstorm_rounded,
    'Пожар и стихия',
    'Fire & Disaster',
    'Ýangyn we betbagtçylyk',
    [
      PSub(Icons.thunderstorm_rounded, 'Стихия', 'Disaster', 'Betbagtçylyk', [
        PPh('Землетрясение', 'Earthquake', 'Ýer titremesi', 'erth-kweyk'),
        PPh('Наводнение', 'Flood', 'Suw joşmasy', 'flad'),
        PPh('Сильный ветер', 'Strong wind', 'Güýçli şemal', 'strong wind'),
        PPh('Гроза', 'Thunderstorm', 'Gök gümmürdisi', 'than-der-storm'),
      ]),
      PSub(
        Icons.safety_divider_rounded,
        'Эвакуация',
        'Evacuation',
        'Ewakuasiýa',
        [
          PPh(
            'Где выход?',
            'Where is the exit?',
            'Çykalga nirede?',
            'wer iz de eg-zit',
          ),
          PPh('Идите спокойно', 'Go calmly', 'Asuda gidiberiň', 'go kam-li'),
          PPh(
            'Все наружу',
            'Everybody outside',
            'Hemmesi daşaryk',
            'ev-ri-bo-di aut-sayd',
          ),
          PPh(
            'Помогите детям',
            'Help the children',
            'Çagalara kömek ediň',
            'help de chil-dren',
          ),
        ],
      ),
    ],
  ),
  // 32
  PCat(
    Icons.explore_rounded,
    'Ориентирование в городе',
    'City directions',
    'Şäher ugry',
    [
      PSub(
        Icons.explore_rounded,
        'Как пройти',
        'Asking the way',
        'Ýol soramak',
        [
          PPh(
            'Как пройти к …?',
            'How do I get to …?',
            '… nädip gitmeli?',
            'hau du ay get tu',
          ),
          PPh('Это далеко?', 'Is it far?', 'Bu uzakmy?', 'iz it far'),
          PPh('Налево / направо', 'Left / right', 'Çepe / saga', 'left / rayt'),
          PPh('Прямо', 'Straight ahead', 'Göni', 'streyt a-hed'),
        ],
      ),
      PSub(Icons.place_rounded, 'Места', 'Places', 'Ýerler', [
        PPh(
          'Где туалет?',
          'Where is the toilet?',
          'Hajathana nirede?',
          'wer iz de toy-let',
        ),
        PPh(
          'Где банкомат?',
          'Where is the ATM?',
          'Bankomat nirede?',
          'wer iz de ey-ti-em',
        ),
        PPh(
          'Где аптека?',
          'Where is the pharmacy?',
          'Dermanhana nirede?',
          'wer iz de far-ma-si',
        ),
        PPh(
          'Где центр?',
          'Where is the center?',
          'Merkez nirede?',
          'wer iz de sen-ter',
        ),
      ]),
      PSub(Icons.near_me_rounded, 'Расстояния', 'Distances', 'Aralyklar', [
        PPh('Рядом', 'Nearby', 'Ýakyn', 'nier-bay'),
        PPh('Далеко', 'Far', 'Uzak', 'far'),
        PPh(
          'За углом',
          'Around the corner',
          'Burçuň aňyrsynda',
          'a-raund de kor-ner',
        ),
        PPh('Напротив', 'Opposite', 'Garşysynda', 'o-po-zit'),
        PPh('Между', 'Between', 'Arasynda', 'bi-tween'),
      ]),
    ],
  ),
  // 33
  PCat(
    Icons.map_rounded,
    'Карта и навигация',
    'Map & Navigation',
    'Karta we nawigasiýa',
    [
      PSub(Icons.map_rounded, 'Карта', 'Map', 'Karta', [
        PPh(
          'Покажите на карте',
          'Show me on the map',
          'Kartada görkeziň',
          'sho mee on de map',
        ),
        PPh(
          'Где я сейчас?',
          'Where am I now?',
          'Men häzir nirede?',
          'wer em ay nau',
        ),
        PPh(
          'Дайте карту',
          'Give me a map',
          'Maňa karta beriň',
          'giv mee a map',
        ),
        PPh('Масштаб крупнее', 'Zoom in', 'Ulaldyň', 'zum in'),
      ]),
      PSub(Icons.navigation_rounded, 'Навигация', 'Navigation', 'Nawigasiýa', [
        PPh('Ведите меня', 'Navigate me', 'Meni ugrukdyryň', 'na-vi-geyt mee'),
        PPh(
          'Сколько метров?',
          'How many meters?',
          'Näçe metr?',
          'hau me-ni mee-ters',
        ),
        PPh(
          'Я сбился с пути',
          'I went off route',
          'Men ýoldan azaşdym',
          'ay went of rut',
        ),
        PPh('Вернитесь назад', 'Go back', 'Yza gaýdyň', 'go bak'),
      ]),
    ],
  ),
  // 34
  PCat(
    Icons.schedule_rounded,
    'Время и расписание',
    'Time & Schedule',
    'Wagt we tertip',
    [
      PSub(Icons.schedule_rounded, 'Время', 'Time', 'Wagt', [
        PPh(
          'Который час?',
          'What time is it?',
          'Sagat näçe?',
          'wot taym iz it',
        ),
        PPh('Мы опаздываем', 'We are late', 'Biz gijikýäris', 'wi ar leyt'),
        PPh('Рано утром', 'Early morning', 'Ir ertir', 'er-li mor-ning'),
        PPh('Поздно вечером', 'Late evening', 'Giç agşam', 'leyt ee-ving'),
      ]),
      PSub(Icons.event_note_rounded, 'Расписание', 'Schedule', 'Tertip', [
        PPh(
          'Когда открывается?',
          'When does it open?',
          'Haçan açylýar?',
          'wen daz it o-pen',
        ),
        PPh(
          'Когда закрывается?',
          'When does it close?',
          'Haçan ýapylýar?',
          'wen daz it kloz',
        ),
        PPh(
          'Обеденный перерыв?',
          'Lunch break?',
          'Nahar arasy barmy?',
          'lanch breyk',
        ),
        PPh('По воскресеньям?', 'On Sundays?', 'Ýekşenbelermi?', 'on san-deys'),
      ]),
    ],
  ),
  // 35
  PCat(
    Icons.calendar_month_rounded,
    'Дни, месяцы, сезоны',
    'Days & Seasons',
    'Günler we pasyllar',
    [
      PSub(Icons.calendar_month_rounded, 'Дни', 'Days', 'Günler', [
        PPh('Сегодня', 'Today', 'Şu gün', 'tu-dey'),
        PPh('Завтра', 'Tomorrow', 'Ertir', 'tu-mo-ro'),
        PPh('Вчера', 'Yesterday', 'Düýn', 'yes-ter-dey'),
        PPh('В какой день?', 'Which day?', 'Haýsy gün?', 'wich dey'),
      ]),
      PSub(Icons.wb_sunny_rounded, 'Сезоны', 'Seasons', 'Pasyllar', [
        PPh('Весна', 'Spring', 'Ýaz', 'spring'),
        PPh('Лето', 'Summer', 'Tomus', 'sa-mer'),
        PPh('Осень', 'Autumn', 'Güýz', 'o-tam'),
        PPh('Зима', 'Winter', 'Gyş', 'win-ter'),
      ]),
    ],
  ),
  // 36
  PCat(Icons.cloud_rounded, 'Погода', 'Weather', 'Howa', [
    PSub(Icons.cloud_rounded, 'О погоде', 'About weather', 'Howa barada', [
      PPh(
        'Какая погода?',
        'What is the weather?',
        'Howa nähili?',
        'wot iz de we-ther',
      ),
      PPh(
        'Сегодня жарко',
        'It is hot today',
        'Şu gün yssy',
        'it iz hot tu-dey',
      ),
      PPh('Будет дождь', 'It will rain', 'Ýagyş ýagar', 'it wil reyn'),
      PPh(
        'Очень ветрено',
        'It is very windy',
        'Örän şemally',
        'it iz ve-ri win-di',
      ),
    ]),
    PSub(Icons.thermostat_rounded, 'Температура', 'Temperature', 'Temperatur', [
      PPh(
        'Сколько градусов?',
        'How many degrees?',
        'Näçe gradus?',
        'hau me-ni di-grees',
      ),
      PPh('Холодно', 'It is cold', 'Sowuk', 'it iz kold'),
      PPh('Тепло', 'It is warm', 'Ýyly', 'it iz worm'),
      PPh('Душно', 'It is stuffy', 'Buggy', 'it iz sta-fi'),
    ]),
    PSub(Icons.calendar_view_week_rounded, 'Прогноз', 'Forecast', 'Çaklama', [
      PPh(
        'Какой прогноз?',
        'What is the forecast?',
        'Çaklama nähili?',
        'wot iz de fo-re-kast',
      ),
      PPh(
        'Завтра солнечно',
        'Sunny tomorrow',
        'Ertir güneşli',
        'sa-ni tu-mo-ro',
      ),
      PPh(
        'Будет холодать',
        'It will get colder',
        'Sowar',
        'it wil get kol-der',
      ),
      PPh(
        'Ожидается шторм',
        'Storm expected',
        'Tupan garaşylýar',
        'storm iks-pek-ted',
      ),
      PPh('Влажно', 'It is humid', 'Çygly', 'it iz hyu-mid'),
    ]),
  ]),
  // 37
  PCat(
    Icons.sentiment_satisfied_rounded,
    'Чувства и эмоции',
    'Feelings',
    'Duýgular',
    [
      PSub(Icons.sentiment_satisfied_rounded, 'Хорошо', 'Good', 'Gowy', [
        PPh('Я рад', 'I am happy', 'Men şat', 'ay em ha-pi'),
        PPh(
          'Мне весело',
          'I am having fun',
          'Maňa gyzykly',
          'ay em ha-ving fan',
        ),
        PPh('Я спокоен', 'I am calm', 'Men asuda', 'ay em kam'),
        PPh('Я доволен', 'I am satisfied', 'Men razy', 'ay em sa-tis-fayd'),
      ]),
      PSub(Icons.sentiment_dissatisfied_rounded, 'Плохо', 'Bad', 'Erbet', [
        PPh('Я устал', 'I am tired', 'Men ýadadym', 'ay em tay-erd'),
        PPh('Я грущу', 'I am sad', 'Men gamgyn', 'ay em sad'),
        PPh('Я злюсь', 'I am angry', 'Men gaharly', 'ay em ang-gri'),
        PPh('Я боюсь', 'I am afraid', 'Men gorkýaryn', 'ay em a-freyd'),
      ]),
    ],
  ),
  // 38
  PCat(Icons.psychology_rounded, 'Характер человека', 'Character', 'Häsiýet', [
    PSub(Icons.psychology_rounded, 'Качества', 'Traits', 'Sypatlar', [
      PPh('Добрый', 'Kind', 'Mähriban', 'kaynd'),
      PPh('Умный', 'Smart', 'Akylly', 'smart'),
      PPh('Смелый', 'Brave', 'Batyr', 'breiv'),
      PPh('Честный', 'Honest', 'Çynlakaý', 'o-nest'),
    ]),
    PSub(Icons.mood_bad_rounded, 'Негатив', 'Negative', 'Otrisatel', [
      PPh('Злой', 'Angry', 'Gaharjaň', 'ang-gri'),
      PPh('Жадный', 'Greedy', 'Harsy', 'gree-di'),
      PPh('Ленивый', 'Lazy', 'Ýaltaň', 'ley-zi'),
      PPh('Грубый', 'Rude', 'Gödek', 'rud'),
    ]),
  ]),
  // 39
  PCat(Icons.face_rounded, 'Внешность', 'Appearance', 'Daşky keşp', [
    PSub(Icons.face_rounded, 'Лицо', 'Face', 'Ýüz', [
      PPh('Глаза', 'Eyes', 'Gözler', 'ayz'),
      PPh('Волосы', 'Hair', 'Saç', 'her'),
      PPh('Улыбка', 'Smile', 'Gülki', 'smayl'),
      PPh('Борода', 'Beard', 'Sakgal', 'beerd'),
    ]),
    PSub(
      Icons.straighten_rounded,
      'Рост и тело',
      'Height & Body',
      'Boý we beden',
      [
        PPh('Высокий / низкий', 'Tall / short', 'Uzyn / gysga', 'tol / short'),
        PPh('Худой / полный', 'Thin / fat', 'Ýuka / semiz', 'thin / fat'),
        PPh('Молодой / старый', 'Young / old', 'Ýaş / gary', 'yang / old'),
        PPh('Красивый', 'Beautiful', 'Owadan', 'byu-ti-ful'),
      ],
    ),
  ]),
  // 40
  PCat(
    Icons.work_rounded,
    'Работа и собеседование',
    'Work & Interview',
    'Iş we söhbetdeşlik',
    [
      PSub(Icons.work_rounded, 'Работа', 'Work', 'Iş', [
        PPh(
          'Я ищу работу',
          'I am looking for a job',
          'Men iş gözleýärin',
          'ay em lu-king for a job',
        ),
        PPh(
          'Какой опыт?',
          'What experience?',
          'Haýsy tejribe?',
          'wot iks-pi-ri-ens',
        ),
        PPh(
          'Где вы работаете?',
          'Where do you work?',
          'Nirede işleýärsiňiz?',
          'wer du yu werk',
        ),
        PPh(
          'Моя профессия …',
          'My profession is …',
          'Meniň hünärim …',
          'may pro-fe-shen iz',
        ),
      ]),
      PSub(
        Icons.handshake_rounded,
        'Собеседование',
        'Interview',
        'Söhbetdeşlik',
        [
          PPh(
            'Когда встреча?',
            'When is the meeting?',
            'Duşuşyk haçan?',
            'wen iz de mee-ting',
          ),
          PPh(
            'Расскажите о себе',
            'Tell about yourself',
            'Özüňiz barada aýdyň',
            'tel a-baut yor-self',
          ),
          PPh(
            'Какая зарплата?',
            'What is the salary?',
            'Aýlyk näçe?',
            'wot iz de sa-la-ri',
          ),
          PPh(
            'Спасибо за время',
            'Thanks for your time',
            'Wagtyňyz üçin sag boluň',
            'thenks for yor taym',
          ),
        ],
      ),
    ],
  ),
  // 41
  PCat(
    Icons.business_center_rounded,
    'Бизнес и встречи',
    'Business & Meetings',
    'Biznes we duşuşyk',
    [
      PSub(Icons.business_center_rounded, 'Встреча', 'Meeting', 'Duşuşyk', [
        PPh(
          'У меня встреча',
          'I have a meeting',
          'Meniň duşuşygym bar',
          'ay hev a mee-ting',
        ),
        PPh(
          'Давайте обсудим',
          'Let us discuss',
          'Geliň, maslahatlaşalyň',
          'let as dis-kas',
        ),
        PPh(
          'Подпишите здесь',
          'Sign here, please',
          'Şu ýerde gol çekiň',
          'sayn heer pleez',
        ),
        PPh(
          'Отправьте по почте',
          'Send by email',
          'E-poçta iberiň',
          'send bay ee-meyl',
        ),
      ]),
      PSub(Icons.handshake_rounded, 'Сделка', 'Deal', 'Şertnama', [
        PPh('Согласны?', 'Do you agree?', 'Razylaşýarsyňyzmy?', 'du yu a-gree'),
        PPh(
          'Подготовим контракт',
          'Prepare the contract',
          'Şertnamany taýýarlalyň',
          'pri-per de kon-trakt',
        ),
        PPh(
          'Когда срок?',
          'What is the deadline?',
          'Möhlet haçan?',
          'wot iz de ded-layn',
        ),
        PPh(
          'Приятно работать',
          'Nice to work together',
          'Bile işleşmek ýakymly',
          'nays tu werk tu-ge-ther',
        ),
      ]),
    ],
  ),
  // 42
  PCat(
    Icons.school_rounded,
    'Учёба и школа',
    'Study & School',
    'Okuw we mekdep',
    [
      PSub(Icons.school_rounded, 'Школа', 'School', 'Mekdep', [
        PPh('Я студент', 'I am a student', 'Men talyp', 'ay em a styu-dent'),
        PPh('Какой предмет?', 'Which subject?', 'Haýsy ders?', 'wich sab-jekt'),
        PPh(
          'Где библиотека?',
          'Where is the library?',
          'Kitaphana nirede?',
          'wer iz de lay-bre-ri',
        ),
        PPh(
          'Когда экзамен?',
          'When is the exam?',
          'Synag haçan?',
          'wen iz de ig-zam',
        ),
      ]),
      PSub(Icons.menu_book_rounded, 'Учёба', 'Studying', 'Okamak', [
        PPh(
          'Я учу язык',
          'I learn a language',
          'Men dil öwrenýärin',
          'ay lern a lang-gwij',
        ),
        PPh('Это трудно', 'It is difficult', 'Bu kyn', 'it iz di-fi-kelt'),
        PPh('Это легко', 'It is easy', 'Bu aňsat', 'it iz ee-zi'),
        PPh(
          'Повторите, пожалуйста',
          'Repeat, please',
          'Gaýtalaň',
          'ri-peet pleez',
        ),
      ]),
    ],
  ),
  // 43
  PCat(
    Icons.account_balance_rounded,
    'Банк и деньги',
    'Bank & Money',
    'Bank we pul',
    [
      PSub(Icons.account_balance_rounded, 'Обмен', 'Exchange', 'Çalşyk', [
        PPh(
          'Где обмен валюты?',
          'Where is the exchange?',
          'Walýuta çalşygy nirede?',
          'wer iz de iks-cheynj',
        ),
        PPh(
          'Обменяю доллары',
          'I change dollars',
          'Dollar çalşýaryn',
          'ay cheynj do-lers',
        ),
        PPh('Какой курс?', 'What is the rate?', 'Kurs näçe?', 'wot iz de reyt'),
        PPh(
          'Без комиссии?',
          'No commission?',
          'Komissiýasyzmy?',
          'no ko-mi-shen',
        ),
      ]),
      PSub(Icons.credit_card_rounded, 'Счёт', 'Account', 'Hasap', [
        PPh(
          'Открою счёт',
          'I open an account',
          'Hasap açaryn',
          'ay o-pen en a-kaunt',
        ),
        PPh(
          'Сниму наличные',
          'I withdraw cash',
          'Nagt alaryn',
          'ay with-dro kesh',
        ),
        PPh(
          'Где банкомат?',
          'Where is the ATM?',
          'Bankomat nirede?',
          'wer iz de ey-ti-em',
        ),
        PPh(
          'Перевод денег',
          'Money transfer',
          'Pul geçirmek',
          'ma-ni trans-fer',
        ),
      ]),
      PSub(Icons.credit_score_rounded, 'Карты', 'Cards', 'Kartlar', [
        PPh(
          'Карта не работает',
          'Card does not work',
          'Kart işlemeýär',
          'kard daz not werk',
        ),
        PPh(
          'Заблокировать карту',
          'Block my card',
          'Kartymy petikle',
          'blok may kard',
        ),
        PPh('ПИН-код', 'PIN code', 'PIN kod', 'pin kod'),
        PPh('Бесконтактно', 'Contactless', 'Galtaşyksyz', 'kon-takt-les'),
        PPh('Лимит', 'Limit', 'Çäk', 'li-mit'),
      ]),
    ],
  ),
  // 44
  PCat(
    Icons.wifi_rounded,
    'Связь и интернет',
    'Connection & Internet',
    'Aragatnaşyk we internet',
    [
      PSub(Icons.wifi_rounded, 'Интернет', 'Internet', 'Internet', [
        PPh(
          'Пароль от Wi-Fi?',
          'Wi-Fi password?',
          'Wi-Fi paroly?',
          'way-fay pas-werd',
        ),
        PPh(
          'Интернет медленный',
          'Internet is slow',
          'Internet haýal',
          'in-ter-net iz slo',
        ),
        PPh('Нет связи', 'No signal', 'Aragatnaşyk ýok', 'no sig-nal'),
        PPh(
          'Где розетка?',
          'Where is the socket?',
          'Rozetka nirede?',
          'wer iz de so-ket',
        ),
      ]),
      PSub(Icons.sim_card_rounded, 'SIM-карта', 'SIM card', 'SIM-karta', [
        PPh(
          'Где купить SIM?',
          'Where to buy a SIM?',
          'SIM nireden almaly?',
          'wer tu bay a sim',
        ),
        PPh(
          'Сколько стоит?',
          'How much is it?',
          'Näçe durýar?',
          'hau mach iz it',
        ),
        PPh('На месяц', 'For one month', 'Bir aýlyk', 'for wan manth'),
        PPh('С интернетом', 'With internet', 'Internetli', 'with in-ter-net'),
      ]),
    ],
  ),
  // 45
  PCat(
    Icons.phone_in_talk_rounded,
    'Соцсети и телефон',
    'Social & Phone',
    'Sosial we telefon',
    [
      PSub(Icons.phone_in_talk_rounded, 'Звонок', 'Call', 'Jaň', [
        PPh(
          'Можно позвонить?',
          'Can I make a call?',
          'Jaň edip bilerinmi?',
          'ken ay meyk a kol',
        ),
        PPh('Ваш номер?', 'Your number?', 'Belgiňiz näme?', 'yor nam-ber'),
        PPh(
          'Я перезвоню',
          'I will call back',
          'Men gaýtadan jaň ederin',
          'ay wil kol bak',
        ),
        PPh(
          'Не слышно',
          'I cannot hear you',
          'Sizi eşidemok',
          'ay ka-not heer yu',
        ),
      ]),
      PSub(Icons.share_rounded, 'Соцсети', 'Social', 'Sosial', [
        PPh('Добавьте меня', 'Add me', 'Meni goşuň', 'ad mee'),
        PPh(
          'Отправлю фото',
          'I will send a photo',
          'Surat ibererin',
          'ay wil send a fo-to',
        ),
        PPh(
          'Где скачать приложение?',
          'Where to download the app?',
          'Programmany nireden almaly?',
          'wer tu daun-lod de ap',
        ),
        PPh('Подпишитесь', 'Follow me', 'Yzyma ýazylyň', 'fo-lo mee'),
      ]),
    ],
  ),
  // 46
  PCat(
    Icons.movie_rounded,
    'Развлечения и кино',
    'Fun & Cinema',
    'Güýmenje we kino',
    [
      PSub(Icons.movie_rounded, 'Кино', 'Cinema', 'Kino', [
        PPh('Два билета', 'Two tickets', 'Iki bilet', 'tu ti-kits'),
        PPh(
          'Во сколько сеанс?',
          'What time is the show?',
          'Seans sagat näçede?',
          'wot taym iz de sho',
        ),
        PPh('Где зал?', 'Where is the hall?', 'Zal nirede?', 'wer iz de hol'),
        PPh(
          'С субтитрами?',
          'With subtitles?',
          'Subtitrli?',
          'with sab-tay-tels',
        ),
      ]),
      PSub(Icons.music_note_rounded, 'Музыка', 'Music', 'Saz', [
        PPh(
          'Где концерт?',
          'Where is the concert?',
          'Konsert nirede?',
          'wer iz de kon-sert',
        ),
        PPh('Какая музыка?', 'What music?', 'Haýsy saz?', 'wot myu-zik'),
        PPh('Громко', 'Too loud', 'Örän gaty', 'tu lawd'),
        PPh('Мне нравится', 'I like it', 'Maňa ýaraýar', 'ay layk it'),
      ]),
    ],
  ),
  // 47
  PCat(Icons.sports_soccer_rounded, 'Спорт', 'Sports', 'Sport', [
    PSub(Icons.sports_soccer_rounded, 'Игра', 'Game', 'Oýun', [
      PPh(
        'Где стадион?',
        'Where is the stadium?',
        'Stadion nirede?',
        'wer iz de stey-di-em',
      ),
      PPh('Кто выиграл?', 'Who won?', 'Kim ýeňdi?', 'hu won'),
      PPh(
        'Какой счёт?',
        'What is the score?',
        'Hasap nähili?',
        'wot iz de skor',
      ),
      PPh('Давайте играть', 'Let us play', 'Geliň, oýnalyň', 'let as play'),
    ]),
    PSub(
      Icons.fitness_center_rounded,
      'Тренировка',
      'Training',
      'Türgenleşik',
      [
        PPh(
          'Где спортзал?',
          'Where is the gym?',
          'Sport zaly nirede?',
          'wer iz de jim',
        ),
        PPh('Я бегаю', 'I run', 'Men ylgayaryn', 'ay ran'),
        PPh(
          'Бассейн есть?',
          'Is there a pool?',
          'Basseýn barmy?',
          'iz der a pul',
        ),
        PPh('Мяч', 'A ball', 'Töp', 'a bol'),
      ],
    ),
  ]),
  // 48
  PCat(
    Icons.beach_access_rounded,
    'Пляж и море',
    'Beach & Sea',
    'Kenaryýaka we deňiz',
    [
      PSub(Icons.beach_access_rounded, 'Пляж', 'Beach', 'Kenaryýaka', [
        PPh(
          'Где пляж?',
          'Where is the beach?',
          'Kenaryýaka nirede?',
          'wer iz de beech',
        ),
        PPh(
          'Лежак свободен?',
          'Is the sunbed free?',
          'Ýatyş ýeri boşmy?',
          'iz de san-bed free',
        ),
        PPh(
          'Зонт нужен',
          'I need an umbrella',
          'Maňa saýawan gerek',
          'ay need en am-bre-la',
        ),
        PPh(
          'Где душ?',
          'Where is the shower?',
          'Hammam nirede?',
          'wer iz de shau-er',
        ),
      ]),
      PSub(Icons.waves_rounded, 'Море', 'Sea', 'Deňiz', [
        PPh(
          'Вода тёплая',
          'The water is warm',
          'Suw ýyly',
          'de wo-ter iz worm',
        ),
        PPh(
          'Глубоко здесь?',
          'Is it deep here?',
          'Bu ýer çuňmy?',
          'iz it deep heer',
        ),
        PPh(
          'Опасно купаться?',
          'Is it safe to swim?',
          'Ýüzmek howpsuzmy?',
          'iz it seyf tu swim',
        ),
        PPh(
          'Сильные волны',
          'Strong waves',
          'Güýçli tolkunlar',
          'strong weyvs',
        ),
      ]),
    ],
  ),
  // 49
  PCat(
    Icons.park_rounded,
    'Природа и животные',
    'Nature & Animals',
    'Tebigat we haýwanlar',
    [
      PSub(Icons.park_rounded, 'Природа', 'Nature', 'Tebigat', [
        PPh('Гора', 'Mountain', 'Dag', 'maun-tin'),
        PPh('Река', 'River', 'Derýa', 'ri-ver'),
        PPh('Лес', 'Forest', 'Tokaý', 'fo-rest'),
        PPh('Озеро', 'Lake', 'Köl', 'leyk'),
      ]),
      PSub(Icons.pets_rounded, 'Животные', 'Animals', 'Haýwanlar', [
        PPh('Собака', 'Dog', 'It', 'dog'),
        PPh('Кошка', 'Cat', 'Pişik', 'kat'),
        PPh('Лошадь', 'Horse', 'At', 'hors'),
        PPh('Птица', 'Bird', 'Guş', 'berd'),
      ]),
      PSub(
        Icons.pets_rounded,
        'Дикие животные',
        'Wild animals',
        'Ýabany haýwanlar',
        [
          PPh('Волк', 'Wolf', 'Böri', 'wulf'),
          PPh('Лиса', 'Fox', 'Tülki', 'foks'),
          PPh('Медведь', 'Bear', 'Aýy', 'ber'),
          PPh('Заяц', 'Hare', 'Towşan', 'her'),
          PPh('Орёл', 'Eagle', 'Bürgüt', 'ee-gel'),
        ],
      ),
    ],
  ),
  // 50
  PCat(
    Icons.celebration_rounded,
    'Праздники и поздравления',
    'Holidays & Wishes',
    'Baýram we gutlag',
    [
      PSub(Icons.celebration_rounded, 'Поздравления', 'Wishes', 'Gutlag', [
        PPh(
          'С днём рождения!',
          'Happy birthday!',
          'Doglan günüňiz gutly bolsun!',
          'ha-pi berth-dey',
        ),
        PPh(
          'С новым годом!',
          'Happy new year!',
          'Täze ýylyňyz gutly bolsun!',
          'ha-pi nyu yir',
        ),
        PPh(
          'Поздравляю!',
          'Congratulations!',
          'Gutlaýaryn!',
          'kon-gra-chu-ley-shens',
        ),
        PPh(
          'Всего хорошего!',
          'All the best!',
          'Hemmesi gowy bolsun!',
          'ol de best',
        ),
      ]),
      PSub(Icons.card_giftcard_rounded, 'Подарки', 'Gifts', 'Sowgat', [
        PPh('Это тебе', 'This is for you', 'Bu saňa', 'dis iz for yu'),
        PPh(
          'Спасибо за подарок',
          'Thanks for the gift',
          'Sowgat üçin sag bol',
          'thenks for de gift',
        ),
        PPh('С любовью', 'With love', 'Söýgi bilen', 'with lav'),
        PPh('Открой', 'Open it', 'Aç', 'o-pen it'),
      ]),
    ],
  ),
  // 51
  PCat(
    Icons.help_outline_rounded,
    'Вопросы и основы',
    'Basics & Questions',
    'Soraglar we esaslar',
    [
      PSub(
        Icons.help_rounded,
        'Основные вопросы',
        'Basic questions',
        'Esasy soraglar',
        [
          PPh('Что это?', 'What is this?', 'Bu näme?', 'wot iz dis'),
          PPh('Кто это?', 'Who is this?', 'Bu kim?', 'hu iz dis'),
          PPh('Где?', 'Where?', 'Nirede?', 'wer'),
          PPh('Когда?', 'When?', 'Haçan?', 'wen'),
          PPh('Почему?', 'Why?', 'Näme üçin?', 'way'),
          PPh('Как?', 'How?', 'Nädip?', 'hau'),
        ],
      ),
      PSub(Icons.check_circle_rounded, 'Да / Нет', 'Yes / No', 'Hawa / Ýok', [
        PPh('Да', 'Yes', 'Hawa', 'yes'),
        PPh('Нет', 'No', 'Ýok', 'no'),
        PPh('Может быть', 'Maybe', 'Belki', 'mey-bi'),
        PPh('Конечно', 'Of course', 'Elbetde', 'ov kors'),
        PPh('Не знаю', 'I do not know', 'Bilemok', 'ay du not no'),
      ]),
    ],
  ),
  // 52
  PCat(
    Icons.thumb_up_rounded,
    'Согласие и отказ',
    'Agreement & Refusal',
    'Razylyk we ýüz öwürme',
    [
      PSub(Icons.thumb_up_rounded, 'Согласие', 'Agreement', 'Razylyk', [
        PPh('Согласен', 'I agree', 'Razy', 'ay a-gree'),
        PPh('Хорошо', 'Okay', 'Bolýar', 'o-key'),
        PPh('Отлично', 'Great', 'Berekella', 'greyt'),
        PPh('Без проблем', 'No problem', 'Mesele ýok', 'no pro-blem'),
      ]),
      PSub(Icons.thumb_down_rounded, 'Отказ', 'Refusal', 'Ýüz öwürme', [
        PPh('Не могу', 'I cannot', 'Bilmeýärin', 'ay ka-not'),
        PPh('Не хочу', 'I do not want', 'Islemeýärin', 'ay du not wont'),
        PPh('Нет, спасибо', 'No, thanks', 'Ýok, sag bol', 'no thenks'),
        PPh('Позже', 'Later', 'Soňra', 'ley-ter'),
      ]),
    ],
  ),
  // 53
  PCat(Icons.pan_tool_rounded, 'Просьбы', 'Requests', 'Haýyşlar', [
    PSub(Icons.pan_tool_rounded, 'Попросить', 'Asking', 'Soramak', [
      PPh('Можно …?', 'Can I …?', '… bolarmy?', 'ken ay'),
      PPh(
        'Помогите мне',
        'Help me, please',
        'Maňa kömek ediň',
        'help mee pleez',
      ),
      PPh('Дайте мне', 'Give me, please', 'Maňa beriň', 'giv mee pleez'),
      PPh('Подождите', 'Wait, please', 'Garaşyň', 'weyt pleez'),
    ]),
    PSub(Icons.lock_open_rounded, 'Разрешение', 'Permission', 'Rugsat', [
      PPh(
        'Можно войти?',
        'May I come in?',
        'Girip bilerinmi?',
        'mey ay kam in',
      ),
      PPh(
        'Можно взять?',
        'May I take it?',
        'Alyp bilerinmi?',
        'mey ay teyk it',
      ),
      PPh('Разрешено?', 'Is it allowed?', 'Rugsatmy?', 'iz it a-laud'),
      PPh('Запрещено', 'It is forbidden', 'Gadagan', 'it iz for-bi-den'),
    ]),
  ]),
  // 54
  PCat(Icons.report_problem_rounded, 'Жалобы', 'Complaints', 'Şikaýatlar', [
    PSub(Icons.report_problem_rounded, 'Жалоба', 'Complaint', 'Şikaýat', [
      PPh(
        'Мне не нравится',
        'I do not like it',
        'Maňa ýaranok',
        'ay du not layk it',
      ),
      PPh('Это неправильно', 'This is wrong', 'Bu nädogry', 'dis iz rong'),
      PPh('Это сломано', 'It is broken', 'Bu döwük', 'it iz bro-ken'),
      PPh(
        'Я недоволен',
        'I am not satisfied',
        'Men razy däl',
        'ay em not sa-tis-fayd',
      ),
    ]),
    PSub(Icons.support_agent_rounded, 'Решение', 'Resolution', 'Çözgüt', [
      PPh(
        'Верните деньги',
        'Refund my money',
        'Pulumy yzyna beriň',
        'ri-fand may ma-ni',
      ),
      PPh('Замените это', 'Replace this', 'Muny çalşyryň', 'ri-pleys dis'),
      PPh(
        'Позовите менеджера',
        'Call the manager',
        'Dolandyryjyny çagyryň',
        'kol de ma-ni-jer',
      ),
      PPh(
        'Хочу пожаловаться',
        'I want to complain',
        'Şikaýat etmek isleýärin',
        'ay wont tu kom-pleyn',
      ),
    ]),
  ]),
  // 55
  PCat(
    Icons.favorite_border_rounded,
    'Комплименты',
    'Compliments',
    'Höweslendirme',
    [
      PSub(Icons.favorite_rounded, 'Похвала', 'Praise', 'Makullama', [
        PPh('Отлично!', 'Excellent!', 'Berekella!', 'ek-se-lent'),
        PPh('Красиво', 'Beautiful', 'Owadan', 'byu-ti-ful'),
        PPh('Вкусно', 'Delicious', 'Tagamly', 'di-li-shes'),
        PPh('Молодец!', 'Well done!', 'Berekella!', 'wel dan'),
      ]),
      PSub(
        Icons.sentiment_very_satisfied_rounded,
        'Дружелюбие',
        'Friendly',
        'Dostluk',
        [
          PPh('Ты добрый', 'You are kind', 'Sen mähriban', 'yu ar kaynd'),
          PPh(
            'Рад видеть',
            'Glad to see you',
            'Seni görenime şat',
            'glad tu see yu',
          ),
          PPh(
            'Ты мне нравишься',
            'I like you',
            'Sen maňa ýaraýarsyň',
            'ay layk yu',
          ),
          PPh(
            'Спасибо за всё',
            'Thanks for everything',
            'Hemmesi üçin sag bol',
            'thenks for ev-ri-ting',
          ),
        ],
      ),
    ],
  ),
  // 56
  PCat(
    Icons.chat_bubble_outline_rounded,
    'Светская беседа',
    'Small talk',
    'Ýeňil gürrüň',
    [
      PSub(
        Icons.chat_bubble_rounded,
        'О жизни',
        'About life',
        'Durmuş barada',
        [
          PPh('Что нового?', 'What is new?', 'Näme täzelik?', 'wot iz nyu'),
          PPh(
            'Как семья?',
            'How is your family?',
            'Maşgalaňyz nähili?',
            'hau iz yor fa-mi-li',
          ),
          PPh(
            'Чем занимаетесь?',
            'What do you do?',
            'Näme işleýärsiňiz?',
            'wot du yu du',
          ),
          PPh('Хорошая погода', 'Nice weather', 'Howa gowy', 'nays we-ther'),
        ],
      ),
      PSub(Icons.interests_rounded, 'Интересы', 'Interests', 'Gyzyklanmalar', [
        PPh(
          'Что любишь?',
          'What do you like?',
          'Näme halaýarsyň?',
          'wot du yu layk',
        ),
        PPh(
          'Я люблю музыку',
          'I like music',
          'Men saz halaýaryn',
          'ay layk myu-zik',
        ),
        PPh(
          'Люблю путешествовать',
          'I like travelling',
          'Men syýahat halaýaryn',
          'ay layk tra-ve-ling',
        ),
        PPh('Свободное время', 'Free time', 'Boş wagt', 'free taym'),
      ]),
    ],
  ),
  // 57
  PCat(Icons.home_work_rounded, 'В гостях', 'Visiting', 'Myhmançylyk', [
    PSub(Icons.door_front_door, 'Приход', 'Arrival', 'Gelmek', [
      PPh(
        'Можно войти?',
        'May I come in?',
        'Girip bilerinmi?',
        'mey ay kam in',
      ),
      PPh(
        'Спасибо за приглашение',
        'Thanks for inviting',
        'Çagyryş üçin sag bol',
        'thenks for in-vay-ting',
      ),
      PPh('Проходите', 'Come in', 'Buyruň', 'kam in'),
      PPh('Садитесь', 'Sit down', 'Oturyň', 'sit daun'),
    ]),
    PSub(Icons.coffee_rounded, 'Угощение', 'Hospitality', 'Myhmansöýerlik', [
      PPh(
        'Хотите чай?',
        'Would you like tea?',
        'Çay isleýärsiňizmi?',
        'wud yu layk tee',
      ),
      PPh('Угощайтесь', 'Help yourself', 'Buyruň, alyň', 'help yor-self'),
      PPh('Ещё?', 'Some more?', 'Ýene?', 'sam mor'),
      PPh(
        'Сыт, спасибо',
        'I am full, thanks',
        'Doydum, sag bol',
        'ay em ful thenks',
      ),
    ]),
  ]),
  // 58
  PCat(Icons.favorite_rounded, 'Свидание', 'Dating', 'Söýgi', [
    PSub(Icons.favorite_rounded, 'Романтика', 'Romance', 'Söýgi', [
      PPh(
        'Ты мне нравишься',
        'I like you',
        'Sen maňa ýaraýarsyň',
        'ay layk yu',
      ),
      PPh(
        'Ты красивый/ая',
        'You are beautiful',
        'Sen owadan',
        'yu ar byu-ti-ful',
      ),
      PPh(
        'Пойдём гулять?',
        'Shall we go for a walk?',
        'Gezelenje gideliňmi?',
        'shal wi go for a wok',
      ),
      PPh('Я скучаю', 'I miss you', 'Men seni küýseýärin', 'ay mis yu'),
    ]),
    PSub(Icons.local_florist_rounded, 'Встреча', 'Date', 'Duşuşyk', [
      PPh(
        'Во сколько встречаемся?',
        'What time shall we meet?',
        'Sagat näçede duşuşaly?',
        'wot taym shal wi meet',
      ),
      PPh(
        'Где встретимся?',
        'Where shall we meet?',
        'Nirede duşuşaly?',
        'wer shal wi meet',
      ),
      PPh('Я приду', 'I will come', 'Men gelerin', 'ay wil kam'),
      PPh('Пока, до встречи', 'Bye, see you', 'Hoş, görüşýänçäk', 'bay see yu'),
    ]),
  ]),
  // 59
  PCat(
    Icons.child_care_rounded,
    'Дети и уход',
    'Kids & Care',
    'Çagalar we ideg',
    [
      PSub(Icons.child_care_rounded, 'Дети', 'Children', 'Çagalar', [
        PPh(
          'Сколько лет ребёнку?',
          'How old is the child?',
          'Çaga näçe ýaşda?',
          'hau old iz de chayld',
        ),
        PPh(
          'Где ребёнок?',
          'Where is the child?',
          'Çaga nirede?',
          'wer iz de chayld',
        ),
        PPh('Он спит', 'He is sleeping', 'Ol uklaýar', 'hi iz slee-ping'),
        PPh(
          'Осторожно, дети',
          'Careful, children',
          'Ägä boluň, çagalar',
          'ker-ful chil-dren',
        ),
      ]),
      PSub(Icons.baby_changing_station_rounded, 'Уход', 'Care', 'Ideg', [
        PPh(
          'Нужен подгузник',
          'Need a diaper',
          'Çaga bezi gerek',
          'need a day-per',
        ),
        PPh(
          'Где молоко?',
          'Where is the milk?',
          'Süt nirede?',
          'wer iz de milk',
        ),
        PPh(
          'Ребёнок плачет',
          'The child is crying',
          'Çaga aglaýar',
          'de chayld iz kray-ing',
        ),
        PPh('Покормить', 'To feed', 'Iýmitlendirmek', 'tu feed'),
      ]),
    ],
  ),
  // 60
  PCat(
    Icons.brush_rounded,
    'Красота и салон',
    'Beauty salon',
    'Gözellik salony',
    [
      PSub(Icons.content_cut_rounded, 'Парикмахер', 'Barber', 'Saç ussasy', [
        PPh(
          'Подстригите',
          'A haircut, please',
          'Saçymy alyň',
          'a her-kat pleez',
        ),
        PPh('Короче', 'Shorter', 'Gysgarak', 'shor-ter'),
        PPh('Немного', 'Not too much', 'Örän däl', 'not tu mach'),
        PPh('Побрейте', 'Shave, please', 'Sakgalymy alyň', 'sheyv pleez'),
      ]),
      PSub(Icons.face_retouching_natural_rounded, 'Салон', 'Salon', 'Salon', [
        PPh('Маникюр', 'Manicure', 'Manikýur', 'ma-ni-kyur'),
        PPh('Макияж', 'Makeup', 'Makiýaž', 'meyk-ap'),
        PPh(
          'Запись на завтра',
          'Appointment tomorrow',
          'Ertire ýazylmak',
          'a-poynt-ment tu-mo-ro',
        ),
        PPh('Сколько стоит?', 'How much?', 'Näçe?', 'hau mach'),
      ]),
    ],
  ),
  // 61
  PCat(
    Icons.plumbing_rounded,
    'Дом и ремонт',
    'Home & Repair',
    'Öý we abatlaýyş',
    [
      PSub(Icons.plumbing_rounded, 'Поломки', 'Repairs', 'Abatlaýyş', [
        PPh(
          'Течёт кран',
          'The tap is leaking',
          'Kran akýar',
          'de tap iz lee-king',
        ),
        PPh('Нет света', 'No electricity', 'Tok ýok', 'no i-lek-tri-si-ti'),
        PPh(
          'Сломался замок',
          'The lock is broken',
          'Gulpy döwük',
          'de lok iz bro-ken',
        ),
        PPh(
          'Вызовите мастера',
          'Call a repairman',
          'Ussa çagyryň',
          'kol a ri-per-man',
        ),
      ]),
      PSub(Icons.chair_rounded, 'Мебель', 'Furniture', 'Mebel', [
        PPh('Стол', 'Table', 'Stol', 'tey-bol'),
        PPh('Стул', 'Chair', 'Stul', 'cher'),
        PPh('Кровать', 'Bed', 'Düşek', 'bed'),
        PPh('Шкаф', 'Wardrobe', 'Şkaf', 'word-rob'),
      ]),
    ],
  ),
  // 62
  PCat(Icons.restaurant_menu_rounded, 'Готовка', 'Cooking', 'Nahar bişirmek', [
    PSub(Icons.restaurant_menu_rounded, 'Кухня', 'Kitchen', 'Aşhana', [
      PPh(
        'Где кухня?',
        'Where is the kitchen?',
        'Aşhana nirede?',
        'wer iz de ki-chen',
      ),
      PPh('Дайте нож', 'Give me a knife', 'Maňa pyçak beriň', 'giv mee a nayf'),
      PPh('Кастрюля', 'Pot', 'Gazan', 'pot'),
      PPh('Сковорода', 'Pan', 'Taba', 'pan'),
    ]),
    PSub(
      Icons.local_fire_department_rounded,
      'Процесс',
      'Process',
      'Bişirmek',
      [
        PPh('Варить', 'To boil', 'Gaýnatmak', 'tu boyl'),
        PPh('Жарить', 'To fry', 'Gyzartmak', 'tu fray'),
        PPh('Резать', 'To cut', 'Dogramak', 'tu kat'),
        PPh('Готово', 'It is ready', 'Taýýar', 'it iz re-di'),
      ],
    ),
  ]),
  // 63
  PCat(Icons.local_laundry_service_rounded, 'Стирка', 'Laundry', 'Ýuwuş', [
    PSub(Icons.local_laundry_service_rounded, 'Стирка', 'Washing', 'Ýuwmak', [
      PPh(
        'Где стирка?',
        'Where is the laundry?',
        'Ýuwuş nirede?',
        'wer iz de lon-dri',
      ),
      PPh('Постирать', 'To wash', 'Ýuwmak', 'tu wosh'),
      PPh('Порошок', 'Detergent', 'Ýuwujy', 'di-ter-jent'),
      PPh('Сушить', 'To dry', 'Guratmak', 'tu dray'),
    ]),
    PSub(Icons.iron_rounded, 'Глажка', 'Ironing', 'Ütükleme', [
      PPh('Погладить', 'To iron', 'Ütüklemek', 'tu ay-ron'),
      PPh('Утюг', 'Iron', 'Ütük', 'ay-ron'),
      PPh('Чистая одежда', 'Clean clothes', 'Arassa eşik', 'kleen klods'),
      PPh('Пятно', 'A stain', 'Tegmil', 'a steyn'),
    ]),
  ]),
  // 64
  PCat(Icons.pets_rounded, 'Питомцы', 'Pets', 'Öý haýwanlary', [
    PSub(Icons.pets_rounded, 'Питомцы', 'Pets', 'Haýwanlar', [
      PPh(
        'У меня есть собака',
        'I have a dog',
        'Meniň itim bar',
        'ay hev a dog',
      ),
      PPh('Кошка', 'Cat', 'Pişik', 'kat'),
      PPh('Корм для собак', 'Dog food', 'It iýmiti', 'dog fud'),
      PPh('Ветеринар', 'Veterinarian', 'Weterinar', 've-te-ri-neri-en'),
    ]),
    PSub(
      Icons.medical_services_rounded,
      'Уход за питомцем',
      'Pet care',
      'Haýwan idegi',
      [
        PPh('Гулять с собакой', 'Walk the dog', 'Iti gezdirmek', 'wok de dog'),
        PPh('Поводок', 'A leash', 'Tasma', 'a leesh'),
        PPh('Он кусается', 'It bites', 'Ol dişleýär', 'it bayts'),
        PPh('Прививка', 'Vaccination', 'Sanjym', 'vak-si-ney-shen'),
      ],
    ),
  ]),
  // 65
  PCat(
    Icons.yard_rounded,
    'Сад и растения',
    'Garden & Plants',
    'Bag we ösümlikler',
    [
      PSub(Icons.yard_rounded, 'Сад', 'Garden', 'Bag', [
        PPh('Цветы', 'Flowers', 'Güller', 'flau-ers'),
        PPh('Дерево', 'Tree', 'Agaç', 'tree'),
        PPh('Трава', 'Grass', 'Ot', 'gras'),
        PPh('Поливать', 'To water', 'Suwarmak', 'tu wo-ter'),
      ]),
      PSub(Icons.spa_rounded, 'Растения', 'Plants', 'Ösümlikler', [
        PPh('Семена', 'Seeds', 'Tohum', 'seeds'),
        PPh('Горшок', 'A pot', 'Küýze', 'a pot'),
        PPh('Почва', 'Soil', 'Toprak', 'soyl'),
        PPh('Солнце', 'Sun', 'Gün', 'san'),
      ]),
    ],
  ),
  // 66
  PCat(
    Icons.car_repair_rounded,
    'Авто: поломки',
    'Car troubles',
    'Maşyn meseleleri',
    [
      PSub(Icons.car_repair_rounded, 'Поломка', 'Breakdown', 'Döwülme', [
        PPh(
          'Машина сломалась',
          'The car broke down',
          'Maşyn döwüldi',
          'de kar brok daun',
        ),
        PPh('Спустило колесо', 'Flat tyre', 'Tigir ýaryldy', 'flat tayr'),
        PPh(
          'Не заводится',
          'It does not start',
          'Işlemeýär',
          'it daz not start',
        ),
        PPh(
          'Нужен механик',
          'I need a mechanic',
          'Maňa mehanik gerek',
          'ay need a me-ka-nik',
        ),
      ]),
      PSub(Icons.build_rounded, 'Помощь', 'Help', 'Kömek', [
        PPh(
          'Вызовите эвакуатор',
          'Call a tow truck',
          'Ewakuator çagyryň',
          'kol a to trak',
        ),
        PPh(
          'Где шиномонтаж?',
          'Where is the tyre shop?',
          'Tigir ussahanasy nirede?',
          'wer iz de tayr shop',
        ),
        PPh('Долейте масло', 'Add oil, please', 'Ýag goşuň', 'ad oyl pleez'),
        PPh(
          'Аккумулятор сел',
          'Battery is dead',
          'Akumulýator öçdi',
          'ba-te-ri iz ded',
        ),
      ]),
    ],
  ),
  // 67
  PCat(
    Icons.directions_boat_rounded,
    'Лодка и паром',
    'Boat & Ferry',
    'Gaýyk we parom',
    [
      PSub(Icons.directions_boat_rounded, 'Паром', 'Ferry', 'Parom', [
        PPh(
          'Где паром?',
          'Where is the ferry?',
          'Parom nirede?',
          'wer iz de fe-ri',
        ),
        PPh(
          'Во сколько отплытие?',
          'What time does it sail?',
          'Sagat näçede gidýär?',
          'wot taym daz it seyl',
        ),
        PPh('Билет на паром', 'Ferry ticket', 'Parom bileti', 'fe-ri ti-kit'),
        PPh(
          'На тот берег',
          'To the other side',
          'Beýleki kenaryna',
          'tu de a-ther sayd',
        ),
      ]),
      PSub(Icons.sailing_rounded, 'Лодка', 'Boat', 'Gaýyk', [
        PPh('Аренда лодки', 'Boat rental', 'Gaýyk kärendesi', 'bot ren-tal'),
        PPh(
          'Спасательный жилет',
          'Life jacket',
          'Halas ediş ýelek',
          'layf ja-kit',
        ),
        PPh('Глубоко', 'It is deep', 'Çuň', 'it iz deep'),
        PPh(
          'Осторожно, волны',
          'Careful, waves',
          'Ägä boluň, tolkun',
          'ker-ful weyvs',
        ),
      ]),
    ],
  ),
  // 68
  PCat(Icons.flight_land_rounded, 'В полёте', 'On the plane', 'Uçarda', [
    PSub(Icons.flight_land_rounded, 'На борту', 'On board', 'Bortda', [
      PPh(
        'Моё место у окна',
        'My seat is by the window',
        'Ýerim penjire ýany',
        'may seet iz bay de win-do',
      ),
      PPh('Дайте воды', 'Some water, please', 'Suw haýyş', 'sam wo-ter pleez'),
      PPh('Мне холодно', 'I am cold', 'Maňa sowuk', 'ay em kold'),
      PPh(
        'Пристегните ремень',
        'Fasten your seatbelt',
        'Howpsuzlyk guşagyny daňyň',
        'fa-sen yor seet-belt',
      ),
    ]),
    PSub(Icons.luggage_rounded, 'Прибытие', 'Arrival', 'Gelmek', [
      PPh('Мы приземлились?', 'Have we landed?', 'Gondukmy?', 'hev wi lan-ded'),
      PPh(
        'Где выход?',
        'Where is the exit?',
        'Çykalga nirede?',
        'wer iz de eg-zit',
      ),
      PPh(
        'Где мой багаж?',
        'Where is my baggage?',
        'Ýüküm nirede?',
        'wer iz may ba-gij',
      ),
      PPh('Долгий полёт', 'Long flight', 'Uzyn uçuş', 'long flayt'),
    ]),
  ]),
  // 69
  PCat(
    Icons.badge_rounded,
    'Паспортный контроль',
    'Passport control',
    'Pasport barlagy',
    [
      PSub(Icons.badge_rounded, 'Контроль', 'Control', 'Barlag', [
        PPh(
          'Вот мой паспорт',
          'Here is my passport',
          'Ine pasportym',
          'heer iz may pas-port',
        ),
        PPh(
          'Цель визита?',
          'Purpose of visit?',
          'Geliş maksady?',
          'per-pes ov vi-zit',
        ),
        PPh('Туризм', 'Tourism', 'Syýahat', 'tu-rizm'),
        PPh('На неделю', 'For one week', 'Bir hepdelik', 'for wan week'),
      ]),
      PSub(Icons.help_rounded, 'Вопросы', 'Questions', 'Soraglar', [
        PPh(
          'Где остановитесь?',
          'Where will you stay?',
          'Nirede galýarsyňyz?',
          'wer wil yu stey',
        ),
        PPh('В отеле', 'At a hotel', 'Myhmanhanada', 'et a ho-tel'),
        PPh(
          'Обратный билет?',
          'Return ticket?',
          'Yzyna bilet barmy?',
          'ri-tern ti-kit',
        ),
        PPh('Сколько денег?', 'How much money?', 'Näçe pul?', 'hau mach ma-ni'),
      ]),
    ],
  ),
  // 70
  PCat(Icons.assignment_rounded, 'Таможня', 'Customs', 'Gümrük', [
    PSub(Icons.assignment_rounded, 'Декларация', 'Declaration', 'Deklarasiýa', [
      PPh(
        'Нечего декларировать',
        'Nothing to declare',
        'Deklarirläp zat ýok',
        'na-ting tu di-klare',
      ),
      PPh('Это подарок', 'It is a gift', 'Bu sowgat', 'it iz a gift'),
      PPh(
        'Для личного пользования',
        'For personal use',
        'Şahsy ulanyş üçin',
        'for per-so-nal yus',
      ),
      PPh('Откройте сумку', 'Open your bag', 'Sumkaňyzy açyň', 'o-pen yor bag'),
    ]),
    PSub(
      Icons.policy_rounded,
      'Ограничения',
      'Restrictions',
      'Çäklendirmeler',
      [
        PPh(
          'Сколько можно ввезти?',
          'How much can I bring?',
          'Näçe getirip bolýar?',
          'hau mach ken ay bring',
        ),
        PPh(
          'Запрещено ввозить',
          'Forbidden to import',
          'Getirmek gadagan',
          'for-bi-den tu im-port',
        ),
        PPh('Пошлина', 'Duty', 'Gümrük paýy', 'dyu-ti'),
        PPh(
          'Где зелёный коридор?',
          'Where is the green channel?',
          'Ýaşyl ýol nirede?',
          'wer iz de green cha-nel',
        ),
      ],
    ),
  ]),
  // 71
  PCat(Icons.engineering_rounded, 'Профессии', 'Professions', 'Hünärler', [
    PSub(Icons.work_rounded, 'Профессии', 'Jobs', 'Işler', [
      PPh('Врач', 'Doctor', 'Lukman', 'dok-ter'),
      PPh('Учитель', 'Teacher', 'Mugallym', 'tee-cher'),
      PPh('Инженер', 'Engineer', 'Inžener', 'en-ji-nir'),
      PPh('Повар', 'Cook', 'Aşpez', 'kuk'),
      PPh('Водитель', 'Driver', 'Sürüji', 'dray-ver'),
    ]),
    PSub(Icons.business_center_rounded, 'Службы', 'Services', 'Gulluklar', [
      PPh(
        'Полицейский',
        'Police officer',
        'Polisiýa işgäri',
        'po-lees o-fi-ser',
      ),
      PPh('Продавец', 'Seller', 'Satyjy', 'se-ler'),
      PPh('Медсестра', 'Nurse', 'Şepagat uýasy', 'ners'),
      PPh('Строитель', 'Builder', 'Gurluşykçy', 'bil-der'),
    ]),
    PSub(
      Icons.computer_rounded,
      'Офис и услуги',
      'Office & Services',
      'Ofis we hyzmatlar',
      [
        PPh('Менеджер', 'Manager', 'Dolandyryjy', 'ma-ni-jer'),
        PPh('Бухгалтер', 'Accountant', 'Hasapçy', 'a-kaun-tant'),
        PPh('Юрист', 'Lawyer', 'Ýurist', 'loy-er'),
        PPh('Парикмахер', 'Hairdresser', 'Saç ussasy', 'her-dre-ser'),
        PPh('Гид', 'Guide', 'Gid', 'gayd'),
      ],
    ),
  ]),
  // 72
  PCat(Icons.category_rounded, 'Материалы', 'Materials', 'Materiallar', [
    PSub(Icons.category_rounded, 'Твёрдые', 'Solid', 'Gaty', [
      PPh('Дерево', 'Wood', 'Agaç', 'wud'),
      PPh('Металл', 'Metal', 'Metal', 'me-tal'),
      PPh('Стекло', 'Glass', 'Aýna', 'glas'),
      PPh('Пластик', 'Plastic', 'Plastik', 'plas-tik'),
    ]),
    PSub(Icons.checkroom_rounded, 'Ткани', 'Fabrics', 'Matalar', [
      PPh('Хлопок', 'Cotton', 'Pagta', 'ko-ton'),
      PPh('Шёлк', 'Silk', 'Ýüpek', 'silk'),
      PPh('Шерсть', 'Wool', 'Ýüň', 'wul'),
      PPh('Кожа', 'Leather', 'Deri', 'le-ther'),
    ]),
  ]),
  // 73
  PCat(Icons.hexagon_rounded, 'Формы', 'Shapes', 'Şekiller', [
    PSub(Icons.circle_rounded, 'Фигуры', 'Figures', 'Şekiller', [
      PPh('Круг', 'Circle', 'Töwerek', 'ser-kel'),
      PPh('Квадрат', 'Square', 'Kwadrat', 'skwer'),
      PPh('Треугольник', 'Triangle', 'Üçburçluk', 'tray-an-gel'),
      PPh('Линия', 'Line', 'Çyzyk', 'layn'),
    ]),
    PSub(Icons.straighten_rounded, 'Размер', 'Size', 'Ölçeg', [
      PPh('Большой', 'Big', 'Uly', 'big'),
      PPh('Маленький', 'Small', 'Kiçi', 'smol'),
      PPh('Длинный', 'Long', 'Uzyn', 'long'),
      PPh('Короткий', 'Short', 'Gysga', 'short'),
    ]),
  ]),
  // 74
  PCat(Icons.scale_rounded, 'Меры и веса', 'Measurements', 'Ölçegler', [
    PSub(Icons.scale_rounded, 'Вес', 'Weight', 'Agram', [
      PPh('Килограмм', 'Kilogram', 'Kilogram', 'ki-lo-gram'),
      PPh('Грамм', 'Gram', 'Gram', 'gram'),
      PPh('Тяжёлый', 'Heavy', 'Agyr', 'he-vi'),
      PPh('Лёгкий', 'Light', 'Ýeňil', 'layt'),
    ]),
    PSub(Icons.straighten_rounded, 'Длина', 'Length', 'Uzynlyk', [
      PPh('Метр', 'Meter', 'Metr', 'mee-ter'),
      PPh('Сантиметр', 'Centimeter', 'Santimetr', 'sen-ti-mee-ter'),
      PPh('Широкий', 'Wide', 'Giň', 'wayd'),
      PPh('Узкий', 'Narrow', 'Dar', 'na-ro'),
    ]),
  ]),
  // 75
  PCat(
    Icons.monetization_on_rounded,
    'Деньги детально',
    'Money details',
    'Pul jikme-jik',
    [
      PSub(Icons.monetization_on_rounded, 'Наличные', 'Cash', 'Nagt', [
        PPh('Купюра', 'Banknote', 'Kagyz pul', 'bank-not'),
        PPh('Монета', 'Coin', 'Şaýlyk', 'koyn'),
        PPh('Сдача', 'Change', 'Gaýtargy', 'cheynj'),
        PPh('Мелочь', 'Small change', 'Ownuk pul', 'smol cheynj'),
      ]),
      PSub(Icons.currency_exchange_rounded, 'Валюта', 'Currency', 'Walýuta', [
        PPh('Доллар', 'Dollar', 'Dollar', 'do-ler'),
        PPh('Евро', 'Euro', 'Ýewro', 'yu-ro'),
        PPh('Манат', 'Manat', 'Manat', 'ma-nat'),
        PPh('Курс обмена', 'Exchange rate', 'Çalşyk kursy', 'iks-cheynj reyt'),
      ]),
    ],
  ),
  // 76
  PCat(Icons.checkroom_rounded, 'Гардероб', 'Wardrobe', 'Eşikler', [
    PSub(Icons.checkroom_rounded, 'Одежда', 'Clothes', 'Eşikler', [
      PPh('Рубашка', 'Shirt', 'Köýnek', 'shert'),
      PPh('Брюки', 'Trousers', 'Balak', 'trau-zers'),
      PPh('Куртка', 'Jacket', 'Kurtka', 'ja-kit'),
      PPh('Платье', 'Dress', 'Don', 'dres'),
    ]),
    PSub(Icons.dry_cleaning_rounded, 'Верхнее', 'Outerwear', 'Daşky eşik', [
      PPh('Пальто', 'Coat', 'Palto', 'kot'),
      PPh('Свитер', 'Sweater', 'Switer', 'swe-ter'),
      PPh('Шарф', 'Scarf', 'Şarf', 'skarf'),
      PPh('Перчатки', 'Gloves', 'Ellyk', 'glavs'),
    ]),
  ]),
  // 77
  PCat(Icons.diamond_rounded, 'Украшения', 'Jewelry', 'Şaý-sepler', [
    PSub(Icons.diamond_rounded, 'Украшения', 'Jewelry', 'Şaý-sepler', [
      PPh('Кольцо', 'Ring', 'Ýüzük', 'ring'),
      PPh('Серёжки', 'Earrings', 'Gulakhalka', 'eer-rings'),
      PPh('Ожерелье', 'Necklace', 'Monjuk', 'nek-les'),
      PPh('Браслет', 'Bracelet', 'Bilezik', 'breys-let'),
    ]),
    PSub(Icons.diamond_rounded, 'Ценности', 'Valuables', 'Gymmatlyklar', [
      PPh('Золото', 'Gold', 'Altyn', 'gold'),
      PPh('Серебро', 'Silver', 'Kümüş', 'sil-ver'),
      PPh('Часы', 'Watch', 'Sagat', 'woch'),
      PPh('Драгоценный', 'Precious', 'Gymmatly', 'pre-shes'),
    ]),
  ]),
  // 78
  PCat(
    Icons.sanitizer_rounded,
    'Косметика и уход',
    'Cosmetics & Care',
    'Kosmetika we ideg',
    [
      PSub(Icons.sanitizer_rounded, 'Косметика', 'Cosmetics', 'Kosmetika', [
        PPh('Помада', 'Lipstick', 'Dodak boýagy', 'lip-stik'),
        PPh('Крем', 'Cream', 'Krem', 'kreem'),
        PPh('Духи', 'Perfume', 'Atyr', 'per-fyum'),
        PPh('Мыло', 'Soap', 'Sabyn', 'sop'),
      ]),
      PSub(Icons.bathtub_rounded, 'Гигиена', 'Hygiene', 'Arassaçylyk', [
        PPh('Зубная щётка', 'Toothbrush', 'Diş çotgasy', 'tuth-brash'),
        PPh('Зубная паста', 'Toothpaste', 'Diş pastasy', 'tuth-peyst'),
        PPh('Шампунь', 'Shampoo', 'Şampun', 'sham-pu'),
        PPh('Полотенце', 'Towel', 'Süpürgiç', 'tau-el'),
      ]),
    ],
  ),
  // 79
  PCat(Icons.construction_rounded, 'Инструменты', 'Tools', 'Gurallar', [
    PSub(Icons.construction_rounded, 'Инструменты', 'Tools', 'Gurallar', [
      PPh('Молоток', 'Hammer', 'Çekiç', 'ha-mer'),
      PPh('Отвёртка', 'Screwdriver', 'Otwerka', 'skru-dray-ver'),
      PPh('Пила', 'Saw', 'Byçgy', 'so'),
      PPh('Гвоздь', 'Nail', 'Çüý', 'nayl'),
    ]),
    PSub(Icons.build_rounded, 'Ремонт', 'Repair', 'Abatlaýyş', [
      PPh('Клей', 'Glue', 'Ýelim', 'glu'),
      PPh('Краска', 'Paint', 'Boýag', 'peynt'),
      PPh('Кисть', 'Brush', 'Çotga', 'brash'),
      PPh('Измерить', 'To measure', 'Ölçemek', 'tu me-zher'),
    ]),
  ]),
  // 80
  PCat(Icons.flatware_rounded, 'Посуда', 'Tableware', 'Gap-gaç', [
    PSub(Icons.flatware_rounded, 'Приборы', 'Cutlery', 'Saçak gurallary', [
      PPh('Вилка', 'Fork', 'Çarşak', 'fork'),
      PPh('Ложка', 'Spoon', 'Çemçe', 'spun'),
      PPh('Нож', 'Knife', 'Pyçak', 'nayf'),
      PPh('Тарелка', 'Plate', 'Tarelka', 'pleyt'),
    ]),
    PSub(Icons.local_drink_rounded, 'Ёмкости', 'Containers', 'Gaplar', [
      PPh('Чашка', 'Cup', 'Piýala', 'kap'),
      PPh('Стакан', 'Glass', 'Stakan', 'glas'),
      PPh('Кастрюля', 'Pot', 'Gazan', 'pot'),
      PPh('Бутылка', 'Bottle', 'Çüýşe', 'bo-tel'),
    ]),
  ]),
  // 81
  PCat(Icons.devices_rounded, 'Устройства', 'Devices', 'Enjamlar', [
    PSub(Icons.devices_rounded, 'Гаджеты', 'Gadgets', 'Enjamlar', [
      PPh('Телефон', 'Phone', 'Telefon', 'fon'),
      PPh('Компьютер', 'Computer', 'Kompýuter', 'kom-pyu-ter'),
      PPh('Планшет', 'Tablet', 'Planşet', 'tab-let'),
      PPh('Камера', 'Camera', 'Fotoapparat', 'ka-me-ra'),
    ]),
    PSub(Icons.power_rounded, 'Питание', 'Power', 'Iýmitlendirme', [
      PPh('Зарядка', 'Charger', 'Zarýadlaýjy', 'char-jer'),
      PPh('Батарея', 'Battery', 'Batareýa', 'ba-te-ri'),
      PPh('Кабель', 'Cable', 'Kabel', 'key-bel'),
      PPh('Розетка', 'Socket', 'Rozetka', 'so-ket'),
    ]),
  ]),
  // 82
  PCat(
    Icons.apps_rounded,
    'Приложения и сайты',
    'Apps & Sites',
    'Programmalar we saýtlar',
    [
      PSub(Icons.apps_rounded, 'Приложения', 'Apps', 'Programmalar', [
        PPh('Скачать', 'Download', 'Ýüklemek', 'daun-lod'),
        PPh('Установить', 'Install', 'Gurnamak', 'in-stol'),
        PPh('Обновить', 'Update', 'Täzelemek', 'ap-deyt'),
        PPh('Удалить', 'Delete', 'Pozmak', 'di-let'),
      ]),
      PSub(Icons.language_rounded, 'Сайты', 'Websites', 'Saýtlar', [
        PPh('Открыть сайт', 'Open the site', 'Saýty açmak', 'o-pen de sayt'),
        PPh('Поиск', 'Search', 'Gözleg', 'serch'),
        PPh('Войти', 'Log in', 'Girmek', 'log in'),
        PPh('Пароль', 'Password', 'Parol', 'pas-werd'),
      ]),
    ],
  ),
  // 83
  PCat(
    Icons.photo_camera_rounded,
    'Фото и видео',
    'Photo & Video',
    'Surat we wideo',
    [
      PSub(Icons.photo_camera_rounded, 'Фото', 'Photo', 'Surat', [
        PPh(
          'Сфотографируй меня',
          'Take my photo',
          'Meniň suratymy al',
          'teyk may fo-to',
        ),
        PPh('Улыбнись', 'Smile', 'Gül', 'smayl'),
        PPh('Ещё раз', 'One more time', 'Ýene bir gezek', 'wan mor taym'),
        PPh(
          'Фото получилось',
          'The photo is good',
          'Surat gowy boldy',
          'de fo-to iz gud',
        ),
      ]),
      PSub(Icons.videocam_rounded, 'Видео', 'Video', 'Wideo', [
        PPh('Сними видео', 'Record a video', 'Wideo ýaz', 'ri-kord a vi-de-o'),
        PPh('Камера включена', 'Camera is on', 'Kamera açyk', 'ka-me-ra iz on'),
        PPh('Стоп', 'Stop', 'Dur', 'stop'),
        PPh('Покажи фото', 'Show the photo', 'Suraty görkez', 'sho de fo-to'),
      ]),
    ],
  ),
  // 84
  PCat(
    Icons.piano_rounded,
    'Муз. инструменты',
    'Instruments',
    'Saz gurallary',
    [
      PSub(Icons.piano_rounded, 'Инструменты', 'Instruments', 'Gurallar', [
        PPh('Гитара', 'Guitar', 'Gitara', 'gi-tar'),
        PPh('Пианино', 'Piano', 'Pianino', 'pi-a-no'),
        PPh('Барабан', 'Drum', 'Dep', 'dram'),
        PPh('Скрипка', 'Violin', 'Skripka', 'vay-o-lin'),
      ]),
      PSub(Icons.music_note_rounded, 'Музыка', 'Music', 'Saz', [
        PPh('Песня', 'Song', 'Aýdym', 'song'),
        PPh('Играть', 'To play', 'Çalmak', 'tu play'),
        PPh('Петь', 'To sing', 'Aýtmak', 'tu sing'),
        PPh('Мелодия', 'Melody', 'Saz', 'me-lo-di'),
      ]),
    ],
  ),
  // 85
  PCat(
    Icons.palette_rounded,
    'Искусство и музей',
    'Art & Museum',
    'Sungat we muzeý',
    [
      PSub(Icons.palette_rounded, 'Искусство', 'Art', 'Sungat', [
        PPh('Картина', 'Painting', 'Surat', 'peyn-ting'),
        PPh('Художник', 'Artist', 'Suratkeş', 'ar-tist'),
        PPh('Выставка', 'Exhibition', 'Sergi', 'eks-i-bi-shen'),
        PPh('Скульптура', 'Sculpture', 'Heýkel', 'skalp-cher'),
      ]),
      PSub(Icons.museum_rounded, 'Музей', 'Museum', 'Muzeý', [
        PPh(
          'Где музей?',
          'Where is the museum?',
          'Muzeý nirede?',
          'wer iz de myu-zi-em',
        ),
        PPh(
          'Сколько вход?',
          'How much is entry?',
          'Giriş näçe?',
          'hau mach iz en-tri',
        ),
        PPh(
          'Можно фотографировать?',
          'Can I take photos?',
          'Surat almak bolýarmy?',
          'ken ay teyk fo-tos',
        ),
        PPh('Экскурсия', 'Guided tour', 'Ekskursiýa', 'gay-ded tur'),
      ]),
    ],
  ),
  // 86
  PCat(
    Icons.menu_book_rounded,
    'Книги и чтение',
    'Books & Reading',
    'Kitaplar we okamak',
    [
      PSub(Icons.menu_book_rounded, 'Книги', 'Books', 'Kitaplar', [
        PPh('Книга', 'Book', 'Kitap', 'buk'),
        PPh('Газета', 'Newspaper', 'Gazet', 'nyus-pey-per'),
        PPh('Журнал', 'Magazine', 'Žurnal', 'ma-ga-zeen'),
        PPh('Автор', 'Author', 'Awtor', 'o-thor'),
      ]),
      PSub(Icons.local_library_rounded, 'Чтение', 'Reading', 'Okamak', [
        PPh('Я читаю', 'I am reading', 'Men okaýaryn', 'ay em ree-ding'),
        PPh('Интересно', 'Interesting', 'Gyzykly', 'in-tres-ting'),
        PPh('Страница', 'Page', 'Sahypa', 'peyj'),
        PPh('Глава', 'Chapter', 'Bap', 'chap-ter'),
      ]),
    ],
  ),
  // 87
  PCat(
    Icons.school_rounded,
    'Университет и экзамены',
    'University & Exams',
    'Uniwersitet we synag',
    [
      PSub(Icons.school_rounded, 'Учёба', 'Studies', 'Okuw', [
        PPh('Университет', 'University', 'Uniwersitet', 'yu-ni-ver-si-ti'),
        PPh('Факультет', 'Faculty', 'Fakultet', 'fa-kal-ti'),
        PPh('Лекция', 'Lecture', 'Leksiýa', 'lek-cher'),
        PPh('Диплом', 'Diploma', 'Diplom', 'di-plo-ma'),
      ]),
      PSub(Icons.quiz_rounded, 'Экзамены', 'Exams', 'Synaglar', [
        PPh('Экзамен', 'Exam', 'Synag', 'ig-zam'),
        PPh('Я сдал', 'I passed', 'Men geçdim', 'ay past'),
        PPh('Я провалил', 'I failed', 'Men ýykyldym', 'ay feyld'),
        PPh('Оценка', 'Grade', 'Baha', 'greyd'),
      ]),
    ],
  ),
  // 88
  PCat(
    Icons.emoji_emotions_rounded,
    'Эмоции (ещё)',
    'More emotions',
    'Duýgular (dowam)',
    [
      PSub(Icons.emoji_emotions_rounded, 'Положительные', 'Positive', 'Oňyn', [
        PPh('Я горжусь', 'I am proud', 'Men buýsanýaryn', 'ay em praud'),
        PPh('Я удивлён', 'I am surprised', 'Men haýran', 'ay em ser-prayzd'),
        PPh(
          'Я благодарен',
          'I am grateful',
          'Men minnetdar',
          'ay em greyt-ful',
        ),
        PPh('Я спокоен', 'I am calm', 'Men asuda', 'ay em kam'),
      ]),
      PSub(
        Icons.emoji_events_rounded,
        'Отрицательные',
        'Negative',
        'Otrisatel',
        [
          PPh(
            'Я нервничаю',
            'I am nervous',
            'Men tolgunýaryn',
            'ay em ner-ves',
          ),
          PPh(
            'Я разочарован',
            'I am disappointed',
            'Men lapykeç',
            'ay em di-sa-poynted',
          ),
          PPh('Мне скучно', 'I am bored', 'Maňa içgyn', 'ay em borld'),
          PPh(
            'Я беспокоюсь',
            'I am worried',
            'Men alada edýärin',
            'ay em wa-rid',
          ),
        ],
      ),
    ],
  ),
  // 89
  PCat(
    Icons.psychology_alt_rounded,
    'Характер (ещё)',
    'More character',
    'Häsiýet (dowam)',
    [
      PSub(Icons.psychology_alt_rounded, 'Хорошие', 'Good', 'Gowy', [
        PPh('Щедрый', 'Generous', 'Jomart', 'je-ne-res'),
        PPh('Терпеливый', 'Patient', 'Sabyrly', 'pey-shent'),
        PPh('Дружелюбный', 'Friendly', 'Dostlukly', 'frend-li'),
        PPh('Надёжный', 'Reliable', 'Ygtybarly', 'ri-lay-a-bel'),
      ]),
      PSub(Icons.sentiment_neutral_rounded, 'Разные', 'Mixed', 'Dürli', [
        PPh('Скромный', 'Modest', 'Kiçigöwün', 'mo-dest'),
        PPh('Любопытный', 'Curious', 'Merak', 'kyu-ri-es'),
        PPh('Серьёзный', 'Serious', 'Çynlakaý', 'se-ri-es'),
        PPh('Весёлый', 'Cheerful', 'Şadyýan', 'cheer-ful'),
      ]),
    ],
  ),
  // 90
  PCat(
    Icons.water_drop_rounded,
    'Природные явления',
    'Natural phenomena',
    'Tebigy hadysalar',
    [
      PSub(Icons.water_drop_rounded, 'Явления', 'Phenomena', 'Hadysalar', [
        PPh('Дождь', 'Rain', 'Ýagyş', 'reyn'),
        PPh('Снег', 'Snow', 'Gar', 'sno'),
        PPh('Ветер', 'Wind', 'Şemal', 'wind'),
        PPh('Туман', 'Fog', 'Duman', 'fog'),
      ]),
      PSub(Icons.thunderstorm_rounded, 'Стихия', 'Storms', 'Tupan', [
        PPh('Гроза', 'Thunderstorm', 'Gök gümmürdisi', 'than-der-storm'),
        PPh('Молния', 'Lightning', 'Ýyldyrym', 'layt-ning'),
        PPh('Град', 'Hail', 'Dolu', 'heyl'),
        PPh('Радуга', 'Rainbow', 'Älemgoşar', 'reyn-bo'),
        PPh('Жарко', 'Hot', 'Yssy', 'hot'),
      ]),
    ],
  ),
];
