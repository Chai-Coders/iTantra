import 'dart:async';
import 'dart:convert';
import 'dart:io';

enum PacketType { beacon, voiceText, prioritySos }

class TransceiverPacket {
  final PacketType type;
  final String senderId;
  final String senderName;
  final String sourceLang;
  final String targetLang;
  final String content;
  final int timestamp;
  final int hops;

  TransceiverPacket({
    required this.type,
    required this.senderId,
    required this.senderName,
    required this.sourceLang,
    required this.targetLang,
    required this.content,
    required this.timestamp,
    this.hops = 1,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'senderId': senderId,
        'senderName': senderName,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'content': content,
        'timestamp': timestamp,
        'hops': hops,
      };

  factory TransceiverPacket.fromJson(Map<String, dynamic> json) =>
      TransceiverPacket(
        type: PacketType.values.firstWhere((e) => e.name == json['type']),
        senderId: json['senderId'] ?? 'Unknown',
        senderName: json['senderName'] ?? 'Mesh Node',
        sourceLang: json['sourceLang'] ?? 'English',
        targetLang: json['targetLang'] ?? 'Malayalam',
        content: json['content'] ?? '',
        timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
        hops: json['hops'] ?? 1,
      );
}

class DiscoveredPeer {
  final String id;
  final String name;
  final String language;
  DateTime lastSeen;
  int hops;

  DiscoveredPeer({
    required this.id,
    required this.name,
    required this.language,
    required this.lastSeen,
    this.hops = 1,
  });
}

class TransceiverEngine {
  static final TransceiverEngine _instance = TransceiverEngine._internal();
  factory TransceiverEngine() => _instance;
  TransceiverEngine._internal();

  static const int meshPort = 8888;
  RawDatagramSocket? _socket;
  Timer? _beaconTimer;

  late String nodeId;
  late String nodeName;
  late String primaryLanguage;

  final Map<String, DiscoveredPeer> _activePeers = {};
  final _peerStreamController =
      StreamController<List<DiscoveredPeer>>.broadcast();
  final _incomingPacketController =
      StreamController<TransceiverPacket>.broadcast();

  Stream<List<DiscoveredPeer>> get peerStream => _peerStreamController.stream;
  Stream<TransceiverPacket> get packetStream =>
      _incomingPacketController.stream;
  List<DiscoveredPeer> get currentPeers => _activePeers.values.toList();

  Future<void> start({
    required String name,
    required String language,
  }) async {
    nodeId = 'node_${DateTime.now().millisecondsSinceEpoch % 10000}';
    nodeName = name;
    primaryLanguage = language;

    _socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      meshPort,
      reuseAddress: true,
      reusePort: true,
    );
    _socket?.broadcastEnabled = true;

    _socket?.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = _socket?.receive();
        if (datagram != null) {
          _handleIncomingDatagram(datagram.data);
        }
      }
    });

    // Broadcast node presence every 3 seconds to keep mesh peer table warm[cite: 1, 5]
    _beaconTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _sendBeacon();
      _pruneStalePeers();
    });
  }

  void _sendBeacon() {
    final packet = TransceiverPacket(
      type: PacketType.beacon,
      senderId: nodeId,
      senderName: nodeName,
      sourceLang: primaryLanguage,
      targetLang: '',
      content: 'READY',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    _broadcast(packet);
  }

  void broadcastVoiceText({
    required String text,
    required String targetLang,
  }) {
    final packet = TransceiverPacket(
      type: PacketType.voiceText,
      senderId: nodeId,
      senderName: nodeName,
      sourceLang: primaryLanguage,
      targetLang: targetLang,
      content: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    _broadcast(packet);
  }

  void broadcastSos({
    required String alertText,
  }) {
    final packet = TransceiverPacket(
      type: PacketType.prioritySos,
      senderId: nodeId,
      senderName: nodeName,
      sourceLang: primaryLanguage,
      targetLang: 'ALL',
      content: alertText,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    _broadcast(packet);
  }

  void _broadcast(TransceiverPacket packet) {
    if (_socket == null) return;
    final jsonStr = jsonEncode(packet.toJson());
    final data = utf8.encode(jsonStr);
    _socket?.send(data, InternetAddress('255.255.255.255'), meshPort);
  }

  void _handleIncomingDatagram(List<int> data) {
    try {
      final jsonStr = utf8.decode(data);
      final packet = TransceiverPacket.fromJson(jsonDecode(jsonStr));

      // Disregard self-broadcasts
      if (packet.senderId == nodeId) return;

      // Update peer registry
      _activePeers[packet.senderId] = DiscoveredPeer(
        id: packet.senderId,
        name: packet.senderName,
        language: packet.sourceLang,
        lastSeen: DateTime.now(),
        hops: packet.hops,
      );
      _peerStreamController.add(_activePeers.values.toList());

      // Forward packet to application layer
      _incomingPacketController.add(packet);
    } catch (_) {
      // Drop malformed packets to protect mesh integrity[cite: 1]
    }
  }

  void _pruneStalePeers() {
    final threshold = DateTime.now().subtract(const Duration(seconds: 10));
    _activePeers.removeWhere((_, peer) => peer.lastSeen.isBefore(threshold));
    _peerStreamController.add(_activePeers.values.toList());
  }

  void stop() {
    _beaconTimer?.cancel();
    _socket?.close();
  }
}