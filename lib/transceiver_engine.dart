import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'protocol/mesh_codec.dart';
import 'ml_engine.dart';
import 'geo_engine.dart';

enum PacketType { beacon, voiceText, prioritySos }

class TransceiverPacket {
  final String packetId;
  final PacketType type;
  final String senderId;
  final String senderName;
  final String relayedBy;
  final String sourceLang;
  final String targetLang;
  final String content;
  final int timestamp;
  final int hops;
  final int ttl;
  final double latitude;
  final double longitude;

  TransceiverPacket({
    required this.packetId,
    required this.type,
    required this.senderId,
    required this.senderName,
    this.relayedBy = '',
    required this.sourceLang,
    required this.targetLang,
    required this.content,
    required this.timestamp,
    this.hops = 1,
    this.ttl = 4,
    this.latitude = 9.7460,
    this.longitude = 76.6548,
  });

  Map<String, dynamic> toJson() => {
        'packetId': packetId,
        'type': type.name,
        'senderId': senderId,
        'senderName': senderName,
        'relayedBy': relayedBy,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'content': content,
        'timestamp': timestamp,
        'hops': hops,
        'ttl': ttl,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory TransceiverPacket.fromJson(Map<String, dynamic> json) =>
      TransceiverPacket(
        packetId: json['packetId'] ?? 'pkt_${DateTime.now().microsecondsSinceEpoch}',
        type: PacketType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => PacketType.beacon,
        ),
        senderId: json['senderId'] ?? 'Unknown',
        senderName: json['senderName'] ?? 'Mesh Node',
        relayedBy: json['relayedBy'] ?? '',
        sourceLang: json['sourceLang'] ?? 'English',
        targetLang: json['targetLang'] ?? 'Malayalam',
        content: json['content'] ?? '',
        timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
        hops: json['hops'] ?? 1,
        ttl: json['ttl'] ?? 4,
        latitude: (json['latitude'] as num?)?.toDouble() ?? 9.7460,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 76.6548,
      );
}

class DiscoveredPeer {
  final String id;
  final String name;
  final String language;
  final String ip;
  DateTime lastSeen;
  int hops;
  final double latitude;
  final double longitude;
  final bool isSimulated;

  DiscoveredPeer({
    required this.id,
    required this.name,
    required this.language,
    required this.ip,
    required this.lastSeen,
    this.hops = 1,
    this.latitude = 9.7460,
    this.longitude = 76.6548,
    this.isSimulated = false,
  });

  double get distanceMeters => GeoEngine().calculateDistance(
        GeoEngine().currentLocation,
        GeoCoordinates(latitude: latitude, longitude: longitude),
      );

  double get bearingDegrees => GeoEngine().calculateBearing(
        GeoEngine().currentLocation,
        GeoCoordinates(latitude: latitude, longitude: longitude),
      );
}

class TransceiverEngine {
  static final TransceiverEngine _instance = TransceiverEngine._internal();
  factory TransceiverEngine() => _instance;
  TransceiverEngine._internal();

  static const int meshPort = 8888;
  static const int defaultTtl = 4;
  static const int maxSeenCache = 500;

  RawDatagramSocket? _socket;
  Timer? _beaconTimer;
  Timer? _simulationTimer;

  late String nodeId;
  late String nodeName;
  late String primaryLanguage;
  String localIp = '127.0.0.1';

  bool relayEnabled = true;
  bool simulationActive = false;
  bool useBinaryProtocol = true;

  final ValueNotifier<int> packetsSentNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> packetsReceivedNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> packetsRelayedNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> lastWireBytesNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String> logNotifier = ValueNotifier<String>('Initialized');

  final Set<String> _seenPacketIds = {};
  final List<String> _seenOrder = [];

  final Map<String, DiscoveredPeer> _activePeers = {};
  final _peerStreamController = StreamController<List<DiscoveredPeer>>.broadcast();
  final _incomingPacketController = StreamController<TransceiverPacket>.broadcast();

  Stream<List<DiscoveredPeer>> get peerStream => _peerStreamController.stream;
  Stream<TransceiverPacket> get packetStream => _incomingPacketController.stream;
  List<DiscoveredPeer> get currentPeers => _activePeers.values.toList();

  Future<void> start({
    required String name,
    required String language,
  }) async {
    nodeId = 'node_${DateTime.now().millisecondsSinceEpoch % 10000}';
    nodeName = name;
    primaryLanguage = language;

    final randOffset = (Random().nextInt(40) - 20) / 10000.0;
    GeoEngine().updateLocation(
      9.7460 + randOffset,
      76.6548 + randOffset,
    );

    await _refreshLocalIp();

    try {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        meshPort,
        reuseAddress: true,
        reusePort: false,
      );
      _socket?.broadcastEnabled = true;

      _socket?.listen(
        (RawSocketEvent event) {
          if (event == RawSocketEvent.read) {
            final datagram = _socket?.receive();
            if (datagram != null) {
              _handleIncomingDatagram(datagram);
            }
          }
        },
        onError: (err) {
          logNotifier.value = 'Socket err: $err';
        },
      );

      logNotifier.value = 'Mesh active on $localIp:$meshPort';
    } catch (e) {
      logNotifier.value = 'Bind fail: $e';
    }

