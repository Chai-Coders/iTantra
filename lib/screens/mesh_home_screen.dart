import 'dart:async';
import 'package:flutter/material.dart';
import '../transceiver_engine.dart';
import '../speech_engine.dart';
import '../geo_engine.dart';
import 'transmitting_screen.dart';
import 'sos_emergency_screen.dart';
import 'peers_screen.dart';
import 'settings_screen.dart';

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
  int _currentTabIndex = 0;
  bool _isWalkieTalkie = true;
  bool _isSosScreenOpen = false;
  StreamSubscription? _packetSub;

  @override
  void initState() {
    super.initState();
    SpeechEngine().init();

    _packetSub = TransceiverEngine().packetStream.listen((packet) {
      if (packet.type == PacketType.prioritySos && mounted) {
        if (_isSosScreenOpen) return;
        _isSosScreenOpen = true;

        SpeechEngine().playEmergencyAlert(
          text: packet.content,
          language: widget.englishLanguage,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SosEmergencyScreen(
              sender: packet.senderName,
              alertText: packet.content,
              hops: packet.hops,
              language: widget.englishLanguage,
              incidentLat: packet.latitude,
              incidentLon: packet.longitude,
            ),
          ),
        ).then((_) {
          _isSosScreenOpen = false;
        });
      } else if (packet.type == PacketType.voiceText && mounted) {
        SpeechEngine().playVoiceNote(
          text: packet.content,
          language: widget.englishLanguage,
        );

        final distanceMeters = GeoEngine().calculateDistance(
          GeoEngine().currentLocation,
          GeoCoordinates(latitude: packet.latitude, longitude: packet.longitude),
        );
        final distStr = GeoEngine().formatDistance(distanceMeters);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF161A22),
            content: Row(
              children: [
                const Icon(Icons.record_voice_over, color: Color(0xFF27AE60), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${packet.senderName} ($distStr away): "${packet.content}"',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
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

  void _triggerSosBroadcast(TransceiverEngine engine) {
    if (_isSosScreenOpen) return;
    _isSosScreenOpen = true;

    const alertMsg = 'evacuation';
    engine.broadcastSos(alertText: alertMsg);

    final localAlert = SpeechEngine().translateOrEcho(
      rawText: alertMsg,
      targetLang: widget.englishLanguage,
    );

    SpeechEngine().playEmergencyAlert(
      text: localAlert,
      language: widget.englishLanguage,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SosEmergencyScreen(
          sender: engine.nodeName,
          alertText: localAlert,
          hops: 1,
          language: widget.englishLanguage,
          incidentLat: GeoEngine().currentLocation.latitude,
          incidentLon: GeoEngine().currentLocation.longitude,
        ),
      ),
    ).then((_) {
      _isSosScreenOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentTabIndex == 1) {
      return Scaffold(
        body: PeersScreen(
          selectedLanguage: widget.selectedLanguage,
          englishLanguage: widget.englishLanguage,
        ),
        bottomNavigationBar: _buildBottomNav(),
      );
    } else if (_currentTabIndex == 2) {
      return Scaffold(
        body: SettingsScreen(
          selectedLanguage: widget.selectedLanguage,
          englishLanguage: widget.englishLanguage,
        ),
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    final engine = TransceiverEngine();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                          const Icon(Icons.hub, size: 16, color: Color(0xFF27AE60)),
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
                      Text(
                        engine.localIp,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.battery_5_bar, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      const Text('84%', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF161A22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: engine.packetsSentNotifier,
                      builder: (_, sent, __) => Text('TX: $sent  ', style: const TextStyle(fontSize: 10, color: Color(0xFF2F80ED))),
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: engine.packetsReceivedNotifier,
                      builder: (_, rx, __) => Text('RX: $rx  ', style: const TextStyle(fontSize: 10, color: Color(0xFF27AE60))),
                    ),
                    Expanded(
                      child: ValueListenableBuilder<String>(
                        valueListenable: engine.logNotifier,
                        builder: (_, log, __) => Text(
                          log,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => engine.forceBeacon(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F80ED).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('PING', style: TextStyle(fontSize: 9, color: Color(0xFF2F80ED), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
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
                        child: const Icon(Icons.record_voice_over, color: Color(0xFF2F80ED), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('iTantra',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(engine.nodeName,
                              style: const TextStyle(fontSize: 11, color: Colors.white54)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E232B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.translate, size: 14, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(widget.selectedLanguage,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
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
                            color: _isWalkieTalkie ? const Color(0xFF2F80ED) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.radio, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text('WALKIE-TALKIE',
                                  style: TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
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
                            color: !_isWalkieTalkie ? const Color(0xFF2F80ED) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.call, size: 16, color: Colors.white70),
                              SizedBox(width: 6),
                              Text('PHONE',
                                  style: TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Discovered Peers',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  Row(
                    children: [
                      Text('Subnet Auto-Sync',
                          style: TextStyle(fontSize: 11, color: Color(0xFF27AE60))),
                      SizedBox(width: 4),
                      Icon(Icons.sync, size: 14, color: Color(0xFF27AE60)),
                    ],
                  ),
                ],
              ),
            ),
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
                          Icon(Icons.radar, size: 38, color: Colors.white24),
                          SizedBox(height: 6),
                          Text(
                            'Scanning subnet broadcast...\nConnect 2 devices to the same Hotspot or Wi-Fi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Colors.white38),
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
                      final dist = GeoEngine().formatDistance(peer.distanceMeters);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                                peer.name.isNotEmpty ? peer.name.substring(0, 1) : 'N',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(peer.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${peer.language}  ·  $dist  ·  ${peer.hops} hop  ·  ${peer.id}',
                                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.network_cell, size: 16, color: Color(0xFF27AE60)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                  width: 130,
                  height: 130,
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
                      width: 96,
                      height: 96,
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
                            size: 28,
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
              _isWalkieTalkie ? 'READY TO BROADCAST' : 'LIVE DUPLEX PHONE MODE',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEB5757),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  onPressed: () => _triggerSosBroadcast(engine),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'BROADCAST PRIORITY SOS',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      Text(
                        'PRESS TO BROADCAST',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C0E12),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => setState(() => _currentTabIndex = 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hub,
                  color: _currentTabIndex == 0 ? const Color(0xFF2F80ED) : Colors.white54,
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 10,
                    color: _currentTabIndex == 0 ? const Color(0xFF2F80ED) : Colors.white54,
                    fontWeight: _currentTabIndex == 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _currentTabIndex = 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: _currentTabIndex == 1 ? const Color(0xFF2F80ED) : Colors.white54,
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  'Peers',
                  style: TextStyle(
                    fontSize: 10,
                    color: _currentTabIndex == 1 ? const Color(0xFF2F80ED) : Colors.white54,
                    fontWeight: _currentTabIndex == 1 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _currentTabIndex = 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: _currentTabIndex == 2 ? const Color(0xFF2F80ED) : Colors.white54,
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 10,
                    color: _currentTabIndex == 2 ? const Color(0xFF2F80ED) : Colors.white54,
                    fontWeight: _currentTabIndex == 2 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}