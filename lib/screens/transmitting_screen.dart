import 'dart:async';
import 'package:flutter/material.dart';
import '../transceiver_engine.dart';
import '../stt_service.dart';
import '../ml_engine.dart';
import '../geo_engine.dart';

class TransmittingScreen extends StatefulWidget {
  final String targetLang;
  const TransmittingScreen({super.key, required this.targetLang});

  @override
  State<TransmittingScreen> createState() => _TransmittingScreenState();
}

class _TransmittingScreenState extends State<TransmittingScreen> {
  int _seconds = 0;
  Timer? _timer;
  final TextEditingController _textController = TextEditingController();
  bool _isProcessing = false;
  final SttService _stt = SttService();
  String _translatedPreview = '';

  final List<String> _quickPhrases = const [
    'Evacuation teams arriving at sector junction.',
    'Status normal. Holding current perimeter.',
    'Require medical support at forward checkpoint.',
    'Water surge detected. Requesting relocation.',
  ];

  @override
  void initState() {
    super.initState();
    _startRecordingSession();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  Future<void> _startRecordingSession() async {
    await _stt.startListening(
      language: widget.targetLang,
      onResult: (liveText, isFinal) {
        if (mounted && liveText.trim().isNotEmpty) {
          final payload = EdgeMlEngine().processTransmission(
            rawText: liveText,
            sourceLang: 'English',
            targetLang: widget.targetLang,
          );
          setState(() {
            _textController.text = liveText;
            _translatedPreview = payload.translatedText;
          });
        }
      },
      onPauseDetected: () {
        if (_textController.text.trim().isNotEmpty) {
          _finishAndBroadcast(_textController.text.trim());
        }
      },
    );
  }

  void _finishAndBroadcast(String text) {
    if (_isProcessing) return;
    _isProcessing = true;
    _stt.stop();

    final payload = text.trim().isNotEmpty ? text.trim() : 'check_in';

    TransceiverEngine().broadcastVoiceText(
      text: payload,
      targetLang: widget.targetLang,
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stt.stop();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GeoEngine().currentLocation;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        const Text('Live Transmission',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Color(0xFF27AE60), size: 28),
                      onPressed: () => _finishAndBroadcast(
                        _textController.text.isNotEmpty ? _textController.text : 'check_in',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEB5757).withValues(alpha: 0.12),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (_stt.isListening) {
                            await _stt.stop();
                          } else {
                            await _startRecordingSession();
                          }
                          if (mounted) setState(() {});
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _stt.isListening ? const Color(0xFFD32F2F) : const Color(0xFF1E232B),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _stt.isListening ? Icons.mic : Icons.mic_none,
                                color: Colors.white,
                                size: 34,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '00:${_seconds.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Location Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161A22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.my_location, size: 12, color: Color(0xFF27AE60)),
                      const SizedBox(width: 6),
                      Text(
                        'Geo-Fix: ${location.latitude.toStringAsFixed(4)}°N, ${location.longitude.toStringAsFixed(4)}°E',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                ValueListenableBuilder<String>(
                  valueListenable: _stt.statusNotifier,
                  builder: (context, status, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _stt.isListening ? const Color(0xFF27AE60) : const Color(0xFFF2994A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Raw Input Area
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161A22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    onChanged: (val) {
                      final trans = EdgeMlEngine().processTransmission(
                        rawText: val,
                        sourceLang: 'English',
                        targetLang: widget.targetLang,
                      );
                      setState(() {
                        _translatedPreview = trans.translatedText;
                      });
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Speak now, type manually, or tap a tactical chip below...',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ),
                ),

                // Translation Preview
                if (_translatedPreview.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C222C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2F80ED).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.translate, size: 12, color: Color(0xFF2F80ED)),
                            const SizedBox(width: 6),
                            Text(
                              'Auto-Translated to ${widget.targetLang}:',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2F80ED)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _translatedPreview,
                          style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _quickPhrases.map((phrase) {
                    return ActionChip(
                      backgroundColor: const Color(0xFF1E232B),
                      label: Text(
                        phrase,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                      onPressed: () {
                        final trans = EdgeMlEngine().processTransmission(
                          rawText: phrase,
                          sourceLang: 'English',
                          targetLang: widget.targetLang,
                        );
                        setState(() {
                          _textController.text = phrase;
                          _translatedPreview = trans.translatedText;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80ED),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () => _finishAndBroadcast(
                      _textController.text.isNotEmpty ? _textController.text : 'check_in',
                    ),
                    child: const Text(
                      'TRANSMIT PACKET OVER MESH',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}