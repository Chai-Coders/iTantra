import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SttService {
  static final SttService _instance = SttService._internal();
  factory SttService() => _instance;
  SttService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;

  static const Map<String, String> _sttLocales = {
    'English': 'en_IN',
    'Hindi': 'hi_IN',
    'Malayalam': 'ml_IN',
    'Bengali': 'bn_IN',
    'Tamil': 'ta_IN',
    'Telugu': 'te_IN',
    'Kannada': 'kn_IN',
    'Marathi': 'mr_IN',
    'Gujarati': 'gu_IN',
    'Odia': 'or_IN',
  };

  bool get isListening => _speech.isListening;

  Future<bool> init() async {
    if (_isAvailable) return true;
    _isAvailable = await _speech.initialize(
      onError: (val) {},
      onStatus: (val) {},
    );
    return _isAvailable;
  }

  Future<void> startListening({
    required String language,
    required Function(String liveText, bool isFinal) onResult,
    required Function() onPauseDetected,
  }) async {
    final ready = await init();
    if (!ready) return;

    if (_speech.isListening) {
      await _speech.stop();
    }

    final localeId = _sttLocales[language] ?? 'en_IN';

    await _speech.listen(
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      ),
      pauseFor: const Duration(seconds: 4), // Prevents early shutdown during pauses
      listenFor: const Duration(seconds: 30),
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords, result.finalResult);
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          onPauseDetected(); // Sentence endpoint detection trigger
        }
      },
    );
  }

  Future<void> stop() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }
}