    _sendBeacon();

    _beaconTimer?.cancel();
    _beaconTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _refreshLocalIp();
      _sendBeacon();
      _pruneStalePeers();
    });
  }

  Future<void> _refreshLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (var iface in interfaces) {
        for (var addr in iface.addresses) {
          if (!addr.isLoopback && addr.address != '127.0.0.1') {
            localIp = addr.address;
            return;
          }
        }
      }
    } catch (_) {}
  }

  Future<Set<InternetAddress>> _resolveBroadcastDestinations() async {
    final destinations = <InternetAddress>{
      InternetAddress('255.255.255.255'),
      InternetAddress('192.168.43.255'),
      InternetAddress('192.168.43.1'),
    };

    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (var iface in interfaces) {
        for (var addr in iface.addresses) {
          if (!addr.isLoopback) {
            final parts = addr.address.split('.');
            if (parts.length == 4) {
              destinations.add(InternetAddress('${parts[0]}.${parts[1]}.${parts[2]}.255'));
              destinations.add(InternetAddress('${parts[0]}.${parts[1]}.${parts[2]}.1'));
            }
          }
        }
      }
    } catch (_) {}

    return destinations;
  }

  String _generatePacketId() {
    final rand = Random().nextInt(9999);
    return 'p_${nodeId}_${DateTime.now().microsecondsSinceEpoch}_$rand';
  }

  void _markSeen(String pid) {
    if (_seenPacketIds.contains(pid)) return;
    if (_seenOrder.length >= maxSeenCache) {
      final oldest = _seenOrder.removeAt(0);
      _seenPacketIds.remove(oldest);
    }
    _seenOrder.add(pid);
    _seenPacketIds.add(pid);
  }

  void _sendBeacon() {
    final pid = _generatePacketId();
    _markSeen(pid);

    final packet = TransceiverPacket(
      packetId: pid,
      type: PacketType.beacon,
      senderId: nodeId,
      senderName: nodeName,
      sourceLang: primaryLanguage,
      targetLang: '',
      content: 'BEACON_PING',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      hops: 1,
      ttl: 1,
      latitude: GeoEngine().currentLocation.latitude,
      longitude: GeoEngine().currentLocation.longitude,
    );
    _broadcast(packet);
  }

  void broadcastVoiceText({
    required String text,
    required String targetLang,
  }) {
    final pid = _generatePacketId();
    _markSeen(pid);

    final payload = EdgeMlEngine().processTransmission(
      rawText: text,
      sourceLang: primaryLanguage,
      targetLang: targetLang,
    );

    final packet = TransceiverPacket(
      packetId: pid,
      type: PacketType.voiceText,
      senderId: nodeId,
      senderName: nodeName,
      sourceLang: primaryLanguage,
      targetLang: targetLang,
      content: payload.translatedText,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      hops: 1,
      ttl: defaultTtl,
      latitude: payload.latitude,
      longitude: payload.longitude,
    );
    _broadcast(packet);
  }

  void broadcastSos({
    required String alertText,
  }) {
    final pid = _generatePacketId();
    _markSeen(pid);

    final payload = EdgeMlEngine().processTransmission(
      rawText: alertText,
      sourceLang: primaryLanguage,
      targetLang: 'ALL',
    );

    final packet = TransceiverPacket(
      packetId: pid,
      type: PacketType.prioritySos,
      senderId: nodeId,
      senderName: nodeName,
      sourceLang: primaryLanguage,
      targetLang: 'ALL',
      content: payload.translatedText,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      hops: 1,
      ttl: defaultTtl + 2,
      latitude: payload.latitude,
      longitude: payload.longitude,
    );
    _broadcast(packet);
  }

  Future<void> _broadcast(TransceiverPacket packet) async {
    if (_socket == null) return;

    try {
      final List<int> wireData = useBinaryProtocol
          ? MeshCodec.encode(packet)
          : utf8.encode(jsonEncode(packet.toJson()));

      lastWireBytesNotifier.value = wireData.length;
      final destinations = await _resolveBroadcastDestinations();

      for (var target in destinations) {
        try {
          _socket?.send(wireData, target, meshPort);
        } catch (_) {}
      }

      packetsSentNotifier.value++;
      logNotifier.value = 'TX ${wireData.length}B (${packet.type.name}, Hop:${packet.hops})';
    } catch (e) {
      logNotifier.value = 'Broadcast fail: $e';
    }
  }

  void _handleIncomingDatagram(Datagram datagram) {
    try {
      final packet = MeshCodec.decode(datagram.data);

      if (packet.senderId == nodeId) return;
      if (_seenPacketIds.contains(packet.packetId)) return;

      _markSeen(packet.packetId);
      packetsReceivedNotifier.value++;
      lastWireBytesNotifier.value = datagram.data.length;

      final senderIp = datagram.address.address;

      _activePeers[packet.senderId] = DiscoveredPeer(
        id: packet.senderId,
        name: packet.senderName,
        language: packet.sourceLang,
        ip: senderIp,
        lastSeen: DateTime.now(),
        hops: packet.hops,
        latitude: packet.latitude,
        longitude: packet.longitude,
      );
      _peerStreamController.add(_activePeers.values.toList());

      // Edge translation into this node's primary language if required
      String localContent = packet.content;
      if (packet.targetLang != primaryLanguage && packet.targetLang != 'ALL') {
        final trans = EdgeMlEngine().processTransmission(
          rawText: packet.content,
          sourceLang: packet.sourceLang,
          targetLang: primaryLanguage,
        );
        localContent = trans.translatedText;
      }

      final deliveredPacket = TransceiverPacket(
        packetId: packet.packetId,
        type: packet.type,
        senderId: packet.senderId,
        senderName: packet.senderName,
        relayedBy: packet.relayedBy,
        sourceLang: packet.sourceLang,
        targetLang: primaryLanguage,
        content: localContent,
        timestamp: packet.timestamp,
        hops: packet.hops,
        ttl: packet.ttl,
        latitude: packet.latitude,
        longitude: packet.longitude,
      );

      if (deliveredPacket.type != PacketType.beacon) {
        _incomingPacketController.add(deliveredPacket);
      }

      if (relayEnabled && packet.ttl > 1 && packet.type != PacketType.beacon) {
        _scheduleRelayForward(packet);
      }
    } catch (e) {
      logNotifier.value = 'Parse error: $e';
    }
  }

  void _scheduleRelayForward(TransceiverPacket inbound) {
    final jitterMs = 40 + Random().nextInt(80);

    Timer(Duration(milliseconds: jitterMs), () {
      final relayedPacket = TransceiverPacket(
        packetId: inbound.packetId,
        type: inbound.type,
        senderId: inbound.senderId,
        senderName: inbound.senderName,
        relayedBy: nodeId,
        sourceLang: inbound.sourceLang,
        targetLang: inbound.targetLang,
        content: inbound.content,
        timestamp: inbound.timestamp,
        hops: inbound.hops + 1,
        ttl: inbound.ttl - 1,
        latitude: inbound.latitude,
        longitude: inbound.longitude,
      );

      _broadcast(relayedPacket);
      packetsRelayedNotifier.value++;
      logNotifier.value = 'Relayed packet from ${inbound.senderName} (Hop ${relayedPacket.hops})';
    });
  }

  void _pruneStalePeers() {
    final threshold = DateTime.now().subtract(const Duration(seconds: 8));
    final beforeCount = _activePeers.length;

    _activePeers.removeWhere(
      (_, peer) => !peer.isSimulated && peer.lastSeen.isBefore(threshold),
    );

    if (beforeCount != _activePeers.length) {
      _peerStreamController.add(_activePeers.values.toList());
    }
  }

  void setSimulationMode(bool enable) {
    simulationActive = enable;
    _simulationTimer?.cancel();

    if (!enable) {
      _activePeers.removeWhere((_, peer) => peer.isSimulated);
      _peerStreamController.add(_activePeers.values.toList());
      logNotifier.value = 'Simulation deactivated';
      return;
    }

    _injectSimulatedPeers();
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _injectSimulatedPeers();
    });
    logNotifier.value = 'Judge presentation mode active';
  }

  void _injectSimulatedPeers() {
    final now = DateTime.now();

    _activePeers['sim_kl'] = DiscoveredPeer(
      id: 'node_KL01',
      name: 'Node-KL (Kottayam Base)',
      language: 'Malayalam',
      ip: '192.168.43.14',
      lastSeen: now,
      hops: 1,
      latitude: 9.7510,
      longitude: 76.6590,
      isSimulated: true,
    );

    _activePeers['sim_tn'] = DiscoveredPeer(
      id: 'node_TN44',
      name: 'Node-TN (Relay Post B)',
      language: 'Tamil',
      ip: '192.168.43.88',
      lastSeen: now,
      hops: 2,
      latitude: 9.7380,
      longitude: 76.6490,
      isSimulated: true,
    );

    _activePeers['sim_wb'] = DiscoveredPeer(
      id: 'node_WB09',
      name: 'Node-WB (Sector Edge)',
      language: 'Bengali',
      ip: '192.168.43.119',
      lastSeen: now,
      hops: 3,
      latitude: 9.7620,
      longitude: 76.6710,
      isSimulated: true,
    );

    _peerStreamController.add(_activePeers.values.toList());
  }

  void forceBeacon() {
    _sendBeacon();
  }

  void stop() {
    _beaconTimer?.cancel();
    _simulationTimer?.cancel();
    _socket?.close();
  }
}