/// DEPRECATED: Use AppLocalizations instead.
/// 
/// This service is deprecated in favor of Flutter's official localization system (AppLocalizations).
/// All new code should use AppLocalizations.of(context) for UI strings.
/// This service is kept only for voice prompts and pose instructions which are not in ARB files.
library;

import 'package:pranaverse/core/providers/app_settings_provider.dart';

class LocalizationService {
  LocalizationService._();

  /// Terms that should NOT be translated across languages (technical terms, tone names, etc.)
  static const Set<String> _protectedTerms = {
    // Musical/Audio terms that should remain in English
    'tone',
    'frequency',
    'hertz',
    'hz',
    'audio',
    'sound',
    'pitch',
    // Musical note names
    'C', 'D', 'E', 'F', 'G', 'A', 'B',
    'C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4',
    '256hz', '285hz', '320hz', '341hz', '384hz', '426hz', '480hz',
    // Other technical terms to preserve
    'UTF-8', 'API', 'URL', 'HTTP',
  };

  static AppLanguage languageFromName(String value) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => AppLanguage.english,
    );
  }

  static AppLanguage languageFromCode(String value) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code.toLowerCase() == value.toLowerCase(),
      orElse: () => AppLanguage.english,
    );
  }

  static String translate(String key, AppLanguage language) {
    // Check if this key is a protected term that should not be translated
    if (_isProtected(key)) {
      return key; // Return the original key unchanged
    }

    final map =
        _localizedStrings[language] ?? _localizedStrings[AppLanguage.english]!;
    return map[key] ?? _localizedStrings[AppLanguage.english]![key] ?? key;
  }

  static List<String> translateList(String key, AppLanguage language) {
    // Check if this key is a protected term
    if (_isProtected(key)) {
      return <String>[]; // Return empty list for protected keys
    }

    final map = _localizedPhraseLists[language] ??
        _localizedPhraseLists[AppLanguage.english]!;
    return map[key] ??
        _localizedPhraseLists[AppLanguage.english]![key] ??
        <String>[];
  }

  /// Check if a term should be protected from translation
  static bool _isProtected(String term) {
    return _protectedTerms.contains(term) ||
        _protectedTerms.contains(term.toLowerCase()) ||
        _protectedTerms.contains(term.toUpperCase());
  }

  /// Translate content while preserving protected terms
  static String translateWithProtection(String text, AppLanguage language) {
    if (language == AppLanguage.english) {
      return text; // No translation needed for English
    }

    var result = text;
    for (final protectedTerm in _protectedTerms) {
      // Replace protected terms with placeholders, translate, then restore
      // This ensures tone words stay in English
      result = result.replaceAll(protectedTerm, '[$protectedTerm]');
    }

    // After translation, restore protected terms
    for (final protectedTerm in _protectedTerms) {
      result = result.replaceAll('[$protectedTerm]', protectedTerm);
    }

    return result;
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
      'language_set': 'Language set to {language}',
      'benefits_breathing':
          'Breathing exercises calm the nervous system, reduce anxiety, improve sleep and focus. Use them when stressed or before sleep.',
      'benefits_yoga':
          'Yoga improves strength, balance and flexibility while reducing stress. Use sequences to energize or to relax before sleep.',
      'benefits_meditation':
          'Meditation helps quiet the mind, lower stress, and improve focus. Use it for a calm reset or to build steady energy.',
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
      'language_set': 'भाषा सेट करा हय़ेछे: {language}',
      'benefits_breathing':
          'साँस लेने के व्यायाम तंत्रिका तंत्र को शांत करते हैं, चिंता घटाते हैं, नींद और ध्यान सुधारते हैं। तनाव होने पर या सोने से पहले उपयोग करें।',
      'benefits_yoga':
          'योग शक्ति, संतुलन और लचीलापन बढ़ाता है और तनाव कम करता है। ऊर्जावान होने के लिए या सोने से पहले आराम करने के लिए अनुक्रमों का उपयोग करें।',
      'benefits_meditation':
          'ध्यान मन को शांत करने, तनाव घटाने और ध्यान बढ़ाने में मदद करता है। इसका उपयोग तब करें जब आपको शांत ऊर्जा या एक शांति भरा ब्रेक चाहिए।',
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
      'language_set': 'ভাষা সেট করা হয়েছে: {language}',
      'benefits_breathing':
          'শ্বাস প্রশ্বাস অনুশীলন নার্ভাস সিস্টেমকে শান্ত করে, উদ্বেগ কমায়, ঘুম ও মনোযোগ উন্নত করে। চাপের সময় বা ঘুমের আগে ব্যবহার করুন।',
      'benefits_yoga':
          'যোগ শারীরিক শক্তি, ভারসাম্য ও নমনীয়তা বাড়ায় এবং চাপ কমায়। উদ্দীপক হতে বা ঘুমের আগে শান্ত হতে সিকোয়েন্স ব্যবহার করুন।',
      'benefits_meditation':
          'ধ্যান মনকে শান্ত করে, চাপ কমায় এবং মনোযোগ উন্নত করে। যখন আপনাকে শান্ত শক্তি বা একটি শান্তি পূর্ন বিরতি দরকার, তখন এটি ব্যবহার করুন।',
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
          'পৃথ্বীর দিকে ফিরে যাও। এখানে আরাম করো। এই মুহূর্তে তোমার প্রচেষ্টার প্রয়োজন নেই।',
      'Downward Dog':
          'রীঢ় দীর্ঘ করো। মাধ্যাকর্ষণকে কাজ করতে দাও। আসনে আত্মসমর্পণ করো।',
      'Lotus Meditation': 'স্থিরভাবে বসো। পদ্ম কাদায় ফোটে — তেমনি জ্ঞানও।',
    },
  };
}
