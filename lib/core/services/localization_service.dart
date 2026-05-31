
/// App-wide text and voice translations for Mindfulness Garden.
///
/// This service is intentionally lightweight and stores language maps for
/// UI labels, voice prompts, and pose instructions.
/// Use `LocalizationService.translate(key, language)` for text and
/// `LocalizationService.translateList(key, language)` for voice phrase lists.
library;

enum AppLanguage {
  english,
  hindi,
  bengali,
  spanish,
  french,
  german,
  chinese,
}

extension AppLanguageExtension on AppLanguage {
  String get displayName {
    switch (this) {
      case AppLanguage.hindi:
        return 'Hindi';
      case AppLanguage.bengali:
        return 'Bengali';
      case AppLanguage.spanish:
        return 'Spanish';
      case AppLanguage.french:
        return 'French';
      case AppLanguage.german:
        return 'German';
      case AppLanguage.chinese:
        return 'Chinese';
      default:
        return 'English';
    }
  }

  String get localeCode {
    switch (this) {
      case AppLanguage.hindi:
        return 'hi-IN';
      case AppLanguage.bengali:
        return 'bn-IN';
      case AppLanguage.spanish:
        return 'es-ES';
      case AppLanguage.french:
        return 'fr-FR';
      case AppLanguage.german:
        return 'de-DE';
      case AppLanguage.chinese:
        return 'zh-CN';
      default:
        return 'en-US';
    }
  }
}

class LocalizationService {
  LocalizationService._();

