import 'package:flutter/material.dart';
import '../speech_engine.dart';

class SosEmergencyScreen extends StatelessWidget {
  final String sender;
  final String alertText;
  final int hops;
  final String language;

  const SosEmergencyScreen({
    super.key,
    required this.sender,
    required this.alertText,
    required this.hops,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        await SpeechEngine().stop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        SpeechEngine().stop();
                        Navigator.pop(context);
                      },
                    ),
                    const Text('Priority 1 Inbound Alert',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Icon(Icons.warning, color: Color(0xFFEB5757)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PRIORITY 1 - LIFE SAFETY BROADCAST',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      Icon(Icons.priority_high, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161A22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEB5757).withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EMERGENCY ALERT',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8A80)),
                        ),
                        const SizedBox(height: 8),
                        Text('From: $sender',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('⏱ Relayed via $hops mesh hop(s)',
                            style: const TextStyle(fontSize: 10, color: Colors.white54)),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C222C),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            alertText,
                            style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C222C),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Non-Interruptible Voice Output',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              Text('100% VOLUME (ALARM)',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A2828),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      SpeechEngine().stop();
                      Navigator.pop(context);
                    },
                    child: const Text('Acknowledge Safety Alert',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: TextButton(
                    onPressed: () {
                      SpeechEngine().playEmergencyAlert(
                        text: alertText,
                        language: language,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh, size: 16, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text('Repeat Audio in $language',
                            style: const TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
