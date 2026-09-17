import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SttService {
  static final SttService _instance = SttService._internal();
  factory SttService() => _instance;
  SttService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;
  bool _shouldKeepListening = false;
  String _activeLanguage = 'English';
  Function(String liveText, bool isFinal)? _resultCallback;
  Function()? _pauseCallback;

  final ValueNotifier<String> statusNotifier = ValueNotifier<String>('Idle');
  final ValueNotifier<String> errorNotifier = ValueNotifier<String>('');

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
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      errorNotifier.value = 'Microphone permission denied.';
      statusNotifier.value = 'Permission Denied';
      return false;
    }

    if (_isAvailable) return true;

    try {
      _isAvailable = await _speech.initialize(
        onError: (val) {
          _handleSpeechError(val.errorMsg);
        },
        onStatus: (status) {
          if (status == 'listening') {
            statusNotifier.value = 'Listening for speech...';
            errorNotifier.value = '';
          } else if (status == 'notListening' && _shouldKeepListening) {
            _restartListenLoop();
          } else {
            statusNotifier.value = status;
          }
        },
      );
    } catch (e) {
      errorNotifier.value = e.toString();
      _isAvailable = false;
    }

    return _isAvailable;
  }

  void _handleSpeechError(String errorMsg) {
    // Treat silence and no-match timeouts as normal pauses, not fatal errors
    if (errorMsg == 'error_no_match' ||
        errorMsg == 'error_speech_timeout' ||
        errorMsg == 'error_busy') {
      if (_shouldKeepListening) {
        statusNotifier.value = 'Listening (waiting for voice)...';
        _restartListenLoop();
      }
    } else {
      errorNotifier.value = errorMsg;
      statusNotifier.value = 'STT Warning';
    }
  }

  void _restartListenLoop() {
    if (!_shouldKeepListening) return;

    Timer(const Duration(milliseconds: 350), () async {
      if (_shouldKeepListening && !_speech.isListening) {
        await _executeListen();
      }
    });
  }

  Future<void> _executeListen() async {
    final localeId = _sttLocales[_activeLanguage] ?? 'en_IN';

    try {
      await _speech.listen(
        localeId: localeId,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
        ),
        pauseFor: const Duration(seconds: 5),
        listenFor: const Duration(seconds: 60),
        onResult: (SpeechRecognitionResult result) {
          if (_resultCallback != null) {
            _resultCallback!(result.recognizedWords, result.finalResult);
          }
          if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
            if (_pauseCallback != null) {
              _pauseCallback!();
            }
          }
        },
      );
    } catch (_) {
      // Fallback silently without breaking the session
    }
  }

  Future<bool> startListening({
    required String language,
    required Function(String liveText, bool isFinal) onResult,
    required Function() onPauseDetected,
  }) async {
    _activeLanguage = language;
    _resultCallback = onResult;
    _pauseCallback = onPauseDetected;
    _shouldKeepListening = true;
    errorNotifier.value = '';

    final ready = await init();
    if (!ready) {
      statusNotifier.value = 'STT Unavailable';
      return false;
    }

    if (_speech.isListening) {
      await _speech.stop();
    }

    await _executeListen();
    return true;
  }

  Future<void> stop() async {
    _shouldKeepListening = false;
    if (_speech.isListening) {
      await _speech.stop();
    }
    statusNotifier.value = 'Idle';
  }
}