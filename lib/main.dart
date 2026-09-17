import 'dart:async';
import 'package:flutter/material.dart';

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
// 1. STEP 01 / LOCALIZATION SCREEN
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
  // 10 Indian Languages per SIH Problem ID 26173
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

  int _selectedIndex = 0; // Default: Malayalam

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
                'You can change this later in settings. Speech will be auto-translated to this language.',
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
                      child: const Icon(Icons.graphic_eq, color: Color(0xFF27AE60), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Neural Acoustic Engine',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Zero-latency peer-to-peer synth...',
                            style: TextStyle(fontSize: 11, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2F80ED) : const Color(0xFF1A1F28),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2F80ED) : Colors.white10,
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
                                      color: isSelected ? Colors.white70 : Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, size: 16, color: Colors.white),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MeshHomeScreen(
                          selectedLanguage: _languages[_selectedIndex].nativeName,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Continue',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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
                  Icon(Icons.verified_user_outlined, size: 13, color: Color(0xFF27AE60)),
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
class PeerNode {
  final String name;
  final String initial;
  final String language;
  final int hops;
  final String statusText;
  final Color statusColor;
  final bool isEncrypted;

  const PeerNode({
    required this.name,
    required this.initial,
    required this.language,
    required this.hops,
    required this.statusText,
    required this.statusColor,
    required this.isEncrypted,
  });
}

class MeshHomeScreen extends StatefulWidget {
  final String selectedLanguage;
  const MeshHomeScreen({super.key, required this.selectedLanguage});

  @override
  State<MeshHomeScreen> createState() => _MeshHomeScreenState();
}

class _MeshHomeScreenState extends State<MeshHomeScreen> {
  bool _isWalkieTalkie = true;

  final List<PeerNode> _peers = const [
    PeerNode(
      name: 'Ravi Kumar',
      initial: 'R',
      language: 'Hindi',
      hops: 1,
      statusText: 'Optimal',
      statusColor: Color(0xFF27AE60),
      isEncrypted: true,
    ),
    PeerNode(
      name: 'Ananya Sen',
      initial: 'A',
      language: 'Bengali',
      hops: 2,
      statusText: 'Good',
      statusColor: Color(0xFFF2994A),
      isEncrypted: false,
    ),
    PeerNode(
      name: 'Manoj Patel',
      initial: 'M',
      language: 'Gujarati',
      hops: 3,
      statusText: 'Fringe',
      statusColor: Color(0xFFEB5757),
      isEncrypted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.hub, size: 16, color: Color(0xFF27AE60)),
                      SizedBox(width: 6),
                      Text(
                        '12 Nodes Active',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF27AE60)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2994A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Offline Mesh',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.battery_5_bar, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      const Text(
                        '84%',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // App Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        child: const Icon(Icons.record_voice_over, color: Color(0xFF2F80ED), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('iTantra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Mesh Home', style: TextStyle(fontSize: 11, color: Colors.white54)),
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
                            Text(widget.selectedLanguage, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 16, color: Colors.white54),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.radio, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text('WALKIE-TALKIE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.call, size: 16, color: Colors.white70),
                              SizedBox(width: 6),
                              Text('PHONE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF161A22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.graphic_eq, color: Colors.white70, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('CHANNEL 04 · EMERGENCY RE...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          SizedBox(height: 2),
                          Text('Sub-GHz ISM Band (868 MHz)', style: TextStyle(fontSize: 10, color: Colors.white54)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.circle, color: Color(0xFF27AE60), size: 6),
                          SizedBox(width: 4),
                          Text('OPEN', style: TextStyle(color: Color(0xFF27AE60), fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Nearby Peers List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Nearby Peers  (3 active)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Row(
                    children: [
                      Text('Signal Range', style: TextStyle(fontSize: 11, color: Colors.white54)),
                      SizedBox(width: 4),
                      Icon(Icons.tune, size: 14, color: Colors.white54),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _peers.length,
                itemBuilder: (context, index) {
                  final peer = _peers[index];
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
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFF242C38),
                              child: Text(
                                peer.initial,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: peer.statusColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF161A22), width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    peer.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  if (peer.isEncrypted) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.lock_outline, size: 12, color: Colors.white54),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${peer.language}  ·  ${peer.hops} hop${peer.hops > 1 ? 's' : ''}',
                                style: const TextStyle(fontSize: 11, color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(Icons.network_cell, size: 16, color: peer.statusColor),
                            const SizedBox(height: 2),
                            Text(
                              peer.statusText,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: peer.statusColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // PTT Controls & Broadcast Info
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransmittingScreen()),
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
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 2),
            const Text(
              'Transmits audio to all nodes within range\n(approx. 250m)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.white54),
            ),
            const SizedBox(height: 12),

            // Broadcast Priority SOS Button[cite: 1]
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SosEmergencyScreen()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
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
                        'HOLD 3s',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Bottom Navigation
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hub, color: Color(0xFF2F80ED), size: 20),
                      SizedBox(height: 2),
                      Text('Home', style: TextStyle(fontSize: 10, color: Color(0xFF2F80ED), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.white54, size: 20),
                      SizedBox(height: 2),
                      Text('Peers', style: TextStyle(fontSize: 10, color: Colors.white54)),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings_outlined, color: Colors.white54, size: 20),
                      SizedBox(height: 2),
                      Text('Settings', style: TextStyle(fontSize: 10, color: Colors.white54)),
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

// ==========================================
// 3. ACTIVE TRANSMITTING SCREEN (PTT STATE)
// ==========================================
class TransmittingScreen extends StatefulWidget {
  const TransmittingScreen({super.key});

  @override
  State<TransmittingScreen> createState() => _TransmittingScreenState();
}

class _TransmittingScreenState extends State<TransmittingScreen> {
  int _seconds = 22;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _seconds++);
    });
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.hub, size: 16, color: Color(0xFF27AE60)),
                      SizedBox(width: 6),
                      Text(
                        'Mesh Relay Active',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF27AE60)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Offline Mesh', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      SizedBox(width: 8),
                      Icon(Icons.battery_5_bar, size: 16, color: Colors.white70),
                      SizedBox(width: 4),
                      Text('84%', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFF2F80ED),
                        child: Icon(Icons.mic, size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text('Active Node S...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF2F80ED),
                    child: Icon(Icons.person, size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.cell_tower, color: Color(0xFFEB5757), size: 16),
                      SizedBox(width: 6),
                      Text('Broadcast to all nodes', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF241618),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEB5757).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.circle, color: Color(0xFFEB5757), size: 8),
                        SizedBox(width: 8),
                        Text(
                          'CH-01 EMERGENCY ALL-CALL',
                          style: TextStyle(color: Color(0xFFEB5757), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFEB5757), size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Transmitting Pulsing Visualizer
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEB5757).withOpacity(0.08),
                    ),
                  ),
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEB5757).withOpacity(0.2),
                    ),
                  ),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD32F2F),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mic, color: Colors.white, size: 32),
                        const SizedBox(height: 4),
                        const Text(
                          'TRANSMITTING',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          '00:${_seconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Audio Waveform representation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                18,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 3,
                  height: (i % 3 == 0) ? 26 : (i % 2 == 0 ? 16 : 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEB5757),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Mesh Gain: +6dB', style: TextStyle(fontSize: 11, color: Colors.white54)),
                SizedBox(width: 16),
                Text('Low-Latency Opus', style: TextStyle(fontSize: 11, color: Colors.white54)), // Fallback codec[cite: 1]
              ],
            ),
            const Spacer(),
            // Relay Pipeline Indicator[cite: 1]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('RELAY PIPELINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                  Text('Live Transmission', style: TextStyle(fontSize: 11, color: Color(0xFFEB5757), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF241618),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEB5757).withOpacity(0.3)),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.hearing, color: Color(0xFFEB5757), size: 18),
                          SizedBox(height: 4),
                          Text('Listening...', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEB5757))),
                          Text('Live Mic', style: TextStyle(fontSize: 9, color: Colors.white54)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161A22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.graphic_eq, color: Colors.white54, size: 18),
                          SizedBox(height: 4),
                          Text('Processing', style: TextStyle(fontSize: 11, color: Colors.white70)),
                          Text('Neural STT', style: TextStyle(fontSize: 9, color: Colors.white54)), // IndicConformer STT[cite: 1]
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161A22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.hub, color: Colors.white54, size: 18),
                          SizedBox(height: 4),
                          Text('Relaying', style: TextStyle(fontSize: 11, color: Colors.white70)),
                          Text('Mesh Packets', style: TextStyle(fontSize: 9, color: Colors.white54)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF161A22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F80ED).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.translate, color: Color(0xFF2F80ED), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Universal Target Broadcast', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          SizedBox(height: 2),
                          Text(
                            'All 5 reachable peers will receive instant translated audio in their chosen language.',
                            style: TextStyle(fontSize: 10, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F242F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.compare_arrows, size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Switch to Direct P2P Call', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. PRIORITY 1 / SOS EMERGENCY ALERT SCREEN
// ==========================================
class SosEmergencyScreen extends StatelessWidget {
  const SosEmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.hub, size: 16, color: Color(0xFF27AE60)),
                      SizedBox(width: 6),
                      Text('Mesh Relay Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF27AE60))),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Offline Mesh', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      SizedBox(width: 8),
                      Icon(Icons.battery_5_bar, size: 16, color: Colors.white70),
                      SizedBox(width: 4),
                      Text('84%', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                      const SizedBox(width: 4),
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFF2F80ED),
                        child: Icon(Icons.mic, size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text('Sos Emergenc...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF2F80ED),
                    child: Icon(Icons.person, size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Priority 1 Alert Header[cite: 1]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 8),
                        SizedBox(width: 8),
                        Text(
                          'PRIORITY 1 - LIFE SAFETY BROADCAST',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Emergency Alert Content Box
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161A22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEB5757).withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'EMERGENCY\nALERT',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF8A80), height: 1.1),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('EVACUATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'From: Coast Guard Disaster\nResponse Team',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '⏱ Received 1 min ago  ·  Relayed via 4 mesh hops',
                        style: TextStyle(fontSize: 10, color: Colors.white54),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C222C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Icon(Icons.crisis_alert, color: Color(0xFFFF8A80), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Cyclone alert: Evacuate coastal sector B immediately. High tidal surge expected in 45 minutes. Proceed to High School Shelter on Hill Top.',
                                style: TextStyle(fontSize: 12, height: 1.4, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 90,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF222936),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.map_outlined, color: Colors.white38, size: 28),
                            SizedBox(height: 6),
                            Text(
                              'Target Shelter: Sector B Hill Top (2.1 km)',
                              style: TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Non-interruptible high-volume TTS Audio Note Widget[cite: 1]
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C222C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.volume_up, color: Colors.white, size: 16),
                                    SizedBox(width: 6),
                                    Text('Malayalam Voice Broadcast', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                                  child: const Text('100% VOLUME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)), // STREAM_ALARM specification[cite: 1]
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Auto-playing alert voice broadcast in Malayalam (തത്സമയ സുരക്ഷാ നിർദ്ദേശം)',
                              style: TextStyle(fontSize: 10, color: Colors.white54),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                24,
                                (i) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  width: 3,
                                  height: (i % 4 == 0) ? 22 : (i % 2 == 0 ? 14 : 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF8A80),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF161A22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.lock_clock, size: 14, color: Colors.white70),
                        SizedBox(width: 6),
                        Text('Screen locked for safety listening', style: TextStyle(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                    Text('00:05s remaining', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2828),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shield_outlined, size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Acknowledge Safety Alert', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.refresh, size: 16, color: Colors.white70),
                      SizedBox(width: 8),
                      Text('Repeat Audio in Malayalam', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.vibration, size: 14, color: Colors.white38),
                  SizedBox(width: 6),
                  Text('Tactical continuous alert vibration running', style: TextStyle(fontSize: 10, color: Colors.white38)),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}