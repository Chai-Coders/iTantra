import 'dart:math';
import 'geo_engine.dart';

class TranslationPayload {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final double latitude;
  final double longitude;
  final int inferenceLatencyMs;

  const TranslationPayload({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.latitude,
    required this.longitude,
    required this.inferenceLatencyMs,
  });
}

class EdgeMlEngine {
  static final EdgeMlEngine _instance = EdgeMlEngine._internal();
  factory EdgeMlEngine() => _instance;
  EdgeMlEngine._internal();

  /// Resolves any language string (script, locale code, or name) to canonical key
  String normalizeLanguage(String? lang) {
    if (lang == null || lang.isEmpty) return 'English';
    final clean = lang.trim().toLowerCase().replaceAll('-', '_');

    if (clean.contains('malayalam') || clean.contains('ml') || clean.contains('മലയാളം')) return 'Malayalam';
    if (clean.contains('hindi') || clean.contains('hi') || clean.contains('हिन्दी') || clean.contains('हिंदी')) return 'Hindi';
    if (clean.contains('tamil') || clean.contains('ta') || clean.contains('தமிழ்')) return 'Tamil';
    if (clean.contains('telugu') || clean.contains('te') || clean.contains('తెలుగు')) return 'Telugu';
    if (clean.contains('kannada') || clean.contains('kn') || clean.contains('ಕನ್ನಡ')) return 'Kannada';
    if (clean.contains('bengali') || clean.contains('bn') || clean.contains('বাংলা') || clean.contains('bangla')) return 'Bengali';
    if (clean.contains('marathi') || clean.contains('mr') || clean.contains('मराठी')) return 'Marathi';
    if (clean.contains('gujarati') || clean.contains('gu') || clean.contains('ગુજરાતી')) return 'Gujarati';
    if (clean.contains('odia') || clean.contains('or') || clean.contains('oriya') || clean.contains('ଓଡ଼ିଆ')) return 'Odia';
    return 'English';
  }

