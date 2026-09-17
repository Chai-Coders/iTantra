import 'package:flutter_tts/flutter_tts.dart';

class SpeechEngine {
  static final SpeechEngine _instance = SpeechEngine._internal();
  factory SpeechEngine() => _instance;
  SpeechEngine._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  static const Map<String, String> _localeMap = {
    'Malayalam': 'ml-IN',
    'Hindi': 'hi-IN',
    'Gujarati': 'gu-IN',
    'Marathi': 'mr-IN',
    'Kannada': 'kn-IN',
    'Tamil': 'ta-IN',
    'Telugu': 'te-IN',
    'Odia': 'or-IN',
    'Bengali': 'bn-IN',
    'English': 'en-IN',
  };

  static const Map<String, Map<String, String>> _phraseBook = {
    'evacuation': {
      'English': 'Evacuate immediately. Proceed to the shelter on Hill Top.',
      'Malayalam': 'ഉടൻ തന്നെ ഒഴിഞ്ഞുപോകുക. ഹിൽ ടോപ്പിലെ അഭയകേന്ദ്രത്തിലേക്ക് പോകുക.',
      'Hindi': 'तुरंत सुरक्षित स्थान पर जाएं। हिल टॉप आश्रय की ओर बढ़ें।',
      'Bengali': 'অবিলম্বে নিরাপদ স্থানে সরিয়ে যান। হিল টপ আশ্রয়ে পৌঁছান।',
      'Tamil': 'உடனடியாக வெளியேறவும். ஹில் டாப் முகாமிற்கு செல்லவும்.',
      'Telugu': 'వెంటనే ఖాళీ చేయండి. హిల్ టాప్ ఆశ్రయానికి వెళ్లండి.',
      'Kannada': 'ತಕ್ಷಣವೇ ಖಾಲಿ ಮಾಡಿ. ಹಿಲ್ ಟಾಪ್ ಆಶ್ರಯಕ್ಕೆ ತೆರಳಿ.',
      'Marathi': 'त्वरित सुरक्षित स्थळी स्थળાंतर करा. हिल टॉप निवाऱ्याकडे जा.',
      'Gujarati': 'તરત જ સુરક્ષિત સ્થળે ખસી જાઓ. હિલ ટોપ શેલ્ટર તરફ આગળ વધો.',
      'Odia': 'ତୁରନ୍ତ ସୁରକ୍ଷିତ ସ୍ଥାନକୁ ଯାଆନ୍ତୁ। ହିଲ୍ ଟପ୍ ଆଶ୍ରୟସ୍ଥଳକୁ ଯାଆନ୍ତୁ।',
    },
    'check_in': {
      'English': 'Evacuation teams arriving at sector junction. Confirm status.',
      'Malayalam': 'രക്ഷാപ്രവർത്തകർ സെക്ടർ ജംഗ്ഷനിൽ എത്തിക്കൊണ്ടിരിക്കുന്നു. സ്ഥിതി സ്ഥിരീകരിക്കുക.',
      'Hindi': 'बचाव दल सेक्टर जंक्शन पर पहुंच रहा है। अपनी स्थिति की पुष्टि करें।',
      'Bengali': 'উদ্ধারকারী দল সেক্টর জংশনে পৌঁছাচ্ছে। অবস্থান নিশ্চিত করুন।',
      'Tamil': 'மீட்புக் குழுவினர் சந்திப்பை அடைகின்றனர். நிலையை உறுதிப்படுத்தவும்.',
      'Telugu': 'రెస్క్యూ బృందాలు సెక్టార్ జంక్షన్‌కు చేరుకుంటున్నాయి. స్థితిని నిర్ధారించండి.',
      'Kannada': 'ರಕ್ಷಣಾ ತಂಡಗಳು ವಲಯ ಜಂಕ್ಷನ್‌ಗೆ ತಲುಪುತ್ತಿವೆ. ಸ್ಥಿತಿಯನ್ನು ದೃಢೀಕರಿಸಿ.',
      'Marathi': 'बचाव पथक सेक्टर जंक्शनवर पोहोचत आहे. स्थितीची खात्री करा.',
      'Gujarati': 'બચાવ ટુકડી સેક્ટર જંક્શન પર પહોંચી રહી છે. સ્થિતિની ખાતરી કરો.',
      'Odia': 'ଉଦ୍ଧାରକାରୀ ଦଳ ସେକ୍ଟର ଛକରେ ପହଞ୍ଚୁଛନ୍ତି। ସ୍ଥିତି ନିଶ୍ଚିତ କରନ୍ତୁ।',
    }
  };

  Future<void> init() async {
    if (_isInitialized) return;
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.48);
    await _flutterTts.setVolume(1.0);
    _isInitialized = true;
  }

  String translateOrEcho({
    required String rawText,
    required String targetLang,
  }) {
    if (_phraseBook.containsKey(rawText)) {
      return _phraseBook[rawText]?[targetLang] ??
          _phraseBook[rawText]?['English'] ??
          rawText;
    }
    return rawText;
  }

  Future<void> playVoiceNote({
    required String text,
    required String language,
  }) async {
    await init();
    final locale = _localeMap[language] ?? 'en-IN';
    final isSupported = await _flutterTts.isLanguageAvailable(locale);

    if (isSupported == 1 || isSupported == true) {
      await _flutterTts.setLanguage(locale);
    } else {
      await _flutterTts.setLanguage('en-IN');
    }

    await _flutterTts.setVolume(0.9);
    await _flutterTts.speak(text);
  }

  Future<void> playEmergencyAlert({
    required String text,
    required String language,
  }) async {
    await init();
    final locale = _localeMap[language] ?? 'en-IN';
    final isSupported = await _flutterTts.isLanguageAvailable(locale);

    if (isSupported == 1 || isSupported == true) {
      await _flutterTts.setLanguage(locale);
    } else {
      await _flutterTts.setLanguage('en-IN');
    }

    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.42);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}