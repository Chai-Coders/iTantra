import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

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
  final String ip;
  DateTime lastSeen;
  int hops;

  DiscoveredPeer({
    required this.id,
    required this.name,
    required this.language,
    required this.ip,
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
  String localIp = '127.0.0.1';

  final ValueNotifier<int> packetsSentNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> packetsReceivedNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String> logNotifier = ValueNotifier<String>('Initialized');

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
          logNotifier.value = 'Socket error: $err';
        },
      );

      logNotifier.value = 'Bound on $localIp:$meshPort';
    } catch (e) {
      logNotifier.value = 'Bind failed: $e';
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
      InternetAddress('192.168.43.255'), // Standard Android Hotspot Broadcast
      InternetAddress('192.168.43.1'),   // Hotspot Gateway Node
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
              // Direct subnet broadcast
              destinations.add(InternetAddress('${parts[0]}.${parts[1]}.${parts[2]}.255'));
              // Direct gateway probe
              destinations.add(InternetAddress('${parts[0]}.${parts[1]}.${parts[2]}.1'));
            }
          }
        }
      }
    } catch (_) {}

    return destinations;
  }

  void _sendBeacon() {
    final packet = TransceiverPacket(
      type: PacketType.beacon,
      senderId: nodeId,
      senderName: nodeName,
      sourceLang: primaryLanguage,
      targetLang: '',
      content: 'BEACON_PING',
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

  Future<void> _broadcast(TransceiverPacket packet) async {
    if (_socket == null) return;

    try {
      final jsonStr = jsonEncode(packet.toJson());
      final data = utf8.encode(jsonStr);
      final destinations = await _resolveBroadcastDestinations();

      for (var target in destinations) {
        try {
          _socket?.send(data, target, meshPort);
        } catch (_) {}
      }

      packetsSentNotifier.value++;
      logNotifier.value = 'Sent ${packet.type.name} to ${destinations.length} targets';
    } catch (e) {
      logNotifier.value = 'Broadcast fail: $e';
    }
  }

  void _handleIncomingDatagram(Datagram datagram) {
    try {
      final jsonStr = utf8.decode(datagram.data);
      final packet = TransceiverPacket.fromJson(jsonDecode(jsonStr));

      // Ignore packets sent by this own node
      if (packet.senderId == nodeId) return;

      packetsReceivedNotifier.value++;
      final senderIp = datagram.address.address;

      _activePeers[packet.senderId] = DiscoveredPeer(
        id: packet.senderId,
        name: packet.senderName,
        language: packet.sourceLang,
        ip: senderIp,
        lastSeen: DateTime.now(),
        hops: packet.hops,
      );

      _peerStreamController.add(_activePeers.values.toList());
      logNotifier.value = 'Received from ${packet.senderName} ($senderIp)';

      if (packet.type != PacketType.beacon) {
        _incomingPacketController.add(packet);
      }
    } catch (e) {
      logNotifier.value = 'Packet parse error: $e';
    }
  }

  void _pruneStalePeers() {
    final threshold = DateTime.now().subtract(const Duration(seconds: 8));
    final beforeCount = _activePeers.length;
    _activePeers.removeWhere((_, peer) => peer.lastSeen.isBefore(threshold));

    if (beforeCount != _activePeers.length) {
      _peerStreamController.add(_activePeers.values.toList());
    }
  }

  void forceBeacon() {
    _sendBeacon();
  }

  void stop() {
    _beaconTimer?.cancel();
    _socket?.close();
  }
}