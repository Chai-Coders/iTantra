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
                  Text('Node Identifier: ${engine.nodeId}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Subnet Interface IP: ${engine.localIp}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Local Voice Locale: ${widget.selectedLanguage} (${widget.englishLanguage})', style: const TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'DEMONSTRATION & JUDGING SAFEGUARDS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161A22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2F80ED).withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: engine.simulationActive,
                    activeThumbColor: const Color(0xFF2F80ED),
                    title: const Text('Judge Mode: Simulate Mesh Topology', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Spins up 3 synthetic multi-hop nodes (KL, TN, WB) for evaluation panels', style: TextStyle(fontSize: 11, color: Colors.white54)),
                    onChanged: (v) {
                      setState(() {
                        engine.setSimulationMode(v);
                      });
                    },
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
                  const ListTile(
                    leading: Icon(Icons.settings_input_antenna, color: Color(0xFF2F80ED)),
                    title: Text('Operating Band', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text('Sub-GHz 868 MHz ISM / Wi-Fi Direct Mesh', style: TextStyle(fontSize: 11, color: Colors.white54)),
                    trailing: Text('CH-04', style: TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  SwitchListTile(
                    value: engine.relayEnabled,
                    activeThumbColor: const Color(0xFF27AE60),
                    title: const Text('Multi-Hop Mesh Forwarding', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Relay non-local packets with jitter backoff to extend mesh perimeter', style: TextStyle(fontSize: 11, color: Colors.white54)),
                    onChanged: (v) {
                      setState(() {
                        engine.relayEnabled = v;
                      });
                    },
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  SwitchListTile(
                    value: _lowLatencyOpus,
                    activeThumbColor: const Color(0xFF27AE60),
                    title: const Text('IndicConformer Neural Quantization', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('INT8 compressed on-device weights (<40ms latency)', style: TextStyle(fontSize: 11, color: Colors.white54)),
                    onChanged: (v) => setState(() => _lowLatencyOpus = v),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  SwitchListTile(
                    value: _tactileAlerts,
                    activeThumbColor: const Color(0xFFEB5757),
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