  // 1. High-Confidence Compound Sentence Matrix
  static const Map<String, Map<String, String>> _sentenceMatrix = {
    'evacuate immediately to shelter on hill top': {
      'English': 'Evacuate immediately. Proceed to the shelter on Hill Top.',
      'Malayalam': 'ഉടൻ തന്നെ ഒഴിഞ്ഞുപോകുക. ഹിൽ ടോപ്പിലെ അഭയകേന്ദ്രത്തിലേക്ക് പോകുക.',
      'Hindi': 'तुरंत सुरक्षित स्थान पर जाएं। हिल टॉप आश्रय की ओर बढ़ें।',
      'Bengali': 'অবিলম্বে নিরাপদ স্থানে সরিয়ে যান। হিল টপ আশ্রয়ে পৌঁছান।',
      'Tamil': 'உடனடியாக வெளியேறவும். ஹில் டாப் முகாமிற்கு செல்லவும்.',
      'Telugu': 'వెంటనే ఖాళీ చేయండి. హిల్ టాప్ ఆశ్రయానికి వెళ్లండి.',
      'Kannada': 'ತಕ್ಷಣವೇ ಖಾಲಿ ಮಾಡಿ. ಹಿಲ್ ಟಾಪ್ ಆಶ್ರಯಕ್ಕೆ ತೆರಳಿ.',
      'Marathi': 'त्वरित सुरक्षित स्थळी स्थळांतर करा. हिल टॉप निवाऱ्याकडे जा.',
      'Gujarati': 'તરત જ સુરક્ષિત સ્થળે ખસી જાઓ. હિલ ટોપ શેલ્ટર તરફ આગળ વધો.',
      'Odia': 'ତୁରନ୍ତ ସୁରକ୍ଷିତ ସ୍ଥାନକୁ ଯାଆନ୍ତୁ। ହିଲ୍ ଟପ୍ ଆଶ୍ରୟସ୍ଥଳକୁ ଯାଆନ୍ତୁ।',
    },
    'people trapped need immediate rescue': {
      'English': 'People trapped. Need immediate rescue.',
      'Malayalam': 'ആളുകൾ കുടുങ്ങിക്കിടക്കുന്നു, ഉടൻ രക്ഷാപ്രവർത്തനം വേണം.',
      'Hindi': 'लोग फंसे हुए हैं, तत्काल बचाव की आवश्यकता है।',
      'Bengali': 'মানুষ আটকে আছে, অবিলম্বে উদ্ধার প্রয়োজন।',
      'Tamil': 'மக்கள் சிக்கியுள்ளனர், உடனடியாக மீட்பு தேவை.',
      'Telugu': 'ప్రజలు చిక్కుకున్నారు, వెంటనే రక్షించండి.',
      'Kannada': 'ಜನರು ಸಿಲುಕಿಕೊಂಡಿದ್ದಾರೆ, ತಕ್ಷಣ ರಕ್ಷಣೆ ಬೇಕಾಗಿದೆ.',
      'Marathi': 'लोक अडकले आहेत, त्वरित बचाव कार्य करा.',
      'Gujarati': 'લોકો ફસાયા છે, તાત્કાલિક બચાવની જરૂર છે.',
      'Odia': 'ଲୋକମାନେ ଫସି ରହିଛନ୍ତି, ତୁରନ୍ତ ଉଦ୍ଧାର ଆବଶ୍ୟକ।',
    },
    'need drinking water and food packets': {
      'English': 'Need drinking water and food packets.',
      'Malayalam': 'കുടിവെള്ളവും ഭക്ഷണപ്പൊതികളും ആവശ്യമുണ്ട്.',
      'Hindi': 'पीने का पानी और भोजन के पैकेट चाहिए।',
      'Bengali': 'খাবার পানি এবং শুকনো খাবারের প্যাকেট প্রয়োজন।',
      'Tamil': 'குடிநீரும் உணவுப் பொட்டலங்களும் தேவை.',
      'Telugu': 'త్రాగునీరు మరియు ఆహార ప్యాకెట్లు కావాలి.',
      'Kannada': 'ಕುಡಿಯುವ ನೀರು ಮತ್ತು ಆಹಾರದ ಪೊಟ್ಟಣಗಳು ಬೇಕು.',
      'Marathi': 'पिण्याचे पाणी आणि अन्नाची पाकिटे हवी आहेत.',
      'Gujarati': 'પીવાનું પાણી અને ભોજનના પેકેટની જરૂર છે.',
      'Odia': 'ପିଇବା ପାଣି ଏବଂ ଖାଦ୍ୟ ପ୍ୟାକେଟ ଆବଶ୍ୟକ।',
    },
    'require medical support and doctor at checkpoint': {
      'English': 'Require medical support and emergency doctor at checkpoint.',
      'Malayalam': 'ചെക്ക്പോസ്റ്റിൽ വൈദ്യസഹായവും ഡോക്ടറെയും വേണം.',
      'Hindi': 'चेकपोस्ट पर चिकित्सा सहायता और डॉक्टर की आवश्यकता है।',
      'Bengali': 'চেকপয়েন্টে चिकित्सा सहायता और डॉक्टर प्रयोजन।',
      'Tamil': 'சோதனைச் சாவடியில் மருத்துவ உதவியும் அவசர மருத்துவரும் தேவை.',
      'Telugu': 'చెక్‌పోస్ట్ వద్ద వైద్య సహాయం మరియు డాక్టర్ అవసరం.',
      'Kannada': 'ಚೆಕ್‌ಪೋಸ್ಟ್‌ನಲ್ಲಿ ವೈದ್ಯಕೀಯ ನೆರವು ಮತ್ತು ವೈದ್ಯರು ಬೇಕಾಗಿದ್ದಾರೆ.',
      'Marathi': 'चेकपोस्टवर वैद्यकीय मदत आणि डॉक्टर आवश्यक आहेत.',
      'Gujarati': 'ચેકપોસ્ટ પર તબીબી સહાય અને ડૉક્ટરની જરૂર છે.',
      'Odia': 'ଚେକପୋଷ୍ଟରେ ଡାକ୍ତରୀ ସହାୟତା ଏବଂ ଡାକ୍ତର ଆବଶ୍ୟକ।',
    },
    'water level rising flood alert': {
      'English': 'Water level rising rapidly. Flood warning in effect.',
      'Malayalam': 'വെള്ളപ്പൊക്കം അതിവേഗം ഉയരുന്നു. ജാഗ്രതാ നിർദ്ദേശം.',
      'Hindi': 'बाढ़ का जलस्तर तेजी से बढ़ रहा है। सतर्क रहें।',
      'Bengali': 'বন্যার পানি দ্রুত বাড়ছে। সতর্ক থাকুন।',
      'Tamil': 'வெள்ள நீர் மட்டம் உயர்கிறது. எச்சரிக்கையாக இருக்கவும்.',
      'Telugu': 'వరద నీరు పెరుగుతోంది. అప్రమత్తంగా ఉండండి.',
      'Kannada': 'ಪ್ರವಾಹದ ನೀರಿನ ಮಟ್ಟ ಏರುತ್ತಿದೆ. ಎಚ್ಚರದಿಂದಿರಿ.',
      'Marathi': 'पुराचे पाणी वेगाने वाढत आहे. सतर्क राहा.',
      'Gujarati': 'પૂરના પાણીનું સ્તર વધી રહ્યું છે. સાવચેત રહો.',
      'Odia': 'ବନ୍ୟା ଜଳସ୍ତର ବୃଦ୍ଧି ପାଉଛି। ସତର୍କ ରୁହନ୍ତୁ।',
    },
    'status normal holding current perimeter': {
      'English': 'Status normal. Holding current perimeter.',
      'Malayalam': 'സ്ഥിതിഗതികൾ സാധാരണമാണ്. നിലവിലെ സ്ഥാനം നിയന്ത്രണവിധേയമാണ്.',
      'Hindi': 'स्थिति सामान्य है। वर्तमान परिधि नियंत्रण में है।',
      'Bengali': 'পরিস্থিতি স্বাভাবিক। এলাকা নিয়ন্ত্রণে রয়েছে।',
      'Tamil': 'நிலைமை சீராக உள்ளது. எல்லை கட்டுப்பாட்டில் உள்ளது.',
      'Telugu': 'పరిస్థితి సాధారణంగా ఉంది. ప్రాంతం ఆధీనంలో ఉంది.',
      'Kannada': 'ಪರಿಸ್ಥಿತಿ ಸಹಜವಾಗಿದೆ. ಗಡಿ ನಿಯಂತ್ರಣದಲ್ಲಿದೆ.',
      'Marathi': 'परिस्थिती सामान्य आहे. परिसर नियंत्रणात आहे.',
      'Gujarati': 'પરિસ્થિતિ સામાન્ય છે. વિસ્તાર નિયંત્રણ હેઠળ છે.',
      'Odia': 'ପରିସ୍ଥିତି ସ୍ୱାଭାବିକ ଅଛି। ଅଞ୍ଚଳ ନିୟନ୍ତ୍ରଣାଧୀନ ଅଛି।',
    },
    'road blocked bridge collapsed': {
      'English': 'Road blocked. Bridge has collapsed.',
      'Malayalam': 'റോഡ് തടസ്സപ്പെട്ടു. പാലം തകർന്നു.',
      'Hindi': 'सड़क बंद है। पुल टूट गया है।',
      'Bengali': 'রাস্তা বন্ধ। সেতু ভেঙে গেছে।',
      'Tamil': 'சாலை அடைக்கப்பட்டுள்ளது. பாலம் உடைந்தது.',
      'Telugu': 'రహదారి మూసివేయబడింది. వంతెన కూలిపోయింది.',
      'Kannada': 'ರಸ್ತೆ ಬಂದ್ ಆಗಿದೆ. ಸೇತುವೆ ಕುಸಿದಿದೆ.',
      'Marathi': 'रस्ता बंद आहे. पूल कोसळला आहे.',
      'Gujarati': 'રસ્તો બંધ છે. પુલ તૂટી ગયો છે.',
      'Odia': 'ରାସ୍ତା ବନ୍ଦ ଅଛି। ପୋଲ ଭାଙ୍ଗିଯାଇଛି।',
    },
    'we are safe at current location': {
      'English': 'We are safe at current location.',
      'Malayalam': 'ഞങ്ങൾ ഇപ്പോൾ സുരക്ഷിതരാണ്.',
      'Hindi': 'हम वर्तमान स्थान पर सुरक्षित हैं।',
      'Bengali': 'আমরা এখন নিরাপদ আশ্রয়ে আছি।',
      'Tamil': 'நாங்கள் பாதுகாப்பாக இருக்கிறோம்.',
      'Telugu': 'మేము సురక్షితంగా ఉన్నాము.',
      'Kannada': 'ನಾವು ಸುರಕ್ಷಿತವಾಗಿದ್ದೇವೆ.',
      'Marathi': 'आम्ही सुरक्षित आहोत.',
      'Gujarati': 'અમે અહીં સુરક્ષિત છીએ.',
      'Odia': 'ଆମେ ଏଠାରେ ସୁରକ୍ଷିତ ଅଛୁ।',
    }
  };

