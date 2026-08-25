enum AppLang { tk, ru, en, tr }

extension AppLangX on AppLang {
  String get flag => switch (this) {
    AppLang.tk => '🇹🇲',
    AppLang.ru => '🇷🇺',
    AppLang.en => '🇬🇧',
    AppLang.tr => '🇹🇷',
  };
  String get title => switch (this) {
    AppLang.tk => 'Türkmençe',
    AppLang.ru => 'Русский',
    AppLang.en => 'English',
    AppLang.tr => 'Türkçe',
  };
}

const Map<AppLang, Map<String, String>> appStrings = {
  AppLang.tk: {
    'app_name': 'Köpri',
    'nav_translate': 'Terjime',
    'nav_conversation': 'Söhbet',
    'nav_phrasebook': 'Sözler',
    'nav_flashcards': 'Kartlar',
    'nav_history': 'Taryh',
    'settings': 'Sazlamalar',
    'appearance': 'Daşky görnüş',
    'theme': 'Tema',
    'theme_dark': 'Garaňky',
    'theme_light': 'Ýagty',
    'theme_system': 'Ulgam',
    'language': 'Dil',
    'interface_language': 'Programma dili',
    'font_size': 'Şrift ölçegi',
    'speech_rate': 'Ses tizligi',
    'data': 'Maglumatlar',
    'about': 'Programma barada',
    'version': 'Wersiýa',
    'history': 'Taryh',
    'favorites': 'Halanlarym',
    'no_history': 'Entek terjime ýok',
    'no_favorites': 'Halanlar ýok — ýyldyzjyk bilen belläň',
    'search': 'Gözle…',
    'conversation_title': 'Söhbet režimi',
    'tap_to_speak': 'Gürlemek üçin basyň',
    'listening': 'Diňleýäris…',
    'phrasebook_title': 'Sözleşme kitaby',
    'flashcards_title': 'Kartlar',
    'flashcards_empty': 'Kart ýok — taryhda ýyldyzjyk goýuň',
    'remember': 'Bilýärin',
    'forgot': 'Unutdym',
    'flip': 'Öwür',
    'copy': 'Göçür',
    'copied': 'Göçürildi ✓',
    'paste': 'Goý',
    'clear': 'Arassala',
    'speak': 'Seslendir',
    'input_hint': 'Terjime etmeli tekstiňizi ýazyň…',
    'from': 'GÖZBAŞY',
    'to': 'TERJIME',
    'translation_section': 'TERJIME',
    'default_source': 'Deslapky gözbaşy',
    'default_target': 'Deslapky terjime',
    'auto_translate': 'Awtoterjime',
    'auto_translate_desc': 'Ýazylan badyna terjime et',
    'translate_delay': 'Gijikdirme',
    'speech_section': 'SES',
    'auto_speak': 'Awtoseslendirme',
    'auto_speak_desc': 'Terjimäni dessine aýd',
    'volume': 'Gatylyk',
    'pitch': 'Ton',
    'listen_preview': 'Synlap gör',
    'mic_listen_for': 'Diňleme wagty',
    'mic_pause': 'Sessizlikde dur',
    'phrasebook_section': 'SÖZLER WE KARTLAR',
    'phrase_speak': 'Sözleriň sesi',
    'phrase_speak_iface': 'Programma dili',
    'phrase_speak_english': 'Iňlisçe',
    'phrase_speak_both': 'Ikisi hem',
    'flashcard_session': 'Sessiýa ölçegi',
    'spaced_rep': 'Gaýtalaýyş',
    'data_section': 'MAGLUMAT',
    'auto_save_history': 'Taryhy ýatda sakla',
    'clear_history': 'Taryhy arassala',
    'clear_favorites': 'Halanlary arassala',
    'clear_all': 'Ählisini arassala',
    'history_exported': 'Taryh bufere göçürildi',
    'history_imported': 'Taryh buferden alyndy',
    'confirm': 'Tassykla',
    'cancel': 'Ýok',
    'look_section': 'GÖRNÜŞ',
    'accent_color': 'Esasy reňk',
    'animations': 'Animasiýalar',
    'animations_desc': 'Geçişleri we Hero görkez',
    'compact': 'Ykjam görnüş',
    'compact_desc': 'Has dykyz sanawlar',
    'about_section': 'PROGRAMMA',
    'licenses': 'Rugsatnamalar',
    'share_app': 'Paýlaş',
    'feedback': 'Pikir',
    'export_history': 'Taryhy eksport et (faýl)',
    'import_history': 'Taryhy import et (bufer)',
    'auto_save_desc': 'Her terjimäni taryha ýaz',
    'auto_clean': 'Awto-arassala',
    'auto_clean_desc': 'Köne ýazgylar programma açylanda pozulýar',
    'no_data_clipboard': 'Buferde maglumat ýok',
    'cleared': 'Arassalandy',
    'removed_stars': 'Ýyldyzlar aýryldy',
    'repeat': 'Gaýtala',
    'flashcard_session_desc': 'Bir raunddaky kart sany',
    'spaced_rep_desc': 'Unudan kartlaryň soň gaýtalanýar',
    'offline_models_title': 'OFLAÝN MODELLER',
    'offline_models_desc':
        'Bu modeller — terjime faýllary. Olar internetsiz işlemek üçin telefonyňyza bir gezek ýüklenýär. Soňra terjime Wi‑Fi bolmasa‑da işleýär. Bu wirus ýa‑da artykmaç zat däl — diňe ulanýan dilleriňiz üçin terjime motorydyr.',
    'offline_models_desc2':
        'Modeller programma maglumatlaryndan aýratyn saklanýar: keşi arassalamak olara degmeýär. Pozsaňyzam gorkmaň — indiki terjimede ýene awtomatiki ýüklenýär. Ýüklemek üçin VPN gerek däl.',
    'offline_models_downloaded': 'Ýüklenen',
    'offline_models_empty':
        'Entek model ýüklenmedi. Ilkinji terjimäňizde awtomatiki ýüklenýär.',
    'offline_models_loading': 'Barlanýar…',
    'offline_models_delete_all': 'Ähli modelleri poz',
    'offline_models_deleted_one': 'Model pozuldy',
    'offline_models_deleted_all': 'Ähli modeller pozuldy',
    'offline_models_none': 'Pozmaga model ýok',
    'offline_models_note_bg':
        'Üns beriň: modeliň ýüklenýändigini ekranda görmeseňizem, alada etmäň — ol arka planda, ünsüňizi bölmän ýüklenýär. Ýükleme gutaransoň terjime taýýar bolar.',
    'offline_models_format':
        'Her dil paketi ulgamda dil kody bilen bellenýär (meselem, af, en, ru). Jübüti terjime etmek üçin iki diliň hem paketi gerek, şonuň üçin telefonyňyzdaky faýllar diňe ulanýan jübütleriňize görä düzülýär — artykmaç zat ýüklenmeýär.',
    'offline_models_en_note':
        'Iňlis dili paketi käwagt ulgamyň esasy toplumyna girýär we şonuň üçin pozulmaýar — bu adaty we howpsuz ýagdaý.',
    'offline_models_could_not_delete': 'Pozup bolmady (belki, ulgam paketi)',
    'offline_models_deleted_some': 'Käbir modeller pozuldy',
    'analyzing': 'Analiz…',
    'translate_error': 'Terjime başa barmady. Interneti barlaň.',
    'nav_camera': 'Kamera',
    'camera_title': 'Suratdan terjime',
    'camera_subtitle': 'Surata düşüň — tekst awtomatik terjime ediler',
    'camera_open': 'Kamerany aç',
    'camera_gallery': 'Suratlar',
    'camera_empty': 'Entek surat ýok',
    'camera_no_text': 'Suratda tekst tapylmady',
    'camera_translating': 'Terjime edilýär…',
    'camera_original': 'ASLY',
    'camera_translation': 'TERJIME',
    'camera_deleted': 'Surat pozuldy',
    'camera_permission': 'Kamera rugsady gerek',
    'clear_photos': 'Suratlary poz',
    'photos_cleared': 'Suratlar pozuldy',
    'nav_profile': 'Profil',
    'profile_title': 'Profil',
    'profile_user_default': 'Ulanyjy',
    'profile_user_label': 'Ulanyjy ady',
    'profile_enter_name': 'Adyňyzy ýazyň',
    'profile_activity': 'IŞJEŇLIK',
    'profile_translations': 'Terjimeler',
    'profile_favorites': 'Halanlar',
    'profile_cards': 'Kartlar',
    'profile_photos': 'Suratlar',
    'profile_achievements': 'ÜSTÜNLIKLER',
    'profile_quick': 'ÇALT HEREKETLER',
    'profile_share': 'Profili paýlaş',
    'profile_clear': 'Profili arassala',
    'profile_clear_msg': 'Ady we awatary pozmaly?',
    'profile_cleared': 'Arassalandy',
    'profile_gallery': 'Galereýa',
    'profile_camera': 'Kamera',
    'profile_remove_photo': 'Suraty poz',
    'profile_badge_hint': 'Ilkinji nyşan üçin 10 tekst terjime et',
    'badge_translator': 'Terjimeçi (10+)',
    'badge_master': 'Ussa (100+)',
    'badge_legend': 'Rowaýat (500+)',
    'badge_collector': 'Kolleksioner (20+)',
    'badge_learner': 'Okuwçy (50+)',
    'badge_photo': 'Surat terjimeçi (10+)',
    'profile_week': 'SOŇKY 7 GÜN',
    'profile_adv': 'GIŇIŞLEÝIN STATISTIKA',
    'profile_top_lang': 'Ýygy dil',
    'profile_peak': 'Işjeň wagt',
    'profile_avg_len': 'Orta uzynlyk',
    'profile_top_phrases': 'Ýygy sözler',
    'profile_phrase_day': 'GÜNÜŇ SÖZI',
    'profile_bio_hint': 'Status goş',
    'profile_emoji': 'Emoji awatar',
    'profile_export': 'Eksport / Import',
    'profile_import': 'Import',
    'profile_import_hint': 'JSON ýelimiňi goý',
    'profile_exported_to': 'Ýatda saklanyldy:',
    'profile_imported': 'Import edildi:',
    'profile_clear_old': 'Köneleri poz',
    'profile_days': 'gün',
    'profile_feedback': 'Pikir ibermek',
    'profile_hidden': 'Gizlin nyşan',
    'rar_common': 'Adaty',
    'rar_rare': 'Seýrek',
    'rar_epic': 'Epik',
    'rar_legendary': 'Rowaýat',
    'licenses_thanks_title': 'Minnetdarlyk',
    'licenses_thanks_desc':
        'Bu programma Flutter we açyk çeşme jemgyýetiniň ajaýyp paketleri esasynda guruldy.',
    'licenses_search': 'Paket gözle…',
    'licenses_packages': 'paket',
    'licenses_not_found': 'Paket tapylmady',
    'profile_feedback_title': 'Pikir ibermek',
    'profile_feedback_desc':
        'Soraglaryňyz ýa-da teklipleriňiz bar bolsa, Telegram bot arkaly habarlaşyň. Biz hökman jogap bereris!',
    'profile_feedback_open': 'Telegram aç',
    'profile_feedback_error': 'Telegram açylmady',
    'profile_emoji_hint':
        'Saňa ýaraýan emojini saýla. Profil suratyň ýerine görkeziler.',
    'profile_emoji_count': 'emoji',
    'export_empty': 'Taryh boş — eksport etjek zat ýok',
    'export_done': 'Ýatda saklanyldy:',
    'export_clipboard': 'buferde hem bar',
    'export_error': 'Ýalňyşlyk boldy, synanyşyň',
    'export_json_desc': 'Ähli taryhy göçür we faýl et',
    'export_csv_desc': 'Excel / Google Sheets üçin tablisa',
    'import_desc': 'Başga telefondan taryhy getir',
    'import_howto':
        'Köne telefonyňyzda «Eksport» basyň, teksti göçüriň we şu ýere goýuň.',
    'import_empty_field': 'Meýdana taryhy (JSON) goýuň',
    'import_bad_format': 'Bu Köpri taryhy däl — barlaň',
    'import_empty': 'Import etjek zat ýok — taryh boş',
    'import_done': 'Import edildi:',
    'clear_old_desc': 'Köne terjimeleri poz',
    'profile_create_name': 'At döret',
    'profile_save_name': 'Ýatda sakla',
    'profile_change_name': 'Üýtget',
    'profile_week_activity': ' hepde',
    'level': 'Dereje',
    'xp_to_next_level': 'XP indiki derejä çenli',
    'daily_goal': 'Gündelik maksat',
    'phrases_more': 'ýene terjime et',
    'goal_completed': 'Maksat ýerine ýetirildi! Ajaýyp iş!',
    'phrases_remaining': 'ýene terjime et',
    'streak_day': 'gün',
    'streak_days': 'gün',
    'streak_consecutive': 'yzygiderli',
    'invalid_json': 'Nädogry JSON formaty',
    'import_failed': 'Import şowsuz boldy',
    'export_failed': 'Eksport şowsuz boldy',
    'apk_not_found': 'APK tapylmady',
    'share_failed': 'Paýlaşyp bolmady',
    'telegram_failed': 'Telegram açylmady',
    'share_unavailable': 'Bu funksiýa diňe Android-de işleýär',

    // ═══════════════════════════════════════════════════════════════
    // TERMS OF SERVICE — Условие использования
    // ═══════════════════════════════════════════════════════════════
    'terms_of_service': 'Ulanyş şertleri',
    'terms_intro_title': 'Biziň aramyzdaky hukuk şertnamasy',
    'terms_intro_body':
        'Köpri mobil programmasyny («Programma») ýükläp, gurnap ýa-da ulanyp, siz («Ulanyjy») şu şertleri doly we çäklendirilmedik kabul edýärsiňiz. Eger şu şertleriň haýsydyr bir bölegi bilen razy bolmasaňyz, Programmany derrew ulanmagy bes etmegiňizi we enjamyňyzdan aýyrmagyňyzy haýyş edýäris. Şu resminama siziň bilen Köpri döredijisiniň («Biz», «Önümi eýesi») arasyndaky baglanyşykly hukuk gatnaşyklaryny düzgünleşdirýär.',
    'terms_sec1_title': '1. Lisenziýa we intellektual eýeçilik',
    'terms_sec1_body':
        'Biz size şahsy, aýratyn däl, gaýtadan berlip bilinmeýän, mugt we çäkli lisenziýa berýäris — diňe Programmany öz şahsy enjamyňyzda ulanmak üçin. Ähli intellektual eýeçilik hukuklary, şol sanda awtorlyk hukugy, söwda belligi, Programma kody, dizaýn, nyşanlar we terjime algoritmleri — biziň eýeçiligimizde galýar. Biziň açyk ýazmaça rugsadymyzsyz şu hereketler düýbünden gadagan:',
    'terms_sec1_b1':
        'Programmanyň binar koduny gaýtadan inženerçilik etmek, dekompilýasiýa ýa-da disassemblirlemek',
    'terms_sec1_b2':
        'Programmanyň çeşme koduny, gurluşyny ýa-da algoritmlerini çykarmaga synanyşmak',
    'terms_sec1_b3':
        'Programmanyň üýtgedilen ýa-da gelip çykan nusgalaryny döretmek ýa-da ýaýratmak',
    'terms_sec1_b4':
        'Programmany täjirçilik maksatly kärendesine bermek, satmak ýa-da gaýtadan lisenziýalamak',
    'terms_sec2_title': '2. Terjime hili we takyklyk kepilligi ýok',
    'terms_sec2_body':
        'Terjimeler awtomatiki maşyn öwreniş modelleri (Google ML Kit, Google Translate API, MyMemory Translation Memory), neýron torlary we gurulan lingwistik sözlük arkaly döredilýär. Maşyn terjimesi tebigaty boýunça doly takyklygy kepillendirip bilmeýär — ol semantik, grammatik, pragmatik we medeniýet ýalňyşlyklary öz içine alyp biler. Biz aşakdakylary duýdurýarys:',
    'terms_sec2_b1':
        'Lukmançylyk diagnozlary, derman dozalary ýa-da kliniki maslahatlar üçin Köpri terjimelerine daýanmaň',
    'terms_sec2_b2':
        'Hukuk şertnamalary, kazyýet resminamalary ýa-da kadalaşdyryjy talaplar üçin ulanmaň',
    'terms_sec2_b3':
        'Maliýe hasabatlary, bank amallary ýa-da salgyt beýannamalary üçin ulanmaň',
    'terms_sec2_b4':
        'Möhüm terjimeler üçin hemişe ygtyýarly hünärmen terjimeçi tarapyndan barladyň',
    'terms_sec3_title': '3. Jogapkärçiligiň çäklendirilmegi',
    'terms_sec3_body':
        'Programma «BAR BOLŞY ÝALY» (AS IS) we «ELÝETER BOLŞY ÝALY» (AS AVAILABLE) ýörelgeleri esasynda, hiç hili göni ýa-da gytaklaýyn kepilliksiz berilýär. Kanunyň iň ýokary rugsat berýän çäginde Biz aşakdakylar üçin jogapkärçilik çekmeýäris:',
    'terms_sec3_b1':
        'Göni, gytaklaýyn, tötänleýin, aýratyn ýa-da netijeli zyýan (şol sanda maglumat ýitgisi)',
    'terms_sec3_b2':
        'Elden giderilen girdeji, iş togtamasy ýa-da täjirçilik zyýany',
    'terms_sec3_b3':
        'Enjamyň näsazlygy, batareýanyň çalt gutarmasy ýa-da ulgam resurslarynyň aşa ulanylmagy',
    'terms_sec3_b4':
        'Üçünji tarap hyzmatlarynyň (Google, MyMemory) elýeterliliginiň kesilmegi ýa-da ýalňyşlygy',
    'terms_sec4_title': '4. Gadagan ulanma we Ulanyjynyň borçlary',
    'terms_sec4_body':
        'Programmany ulanyp, siz aşakdaky hereketlerden saklanmaga borçlanýarsyňyz:',
    'terms_sec4_b1':
        'Jenaýatçylykly, kemsidiji, adamyň abraýyna degýän, jynsçylykly ýa-da zorlukly mazmuny terjime etmek',
    'terms_sec4_b2':
        'Awtorlyk hukugy bilen goralýan materiallary rugsatsyz terjime edip, ýaýratmak',
    'terms_sec4_b3':
        'Spam, phishing, zyýanly programma ýa-da botnet işjeňligi üçin ulanmak',
    'terms_sec4_b4':
        'Döwlet howpsuzlygyna, harby syrlara ýa-da şahsy durmuşyň elde degirmesizligine garşy hereketler',
    'terms_sec4_b5':
        'Awtomatlaşdyrylan skriptler, botlar ýa-da web-skreýping arkaly Programmany aşa ýüklemek',
    'terms_sec5_title': '5. Üçünji tarap komponentleri we açyk çeşme',
    'terms_sec5_body':
        'Köpri aşakdaky üçünji tarap kitapханalary we açyk çeşme komponentleri ulanýar, olaryň her biri öz lisenziýa şertleri bilen berilýär:',
    'terms_sec5_b1':
        'Flutter framework — BSD 3-Clause Lisenziýasy (Google LLC)',
    'terms_sec5_b2':
        'Google ML Kit — Google LLC-iň hyzmat şertlerine laýyklykda',
    'terms_sec5_b3':
        'Hive, flutter_tts, shared_preferences we beýlekiler — degişli MIT, Apache 2.0 ýa-da BSD lisenziýalary',
    'terms_sec5_b4':
        'Doly sanaw we lisenziýa tekstleri Programma sazlamalaryndaky «Rugsatnamalar» bölüminde elýeter',
    'terms_sec6_title': '6. Ulanylýan hukuk we dawalary çözmek',
    'terms_sec6_body':
        'Şu Şertler siziň ýaşaýan ýurduňyzyň kanunlaryna laýyklykda düşündirilýär we düzgünleşdirilýär. Islendik dawa ýa-da düşünişmezlik ilki bilen gepleşikler arkaly, ýazmaça habarlaşma arkaly, makul möhletlerde çözülmäge synanyşylýar. Eger gepleşikler netije bermese, dawa degişli ýurisdiksiýanyň ygtyýarly kazyýetinde serediler. Şu Şertleriň haýsydyr bir maddasy kanuna garşy gelýän diýlip ykrar edilse, beýleki maddalar doly güýjünde galýar.',
    'terms_acceptance':
        'Köpri ulanyp, siz şu Ulanyş şertlerini we Gizlinlik syýasatyny doly okandygyňyzy, düşünýändigiňizi we olary ýerine ýetirmäge razydygyňyzy tassyklaýarsyňyz.',
    'terms_footer': 'Köpri · Güýje giren senesi: awgust 2026',

    // ═══════════════════════════════════════════════════════════════
    // PRIVACY POLICY — Политика конфиденциальности
    // ═══════════════════════════════════════════════════════════════
    'privacy_policy': 'Gizlinlik syýasaty',
    'privacy_intro_title': 'Siziň şahsy maglumatlaryňyzyň goragy',
    'privacy_intro_body':
        'Köpri («Biz», «Önümi eýesi») siziň şahsy durmuşyňyzyň elde degirmesizligini we maglumatlaryňyzyň howpsuzlygyny iň ýokary derejede goramaga borçlanýar. Şu Gizlinlik syýasaty (mundan beýläk «Syýasat») haýsy maglumatlaryň işlenýändigini, haýsylarynyň işlenmeýändigini, maglumatlaryňyzyň nirede saklanýandygyny we üçünji taraplar bilen nähili gatnaşykda bolýandygyny düşündirýär. Köpri ulanmak bilen, şu Syýasatda beýan edilen maglumat işläp taýýarlamak usullaryna razylyk berýärsiňiz.',
    'privacy_sec1_title': '1. Biz näme ÝYGNAMEÝARYS',
    'privacy_sec1_body':
        'Köpri «ilki bilen gizlinlik» (privacy-by-design) ýörelgesi esasynda guruldy. Biz aşakdaky maglumatlary hiç haçan we hiç hili görnüşde ýygnamaýarys:',
    'privacy_sec1_b1':
        'Şahsyýeti anyklaýjy maglumatlar (at, familiýa, ata ady, doglan senesi)',
    'privacy_sec1_b2':
        'Habarlaşma maglumatlary (e-poçta salgysy, telefon belgisi, poçta salgysy)',
    'privacy_sec1_b3':
        'Töleg we maliýe maglumatlary (bank kartlary, hasaplar, tranzaksiýalar)',
    'privacy_sec1_b4':
        'Geolokasiýa maglumatlary (GPS koordinatalary, IP-salgylar, tor metadata)',
    'privacy_sec1_b5':
        'Biometrik maglumatlar (barmak yzy, ýüz tanama, ses nusgalary)',
    'privacy_sec1_b6':
        'Mahabat profilleri, treker identifikatorlary we analitik cookie-faýllar',
    'privacy_sec2_title': '2. Enjamyňyzda ýerli SAKLANÝAN maglumatlar',
    'privacy_sec2_body':
        'Ähli siziň işjeňligiňiz diňe siziň şahsy enjamyňyzda galýar we internete iberilmeýär. Ýerli (lokal) saklanýan maglumatlara şular degişli:',
    'privacy_sec2_b1':
        'Terjime taryhy we halanlaryňyz — Hive maglumatlar bazasynda şifrlenen görnüşde',
    'privacy_sec2_b2':
        'Programma sazlamalary: tema, dil, şrift ölçegi, ses parametrleri',
    'privacy_sec2_b3':
        'Öwreniş statistikasy: yzygiderli günler (streak), XP ballary, derejeler, nyşanlar',
    'privacy_sec2_b4':
        'Google ML Kit offlaýn terjime modelleri — diňe saýlan dilleriňiz üçin',
    'privacy_sec2_b5':
        'Profil maglumatlary: ulanyjy ady, emoji awatar, şahsy status',
    'privacy_sec3_title': '3. Android ULGAM RUGSATLARY',
    'privacy_sec3_body':
        'Programma aşakdaky rugsatlary talap edýär, olaryň her biri diňe anyk funksiýa üçin niýetlenen we islendik wagt Android ulgam sazlamalarynda yzyna alynyp bilner:',
    'privacy_sec3_b1':
        'KAMERA — suratlardaky teksti OCR (optiki nyşan tanamak) arkaly terjime etmek; maglumat diňe enjamda işlenýär',
    'privacy_sec3_b2':
        'MIKROFON — ses bilen girizmek we dialog režimi; ses diňe ýerli tanama üçin ulanylýar',
    'privacy_sec3_b3':
        'PENJIRELERIŇ ÜSTÜNDE GÖRKEZMEK — buferden terjime köpügi (overlay bubble)',
    'privacy_sec3_b4':
        'HABARNAMALAR — arka plandaky bufer gözegçilik hyzmatynyň işlemegi',
    'privacy_sec3_b5':
        'INTERNET — diňe onlaýn terjime hyzmatlaryna baglanmak üçin',
    'privacy_sec4_title': '4. TOR HAÝYŞLARY we üçünji tarap hyzmatlary',
    'privacy_sec4_body':
        'Onlaýn terjime üçin Programma internete birigýär we terjime edýän tekstiňiz aşakdaky üçünji tarap hyzmatlaryna iberilip bilner. Her hyzmat öz gizlinlik syýasatyna eýedir:',
    'privacy_sec4_b1':
        'Google Translate API (translate.googleapis.com) — Google LLC-iň Gizlinlik syýasaty',
    'privacy_sec4_b2':
        'Lingva Translate — açyk çeşme proksi, serwer tarapynda maglumatlar saklanmaýar',
    'privacy_sec4_b3':
        'MyMemory Translation API (mymemory.translated.net) —Translated Srl-iň syýasaty',
    'privacy_sec4_b4':
        'Firebase Crashlytics — diňe programma näsazlyklary barada anonim tehniki hasabatlar (stack trace, enjam modeli, OS wersiýasy)',
    'privacy_sec5_title': '5. OFLAÝN TERTIBI we ýerli işlemek',
    'privacy_sec5_body':
        'Offlaýn terjime Google ML Kit arkaly doly siziň enjamyňyzda işleýär. Ýüklenen neýron tor modelleri ýerli faýl ulgamynda saklanýar we hiç hili serwere iberilmeýär. Gurulan türkmen-rus we türkmen-iňlis lingwistik sözlügi hem doly offlaýn işleýär we tora mätäçlik çekmeýär. Bu, internet ýok wagty hem terjime hyzmatynyň doly elýeter bolmagyny üpjün edýär we siziň tekstleriňiziň gizlinligini iň ýokary derejede goraýar.',
    'privacy_sec6_title': '6. ÇAGALARYŇ gizlinligi (COPPA laýyklykda)',
    'privacy_sec6_body':
        'Köpri 13 ýaşdan kiçi çagalardan (ýa-da degişli ýurisdiksiýada kesgitlenen san — mysal üçin, ÝB-de 16 ýaş) bilkastlaýyn şahsy maglumat ýygnamaýar. Biz çagalaryň şahsy maglumatlaryny ýygnamak, ulanmak ýa-da açmak üçin ene-ata ýa-da howandaryň tassyklanylýan razylygyny talap etmeýäris. Eger ene-ata ýa-da howandar çagasynyň bize şahsy maglumat berendigine ynanýan bolsa, dessine bize ýüz tutsun — biz maglumatlary 24 sagadyň dowamynda serwerlermizden (bar bolsa) we ýerli enjamlardan hem pozarys.',
    'privacy_sec7_title': '7. Syýasata ÜÝTGEŞMELER we habarnamalar',
    'privacy_sec7_body':
        'Biz şu Syýasaty wagtal-wagtal täzeläp bileris. Mazmunly üýtgeşmeler (maglumat ýygnamagyň täze görnüşleri, üçünji tarap hyzmatlarynyň üýtgemegi, hukuk esaslarynyň üýtgemegi) barada öňünden habar bereris: Programma içindäki habarnama ýa-da açylyş ekrany arkaly. Täzelenen Syýasaty yzygiderli ulanmagy dowam etseňiz, üýtgeşmeleri kabul edýärsiňiz.',
    'privacy_contact_title': 'Bize ýüz tutmak we hukuklaryňyz',
    'privacy_contact_body':
        'Maglumatlaryňyza girişi, düzedişleri, göçürilmegini ýa-da doly pozulmagyny haýyş etmek üçin, şeýle hem şu Syýasat boýunça islendik sorag ýa-da teklip üçin Telegram arkaly habarlaşyň:',
    'privacy_footer': 'Köpri · Soňky täzelenme: awgust 2026',
    'danger_zone': 'Howply ýer',
  },
  AppLang.ru: {
    'app_name': 'Köpri',
    'nav_translate': 'Перевод',
    'nav_conversation': 'Диалог',
    'nav_phrasebook': 'Фразы',
    'nav_flashcards': 'Карточки',
    'nav_history': 'История',
    'settings': 'Настройки',
    'appearance': 'Оформление',
    'theme': 'Тема',
    'theme_dark': 'Тёмная',
    'theme_light': 'Светлая',
    'theme_system': 'Системная',
    'language': 'Язык',
    'interface_language': 'Язык приложения',
    'font_size': 'Размер шрифта',
    'speech_rate': 'Скорость речи',
    'data': 'Данные',
    'clear_history': 'Очистить историю',
    'about': 'О приложении',
    'clear_all': 'Очистить всё',
    'version': 'Версия',
    'history': 'История',
    'favorites': 'Избранное',
    'no_history': 'Пока нет переводов',
    'no_favorites': 'Нет избранного — отмечайте звёздочкой',
    'search': 'Поиск…',
    'conversation_title': 'Режим диалога',
    'tap_to_speak': 'Нажмите, чтобы говорить',
    'listening': 'Слушаем…',
    'phrasebook_title': 'Разговорник',
    'flashcards_title': 'Карточки',
    'flashcards_empty': 'Нет карточек — добавьте звёздочку в истории',
    'remember': 'Помню',
    'forgot': 'Забыл',
    'flip': 'Перевернуть',
    'copy': 'Копировать',
    'copied': 'Скопировано ✓',
    'paste': 'Вставить',
    'clear': 'Очистить',
    'speak': 'Озвучить',
    'input_hint': 'Введите текст для перевода…',
    'from': 'ОРИГИНАЛ',
    'to': 'ПЕРЕВОД',
    'translation_section': 'ПЕРЕВОД',
    'default_source': 'Язык источника по умолч.',
    'default_target': 'Язык перевода по умолч.',
    'auto_translate': 'Автоперевод',
    'auto_translate_desc': 'Переводить при вводе',
    'translate_delay': 'Задержка',
    'speech_section': 'РЕЧЬ',
    'auto_speak': 'Автоозвучка',
    'auto_speak_desc': 'Озвучивать перевод сразу',
    'volume': 'Громкость',
    'pitch': 'Тон',
    'listen_preview': 'Прослушать пример',
    'mic_listen_for': 'Время прослушивания',
    'mic_pause': 'Стоп по тишине',
    'phrasebook_section': 'ФРАЗЫ И КАРТОЧКИ',
    'phrase_speak': 'Озвучка фраз',
    'phrase_speak_iface': 'Язык приложения',
    'phrase_speak_english': 'Английский',
    'phrase_speak_both': 'Оба',
    'flashcard_session': 'Размер сессии',
    'spaced_rep': 'Интервальные повторы',
    'data_section': 'ДАННЫЕ',
    'auto_save_history': 'Сохранять историю',
    'clear_favorites': 'Очистить избранное',
    'history_exported': 'История скопирована в буфер',
    'history_imported': 'История импортирована из буфера',
    'confirm': 'Подтвердить',
    'cancel': 'Отмена',
    'look_section': 'ВИД',
    'accent_color': 'Акцентный цвет',
    'animations': 'Анимации',
    'animations_desc': 'Переходы и Hero',
    'compact': 'Компактный вид',
    'compact_desc': 'Более плотные списки',
    'about_section': 'ПРИЛОЖЕНИЕ',
    'licenses': 'Лицензии',
    'share_app': 'Поделиться',
    'feedback': 'Обратная связь',
    'export_history': 'Экспорт истории (файл)',
    'import_history': 'Импорт истории (буфер)',
    'auto_save_desc': 'Сохранять каждый перевод',
    'auto_clean': 'Автоочистка',
    'auto_clean_desc': 'Старые записи удаляются при запуске',
    'no_data_clipboard': 'В буфере нет данных',
    'cleared': 'Очищено',
    'removed_stars': 'Звёзды сняты',
    'repeat': 'Повтор',
    'flashcard_session_desc': 'Сколько карточек в раунде',
    'spaced_rep_desc': 'Забытые карточки возвращаются позже',
    'offline_models_title': 'ОФФЛАЙН-МОДЕЛИ',
    'offline_models_desc':
        'Эти модели — файлы перевода. Они один раз скачиваются на телефон, чтобы перевод работал без интернета. Это не вирус и не лишний мусор — это движок перевода для тех языков, которыми вы пользуетесь.',
    'offline_models_desc2':
        'Модели хранятся отдельно от данных приложения: очистка кеша их не тронет. Если удалите — не пугайтесь, при следующем переводе они скачаются заново автоматически. Для загрузки VPN не нужен.',
    'offline_models_downloaded': 'Скачано',
    'offline_models_empty':
        'Пока моделей нет. Они скачаются автоматически при первом переводе.',
    'offline_models_loading': 'Проверка…',
    'offline_models_delete_all': 'Удалить все модели',
    'offline_models_deleted_one': 'Модель удалена',
    'offline_models_deleted_all': 'Все модели удалены',
    'offline_models_none': 'Нет моделей для удаления',
    'offline_models_note_bg':
        'Обратите внимание: даже если вы не видите индикатор загрузки на экране — не волнуйтесь, модель скачивается в фоновом режиме и не мешает работе. Перевод станет доступен, как только загрузка завершится.',
    'offline_models_format':
        'Каждый языковой пакет помечен в системе кодом языка (например, af, en, ru). Для перевода пары нужны пакеты обоих языков, поэтому набор файлов на телефоне формируется строго под ваши пары — ничего лишнего не скачивается.',
    'offline_models_en_note':
        'Английский пакет иногда входит в базовый набор системы и поэтому может не удаляться — это нормально и безопасно.',
    'offline_models_could_not_delete':
        'Не удалось удалить (возможно, системный пакет)',
    'offline_models_deleted_some': 'Удалена часть моделей',
    'translate_error': 'Перевод не удался. Проверьте интернет.',
    'analyzing': 'Анализ…',
    'nav_camera': 'Камера',
    'camera_title': 'Перевод текста с фото',
    'camera_subtitle': 'Сделайте снимок — текст переведётся автоматически',
    'camera_open': 'Открыть камеру',
    'camera_gallery': 'Снимки',
    'camera_empty': 'Пока нет снимков',
    'camera_no_text': 'Текст на фото не найден',
    'camera_translating': 'Переводим…',
    'camera_original': 'ОРИГИНАЛ',
    'camera_translation': 'ПЕРЕВОД',
    'camera_deleted': 'Фото удалено',
    'camera_permission': 'Нужно разрешение на камеру',
    'clear_photos': 'Очистить фото',
    'photos_cleared': 'Фото очищены',
    'nav_profile': 'Профиль',
    'profile_title': 'Профиль',
    'profile_user_default': 'Пользователь',
    'profile_user_label': 'Имя пользователя',
    'profile_enter_name': 'Введите имя',
    'profile_activity': 'АКТИВНОСТЬ',
    'profile_translations': 'Переводы',
    'profile_favorites': 'Избранное',
    'profile_cards': 'Карточки',
    'profile_photos': 'Фото',
    'profile_achievements': 'ДОСТИЖЕНИЯ',
    'profile_quick': 'БЫСТРЫЕ ДЕЙСТВИЯ',
    'profile_share': 'Поделиться профилем',
    'profile_clear': 'Очистить профиль',
    'profile_clear_msg': 'Удалить имя и аватар?',
    'profile_cleared': 'Очищено',
    'profile_gallery': 'Галерея',
    'profile_camera': 'Камера',
    'profile_remove_photo': 'Удалить фото',
    'profile_badge_hint': 'Переведи 10 текстов для первого бейджа',
    'badge_translator': 'Переводчик (10+)',
    'badge_master': 'Мастер (100+)',
    'badge_legend': 'Легенда (500+)',
    'badge_collector': 'Коллекционер (20+)',
    'badge_learner': 'Ученик (50+)',
    'badge_photo': 'Фото-переводчик (10+)',
    'profile_week': 'ПОСЛЕДНИЕ 7 ДНЕЙ',
    'profile_adv': 'ПРОДВИНУТАЯ СТАТИСТИКА',
    'profile_top_lang': 'Частый язык',
    'profile_peak': 'Пик активности',
    'profile_avg_len': 'Средняя длина',
    'profile_top_phrases': 'Частые фразы',
    'profile_phrase_day': 'ФРАЗА ДНЯ',
    'profile_bio_hint': 'Добавить статус',
    'profile_emoji': 'Эмодзи-аватар',
    'profile_export': 'Экспорт / Импорт',
    'profile_import': 'Импорт',
    'profile_import_hint': 'Вставь JSON',
    'profile_exported_to': 'Сохранено:',
    'profile_imported': 'Импортировано:',
    'profile_clear_old': 'Удалить старые',
    'profile_days': 'дней',
    'profile_feedback': 'Обратная связь',
    'profile_hidden': 'Скрытый бейдж',
    'rar_common': 'Обычный',
    'rar_rare': 'Редкий',
    'rar_epic': 'Эпический',
    'rar_legendary': 'Легендарный',
    'licenses_thanks_title': 'Благодарность',
    'licenses_thanks_desc':
        'Приложение создано благодаря Flutter и замечательным пакетам open-source сообщества.',
    'licenses_search': 'Поиск пакета…',
    'licenses_packages': 'пакетов',
    'licenses_not_found': 'Пакет не найден',
    'profile_feedback_title': 'Обратная связь',
    'profile_feedback_desc':
        'Есть вопросы или предложения? Напишите нам через Telegram бот. Мы обязательно ответим!',
    'profile_feedback_open': 'Открыть Telegram',
    'profile_feedback_error': 'Не удалось открыть Telegram',
    'profile_emoji_hint':
        'Выбери эмодзи, который будет отображаться вместо фото в профиле.',
    'profile_emoji_count': 'эмодзи',
    'export_empty': 'История пуста — нечего экспортировать',
    'export_done': 'Сохранено записей:',
    'export_clipboard': 'также в буфере',
    'export_error': 'Что-то пошло не так, попробуйте ещё раз',
    'export_json_desc': 'Скопировать всю историю в файл',
    'export_csv_desc': 'Таблица для Excel / Google Sheets',
    'import_desc': 'Перенести историю с другого телефона',
    'import_howto':
        'На старом телефоне нажмите «Экспорт», скопируйте текст и вставьте сюда.',
    'import_empty_field': 'Вставьте историю (JSON) в поле',
    'import_bad_format': 'Это не история Köpri — проверьте данные',
    'import_empty': 'Нечего импортировать — история пустая',
    'import_done': 'Импортировано записей:',
    'clear_old_desc': 'Удалить старые переводы',
    'profile_create_name': 'Создать имя',
    'profile_save_name': 'Сохранить',
    'profile_change_name': 'Изменить',
    'profile_week_activity': 'Активность за неделю',
    'level': 'Уровень',
    'xp_to_next_level': 'XP до уровня',
    'daily_goal': 'Ежедневная цель',
    'phrases_more': 'фраз',
    'goal_completed': 'Цель выполнена! Отличная работа!',
    'phrases_remaining': 'Переведи ещё',
    'streak_day': 'день',
    'streak_days': 'дней',
    'streak_consecutive': 'подряд',
    'invalid_json': 'Неверный формат JSON',
    'import_failed': 'Ошибка импорта',
    'export_failed': 'Ошибка экспорта',
    'apk_not_found': 'APK не найден',
    'share_failed': 'Не удалось поделиться',
    'telegram_failed': 'Не удалось открыть Telegram',
    'share_unavailable': 'Функция доступна только на Android',

    // ═══════════════════════════════════════════════════════════════
    // TERMS OF SERVICE
    // ═══════════════════════════════════════════════════════════════
    'terms_of_service': 'Условия использования',
    'terms_intro_title': 'Юридическое соглашение между вами и нами',
    'terms_intro_body':
        'Загружая, устанавливая или используя мобильное приложение Köpri («Приложение»), вы («Пользователь») полностью и безоговорочно принимаете настоящие условия. Если вы не согласны с каким-либо пунктом настоящих условий, мы просим вас немедленно прекратить использование Приложения и удалить его с вашего устройства. Настоящий документ регулирует правовые отношения между вами и разработчиком Köpri («Мы», «Правообладатель»).',
    'terms_sec1_title': '1. Лицензия и интеллектуальная собственность',
    'terms_sec1_body':
        'Мы предоставляем вам личную, неисключительную, непередаваемую, безвозмездную и ограниченную лицензию на использование Приложения исключительно на вашем личном устройстве. Все права интеллектуальной собственности, включая авторское право, товарные знаки, исходный код, дизайн, логотипы и алгоритмы перевода, остаются нашей собственностью. Без нашего прямого письменного разрешения категорически запрещается:',
    'terms_sec1_b1':
        'Осуществлять обратную разработку, декомпиляцию или дизассемблирование бинарного кода Приложения',
    'terms_sec1_b2':
        'Предпринимать попытки извлечения исходного кода, структуры или алгоритмов Приложения',
    'terms_sec1_b3':
        'Создавать или распространять модифицированные или производные версии Приложения',
    'terms_sec1_b4':
        'Сдавать Приложение в аренду, продавать или сублицензировать в коммерческих целях',
    'terms_sec2_title': '2. Качество перевода и отсутствие гарантий',
    'terms_sec2_body':
        'Переводы генерируются автоматически с помощью моделей машинного обучения (Google ML Kit, Google Translate API, MyMemory Translation Memory), нейронных сетей и встроенного лингвистического словаря. Машинный перевод по своей природе не может гарантировать абсолютную точность — он может содержать семантические, грамматические, прагматические и культурные ошибки. Мы предупреждаем:',
    'terms_sec2_b1':
        'Не полагайтесь на переводы Köpri для медицинских диагнозов, дозировок лекарств или клинических рекомендаций',
    'terms_sec2_b2':
        'Не используйте для юридических договоров, судебных документов или нормативных требований',
    'terms_sec2_b3':
        'Не используйте для финансовых отчётов, банковских операций или налоговых деклараций',
    'terms_sec2_b4':
        'Для критически важных переводов всегда проводите проверку квалифицированным переводчиком',
    'terms_sec3_title': '3. Ограничение ответственности',
    'terms_sec3_body':
        'Приложение предоставляется на принципах «КАК ЕСТЬ» (AS IS) и «ПО МЕРЕ ДОСТУПНОСТИ» (AS AVAILABLE) без каких-либо прямых или косвенных гарантий. В максимальной степени, допускаемой законом, Мы не несём ответственности за:',
    'terms_sec3_b1':
        'Прямой, косвенный, случайный, особый или последующий ущерб (включая потерю данных)',
    'terms_sec3_b2':
        'Упущенную выгоду, приостановку деятельности или коммерческий ущерб',
    'terms_sec3_b3':
        'Сбои устройства, быстрый разряд батареи или чрезмерное использование системных ресурсов',
    'terms_sec3_b4':
        'Недоступность или ошибки сторонних сервисов (Google, MyMemory)',
    'terms_sec4_title':
        '4. Запрещённое использование и обязанности Пользователя',
    'terms_sec4_body':
        'Используя Приложение, вы обязуетесь воздерживаться от следующих действий:',
    'terms_sec4_b1':
        'Перевод преступного, оскорбительного, клеветнического, порнографического или насильственного контента',
    'terms_sec4_b2':
        'Перевод и распространение материалов, защищённых авторским правом, без разрешения',
    'terms_sec4_b3':
        'Использование для спама, фишинга, вредоносного ПО или активности ботнета',
    'terms_sec4_b4':
        'Действия против государственной безопасности, военной тайны или неприкосновенности частной жизни',
    'terms_sec4_b5':
        'Чрезмерная нагрузка на Приложение через автоматизированные скрипты, боты или веб-скрейпинг',
    'terms_sec5_title': '5. Сторонние компоненты и открытый исходный код',
    'terms_sec5_body':
        'Köpri использует следующие сторонние библиотеки и компоненты с открытым исходным кодом, каждый из которых предоставляется на условиях собственной лицензии:',
    'terms_sec5_b1': 'Фреймворк Flutter — лицензия BSD 3-Clause (Google LLC)',
    'terms_sec5_b2':
        'Google ML Kit — в соответствии с условиями обслуживания Google LLC',
    'terms_sec5_b3':
        'Hive, flutter_tts, shared_preferences и другие — соответствующие лицензии MIT, Apache 2.0 или BSD',
    'terms_sec5_b4':
        'Полный список и тексты лицензий доступны в разделе «Лицензии» в настройках Приложения',
    'terms_sec6_title': '6. Применимое право и разрешение споров',
    'terms_sec6_body':
        'Настоящие Условия толкуются и регулируются в соответствии с законодательством страны вашего проживания. Любой спор или разногласие сначала предпринимаются попытки решить путём переговоров в разумные сроки. Если переговоры не приносят результата, спор рассматривается в компетентном суде соответствующей юрисдикции. Если какое-либо положение настоящих Условий будет признано противоречащим закону, остальные положения сохраняют полную силу.',
    'terms_acceptance':
        'Используя Köpri, вы подтверждаете, что полностью прочитали, поняли и согласны соблюдать настоящие Условия использования и Политику конфиденциальности.',
    'terms_footer': 'Köpri · Дата вступления в силу: август 2026',

    // ═══════════════════════════════════════════════════════════════
    // PRIVACY POLICY
    // ═══════════════════════════════════════════════════════════════
    'privacy_policy': 'Политика конфиденциальности',
    'privacy_intro_title': 'Защита ваших персональных данных',
    'privacy_intro_body':
        'Köpri («Мы», «Правообладатель») обязуется обеспечивать максимальный уровень защиты вашей частной жизни и безопасности ваших данных. Настоящая Политика конфиденциальности (далее «Политика») разъясняет, какие данные обрабатываются, какие не обрабатываются, где хранятся ваши данные и как осуществляется взаимодействие с третьими сторонами. Используя Köpri, вы соглашаетесь с методами обработки данных, описанными в настоящей Политике.',
    'privacy_sec1_title': '1. Что мы НЕ собираем',
    'privacy_sec1_body':
        'Köpri построен по принципу «приватность по умолчанию» (privacy-by-design). Мы никогда и ни в какой форме не собираем следующие данные:',
    'privacy_sec1_b1':
        'Персональные идентифицирующие данные (имя, фамилия, отчество, дата рождения)',
    'privacy_sec1_b2':
        'Контактные данные (email, номер телефона, почтовый адрес)',
    'privacy_sec1_b3':
        'Платёжные и финансовые данные (банковские карты, счета, транзакции)',
    'privacy_sec1_b4':
        'Геолокационные данные (GPS-координаты, IP-адреса, сетевые метаданные)',
    'privacy_sec1_b5':
        'Биометрические данные (отпечатки пальцев, распознавание лиц, голосовые образцы)',
    'privacy_sec1_b6':
        'Рекламные профили, идентификаторы трекеров и аналитические cookie-файлы',
    'privacy_sec2_title': '2. Данные, хранимые ЛОКАЛЬНО на устройстве',
    'privacy_sec2_body':
        'Вся ваша активность остаётся только на вашем личном устройстве и не передаётся в интернет. К локально хранимым данным относятся:',
    'privacy_sec2_b1':
        'История переводов и избранное — в зашифрованном виде в базе данных Hive',
    'privacy_sec2_b2':
        'Настройки приложения: тема, язык, размер шрифта, параметры голоса',
    'privacy_sec2_b3':
        'Статистика обучения: серии дней (streak), XP-баллы, уровни, бейджи',
    'privacy_sec2_b4':
        'Оффлайн-модели перевода Google ML Kit — только для выбранных вами языков',
    'privacy_sec2_b5':
        'Данные профиля: имя пользователя, эмодзи-аватар, личный статус',
    'privacy_sec3_title': '3. СИСТЕМНЫЕ разрешения Android',
    'privacy_sec3_body':
        'Приложение запрашивает следующие разрешения, каждое из которых предназначено исключительно для конкретной функции и может быть отозвано в любой момент в системных настройках Android:',
    'privacy_sec3_b1':
        'КАМЕРА — перевод текста с фото через OCR (оптическое распознавание); данные обрабатываются только на устройстве',
    'privacy_sec3_b2':
        'МИКРОФОН — голосовой ввод и режим диалога; звук используется только для локального распознавания',
    'privacy_sec3_b3':
        'ОТОБРАЖЕНИЕ ПОВЕРХ ОКОН — пузырёк перевода из буфера обмена (overlay bubble)',
    'privacy_sec3_b4':
        'УВЕДОМЛЕНИЯ — работа фоновой службы мониторинга буфера обмена',
    'privacy_sec3_b5':
        'ИНТЕРНЕТ — исключительно для подключения к онлайн-сервисам перевода',
    'privacy_sec4_title': '4. СЕТЕВЫЕ ЗАПРОСЫ и сторонние сервисы',
    'privacy_sec4_body':
        'Для онлайн-перевода Приложение подключается к интернету, и переводимый вами текст может отправляться в следующие сторонние сервисы. У каждого сервиса есть собственная политика конфиденциальности:',
    'privacy_sec4_b1':
        'Google Translate API (translate.googleapis.com) — Политика конфиденциальности Google LLC',
    'privacy_sec4_b2':
        'Lingva Translate — прокси с открытым исходным кодом, данные не хранятся на сервере',
    'privacy_sec4_b3':
        'MyMemory Translation API (mymemory.translated.net) — политика Translated Srl',
    'privacy_sec4_b4':
        'Firebase Crashlytics — только анонимные технические отчёты о сбоях приложения (stack trace, модель устройства, версия ОС)',
    'privacy_sec5_title': '5. ОФФЛАЙН-РЕЖИМ и локальная обработка',
    'privacy_sec5_body':
        'Оффлайн-перевод через Google ML Kit полностью выполняется на вашем устройстве. Загруженные модели нейронных сетей хранятся в локальной файловой системе и не отправляются ни на какой сервер. Встроенный лингвистический словарь туркменско-русского и туркменско-английского также работает полностью оффлайн и не требует подключения к сети. Это обеспечивает полную доступность сервиса перевода даже при отсутствии интернета и гарантирует максимальный уровень конфиденциальности ваших текстов.',
    'privacy_sec6_title': '6. Конфиденциальность ДЕТЕЙ (соответствие COPPA)',
    'privacy_sec6_body':
        'Köpri не собирает намеренно персональные данные от детей младше 13 лет (или возраста, установленного в соответствующей юрисдикции — например, 16 лет в ЕС). Мы не требуем заверенного согласия родителей или опекунов на сбор, использование или раскрытие персональных данных детей. Если родитель или опекун считает, что ребёнок предоставил нам персональные данные, ему следует немедленно связаться с нами — мы удалим данные в течение 24 часов как с наших серверов (если они там есть), так и с локальных устройств.',
    'privacy_sec7_title': '7. ИЗМЕНЕНИЯ в Политике и уведомления',
    'privacy_sec7_body':
        'Мы можем время от времени обновлять настоящую Политику. О существенных изменениях (новые виды сбора данных, изменение сторонних сервисов, изменение правовых оснований) мы уведомим вас заранее: через уведомление в Приложении или на стартовом экране. Продолжая использовать обновлённую Политику на регулярной основе, вы принимаете изменения.',
    'privacy_contact_title': 'Связаться с нами и ваши права',
    'privacy_contact_body':
        'Чтобы запросить доступ к вашим данным, их исправление, экспорт или полное удаление, а также по любым вопросам или предложениям касательно настоящей Политики — напишите нам в Telegram:',
    'privacy_footer': 'Köpri · Последнее обновление: август 2026',
    'danger_zone': 'Опасная зона',
  },
  AppLang.en: {
    'app_name': 'Köpri',
    'nav_translate': 'Translate',
    'nav_conversation': 'Dialogue',
    'nav_phrasebook': 'Phrases',
    'nav_flashcards': 'Cards',
    'nav_history': 'History',
    'settings': 'Settings',
    'appearance': 'Appearance',
    'theme': 'Theme',
    'theme_dark': 'Dark',
    'theme_light': 'Light',
    'theme_system': 'System',
    'language': 'Language',
    'interface_language': 'App language',
    'font_size': 'Font size',
    'speech_rate': 'Speech rate',
    'data': 'Data',
    'clear_history': 'Clear history',
    'clear_all': 'Clear everything',
    'about': 'About',
    'version': 'Version',
    'history': 'History',
    'favorites': 'Favorites',
    'no_history': 'No translations yet',
    'no_favorites': 'No favorites — tap the star',
    'search': 'Search…',
    'conversation_title': 'Conversation mode',
    'tap_to_speak': 'Tap to speak',
    'listening': 'Listening…',
    'phrasebook_title': 'Phrasebook',
    'flashcards_title': 'Flashcards',
    'flashcards_empty': 'No cards — star items in history',
    'remember': 'Know it',
    'forgot': 'Forgot',
    'flip': 'Flip',
    'copy': 'Copy',
    'copied': 'Copied ✓',
    'paste': 'Paste',
    'clear': 'Clear',
    'speak': 'Speak',
    'input_hint': 'Type text to translate…',
    'from': 'SOURCE',
    'to': 'TRANSLATION',
    'translation_section': 'TRANSLATION',
    'default_source': 'Default source language',
    'default_target': 'Default target language',
    'auto_translate': 'Auto-translate',
    'auto_translate_desc': 'Translate as you type',
    'translate_delay': 'Delay',
    'speech_section': 'SPEECH',
    'auto_speak': 'Auto-speak',
    'auto_speak_desc': 'Speak translation instantly',
    'volume': 'Volume',
    'pitch': 'Pitch',
    'listen_preview': 'Hear example',
    'mic_listen_for': 'Listening time',
    'mic_pause': 'Stop on silence',
    'phrasebook_section': 'PHRASES & CARDS',
    'phrase_speak': 'Phrase audio',
    'phrase_speak_iface': 'App language',
    'phrase_speak_english': 'English',
    'phrase_speak_both': 'Both',
    'flashcard_session': 'Session size',
    'spaced_rep': 'Spaced repetition',
    'data_section': 'DATA',
    'auto_save_history': 'Save history',
    'clear_favorites': 'Clear favorites',
    'history_exported': 'History copied to clipboard',
    'history_imported': 'History imported from clipboard',
    'confirm': 'Confirm',
    'cancel': 'Cancel',
    'look_section': 'LOOK',
    'accent_color': 'Accent color',
    'animations': 'Animations',
    'animations_desc': 'Transitions and Hero',
    'compact': 'Compact view',
    'compact_desc': 'Denser lists',
    'about_section': 'APP',
    'licenses': 'Licenses',
    'share_app': 'Share',
    'feedback': 'Feedback',
    'export_history': 'Export history (file)',
    'import_history': 'Import history (clipboard)',
    'auto_save_desc': 'Save every translation',
    'auto_clean': 'Auto-clean',
    'auto_clean_desc': 'Old entries are deleted on launch',
    'no_data_clipboard': 'No data in clipboard',
    'cleared': 'Cleared',
    'removed_stars': 'Stars removed',
    'repeat': 'Repeat',
    'flashcard_session_desc': 'Cards per round',
    'spaced_rep_desc': 'Forgotten cards come back later',
    'offline_models_title': 'OFFLINE MODELS',
    'offline_models_desc':
        'These models are translation files. They download to your phone once so translation works without internet. This is not a virus or junk — it is the translation engine for the languages you use.',
    'offline_models_desc2':
        'Models are stored separately from app data: clearing the cache will not touch them. If you delete them, don\'t worry — they download again automatically on the next translation. No VPN is needed to download.',
    'offline_models_downloaded': 'Downloaded',
    'offline_models_empty':
        'No models yet. They download automatically on your first translation.',
    'offline_models_loading': 'Checking…',
    'offline_models_delete_all': 'Delete all models',
    'offline_models_deleted_one': 'Model deleted',
    'offline_models_deleted_all': 'All models deleted',
    'offline_models_none': 'No models to delete',
    'offline_models_note_bg':
        'Please note: even if you don\'t see a download indicator on screen, don\'t worry — the model downloads quietly in the background without interrupting you. Translation becomes available as soon as the download finishes.',
    'offline_models_format':
        'Each language pack is tagged in the system by its language code (for example, af, en, ru). Translating a pair needs both languages\' packs, so the set of files on your phone is built strictly around the pairs you use — nothing extra is downloaded.',
    'offline_models_en_note':
        'The English pack is sometimes part of the system\'s base set and so may not be removable — this is normal and safe.',
    'offline_models_could_not_delete':
        'Could not delete (possibly a system pack)',
    'offline_models_deleted_some': 'Some models deleted',
    'analyzing': 'Analyzing…',
    'translate_error': 'Translation failed. Check your connection.',
    'nav_camera': 'Camera',
    'camera_title': 'Translate text from a photo',
    'camera_subtitle':
        'Take a photo — the text will be translated automatically',
    'camera_open': 'Open camera',
    'camera_gallery': 'Photos',
    'camera_empty': 'No photos yet',
    'camera_no_text': 'No text found in the photo',
    'camera_translating': 'Translating…',
    'camera_original': 'ORIGINAL',
    'camera_translation': 'TRANSLATION',
    'camera_deleted': 'Photo deleted',
    'camera_permission': 'Camera permission required',
    'clear_photos': 'Clear photos',
    'photos_cleared': 'Photos cleared',
    'nav_profile': 'Profile',
    'profile_title': 'Profile',
    'profile_user_default': 'User',
    'profile_user_label': 'User name',
    'profile_enter_name': 'Enter your name',
    'profile_activity': 'ACTIVITY',
    'profile_translations': 'Translations',
    'profile_favorites': 'Favorites',
    'profile_cards': 'Cards',
    'profile_photos': 'Photos',
    'profile_achievements': 'ACHIEVEMENTS',
    'profile_quick': 'QUICK ACTIONS',
    'profile_share': 'Share profile',
    'profile_clear': 'Clear profile',
    'profile_clear_msg': 'Delete name and avatar?',
    'profile_cleared': 'Cleared',
    'profile_gallery': 'Gallery',
    'profile_camera': 'Camera',
    'profile_remove_photo': 'Remove photo',
    'profile_badge_hint': 'Translate 10 texts to earn your first badge',
    'badge_translator': 'Translator (10+)',
    'badge_master': 'Master (100+)',
    'badge_legend': 'Legend (500+)',
    'badge_collector': 'Collector (20+)',
    'badge_learner': 'Learner (50+)',
    'badge_photo': 'Photo translator (10+)',
    'profile_week': 'LAST 7 DAYS',
    'profile_adv': 'ADVANCED STATS',
    'profile_top_lang': 'Top language',
    'profile_peak': 'Peak hour',
    'profile_avg_len': 'Avg length',
    'profile_top_phrases': 'Top phrases',
    'profile_phrase_day': 'PHRASE OF THE DAY',
    'profile_bio_hint': 'Add status',
    'profile_emoji': 'Emoji avatar',
    'profile_export': 'Export / Import',
    'profile_import': 'Import',
    'profile_import_hint': 'Paste JSON',
    'profile_exported_to': 'Saved:',
    'profile_imported': 'Imported:',
    'profile_clear_old': 'Clear old entries',
    'profile_days': 'days',
    'profile_feedback': 'Feedback',
    'profile_hidden': 'Hidden badge',
    'rar_common': 'Common',
    'rar_rare': 'Rare',
    'rar_epic': 'Epic',
    'rar_legendary': 'Legendary',
    'licenses_thanks_title': 'Acknowledgements',
    'licenses_thanks_desc':
        'This app is built thanks to Flutter and the amazing open-source community packages.',
    'licenses_search': 'Search packages…',
    'licenses_packages': 'packages',
    'licenses_not_found': 'Package not found',
    'profile_feedback_title': 'Feedback',
    'profile_feedback_desc':
        'Have questions or suggestions? Contact us via Telegram bot. We will definitely respond!',
    'profile_feedback_open': 'Open Telegram',
    'profile_feedback_error': 'Could not open Telegram',
    'profile_emoji_hint':
        'Choose an emoji that will be displayed instead of your profile photo.',
    'profile_emoji_count': 'emojis',
    'export_empty': 'History is empty — nothing to export',
    'export_done': 'Saved entries:',
    'export_clipboard': 'also in clipboard',
    'export_error': 'Something went wrong, try again',
    'export_json_desc': 'Copy all history to a file',
    'export_csv_desc': 'Table for Excel / Google Sheets',
    'import_desc': 'Transfer history from another phone',
    'import_howto':
        'On the old phone tap "Export", copy the text and paste it here.',
    'import_empty_field': 'Paste the history (JSON) into the field',
    'import_bad_format': 'This is not Köpri history — check the data',
    'import_empty': 'Nothing to import — history is empty',
    'import_done': 'Imported entries:',
    'clear_old_desc': 'Delete old translations',
    'profile_create_name': 'Create name',
    'profile_save_name': 'Save',
    'profile_change_name': 'Change',
    'profile_week_activity': 'Weekly Activity',
    'level': 'Level',
    'xp_to_next_level': 'XP to next level',
    'daily_goal': 'Daily goal',
    'phrases_more': 'phrases',
    'goal_completed': 'Goal completed! Great job!',
    'phrases_remaining': 'Translate',
    'streak_day': 'day',
    'streak_days': 'days',
    'streak_consecutive': 'consecutive',
    'invalid_json': 'Invalid JSON format',
    'import_failed': 'Import failed',
    'export_failed': 'Export failed',
    'apk_not_found': 'APK not found',
    'share_failed': 'Could not share',
    'telegram_failed': 'Could not open Telegram',
    'share_unavailable': 'This feature is only available on Android',

    // ═══════════════════════════════════════════════════════════════
    // TERMS OF SERVICE
    // ═══════════════════════════════════════════════════════════════
    'terms_of_service': 'Terms of Service',
    'terms_intro_title': 'Legal agreement between you and us',
    'terms_intro_body':
        'By downloading, installing, or using the Köpri mobile application (the "App"), you (the "User") fully and unconditionally accept these terms. If you do not agree with any part of these terms, we request that you immediately cease using the App and uninstall it from your device. This document governs the legal relationship between you and the Köpri developer ("We", "the Owner").',
    'terms_sec1_title': '1. License and intellectual property',
    'terms_sec1_body':
        'We grant you a personal, non-exclusive, non-transferable, free and limited license to use the App solely on your personal device. All intellectual property rights, including copyright, trademarks, source code, design, logos, and translation algorithms, remain our property. Without our express written permission, the following actions are strictly prohibited:',
    'terms_sec1_b1':
        'Reverse engineering, decompiling, or disassembling the App\'s binary code',
    'terms_sec1_b2':
        'Attempting to extract the App\'s source code, structure, or algorithms',
    'terms_sec1_b3':
        'Creating or distributing modified or derivative versions of the App',
    'terms_sec1_b4':
        'Renting, selling, or sublicensing the App for commercial purposes',
    'terms_sec2_title': '2. Translation quality and no warranties',
    'terms_sec2_body':
        'Translations are automatically generated using machine learning models (Google ML Kit, Google Translate API, MyMemory Translation Memory), neural networks, and a built-in linguistic dictionary. Machine translation by its nature cannot guarantee absolute accuracy — it may contain semantic, grammatical, pragmatic, and cultural errors. We warn:',
    'terms_sec2_b1':
        'Do not rely on Köpri translations for medical diagnoses, drug dosages, or clinical advice',
    'terms_sec2_b2':
        'Do not use for legal contracts, court documents, or regulatory requirements',
    'terms_sec2_b3':
        'Do not use for financial reports, banking operations, or tax declarations',
    'terms_sec2_b4':
        'For critical translations, always have them verified by a qualified human translator',
    'terms_sec3_title': '3. Limitation of liability',
    'terms_sec3_body':
        'The App is provided on an "AS IS" and "AS AVAILABLE" basis without any express or implied warranties. To the maximum extent permitted by law, We are not liable for:',
    'terms_sec3_b1':
        'Direct, indirect, incidental, special, or consequential damages (including data loss)',
    'terms_sec3_b2':
        'Lost profits, business interruption, or commercial damage',
    'terms_sec3_b3':
        'Device malfunctions, rapid battery drain, or excessive system resource usage',
    'terms_sec3_b4':
        'Unavailability or errors of third-party services (Google, MyMemory)',
    'terms_sec4_title': '4. Prohibited use and User obligations',
    'terms_sec4_body':
        'By using the App, you undertake to refrain from the following activities:',
    'terms_sec4_b1':
        'Translating criminal, offensive, defamatory, pornographic, or violent content',
    'terms_sec4_b2':
        'Translating and distributing copyrighted materials without permission',
    'terms_sec4_b3':
        'Using the App for spam, phishing, malware, or botnet activity',
    'terms_sec4_b4':
        'Activities against national security, military secrets, or privacy',
    'terms_sec4_b5':
        'Overloading the App through automated scripts, bots, or web scraping',
    'terms_sec5_title': '5. Third-party components and open source',
    'terms_sec5_body':
        'Köpri uses the following third-party libraries and open-source components, each provided under its own license terms:',
    'terms_sec5_b1': 'Flutter framework — BSD 3-Clause License (Google LLC)',
    'terms_sec5_b2':
        'Google ML Kit — in accordance with Google LLC\'s terms of service',
    'terms_sec5_b3':
        'Hive, flutter_tts, shared_preferences, and others — respective MIT, Apache 2.0, or BSD licenses',
    'terms_sec5_b4':
        'The full list and license texts are available in the Licenses section of the App settings',
    'terms_sec6_title': '6. Governing law and dispute resolution',
    'terms_sec6_body':
        'These Terms are interpreted and governed in accordance with the laws of your country of residence. Any dispute or disagreement shall first be attempted to be resolved through negotiation within a reasonable timeframe. If negotiations fail, the dispute shall be heard in a court of competent jurisdiction. If any provision of these Terms is found to be contrary to law, the remaining provisions shall remain in full force and effect.',
    'terms_acceptance':
        'By using Köpri, you confirm that you have fully read, understood, and agreed to comply with these Terms of Service and the Privacy Policy.',
    'terms_footer': 'Köpri · Effective date: August 2026',

    // ═══════════════════════════════════════════════════════════════
    // PRIVACY POLICY
    // ═══════════════════════════════════════════════════════════════
    'privacy_policy': 'Privacy Policy',
    'privacy_intro_title': 'Protection of your personal data',
    'privacy_intro_body':
        'Köpri ("We", "the Owner") is committed to ensuring the highest level of protection for your privacy and data security. This Privacy Policy (hereinafter "the Policy") explains what data is processed, what is not processed, where your data is stored, and how interaction with third parties occurs. By using Köpri, you agree to the data processing methods described in this Policy.',
    'privacy_sec1_title': '1. What we do NOT collect',
    'privacy_sec1_body':
        'Köpri is built on a "privacy-by-design" principle. We never, in any form, collect the following data:',
    'privacy_sec1_b1':
        'Personal identifying information (name, surname, patronymic, date of birth)',
    'privacy_sec1_b2':
        'Contact information (email, phone number, postal address)',
    'privacy_sec1_b3':
        'Payment and financial information (bank cards, accounts, transactions)',
    'privacy_sec1_b4':
        'Geolocation data (GPS coordinates, IP addresses, network metadata)',
    'privacy_sec1_b5':
        'Biometric data (fingerprints, facial recognition, voice samples)',
    'privacy_sec1_b6':
        'Advertising profiles, tracker identifiers, and analytical cookies',
    'privacy_sec2_title': '2. Data stored LOCALLY on your device',
    'privacy_sec2_body':
        'All your activity remains only on your personal device and is not transmitted to the internet. Locally stored data includes:',
    'privacy_sec2_b1':
        'Translation history and favorites — encrypted in the Hive database',
    'privacy_sec2_b2':
        'App settings: theme, language, font size, voice parameters',
    'privacy_sec2_b3':
        'Learning statistics: day streaks, XP points, levels, badges',
    'privacy_sec2_b4':
        'Google ML Kit offline translation models — only for the languages you selected',
    'privacy_sec2_b5': 'Profile data: username, emoji avatar, personal status',
    'privacy_sec3_title': '3. Android SYSTEM permissions',
    'privacy_sec3_body':
        'The App requests the following permissions, each of which is intended solely for a specific function and can be revoked at any time in Android system settings:',
    'privacy_sec3_b1':
        'CAMERA — translating text from photos via OCR (optical character recognition); data is processed only on the device',
    'privacy_sec3_b2':
        'MICROPHONE — voice input and dialogue mode; audio is used only for local recognition',
    'privacy_sec3_b3':
        'DISPLAY OVER OTHER APPS — clipboard translation bubble (overlay bubble)',
    'privacy_sec3_b4':
        'NOTIFICATIONS — operation of the background clipboard monitoring service',
    'privacy_sec3_b5':
        'INTERNET — solely for connecting to online translation services',
    'privacy_sec4_title': '4. NETWORK requests and third-party services',
    'privacy_sec4_body':
        'For online translation, the App connects to the internet, and the text you translate may be sent to the following third-party services. Each service has its own privacy policy:',
    'privacy_sec4_b1':
        'Google Translate API (translate.googleapis.com) — Google LLC Privacy Policy',
    'privacy_sec4_b2':
        'Lingva Translate — open-source proxy; data is not stored on the server',
    'privacy_sec4_b3':
        'MyMemory Translation API (mymemory.translated.net) — Translated Srl policy',
    'privacy_sec4_b4':
        'Firebase Crashlytics — only anonymous technical reports about app crashes (stack trace, device model, OS version)',
    'privacy_sec5_title': '5. OFFLINE mode and local processing',
    'privacy_sec5_body':
        'Offline translation via Google ML Kit is performed entirely on your device. Downloaded neural network models are stored in the local file system and are not sent to any server. The built-in Turkmen-Russian and Turkmen-English linguistic dictionaries also work completely offline and do not require a network connection. This ensures full availability of the translation service even without internet access and guarantees the maximum level of confidentiality for your texts.',
    'privacy_sec6_title': '6. CHILDREN\'s privacy (COPPA compliance)',
    'privacy_sec6_body':
        'Köpri does not knowingly collect personal data from children under 13 years of age (or the age established in the relevant jurisdiction — for example, 16 in the EU). We do not require verifiable parental or guardian consent to collect, use, or disclose children\'s personal data. If a parent or guardian believes that their child has provided us with personal data, they should contact us immediately — we will delete the data within 24 hours from both our servers (if present) and local devices.',
    'privacy_sec7_title': '7. CHANGES to the Policy and notifications',
    'privacy_sec7_body':
        'We may update this Policy from time to time. Material changes (new types of data collection, changes to third-party services, changes to legal grounds) will be notified in advance: via an in-app notification or a startup screen. By continuing to use the updated Policy on a regular basis, you accept the changes.',
    'privacy_contact_title': 'Contact us and your rights',
    'privacy_contact_body':
        'To request access to your data, correction, export, or complete deletion, as well as for any questions or suggestions regarding this Policy — contact us on Telegram:',
    'privacy_footer': 'Köpri · Last updated: August 2026',
    'danger_zone': 'Danger Zone',
  },
  AppLang.tr: {
    'app_name': 'Köpri',
    'nav_translate': 'Çeviri',
    'nav_conversation': 'Sohbet',
    'nav_phrasebook': 'İfadeler',
    'nav_flashcards': 'Kartlar',
    'nav_history': 'Geçmiş',
    'settings': 'Ayarlar',
    'appearance': 'Görünüm',
    'theme': 'Tema',
    'theme_dark': 'Koyu',
    'theme_light': 'Açık',
    'theme_system': 'Sistem',
    'language': 'Dil',
    'interface_language': 'Uygulama dili',
    'font_size': 'Yazı tipi boyutu',
    'speech_rate': 'Konuşma hızı',
    'data': 'Veriler',
    'clear_history': 'Geçmişi temizle',
    'clear_all': 'Hepsini temizle',
    'about': 'Hakkında',
    'version': 'Sürüm',
    'history': 'Geçmiş',
    'favorites': 'Favoriler',
    'no_history': 'Henüz çeviri yok',
    'no_favorites': 'Favori yok — yıldızla işaretle',
    'search': 'Ara…',
    'conversation_title': 'Sohbet modu',
    'tap_to_speak': 'Konuşmak için dokun',
    'listening': 'Dinleniyor…',
    'phrasebook_title': 'İfade kitabı',
    'flashcards_title': 'Bilgi kartları',
    'flashcards_empty': 'Kart yok — geçmişte yıldızla',
    'remember': 'Biliyorum',
    'forgot': 'Unuttum',
    'flip': 'Çevir',
    'copy': 'Kopyala',
    'copied': 'Kopyalandı ✓',
    'paste': 'Yapıştır',
    'clear': 'Temizle',
    'speak': 'Seslendir',
    'input_hint': 'Çevrilecek metni yazın…',
    'from': 'KAYNAK',
    'to': 'ÇEVİRİ',
    'translation_section': 'ÇEVİRİ',
    'default_source': 'Varsayılan kaynak dil',
    'default_target': 'Varsayılan hedef dil',
    'auto_translate': 'Otomatik çeviri',
    'auto_translate_desc': 'Yazarken çevir',
    'translate_delay': 'Gecikme',
    'speech_section': 'SES',
    'auto_speak': 'Otomatik seslendirme',
    'auto_speak_desc': 'Çeviriyi hemen seslendir',
    'volume': 'Ses seviyesi',
    'pitch': 'Ton',
    'listen_preview': 'Örneği dinle',
    'mic_listen_for': 'Dinleme süresi',
    'mic_pause': 'Sessizlikte dur',
    'phrasebook_section': 'İFADELER VE KARTLAR',
    'phrase_speak': 'İfade sesi',
    'phrase_speak_iface': 'Uygulama dili',
    'phrase_speak_english': 'İngilizce',
    'phrase_speak_both': 'İkisi de',
    'flashcard_session': 'Oturum boyutu',
    'spaced_rep': 'Aralıklı tekrar',
    'data_section': 'VERİLER',
    'auto_save_history': 'Geçmişi kaydet',
    'clear_favorites': 'Favorileri temizle',
    'history_exported': 'Geçmiş panoya kopyalandı',
    'history_imported': 'Geçmiş panodan alındı',
    'confirm': 'Onayla',
    'cancel': 'İptal',
    'look_section': 'GÖRÜNÜM',
    'accent_color': 'Vurgu rengi',
    'animations': 'Animasyonlar',
    'animations_desc': 'Geçişler ve Hero',
    'compact': 'Kompakt görünüm',
    'compact_desc': 'Daha sıkı listeler',
    'about_section': 'UYGULAMA',
    'licenses': 'Lisanslar',
    'share_app': 'Paylaş',
    'feedback': 'Geri bildirim',
    'export_history': 'Geçmişi dışa aktar (dosya)',
    'import_history': 'Geçmişi içe aktar (pano)',
    'auto_save_desc': 'Her çeviriyi kaydet',
    'auto_clean': 'Otomatik temizlik',
    'auto_clean_desc': 'Eski kayıtlar açılışta silinir',
    'no_data_clipboard': 'Panoda veri yok',
    'cleared': 'Temizlendi',
    'removed_stars': 'Yıldızlar kaldırıldı',
    'repeat': 'Tekrarla',
    'flashcard_session_desc': 'Tur başına kart sayısı',
    'spaced_rep_desc': 'Unutulan kartlar sonra döner',
    'offline_models_title': 'ÇEVRİMDIŞI MODELLER',
    'offline_models_desc':
        'Bu modeller çeviri dosyalarıdır. Çevirinin internetsiz çalışması için telefonunuza bir kez indirilir. Virüs veya gereksiz dosya değildir — kullandığınız diller için çeviri motorudur.',
    'offline_models_desc2':
        'Modeller uygulama verilerinden ayrı saklanır: önbelleği temizlemek onlara dokunmaz. Silerseniz endişelenmeyin — sonraki çeviride otomatik olarak tekrar indirilir. İndirmek için VPN gerekmez.',
    'offline_models_downloaded': 'İndirildi',
    'offline_models_empty':
        'Henüz model yok. İlk çevirinizde otomatik indirilir.',
    'offline_models_loading': 'Kontrol ediliyor…',
    'offline_models_delete_all': 'Tüm modelleri sil',
    'offline_models_deleted_one': 'Model silindi',
    'offline_models_deleted_all': 'Tüm modeller silindi',
    'offline_models_none': 'Silinecek model yok',
    'offline_models_note_bg':
        'Dikkat: ekranda indirme göstergesi görmeseniz bile endişelenmeyin — model arka planda sessizce indirilir ve sizi rahatsız etmez. İndirme tamamlanınca çeviri hazır olur.',
    'offline_models_format':
        'Her dil paketi sistemde dil koduyla etiketlenir (ör. af, en, ru). Bir çifti çevirmek için her iki dilin paketi gerekir, bu yüzden telefonunuzdaki dosyalar yalnızca kullandığınız çiftlere göre oluşturulur — gereksiz bir şey indirilmez.',
    'offline_models_en_note':
        'İngilizce paketi bazen sistemin temel setinde bulunur ve silinemeyebilir — bu normal ve güvenlidir.',
    'offline_models_could_not_delete': 'Silinemedi (muhtemelen sistem paketi)',
    'offline_models_deleted_some': 'Bazı modeller silindi',
    'translate_error': 'Çeviri başarısız. Bağlantıyı kontrol edin.',
    'analyzing': 'Analiz ediliyor…',
    'nav_camera': 'Kamera',
    'camera_title': 'Fotoğraftan metin çevirisi',
    'camera_subtitle': 'Fotoğraf çekin — metin otomatik çevrilecek',
    'camera_open': 'Kamerayı aç',
    'camera_gallery': 'Fotoğraflar',
    'camera_empty': 'Henüz fotoğraf yok',
    'camera_no_text': 'Fotoğrafta metin bulunamadı',
    'camera_translating': 'Çevriliyor…',
    'camera_original': 'ORİJİNAL',
    'camera_translation': 'ÇEVİRİ',
    'camera_deleted': 'Fotoğraf silindi',
    'camera_permission': 'Kamera izni gerekli',
    'clear_photos': 'Fotoğrafları temizle',
    'photos_cleared': 'Fotoğraflar temizlendi',
    'nav_profile': 'Profil',
    'profile_title': 'Profil',
    'profile_user_default': 'Kullanıcı',
    'profile_user_label': 'Kullanıcı adı',
    'profile_enter_name': 'Adınızı girin',
    'profile_activity': 'ETKİNLİK',
    'profile_translations': 'Çeviriler',
    'profile_favorites': 'Favoriler',
    'profile_cards': 'Kartlar',
    'profile_photos': 'Fotoğraflar',
    'profile_achievements': 'BAŞARILAR',
    'profile_quick': 'HIZLI İŞLEMLER',
    'profile_share': 'Profili paylaş',
    'profile_clear': 'Profili temizle',
    'profile_clear_msg': 'Adı ve avatarı sil?',
    'profile_cleared': 'Temizlendi',
    'profile_gallery': 'Galeri',
    'profile_camera': 'Kamera',
    'profile_remove_photo': 'Fotoğrafı kaldır',
    'profile_badge_hint': 'İlk rozet için 10 metin çevir',
    'badge_translator': 'Çevirmen (10+)',
    'badge_master': 'Usta (100+)',
    'badge_legend': 'Efsane (500+)',
    'badge_collector': 'Koleksiyoncu (20+)',
    'badge_learner': 'Öğrenci (50+)',
    'badge_photo': 'Fotoğraf çevirmeni (10+)',
    'profile_week': 'SON 7 GÜN',
    'profile_adv': 'GELİŞMİŞ İSTATİSTİKLER',
    'profile_top_lang': 'En sık dil',
    'profile_peak': 'Yoğun saat',
    'profile_avg_len': 'Ort. uzunluk',
    'profile_top_phrases': 'Sık ifadeler',
    'profile_phrase_day': 'GÜNÜN İFADESİ',
    'profile_bio_hint': 'Durum ekle',
    'profile_emoji': 'Emoji avatar',
    'profile_export': 'Dışa / İçe aktar',
    'profile_import': 'İçe aktar',
    'profile_import_hint': 'JSON yapıştır',
    'profile_exported_to': 'Kaydedildi:',
    'profile_imported': 'İçe aktarıldı:',
    'profile_clear_old': 'Eskileri sil',
    'profile_days': 'gün',
    'profile_feedback': 'Geri bildirim',
    'profile_hidden': 'Gizli rozet',
    'rar_common': 'Sıradan',
    'rar_rare': 'Nadir',
    'rar_epic': 'Epik',
    'rar_legendary': 'Efsanevi',
    'licenses_thanks_title': 'Teşekkürler',
    'licenses_thanks_desc':
        'Bu uygulama Flutter ve harika açık kaynak topluluk paketleri sayesinde geliştirildi.',
    'licenses_search': 'Paket ara…',
    'licenses_packages': 'paket',
    'licenses_not_found': 'Paket bulunamadı',
    'profile_feedback_title': 'Geri bildirim',
    'profile_feedback_desc':
        'Sorularınız veya önerileriniz mi var? Telegram bot üzerinden bize yazın. Mutlaka cevap vereceğiz!',
    'profile_feedback_open': 'Telegram\'ı aç',
    'profile_feedback_error': 'Telegram açılamadı',
    'profile_emoji_hint': 'Profil fotoğrafı yerine gösterilecek emojiyi seçin.',
    'profile_emoji_count': 'emoji',
    'export_empty': 'Geçmiş boş — dışa aktarılacak bir şey yok',
    'export_done': 'Kaydedilen kayıt:',
    'export_clipboard': 'ayrıca panoda',
    'export_error': 'Bir şeyler ters gitti, tekrar deneyin',
    'export_json_desc': 'Tüm geçmişi dosyaya kopyala',
    'export_csv_desc': 'Excel / Google Sheets için tablo',
    'import_desc': 'Başka telefondan geçmişi aktar',
    'import_howto':
        'Eski telefonda "Dışa aktar"a dokunun, metni kopyalayıp buraya yapıştırın.',
    'import_empty_field': 'Geçmişi (JSON) alana yapıştırın',
    'import_bad_format': 'Bu Köpri geçmişi değil — veriyi kontrol edin',
    'import_empty': 'İçe aktarılacak bir şey yok — geçmiş boş',
    'import_done': 'İçe aktarılan kayıt:',
    'clear_old_desc': 'Eski çevirileri sil',
    'profile_create_name': 'Ad oluştur',
    'profile_save_name': 'Kaydet',
    'profile_change_name': 'Değiştir',
    'profile_week_activity': 'Haftalık etkinlik',
    'level': 'Seviye',
    'xp_to_next_level': 'Sonraki seviyeye XP',
    'daily_goal': 'Günlük hedef',
    'phrases_more': 'ifade',
    'goal_completed': 'Hedef tamamlandı! Harika iş!',
    'phrases_remaining': 'Çevir',
    'streak_day': 'gün',
    'streak_days': 'gün',
    'streak_consecutive': 'art arda',
    'invalid_json': 'Geçersiz JSON formatı',
    'import_failed': 'İçe aktarma başarısız',
    'export_failed': 'Dışa aktarma başarısız',
    'apk_not_found': 'APK bulunamadı',
    'share_failed': 'Paylaşılamadı',
    'telegram_failed': 'Telegram açılamadı',
    'share_unavailable': 'Bu özellik yalnızca Android\'de kullanılabilir',

    // ═══════════════════════════════════════════════════════════════
    // TERMS OF SERVICE — Kullanım Koşulları
    // ═══════════════════════════════════════════════════════════════
    'terms_of_service': 'Kullanım Koşulları',
    'terms_intro_title': 'Sizinle aramızdaki yasal anlaşma',
    'terms_intro_body':
        'Köpri mobil uygulamasını ("Uygulama") indirerek, kurarak veya kullanarak, siz ("Kullanıcı") bu koşulları tam ve şartsız olarak kabul etmiş olursunuz. Bu koşulların herhangi bir bölümüne katılmıyorsanız, Uygulamayı kullanmayı derhal bırakmanızı ve cihazınızdan kaldırmanızı rica ederiz. Bu belge, siz ve Köpri geliştiricisi ("Biz", "Sahip") arasındaki yasal ilişkiyi düzenler.',
    'terms_sec1_title': '1. Lisans ve fikri mülkiyet',
    'terms_sec1_body':
        'Size, Uygulamayı yalnızca kişisel cihazınızda kullanmak üzere kişisel, münhasır olmayan, devredilemez, ücretsiz ve sınırlı bir lisans veriyoruz. Telif hakkı, ticari markalar, kaynak kodu, tasarım, logolar ve çeviri algoritmaları dahil tüm fikri mülkiyet hakları bizim mülkiyetimizde kalır. Açık yazılı iznimiz olmadan aşağıdaki işlemler kesinlikle yasaktır:',
    'terms_sec1_b1':
        'Uygulamanın ikili kodunu tersine mühendislik yapmak, derlemesini çözmek veya parçalarına ayırmak',
    'terms_sec1_b2':
        'Uygulamanın kaynak kodunu, yapısını veya algoritmalarını çıkarmaya çalışmak',
    'terms_sec1_b3':
        'Uygulamanın değiştirilmiş veya türetilmiş sürümlerini oluşturmak veya dağıtmak',
    'terms_sec1_b4':
        'Uygulamayı ticari amaçlarla kiralamak, satmak veya alt lisanslamak',
    'terms_sec2_title': '2. Çeviri kalitesi ve garanti verilmez',
    'terms_sec2_body':
        'Çeviriler, makine öğrenimi modelleri (Google ML Kit, Google Translate API, MyMemory Translation Memory), sinir ağları ve yerleşik dilbilimsel sözlük kullanılarak otomatik olarak oluşturulur. Makine çevirisi doğası gereği mutlak doğruluğu garanti edemez — anlamsal, dilbilgisel, pragmatik ve kültürel hatalar içerebilir. Uyarıyoruz:',
    'terms_sec2_b1':
        'Köpri çevirilerine tıbbi teşhisler, ilaç dozajları veya klinik tavsiyeler için güvenmeyin',
    'terms_sec2_b2':
        'Yasal sözleşmeler, mahkeme belgeleri veya düzenleyici gereklilikler için kullanmayın',
    'terms_sec2_b3':
        'Mali tablolar, bankacılık işlemleri veya vergi beyannameleri için kullanmayın',
    'terms_sec2_b4':
        'Kritik çeviriler için her zaman nitelikli bir insan çevirmen tarafından doğrulatın',
    'terms_sec3_title': '3. Sorumluluk sınırlaması',
    'terms_sec3_body':
        'Uygulama "OLDUĞU GİBİ" (AS IS) ve "MEVCUT OLDUĞU GİBİ" (AS AVAILABLE) esasına göre, herhangi bir açık veya zımni garanti olmaksızın sunulur. Yasaların izin verdiği azami ölçüde, aşağıdakilerden sorumlu değiliz:',
    'terms_sec3_b1':
        'Doğrudan, dolaylı, arızi, özel veya sonuçsal zararlar (veri kaybı dahil)',
    'terms_sec3_b2': 'Kazanç kaybı, iş kesintisi veya ticari zarar',
    'terms_sec3_b3':
        'Cihaz arızaları, hızlı pil bitmesi veya aşırı sistem kaynağı kullanımı',
    'terms_sec3_b4':
        'Üçüncü taraf hizmetlerinin (Google, MyMemory) kullanılamazlığı veya hataları',
    'terms_sec4_title': '4. Yasaklı kullanım ve Kullanıcı yükümlülükleri',
    'terms_sec4_body':
        'Uygulamayı kullanarak aşağıdaki faaliyetlerden kaçınmayı taahhüt edersiniz:',
    'terms_sec4_b1':
        'Suç içeren, saldırgan, iftira niteliğinde, pornografik veya şiddet içeren içeriklerin çevirisi',
    'terms_sec4_b2':
        'İzin olmaksızın telif hakkıyla korunan materyallerin çevrilmesi ve dağıtılması',
    'terms_sec4_b3':
        'Spam, kimlik avı, kötü amaçlı yazılım veya botnet faaliyeti için kullanma',
    'terms_sec4_b4':
        'Ulusal güvenliğe, askeri sırlara veya mahremiyete karşı faaliyetler',
    'terms_sec4_b5':
        'Otomatik komut dosyaları, botlar veya web kazıma yoluyla Uygulamayı aşırı yükleme',
    'terms_sec5_title': '5. Üçüncü taraf bileşenler ve açık kaynak',
    'terms_sec5_body':
        'Köpri, her biri kendi lisans koşulları altında sağlanan aşağıdaki üçüncü taraf kütüphaneleri ve açık kaynak bileşenleri kullanır:',
    'terms_sec5_b1': 'Flutter framework — BSD 3-Clause Lisansı (Google LLC)',
    'terms_sec5_b2':
        'Google ML Kit — Google LLC\'nin hizmet koşullarına uygun olarak',
    'terms_sec5_b3':
        'Hive, flutter_tts, shared_preferences ve diğerleri — ilgili MIT, Apache 2.0 veya BSD lisansları',
    'terms_sec5_b4':
        'Tam liste ve lisans metinleri, Uygulama ayarlarının Lisanslar bölümünde mevcuttur',
    'terms_sec6_title': '6. Geçerli hukuk ve uyuşmazlık çözümü',
    'terms_sec6_body':
        'Bu Koşullar, ikamet ettiğiniz ülkenin yasalarına göre yorumlanır ve yönetilir. Herhangi bir anlaşmazlık veya uyuşmazlık ilk olarak makul bir süre içinde müzakereler yoluyla çözülmeye çalışılır. Müzakereler başarısız olursa, uyuşmazlık yetkili mahkemede görülür. Bu Koşulların herhangi bir hükmü yasaya aykırı bulunursa, kalan hükümler tam yürürlükte kalır.',
    'terms_acceptance':
        'Köpri\'yi kullanarak, bu Kullanım Koşullarını ve Gizlilik Politikasını tamamen okuduğunuzu, anladığınızı ve bunlara uymayı kabul ettiğinizi onaylarsınız.',
    'terms_footer': 'Köpri · Yürürlük tarihi: Ağustos 2026',

    // ═══════════════════════════════════════════════════════════════
    // PRIVACY POLICY — Gizlilik Politikası
    // ═══════════════════════════════════════════════════════════════
    'privacy_policy': 'Gizlilik Politikası',
    'privacy_intro_title': 'Kişisel verilerinizin korunması',
    'privacy_intro_body':
        'Köpri ("Biz", "Sahip") gizliliğinizin ve veri güvenliğinizin en yüksek düzeyde korunmasını taahhüt eder. Bu Gizlilik Politikası (bundan sonra "Politika"), hangi verilerin işlendiğini, hangilerinin işlenmediğini, verilerinizin nerede saklandığını ve üçüncü taraflarla etkileşimin nasıl gerçekleştiğini açıklar. Köpri\'yi kullanarak, bu Politikada açıklanan veri işleme yöntemlerini kabul etmiş olursunuz.',
    'privacy_sec1_title': '1. NE toplamadığımız',
    'privacy_sec1_body':
        'Köpri, "tasarımla gizlilik" (privacy-by-design) ilkesi üzerine kuruludur. Aşağıdaki verileri asla ve hiçbir biçimde toplamayız:',
    'privacy_sec1_b1':
        'Kişiyi tanımlayan bilgiler (ad, soyad, baba adı, doğum tarihi)',
    'privacy_sec1_b2':
        'İletişim bilgileri (e-posta, telefon numarası, posta adresi)',
    'privacy_sec1_b3':
        'Ödeme ve finansal bilgiler (banka kartları, hesaplar, işlemler)',
    'privacy_sec1_b4':
        'Konum verileri (GPS koordinatları, IP adresleri, ağ meta verileri)',
    'privacy_sec1_b5':
        'Biyometrik veriler (parmak izi, yüz tanıma, ses örnekleri)',
    'privacy_sec1_b6':
        'Reklam profilleri, izleyici tanımlayıcıları ve analitik çerezler',
    'privacy_sec2_title': '2. Cihazınızda YEREL olarak saklanan veriler',
    'privacy_sec2_body':
        'Tüm etkinliğiniz yalnızca kişisel cihazınızda kalır ve internete iletilmez. Yerel olarak saklanan veriler şunları içerir:',
    'privacy_sec2_b1':
        'Çeviri geçmişi ve favoriler — Hive veritabanında şifrelenmiş olarak',
    'privacy_sec2_b2':
        'Uygulama ayarları: tema, dil, yazı tipi boyutu, ses parametreleri',
    'privacy_sec2_b3':
        'Öğrenme istatistikleri: gün serileri, XP puanları, seviyeler, rozetler',
    'privacy_sec2_b4':
        'Google ML Kit çevrimdışı çeviri modelleri — yalnızca seçtiğiniz diller için',
    'privacy_sec2_b5':
        'Profil verileri: kullanıcı adı, emoji avatar, kişisel durum',
    'privacy_sec3_title': '3. Android SİSTEM izinleri',
    'privacy_sec3_body':
        'Uygulama, her biri yalnızca belirli bir işlev için tasarlanmış ve Android sistem ayarlarından istenildiği zaman geri alınabilen aşağıdaki izinleri ister:',
    'privacy_sec3_b1':
        'KAMERA — OCR (optik karakter tanıma) aracılığıyla fotoğraflardaki metni çevirme; veriler yalnızca cihazda işlenir',
    'privacy_sec3_b2':
        'MİKROFON — sesli giriş ve diyalog modu; ses yalnızca yerel tanıma için kullanılır',
    'privacy_sec3_b3':
        'DİĞER UYGULAMALARIN ÜZERİNDE GÖSTERME — pano çeviri balonu (overlay bubble)',
    'privacy_sec3_b4':
        'BİLDİRİMLER — arka plan pano izleme hizmetinin çalışması',
    'privacy_sec3_b5':
        'İNTERNET — yalnızca çevrimiçi çeviri hizmetlerine bağlanmak için',
    'privacy_sec4_title': '4. AĞ istekleri ve üçüncü taraf hizmetleri',
    'privacy_sec4_body':
        'Çevrimiçi çeviri için Uygulama internete bağlanır ve çevirdiğiniz metin aşağıdaki üçüncü taraf hizmetlere gönderilebilir. Her hizmetin kendi gizlilik politikası vardır:',
    'privacy_sec4_b1':
        'Google Translate API (translate.googleapis.com) — Google LLC Gizlilik Politikası',
    'privacy_sec4_b2':
        'Lingva Translate — açık kaynak proxy; veriler sunucuda saklanmaz',
    'privacy_sec4_b3':
        'MyMemory Translation API (mymemory.translated.net) — Translated Srl politikası',
    'privacy_sec4_b4':
        'Firebase Crashlytics — yalnızca uygulama çökmeleri hakkında anonim teknik raporlar (stack trace, cihaz modeli, OS sürümü)',
    'privacy_sec5_title': '5. ÇEVRİMDIŞI modu ve yerel işleme',
    'privacy_sec5_body':
        'Google ML Kit aracılığıyla çevrimdışı çeviri tamamen cihazınızda gerçekleştirilir. İndirilen sinir ağı modelleri yerel dosya sisteminde saklanır ve hiçbir sunucuya gönderilmez. Yerleşik Türkmen-Rus ve Türkmen-İngiliz dilbilimsel sözlükler de tamamen çevrimdışı çalışır ve ağ bağlantısı gerektirmez. Bu, internet olmasa bile çeviri hizmetinin tam olarak kullanılabilirliğini sağlar ve metinlerinizin azami gizliliğini garanti eder.',
    'privacy_sec6_title': '6. ÇOCUKLARIN gizliliği (COPPA uyumu)',
    'privacy_sec6_body':
        'Köpri, 13 yaşın altındaki çocuklardan (veya ilgili yargı bölgesinde belirlenen yaştan — örneğin AB\'de 16) bilerek kişisel veri toplamaz. Çocukların kişisel verilerini toplamak, kullanmak veya ifşa etmek için ebeveyn veya vasisinin doğrulanabilir onayını istemeyiz. Bir ebeveyn veya vasi, çocuğunun bize kişisel veri sağladığına inanıyorsa, derhal bizimle iletişime geçmelidir — verileri 24 saat içinde hem sunucularımızdan (varsa) hem de yerel cihazlardan sileceğiz.',
    'privacy_sec7_title': '7. Politikadaki DEĞİŞİKLİKLER ve bildirimler',
    'privacy_sec7_body':
        'Bu Politikayı zaman zaman güncelleyebiliriz. Önemli değişiklikler (yeni veri toplama türleri, üçüncü taraf hizmetlerindeki değişiklikler, yasal gerekçelerdeki değişiklikler) hakkında önceden bildirimde bulunacağız: uygulama içi bildirim veya başlangıç ekranı aracılığıyla. Güncellenmiş Politikayı düzenli olarak kullanmaya devam ederek değişiklikleri kabul etmiş olursunuz.',
    'privacy_contact_title': 'Bize ulaşın ve haklarınız',
    'privacy_contact_body':
        'Verilerinize erişim, düzeltme, dışa aktarma veya tamamen silme talebinde bulunmak, ayrıca bu Politika ile ilgili herhangi bir soru veya öneri için Telegram üzerinden bize ulaşın:',
    'privacy_footer': 'Köpri · Son güncelleme: Ağustos 2026',
    'danger_zone': 'Tehlikeli Bölge',
  },
};
