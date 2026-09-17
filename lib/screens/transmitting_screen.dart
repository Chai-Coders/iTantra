import 'dart:async';
import 'package:flutter/material.dart';
import '../transceiver_engine.dart';
import '../stt_service.dart';

class TransmittingScreen extends StatefulWidget {
  final String targetLang;
  const TransmittingScreen({super.key, required this.targetLang});

  @override
  State<TransmittingScreen> createState() => _TransmittingScreenState();
}

class _TransmittingScreenState extends State<TransmittingScreen> {
  int _seconds = 0;
  Timer? _timer;
  String _recognizedText = '';
  bool _isProcessing = false;
  bool _micActive = false;

  final List<String> _quickPhrases = const [
    'Evacuation teams arriving at sector junction.',
    'Status normal. Holding current perimeter.',
    'Require medical support at forward checkpoint.',
    'Water surge detected. Requesting relocation.',
  ];

  @override
  void initState() {
    super.initState();
    _startRecording();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  Future<void> _startRecording() async {
    setState(() => _micActive = true);
    await SttService().startListening(
      language: widget.targetLang,
      onResult: (liveText, isFinal) {
        if (mounted) {
          setState(() {
            _recognizedText = liveText;
          });
        }
      },
      onPauseDetected: () {
        if (_recognizedText.trim().isNotEmpty) {
          _finishAndBroadcast(_recognizedText.trim());
        }
      },
    );
  }

  void _finishAndBroadcast(String text) {
    if (_isProcessing) return;
    _isProcessing = true;
    SttService().stop();

    final payload = text.trim().isNotEmpty ? text.trim() : 'check_in';

    // Broadcast compact text string instead of raw audio
    TransceiverEngine().broadcastVoiceText(
      text: payload,
      targetLang: widget.targetLang,
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    SttService().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle,
                        color: Color(0xFF27AE60), size: 28),
                    onPressed: () => _finishAndBroadcast(
                        _recognizedText.isNotEmpty
                            ? _recognizedText
                            : 'check_in'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEB5757).withValues(alpha: 0.12),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _micActive
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF1E232B),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _micActive ? Icons.mic : Icons.mic_off,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '00:${_seconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _micActive
                        ? const Color(0xFF27AE60)
                        : Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _micActive
                      ? 'Neural Acoustic VAD Active'
                      : 'Audio Stream Paused',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Live Transcription Display Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 80),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161A22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  _recognizedText.isEmpty
                      ? 'Listening... Speak clearly or pick a tactical preset below.'
                      : '"$_recognizedText"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: _recognizedText.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color: _recognizedText.isEmpty
                        ? Colors.white38
                        : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Quick Phrase Fallback Chips (Emergency edge case mitigation)[cite: 1]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _quickPhrases.map((phrase) {
                  return ActionChip(
                    backgroundColor: const Color(0xFF1E232B),
                    label: Text(
                      phrase,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                    onPressed: () {
                      setState(() => _recognizedText = phrase);
                    },
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () => _finishAndBroadcast(
                      _recognizedText.isNotEmpty
                          ? _recognizedText
                          : 'check_in'),
                  child: const Text(
                    'TRANSMIT PACKET OVER MESH',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}