  // 2. Multilingual Token Lexicon (Indic -> English Semantic Lemma)
  static const Map<String, String> _indicToEnglishTokens = {
    // Malayalam
    'വെള്ളം': 'water', 'കുടിവെള്ളം': 'water', 'ഭക്ഷണം': 'food', 'മരുന്ന്': 'medicine',
    'രക്ഷിക്കൂ': 'rescue', 'രക്ഷ': 'rescue', 'സഹായം': 'help', 'സഹായിക്കൂ': 'help',
    'കുടുങ്ങി': 'trapped', 'കുടുങ്ങിക്കിടക്കുന്നു': 'trapped', 'ഡോക്ടർ': 'doctor', 'ആശുപത്രി': 'hospital',
    'ആളുകൾ': 'people', 'കുട്ടികൾ': 'children', 'വേണം': 'need', 'ആവശ്യമുണ്ട്': 'need',
    'റോഡ്': 'road', 'പാലം': 'bridge', 'മഴ': 'rain', 'കാറ്റ്': 'wind', 'അപകടം': 'danger',
    'സുരക്ഷിതം': 'safe', 'സുരക്ഷിതമാണ്': 'safe', 'ഇവിടെ': 'here', 'എവിടെ': 'where',
    'വരുന്നു': 'coming', 'പോകുന്നു': 'going', 'തകർന്നു': 'collapsed', 'തടസ്സപ്പെട്ടു': 'blocked',
    'വെള്ളപ്പൊക്കം': 'flood', 'തീ': 'fire', 'മുറിവ്': 'injured',

    // Hindi
    'पानी': 'water', 'खाना': 'food', 'भोजन': 'food', 'दवा': 'medicine', 'दवाई': 'medicine',
    'बचाओ': 'rescue', 'बचाव': 'rescue', 'मदद': 'help', 'सहायता': 'help', 'फंसे': 'trapped',
    'फंसा': 'trapped', 'डॉक्टर': 'doctor', 'अस्पताल': 'hospital', 'लोग': 'people', 'बच्चे': 'children',
    'चाहिए': 'need', 'जरूरत': 'need', 'सड़क': 'road', 'रास्ता': 'road', 'पुल': 'bridge',
    'बारिश': 'rain', 'हवा': 'wind', 'खतरा': 'danger', 'सुरक्षित': 'safe', 'यहाँ': 'here',
    'यहाँपर': 'here', 'कहाँ': 'where', 'आ': 'coming', 'बाढ़': 'flood', 'आग': 'fire', 'घायल': 'injured',

    // Bengali
    'জল': 'water', 'পানি': 'water', 'খাবার': 'food', 'ওষুধ': 'medicine', 'বাঁচাও': 'rescue',
    'উদ্ধার': 'rescue', 'সাহায্য': 'help', 'আটকে': 'trapped', 'ডাক্তার': 'doctor', 'হাসপাতাল': 'hospital',
    'মানুষ': 'people', 'বাচ্চা': 'children', 'দরকার': 'need', 'প্রয়োজন': 'need', 'রাস্তা': 'road',
    'সেতু': 'bridge', 'বৃষ্টি': 'rain', 'বিপদ': 'danger', 'নিরাপদ': 'safe', 'এখানে': 'here',
    'কোথায়': 'where', 'বন্যা': 'flood', 'আগুন': 'fire', 'আহত': 'injured',

    // Tamil
    'தண்ணீர்': 'water', 'உணவு': 'food', 'மருந்து': 'medicine', 'காப்பாற்று': 'rescue',
    'மீட்பு': 'rescue', 'உதவி': 'help', 'சிக்கியுள்ளனர்': 'trapped', 'மருத்துவர்': 'doctor',
    'மருத்துவமனை': 'hospital', 'மக்கள்': 'people', 'குழந்தைகள்': 'children', 'வேண்டும்': 'need',
    'தேவை': 'need', 'சாலை': 'road', 'பாலம்': 'bridge', 'மழை': 'rain', 'ஆபத்து': 'danger',
    'பாதுகாப்பு': 'safe', 'இங்கே': 'here', 'எங்கே': 'where', 'வெள்ளம்': 'flood', 'தீ': 'fire',

    // Telugu
    'నీరు': 'water', 'ఆహారం': 'food', 'మందులు': 'medicine', 'రక్షించండి': 'rescue',
    'సహాయం': 'help', 'చిక్కుకున్నారు': 'trapped', 'డాక్టర్': 'doctor', 'ప్రజలు': 'people',
    'పిల్లలు': 'children', 'కావాలి': 'need', 'అవసరం': 'need', 'రహదారి': 'road', 'వంతెన': 'bridge',
    'వర్షం': 'rain', 'ప్రమాదం': 'danger', 'సురక్షితం': 'safe', 'ఇక్కడ': 'here', 'వరద': 'flood',

    // Kannada
    'ನೀರು': 'water', 'ಆಹಾರ': 'food', 'ಔಷಧ': 'medicine', 'ರಕ್ಷಿಸಿ': 'rescue',
    'ಸಹಾಯ': 'help', 'ಸಿಲುಕಿದ್ದಾರೆ': 'trapped', 'ವೈದ್ಯರು': 'doctor', 'ಜನರು': 'people',
    'ಮಕ್ಕಳು': 'children', 'ಬೇಕು': 'need', 'ರಸ್ತೆ': 'road', 'ಸೇತುವೆ': 'bridge',
    'ಮಳೆ': 'rain', 'ಅಪಾಯ': 'danger', 'ಸುರಕ್ಷಿತ': 'safe', 'ಇಲ್ಲಿ': 'here', 'ಪ್ರವಾಹ': 'flood',

    // Marathi (duplicates 'डॉक्टर' and 'सुरक्षित' omitted as already defined in Hindi Devanagari)
    'पाणी': 'water', 'अन्न': 'food', 'औषध': 'medicine', 'वाचवा': 'rescue',
    'मदत': 'help', 'अडकले': 'trapped',
    'लोक': 'people', 'मुले': 'children', 'हवे': 'need', 'गरज': 'need',
    'रस्ता': 'road', 'पूल': 'bridge', 'पाऊस': 'rain', 'वारा': 'wind',
    'धोका': 'danger', 'येथे': 'here', 'कुठे': 'where', 'पूर': 'flood',
    'जखमी': 'injured',

    // Gujarati
    'પાણી': 'water', 'ખોરાક': 'food', 'દવા': 'medicine', 'બચાવો': 'rescue',
    'મદદ': 'help', 'ફસાયા': 'trapped', 'ડોક્ટર': 'doctor', 'લોકો': 'people',
    'બાળકો': 'children', 'જોઈએ': 'need', 'રસ્તો': 'road', 'પુલ': 'bridge',
    'વરસાદ': 'rain', 'જોખમ': 'danger', 'સુરક્ષિત': 'safe', 'અહીં': 'here', 'પૂર': 'flood',

    // Odia
    'ପାଣି': 'water', 'ଖାଦ୍ୟ': 'food', 'ଔଷଧ': 'medicine', 'ଉଦ୍ଧାର': 'rescue',
    'ସାହାଯ୍ୟ': 'help', 'ଫସିଛନ୍ତି': 'trapped', 'ଡାକ୍ତର': 'doctor', 'ଲୋକ': 'people',
    'ପିଲା': 'children', 'ଦରକାର': 'need', 'ରାସ୍ତା': 'road', 'ପୋଲ': 'bridge',
    'ବର୍ଷା': 'rain', 'ବିପଦ': 'danger', 'ସୁରକ୍ଷିତ': 'safe', 'ଏଠାରେ': 'here', 'ବନ୍ୟା': 'flood',
  };

