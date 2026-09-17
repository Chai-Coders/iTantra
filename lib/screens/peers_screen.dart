import 'package:flutter/material.dart';
import '../transceiver_engine.dart';
import 'transmitting_screen.dart';

class PeersScreen extends StatelessWidget {
  final String selectedLanguage;
  final String englishLanguage;

  const PeersScreen({
    super.key,
    required this.selectedLanguage,
    required this.englishLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final engine = TransceiverEngine();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.hub, color: Color(0xFF27AE60), size: 20),
            SizedBox(width: 8),
            Text(
              'Mesh Network Topology',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<DiscoveredPeer>>(
          stream: engine.peerStream,
          initialData: engine.currentPeers,
          builder: (context, snapshot) {
            final peers = snapshot.data ?? [];

            if (peers.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF161A22),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Icon(Icons.radar, size: 54, color: Color(0xFF2F80ED)),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Scanning Subnet Broadcast Frequencies',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Broadcasting beacon from ${engine.localIp}:${TransceiverEngine.meshPort} across ad-hoc nodes.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: peers.length,
              itemBuilder: (context, index) {
                final peer = peers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161A22),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: peer.isSimulated
                          ? const Color(0xFF2F80ED).withValues(alpha: 0.3)
                          : Colors.white10,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFF242C38),
                        child: Text(
                          peer.name.isNotEmpty ? peer.name.substring(0, 1) : 'N',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  peer.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  peer.isSimulated ? Icons.auto_awesome : Icons.lock,
                                  size: 12,
                                  color: peer.isSimulated ? const Color(0xFF2F80ED) : const Color(0xFF27AE60),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${peer.language}  ·  ${peer.hops} hop${peer.hops > 1 ? 's' : ''}  ·  ${peer.id}',
                              style: const TextStyle(fontSize: 11, color: Colors.white54),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.signal_cellular_alt, size: 12, color: peer.hops == 1 ? const Color(0xFF27AE60) : const Color(0xFFF2994A)),
                                const SizedBox(width: 4),
                                Text(
                                  peer.hops == 1
                                      ? '-52 dBm (Direct P2P Link)'
                                      : '-78 dBm (Multi-Hop Mesh Relay)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: peer.hops == 1 ? const Color(0xFF27AE60) : const Color(0xFFF2994A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone_forwarded, color: Color(0xFF2F80ED), size: 22),
                        tooltip: 'Call Peer Directly',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TransmittingScreen(
                                targetLang: peer.language,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}