import 'dart:async';
import 'package:flutter/material.dart';
import 'transceiver_engine.dart';
import 'speech_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ITantraApp());
}

class ITantraApp extends StatelessWidget {
  const ITantraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iTantra Transceiver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0C0E12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2F80ED),
          surface: Color(0xFF161A22),
        ),
      ),
      home: const LocalizationScreen(),
    );
  }
}

// ==========================================
// 1. LOCALIZATION SCREEN
// ==========================================
class LanguageOption {
  final String nativeName;
  final String englishName;
  const LanguageOption(this.nativeName, this.englishName);
}

class LocalizationScreen extends StatefulWidget {
  const LocalizationScreen({super.key});

  @override
  State<LocalizationScreen> createState() => _LocalizationScreenState();
}

class _LocalizationScreenState extends State<LocalizationScreen> {
  final List<LanguageOption> _languages = const [
    LanguageOption('മലയാളം', 'Malayalam'),
    LanguageOption('हिन्दी', 'Hindi'),
    LanguageOption('ગુજરાતી', 'Gujarati'),
    LanguageOption('मराठी', 'Marathi'),
    LanguageOption('ಕನ್ನಡ', 'Kannada'),
    LanguageOption('தமிழ்', 'Tamil'),
    LanguageOption('తెలుగు', 'Telugu'),
    LanguageOption('ଓଡ଼ିଆ', 'Odia'),
    LanguageOption('বাংলা', 'Bengali'),
    LanguageOption('English', 'English'),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F80ED),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.wifi, size: 16, color: Color(0xFF27AE60)),
                      SizedBox(width: 6),
                      Text(
                        'MESH NODE PREP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF27AE60),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Icon(Icons.translate, size: 16, color: Colors.white70),
                  SizedBox(width: 6),
                  Text(
                    'STEP 01 / LOCALIZATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose Your Primary\nLanguage',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Speech will be auto-translated to this language offline via IndicTrans2.',
                style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.graphic_eq,
                          color: Color(0xFF27AE60), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Neural Acoustic Engine',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Zero-latency peer-to-peer synth...',
                            style: TextStyle(
                                fontSize: 11, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'READY',
                        style: TextStyle(
                          color: Color(0xFF27AE60),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = _selectedIndex == index;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2F80ED)
                              : const Color(0xFF1A1F28),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2F80ED)
                                : Colors.white10,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    lang.nativeName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    lang.englishName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected
                                          ? Colors.white70
                                          : Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  size: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final selected = _languages[_selectedIndex];
                    await TransceiverEngine().start(
                      name: 'Node-${selected.englishName.substring(0, 2).toUpperCase()}',
                      language: selected.englishName,
                    );

                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MeshHomeScreen(
                            selectedLanguage: selected.nativeName,
                            englishLanguage: selected.englishName,
                          ),
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Continue',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.verified_user_outlined,
                      size: 13, color: Color(0xFF27AE60)),
                  SizedBox(width: 6),
                  Text(
                    'Offline translation models will be loaded locally on device.',
                    style: TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. MESH HOME / WALKIE-TALKIE SCREEN
// ==========================================
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
    // Listen for incoming mesh packets
    _packetSub = TransceiverEngine().packetStream.listen((packet) {
      if (packet.type == PacketType.prioritySos && mounted) {
        // High-priority interruption as specified in Section 2.1[cite: 1, 3]
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SosEmergencyScreen(
              sender: packet.senderName,
              alertText: packet.content,
              hops: packet.hops,
            ),
          ),
        );
      } else if (packet.type == PacketType.voiceText && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E232B),
            content: Text(
              '📥 [${packet.senderName} - ${packet.sourceLang}]: "${packet.content}"',
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
                          color: const Color(0xFF2F80ED).withOpacity(0.2),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Discovered Peers',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Row(
                    children: [
                      Text('Auto-Sync Active',
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.radar, size: 42, color: Colors.white24),
                          SizedBox(height: 8),
                          Text(
                            'Scanning mesh frequencies...\nRun on 2nd device or emulator to test.',
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
                                peer.name.substring(0, 1),
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
                        color: const Color(0xFF2F80ED).withOpacity(0.3),
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
                        children: const [
                          Icon(Icons.mic, color: Colors.white, size: 30),
                          SizedBox(height: 4),
                          Text(
                            'HOLD TO\nTALK',
                            textAlign: TextAlign.center,
                            style: TextStyle(
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
            const Text(
              'READY TO BROADCAST',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 2),
            const Text(
              'Transmits audio to all nodes within range\n(approx. 250m)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.white54),
            ),
            const SizedBox(height: 12),
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
                    // Send SOS broadcast across all reachable mesh nodes[cite: 1, 3]
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
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
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
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. ACTIVE TRANSMITTING SCREEN
// ==========================================
class TransmittingScreen extends StatefulWidget {
  final String targetLang;
  const TransmittingScreen({super.key, required this.targetLang});

  @override
  State<TransmittingScreen> createState() => _TransmittingScreenState();
}

class _TransmittingScreenState extends State<TransmittingScreen> {
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _finishAndBroadcast() {
    TransceiverEngine().broadcastVoiceText(
      text: 'Evacuation teams arriving at sector junction. Confirm status.',
      targetLang: widget.targetLang,
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                    icon: const Icon(Icons.check, color: Color(0xFF27AE60)),
                    onPressed: _finishAndBroadcast,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEB5757).withOpacity(0.12),
                    ),
                  ),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD32F2F),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mic, color: Colors.white, size: 36),
                        const SizedBox(height: 6),
                        Text(
                          '00:${_seconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Transcribing speech via on-device IndicConformer...',
              style: TextStyle(fontSize: 12, color: Colors.white54),
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
                  onPressed: _finishAndBroadcast,
                  child: const Text('TRANSMIT TO ALL NODES',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. PRIORITY 1 / SOS EMERGENCY SCREEN
// ==========================================
class SosEmergencyScreen extends StatelessWidget {
  final String sender;
  final String alertText;
  final int hops;

  const SosEmergencyScreen({
    super.key,
    required this.sender,
    required this.alertText,
    required this.hops,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Priority 1 Inbound Alert',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const Icon(Icons.warning, color: Color(0xFFEB5757)),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('PRIORITY 1 - LIFE SAFETY BROADCAST',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
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
                    border: Border.all(
                        color: const Color(0xFFEB5757).withOpacity(0.4)),
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
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('⏱ Relayed via $hops mesh hop(s)',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white54)),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C222C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          alertText,
                          style: const TextStyle(
                              fontSize: 12, height: 1.4, color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C222C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Non-Interruptible Voice Output',
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold)),
                            Text('STREAM_ALARM',
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Acknowledge Safety Alert',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}