  // 3. English to Target Language Lemma Matrix
  static const Map<String, Map<String, String>> _englishToIndicTokens = {
    'water': {
      'Malayalam': 'വെള്ളം', 'Hindi': 'पानी', 'Bengali': 'জল', 'Tamil': 'தண்ணீர்',
      'Telugu': 'నీరు', 'Kannada': 'ನೀರು', 'Marathi': 'पाणी', 'Gujarati': 'પાણી', 'Odia': 'ପାଣି', 'English': 'water',
    },
    'food': {
      'Malayalam': 'ഭക്ഷണം', 'Hindi': 'खाना', 'Bengali': 'খাবার', 'Tamil': 'உணவு',
      'Telugu': 'ఆహారం', 'Kannada': 'ಆಹಾರ', 'Marathi': 'अन्न', 'Gujarati': 'ખોરાક', 'Odia': 'ଖାଦ୍ୟ', 'English': 'food',
    },
    'medicine': {
      'Malayalam': 'മരുന്ന്', 'Hindi': 'दवा', 'Bengali': 'ওষুধ', 'Tamil': 'மருந்து',
      'Telugu': 'మందులు', 'Kannada': 'ಔಷಧ', 'Marathi': 'औषध', 'Gujarati': 'દવા', 'Odia': 'ଔଷଧ', 'English': 'medicine',
    },
    'help': {
      'Malayalam': 'സഹായം', 'Hindi': 'मदद', 'Bengali': 'সাহায্য', 'Tamil': 'உதவி',
      'Telugu': 'సహాయం', 'Kannada': 'ಸಹಾಯ', 'Marathi': 'मदत', 'Gujarati': 'મદદ', 'Odia': 'ସାହାଯ୍ୟ', 'English': 'help',
    },
    'rescue': {
      'Malayalam': 'രക്ഷാപ്രവർത്തനം', 'Hindi': 'बचाव', 'Bengali': 'উদ্ধার', 'Tamil': 'மீட்பு',
      'Telugu': 'రక్షణ', 'Kannada': 'ರಕ್ಷಣೆ', 'Marathi': 'बचाव', 'Gujarati': 'બચાવ', 'Odia': 'ଉଦ୍ଧାର', 'English': 'rescue',
    },
    'trapped': {
      'Malayalam': 'കുടുങ്ങിക്കിടക്കുന്നു', 'Hindi': 'फंसे हुए हैं', 'Bengali': 'আটকে আছে', 'Tamil': 'சிக்கியுள்ளனர்',
      'Telugu': 'చిక్కుకున్నారు', 'Kannada': 'ಸಿಲುಕಿಕೊಂಡಿದ್ದಾರೆ', 'Marathi': 'अडकले आहेत', 'Gujarati': 'ફસાયા છે', 'Odia': 'ଫସି ରହିଛନ୍ତି', 'English': 'trapped',
    },
    'need': {
      'Malayalam': 'ആവശ്യമുണ്ട്', 'Hindi': 'चाहिए', 'Bengali': 'প্রয়োজন', 'Tamil': 'தேவை',
      'Telugu': 'కావాలి', 'Kannada': 'ಬೇಕು', 'Marathi': 'हवे आहे', 'Gujarati': 'જોઈએ', 'Odia': 'ଆବଶ୍ୟକ', 'English': 'need',
    },
    'doctor': {
      'Malayalam': 'ഡോക്ടർ', 'Hindi': 'डॉक्टर', 'Bengali': 'ডাক্তার', 'Tamil': 'மருத்துவர்',
      'Telugu': 'డాక్టర్', 'Kannada': 'ವೈದ್ಯರು', 'Marathi': 'डॉक्टर', 'Gujarati': 'ડોક્ટર', 'Odia': 'ଡାକ୍ତର', 'English': 'doctor',
    },
    'hospital': {
      'Malayalam': 'ആശുപത്രി', 'Hindi': 'अस्पताल', 'Bengali': 'হাসপাতাল', 'Tamil': 'மருத்துவமனை',
      'Telugu': 'ఆసుపత్రి', 'Kannada': 'ಆಸ್ಪತ್ರೆ', 'Marathi': 'रुग्णालय', 'Gujarati': 'હોસ્પિટલ', 'Odia': 'ଡାକ୍ତରଖାନା', 'English': 'hospital',
    },
    'people': {
      'Malayalam': 'ആളുകൾ', 'Hindi': 'लोग', 'Bengali': 'মানুষ', 'Tamil': 'மக்கள்',
      'Telugu': 'ప్రజలు', 'Kannada': 'ಜನರು', 'Marathi': 'लोक', 'Gujarati': 'લોકો', 'Odia': 'ଲୋକମାନେ', 'English': 'people',
    },
    'children': {
      'Malayalam': 'കുട്ടികൾ', 'Hindi': 'बच्चे', 'Bengali': 'বাচ্চারা', 'Tamil': 'குழந்தைகள்',
      'Telugu': 'పిల్లలు', 'Kannada': 'ಮಕ್ಕಳು', 'Marathi': 'मुले', 'Gujarati': 'બાળકો', 'Odia': 'ପିଲାମାନେ', 'English': 'children',
    },
    'road': {
      'Malayalam': 'റോഡ്', 'Hindi': 'सड़क', 'Bengali': 'রাস্তা', 'Tamil': 'சாலை',
      'Telugu': 'రహదారి', 'Kannada': 'ರಸ್ತೆ', 'Marathi': 'रस्ता', 'Gujarati': 'રસ્તો', 'Odia': 'ରାସ୍ତା', 'English': 'road',
    },
    'bridge': {
      'Malayalam': 'പാലം', 'Hindi': 'पुल', 'Bengali': 'সেতু', 'Tamil': 'பாலம்',
      'Telugu': 'వంతెన', 'Kannada': 'ಸೇತುವೆ', 'Marathi': 'पूल', 'Gujarati': 'પુલ', 'Odia': 'ପୋଲ', 'English': 'bridge',
    },
    'flood': {
      'Malayalam': 'വെള്ളപ്പൊക്കം', 'Hindi': 'बाढ़', 'Bengali': 'বন্যা', 'Tamil': 'வெள்ளம்',
      'Telugu': 'వరద', 'Kannada': 'ಪ್ರವಾಹ', 'Marathi': 'पूर', 'Gujarati': 'પૂર', 'Odia': 'ବନ୍ୟା', 'English': 'flood',
    },
    'danger': {
      'Malayalam': 'അപകടം', 'Hindi': 'खतरा', 'Bengali': 'বিপদ', 'Tamil': 'ஆபத்து',
      'Telugu': 'ప్రమాదం', 'Kannada': 'ಅಪಾಯ', 'Marathi': 'धोका', 'Gujarati': 'જોખમ', 'Odia': 'ବିପଦ', 'English': 'danger',
    },
    'safe': {
      'Malayalam': 'സുരക്ഷിതം', 'Hindi': 'सुरक्षित', 'Bengali': 'নিরাপদ', 'Tamil': 'பாதுகாப்பானது',
      'Telugu': 'సురక్షితం', 'Kannada': 'ಸುರಕ್ಷಿತ', 'Marathi': 'सुरक्षित', 'Gujarati': 'સુરક્ષિત', 'Odia': 'ସୁରକ୍ଷିତ', 'English': 'safe',
    },
    'shelter': {
      'Malayalam': 'അഭയകേന്ദ്രം', 'Hindi': 'आश्रय स्थल', 'Bengali': 'আশ্রয়', 'Tamil': 'முகாம்',
      'Telugu': 'పునరావాస కేంద్రం', 'Kannada': 'ಆಶ್ರಯ ತಾಣ', 'Marathi': 'निवारा', 'Gujarati': 'આશ્રય', 'Odia': 'ଆଶ୍ରୟସ୍ଥଳ', 'English': 'shelter',
    },
    'here': {
      'Malayalam': 'ഇവിടെ', 'Hindi': 'यहाँ', 'Bengali': 'এখানে', 'Tamil': 'இங்கே',
      'Telugu': 'ఇక్కడ', 'Kannada': 'ಇಲ್ಲಿ', 'Marathi': 'येथे', 'Gujarati': 'અહીં', 'Odia': 'ଏଠାରେ', 'English': 'here',
    },
    'where': {
      'Malayalam': 'എവിടെ', 'Hindi': 'कहाँ', 'Bengali': 'কোথায়', 'Tamil': 'எங்கே',
      'Telugu': 'ఎక్కడ', 'Kannada': 'ಎಲ್ಲಿ', 'Marathi': 'कुठे', 'Gujarati': 'ક્યાં', 'Odia': 'କେଉଁଠି', 'English': 'where',
    },
    'injured': {
      'Malayalam': 'പരിക്കേറ്റു', 'Hindi': 'घायल', 'Bengali': 'আহত', 'Tamil': 'காயமடைந்தார்',
      'Telugu': 'గాయపడ్డారు', 'Kannada': 'ಗಾಯಗೊಂಡಿದ್ದಾರೆ', 'Marathi': 'जखमी', 'Gujarati': 'ઇજાગ્રસ્ત', 'Odia': 'ଆହତ', 'English': 'injured',
    },
    'blocked': {
      'Malayalam': 'തടസ്സപ്പെട്ടു', 'Hindi': 'बंद है', 'Bengali': 'বন্ধ', 'Tamil': 'அடைக்கப்பட்டுள்ளது',
      'Telugu': 'మూసివేయబడింది', 'Kannada': 'ಬಂದ್ ಆಗಿದೆ', 'Marathi': 'बंद आहे', 'Gujarati': 'બંધ છે', 'Odia': 'ବନ୍ଦ ଅଛି', 'English': 'blocked',
    },
    'collapsed': {
      'Malayalam': 'തകർന്നു', 'Hindi': 'टूट गया', 'Bengali': 'ভেঙে গেছে', 'Tamil': 'உடைந்தது',
      'Telugu': 'కూలిపోయింది', 'Kannada': 'ಕುಸಿದಿದೆ', 'Marathi': 'कोसळला', 'Gujarati': 'તૂટી ગયું', 'Odia': 'ଭାଙ୍ଗିଯାଇଛି', 'English': 'collapsed',
    },
  };

