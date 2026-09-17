import 'dart:async';
import 'package:flutter/material.dart';
import '../transceiver_engine.dart';
import '../speech_engine.dart';
import 'transmitting_screen.dart';
import 'sos_emergency_screen.dart';

class MeshHomeScreen extends StatefulWidget {
  final String selectedLanguage;
  final String englishLanguage;

  const MeshHomeScreen({
    super.key,
    required this.selectedLanguage,
    required this.englishLanguage,
  });

  @override
  State<MeshHomeScreen> createState() => _MeshHomeScreenState();
}

class _MeshHomeScreenState extends State<MeshHomeScreen> {
  bool _isWalkieTalkie = true;
  StreamSubscription? _packetSub;

  @override
  void initState() {
    super.initState();
    SpeechEngine().init();

    // Listen for incoming mesh packets
    _packetSub = TransceiverEngine().packetStream.listen((packet) {
      if (packet.type == PacketType.prioritySos && mounted) {
        final localizedAlert = SpeechEngine().translatePhrase(
          phraseKey: 'evacuation',
          targetLang: widget.englishLanguage,
        );
        SpeechEngine().playEmergencyAlert(
          text: localizedAlert,
          language: widget.englishLanguage,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SosEmergencyScreen(
              sender: packet.senderName,
              alertText: localizedAlert,
              hops: packet.hops,
              language: widget.englishLanguage,
            ),
          ),
        );
      } else if (packet.type == PacketType.voiceText && mounted) {
        final translatedText = SpeechEngine().translatePhrase(
          phraseKey: packet.content == 'check_in' ? 'check_in' : 'evacuation',
          targetLang: widget.englishLanguage,
        );
        SpeechEngine().playVoiceNote(
          text: translatedText,
          language: widget.englishLanguage,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E232B),
            content: Text(
              '📥 [${packet.senderName} - ${packet.sourceLang}]: "$translatedText"',
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _packetSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = TransceiverEngine();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<List<DiscoveredPeer>>(
                    stream: engine.peerStream,
                    initialData: engine.currentPeers,
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Row(
                        children: [
                          const Icon(Icons.hub,
                              size: 16, color: Color(0xFF27AE60)),
                          const SizedBox(width: 6),
                          Text(
                            '$count Node${count == 1 ? '' : 's'} Active',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF27AE60)),
                          ),
                        ],
                      );
                    },
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF27AE60),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('Ad-Hoc Mesh',
                          style: TextStyle(fontSize: 12, color: Colors.white70)),
                      const SizedBox(width: 12),
                      const Icon(Icons.battery_5_bar,
                          size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      const Text('84%',
                          style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),

            // App Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F80ED).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.record_voice_over,
                            color: Color(0xFF2F80ED), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('iTantra',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(engine.nodeName,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.white54)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E232B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.translate,
                                size: 14, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(widget.selectedLanguage,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF2F80ED),
                        child: Icon(Icons.person, size: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Mode Selector: Walkie-Talkie vs Phone
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF161A22),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isWalkieTalkie = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isWalkieTalkie
                                ? const Color(0xFF2F80ED)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.radio, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text('WALKIE-TALKIE',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isWalkieTalkie = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isWalkieTalkie
                                ? const Color(0xFF2F80ED)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.call,
                                  size: 16, color: Colors.white70),
                              SizedBox(width: 6),
                              Text('PHONE',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Channel Selector Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF161A22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.graphic_eq,
                        color: Colors.white70, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CHANNEL 04 · EMERGENCY RE...',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          SizedBox(height: 2),
                          Text('Sub-GHz ISM Band (868 MHz)',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.white54)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, color: Color(0xFF27AE60), size: 6),
                          SizedBox(width: 4),
                          Text('OPEN',
                              style: TextStyle(
                                  color: Color(0xFF27AE60),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Nearby Peers List Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Discovered Peers',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Row(
                    children: [
                      Text('Auto-Sync Active',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF27AE60))),
                      SizedBox(width: 4),
                      Icon(Icons.sync, size: 14, color: Color(0xFF27AE60)),
                    ],
                  ),
                ],
              ),
            ),

            // Discovered Peers Stream
            Expanded(
              child: StreamBuilder<List<DiscoveredPeer>>(
                stream: engine.peerStream,
                initialData: engine.currentPeers,
                builder: (context, snapshot) {
                  final peers = snapshot.data ?? [];
                  if (peers.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.radar, size: 42, color: Colors.white24),
                          SizedBox(height: 8),
                          Text(
                            'Scanning mesh frequencies...\nRun on 2nd device to test P2P link.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.white38),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: peers.length,
                    itemBuilder: (context, index) {
                      final peer = peers[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161A22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFF242C38),
                              child: Text(
                                peer.name.isNotEmpty
                                    ? peer.name.substring(0, 1)
                                    : 'N',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(peer.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${peer.language}  ·  ${peer.hops} hop  ·  ${peer.id}',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.white54),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.network_cell,
                                size: 16, color: Color(0xFF27AE60)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // PTT / Full-Duplex Action Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransmittingScreen(
                        targetLang: widget.englishLanguage,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1C2430),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2F80ED),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isWalkieTalkie ? Icons.mic : Icons.phone_in_talk,
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isWalkieTalkie ? 'HOLD TO\nTALK' : 'LIVE\nCALL',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              _isWalkieTalkie
                  ? 'READY TO BROADCAST'
                  : 'LIVE DUPLEX PHONE MODE',
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 2),
            Text(
              _isWalkieTalkie
                  ? 'Transmits audio to all nodes within range\n(approx. 250m)'
                  : 'Streams transcribed text immediately upon pause detection',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.white54),
            ),
            const SizedBox(height: 12),

            // Emergency SOS Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEB5757),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    engine.broadcastSos(
                      alertText:
                          'Cyclone warning: Immediate high-priority evacuation initiated across Sector B.',
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SosEmergencyScreen(
                          sender: engine.nodeName,
                          alertText:
                              'Cyclone warning: Immediate high-priority evacuation initiated across Sector B.',
                          hops: 1,
                          language: widget.englishLanguage,
                        ),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'BROADCAST PRIORITY SOS',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      Text(
                        'PRESS TO BROADCAST',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Bottom Navigation Footer
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hub, color: Color(0xFF2F80ED), size: 20),
                      SizedBox(height: 2),
                      Text('Home',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF2F80ED),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          color: Colors.white54, size: 20),
                      SizedBox(height: 2),
                      Text('Peers',
                          style: TextStyle(fontSize: 10, color: Colors.white54)),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings_outlined,
                          color: Colors.white54, size: 20),
                      SizedBox(height: 2),
                      Text('Settings',
                          style: TextStyle(fontSize: 10, color: Colors.white54)),
                    ],
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