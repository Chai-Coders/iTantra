import 'package:flutter/material.dart';
import '../transceiver_engine.dart';

class SettingsScreen extends StatefulWidget {
  final String selectedLanguage;
  final String englishLanguage;

  const SettingsScreen({
    super.key,
    required this.selectedLanguage,
    required this.englishLanguage,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _tactileAlerts = true;
  bool _meshRelayMode = true;
  bool _lowLatencyOpus = true;

  @override
  Widget build(BuildContext context) {
    final engine = TransceiverEngine();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        title: const Text(
          'Hardware & Protocol Config',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF161A22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Node Identity',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Node Identifier: ${engine.nodeId}',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subnet Broadcast IP: ${engine.localIp}',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Local Voice Locale: ${widget.selectedLanguage} (${widget.englishLanguage})',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'RADIO FREQUENCY & TRANSLATION PIPELINE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161A22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_input_antenna, color: Color(0xFF2F80ED)),
                    title: const Text('Operating Band', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Sub-GHz 868 MHz ISM / Wi-Fi Direct Mesh', style: TextStyle(fontSize: 11, color: Colors.white54)),
                    trailing: const Text('CH-04', style: TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  SwitchListTile(
                    value: _meshRelayMode,
                    activeColor: const Color(0xFF27AE60),
                    title: const Text('Multi-Hop Mesh Forwarding', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Relay inbound packets to extend mesh perimeter', style: TextStyle(fontSize: 11, color: Colors.white54)),
                    onChanged: (v) => setState(() => _meshRelayMode = v),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  SwitchListTile(
                    value: _lowLatencyOpus,
                    activeColor: const Color(0xFF27AE60),
                    title: const Text('IndicConformer Neural Quantization', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('INT8 compressed on-device weights', style: TextStyle(fontSize: 11, color: Colors.white54)),
                    onChanged: (v) => setState(() => _lowLatencyOpus = v),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  SwitchListTile(
                    value: _tactileAlerts,
                    activeColor: const Color(0xFFEB5757),
                    title: const Text('Priority 1 Tactical Vibration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Continuous pattern override for SOS alarms', style: TextStyle(fontSize: 11, color: Colors.white54)),
                    onChanged: (v) => setState(() => _tactileAlerts = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}