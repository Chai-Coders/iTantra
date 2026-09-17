import 'dart:math';
import 'package:flutter/material.dart';
import '../speech_engine.dart';
import '../geo_engine.dart';

class SosEmergencyScreen extends StatefulWidget {
  final String sender;
  final String alertText;
  final int hops;
  final String language;
  final double incidentLat;
  final double incidentLon;

  const SosEmergencyScreen({
    super.key,
    required this.sender,
    required this.alertText,
    required this.hops,
    required this.language,
    this.incidentLat = 9.7540,
    this.incidentLon = 76.6620,
  });

  @override
  State<SosEmergencyScreen> createState() => _SosEmergencyScreenState();
}

class _SosEmergencyScreenState extends State<SosEmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  late double _distanceMeters;
  late double _bearingDegrees;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    final origin = GeoEngine().currentLocation;
    final incident = GeoCoordinates(
      latitude: widget.incidentLat,
      longitude: widget.incidentLon,
    );

    _distanceMeters = GeoEngine().calculateDistance(origin, incident);
    _bearingDegrees = GeoEngine().calculateBearing(origin, incident);
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        await SpeechEngine().stop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C0E12),
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
                    const Text(
                      'Priority 1 Inbound Alert',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
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
                      Text(
                        'PRIORITY 1 - LIFE SAFETY BROADCAST',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Icon(Icons.priority_high, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'EMERGENCY ALERT',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF8A80),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD32F2F),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'EVACUATION',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'From: ${widget.sender}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '⏱ Relayed via ${widget.hops} mesh hop(s) · Local Geodesic Bearing',
                          style: const TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C222C),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.alertText,
                            style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Offline Dynamic Radar using actual geodesic calculations
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF13171F),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: AnimatedBuilder(
                              animation: _radarController,
                              builder: (context, _) {
                                return CustomPaint(
                                  painter: TacticalRadarPainter(
                                    sweepAngle: _radarController.value * 2 * pi,
                                    targetBearingDegrees: _bearingDegrees,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'BEARING ${_bearingDegrees.toStringAsFixed(0).padLeft(3, '0')}° · ${GeoEngine().formatDistance(_distanceMeters)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF27AE60),
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Target Waypoint: ${widget.incidentLat.toStringAsFixed(4)}°N, ${widget.incidentLon.toStringAsFixed(4)}°E',
                                          style: const TextStyle(fontSize: 10, color: Colors.white60),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C222C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.volume_up, color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${widget.language} Voice Synth Alert',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '100% STREAM_ALARM',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
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
                    child: const Text(
                      'Acknowledge Safety Alert',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: TextButton(
                    onPressed: () {
                      SpeechEngine().playEmergencyAlert(
                        text: widget.alertText,
                        language: widget.language,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh, size: 16, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text(
                          'Repeat Audio in ${widget.language}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class TacticalRadarPainter extends CustomPainter {
  final double sweepAngle;
  final double targetBearingDegrees;

  TacticalRadarPainter({
    required this.sweepAngle,
    required this.targetBearingDegrees,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 10);
    final radius = min(size.width / 2 - 20, size.height / 2 - 24);

    final ringPaint = Paint()
      ..color = const Color(0xFF27AE60).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius * 0.33, ringPaint);
    canvas.drawCircle(center, radius * 0.66, ringPaint);
    canvas.drawCircle(center, radius, ringPaint);

    final axisPaint = Paint()
      ..color = const Color(0xFF27AE60).withValues(alpha: 0.2)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), axisPaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), axisPaint);

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: FractionalOffset(center.dx / size.width, center.dy / size.height),
        startAngle: 0.0,
        endAngle: pi * 2,
        colors: [
          const Color(0xFF27AE60).withValues(alpha: 0.0),
          const Color(0xFF27AE60).withValues(alpha: 0.35),
        ],
        stops: const [0.85, 1.0],
        transform: GradientRotation(sweepAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);

    // Geodesic bearing position (0° points straight up)
    final bearingRad = (targetBearingDegrees - 90) * (pi / 180);
    final blipPos = Offset(
      center.dx + (radius * 0.72) * cos(bearingRad),
      center.dy + (radius * 0.72) * sin(bearingRad),
    );

    final blipPaint = Paint()..color = const Color(0xFF27AE60);
    canvas.drawCircle(blipPos, 5, blipPaint);

    final blipGlow = Paint()
      ..color = const Color(0xFF27AE60).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(blipPos, 9, blipGlow);
  }

  @override
  bool shouldRepaint(covariant TacticalRadarPainter oldDelegate) =>
      oldDelegate.sweepAngle != sweepAngle ||
      oldDelegate.targetBearingDegrees != targetBearingDegrees;
}