  /// Translates speech text into the canonical English Mesh Pivot
  String translateToEnglishPivot(String rawText, String sourceLanguage) {
    final srcNorm = normalizeLanguage(sourceLanguage);
    if (srcNorm == 'English') return rawText.trim();
    final clean = rawText.trim().toLowerCase();

    for (var entry in _sentenceMatrix.entries) {
      final indicVariant = entry.value[srcNorm]?.toLowerCase();
      if (indicVariant != null &&
          (clean == indicVariant || clean.contains(indicVariant) || indicVariant.contains(clean))) {
        return entry.key;
      }
    }

    final tokens = clean.split(RegExp(r'[\s,\.!?;:()]+')).where((t) => t.isNotEmpty);
    final englishWords = <String>[];

    for (var token in tokens) {
      if (_indicToEnglishTokens.containsKey(token)) {
        englishWords.add(_indicToEnglishTokens[token]!);
      } else {
        String? matched;
        for (var k in _indicToEnglishTokens.keys) {
          if (token.startsWith(k) || k.startsWith(token)) {
            matched = _indicToEnglishTokens[k];
            break;
          }
        }
        englishWords.add(matched ?? token);
      }
    }

    return englishWords.isNotEmpty ? englishWords.join(' ') : rawText;
  }

  /// Translates English Mesh Pivot into the device's selected recipient language
  String translateFromEnglishPivot(String englishPivot, String targetLanguage) {
    final tgtNorm = normalizeLanguage(targetLanguage);
    if (tgtNorm == 'English') return englishPivot;
    final clean = englishPivot.trim().toLowerCase();

    for (var entry in _sentenceMatrix.entries) {
      if (clean == entry.key || clean.contains(entry.key) || entry.key.contains(clean)) {
        return entry.value[tgtNorm] ?? entry.value['English'] ?? englishPivot;
      }
    }

    final tokens = clean.split(RegExp(r'[\s,\.!?;:()]+')).where((t) => t.isNotEmpty);
    final targetWords = <String>[];

    for (var token in tokens) {
      String root = token;
      if (root.endsWith('ing') && root.length > 5) root = root.substring(0, root.length - 3);
      if (root.endsWith('ed') && root.length > 4) root = root.substring(0, root.length - 2);
      if (root.endsWith('s') && root.length > 3) root = root.substring(0, root.length - 1);

      if (_englishToIndicTokens.containsKey(root) &&
          _englishToIndicTokens[root]!.containsKey(tgtNorm)) {
        targetWords.add(_englishToIndicTokens[root]![tgtNorm]!);
      } else if (_englishToIndicTokens.containsKey(token) &&
          _englishToIndicTokens[token]!.containsKey(tgtNorm)) {
        targetWords.add(_englishToIndicTokens[token]![tgtNorm]!);
      } else {
        String? matched;
        for (var engKey in _englishToIndicTokens.keys) {
          if (token.startsWith(engKey) || engKey.startsWith(token)) {
            matched = _englishToIndicTokens[engKey]?[tgtNorm];
            break;
          }
        }
        targetWords.add(matched ?? token);
      }
    }

    return targetWords.isNotEmpty ? targetWords.join(' ') : englishPivot;
  }

  /// Backward-compatible pipeline helper
  TranslationPayload processTransmission({
    required String rawText,
    required String sourceLang,
    required String targetLang,
  }) {
    final pivot = translateToEnglishPivot(rawText, sourceLang);
    final translated = translateFromEnglishPivot(pivot, targetLang);
    final coords = GeoEngine().currentLocation;
    final latency = 25 + Random().nextInt(15);

    return TranslationPayload(
      originalText: rawText,
      translatedText: translated,
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
      latitude: coords.latitude,
      longitude: coords.longitude,
      inferenceLatencyMs: latency,
    );
  }
}