  static AppLanguage languageFromName(String value) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => AppLanguage.english,
    );
  }

  static AppLanguage languageFromCode(String value) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.localeCode.toLowerCase() == value.toLowerCase(),
      orElse: () => AppLanguage.english,
    );
  }

  static String translate(String key, AppLanguage language) {
    final map =
        _localizedStrings[language] ?? _localizedStrings[AppLanguage.english]!;
    return map[key] ?? _localizedStrings[AppLanguage.english]![key] ?? key;
  }

  static List<String> translateList(String key, AppLanguage language) {
    final map = _localizedPhraseLists[language] ??
        _localizedPhraseLists[AppLanguage.english]!;
    return map[key] ??
        _localizedPhraseLists[AppLanguage.english]![key] ??
        <String>[];
  }

  static String translatePoseInstruction(
      String poseName, AppLanguage language) {
    final map = _poseInstructionStrings[language] ??
        _poseInstructionStrings[AppLanguage.english]!;
    return map[poseName] ??
        _poseInstructionStrings[AppLanguage.english]![poseName] ??
        poseName;
  }

  static final Map<AppLanguage, Map<String, String>> _localizedStrings = {
    AppLanguage.english: {
      'breathing_exercises_title': 'Breathing Exercises',
      'breathing_exercises_subtitle': 'Master your breath to master your mind',
      'breathing_guide':
          'Follow the animated circle. Inhale as it expands, exhale as it contracts.',
      'yoga_title': 'Yoga with Zeno',
      'yoga_subtitle': '2.5D immersive experience',
      'start_yoga_session': 'Begin Yoga Session',
      'select_environment': 'Select environment',
      'select_time_of_day': 'Select time of day',
      'sequence_preview': 'Sequence Preview',
      'back_to_main_menu': 'Back to Main Menu',
      'best_time': 'Best time',
      'recommended_time_morning': 'Morning',
      'recommended_time_evening': 'Evening',
      'recommended_time_night': 'Night',
      'recommended_time_midday': 'Midday',
      'pose_status': 'Pose {current} of {total}',
      'next_pose': 'Next Pose',
      'home_language': 'Language',
      'start': 'Start',
      'pause': 'Pause',
      'resume': 'Resume',
      'complete': 'Complete',
      'session_start':
          'The guided session begins now. Follow the breath and move with ease.',
      'session_complete':
          'Your session is complete. Carry this calm with you throughout the day.',
      'select_language': 'Select Language',
    },
    AppLanguage.hindi: {
      'breathing_exercises_title': 'साँस लेने के व्यायाम',
      'breathing_exercises_subtitle':
          'अपने मन को नियंत्रित करने के लिए अपनी साँस नियंत्रण करें',
      'breathing_guide':
          'एनिमेटेड वृत्त का पालन करें। यह फैलते समय साँस लें, सिकुड़ते समय छोड़ें।',
      'yoga_title': 'ज़ेनो के साथ योग',
      'yoga_subtitle': '2.5D इमर्सिव अनुभव',
      'start_yoga_session': 'योग सत्र शुरू करें',
      'select_environment': 'पर्यावरण चुनें',
      'select_time_of_day': 'दिन का समय चुनें',
      'sequence_preview': 'क्रमानुसार पूर्वावलोकन',
      'back_to_main_menu': 'मुख्य मेनू पर वापस जाएँ',
      'best_time': 'सर्वोत्तम समय',
      'recommended_time_morning': 'सुबह',
      'recommended_time_evening': 'शाम',
      'recommended_time_night': 'रात',
      'recommended_time_midday': 'दोपहर',
      'pose_status': 'आसन {current} में से {total}',
      'next_pose': 'अगला आसन',
      'home_language': 'भाषा',
      'start': 'प्रारंभ',
      'pause': 'विराम',
      'resume': 'जारी रखें',
      'complete': 'पूरा',
      'session_start':
          'मार्गदर्शित सत्र अब शुरू होता है। श्वास का अनुसरण करें और आसानी से चलें।',
      'session_complete':
          'आपका सत्र पूरा हुआ। इस शांति को अपने दिन भर के साथ रखें।',
      'select_language': 'भाषा चुनें',
    },
    AppLanguage.bengali: {
      'breathing_exercises_title': 'শ্বাস প্রশ্বাস ব্যায়াম',
      'breathing_exercises_subtitle':
          'মন নিয়ন্ত্রণ করতে আপনার শ্বাস নিয়ন্ত্রণ করুন',
      'breathing_guide':
          'অ্যানিমেটেড বৃত্ত অনুসরণ করুন। এটি বাড়ার সময় শ্বাস নিন, সঙ্কুচিত হলে বের করুন।',
      'yoga_title': 'জেনোর সাথে যোগ',
      'yoga_subtitle': '2.5D ডুবে যাওয়া অভিজ্ঞতা',
      'start_yoga_session': 'যোগ সেশন শুরু করুন',
      'select_environment': 'পরিবেশ নির্বাচন করুন',
      'select_time_of_day': 'দিনের সময় নির্বাচন করুন',
      'sequence_preview': 'সিকোয়েন্স পূর্বদর্শন',
      'back_to_main_menu': 'প্রধান মেনুতে ফিরে যান',
      'best_time': 'সেরা সময়',
      'recommended_time_morning': 'সকাল',
      'recommended_time_evening': 'সন্ধ্যা',
      'recommended_time_night': 'রাত',
      'recommended_time_midday': 'দুপুর',
      'pose_status': 'অ্যাসন {current} এর {total}',
      'next_pose': 'পরবর্তী অ্যাসন',
      'home_language': 'ভাষা',
      'start': 'শুরু',
      'pause': 'বিরতি',
      'resume': 'চালিয়ে যান',
      'complete': 'সম্পন্ন',
      'session_start':
          'গাইড করা সেশন এখন শুরু হচ্ছে। শ্বাস অনুসরণ করো এবং সহজে চল।',
      'session_complete':
          'তোমার সেশন সম্পন্ন। এই শান্তি তোমার দিনজুড়ে সাথে রাখো।',
      'select_language': 'ভাষা নির্বাচন করুন',
    },
    AppLanguage.spanish: {
      'breathing_exercises_title': 'Ejercicios de Respiración',
      'breathing_exercises_subtitle':
          'Domina tu respiración para dominar tu mente',
      'breathing_guide':
          'Sigue el círculo animado. Inhala cuando se expande y exhala cuando se contrae.',
      'yoga_title': 'Yoga con Zeno',
      'yoga_subtitle': 'Experiencia inmersiva 2.5D',
      'start_yoga_session': 'Iniciar sesión de yoga',
      'select_environment': 'Seleccionar ambiente',
      'select_time_of_day': 'Seleccionar hora del día',
      'sequence_preview': 'Vista previa de la secuencia',
      'back_to_main_menu': 'Volver al menú principal',
      'best_time': 'Mejor hora',
      'recommended_time_morning': 'Mañana',
      'recommended_time_evening': 'Tarde',
      'recommended_time_night': 'Noche',
      'recommended_time_midday': 'Mediodía',
      'pose_status': 'Postura {current} de {total}',
      'next_pose': 'Siguiente postura',
      'home_language': 'Idioma',
      'start': 'Iniciar',
      'pause': 'Pausa',
      'resume': 'Continuar',
      'complete': 'Completar',
      'session_start':
          'La sesión guiada empieza ahora. Sigue la respiración y muévete con facilidad.',
      'session_complete':
          'Tu sesión ha concluido. Lleva esta calma contigo todo el día.',
      'select_language': 'Selecciona idioma',
    },
    AppLanguage.french: {
      'breathing_exercises_title': 'Exercices de Respiration',
      'breathing_exercises_subtitle':
          'Maîtrisez votre respiration pour maîtriser votre esprit',
      'breathing_guide':
          'Suivez le cercle animé. Inspirez quand il s’agrandit, expirez quand il se contracte.',
      'yoga_title': 'Yoga avec Zeno',
      'yoga_subtitle': 'Expérience immersive 2.5D',
      'start_yoga_session': 'Commencer la séance de yoga',
      'select_environment': 'Choisir l’environnement',
      'select_time_of_day': 'Choisir le moment de la journée',
      'sequence_preview': 'Aperçu de la séquence',
      'back_to_main_menu': 'Retour au menu principal',
      'best_time': 'Meilleur moment',
      'recommended_time_morning': 'Matin',
      'recommended_time_evening': 'Soir',
      'recommended_time_night': 'Nuit',
      'recommended_time_midday': 'Midi',
      'pose_status': 'Posture {current} sur {total}',
      'next_pose': 'Prochaine posture',
      'home_language': 'Langue',
      'start': 'Démarrer',
      'pause': 'Pause',
      'resume': 'Reprendre',
      'complete': 'Terminé',
      'session_start':
          'La séance guidée commence maintenant. Suis le souffle et bouge avec aisance.',
      'session_complete':
          'Ta séance est terminée. Emporte ce calme avec toi toute la journée.',
      'select_language': 'Sélectionnez la langue',
    },
    AppLanguage.german: {
      'breathing_exercises_title': 'Atemübungen',
      'breathing_exercises_subtitle':
          'Meistere deinen Atem, um deinen Geist zu meistern',
      'breathing_guide':
          'Folge dem animierten Kreis. Atme ein, wenn er sich ausdehnt, atme aus, wenn er sich zusammenzieht.',
      'yoga_title': 'Yoga mit Zeno',
      'yoga_subtitle': 'Immersives 2.5D-Erlebnis',
      'start_yoga_session': 'Yoga-Sitzung starten',
      'select_environment': 'Umgebung wählen',
      'select_time_of_day': 'Tageszeit wählen',
      'sequence_preview': 'Sequenzvorschau',
      'back_to_main_menu': 'Zurück zum Hauptmenü',
      'best_time': 'Beste Zeit',
      'recommended_time_morning': 'Morgen',
      'recommended_time_evening': 'Abend',
      'recommended_time_night': 'Nacht',
      'recommended_time_midday': 'Mittag',
      'pose_status': 'Pose {current} von {total}',
      'next_pose': 'Nächste Pose',
      'home_language': 'Sprache',
      'start': 'Start',
      'pause': 'Pause',
      'resume': 'Fortsetzen',
      'complete': 'Fertig',
      'session_start':
          'Die geführte Sitzung beginnt jetzt. Folge dem Atem und bewege dich mit Leichtigkeit.',
      'session_complete':
          'Deine Sitzung ist beendet. Nimm diese Ruhe den ganzen Tag mit.',
      'select_language': 'Sprache wählen',
    },
    AppLanguage.chinese: {
      'breathing_exercises_title': '呼吸练习',
      'breathing_exercises_subtitle': '掌控你的呼吸，掌控你的心智',
      'breathing_guide': '跟随动画圆圈。它扩大时吸气，收缩时呼气。',
      'yoga_title': '与 Zeno 一起瑜伽',
      'yoga_subtitle': '2.5D 沉浸式体验',
      'start_yoga_session': '开始瑜伽课程',
      'select_environment': '选择环境',
      'select_time_of_day': '选择一天中的时间',
      'sequence_preview': '序列预览',
      'back_to_main_menu': '返回主菜单',
      'best_time': '最佳时间',
      'recommended_time_morning': '早晨',
      'recommended_time_evening': '傍晚',
      'recommended_time_night': '夜晚',
      'recommended_time_midday': '中午',
      'pose_status': '体式 {current} / {total}',
      'next_pose': '下一个体式',
      'home_language': '语言',
      'start': '开始',
      'pause': '暂停',
      'resume': '继续',
      'complete': '完成',
      'session_start': '引导课程现在开始。跟随呼吸，轻松移动。',
      'session_complete': '你的课程已完成。将这份平静带到整天。',
      'select_language': '选择语言',
    },
  };

  static final Map<AppLanguage, Map<String, List<String>>>
      _localizedPhraseLists = {
    AppLanguage.english: {
      'breathingIntro': [
        'Welcome, seeker. I am here to guide you. Let us begin with the breath — the bridge between body and mind.',
        'Peace be with you. The breath is your anchor. Let us breathe together and find stillness.',
        'Greetings. The mind is like water — when still, it reflects all things clearly. Let us still the waters.',
      ],
      'inhalePrompts': [
        'Breathe in... draw life into every cell.',
        'Inhale... feel the universe filling you.',
        'Breathe in deeply... you are receiving.',
      ],
      'holdPrompts': [
        'Hold... rest in this moment of fullness.',
        'Be still... this is the space between worlds.',
        'Hold gently... neither grasping nor releasing.',
      ],
      'exhalePrompts': [
        'Release... let go of all that does not serve you.',
        'Exhale... surrender what you cannot control.',
        'Breathe out... return to emptiness, which is fullness.',
      ],
      'poseTransitions': [
        'Now we move into the next posture. Let the body follow the breath.',
        'Transition with awareness. Each movement is a meditation.',
        'Shift gently. The body is a temple — move within it with reverence.',
      ],
      'sessionCompleteLines': [
        'You have done well, seeker. Carry this stillness into your day.',
        'The practice is complete. Remember — the peace you found here lives within you always.',
        'Well done. The lotus grows from mud, yet remains unstained. So too shall you.',
      ],
      'encouragement': [
        'The mind wanders — this is its nature. Gently return, without judgment.',
        'There is no failure in practice. Only returning, again and again.',
        'You are exactly where you need to be.',
      ],
    },
    AppLanguage.hindi: {
      'breathingIntro': [
        'स्वागत है। मैं आपका मार्गदर्शन करने के लिए यहां हूं। श्वास से शुरू करते हैं — शरीर और मन के बीच का सेतु।',
        'शांति आपके साथ हो। श्वास आपका लंगर है। चलिए साथ में साँस लेते हैं और स्थिरता पाते हैं।',
        'नमस्ते। मन पानी के समान है — जब शांत होता है, तो सब कुछ स्पष्ट रूप से प्रतिबिंबित करता है। चलिए पानी को शांत करें।',
      ],
      'inhalePrompts': [
        'साँस अंदर लें... प्रत्येक कोशिका में जीवन भरें।',
        'अंदर लें... ब्रह्मांड को अपने अन्दर भरते हुए अनुभव करें।',
        'गहराई से साँस लें... आप प्राप्त कर रहे हैं।',
      ],
      'holdPrompts': [
        'रुको... इस पूर्णता के क्षण में विश्राम करें।',
        'शांत रहें... यह दुनिया के बीच की जगह है।',
        'धीरे से रोको... न पकड़ो, न छोड़ो।',
      ],
      'exhalePrompts': [
        'छोड़ दें... जो भी सेवा नहीं करता उसे पहचानें और छोड़ दें।',
        'साँस बाहर छोड़ें... जो नियंत्रित नहीं कर सकते उसे त्याग दें।',
        'बाहिर निकलें... शून्यता में लौटें, जो पूर्णता है।',
      ],
      'poseTransitions': [
        'अब हम अगले आसन में जाते हैं। शरीर को साँस के साथ चलने दें।',
        'सावधानी से बदलाव करें। प्रत्येक आंदोलन ध्यान है।',
        'मुलायम रूप से स्थानांतरित करें। शरीर एक मंदिर है — इसमें सम्मान के साथ चलें।',
      ],
      'sessionCompleteLines': [
        'तुमने अच्छा किया, साधक। इस शांति को अपने दिन में ले जाओ।',
        'अभ्यास पूरा हुआ। याद रखें — यह शांति जो तुमने यहां पाई, वह हमेशा तुम्हारे भीतर रहती है।',
        'शाबाश। कमल की पत्तियाँ कीचड़ से उगती हैं, फिर भी अव्यक्त रहती हैं। तुम्हारे साथ भी ऐसा ही होगा।',
      ],
      'encouragement': [
        'मन भटकता है — यह उसकी प्रकृति है। बिना निर्णय किए धीरे से वापस लाओ।',
        'अभ्यास में कोई विफलता नहीं है। केवल लौटना है, बार-बार।',
        'तुम वही हो जहां तुम्हें होना चाहिए।',
      ],
    },
    AppLanguage.bengali: {
      'breathingIntro': [
        'স্বাগতম। আমি আপনাকে গাইড করতে এখানে এসেছি। আসুন শ্বাস দিয়ে শুরু করি — শরীর এবং মনের মধ্যে সেতু।',
        'শান্তি তোমার সাথে থাকুক। শ্বাস তোমার নোংড়া। আসুন একসাথে শ্বাস নেই এবং স্থিরতা খুঁজে নেই।',
        'নমস্কার। মন পানির মতো — যখন শান্ত হয়, তখন সব কিছু পরিষ্কারভাবে প্রতিফলিত হয়। আসুন পানি স্থির করি।',
      ],
      'inhalePrompts': [
        'শ্বাস নাও... প্রতিটি কোষে জীবন ভরাও।',
        'অন্তর্ভুক্ত হও... ব্রহ্মাণ্ড তোমার ভিতরে ভরে উঠেছে অনুভব করো।',
        'গভীরভাবে শ্বাস নাও... তুমি গ্রহণ করছো।',
      ],
      'holdPrompts': [
        'থাও... এই পূর্ণতার মুহূর্তে বিশ্রাম নাও।',
        'শান্ত হও... এটি বিশ্বের মধ্যে স্থান।',
        'হালকা শোনো... না ধরো, না ছাড়ো।',
      ],
      'exhalePrompts': [
        'ছেড়ে দাও... যা কাজে আসে না তা ছেড়ে দাও।',
        'শ্বাস ছেড়ে দাও... যা নিয়ন্ত্রণ করতে পারো না তা আনুগত্য কর।',
        'বাহিরে নিঃশ্বাস নাও... শূন্যতায় ফিরে যাও, যা পূর্ণতা।',
      ],
      'poseTransitions': [
        'এখন আমরা পরবর্তী পাসে যাই। শ্বাসের সাথে শরীরকে অগ্রসর হতে দাও।',
        'সচেতনভাবে পরিবর্তন করো। প্রতিটি গতি একটি ধ্যান।',
        'নরমভাবে স্থানান্তর করো। শরীর একটি মন্দির — সম্মানের সাথে এর মধ্যে চল।',
      ],
      'sessionCompleteLines': [
        'তুমি ভাল করেছো, অন্বেষণকারী। এই স্থিরতাকে তোমার দিনে নিয়ে যাও।',
        'অনুশীলন সম্পন্ন। মনে রেখো — যা শান্তি তুমি এখানে পেয়েছো, তা সর্বদা তোমার ভেতরে থাকে।',
        'শুভ work। পদ্ম কখনও নোংরা হয় না, তবুও মাটি থেকে উঠে। তোমার সাথেও তাই হবে।',
      ],
      'encouragement': [
        'মন ভ্রমণ করে — এটি তার প্রকৃতি। বিনা বিচার করে ধীরে ফিরে আসো।',
        'অনুশীলনে কোনো ব্যর্থতা নেই। শুধু ফিরে আসা, বারবার।',
        'তুমি ঠিক সেখানে আছো যেখানে তোমাকে থাকতে হবে।',
      ],
    },
    AppLanguage.spanish: {
      'breathingIntro': [
        'Bienvenido, buscador. Estoy aquí para guiarte. Comencemos con la respiración, el puente entre el cuerpo y la mente.',
        'La paz esté contigo. La respiración es tu ancla. Respiremos juntos y encontremos quietud.',
        'Saludos. La mente es como el agua — cuando está quieta, refleja todo claramente. Vamos a calmar las aguas.',
      ],
      'inhalePrompts': [
        'Inhala... llena cada célula de vida.',
        'Inhala... siente el universo llenándote.',
        'Respira profundamente... estás recibiendo.',
      ],
      'holdPrompts': [
        'Mantén... descansa en este momento de plenitud.',
        'Permanece en calma... este es el espacio entre mundos.',
        'Sujeta con suavidad... ni agarrando ni soltando.',
      ],
      'exhalePrompts': [
        'Suelta... deja ir lo que no te sirve.',
        'Exhala... entrégate a lo que no puedes controlar.',
        'Expulsa el aire... vuelve al vacío, que es plenitud.',
      ],
      'poseTransitions': [
        'Ahora nos movemos a la siguiente postura. Deja que el cuerpo siga a la respiración.',
        'Transiciona con conciencia. Cada movimiento es una meditación.',
        'Cambia suavemente. El cuerpo es un templo — muévete dentro de él con reverencia.',
      ],
      'sessionCompleteLines': [
        'Has hecho bien, buscador. Lleva esta quietud a tu día.',
        'La práctica está completa. Recuerda — la paz que encontraste aquí vive dentro de ti siempre.',
        'Bien hecho. El loto crece del barro, pero permanece inmaculado. Así también serás tú.',
      ],
      'encouragement': [
        'La mente vaga — esa es su naturaleza. Vuelve suavemente, sin juicio.',
        'No hay fracaso en la práctica. Solo volver, una y otra vez.',
        'Estás exactamente donde necesitas estar.',
      ],
    },
    AppLanguage.french: {
      'breathingIntro': [
        'Bienvenue, chercheur. Je suis ici pour te guider. Commençons par la respiration — le pont entre le corps et l’esprit.',
        'Que la paix soit avec toi. La respiration est ton ancre. Respirons ensemble et trouvons la quiétude.',
        'Salutations. L’esprit est comme l’eau — quand il est immobile, il reflète tout clairement. Calmons les eaux.',
      ],
      'inhalePrompts': [
        'Inspire... remplis chaque cellule de vie.',
        'Inspire... sens l’univers te remplir.',
        'Inspire profondément... tu reçois.',
      ],
      'holdPrompts': [
        'Retiens... repose dans ce moment de plénitude.',
        'Reste immobile... c’est l’espace entre les mondes.',
        'Retiens doucement... ni ne t’accroche, ni ne relâche.',
      ],
      'exhalePrompts': [
        'Libère... laisse partir ce qui ne te sert pas.',
        'Expire... abandonne ce que tu ne peux pas contrôler.',
        'Sors l’air... retourne au vide, qui est plénitude.',
      ],
      'poseTransitions': [
        'Nous passons maintenant à la posture suivante. Laisse le corps suivre la respiration.',
        'Transite avec conscience. Chaque mouvement est une méditation.',
        'Déplace-toi doucement. Le corps est un temple — bouge à l’intérieur avec révérence.',
      ],
      'sessionCompleteLines': [
        'Tu as bien fait, chercheur. Emporte cette tranquillité dans ta journée.',
        'La pratique est terminée. Souviens-toi — la paix que tu as trouvée ici vit toujours en toi.',
        'Bien joué. Le lotus pousse dans la boue, mais reste immaculé. Il en sera de même pour toi.',
      ],
      'encouragement': [
        'L’esprit vagabonde — telle est sa nature. Reviens doucement, sans jugement.',
        'Il n’y a pas d’échec dans la pratique. Seulement retourner, encore et encore.',
        'Tu es exactement là où tu dois être.',
      ],
    },
    AppLanguage.german: {
      'breathingIntro': [
        'Willkommen, Suchender. Ich bin hier, um dich zu führen. Lass uns mit dem Atem beginnen — der Brücke zwischen Körper und Geist.',
        'Frieden sei mit dir. Der Atem ist dein Anker. Lass uns gemeinsam atmen und Stille finden.',
        'Grüße. Der Geist ist wie Wasser — wenn er still ist, spiegelt er alles klar wider. Lass uns das Wasser beruhigen.',
      ],
      'inhalePrompts': [
        'Atme ein... fülle jede Zelle mit Leben.',
        'Atme ein... spüre, wie das Universum dich erfüllt.',
        'Atme tief ein... du empfängst.',
      ],
      'holdPrompts': [
        'Halte... ruhe in diesem Moment der Fülle.',
        'Sei still... dies ist der Raum zwischen den Welten.',
        'Halte sanft... weder greifen noch loslassen.',
      ],
      'exhalePrompts': [
        'Lass los... gib frei, was dir nicht dient.',
        'Atme aus... übergib dich dem, was du nicht kontrollieren kannst.',
        'Atme aus... kehre zurück zur Leere, die Fülle ist.',
      ],
      'poseTransitions': [
        'Jetzt gehen wir in die nächste Haltung. Lass den Körper dem Atem folgen.',
        'Wechsle bewusst. Jede Bewegung ist Meditation.',
        'Bewege dich sanft. Der Körper ist ein Tempel — bewege dich mit Ehrfurcht darin.',
      ],
      'sessionCompleteLines': [
        'Du hast gut gemacht, Suchender. Trage diese Stille in deinen Tag.',
        'Die Praxis ist abgeschlossen. Denk daran — der Frieden, den du hier gefunden hast, lebt immer in dir.',
        'Gut gemacht. Die Lotusblume wächst aus Schlamm, bleibt aber makellos. So wirst auch du sein.',
      ],
      'encouragement': [
        'Der Geist wandert — das ist seine Natur. Kehre sanft zurück, ohne zu urteilen.',
        'Es gibt kein Scheitern in der Praxis. Nur Rückkehr, immer wieder.',
        'Du bist genau dort, wo du sein musst.',
      ],
    },
    AppLanguage.chinese: {
      'breathingIntro': [
        '欢迎，探索者。我在这里引导你。让我们从呼吸开始——身体与心灵之间的桥梁。',
        '愿平安与你同在。呼吸是你的锚。让我们一起呼吸，找到宁静。',
        '问候。心灵如水——当它平静时，一切都清晰地反射。让我们让水安静。',
      ],
      'inhalePrompts': [
        '吸气...将生命注入每一个细胞。',
        '吸气...感受宇宙充满你。',
        '深吸一口气...你正在接收。',
      ],
      'holdPrompts': [
        '保持...在这片刻的充盈中休息。',
        '保持静止...这是世界之间的空间。',
        '轻轻保持...既不抓紧也不释放。',
      ],
      'exhalePrompts': [
        '释放...放下不再服务于你的事物。',
        '呼气...顺从你无法控制的事物。',
        '呼出...返回到虚无，那就是圆满。',
      ],
      'poseTransitions': [
        '现在我们进入下一个体式。让身体随着呼吸移动。',
        '用觉知转换。每一个动作都是一次冥想。',
        '轻柔地转换。身体是庙宇——在其中以敬意移动。',
      ],
      'sessionCompleteLines': [
        '你做得很好，探索者。将这份宁静带入你的一天。',
        '练习完成。记住——你在这里找到的平静会永远留在你体内。',
        '干得好。莲花从泥中生长，却仍然纯洁。你也会如此。',
      ],
      'encouragement': [
        '心灵漂泊——这是它的本性。轻柔地回归，不评判。',
        '练习中没有失败。只有一而再再而三的回归。',
        '你正处在你需要在的位置。',
      ],
    },
  };

  static final Map<AppLanguage, Map<String, String>> _poseInstructionStrings = {
    AppLanguage.english: {
      'Mountain Pose':
          'Stand as a mountain — rooted, immovable, yet open to the sky.',
      'Warrior I':
          'Be the warrior of peace. Ground your feet. Reach toward the heavens.',
      'Tree Pose':
          'Find your centre. The tree bends in the wind but its roots hold firm.',
      "Warrior I (other)":
          'Switch sides. Keep your energy grounded and your breath steady.',
      "Child's Pose":
          'Return to the earth. Rest here. You need not strive in this moment.',
      'Downward Dog':
          'Lengthen the spine. Let gravity do the work. Surrender to the pose.',
      'Lotus Meditation':
          'Sit in stillness. The lotus blooms in muddy water — so does wisdom.',
    },
    AppLanguage.hindi: {
      'Mountain Pose':
          'पर्वत के समान खड़े रहें — जड़ें मजबूत, अविचल, फिर भी आकाश के लिए खुला।',
      'Warrior I':
          'शांति का योद्धा बनो। अपने पैर जमीन पर रखें। स्वर्ग की ओर बढ़ो।',
      'Tree Pose':
          'अपना केंद्र खोजो। पेड़ हवा में झुकता है, लेकिन उसकी जड़ें मजबूत रहती हैं।',
      "Warrior I (other)":
          'दूसरी ओर स्विच करें। अपनी ऊर्जा को जमीन पर रखें और अपनी सांस को स्थिर रखें।',
      "Child's Pose":
          'पृथ्वी की ओर लौटो। यहां आराम करो। इस क्षण में तुम्हें प्रयास करने की आवश्यकता नहीं है।',
      'Downward Dog':
          'रीढ़ को लंबा करो। गुरुत्वाकर्षण को काम करने दो। आसन को समर्पित करें।',
      'Lotus Meditation':
          'स्थिरता में बैठो। कमल की माला कीचड़ में खिलती है — वैसे ही बुद्धि भी।',
    },
    AppLanguage.bengali: {
      'Mountain Pose':
          'পর্বতের মতো দাঁড়াও — স্থির, অচল, তবুও আকাশের জন্য উন্মুক্ত।',
      'Warrior I':
          'শান্তির যোদ্ধা হও। তোমার পা মাটিতে দৃঢ় রাখো। আকাশের দিকে পৌঁছাও।',
      'Tree Pose':
          'তোমার কেন্দ্র খুঁজে পাও। গাছ বায়ুতে হেলে যায়, কিন্তু এর শিকড় দৃঢ় থাকে।',
      "Warrior I (other)":
          'অন্য দিকে স্যুইচ করো। তোমার শক্তি মাটিতে রেখো এবং তোমার শ্বাস স্থির রাখো।',
      "Child's Pose":
          'মাটিতে ফিরে যাও। এখানে বিশ্রাম করো। এই মুহূর্তে তোমার প্রচেষ্টা করার দরকার নেই।',
      'Downward Dog':
          'মেরুদণ্ডটি দীর্ঘ করো। ভারসাম্যকে কাজ করতে দাও। আসনে আত্মসমর্পণ করো।',
      'Lotus Meditation': 'স্থিরভাবে বসো। পদ্ম কাদায় ফোটে — তেমনি জ্ঞানও।',
    },
    AppLanguage.spanish: {
      'Mountain Pose':
          'Párate como una montaña — enraizada, inmóvil, pero abierta al cielo.',
      'Warrior I':
          'Sé el guerrero de la paz. Planta tus pies. Extiéndete hacia los cielos.',
      'Tree Pose':
          'Encuentra tu centro. El árbol se inclina con el viento pero sus raíces se mantienen firmes.',
      "Warrior I (other)":
          'Cambia de lado. Mantén tu energía centrada y tu respiración constante.',
      "Child's Pose":
          'Vuelve a la tierra. Descansa aquí. No necesitas esforzarte en este momento.',
      'Downward Dog':
          'Alarga la columna. Deja que la gravedad haga el trabajo. Ríndete a la postura.',
      'Lotus Meditation':
          'Siéntate en quietud. El loto florece en agua fangosa — así también la sabiduría.',
    },
    AppLanguage.french: {
      'Mountain Pose':
          'Tiens-toi comme une montagne — enraciné, immobile, mais ouvert au ciel.',
      'Warrior I':
          'Sois le guerrier de la paix. Enracine tes pieds. Étends-toi vers les cieux.',
      'Tree Pose':
          'Trouve ton centre. L’arbre se plie dans le vent mais ses racines tiennent bon.',
      "Warrior I (other)":
          'Change de côté. Garde ton énergie ancrée et ta respiration stable.',
      "Child's Pose":
          'Reviens à la terre. Repose-toi ici. Tu n’as pas besoin de t’efforcer en ce moment.',
      'Downward Dog':
          'Allonge la colonne. Laisse la gravité faire le travail. Abandonne-toi à la posture.',
      'Lotus Meditation':
          'Assieds-toi dans le silence. Le lotus fleurit dans la boue — tel est aussi la sagesse.',
    },
    AppLanguage.german: {
      'Mountain Pose':
          'Steh wie ein Berg — verwurzelt, unbeweglich, aber offen zum Himmel.',
      'Warrior I':
          'Sei der Krieger des Friedens. Erd deine Füße. Strecke dich gen Himmel.',
      'Tree Pose':
          'Finde dein Zentrum. Der Baum beugt sich im Wind, aber seine Wurzeln halten fest.',
      "Warrior I (other)":
          'Wechsle die Seite. Halte deine Energie geerdet und deinen Atem ruhig.',
      "Child's Pose":
          'Kehre zur Erde zurück. Ruh dich hier aus. Du musst dich in diesem Moment nicht anstrengen.',
      'Downward Dog':
          'Strecke die Wirbelsäule. Lass die Schwerkraft die Arbeit tun. Gib dich der Haltung hin.',
      'Lotus Meditation':
          'Sitze in Stille. Die Lotusblume blüht im Schlamm — so auch die Weisheit.',
    },
    AppLanguage.chinese: {
      'Mountain Pose': '像山一样站立——根深蒂固，不动摇，但向天空敞开。',
      'Warrior I': '成为和平的战士。稳住双脚。向天空伸展。',
      'Tree Pose': '找到你的中心。树在风中弯曲，但根牢牢扎在地里。',
      "Warrior I (other)": '换边。保持你的能量扎根，呼吸稳定。',
      "Child's Pose": '回归大地。在这里休息。此刻你无需努力。',
      'Downward Dog': '拉长脊柱。让重力工作。向体式投降。',
      'Lotus Meditation': '静坐。莲花在泥中开放——智慧亦然。',
    },
  };
}
