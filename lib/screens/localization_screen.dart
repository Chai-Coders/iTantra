import 'package:flutter/material.dart';
import '../transceiver_engine.dart';
import 'mesh_home_screen.dart';

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
  // 10 Indian Languages per SIH 2026 Problem ID 26173 specification[cite: 1]
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
                  const Row(
                    children: [
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
              const Row(
                children: [
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
                        color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.graphic_eq,
                          color: Color(0xFF27AE60), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        color: const Color(0xFF27AE60).withValues(alpha: 0.2),
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

                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MeshHomeScreen(
                          selectedLanguage: selected.nativeName,
                          englishLanguage: selected.englishName,
                        ),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
